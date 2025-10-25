package com.example.telito.administrador.beans;

import com.example.telito.administrador.beans.Rol;

public class Usuario {

    private int idUsuario;
    private String nombres;
    private String apellidos;
    private String email;
    private String password;
    private boolean activo;
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
