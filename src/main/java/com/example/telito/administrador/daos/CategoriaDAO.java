package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.Categoria;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

public class CategoriaDAO extends DAOBase {

    // Listar todas las categorías
    public ArrayList<Categoria> listarCategorias() {
        ArrayList<Categoria> lista = new ArrayList<>();
        String sql = "SELECT * FROM categorias ORDER BY nombre";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Categoria categoria = new Categoria();
                categoria.setIdCategoria(rs.getInt("id_categoria"));
                categoria.setNombre(rs.getString("nombre"));
                lista.add(categoria);
            }
        } catch (SQLException e) {
            logger.error("Error al listar categorías", e);
            throw new RuntimeException("Error al listar categorías", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return lista;
    }

    // Obtener categoría por ID
    public Categoria obtenerPorId(int id) {
        String sql = "SELECT * FROM categorias WHERE id_categoria = ?";
        Categoria categoria = null;

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                categoria = new Categoria();
                categoria.setIdCategoria(rs.getInt("id_categoria"));
                categoria.setNombre(rs.getString("nombre"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener categoría por ID: " + id, e);
            throw new RuntimeException("Error al obtener categoría", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return categoria;
    }
}