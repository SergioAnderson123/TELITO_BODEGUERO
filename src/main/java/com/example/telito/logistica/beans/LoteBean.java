package com.example.telito.logistica.beans;

// Bean para representar un lote (versión simplificada para logística)
public class LoteBean {
    private int id;
    private String codigoLote;
    private String nombreProducto; // Para mostrar "Producto (Lote)"
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCodigoLote() { return codigoLote; }
    public void setCodigoLote(String codigoLote) { this.codigoLote = codigoLote; }
    public String getNombreProducto() { return nombreProducto; }
    public void setNombreProducto(String nombreProducto) { this.nombreProducto = nombreProducto; }
}