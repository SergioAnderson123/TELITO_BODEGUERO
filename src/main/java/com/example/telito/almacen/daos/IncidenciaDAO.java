package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.Incidencia;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

public class IncidenciaDAO extends DAOBase {
    
    /**
     * Crea una nueva incidencia.
     */
    public int crearIncidencia(Incidencia incidencia) {
        String sql = "INSERT INTO incidencias_almacen " +
                "(lote_id, producto_id, tipo_incidencia, cantidad_reportada, cantidad_sistema, " +
                "diferencia, motivo, descripcion, estado, usuario_reporte_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int generatedId = 0;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setInt(1, incidencia.getLoteId());
            pstmt.setInt(2, incidencia.getProductoId());
            pstmt.setString(3, incidencia.getTipoIncidencia());
            pstmt.setInt(4, incidencia.getCantidadReportada());
            pstmt.setInt(5, incidencia.getCantidadSistema());
            pstmt.setInt(6, incidencia.getDiferencia());
            pstmt.setString(7, incidencia.getMotivo());
            pstmt.setString(8, incidencia.getDescripcion());
            pstmt.setString(9, incidencia.getEstado() != null ? incidencia.getEstado() : "Pendiente");
            pstmt.setInt(10, incidencia.getUsuarioReporteId());
            
            pstmt.executeUpdate();
            
            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                generatedId = rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al crear incidencia", e);
            throw new RuntimeException("Error al crear incidencia", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return generatedId;
    }
    
    /**
     * Lista todas las incidencias con información detallada.
     */
    public ArrayList<Incidencia> listarIncidencias(String estado, String tipo, int page, int size) {
        ArrayList<Incidencia> incidencias = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT i.*, " +
            "l.codigo_lote, " +
            "p.nombre AS nombre_producto, " +
            "CONCAT(ur.nombres, ' ', ur.apellidos) AS nombre_usuario_reporte, " +
            "CONCAT(ures.nombres, ' ', ures.apellidos) AS nombre_usuario_resolucion " +
            "FROM incidencias_almacen i " +
            "INNER JOIN lotes l ON i.lote_id = l.id_lote " +
            "INNER JOIN productos p ON i.producto_id = p.id_producto " +
            "INNER JOIN usuarios ur ON i.usuario_reporte_id = ur.id_usuario " +
            "LEFT JOIN usuarios ures ON i.usuario_resolucion_id = ures.id_usuario " +
            "WHERE 1=1"
        );
        
        ArrayList<Object> params = new ArrayList<>();
        
        if (estado != null && !estado.trim().isEmpty()) {
            sql.append(" AND i.estado = ?");
            params.add(estado);
        }
        
        if (tipo != null && !tipo.trim().isEmpty()) {
            sql.append(" AND i.tipo_incidencia = ?");
            params.add(tipo);
        }
        
        sql.append(" ORDER BY i.fecha_reporte DESC LIMIT ? OFFSET ?");
        params.add(size);
        params.add((page - 1) * size);
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            setParameters(pstmt, params.toArray());
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Incidencia incidencia = mapearIncidencia(rs);
                incidencias.add(incidencia);
            }
        } catch (SQLException e) {
            logger.error("Error al listar incidencias", e);
            throw new RuntimeException("Error al listar incidencias", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return incidencias;
    }
    
    /**
     * Cuenta el total de incidencias con filtros.
     */
    public int contarIncidencias(String estado, String tipo) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM incidencias_almacen WHERE 1=1");
        ArrayList<Object> params = new ArrayList<>();
        
        if (estado != null && !estado.trim().isEmpty()) {
            sql.append(" AND estado = ?");
            params.add(estado);
        }
        
        if (tipo != null && !tipo.trim().isEmpty()) {
            sql.append(" AND tipo_incidencia = ?");
            params.add(tipo);
        }
        
        return count(sql.toString(), params.toArray());
    }
    
    /**
     * Obtiene una incidencia por ID.
     */
    public Incidencia obtenerIncidenciaPorId(int idIncidencia) {
        String sql = "SELECT i.*, " +
                "l.codigo_lote, " +
                "p.nombre AS nombre_producto, " +
                "CONCAT(ur.nombres, ' ', ur.apellidos) AS nombre_usuario_reporte, " +
                "CONCAT(ures.nombres, ' ', ures.apellidos) AS nombre_usuario_resolucion " +
                "FROM incidencias_almacen i " +
                "INNER JOIN lotes l ON i.lote_id = l.id_lote " +
                "INNER JOIN productos p ON i.producto_id = p.id_producto " +
                "INNER JOIN usuarios ur ON i.usuario_reporte_id = ur.id_usuario " +
                "LEFT JOIN usuarios ures ON i.usuario_resolucion_id = ures.id_usuario " +
                "WHERE i.id_incidencia = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Incidencia incidencia = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idIncidencia);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                incidencia = mapearIncidencia(rs);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener incidencia por ID", e);
            throw new RuntimeException("Error al obtener incidencia", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return incidencia;
    }
    
    /**
     * Actualiza el estado de una incidencia (resolución).
     */
    public void actualizarIncidencia(Incidencia incidencia) {
        String sql = "UPDATE incidencias_almacen SET " +
                "estado = ?, " +
                "usuario_resolucion_id = ?, " +
                "fecha_resolucion = ?, " +
                "observaciones_resolucion = ? " +
                "WHERE id_incidencia = ?";
        
        executeUpdate(sql,
            incidencia.getEstado(),
            incidencia.getUsuarioResolucionId(),
            incidencia.getFechaResolucion(),
            incidencia.getObservacionesResolucion(),
            incidencia.getIdIncidencia()
        );
    }
    
    /**
     * Mapea un ResultSet a un objeto Incidencia.
     */
    private Incidencia mapearIncidencia(ResultSet rs) throws SQLException {
        Incidencia incidencia = new Incidencia();
        incidencia.setIdIncidencia(rs.getInt("id_incidencia"));
        incidencia.setLoteId(rs.getInt("lote_id"));
        incidencia.setProductoId(rs.getInt("producto_id"));
        incidencia.setTipoIncidencia(rs.getString("tipo_incidencia"));
        incidencia.setCantidadReportada(rs.getInt("cantidad_reportada"));
        incidencia.setCantidadSistema(rs.getInt("cantidad_sistema"));
        incidencia.setDiferencia(rs.getInt("diferencia"));
        incidencia.setMotivo(rs.getString("motivo"));
        incidencia.setDescripcion(rs.getString("descripcion"));
        incidencia.setEstado(rs.getString("estado"));
        incidencia.setUsuarioReporteId(rs.getInt("usuario_reporte_id"));
        
        Integer usuarioResolucionId = rs.getObject("usuario_resolucion_id", Integer.class);
        incidencia.setUsuarioResolucionId(usuarioResolucionId);
        
        incidencia.setFechaReporte(rs.getTimestamp("fecha_reporte"));
        incidencia.setFechaResolucion(rs.getTimestamp("fecha_resolucion"));
        incidencia.setObservacionesResolucion(rs.getString("observaciones_resolucion"));
        
        // Campos adicionales
        incidencia.setCodigoLote(rs.getString("codigo_lote"));
        incidencia.setNombreProducto(rs.getString("nombre_producto"));
        incidencia.setNombreUsuarioReporte(rs.getString("nombre_usuario_reporte"));
        incidencia.setNombreUsuarioResolucion(rs.getString("nombre_usuario_resolucion"));
        
        return incidencia;
    }
    
    /**
     * Cuenta incidencias pendientes (para notificaciones).
     */
    public int contarIncidenciasPendientes() {
        String sql = "SELECT COUNT(*) FROM incidencias_almacen WHERE estado = 'Pendiente'";
        return count(sql);
    }
}

