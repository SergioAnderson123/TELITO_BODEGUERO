package com.example.telito.almacen.beans;

import java.sql.Date;

public class Lote {
    private int idLote;
    private String codigoLote;
    private int stockActual;
    private int paquetesDisponibles;
    private Date fechaVencimiento;

    // Campos de las tablas relacionadas para mostrar en la vista
    private String nombreProducto;
    private String codigoSKU; // SKU del producto
    private String nombreUbicacion;
    private int productoId;
    private int ubicacionId;
    private int distritoId; // <-- AÑADIR ESTE CAMPO
    private String estado;
    private String estadoStock; // Estado del stock: "En Stock", "Poco Stock", "Sin Stock", "No configurado"
    private boolean tieneIncidenciaPendiente; // Indica si el lote tiene una incidencia pendiente
    private int unidadesPorPaquete; // Unidades por paquete del producto

    // --- AÑADIR GETTERS Y SETTERS PARA 'estado' ---
    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
    // --- AÑADIR GETTERS Y SETTERS PARA distritoId ---
    public int getDistritoId() {
        return distritoId;
    }
    public void setDistritoId(int distritoId) {
        this.distritoId = distritoId;
    }
    // Getters y Setters para todos los campos...
    public int getIdLote() { return idLote; }
    public void setIdLote(int idLote) { this.idLote = idLote; }
    public String getCodigoLote() { return codigoLote; }
    public void setCodigoLote(String codigoLote) { this.codigoLote = codigoLote; }
    public int getStockActual() { return stockActual; }
    public void setStockActual(int stockActual) { this.stockActual = stockActual; }
    public int getPaquetesDisponibles() { return paquetesDisponibles; }
    public void setPaquetesDisponibles(int paquetesDisponibles) { this.paquetesDisponibles = paquetesDisponibles; }
    public Date getFechaVencimiento() { return fechaVencimiento; }
    public void setFechaVencimiento(Date fechaVencimiento) { this.fechaVencimiento = fechaVencimiento; }
    public String getNombreProducto() { return nombreProducto; }
    public void setNombreProducto(String nombreProducto) { this.nombreProducto = nombreProducto; }
    public String getCodigoSKU() { return codigoSKU; }
    public void setCodigoSKU(String codigoSKU) { this.codigoSKU = codigoSKU; }
    public String getNombreUbicacion() { return nombreUbicacion; }
    public void setNombreUbicacion(String nombreUbicacion) { this.nombreUbicacion = nombreUbicacion; }
    public int getProductoId() { return productoId; }
    public void setProductoId(int productoId) { this.productoId = productoId; }
    public int getUbicacionId() { return ubicacionId; }

    public void setUbicacionId(int ubicacionId) {
        this.ubicacionId = ubicacionId;
    }
    
    public String getEstadoStock() {
        return estadoStock;
    }
    
    public void setEstadoStock(String estadoStock) {
        this.estadoStock = estadoStock;
    }
    
    public boolean isTieneIncidenciaPendiente() {
        return tieneIncidenciaPendiente;
    }
    
    public void setTieneIncidenciaPendiente(boolean tieneIncidenciaPendiente) {
        this.tieneIncidenciaPendiente = tieneIncidenciaPendiente;
    }
    
    public int getUnidadesPorPaquete() {
        return unidadesPorPaquete;
    }
    
    public void setUnidadesPorPaquete(int unidadesPorPaquete) {
        this.unidadesPorPaquete = unidadesPorPaquete;
    }
}