package com.example.telito.administrador.services;

import com.example.telito.administrador.beans.AlertaConfig;
import com.example.telito.administrador.daos.AlertaDAO;
import com.example.telito.administrador.daos.StockMinimoDAO;
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.almacen.beans.Lote;
import com.example.telito.administrador.beans.Producto;
import com.example.telito.administrador.daos.ProductoDAO;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Servicio unificado para la gestión de alertas del sistema.
 * Centraliza toda la lógica de evaluación, generación y gestión de alertas.
 */
public class AlertaService {
    
    private final AlertaDAO alertaDAO;
    private final StockMinimoDAO stockMinimoDAO;
    private final LoteDao loteDao;
    private final ProductoDAO productoDAO;
    private final StockAlertaEvaluator stockEvaluator;
    private final VencimientoAlertaEvaluator vencimientoEvaluator;
    private final AlertaConfigManager configManager;
    
    public AlertaService() {
        this.alertaDAO = new AlertaDAO();
        this.stockMinimoDAO = new StockMinimoDAO();
        this.loteDao = new LoteDao();
        this.productoDAO = new ProductoDAO();
        this.stockEvaluator = new StockAlertaEvaluator(stockMinimoDAO, loteDao, productoDAO);
        this.vencimientoEvaluator = new VencimientoAlertaEvaluator(loteDao);
        this.configManager = new AlertaConfigManager();
    }
    
    /**
     * Evalúa todas las reglas de alerta activas y genera las alertas correspondientes.
     * @return Lista de alertas generadas
     */
    public List<AlertaGenerada> evaluarTodasLasAlertas() {
        List<AlertaGenerada> alertasGeneradas = new ArrayList<>();
        
        // Obtener todas las reglas activas
        List<AlertaConfig> reglasActivas = alertaDAO.listarTodasAlertas()
            .stream()
            .filter(AlertaConfig::isActivo)
            .collect(Collectors.toList());
        
        for (AlertaConfig regla : reglasActivas) {
            try {
                List<AlertaGenerada> alertas = evaluarRegla(regla);
                alertasGeneradas.addAll(alertas);
            } catch (Exception e) {
                System.err.println("Error al evaluar regla " + regla.getNombre() + ": " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        return alertasGeneradas;
    }
    
    /**
     * Evalúa una regla de alerta específica.
     */
    private List<AlertaGenerada> evaluarRegla(AlertaConfig regla) {
        List<AlertaGenerada> alertas = new ArrayList<>();
        String tipoAlerta = regla.getTipoAlerta();
        
        // Parsear configuración JSON si existe
        Map<String, Object> config = configManager.parsearConfiguracion(regla.getMensajePersonalizado());
        
        switch (tipoAlerta) {
            case "STOCK_MINIMO":
            case "STOCK_CRITICO":
                alertas.addAll(stockEvaluator.evaluarStock(regla, config));
                break;
                
            case "VENCIMIENTO":
                alertas.addAll(vencimientoEvaluator.evaluarVencimientos(regla, config));
                break;
                
            default:
                System.out.println("Tipo de alerta no soportado: " + tipoAlerta);
        }
        
        return alertas;
    }
    
    /**
     * Obtiene estadísticas de alertas para el dashboard.
     */
    public EstadisticasAlertas obtenerEstadisticas(Date desde, Date hasta) {
        // TODO: Implementar consulta a alertas_generadas
        return new EstadisticasAlertas();
    }
    
    /**
     * Clase interna para representar una alerta generada.
     */
    public static class AlertaGenerada {
        private int alertaConfigId;
        private String tipoAlerta;
        private String nivel; // INFO, WARNING, CRITICAL
        private String mensaje;
        private Integer productoId;
        private Integer loteId;
        private String productoNombre;
        private String loteCodigo;
        
        // Getters y Setters
        public int getAlertaConfigId() { return alertaConfigId; }
        public void setAlertaConfigId(int alertaConfigId) { this.alertaConfigId = alertaConfigId; }
        
        public String getTipoAlerta() { return tipoAlerta; }
        public void setTipoAlerta(String tipoAlerta) { this.tipoAlerta = tipoAlerta; }
        
        public String getNivel() { return nivel; }
        public void setNivel(String nivel) { this.nivel = nivel; }
        
        public String getMensaje() { return mensaje; }
        public void setMensaje(String mensaje) { this.mensaje = mensaje; }
        
        public Integer getProductoId() { return productoId; }
        public void setProductoId(Integer productoId) { this.productoId = productoId; }
        
        public Integer getLoteId() { return loteId; }
        public void setLoteId(Integer loteId) { this.loteId = loteId; }
        
        public String getProductoNombre() { return productoNombre; }
        public void setProductoNombre(String productoNombre) { this.productoNombre = productoNombre; }
        
        public String getLoteCodigo() { return loteCodigo; }
        public void setLoteCodigo(String loteCodigo) { this.loteCodigo = loteCodigo; }
    }
    
    /**
     * Clase para estadísticas de alertas.
     */
    public static class EstadisticasAlertas {
        private int totalAlertas;
        private int alertasInfo;
        private int alertasWarning;
        private int alertasCritical;
        private Map<String, Integer> alertasPorTipo;
        
        // Getters y Setters
        public int getTotalAlertas() { return totalAlertas; }
        public void setTotalAlertas(int totalAlertas) { this.totalAlertas = totalAlertas; }
        
        public int getAlertasInfo() { return alertasInfo; }
        public void setAlertasInfo(int alertasInfo) { this.alertasInfo = alertasInfo; }
        
        public int getAlertasWarning() { return alertasWarning; }
        public void setAlertasWarning(int alertasWarning) { this.alertasWarning = alertasWarning; }
        
        public int getAlertasCritical() { return alertasCritical; }
        public void setAlertasCritical(int alertasCritical) { this.alertasCritical = alertasCritical; }
        
        public Map<String, Integer> getAlertasPorTipo() { return alertasPorTipo; }
        public void setAlertasPorTipo(Map<String, Integer> alertasPorTipo) { this.alertasPorTipo = alertasPorTipo; }
    }
}

