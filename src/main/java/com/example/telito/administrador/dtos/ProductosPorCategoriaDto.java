package com.example.telito.administrador.dtos;

import java.math.BigDecimal;

/**
 * DTO para reportes de productos por categoría con estadísticas de precios.
 * Representa datos agregados que no mapean directamente a una tabla.
 */
public class ProductosPorCategoriaDto {
    
    private String nombreCategoria;
    private int cantidadProductos;
    private BigDecimal precioPromedio;
    private BigDecimal precioMinimo;
    private BigDecimal precioMaximo;
    private int stockTotal;
    private int productosConStockBajo;
    
    // Constructores
    public ProductosPorCategoriaDto() {
    }
    
    public ProductosPorCategoriaDto(String nombreCategoria, int cantidadProductos, 
                                   BigDecimal precioPromedio, BigDecimal precioMinimo, 
                                   BigDecimal precioMaximo, int stockTotal, int productosConStockBajo) {
        this.nombreCategoria = nombreCategoria;
        this.cantidadProductos = cantidadProductos;
        this.precioPromedio = precioPromedio;
        this.precioMinimo = precioMinimo;
        this.precioMaximo = precioMaximo;
        this.stockTotal = stockTotal;
        this.productosConStockBajo = productosConStockBajo;
    }
    
    // Getters y Setters
    public String getNombreCategoria() {
        return nombreCategoria;
    }
    
    public void setNombreCategoria(String nombreCategoria) {
        this.nombreCategoria = nombreCategoria;
    }
    
    public int getCantidadProductos() {
        return cantidadProductos;
    }
    
    public void setCantidadProductos(int cantidadProductos) {
        this.cantidadProductos = cantidadProductos;
    }
    
    public BigDecimal getPrecioPromedio() {
        return precioPromedio;
    }
    
    public void setPrecioPromedio(BigDecimal precioPromedio) {
        this.precioPromedio = precioPromedio;
    }
    
    public BigDecimal getPrecioMinimo() {
        return precioMinimo;
    }
    
    public void setPrecioMinimo(BigDecimal precioMinimo) {
        this.precioMinimo = precioMinimo;
    }
    
    public BigDecimal getPrecioMaximo() {
        return precioMaximo;
    }
    
    public void setPrecioMaximo(BigDecimal precioMaximo) {
        this.precioMaximo = precioMaximo;
    }
    
    public int getStockTotal() {
        return stockTotal;
    }
    
    public void setStockTotal(int stockTotal) {
        this.stockTotal = stockTotal;
    }
    
    public int getProductosConStockBajo() {
        return productosConStockBajo;
    }
    
    public void setProductosConStockBajo(int productosConStockBajo) {
        this.productosConStockBajo = productosConStockBajo;
    }
    
    @Override
    public String toString() {
        return "ProductosPorCategoriaDto{" +
                "nombreCategoria='" + nombreCategoria + '\'' +
                ", cantidadProductos=" + cantidadProductos +
                ", precioPromedio=" + precioPromedio +
                ", precioMinimo=" + precioMinimo +
                ", precioMaximo=" + precioMaximo +
                ", stockTotal=" + stockTotal +
                ", productosConStockBajo=" + productosConStockBajo +
                '}';
    }
}
