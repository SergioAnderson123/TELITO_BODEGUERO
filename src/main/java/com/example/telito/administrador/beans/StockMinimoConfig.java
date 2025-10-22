package com.example.telito.administrador.beans;

import java.sql.Timestamp;

public class StockMinimoConfig {

    private int idStockMinimo;
    private Producto producto;
    private int stockMinimo;
    private int stockCritico;
    private boolean activo;
    private Timestamp fechaCreacion;
    private Timestamp fechaActualizacion;

    // Constructores
    public StockMinimoConfig() {}

    public StockMinimoConfig(Producto producto, int stockMinimo, int stockCritico) {
        this.producto = producto;
        this.stockMinimo = stockMinimo;
        this.stockCritico = stockCritico;
        this.activo = true;
    }

    // Getters y Setters
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

    public int getStockMinimo() {
        return stockMinimo;
    }

    public void setStockMinimo(int stockMinimo) {
        this.stockMinimo = stockMinimo;
    }

    public int getStockCritico() {
        return stockCritico;
    }

    public void setStockCritico(int stockCritico) {
        this.stockCritico = stockCritico;
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
                ", stockMinimo=" + stockMinimo +
                ", stockCritico=" + stockCritico +
                ", activo=" + activo +
                '}';
    }
}