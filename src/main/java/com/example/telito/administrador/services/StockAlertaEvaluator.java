package com.example.telito.administrador.services;

import com.example.telito.administrador.beans.AlertaConfig;
import com.example.telito.administrador.beans.StockMinimoConfig;
import com.example.telito.administrador.daos.StockMinimoDAO;
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.almacen.beans.Lote;
import com.example.telito.administrador.daos.ProductoDAO;
import com.example.telito.administrador.beans.Producto;

import java.util.*;

// Evalúa alertas de stock mínimo y crítico (por lote o por producto total)
public class StockAlertaEvaluator {
    
    private final StockMinimoDAO stockMinimoDAO;
    private final LoteDao loteDao;
    private final ProductoDAO productoDAO;
    
    public StockAlertaEvaluator(StockMinimoDAO stockMinimoDAO, LoteDao loteDao, ProductoDAO productoDAO) {
        this.stockMinimoDAO = stockMinimoDAO;
        this.loteDao = loteDao;
        this.productoDAO = productoDAO;
    }
    
    // Evalúa alertas de stock según la regla configurada
    public List<AlertaService.AlertaGenerada> evaluarStock(AlertaConfig regla, Map<String, Object> config) {
        List<AlertaService.AlertaGenerada> alertas = new ArrayList<>();
        
        String tipoAlerta = regla.getTipoAlerta();
        
        if ("STOCK_MINIMO".equals(tipoAlerta) || "STOCK_CRITICO".equals(tipoAlerta)) {
            // Evaluar por lote individual
            if (config.containsKey("stock_minimo_lote") || config.containsKey("stock_critico_lote")) {
                alertas.addAll(evaluarStockPorLote(regla, config));
            }
            
            // Evaluar por stock total del producto
            if (config.containsKey("stock_minimo_producto") || config.containsKey("stock_critico_producto")) {
                alertas.addAll(evaluarStockPorProducto(regla, config));
            }
        }
        
        return alertas;
    }
    
    // Evalúa stock por lote individual
    private List<AlertaService.AlertaGenerada> evaluarStockPorLote(AlertaConfig regla, Map<String, Object> config) {
        List<AlertaService.AlertaGenerada> alertas = new ArrayList<>();
        
        try {
            // Obtener todos los lotes registrados
            ArrayList<Lote> lotes = loteDao.listarLotesRegistrados(1);
            
            for (Lote lote : lotes) {
                // Obtener configuración de stock mínimo para este producto
                StockMinimoConfig stockConfig = stockMinimoDAO.obtenerPorProducto(lote.getProductoId());
                
                if (stockConfig == null || !stockConfig.isActivo()) {
                    continue; // No hay configuración para este producto
                }
                
                // Obtener información del producto desde la BD
                // Necesitamos obtener unidades_por_paquete del producto
                int unidadesPorPaquete = obtenerUnidadesPorPaquete(lote.getProductoId());
                String nombreProducto = obtenerNombreProducto(lote.getProductoId());
                if (nombreProducto == null) continue;
                
                int paquetesDisponibles = lote.getStockActual() / unidadesPorPaquete;
                
                // Verificar stock crítico
                if (paquetesDisponibles <= stockConfig.getStockCriticoLote()) {
                    AlertaService.AlertaGenerada alerta = crearAlertaStock(
                        regla, lote, nombreProducto, paquetesDisponibles, 
                        stockConfig.getStockCriticoLote(), "CRITICAL", "crítico"
                    );
                    alertas.add(alerta);
                }
                // Verificar stock mínimo
                else if (paquetesDisponibles <= stockConfig.getStockMinimoLote()) {
                    AlertaService.AlertaGenerada alerta = crearAlertaStock(
                        regla, lote, nombreProducto, paquetesDisponibles, 
                        stockConfig.getStockMinimoLote(), "WARNING", "mínimo"
                    );
                    alertas.add(alerta);
                }
            }
        } catch (Exception e) {
            System.err.println("Error al evaluar stock por lote: " + e.getMessage());
            e.printStackTrace();
        }
        
        return alertas;
    }
    
    /**
     * Evalúa stock mínimo/crítico por producto total (suma de todos los lotes).
     */
    private List<AlertaService.AlertaGenerada> evaluarStockPorProducto(AlertaConfig regla, Map<String, Object> config) {
        List<AlertaService.AlertaGenerada> alertas = new ArrayList<>();
        
        try {
            // Obtener todos los productos activos
            ArrayList<Producto> productos = productoDAO.listarProductos();
            
            for (Producto producto : productos) {
                // Obtener configuración de stock mínimo
                StockMinimoConfig stockConfig = stockMinimoDAO.obtenerPorProducto(producto.getIdProducto());
                
                if (stockConfig == null || !stockConfig.isActivo()) {
                    continue;
                }
                
                // Calcular stock total del producto (suma de todos los lotes)
                ArrayList<Lote> lotesProducto = loteDao.buscarLotesPorProducto(producto.getIdProducto());
                
                int stockTotalUnidades = 0;
                for (Lote lote : lotesProducto) {
                    stockTotalUnidades += lote.getStockActual();
                }
                
                int unidadesPorPaquete = producto.getUnidadesPorPaquete();
                if (unidadesPorPaquete <= 0) unidadesPorPaquete = 1;
                
                int paquetesTotales = stockTotalUnidades / unidadesPorPaquete;
                
                // Verificar stock crítico total
                if (paquetesTotales <= stockConfig.getStockCriticoProducto()) {
                    AlertaService.AlertaGenerada alerta = crearAlertaStockTotal(
                        regla, producto, paquetesTotales, 
                        stockConfig.getStockCriticoProducto(), "CRITICAL", "crítico"
                    );
                    alertas.add(alerta);
                }
                // Verificar stock mínimo total
                else if (paquetesTotales <= stockConfig.getStockMinimoProducto()) {
                    AlertaService.AlertaGenerada alerta = crearAlertaStockTotal(
                        regla, producto, paquetesTotales, 
                        stockConfig.getStockMinimoProducto(), "WARNING", "mínimo"
                    );
                    alertas.add(alerta);
                }
            }
        } catch (Exception e) {
            System.err.println("Error al evaluar stock por producto: " + e.getMessage());
            e.printStackTrace();
        }
        
        return alertas;
    }
    
    /**
     * Obtiene las unidades por paquete de un producto.
     */
    private int obtenerUnidadesPorPaquete(int productoId) {
        String sql = "SELECT unidades_por_paquete FROM productos WHERE id_producto = ?";
        try (var conn = com.example.telito.util.DatabaseConnection.getConnection();
             var pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productoId);
            try (var rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int unidades = rs.getInt("unidades_por_paquete");
                    return unidades > 0 ? unidades : 1;
                }
            }
        } catch (Exception e) {
            System.err.println("Error al obtener unidades por paquete: " + e.getMessage());
        }
        return 1; // Valor por defecto
    }
    
    /**
     * Obtiene el nombre de un producto.
     */
    private String obtenerNombreProducto(int productoId) {
        String sql = "SELECT nombre FROM productos WHERE id_producto = ?";
        try (var conn = com.example.telito.util.DatabaseConnection.getConnection();
             var pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productoId);
            try (var rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("nombre");
                }
            }
        } catch (Exception e) {
            System.err.println("Error al obtener nombre del producto: " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Crea una alerta de stock para un lote específico.
     */
    private AlertaService.AlertaGenerada crearAlertaStock(
            AlertaConfig regla, Lote lote, String nombreProducto, 
            int paquetesActuales, int umbral, String nivel, String tipoUmbral) {
        
        AlertaService.AlertaGenerada alerta = new AlertaService.AlertaGenerada();
        alerta.setAlertaConfigId(regla.getIdAlertaConfig());
        alerta.setTipoAlerta(regla.getTipoAlerta());
        alerta.setNivel(nivel);
        alerta.setLoteId(lote.getIdLote());
        alerta.setLoteCodigo(lote.getCodigoLote());
        alerta.setProductoId(lote.getProductoId());
        alerta.setProductoNombre(nombreProducto);
        
        // Generar mensaje
        String mensaje = String.format(
            "Stock %s en lote %s (%s): %d paquetes disponibles (umbral: %d paquetes)",
            tipoUmbral, lote.getCodigoLote(), nombreProducto, paquetesActuales, umbral
        );
        
        // Usar mensaje personalizado si existe
        if (regla.getMensajePersonalizado() != null && !regla.getMensajePersonalizado().isEmpty()) {
            mensaje = regla.getMensajePersonalizado()
                .replace("{lote}", lote.getCodigoLote())
                .replace("{producto}", nombreProducto)
                .replace("{stock_actual}", paquetesActuales + " paquetes")
                .replace("{umbral}", umbral + " paquetes");
        }
        
        alerta.setMensaje(mensaje);
        return alerta;
    }
    
    /**
     * Crea una alerta de stock para un producto total.
     */
    private AlertaService.AlertaGenerada crearAlertaStockTotal(
            AlertaConfig regla, Producto producto, 
            int paquetesTotales, int umbral, String nivel, String tipoUmbral) {
        
        AlertaService.AlertaGenerada alerta = new AlertaService.AlertaGenerada();
        alerta.setAlertaConfigId(regla.getIdAlertaConfig());
        alerta.setTipoAlerta(regla.getTipoAlerta());
        alerta.setNivel(nivel);
        alerta.setProductoId(producto.getIdProducto());
        alerta.setProductoNombre(producto.getNombre());
        
        // Generar mensaje
        String mensaje = String.format(
            "Stock %s total en producto %s: %d paquetes disponibles (umbral: %d paquetes)",
            tipoUmbral, producto.getNombre(), paquetesTotales, umbral
        );
        
        // Usar mensaje personalizado si existe
        if (regla.getMensajePersonalizado() != null && !regla.getMensajePersonalizado().isEmpty()) {
            mensaje = regla.getMensajePersonalizado()
                .replace("{producto}", producto.getNombre())
                .replace("{stock_actual}", paquetesTotales + " paquetes")
                .replace("{umbral}", umbral + " paquetes");
        }
        
        alerta.setMensaje(mensaje);
        return alerta;
    }
}

