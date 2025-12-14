package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.LoteBean;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

// DAO para gestión de lotes desde perspectiva de logística
public class LoteDao extends DAOBase {

    // Lista lotes disponibles del almacén (con ubicación asignada y stock > 0)
    public ArrayList<LoteBean> listarLotesDisponibles() {
        ArrayList<LoteBean> lista = new ArrayList<>();
        // Solo lotes del almacén, no del productor
        String sql = """
            SELECT l.id_lote, l.codigo_lote, p.nombre AS nombre_producto, l.stock_actual, l.estado, l.ubicacion_id
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
            
            logger.info("=== DEBUG LoteDao.listarLotesDisponibles ===");
            int count = 0;

            while (rs.next()) {
                LoteBean lote = new LoteBean();
                lote.setId(rs.getInt("id_lote"));
                lote.setCodigoLote(rs.getString("codigo_lote"));
                lote.setNombreProducto(rs.getString("nombre_producto"));
                lista.add(lote);
                count++;
                logger.debug("Lote encontrado: ID={}, Codigo={}, Producto={}, Stock={}, Estado={}, Ubicacion={}", 
                    lote.getId(), lote.getCodigoLote(), lote.getNombreProducto(),
                    rs.getInt("stock_actual"), rs.getString("estado"), rs.getInt("ubicacion_id"));
            }
            logger.info("Total de lotes disponibles encontrados: {}", count);
            
            // Log de depuración si no hay lotes
            if (count == 0) {
                logger.warn("⚠️ No se encontraron lotes disponibles. Verificando lotes en la BD...");
                String sqlDebug = "SELECT l.id_lote, l.codigo_lote, p.nombre AS nombre_producto, " +
                                 "l.stock_actual, l.estado, l.ubicacion_id " +
                                 "FROM lotes l " +
                                 "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                                 "ORDER BY l.id_lote DESC LIMIT 10";
                try (PreparedStatement pstmtDebug = conn.prepareStatement(sqlDebug);
                     ResultSet rsDebug = pstmtDebug.executeQuery()) {
                    logger.warn("=== Últimos 10 lotes en la BD ===");
                    while (rsDebug.next()) {
                        logger.warn("Lote: ID={}, Codigo={}, Producto={}, Stock={}, Estado={}, Ubicacion={}", 
                            rsDebug.getInt("id_lote"), rsDebug.getString("codigo_lote"), 
                            rsDebug.getString("nombre_producto"), rsDebug.getInt("stock_actual"),
                            rsDebug.getString("estado"), rsDebug.getInt("ubicacion_id"));
                    }
                } catch (SQLException e) {
                    logger.error("Error en consulta de depuración", e);
                }
            }
        } catch (SQLException e) {
            logger.error("Error al listar lotes disponibles", e);
            throw new RuntimeException("Error al listar lotes disponibles", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }

    /**
     * Lista lotes disponibles filtrados por productor
     * @param productorId ID del productor
     * @return Lista de lotes disponibles del productor especificado
     */
    public ArrayList<LoteBean> listarLotesDisponiblesPorProductor(int productorId) {
        ArrayList<LoteBean> lista = new ArrayList<>();
        // Solo listar lotes del almacén (con ubicacion_id asignada) del productor especificado
        String sql = """
            SELECT l.id_lote, l.codigo_lote, p.nombre AS nombre_producto
            FROM lotes l
            INNER JOIN productos p ON l.producto_id = p.id_producto
            WHERE l.stock_actual > 0 
            AND l.estado = 'Registrado'
            AND l.ubicacion_id IS NOT NULL
            AND p.productor_id = ?
            ORDER BY p.nombre, l.codigo_lote;
            """;

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productorId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                LoteBean lote = new LoteBean();
                lote.setId(rs.getInt("id_lote"));
                lote.setCodigoLote(rs.getString("codigo_lote"));
                lote.setNombreProducto(rs.getString("nombre_producto"));
                lista.add(lote);
            }
        } catch (SQLException e) {
            logger.error("Error al listar lotes disponibles por productor: " + productorId, e);
            throw new RuntimeException("Error al listar lotes disponibles por productor", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
}