package com.example.telito.logistica.beans;

// Bean para representar un proveedor (productor)
public class ProveedorBean {
    private int id;
    private String nombre;

    public ProveedorBean() {
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
}