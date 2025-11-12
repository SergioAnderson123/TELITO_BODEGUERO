package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.Job;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;

public class JobDao extends DAOBase {

    public ArrayList<Job> listar(){
        String sql = "select * from zonas";
        ArrayList<Job> lista=new ArrayList<>();

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while(rs.next()){
                Job job=new Job();
                job.setIdZona(rs.getInt("idZona"));
                job.setNombre(rs.getString("nombre"));
                lista.add(job);
            }
        } catch (SQLException e) {
            logger.error("Error al listar jobs", e);
            throw new RuntimeException("Error al listar jobs", e);
        } finally {
            closeResources(conn, stmt, rs);
        }

        return lista;

    }
}
