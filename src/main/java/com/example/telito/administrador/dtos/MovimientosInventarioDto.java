package com.example.telito.administrador.dtos;

import java.time.LocalDate;

/**
 * DTO para reportes de movimientos de inventario por período.
 * Representa datos agregados que no mapean directamente a una tabla.
 */
public class MovimientosInventarioDto {
    
    private LocalDate fecha;
    private String tipoMovimiento;
    private int cantidadMovimientos;
    private int cantidadProductos;
    private String productoMasMovido;
    private String ubicacionMasActiva;
    
    // Constructores
    public MovimientosInventarioDto() {
    }
    
    public MovimientosInventarioDto(LocalDate fecha, String tipoMovimiento, int cantidadMovimientos, 
                                   int cantidadProductos, String productoMasMovido, String ubicacionMasActiva) {
        this.fecha = fecha;
        this.tipoMovimiento = tipoMovimiento;
        this.cantidadMovimientos = cantidadMovimientos;
        this.cantidadProductos = cantidadProductos;
        this.productoMasMovido = productoMasMovido;
        this.ubicacionMasActiva = ubicacionMasActiva;
    }
    
    // Getters y Setters
    public LocalDate getFecha() {
        return fecha;
    }
    
    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
    }
    
    public String getTipoMovimiento() {
        return tipoMovimiento;
    }
    
    public void setTipoMovimiento(String tipoMovimiento) {
        this.tipoMovimiento = tipoMovimiento;
    }
    
    public int getCantidadMovimientos() {
        return cantidadMovimientos;
    }
    
    public void setCantidadMovimientos(int cantidadMovimientos) {
        this.cantidadMovimientos = cantidadMovimientos;
    }
    
    public int getCantidadProductos() {
        return cantidadProductos;
    }
    
    public void setCantidadProductos(int cantidadProductos) {
        this.cantidadProductos = cantidadProductos;
    }
    
    public String getProductoMasMovido() {
        return productoMasMovido;
    }
    
    public void setProductoMasMovido(String productoMasMovido) {
        this.productoMasMovido = productoMasMovido;
    }
    
    public String getUbicacionMasActiva() {
        return ubicacionMasActiva;
    }
    
    public void setUbicacionMasActiva(String ubicacionMasActiva) {
        this.ubicacionMasActiva = ubicacionMasActiva;
    }
    
    @Override
    public String toString() {
        return "MovimientosInventarioDto{" +
                "fecha=" + fecha +
                ", tipoMovimiento='" + tipoMovimiento + '\'' +
                ", cantidadMovimientos=" + cantidadMovimientos +
                ", cantidadProductos=" + cantidadProductos +
                ", productoMasMovido='" + productoMasMovido + '\'' +
                ", ubicacionMasActiva='" + ubicacionMasActiva + '\'' +
                '}';
    }
}
