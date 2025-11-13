package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.LoteBean;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

public class LoteDao extends DAOBase {

    public ArrayList<LoteBean> listarLotesDisponibles() {
        ArrayList<LoteBean> lista = new ArrayList<>();
        // Solo listar lotes del almacén (con ubicacion_id asignada), no del productor
        String sql = """
            SELECT l.id_lote, l.codigo_lote, p.nombre AS nombre_producto
            FROM lotes l
            INNER JOIN productos p ON l.producto_id = p.id_producto
            WHERE l.stock_actual > 0 
            AND l.estado = 'Registrado'
            AND l.ubicacion_id IS NOT NULL
            ORDER BY p.nombre, l.codigo_lote;
            """;

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                LoteBean lote = new LoteBean();
                lote.setId(rs.getInt("id_lote"));
                lote.setCodigoLote(rs.getString("codigo_lote"));
                lote.setNombreProducto(rs.getString("nombre_producto"));
                lista.add(lote);
            }
        } catch (SQLException e) {
            logger.error("Error al listar lotes disponibles", e);
            throw new RuntimeException("Error al listar lotes disponibles", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
}