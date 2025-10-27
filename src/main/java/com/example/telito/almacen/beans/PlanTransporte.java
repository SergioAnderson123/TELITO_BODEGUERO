package com.example.telito.almacen.beans;

public class PlanTransporte {
    private int idPlan;
    private String numeroPlan;
    private String nombreProducto;
    private String codigoLote;
    private int idLote;
    private String estado;
    private String nombreConductor;
    private String placaVehiculo;
    private String fechaEntrega;
    private String nombreDestino;
    private int stockDisponible;
    private int paquetesDisponibles;

    // Constructor vacío
    public PlanTransporte() {
    }

    // Getters y Setters
    public int getIdPlan() {
        return idPlan;
    }

    public void setIdPlan(int idPlan) {
        this.idPlan = idPlan;
    }

    public String getNumeroPlan() {
        return numeroPlan;
    }

    public void setNumeroPlan(String numeroPlan) {
        this.numeroPlan = numeroPlan;
    }

    public String getNombreProducto() {
        return nombreProducto;
    }

    public void setNombreProducto(String nombreProducto) {
        this.nombreProducto = nombreProducto;
    }

    public String getCodigoLote() {
        return codigoLote;
    }

    public void setCodigoLote(String codigoLote) {
        this.codigoLote = codigoLote;
    }

    public int getIdLote() {
        return idLote;
    }

    public void setIdLote(int idLote) {
        this.idLote = idLote;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getNombreConductor() {
        return nombreConductor;
    }

    public void setNombreConductor(String nombreConductor) {
        this.nombreConductor = nombreConductor;
    }

    public String getPlacaVehiculo() {
        return placaVehiculo;
    }

    public void setPlacaVehiculo(String placaVehiculo) {
        this.placaVehiculo = placaVehiculo;
    }

    public String getFechaEntrega() {
        return fechaEntrega;
    }

    public void setFechaEntrega(String fechaEntrega) {
        this.fechaEntrega = fechaEntrega;
    }

    public String getNombreDestino() {
        return nombreDestino;
    }

    public void setNombreDestino(String nombreDestino) {
        this.nombreDestino = nombreDestino;
    }

    public int getStockDisponible() {
        return stockDisponible;
    }

    public void setStockDisponible(int stockDisponible) {
        this.stockDisponible = stockDisponible;
    }

    public int getPaquetesDisponibles() {
        return paquetesDisponibles;
    }

    public void setPaquetesDisponibles(int paquetesDisponibles) {
        this.paquetesDisponibles = paquetesDisponibles;
    }
}

