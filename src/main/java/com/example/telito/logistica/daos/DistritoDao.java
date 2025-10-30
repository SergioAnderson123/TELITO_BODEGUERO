package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.DistritoBean;
import com.example.telito.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;

public class DistritoDao {

    public ArrayList<DistritoBean> listarDistritos() {
        ArrayList<DistritoBean> lista = new ArrayList<>();
        String sql = "SELECT idDistrito, nombre FROM distritos ORDER BY nombre ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                DistritoBean distrito = new DistritoBean();
                distrito.setId(rs.getInt("idDistrito"));
                distrito.setNombre(rs.getString("nombre"));
                lista.add(distrito);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
    
    // Listar distritos por zona
    public ArrayList<DistritoBean> listarDistritosPorZona(int zonaId) {
        ArrayList<DistritoBean> lista = new ArrayList<>();
        String sql = "SELECT idDistrito, nombre FROM distritos WHERE zona_id = ? ORDER BY nombre ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, zonaId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    DistritoBean distrito = new DistritoBean();
                    distrito.setId(rs.getInt("idDistrito"));
                    distrito.setNombre(rs.getString("nombre"));
                    lista.add(distrito);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
    
    // ========== MÉTODOS DE VALIDACIÓN ==========
    
    /**
     * Verifica si existe un distrito con el ID especificado
     */
    public boolean existeDistrito(int distritoId) {
        String sql = "SELECT COUNT(*) as total FROM distritos WHERE idDistrito = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, distritoId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total") > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al verificar existencia de distrito: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}