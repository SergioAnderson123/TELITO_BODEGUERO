package com.example.telito.logistica.beans;

import java.math.BigDecimal;

public class ProductoBean {
    private int id;
    private String nombre;
    private BigDecimal precio;

    public ProductoBean() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public BigDecimal getPrecio() {
        return precio;
    }

    public void setPrecio(BigDecimal precio) {
        this.precio = precio;
    }
}