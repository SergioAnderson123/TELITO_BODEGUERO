package com.example.telito.logistica.beans;

// Bean para representar una orden de compra
public class OrdenCompraBean {
    private String numeroOrden;
    private String nombreProveedor;
    private String nombreProducto;
    private int cantidadPaquetes;
    private String personalResponsable;
    private String estado;
    private String montoTotal;

    public OrdenCompraBean() {
    }

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