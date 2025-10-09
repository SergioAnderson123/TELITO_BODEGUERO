package com.example.telito.logistica.beans;

public class OrdenCompraBean {
    // Campos ajustados a la tabla real de la BD
    private String numeroOrden;
    private String nombreProveedor;
    private String nombreProducto;
    private int cantidadPaquetes;
    // private String fechaEntregaFormateada; // CAMPO ELIMINADO - No existe en la tabla ordenes_compra
    private String personalResponsable;
    private String estado;
    private String montoTotal;

    // Constructor vacío
    public OrdenCompraBean() {
    }

    // CONSTRUCTOR CORREGIDO - Se ha eliminado el parámetro "fechaEntregaFormateada"
    public OrdenCompraBean(String numeroOrden, String nombreProveedor, String nombreProducto,
                           int cantidadPaquetes, String personalResponsable,
                           String estado, String montoTotal) {
        this.numeroOrden = numeroOrden;
        this.nombreProveedor = nombreProveedor;
        this.nombreProducto = nombreProducto;
        this.cantidadPaquetes = cantidadPaquetes;
        this.personalResponsable = personalResponsable;
        this.estado = estado;
        this.montoTotal = montoTotal;
    }

    // Getters y Setters (los de fechaEntregaFormateada han sido eliminados)
    public String getNumeroOrden() {
        return numeroOrden;
    }

    public void setNumeroOrden(String numeroOrden) {
        this.numeroOrden = numeroOrden;
    }

    public String getNombreProveedor() {
        return nombreProveedor;
    }

    public void setNombreProveedor(String nombreProveedor) {
        this.nombreProveedor = nombreProveedor;
    }

    public String getNombreProducto() {
        return nombreProducto;
    }

    public void setNombreProducto(String nombreProducto) {
        this.nombreProducto = nombreProducto;
    }

    public int getCantidadPaquetes() {
        return cantidadPaquetes;
    }

    public void setCantidadPaquetes(int cantidadPaquetes) {
        this.cantidadPaquetes = cantidadPaquetes;
    }

    public String getPersonalResponsable() {
        return personalResponsable;
    }

    public void setPersonalResponsable(String personalResponsable) {
        this.personalResponsable = personalResponsable;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getMontoTotal() {
        return montoTotal;
    }

    public void setMontoTotal(String montoTotal) {
        this.montoTotal = montoTotal;
    }
}