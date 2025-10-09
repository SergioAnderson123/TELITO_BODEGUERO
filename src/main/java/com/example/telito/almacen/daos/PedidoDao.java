package com.example.telito.almacen.daos;


import com.example.telito.almacen.beans.Cliente;
import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.beans.Pedido;
import com.example.telito.almacen.beans.PedidoItem;

import java.sql.*;
import java.util.ArrayList;

public class PedidoDao {

    private String url = "jdbc:mysql://localhost:3306/telito4"; // Reemplaza con tu base de datos
    private String user = "root";
    private String pass = "chupamela2005"; // Reemplaza con tu contraseña


    public ArrayList<Pedido> listarPedidosPendientes() {
        ArrayList<Pedido> listaPedidos = new ArrayList<>();
        // Asumimos que la tabla 'pedidos' tiene una columna 'destino'
        String sql = "SELECT p.id_pedido, p.numero_pedido, p.destino, p.estado_preparacion " +
                " FROM pedidos p ";

        try{Class.forName("com.mysql.cj.jdbc.Driver");
        }catch(ClassNotFoundException e){
            throw new RuntimeException(e);
        }

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Pedido pedido = new Pedido();
                pedido.setIdPedido(rs.getInt("id_pedido"));
                pedido.setNumeroPedido(rs.getString("numero_pedido"));
                pedido.setDestino(rs.getString("destino"));
                pedido.setEstadoPreparacion(rs.getString("estado_preparacion"));
                listaPedidos.add(pedido);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al listar los pedidosss", e);
        }
        return listaPedidos;
    }


    public Pedido buscarPedidoPorId(int idPedido) {
        Pedido pedido = null;
        String sqlPedido = " SELECT p.id_pedido, p.numero_pedido, p.destino, c.nombre " +
                " FROM pedidos p " +
                " INNER JOIN clientes c ON (p.cliente_id = c.id_cliente) " +
                " WHERE p.id_pedido = ? ";

        // CAMBIO 1: La consulta de items ahora es más simple.
        // Ya no necesita unirse con 'lotes' ni 'ubicaciones'.
        String sqlItems = "SELECT pi.producto_id, pi.cantidad_requerida, prod.codigo_sku, prod.nombre " +
                "FROM pedido_items pi " +
                "INNER JOIN productos prod ON (pi.producto_id = prod.id_producto) " +
                "WHERE pi.pedido_id = ?";

        try (Connection conn = DriverManager.getConnection(url, user, pass)) {

            try (PreparedStatement pstmtPedido = conn.prepareStatement(sqlPedido)) {
                pstmtPedido.setInt(1, idPedido);
                try (ResultSet rsPedido = pstmtPedido.executeQuery()) {
                    if (rsPedido.next()) {
                        pedido = new Pedido();
                        // CAMBIO 2: Corrige los nombres de las columnas para que no usen el alias de la tabla.
                        pedido.setIdPedido(rsPedido.getInt("id_pedido"));
                        pedido.setNumeroPedido(rsPedido.getString("numero_pedido"));
                        pedido.setDestino(rsPedido.getString("destino"));

                        Cliente cliente = new Cliente();
                        cliente.setNombre(rsPedido.getString("c.nombre"));
                        pedido.setCliente(cliente);
                    }
                }
            }

            if (pedido != null) {
                // CAMBIO 3: Necesitamos una instancia del LoteDao para buscar los lotes.
                LoteDao loteDao = new LoteDao();
                ArrayList<PedidoItem> listaItems = new ArrayList<>();

                try (PreparedStatement pstmtItems = conn.prepareStatement(sqlItems)) {
                    pstmtItems.setInt(1, idPedido);
                    try (ResultSet rsItems = pstmtItems.executeQuery()) {
                        while (rsItems.next()) {
                            PedidoItem item = new PedidoItem();
                            item.setProductoId(rsItems.getInt("producto_id"));
                            item.setCantidadRequerida(rsItems.getInt("cantidad_requerida"));
                            item.setCodigoProducto(rsItems.getString("codigo_sku"));
                            item.setNombreProducto(rsItems.getString("prod.nombre"));

                            // CAMBIO 4: Por cada item, llamamos al LoteDao para que nos traiga
                            // la lista de lotes disponibles para ese producto.
                            ArrayList<Lote> lotesDisponibles = loteDao.buscarLotesPorProducto(item.getProductoId());
                            item.setLotesDisponibles(lotesDisponibles); // Asumiendo que PedidoItem.java tiene este método set

                            listaItems.add(item);
                        }
                    }
                }
                pedido.setItems(listaItems);
            }

        } catch (SQLException e) {
            throw new RuntimeException("Error al buscar el pedido por ID", e);
        }
        return pedido;
    }

    public void actualizarEstado(int idPedido, String nuevoEstado) {
        String sql = "UPDATE pedidos SET estado_preparacion = ? WHERE id_pedido = ?";

        try{Class.forName("com.mysql.cj.jdbc.Driver");
        }catch(ClassNotFoundException e){
            throw new RuntimeException(e);
        }

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, nuevoEstado);
            pstmt.setInt(2, idPedido);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("Error al actualizar el estado del pedido", e);
        }
    }

}