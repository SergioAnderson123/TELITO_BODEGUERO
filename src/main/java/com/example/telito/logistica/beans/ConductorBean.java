package com.example.telito.logistica.beans;

// Bean para representar un conductor (versión simplificada)
public class ConductorBean {
    private int id;
    private String nombreCompleto;
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNombreCompleto() {
        return nombreCompleto;
    }

    public void setNombreCompleto(String nombreCompleto) {
        this.nombreCompleto = nombreCompleto;
    }
}