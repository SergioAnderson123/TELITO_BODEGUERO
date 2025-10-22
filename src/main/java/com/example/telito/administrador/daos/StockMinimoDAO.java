package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.StockMinimoConfig;
import com.example.telito.administrador.beans.Producto;

import java.sql.*;
import java.util.ArrayList;

public class StockMinimoDAO {

    private String user = "root";
    private String pass = "root";
    private String url = "jdbc:mysql://localhost:3306/telito_bodeguero";

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        return DriverManager.getConnection(url, user, pass);
    }

    // Listar todas las configuraciones de stock mínimo
    public ArrayList<StockMinimoConfig> listarConfiguraciones() {
        ArrayList<StockMinimoConfig> lista = new ArrayList<>();
        String sql = "SELECT smc.*, p.nombre as producto_nombre, p.codigo_sku as producto_codigo " +
                "FROM stock_minimo_config smc " +
                "JOIN productos p ON smc.producto_id = p.id_producto " +
                "WHERE smc.activo = 1 " +
                "ORDER BY p.nombre";

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                StockMinimoConfig config = new StockMinimoConfig();
                config.setIdStockMinimo(rs.getInt("id_stock_minimo"));
                config.setStockMinimo(rs.getInt("stock_minimo"));
                config.setStockCritico(rs.getInt("stock_critico"));
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
            e.printStackTrace();
        }
        return lista;
    }

    // Obtener configuración por ID de producto
    public StockMinimoConfig obtenerPorProducto(int productoId) {
        String sql = "SELECT * FROM stock_minimo_config WHERE producto_id = ? AND activo = 1";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productoId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                StockMinimoConfig config = new StockMinimoConfig();
                config.setIdStockMinimo(rs.getInt("id_stock_minimo"));
                config.setStockMinimo(rs.getInt("stock_minimo"));
                config.setStockCritico(rs.getInt("stock_critico"));
                config.setActivo(rs.getBoolean("activo"));
                config.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                config.setFechaActualizacion(rs.getTimestamp("fecha_actualizacion"));

                Producto producto = new Producto();
                producto.setIdProducto(rs.getInt("producto_id"));
                config.setProducto(producto);

                return config;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Crear nueva configuración
    public boolean crearConfiguracion(StockMinimoConfig config) {
        String sql = "INSERT INTO stock_minimo_config (producto_id, stock_minimo, stock_critico, activo) VALUES (?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, config.getProducto().getIdProducto());
            pstmt.setInt(2, config.getStockMinimo());
            pstmt.setInt(3, config.getStockCritico());
            pstmt.setBoolean(4, config.isActivo());

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Actualizar configuración existente
    public boolean actualizarConfiguracion(StockMinimoConfig config) {
        String sql = "UPDATE stock_minimo_config SET stock_minimo = ?, stock_critico = ?, activo = ? WHERE id_stock_minimo = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, config.getStockMinimo());
            pstmt.setInt(2, config.getStockCritico());
            pstmt.setBoolean(3, config.isActivo());
            pstmt.setInt(4, config.getIdStockMinimo());

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Eliminar configuración (marcar como inactiva)
    public boolean eliminarConfiguracion(int idStockMinimo) {
        String sql = "UPDATE stock_minimo_config SET activo = 0 WHERE id_stock_minimo = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idStockMinimo);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Obtener stock mínimo global por defecto
    public int obtenerStockMinimoGlobal() {
        String sql = "SELECT valor FROM parametros_sistema WHERE clave = 'STOCK_MINIMO_GLOBAL' AND activo = 1";

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return Integer.parseInt(rs.getString("valor"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 10; // Valor por defecto
    }

    // Obtener stock crítico global por defecto
    public int obtenerStockCriticoGlobal() {
        String sql = "SELECT valor FROM parametros_sistema WHERE clave = 'STOCK_CRITICO_GLOBAL' AND activo = 1";

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return Integer.parseInt(rs.getString("valor"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 5; // Valor por defecto
    }
}