package com.example.telito.administrador.beans;

import com.example.telito.administrador.beans.Categoria;
import com.example.telito.administrador.beans.Rol;

public class AlertaConfig {

    private int idAlertaConfig;
    private String nombre;
    private String tipoAlerta;
    private Integer umbralDias; // Usamos Integer para permitir valores nulos
    private Categoria categoria; // Reutilizamos el bean Categoria
    private Rol rolANotificar; // Reutilizamos el bean Rol
    private boolean activo;

    // Getters y Setters

    public int getIdAlertaConfig() {
        return idAlertaConfig;
    }

    public void setIdAlertaConfig(int idAlertaConfig) {
        this.idAlertaConfig = idAlertaConfig;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getTipoAlerta() {
        return tipoAlerta;
    }

    public void setTipoAlerta(String tipoAlerta) {
        this.tipoAlerta = tipoAlerta;
    }

    public Integer getUmbralDias() {
        return umbralDias;
    }

    public void setUmbralDias(Integer umbralDias) {
        this.umbralDias = umbralDias;
    }

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
        this.categoria = categoria;
    }

    public Rol getRolANotificar() {
        return rolANotificar;
    }

    public void setRolANotificar(Rol rolANotificar) {
        this.rolANotificar = rolANotificar;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }
}