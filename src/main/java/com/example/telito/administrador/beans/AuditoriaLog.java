package com.example.telito.administrador.beans;

import java.sql.Timestamp;

// Bean para representar un registro de auditoría
public class AuditoriaLog {
    
    private int idAuditoria;
    private Integer usuarioId; // Puede ser null para acciones sin usuario
    private String usuarioNombre;
    private String accion;
    private String modulo;
    private String descripcion;
    private String datosAnteriores; // JSON como String
    private String datosNuevos; // JSON como String
    private String ipAddress;
    private String userAgent;
    private Timestamp fechaAccion;
    private String estado; // EXITOSO, FALLIDO, ERROR
    private String mensajeError;
    public AuditoriaLog() {
    }
    
    public AuditoriaLog(Integer usuarioId, String usuarioNombre, String accion, String modulo, 
                       String descripcion, String ipAddress, String userAgent) {
        this.usuarioId = usuarioId;
        this.usuarioNombre = usuarioNombre;
        this.accion = accion;
        this.modulo = modulo;
        this.descripcion = descripcion;
        this.ipAddress = ipAddress;
        this.userAgent = userAgent;
        this.estado = "EXITOSO";
    }
    
    // Getters y Setters
    public int getIdAuditoria() {
        return idAuditoria;
    }
    
    public void setIdAuditoria(int idAuditoria) {
        this.idAuditoria = idAuditoria;
    }
    
    public Integer getUsuarioId() {
        return usuarioId;
    }
    
    public void setUsuarioId(Integer usuarioId) {
        this.usuarioId = usuarioId;
    }
    
    public String getUsuarioNombre() {
        return usuarioNombre;
    }
    
    public void setUsuarioNombre(String usuarioNombre) {
        this.usuarioNombre = usuarioNombre;
    }
    
    public String getAccion() {
        return accion;
    }
    
    public void setAccion(String accion) {
        this.accion = accion;
    }
    
    public String getModulo() {
        return modulo;
    }
    
    public void setModulo(String modulo) {
        this.modulo = modulo;
    }
    
    public String getDescripcion() {
        return descripcion;
    }
    
    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
    
    public String getDatosAnteriores() {
        return datosAnteriores;
    }
    
    public void setDatosAnteriores(String datosAnteriores) {
        this.datosAnteriores = datosAnteriores;
    }
    
    public String getDatosNuevos() {
        return datosNuevos;
    }
    
    public void setDatosNuevos(String datosNuevos) {
        this.datosNuevos = datosNuevos;
    }
    
    public String getIpAddress() {
        return ipAddress;
    }
    
    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }
    
    public String getUserAgent() {
        return userAgent;
    }
    
    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }
    
    public Timestamp getFechaAccion() {
        return fechaAccion;
    }
    
    public void setFechaAccion(Timestamp fechaAccion) {
        this.fechaAccion = fechaAccion;
    }
    
    public String getEstado() {
        return estado;
    }
    
    public void setEstado(String estado) {
        this.estado = estado;
    }
    
    public String getMensajeError() {
        return mensajeError;
    }
    
    public void setMensajeError(String mensajeError) {
        this.mensajeError = mensajeError;
    }
}

