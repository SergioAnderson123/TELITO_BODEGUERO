package com.example.telito.administrador.beans;

public class PlantillaMapeo {

    private int idMapeo;
    private String columnaExcel;
    private String campoDestino;

    // Getters y Setters

    public int getIdMapeo() {
        return idMapeo;
    }

    public void setIdMapeo(int idMapeo) {
        this.idMapeo = idMapeo;
    }

    public String getColumnaExcel() {
        return columnaExcel;
    }

    public void setColumnaExcel(String columnaExcel) {
        this.columnaExcel = columnaExcel;
    }

    public String getCampoDestino() {
        return campoDestino;
    }

    public void setCampoDestino(String campoDestino) {
        this.campoDestino = campoDestino;
    }
}
