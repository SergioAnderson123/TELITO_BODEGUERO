package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.Producto;
import java.sql.*;
import java.util.ArrayList;

public class ProductoDAO {

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

    // Para la tabla de inventario general, carga todos los productos.
    public ArrayList<Producto> listarProductos() {
        ArrayList<Producto> listaProductos = new ArrayList<>();
        String sql = "SELECT * FROM productos";

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Producto producto = new Producto();
                producto.setIdProducto(rs.getInt("id_producto"));
                producto.setCodigoSku(rs.getString("codigo_sku"));
                producto.setNombre(rs.getString("nombre"));
                producto.setDescripcion(rs.getString("descripcion"));
                producto.setPrecioActual(rs.getDouble("precio_actual"));
                producto.setStockMinimo(rs.getInt("stock_minimo"));
                producto.setStock(rs.getInt("stock"));
                producto.setUnidadesPorPaquete(rs.getInt("unidades_por_paquete"));
                producto.setProductorId(rs.getInt("productor_id"));
                producto.setCategoriaId(rs.getInt("categoria_id"));
                listaProductos.add(producto);
            }
        } catch (SQLException e) {
            System.out.println("Error en ProductoDAO.listarProductos(): " + e.getMessage());
            e.printStackTrace();
        }
        return listaProductos;
    }

    // Permite cambiar el stock mínimo de un producto desde la tabla de inventario.
    public void actualizarStockMinimo(int productoId, int stockMinimo) {
        String sql = "UPDATE productos SET stock_minimo = ? WHERE id_producto = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, stockMinimo);
            pstmt.setInt(2, productoId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Este es para una de las alertas, cuenta productos con stock por debajo del mínimo.
    public int contarProductosConAlertaDeStock() {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM productos WHERE stock <= stock_minimo AND stock_minimo > 0";
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (SQLException e) {
            System.out.println("Error en ProductoDAO.contarProductosConAlertaDeStock(): " + e.getMessage());
            e.printStackTrace();
        }
        return total;
    }
}
