package com.example.telito.logistica.beans;

// Bean para representar un plan de transporte
public class PlanTransporteBean {

    private String numeroViaje;
    private String nombreProducto;
    private String codigoLote;
    private String estado;
    private String nombreConductor;
    private String placaVehiculo;
    private String fechaEntrega; // Fecha formateada como String
    private String fechaSalida; // Para reportes
    private String nombreDestino;
    private int cantidadLotes; // Cantidad de lotes en el viaje

    public PlanTransporteBean() {
    }

    public PlanTransporteBean(String numeroViaje, String nombreProducto, String codigoLote, String estado, String nombreConductor, String placaVehiculo, String fechaEntrega, String nombreDestino) {
        this.numeroViaje = numeroViaje;
        this.nombreProducto = nombreProducto;
        this.codigoLote = codigoLote;
        this.estado = estado;
        this.nombreConductor = nombreConductor;
        this.placaVehiculo = placaVehiculo;
        this.fechaEntrega = fechaEntrega;
        this.nombreDestino = nombreDestino;
    }

    public String getNumeroViaje() {
        return numeroViaje;
    }

    public void setNumeroViaje(String numeroViaje) {
        this.numeroViaje = numeroViaje;
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

    public String getFechaSalida() {
        return fechaSalida;
    }

    public void setFechaSalida(String fechaSalida) {
        this.fechaSalida = fechaSalida;
    }

    public int getCantidadLotes() {
        return cantidadLotes;
    }

    public void setCantidadLotes(int cantidadLotes) {
        this.cantidadLotes = cantidadLotes;
    }
}