package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.StockMinimoConfig;
import com.example.telito.administrador.beans.Producto;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

public class StockMinimoDAO extends DAOBase {

    // Listar todas las configuraciones de stock mínimo
    public ArrayList<StockMinimoConfig> listarConfiguraciones() {
        ArrayList<StockMinimoConfig> lista = new ArrayList<>();
        String sql = "SELECT smc.*, p.nombre as producto_nombre, p.codigo_sku as producto_codigo " +
                "FROM stock_minimo_config smc " +
                "JOIN productos p ON smc.producto_id = p.id_producto " +
                "WHERE smc.activo = 1 " +
                "ORDER BY p.nombre";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                StockMinimoConfig config = new StockMinimoConfig();
                config.setIdStockMinimo(rs.getInt("id_stock_minimo"));
                config.setStockMinimoProducto(rs.getInt("stock_minimo_producto"));
                config.setStockCriticoProducto(rs.getInt("stock_critico_producto"));
                config.setStockMinimoLote(rs.getInt("stock_minimo_lote"));
                config.setStockCriticoLote(rs.getInt("stock_critico_lote"));
                config.setActivo(rs.getBoolean("activo"));
                config.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                config.setFechaActualizacion(rs.getTimestamp("fecha_actualizacion"));

                // Crear objeto producto básico
                Producto producto = new Producto();
                producto.setIdProducto(rs.getInt("producto_id"));
                producto.setNombre(rs.getString("producto_nombre"));
                producto.setCodigoSku(rs.getString("producto_codigo"));
                config.setProducto(producto);

                lista.add(config);
            }
        } catch (SQLException e) {
            logger.error("Error al listar configuraciones de stock mínimo", e);
            throw new RuntimeException("Error al listar configuraciones de stock mínimo", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return lista;
    }

    // Obtener configuración por ID de producto
    public StockMinimoConfig obtenerPorProducto(int productoId) {
        String sql = "SELECT * FROM stock_minimo_config WHERE producto_id = ? AND activo = 1";

        StockMinimoConfig config = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productoId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                config = new StockMinimoConfig();
                config.setIdStockMinimo(rs.getInt("id_stock_minimo"));
                config.setStockMinimoProducto(rs.getInt("stock_minimo_producto"));
                config.setStockCriticoProducto(rs.getInt("stock_critico_producto"));
                config.setStockMinimoLote(rs.getInt("stock_minimo_lote"));
                config.setStockCriticoLote(rs.getInt("stock_critico_lote"));
                config.setActivo(rs.getBoolean("activo"));
                config.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                config.setFechaActualizacion(rs.getTimestamp("fecha_actualizacion"));

                Producto producto = new Producto();
                producto.setIdProducto(rs.getInt("producto_id"));
                config.setProducto(producto);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener configuración por producto ID: " + productoId, e);
            throw new RuntimeException("Error al obtener configuración de stock mínimo", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return config;
    }

    // Crear nueva configuración
    public boolean crearConfiguracion(StockMinimoConfig config) {
        String sql = "INSERT INTO stock_minimo_config (producto_id, stock_minimo_producto, stock_critico_producto, stock_minimo_lote, stock_critico_lote, activo) VALUES (?, ?, ?, ?, ?, ?)";
        int filasAfectadas = executeUpdate(sql, 
            config.getProducto().getIdProducto(),
            config.getStockMinimoProducto(),
            config.getStockCriticoProducto(),
            config.getStockMinimoLote(),
            config.getStockCriticoLote(),
            config.isActivo());
        return filasAfectadas > 0;
    }

    // Actualizar configuración existente
    public boolean actualizarConfiguracion(StockMinimoConfig config) {
        String sql = "UPDATE stock_minimo_config SET stock_minimo_producto = ?, stock_critico_producto = ?, stock_minimo_lote = ?, stock_critico_lote = ?, activo = ? WHERE id_stock_minimo = ?";
        int filasAfectadas = executeUpdate(sql,
            config.getStockMinimoProducto(),
            config.getStockCriticoProducto(),
            config.getStockMinimoLote(),
            config.getStockCriticoLote(),
            config.isActivo(),
            config.getIdStockMinimo());
        return filasAfectadas > 0;
    }

    // Eliminar configuración (marcar como inactiva)
    public boolean eliminarConfiguracion(int idStockMinimo) {
        String sql = "UPDATE stock_minimo_config SET activo = 0 WHERE id_stock_minimo = ?";
        int filasAfectadas = executeUpdate(sql, idStockMinimo);
        return filasAfectadas > 0;
    }

    // Obtener stock mínimo global por defecto
    public int obtenerStockMinimoGlobal() {
        String sql = "SELECT valor FROM parametros_sistema WHERE clave = 'STOCK_MINIMO_GLOBAL' AND activo = 1";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            if (rs.next()) {
                return Integer.parseInt(rs.getString("valor"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener stock mínimo global", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return 10; // Valor por defecto
    }

    // Obtener stock crítico global por defecto
    public int obtenerStockCriticoGlobal() {
        String sql = "SELECT valor FROM parametros_sistema WHERE clave = 'STOCK_CRITICO_GLOBAL' AND activo = 1";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            if (rs.next()) {
                return Integer.parseInt(rs.getString("valor"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener stock crítico global", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return 5; // Valor por defecto
    }

    /**
     * Obtiene todas las configuraciones de stock mínimo sin filtros.
     * Útil para exportar a Excel.
     * 
     * @return Lista completa de configuraciones de stock mínimo
     */
    public ArrayList<StockMinimoConfig> listarTodasConfiguraciones() {
        ArrayList<StockMinimoConfig> lista = new ArrayList<>();
        String sql = "SELECT smc.*, p.nombre as producto_nombre, p.codigo_sku as producto_codigo " +
                "FROM stock_minimo_config smc " +
                "JOIN productos p ON smc.producto_id = p.id_producto " +
                "ORDER BY p.nombre";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                StockMinimoConfig config = new StockMinimoConfig();
                config.setIdStockMinimo(rs.getInt("id_stock_minimo"));
                config.setStockMinimoProducto(rs.getInt("stock_minimo_producto"));
                config.setStockCriticoProducto(rs.getInt("stock_critico_producto"));
                config.setStockMinimoLote(rs.getInt("stock_minimo_lote"));
                config.setStockCriticoLote(rs.getInt("stock_critico_lote"));
                config.setActivo(rs.getBoolean("activo"));
                config.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                config.setFechaActualizacion(rs.getTimestamp("fecha_actualizacion"));

                // Crear objeto producto básico
                Producto producto = new Producto();
                producto.setIdProducto(rs.getInt("producto_id"));
                producto.setNombre(rs.getString("producto_nombre"));
                producto.setCodigoSku(rs.getString("producto_codigo"));
                config.setProducto(producto);

                lista.add(config);
            }
        } catch (SQLException e) {
            logger.error("Error al listar configuraciones de stock mínimo", e);
            throw new RuntimeException("Error al listar configuraciones de stock mínimo", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return lista;
    }
}