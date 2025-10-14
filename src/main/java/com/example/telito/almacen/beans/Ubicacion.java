package com.example.telito.almacen.beans;

public class Ubicacion {
    private int idUbicacion;
    private String nombre; // CORRECCIÓN: Se renombró 'pasillo' a 'nombre'

    // --- GETTERS Y SETTERS CORREGIDOS ---

    public int getIdUbicacion() {
        return idUbicacion;
    }

    public void setIdUbicacion(int idUbicacion) { // Corregido un pequeño typo en el parámetro
        this.idUbicacion = idUbicacion;
    }

    public String getNombre() { // CORRECCIÓN: El método ahora es getNombre()
        return nombre;
    }

    public void setNombre(String nombre) { // CORRECCIÓN: El método ahora es setNombre()
        this.nombre = nombre;
    }
}