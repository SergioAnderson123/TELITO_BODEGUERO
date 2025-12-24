package com.example.telito.logistica.beans;

public class MovimientoInventarioBean {
    // Los 9 campos que necesita product-movement.html
    private int idMovimiento;           // ID del movimiento
    private String fechaFormateada;     // Fecha
    private String nombreProducto;      // Producto
    private String tipo;                // Tipo (Entrada/Salida/Ajuste)
    private int cantidad;               // Cantidad
    private String destino;             // Destino
    private String codigoLote;          // Lote
    private String responsable;         // Personal Responsable
    private String observaciones;       // Observaciones

    // Constructor vacío
    public MovimientoInventarioBean() {
    }

    // Constructor completo (sin cantidad - para compatibilidad)
    public MovimientoInventarioBean(String fechaFormateada, String nombreProducto, String tipo,
                                    String destino, String codigoLote, String responsable, String observaciones) {
        this.fechaFormateada = fechaFormateada;
        this.nombreProducto = nombreProducto;
        this.tipo = tipo;
        this.destino = destino;
        this.codigoLote = codigoLote;
        this.responsable = responsable;
        this.observaciones = observaciones;
        this.cantidad = 0; // Valor por defecto
    }

    // Constructor completo (con cantidad)
    public MovimientoInventarioBean(String fechaFormateada, String nombreProducto, String tipo, int cantidad,
                                    String destino, String codigoLote, String responsable, String observaciones) {
        this.fechaFormateada = fechaFormateada;
        this.nombreProducto = nombreProducto;
        this.tipo = tipo;
        this.cantidad = cantidad;
        this.destino = destino;
        this.codigoLote = codigoLote;
        this.responsable = responsable;
        this.observaciones = observaciones;
    }

    // Getters y Setters
    public String getFechaFormateada() {
        return fechaFormateada;
    }

    public void setFechaFormateada(String fechaFormateada) {
        this.fechaFormateada = fechaFormateada;
    }

    public String getNombreProducto() {
        return nombreProducto;
    }

    public void setNombreProducto(String nombreProducto) {
        this.nombreProducto = nombreProducto;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public int getCantidad() {
        return cantidad;
    }

    public void setCantidad(int cantidad) {
        this.cantidad = cantidad;
    }

    public String getDestino() {
        return destino;
    }

    public void setDestino(String destino) {
        this.destino = destino;
    }

    public String getCodigoLote() {
        return codigoLote;
    }

    public void setCodigoLote(String codigoLote) {
        this.codigoLote = codigoLote;
    }

    public String getResponsable() {
        return responsable;
    }

    public void setResponsable(String responsable) {
        this.responsable = responsable;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }

    public int getIdMovimiento() {
        return idMovimiento;
    }

    public void setIdMovimiento(int idMovimiento) {
        this.idMovimiento = idMovimiento;
    }
}