package com.example.telito.administrador.beans;

// Bean para representar un conductor
public class Conductor {
    private int idConductor;
    private String nombreCompleto;
    private String licencia;

    public Conductor() {
    }

    public Conductor(int idConductor, String nombreCompleto, String licencia) {
        this.idConductor = idConductor;
        this.nombreCompleto = nombreCompleto;
        this.licencia = licencia;
    }

    public int getIdConductor() {
        return idConductor;
    }

    public void setIdConductor(int idConductor) {
        this.idConductor = idConductor;
    }

    public String getNombreCompleto() {
        return nombreCompleto;
    }

    public void setNombreCompleto(String nombreCompleto) {
        this.nombreCompleto = nombreCompleto;
    }

    public String getLicencia() {
        return licencia;
    }

    public void setLicencia(String licencia) {
        this.licencia = licencia;
    }
}

