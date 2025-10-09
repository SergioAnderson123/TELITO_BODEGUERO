package com.example.inventario.beans;
import java.util.List;

public class PedidoItem {

    // Este campo es útil para la lógica interna, aunque no se muestre directamente.
    private int productoId;
    private String codigoProducto;
    private String nombreProducto;
    private String nombreUbicacion;
    private int cantidadRequerida;
    private List<Lote> lotesDisponibles;


    public int getProductoId() {
        return productoId;
    }

    public void setProductoId(int productoId) {
        this.productoId = productoId;
    }

    public String getCodigoProducto() {
        return codigoProducto;
    }

    public void setCodigoProducto(String codigoProducto) {
        this.codigoProducto = codigoProducto;
    }

    public String getNombreProducto() {
        return nombreProducto;
    }

    public void setNombreProducto(String nombreProducto) {
        this.nombreProducto = nombreProducto;
    }

    public String getNombreUbicacion() {
        return nombreUbicacion;
    }

    public void setNombreUbicacion(String nombreUbicacion) {
        this.nombreUbicacion = nombreUbicacion;
    }

    public int getCantidadRequerida() {
        return cantidadRequerida;
    }

    public void setCantidadRequerida(int cantidadRequerida) {
        this.cantidadRequerida = cantidadRequerida;
    }

    public List<Lote> getLotesDisponibles() {
        return lotesDisponibles;
    }

    public void setLotesDisponibles(List<Lote> lotesDisponibles) {
        this.lotesDisponibles = lotesDisponibles;
    }
}