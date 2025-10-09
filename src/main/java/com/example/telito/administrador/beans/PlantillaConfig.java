package com.example.telito.administrador.beans;

import com.example.telito.administrador.beans.PlantillaMapeo;

import java.util.List;

public class PlantillaConfig {

    private int idPlantilla;
    private String nombre;
    private String tipoCarga;
    private boolean activo;
    private List<PlantillaMapeo> mapeos; // Lista de mapeos de columnas

    // Getters y Setters

    public int getIdPlantilla() {
        return idPlantilla;
    }

    public void setIdPlantilla(int idPlantilla) {
        this.idPlantilla = idPlantilla;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getTipoCarga() {
        return tipoCarga;
    }

    public void setTipoCarga(String tipoCarga) {
        this.tipoCarga = tipoCarga;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public List<PlantillaMapeo> getMapeos() {
        return mapeos;
    }

    public void setMapeos(List<PlantillaMapeo> mapeos) {
        this.mapeos = mapeos;
    }
}