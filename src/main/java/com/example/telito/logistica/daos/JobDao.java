package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.Job;
import com.example.telito.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;

public class JobDao {

    public ArrayList<Job> listar(){
        String sql = "select * from zonas";
        ArrayList<Job> lista=new ArrayList<>();

        try {
            Connection conn = DatabaseConnection.getConnection();
            Statement stmt = conn.createStatement();

            ResultSet rs = stmt.executeQuery(sql);
            while(rs.next()){
                Job job=new Job();
                job.setIdZona(rs.getInt("idZona"));
                job.setNombre(rs.getString("nombre"));

                lista.add(job);

            }

        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        return lista;

    }
}
