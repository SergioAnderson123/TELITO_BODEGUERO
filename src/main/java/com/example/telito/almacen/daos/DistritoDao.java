package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.Distrito;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;

public class DistritoDao extends DAOBase {

    public ArrayList<Distrito> listar() {
        ArrayList<Distrito> lista = new ArrayList<>();
        String sql = "SELECT * FROM distritos";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Distrito distrito = new Distrito();
                distrito.setIdDistrito(rs.getInt("idDistrito"));
                distrito.setNombre(rs.getString("nombre"));
                lista.add(distrito);
            }
        } catch (SQLException e) {
            logger.error("Error al listar distritos", e);
            throw new RuntimeException("Error al listar distritos", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return lista;
    }
}