package com.example.telito.administrador.dtos;

/**
 * DTO para reportes de usuarios por rol.
 * Representa datos agregados que no mapean directamente a una tabla.
 */
public class UsuariosPorRolDto {
    
    private String nombreRol;
    private int cantidadUsuarios;
    private int usuariosActivos;
    private int usuariosInactivos;
    
    // Constructores
    public UsuariosPorRolDto() {
    }
    
    public UsuariosPorRolDto(String nombreRol, int cantidadUsuarios, int usuariosActivos, int usuariosInactivos) {
        this.nombreRol = nombreRol;
        this.cantidadUsuarios = cantidadUsuarios;
        this.usuariosActivos = usuariosActivos;
        this.usuariosInactivos = usuariosInactivos;
    }
    
    // Getters y Setters
    public String getNombreRol() {
        return nombreRol;
    }
    
    public void setNombreRol(String nombreRol) {
        this.nombreRol = nombreRol;
    }
    
    public int getCantidadUsuarios() {
        return cantidadUsuarios;
    }
    
    public void setCantidadUsuarios(int cantidadUsuarios) {
        this.cantidadUsuarios = cantidadUsuarios;
    }
    
    public int getUsuariosActivos() {
        return usuariosActivos;
    }
    
    public void setUsuariosActivos(int usuariosActivos) {
        this.usuariosActivos = usuariosActivos;
    }
    
    public int getUsuariosInactivos() {
        return usuariosInactivos;
    }
    
    public void setUsuariosInactivos(int usuariosInactivos) {
        this.usuariosInactivos = usuariosInactivos;
    }
    
    @Override
    public String toString() {
        return "UsuariosPorRolDto{" +
                "nombreRol='" + nombreRol + '\'' +
                ", cantidadUsuarios=" + cantidadUsuarios +
                ", usuariosActivos=" + usuariosActivos +
                ", usuariosInactivos=" + usuariosInactivos +
                '}';
    }
}
