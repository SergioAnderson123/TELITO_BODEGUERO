package com.example.telito.almacen.daos;


import com.example.telito.almacen.beans.Cliente;
import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.beans.Pedido;
import com.example.telito.almacen.beans.PedidoItem;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

public class PedidoDao extends DAOBase {

    public int contarPedidos() {
        return contarPedidos(null, null);
    }
    
    public int contarPedidos(String busqueda, String estado) {
        String sql = "SELECT COUNT(*) FROM pedidos p " +
                "LEFT JOIN clientes c ON p.cliente_id = c.id_cliente " +
                "WHERE 1=1";
        
        java.util.List<Object> params = new java.util.ArrayList<>();
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (p.numero_pedido LIKE ? OR p.destino LIKE ? OR c.nombre LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
            params.add(busquedaParam);
        }
        
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " AND p.estado_preparacion = ?";
            params.add(estado.trim());
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al contar pedidos", e);
            throw new RuntimeException("Error al contar pedidos", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }
    
    public ArrayList<Pedido> listarPedidosPaginados(int offset, int limit) {
        return listarPedidosPaginados(offset, limit, null, null);
    }
    
    public ArrayList<Pedido> listarPedidosPaginados(int offset, int limit, String busqueda, String estado) {
        ArrayList<Pedido> listaPedidos = new ArrayList<>();
        String sql = "SELECT p.id_pedido, p.numero_pedido, p.destino, p.estado_preparacion, " +
                "c.nombre AS nombre_cliente, c.id_cliente " +
                "FROM pedidos p " +
                "LEFT JOIN clientes c ON p.cliente_id = c.id_cliente " +
                "WHERE 1=1";

        java.util.List<Object> params = new java.util.ArrayList<>();
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (p.numero_pedido LIKE ? OR p.destino LIKE ? OR c.nombre LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
            params.add(busquedaParam);
        }
        
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " AND p.estado_preparacion = ?";
            params.add(estado.trim());
        }
        
        sql += " ORDER BY p.id_pedido DESC LIMIT ? OFFSET ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            
            int paramIndex = 1;
            for (Object param : params) {
                pstmt.setObject(paramIndex++, param);
            }
            
            pstmt.setInt(paramIndex++, limit);
            pstmt.setInt(paramIndex, offset);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Pedido pedido = new Pedido();
                pedido.setIdPedido(rs.getInt("id_pedido"));
                pedido.setNumeroPedido(rs.getString("numero_pedido"));
                pedido.setDestino(rs.getString("destino"));
                pedido.setEstadoPreparacion(rs.getString("estado_preparacion"));
                
                // Agregar cliente si existe
                Cliente cliente = new Cliente();
                cliente.setIdCliente(rs.getInt("id_cliente"));
                cliente.setNombre(rs.getString("nombre_cliente"));
                pedido.setCliente(cliente);
                
                listaPedidos.add(pedido);
            }
        } catch (SQLException e) {
            logger.error("Error al listar los pedidos", e);
            throw new RuntimeException("Error al listar los pedidos", e);
        } finally {
            closeResources(conn, pstmt, rs);
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

        Connection conn = null;
        PreparedStatement pstmtPedido = null;
        ResultSet rsPedido = null;
        PreparedStatement pstmtItems = null;
        ResultSet rsItems = null;

        try {
            conn = getConnection();
            pstmtPedido = conn.prepareStatement(sqlPedido);
            pstmtPedido.setInt(1, idPedido);
            rsPedido = pstmtPedido.executeQuery();

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

            if (pedido != null) {
                // CAMBIO 3: Necesitamos una instancia del LoteDao para buscar los lotes.
                LoteDao loteDao = new LoteDao();
                ArrayList<PedidoItem> listaItems = new ArrayList<>();

                pstmtItems = conn.prepareStatement(sqlItems);
                pstmtItems.setInt(1, idPedido);
                rsItems = pstmtItems.executeQuery();

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
                pedido.setItems(listaItems);
            }

        } catch (SQLException e) {
            logger.error("Error al buscar el pedido por ID: " + idPedido, e);
            throw new RuntimeException("Error al buscar el pedido por ID", e);
        } finally {
            closeResultSet(rsItems);
            closePreparedStatement(pstmtItems);
            closeResultSet(rsPedido);
            closePreparedStatement(pstmtPedido);
            closeConnection(conn);
        }
        return pedido;
    }

    public void actualizarEstado(int idPedido, String nuevoEstado) {
        String sql = "UPDATE pedidos SET estado_preparacion = ? WHERE id_pedido = ?";
        executeUpdate(sql, nuevoEstado, idPedido);
    }
    
    /**
     * Obtiene la lista de pedidos pendientes para recordatorios.
     * 
     * @return Lista de pedidos con estado "Pendiente"
     */
    public ArrayList<Pedido> listarPedidosPendientes() {
        ArrayList<Pedido> listaPedidos = new ArrayList<>();
        String sql = """
            SELECT p.id_pedido, p.numero_pedido, p.destino, p.estado_preparacion,
                   c.nombre AS nombre_cliente, c.id_cliente
            FROM pedidos p
            INNER JOIN clientes c ON p.cliente_id = c.id_cliente
            WHERE p.estado_preparacion = 'Pendiente'
            ORDER BY p.id_pedido ASC
            """;
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Pedido pedido = new Pedido();
                pedido.setIdPedido(rs.getInt("id_pedido"));
                pedido.setNumeroPedido(rs.getString("numero_pedido"));
                pedido.setDestino(rs.getString("destino"));
                pedido.setEstadoPreparacion(rs.getString("estado_preparacion"));
                
                // Agregar cliente si existe
                Cliente cliente = new Cliente();
                cliente.setIdCliente(rs.getInt("id_cliente"));
                cliente.setNombre(rs.getString("nombre_cliente"));
                pedido.setCliente(cliente);
                
                listaPedidos.add(pedido);
            }
        } catch (SQLException e) {
            logger.error("Error al listar pedidos pendientes", e);
            throw new RuntimeException("Error al listar pedidos pendientes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaPedidos;
    }
    
    /**
     * Cuenta la cantidad de pedidos pendientes.
     * 
     * @return Número de pedidos con estado "Pendiente"
     */
    public int contarPedidosPendientes() {
        String sql = "SELECT COUNT(*) FROM pedidos WHERE estado_preparacion = 'Pendiente'";
        return count(sql);
    }

    /**
     * Cuenta todos los pedidos
     */
    public int contarTotalPedidos() {
        String sql = "SELECT COUNT(*) FROM pedidos";
        return count(sql);
    }

    /**
     * Cuenta los pedidos despachados
     */
    public int contarPedidosDespachados() {
        String sql = "SELECT COUNT(*) FROM pedidos WHERE estado_preparacion = 'Despachado'";
        return count(sql);
    }

}