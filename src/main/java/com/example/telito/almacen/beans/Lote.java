package com.example.telito.almacen.beans;

import java.sql.Date;

public class Lote {
    private int idLote;
    private String codigoLote;
    private int stockActual;
    private Date fechaVencimiento;

    // Campos de las tablas relacionadas para mostrar en la vista
    private String nombreProducto;
    private String nombreUbicacion;
    private int productoId;
    private int ubicacionId;

    // Getters y Setters para todos los campos...
    public int getIdLote() { return idLote; }
    public void setIdLote(int idLote) { this.idLote = idLote; }
    public String getCodigoLote() { return codigoLote; }
    public void setCodigoLote(String codigoLote) { this.codigoLote = codigoLote; }
    public int getStockActual() { return stockActual; }
    public void setStockActual(int stockActual) { this.stockActual = stockActual; }
    public Date getFechaVencimiento() { return fechaVencimiento; }
    public void setFechaVencimiento(Date fechaVencimiento) { this.fechaVencimiento = fechaVencimiento; }
    public String getNombreProducto() { return nombreProducto; }
    public void setNombreProducto(String nombreProducto) { this.nombreProducto = nombreProducto; }
    public String getNombreUbicacion() { return nombreUbicacion; }
    public void setNombreUbicacion(String nombreUbicacion) { this.nombreUbicacion = nombreUbicacion; }
    public int getProductoId() { return productoId; }
    public void setProductoId(int productoId) { this.productoId = productoId; }
    public int getUbicacionId() { return ubicacionId; }

    public void setUbicacionId(int ubicacionId) {
        this.ubicacionId = ubicacionId;
    }
}