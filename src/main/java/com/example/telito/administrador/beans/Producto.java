package com.example.telito.administrador.beans;

public class Producto {

    private int idProducto;
    private String codigoSku;
    private String nombre;
    private String descripcion;
    private double precioActual;
    private int stockMinimo;
    private int stock;
    private int unidadesPorPaquete; // <-- AÑADIDO
    private int productorId;      // <-- AÑADIDO
    private int categoriaId;      // <-- AÑADIDO
    private String categoriaNombre; // <-- AÑADIDO
    private boolean activo;       // <-- AÑADIDO
    private int numeroLotes;      // <-- AÑADIDO para mostrar cantidad de lotes
    private Categoria categoria;  // <-- AÑADIDO objeto Categoria completo

    // Getters y Setters

    public int getIdProducto() {
        return idProducto;
    }

    public void setIdProducto(int idProducto) {
        this.idProducto = idProducto;
    }

    public String getCodigoSku() {
        return codigoSku;
    }

    public void setCodigoSku(String codigoSku) {
        this.codigoSku = codigoSku;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public double getPrecioActual() {
        return precioActual;
    }

    public void setPrecioActual(double precioActual) {
        this.precioActual = precioActual;
    }

    public int getStockMinimo() {
        return stockMinimo;
    }

    public void setStockMinimo(int stockMinimo) {
        this.stockMinimo = stockMinimo;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int stock) {
        this.stock = stock;
    }

    public int getUnidadesPorPaquete() {
        return unidadesPorPaquete;
    }

    public void setUnidadesPorPaquete(int unidadesPorPaquete) {
        this.unidadesPorPaquete = unidadesPorPaquete;
    }

    public int getProductorId() {
        return productorId;
    }

    public void setProductorId(int productorId) {
        this.productorId = productorId;
    }

    public int getCategoriaId() {
        return categoriaId;
    }

    public void setCategoriaId(int categoriaId) {
        this.categoriaId = categoriaId;
    }

    public String getCategoriaNombre() {
        return categoriaNombre;
    }

    public void setCategoriaNombre(String categoriaNombre) {
        this.categoriaNombre = categoriaNombre;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public int getNumeroLotes() {
        return numeroLotes;
    }

    public void setNumeroLotes(int numeroLotes) {
        this.numeroLotes = numeroLotes;
    }

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
        this.categoria = categoria;
    }
}
