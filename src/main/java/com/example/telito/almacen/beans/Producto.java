package com.example.telito.almacen.beans;

public class Producto {
    private int ProductoId;
    private String codigoSku;
    private String nombre;
    private String descripcion;

    // Constructor vacío
    public Producto() {
    }

    // Getters y Setters
    public int getProductoId() {
        return ProductoId;
    }

    public void setProductoId(int idProducto) {
        this.ProductoId = idProducto;
    }

    public String getCodigoSku() {
        return codigoSku;
    }

    public void setCodigoSku(String codigoSku) {
        this.codigoSku = codigoSku;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
}