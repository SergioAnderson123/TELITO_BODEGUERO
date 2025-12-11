package com.example.telito.administrador.beans;

import java.sql.Timestamp;

/**
 * Bean que representa una notificación web.
 * Corresponde a la tabla notificaciones_web en la base de datos.
 */
public class Notificacion {
    
    private int idNotificacion;
    private int usuarioId;
    private String tipoNotificacion;
    private String titulo;
    private String mensaje;
    private String nivelPrioridad;
    private Integer productoId;
    private Integer loteId;
    private Integer pedidoId;
    private Integer ordenCompraId;
    private String urlAccion;
    private boolean leida;
    private Timestamp fechaCreacion;
    private Timestamp fechaLectura;
    
    // Campos adicionales para relaciones
    private String productoNombre;
    private String loteCodigo;
    private String pedidoNumero;
    private String ordenCompraNumero;

    // Constructor vacío
    public Notificacion() {
    }

    // Constructor completo
    public Notificacion(int usuarioId, String tipoNotificacion, String titulo, String mensaje, 
                       String nivelPrioridad, String urlAccion) {
        this.usuarioId = usuarioId;
        this.tipoNotificacion = tipoNotificacion;
        this.titulo = titulo;
        this.mensaje = mensaje;
        this.nivelPrioridad = nivelPrioridad;
        this.urlAccion = urlAccion;
        this.leida = false;
    }

    // Getters y Setters
    public int getIdNotificacion() {
        return idNotificacion;
    }

    public void setIdNotificacion(int idNotificacion) {
        this.idNotificacion = idNotificacion;
    }

    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
    }

    public String getTipoNotificacion() {
        return tipoNotificacion;
    }

    public void setTipoNotificacion(String tipoNotificacion) {
        this.tipoNotificacion = tipoNotificacion;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public String getNivelPrioridad() {
        return nivelPrioridad;
    }

    public void setNivelPrioridad(String nivelPrioridad) {
        this.nivelPrioridad = nivelPrioridad;
    }

    public Integer getProductoId() {
        return productoId;
    }

    public void setProductoId(Integer productoId) {
        this.productoId = productoId;
    }

    public Integer getLoteId() {
        return loteId;
    }

    public void setLoteId(Integer loteId) {
        this.loteId = loteId;
    }

    public Integer getPedidoId() {
        return pedidoId;
    }

    public void setPedidoId(Integer pedidoId) {
        this.pedidoId = pedidoId;
    }

    public Integer getOrdenCompraId() {
        return ordenCompraId;
    }

    public void setOrdenCompraId(Integer ordenCompraId) {
        this.ordenCompraId = ordenCompraId;
    }

    public String getUrlAccion() {
        return urlAccion;
    }

    public void setUrlAccion(String urlAccion) {
        this.urlAccion = urlAccion;
    }

    public boolean isLeida() {
        return leida;
    }

    public void setLeida(boolean leida) {
        this.leida = leida;
    }

    public Timestamp getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(Timestamp fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public Timestamp getFechaLectura() {
        return fechaLectura;
    }

    public void setFechaLectura(Timestamp fechaLectura) {
        this.fechaLectura = fechaLectura;
    }

    public String getProductoNombre() {
        return productoNombre;
    }

    public void setProductoNombre(String productoNombre) {
        this.productoNombre = productoNombre;
    }

    public String getLoteCodigo() {
        return loteCodigo;
    }

    public void setLoteCodigo(String loteCodigo) {
        this.loteCodigo = loteCodigo;
    }

    public String getPedidoNumero() {
        return pedidoNumero;
    }

    public void setPedidoNumero(String pedidoNumero) {
        this.pedidoNumero = pedidoNumero;
    }

    public String getOrdenCompraNumero() {
        return ordenCompraNumero;
    }

    public void setOrdenCompraNumero(String ordenCompraNumero) {
        this.ordenCompraNumero = ordenCompraNumero;
    }
}
