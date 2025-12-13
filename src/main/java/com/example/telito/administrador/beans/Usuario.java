package com.example.telito.administrador.beans;

import com.example.telito.administrador.beans.Rol;

public class Usuario {

    private int idUsuario;
    private String nombres;
    private String apellidos;
    private String email;
    private String codigoProductor; // Código único para productores (ej: PROD-0001)
    private Integer distritoId; // ID del distrito asignado (para Gerente de Tienda)
    private String password;
    private boolean activo;
    private boolean cuentaActivada; // Indica si la cuenta ha sido activada por email
    private java.sql.Timestamp fechaActivacion; // Fecha en que se activó la cuenta
    private Rol rol; // Objeto Rol para representar la llave foránea
    private String fotoPerfil;
    
    // Getters y Setters
    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getNombres() {
        return nombres;
    }

    public void setNombres(String nombres) {
        this.nombres = nombres;
    }

    public String getApellidos() {
        return apellidos;
    }

    public void setApellidos(String apellidos) {
        this.apellidos = apellidos;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public Rol getRol() {
        return rol;
    }

    public void setRol(Rol rol) {
        this.rol = rol;
    }

    public String getFotoPerfil() {
        return fotoPerfil;
    }

    public void setFotoPerfil(String fotoPerfil) {
        this.fotoPerfil = fotoPerfil;
    }

    public String getCodigoProductor() {
        return codigoProductor;
    }

    public void setCodigoProductor(String codigoProductor) {
        this.codigoProductor = codigoProductor;
    }
    
    public Integer getDistritoId() {
        return distritoId;
    }
    
    public void setDistritoId(Integer distritoId) {
        this.distritoId = distritoId;
    }
    
    public boolean isCuentaActivada() {
        return cuentaActivada;
    }
    
    public void setCuentaActivada(boolean cuentaActivada) {
        this.cuentaActivada = cuentaActivada;
    }
    
    public java.sql.Timestamp getFechaActivacion() {
        return fechaActivacion;
    }
    
    public void setFechaActivacion(java.sql.Timestamp fechaActivacion) {
        this.fechaActivacion = fechaActivacion;
    }
    
    /**
     * Obtiene la URL de la foto de perfil o genera una por defecto
     */
    public String getFotoPerfilUrl() {
        if (fotoPerfil != null && !fotoPerfil.trim().isEmpty()) {
            return fotoPerfil;
        }
        // Generar avatar por defecto con las iniciales
        String iniciales = "";
        if (nombres != null && !nombres.isEmpty()) {
            iniciales += nombres.charAt(0);
        }
        if (apellidos != null && !apellidos.isEmpty()) {
            iniciales += apellidos.charAt(0);
        }
        return "https://ui-avatars.com/api/?name=" + iniciales + "&background=006d77&color=fff&size=200";
    }
}
