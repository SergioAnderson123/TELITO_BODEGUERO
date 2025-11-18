package com.example.telito.almacen.beans;

import java.sql.Timestamp;

public class Incidencia {
    private int idIncidencia;
    private int loteId;
    private int productoId;
    private String tipoIncidencia; // Faltante, Sobrante
    private int cantidadReportada;
    private int cantidadSistema;
    private int diferencia;
    private String motivo;
    private String descripcion;
    private String estado; // Pendiente, En Revisión, Resuelta, Cerrada
    private int usuarioReporteId;
    private Integer usuarioResolucionId;
    private Timestamp fechaReporte;
    private Timestamp fechaResolucion;
    private String observacionesResolucion;
    
    // Campos adicionales para mostrar en vistas
    private String codigoLote;
    private String nombreProducto;
    private String nombreUsuarioReporte;
    private String nombreUsuarioResolucion;
    
    // Constructor vacío
    public Incidencia() {}
    
    // Getters y Setters
    public int getIdIncidencia() {
        return idIncidencia;
    }
    
    public void setIdIncidencia(int idIncidencia) {
        this.idIncidencia = idIncidencia;
    }
    
    public int getLoteId() {
        return loteId;
    }
    
    public void setLoteId(int loteId) {
        this.loteId = loteId;
    }
    
    public int getProductoId() {
        return productoId;
    }
    
    public void setProductoId(int productoId) {
        this.productoId = productoId;
    }
    
    public String getTipoIncidencia() {
        return tipoIncidencia;
    }
    
    public void setTipoIncidencia(String tipoIncidencia) {
        this.tipoIncidencia = tipoIncidencia;
    }
    
    public int getCantidadReportada() {
        return cantidadReportada;
    }
    
    public void setCantidadReportada(int cantidadReportada) {
        this.cantidadReportada = cantidadReportada;
    }
    
    public int getCantidadSistema() {
        return cantidadSistema;
    }
    
    public void setCantidadSistema(int cantidadSistema) {
        this.cantidadSistema = cantidadSistema;
    }
    
    public int getDiferencia() {
        return diferencia;
    }
    
    public void setDiferencia(int diferencia) {
        this.diferencia = diferencia;
    }
    
    public String getMotivo() {
        return motivo;
    }
    
    public void setMotivo(String motivo) {
        this.motivo = motivo;
    }
    
    public String getDescripcion() {
        return descripcion;
    }
    
    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
    
    public String getEstado() {
        return estado;
    }
    
    public void setEstado(String estado) {
        this.estado = estado;
    }
    
    public int getUsuarioReporteId() {
        return usuarioReporteId;
    }
    
    public void setUsuarioReporteId(int usuarioReporteId) {
        this.usuarioReporteId = usuarioReporteId;
    }
    
    public Integer getUsuarioResolucionId() {
        return usuarioResolucionId;
    }
    
    public void setUsuarioResolucionId(Integer usuarioResolucionId) {
        this.usuarioResolucionId = usuarioResolucionId;
    }
    
    public Timestamp getFechaReporte() {
        return fechaReporte;
    }
    
    public void setFechaReporte(Timestamp fechaReporte) {
        this.fechaReporte = fechaReporte;
    }
    
    public Timestamp getFechaResolucion() {
        return fechaResolucion;
    }
    
    public void setFechaResolucion(Timestamp fechaResolucion) {
        this.fechaResolucion = fechaResolucion;
    }
    
    public String getObservacionesResolucion() {
        return observacionesResolucion;
    }
    
    public void setObservacionesResolucion(String observacionesResolucion) {
        this.observacionesResolucion = observacionesResolucion;
    }
    
    // Campos adicionales
    public String getCodigoLote() {
        return codigoLote;
    }
    
    public void setCodigoLote(String codigoLote) {
        this.codigoLote = codigoLote;
    }
    
    public String getNombreProducto() {
        return nombreProducto;
    }
    
    public void setNombreProducto(String nombreProducto) {
        this.nombreProducto = nombreProducto;
    }
    
    public String getNombreUsuarioReporte() {
        return nombreUsuarioReporte;
    }
    
    public void setNombreUsuarioReporte(String nombreUsuarioReporte) {
        this.nombreUsuarioReporte = nombreUsuarioReporte;
    }
    
    public String getNombreUsuarioResolucion() {
        return nombreUsuarioResolucion;
    }
    
    public void setNombreUsuarioResolucion(String nombreUsuarioResolucion) {
        this.nombreUsuarioResolucion = nombreUsuarioResolucion;
    }
}

