package com.example.telito.logistica.beans;

public class InventarioBean {

    // CAMPOS CORREGIDOS para que coincidan 100% con los alias de la consulta SQL
    private String sku;
    private String nombreProducto;
    private int cantidadLotes;
    private String codigosDeLote;             // CAMBIADO: de codigoLote a codigosDeLote (plural)
    private String proximoVencimiento;        // CAMBIADO: de fechaVencimientoFormateada a proximoVencimiento
    private String estadoStock;
    private int stockTotal;                   // AÑADIDO: para el nuevo campo SUM(stock_actual)

    // Constructor vacío
    public InventarioBean() {
    }

    // CONSTRUCTOR CORREGIDO: Eliminado "ubicacion" y ajustados los nombres de los parámetros
    public InventarioBean(String sku, String nombreProducto, int cantidadLotes, String codigosDeLote, String proximoVencimiento, String estadoStock, int stockTotal) {
        this.sku = sku;
        this.nombreProducto = nombreProducto;
        this.cantidadLotes = cantidadLotes;
        this.codigosDeLote = codigosDeLote;
        this.proximoVencimiento = proximoVencimiento;
        this.estadoStock = estadoStock;
        this.stockTotal = stockTotal;
    }

    // GETTERS Y SETTERS CORREGIDOS Y AÑADIDOS
    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }



    public String getNombreProducto() {
        return nombreProducto;
    }

    public void setNombreProducto(String nombreProducto) {
        this.nombreProducto = nombreProducto;
    }

    public int getCantidadLotes() {
        return cantidadLotes;
    }

    public void setCantidadLotes(int cantidadLotes) {
        this.cantidadLotes = cantidadLotes;
    }

    public String getCodigosDeLote() {
        return codigosDeLote;
    }

    public void setCodigosDeLote(String codigosDeLote) {
        this.codigosDeLote = codigosDeLote;
    }

    public String getProximoVencimiento() {
        return proximoVencimiento;
    }

    public void setProximoVencimiento(String proximoVencimiento) {
        this.proximoVencimiento = proximoVencimiento;
    }

    public String getEstadoStock() {
        return estadoStock;
    }

    public void setEstadoStock(String estadoStock) {
        this.estadoStock = estadoStock;
    }

    public int getStockTotal() {
        return stockTotal;
    }

    public void setStockTotal(int stockTotal) {
        this.stockTotal = stockTotal;
    }
}