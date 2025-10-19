package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.ProductoBean;
import com.example.telito.dao.BaseDao;
import java.sql.*;
import java.util.ArrayList;

public class ProductoDao extends BaseDao {

    public ArrayList<ProductoBean> listarProductos() {
        ArrayList<ProductoBean> listaProductos = new ArrayList<>();
        String sql = "SELECT id_producto, nombre, precio_unitario FROM productos ORDER BY nombre ASC";

        try (Connection conn = this.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                ProductoBean producto = new ProductoBean();
                producto.setId(rs.getInt("id_producto"));
                producto.setNombre(rs.getString("nombre"));
                producto.setPrecio(rs.getBigDecimal("precio_unitario"));
                listaProductos.add(producto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaProductos;
    }
}