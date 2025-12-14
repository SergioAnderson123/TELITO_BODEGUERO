package com.example.telito.administrador.beans;

import java.sql.Timestamp;

// Bean para configuración de stock mínimo por producto
public class StockMinimoConfig {

    private int idStockMinimo;
    private Producto producto;
    private int stockMinimoProducto;  // Mínimo por producto (Logística)
    private int stockCriticoProducto; // Crítico por producto (Logística)
    private int stockMinimoLote;      // Mínimo por lote (Almacén)
    private int stockCriticoLote;     // Crítico por lote (Almacén)
    private boolean activo;
    private Timestamp fechaCreacion;
    private Timestamp fechaActualizacion;

    public StockMinimoConfig() {}

    public StockMinimoConfig(Producto producto, int stockMinimoProducto, int stockCriticoProducto, 
                            int stockMinimoLote, int stockCriticoLote) {
        this.producto = producto;
        this.stockMinimoProducto = stockMinimoProducto;
        this.stockCriticoProducto = stockCriticoProducto;
        this.stockMinimoLote = stockMinimoLote;
        this.stockCriticoLote = stockCriticoLote;
        this.activo = true;
    }

    public int getIdStockMinimo() {
        return idStockMinimo;
    }

    public void setIdStockMinimo(int idStockMinimo) {
        this.idStockMinimo = idStockMinimo;
    }

    public Producto getProducto() {
        return producto;
    }

    public void setProducto(Producto producto) {
        this.producto = producto;
    }

    public int getStockMinimoProducto() {
        return stockMinimoProducto;
    }

    public void setStockMinimoProducto(int stockMinimoProducto) {
        this.stockMinimoProducto = stockMinimoProducto;
    }

    public int getStockCriticoProducto() {
        return stockCriticoProducto;
    }

    public void setStockCriticoProducto(int stockCriticoProducto) {
        this.stockCriticoProducto = stockCriticoProducto;
    }

    public int getStockMinimoLote() {
        return stockMinimoLote;
    }

    public void setStockMinimoLote(int stockMinimoLote) {
        this.stockMinimoLote = stockMinimoLote;
    }

    public int getStockCriticoLote() {
        return stockCriticoLote;
    }

    public void setStockCriticoLote(int stockCriticoLote) {
        this.stockCriticoLote = stockCriticoLote;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public Timestamp getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(Timestamp fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public Timestamp getFechaActualizacion() {
        return fechaActualizacion;
    }

    public void setFechaActualizacion(Timestamp fechaActualizacion) {
        this.fechaActualizacion = fechaActualizacion;
    }

    @Override
    public String toString() {
        return "StockMinimoConfig{" +
                "idStockMinimo=" + idStockMinimo +
                ", producto=" + (producto != null ? producto.getNombre() : "null") +
                ", stockMinimoProducto=" + stockMinimoProducto +
                ", stockCriticoProducto=" + stockCriticoProducto +
                ", stockMinimoLote=" + stockMinimoLote +
                ", stockCriticoLote=" + stockCriticoLote +
                ", activo=" + activo +
                '}';
    }
}