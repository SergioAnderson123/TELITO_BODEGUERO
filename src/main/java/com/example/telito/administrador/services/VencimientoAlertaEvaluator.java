package com.example.telito.administrador.services;

import com.example.telito.administrador.beans.AlertaConfig;
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.almacen.beans.Lote;

import java.util.*;
import java.util.Calendar;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.example.telito.util.DatabaseConnection;

/**
 * Evaluador especializado para alertas de vencimiento de productos.
 */
public class VencimientoAlertaEvaluator {
    
    private final LoteDao loteDao;
    
    public VencimientoAlertaEvaluator(LoteDao loteDao) {
        this.loteDao = loteDao;
    }
    
    /**
     * Evalúa las alertas de vencimiento según la regla configurada.
     */
    public List<AlertaService.AlertaGenerada> evaluarVencimientos(AlertaConfig regla, Map<String, Object> config) {
        List<AlertaService.AlertaGenerada> alertas = new ArrayList<>();
        
        try {
            // Obtener todos los lotes registrados con fecha de vencimiento
            ArrayList<Lote> lotes = loteDao.listarLotesRegistrados(1);
            
            // Obtener umbrales de días desde la configuración o la regla
            Integer diasProximo = obtenerDiasProximo(config, regla);
            Integer diasCritico = obtenerDiasCritico(config);
            
            Calendar hoy = Calendar.getInstance();
            hoy.set(Calendar.HOUR_OF_DAY, 0);
            hoy.set(Calendar.MINUTE, 0);
            hoy.set(Calendar.SECOND, 0);
            hoy.set(Calendar.MILLISECOND, 0);
            
            for (Lote lote : lotes) {
                if (lote.getFechaVencimiento() == null) {
                    continue; // Lote sin fecha de vencimiento
                }
                
                Calendar fechaVencimiento = Calendar.getInstance();
                fechaVencimiento.setTime(lote.getFechaVencimiento());
                fechaVencimiento.set(Calendar.HOUR_OF_DAY, 0);
                fechaVencimiento.set(Calendar.MINUTE, 0);
                fechaVencimiento.set(Calendar.SECOND, 0);
                fechaVencimiento.set(Calendar.MILLISECOND, 0);
                
                long diferenciaMillis = fechaVencimiento.getTimeInMillis() - hoy.getTimeInMillis();
                int diasRestantes = (int) (diferenciaMillis / (1000 * 60 * 60 * 24));
                
                // Verificar si está vencido
                if (diasRestantes < 0) {
                    AlertaService.AlertaGenerada alerta = crearAlertaVencimiento(
                        regla, lote, Math.abs(diasRestantes), "CRITICAL", "vencido"
                    );
                    alertas.add(alerta);
                }
                // Verificar si está próximo a vencer (crítico)
                else if (diasCritico != null && diasRestantes <= diasCritico && diasRestantes >= 0) {
                    AlertaService.AlertaGenerada alerta = crearAlertaVencimiento(
                        regla, lote, diasRestantes, "CRITICAL", "próximo a vencer"
                    );
                    alertas.add(alerta);
                }
                // Verificar si está próximo a vencer (advertencia)
                else if (diasProximo != null && diasRestantes <= diasProximo && diasRestantes > (diasCritico != null ? diasCritico : 0)) {
                    AlertaService.AlertaGenerada alerta = crearAlertaVencimiento(
                        regla, lote, diasRestantes, "WARNING", "próximo a vencer"
                    );
                    alertas.add(alerta);
                }
            }
        } catch (Exception e) {
            System.err.println("Error al evaluar vencimientos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return alertas;
    }
    
    /**
     * Obtiene los días de anticipación para alerta próxima desde la configuración.
     */
    private Integer obtenerDiasProximo(Map<String, Object> config, AlertaConfig regla) {
        if (config.containsKey("dias_vencimiento_proximo")) {
            return (Integer) config.get("dias_vencimiento_proximo");
        }
        // Si no está en config JSON, usar umbral_dias de la regla
        return regla.getUmbralDias();
    }
    
    /**
     * Obtiene los días de anticipación para alerta crítica desde la configuración.
     */
    private Integer obtenerDiasCritico(Map<String, Object> config) {
        if (config.containsKey("dias_vencimiento_critico")) {
            return (Integer) config.get("dias_vencimiento_critico");
        }
        // Valor por defecto: 3 días
        return 3;
    }
    
    /**
     * Crea una alerta de vencimiento.
     */
    private AlertaService.AlertaGenerada crearAlertaVencimiento(
            AlertaConfig regla, Lote lote, int dias, String nivel, String tipo) {
        
        AlertaService.AlertaGenerada alerta = new AlertaService.AlertaGenerada();
        alerta.setAlertaConfigId(regla.getIdAlertaConfig());
        alerta.setTipoAlerta("VENCIMIENTO");
        alerta.setNivel(nivel);
        alerta.setLoteId(lote.getIdLote());
        alerta.setLoteCodigo(lote.getCodigoLote());
        alerta.setProductoId(lote.getProductoId());
        String nombreProducto = lote.getNombreProducto();
        if (nombreProducto == null || nombreProducto.trim().isEmpty()) {
            // Si no viene en el lote, obtenerlo de la BD
            nombreProducto = obtenerNombreProducto(lote.getProductoId());
        }
        alerta.setProductoNombre(nombreProducto != null ? nombreProducto : "N/A");
        
        // Generar mensaje
        String mensaje;
        if (dias == 0) {
            mensaje = String.format(
                "Lote %s (%s) vence HOY",
                lote.getCodigoLote(), alerta.getProductoNombre()
            );
        } else if (tipo.equals("vencido")) {
            mensaje = String.format(
                "Lote %s (%s) vencido hace %d día(s)",
                lote.getCodigoLote(), alerta.getProductoNombre(), dias
            );
        } else {
            mensaje = String.format(
                "Lote %s (%s) vence en %d día(s)",
                lote.getCodigoLote(), alerta.getProductoNombre(), dias
            );
        }
        
        // Usar mensaje personalizado si existe
        if (regla.getMensajePersonalizado() != null && !regla.getMensajePersonalizado().isEmpty()) {
            mensaje = regla.getMensajePersonalizado()
                .replace("{lote}", lote.getCodigoLote())
                .replace("{producto}", alerta.getProductoNombre())
                .replace("{dias_restantes}", String.valueOf(dias));
        }
        
        alerta.setMensaje(mensaje);
        return alerta;
    }
    
    /**
     * Obtiene el nombre de un producto desde la BD.
     */
    private String obtenerNombreProducto(int productoId) {
        String sql = "SELECT nombre FROM productos WHERE id_producto = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productoId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("nombre");
                }
            }
        } catch (Exception e) {
            System.err.println("Error al obtener nombre del producto: " + e.getMessage());
        }
        return null;
    }
}

