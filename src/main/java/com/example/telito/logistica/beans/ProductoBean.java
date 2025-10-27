package com.example.telito.logistica.beans;

import java.math.BigDecimal;

public class ProductoBean {
    private int id;
    private String codigo;
    private String nombre;
    private BigDecimal precio;
    private int unidadesPorPaquete;

    public ProductoBean() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
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
    
    // Sobrecarga para aceptar double
    public void setPrecio(double precio) {
        this.precio = BigDecimal.valueOf(precio);
    }

    public int getUnidadesPorPaquete() {
        return unidadesPorPaquete;
    }

    public void setUnidadesPorPaquete(int unidadesPorPaquete) {
        this.unidadesPorPaquete = unidadesPorPaquete;
    }
}