package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.Categoria;
import com.example.telito.dao.BaseDao;

import java.sql.*;
import java.util.ArrayList;

/**
 * DAO para manejar operaciones relacionadas con categorías de productos.
 * Extiende de BaseDao para heredar la funcionalidad de conexión.
 */
public class CategoriaDAO extends BaseDao {

    /**
     * Obtiene la lista completa de categorías disponibles.
     * Útil para llenar ComboBoxes en formularios.
     * 
     * @return ArrayList<Categoria> lista de todas las categorías
     */
    public ArrayList<Categoria> listarCategorias() {
        ArrayList<Categoria> listaCategorias = new ArrayList<>();
        String sql = "SELECT id_categoria, nombre, descripcion FROM categorias WHERE activo = 1 ORDER BY nombre ASC";

        try (Connection conn = this.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Categoria categoria = new Categoria();
                categoria.setIdCategoria(rs.getInt("id_categoria"));
                categoria.setNombre(rs.getString("nombre"));
                categoria.setDescripcion(rs.getString("descripcion"));
                listaCategorias.add(categoria);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaCategorias;
    }

    /**
     * Obtiene una categoría específica por su ID.
     * 
     * @param idCategoria ID de la categoría a buscar
     * @return Categoria objeto categoría encontrada o null si no existe
     */
    public Categoria obtenerCategoriaPorId(int idCategoria) {
        Categoria categoria = null;
        String sql = "SELECT id_categoria, nombre, descripcion FROM categorias WHERE id_categoria = ?";

        try (Connection conn = this.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idCategoria);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    categoria = new Categoria();
                    categoria.setIdCategoria(rs.getInt("id_categoria"));
                    categoria.setNombre(rs.getString("nombre"));
                    categoria.setDescripcion(rs.getString("descripcion"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categoria;
    }

    /**
     * Cuenta el total de categorías activas.
     * Útil para estadísticas.
     * 
     * @return int número total de categorías activas
     */
    public int contarCategoriasActivas() {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM categorias WHERE activo = 1";
        
        try (Connection conn = this.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }
}
