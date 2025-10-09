package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.Job;
import java.sql.*;
import java.util.ArrayList;

public class JobDao {

    public ArrayList<Job> listar(){

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        String url="jdbc:mysql://localhost:3306/telito_bodeguero";
        String username="root";
        String password="root";
        String sql = "select * from zonas";

        ArrayList<Job> lista=new ArrayList<>();


        try {
            Connection conn = DriverManager.getConnection(url,username,password);
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
