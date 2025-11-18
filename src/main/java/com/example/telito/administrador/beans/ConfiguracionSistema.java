package com.example.telito.administrador.beans;

import java.sql.Timestamp;

/**
 * Bean para representar una configuración del sistema.
 */
public class ConfiguracionSistema {
    
    private int idConfig;
    private String clave;
    private String valor;
    private String tipo; // STRING, NUMBER, BOOLEAN, JSON
    private String categoria; // EMAIL, SISTEMA, NOTIFICACIONES, SEGURIDAD, etc.
    private String descripcion;
    private boolean editable;
    private Timestamp fechaCreacion;
    private Timestamp fechaActualizacion;
    private Integer usuarioActualizacion;
    
    // Constructores
    public ConfiguracionSistema() {
    }
    
    public ConfiguracionSistema(String clave, String valor, String tipo, String categoria, String descripcion) {
        this.clave = clave;
        this.valor = valor;
        this.tipo = tipo;
        this.categoria = categoria;
        this.descripcion = descripcion;
        this.editable = true;
    }
    
    // Getters y Setters
    public int getIdConfig() {
        return idConfig;
    }
    
    public void setIdConfig(int idConfig) {
        this.idConfig = idConfig;
    }
    
    public String getClave() {
        return clave;
    }
    
    public void setClave(String clave) {
        this.clave = clave;
    }
    
    public String getValor() {
        return valor;
    }
    
    public void setValor(String valor) {
        this.valor = valor;
    }
    
    public String getTipo() {
        return tipo;
    }
    
    public void setTipo(String tipo) {
        this.tipo = tipo;
    }
    
    public String getCategoria() {
        return categoria;
    }
    
    public void setCategoria(String categoria) {
        this.categoria = categoria;
    }
    
    public String getDescripcion() {
        return descripcion;
    }
    
    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
    
    public boolean isEditable() {
        return editable;
    }
    
    public void setEditable(boolean editable) {
        this.editable = editable;
    }
    
    public Timestamp getFechaCreacion() {
        return fechaCreacion;
    }
    
    public void setFechaCreacion(Timestamp fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }
    
    public Timestamp getFechaActualizacion() {
        return fechaActualizacion;
    }
    
    public void setFechaActualizacion(Timestamp fechaActualizacion) {
        this.fechaActualizacion = fechaActualizacion;
    }
    
    public Integer getUsuarioActualizacion() {
        return usuarioActualizacion;
    }
    
    public void setUsuarioActualizacion(Integer usuarioActualizacion) {
        this.usuarioActualizacion = usuarioActualizacion;
    }
    
    // Métodos helper para obtener valores tipados
    public String getValorString() {
        return valor != null ? valor : "";
    }
    
    public int getValorInt() {
        try {
            return Integer.parseInt(valor);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
    
    public boolean getValorBoolean() {
        return "true".equalsIgnoreCase(valor) || "1".equals(valor);
    }
    
    public double getValorDouble() {
        try {
            return Double.parseDouble(valor);
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }
}

