package com.example.telito.logistica.beans;

import java.sql.Date;

public class InventarioBean {

    // Propiedades como Almacenero (por lote individual)
    private int idLote;
    private String codigoLote;
    private String codigoSKU;
    private String nombreProducto;
    private int stockActual;
    private int paquetesDisponibles;
    private String nombreUbicacion;
    private Date fechaVencimiento;
    private String estado;
    
    // Propiedades adicionales para vista agrupada de Logística
    private int idProducto;
    private double precioPorPaquete;
    private double costoPorUnidad;
    private String estadoStock; // "En Stock", "Poco Stock", "Sin Stock", "No configurado"

    // Constructor vacío
    public InventarioBean() {
    }

    // Getters y Setters
    public int getIdLote() {
        return idLote;
    }

    public void setIdLote(int idLote) {
        this.idLote = idLote;
    }

    public String getCodigoLote() {
        return codigoLote;
    }

    public void setCodigoLote(String codigoLote) {
        this.codigoLote = codigoLote;
    }

    public String getCodigoSKU() {
        return codigoSKU;
    }

    public void setCodigoSKU(String codigoSKU) {
        this.codigoSKU = codigoSKU;
    }

    public String getNombreProducto() {
        return nombreProducto;
    }

    public void setNombreProducto(String nombreProducto) {
        this.nombreProducto = nombreProducto;
    }

    public int getStockActual() {
        return stockActual;
    }

    public void setStockActual(int stockActual) {
        this.stockActual = stockActual;
    }

    public int getPaquetesDisponibles() {
        return paquetesDisponibles;
    }

    public void setPaquetesDisponibles(int paquetesDisponibles) {
        this.paquetesDisponibles = paquetesDisponibles;
    }

    public String getNombreUbicacion() {
        return nombreUbicacion;
    }

    public void setNombreUbicacion(String nombreUbicacion) {
        this.nombreUbicacion = nombreUbicacion;
    }

    public Date getFechaVencimiento() {
        return fechaVencimiento;
    }

    public void setFechaVencimiento(Date fechaVencimiento) {
        this.fechaVencimiento = fechaVencimiento;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public int getIdProducto() {
        return idProducto;
    }

    public void setIdProducto(int idProducto) {
        this.idProducto = idProducto;
    }

    public double getPrecioPorPaquete() {
        return precioPorPaquete;
    }

    public void setPrecioPorPaquete(double precioPorPaquete) {
        this.precioPorPaquete = precioPorPaquete;
    }

    public double getCostoPorUnidad() {
        return costoPorUnidad;
    }

    public void setCostoPorUnidad(double costoPorUnidad) {
        this.costoPorUnidad = costoPorUnidad;
    }

    public String getEstadoStock() {
        return estadoStock;
    }

    public void setEstadoStock(String estadoStock) {
        this.estadoStock = estadoStock;
    }
}