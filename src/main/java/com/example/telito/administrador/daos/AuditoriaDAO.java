package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.AuditoriaLog;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

// DAO para gestionar registros de auditoría
public class AuditoriaDAO extends DAOBase {
    
    // Registra una acción en el log de auditoría
    public int registrarAccion(AuditoriaLog log) {
        String sql = """
            INSERT INTO auditoria_sistema 
            (usuario_id, usuario_nombre, accion, modulo, descripcion, 
             datos_anteriores, datos_nuevos, ip_address, user_agent, estado, mensaje_error)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;
        
        return executeInsert(sql,
            log.getUsuarioId(),
            log.getUsuarioNombre(),
            log.getAccion(),
            log.getModulo(),
            log.getDescripcion(),
            log.getDatosAnteriores(),
            log.getDatosNuevos(),
            log.getIpAddress(),
            log.getUserAgent(),
            log.getEstado(),
            log.getMensajeError()
        );
    }
    
    // Lista registros de auditoría con filtros y paginación
    public ArrayList<AuditoriaLog> listarAuditoria(String usuarioId, String accion, 
                                                   String modulo, String estado,
                                                   String fechaDesde, String fechaHasta,
                                                   int page, int size) {
        ArrayList<AuditoriaLog> lista = new ArrayList<>();
        
        // Construir consulta base
        StringBuilder sql = new StringBuilder("""
            SELECT id_auditoria, usuario_id, usuario_nombre, accion, modulo, descripcion,
                   datos_anteriores, datos_nuevos, ip_address, user_agent, 
                   fecha_accion, estado, mensaje_error
            FROM auditoria_sistema
            WHERE 1=1
            """);
        
        ArrayList<Object> params = new ArrayList<>();
        
        // Agregar filtros dinámicamente
        if (usuarioId != null && !usuarioId.trim().isEmpty()) {
            sql.append(" AND usuario_id = ?");
            params.add(Integer.parseInt(usuarioId));
        }
        
        if (accion != null && !accion.trim().isEmpty()) {
            sql.append(" AND accion LIKE ?");
            params.add("%" + accion + "%");
        }
        
        if (modulo != null && !modulo.trim().isEmpty()) {
            sql.append(" AND modulo = ?");
            params.add(modulo);
        }
        
        if (estado != null && !estado.trim().isEmpty()) {
            sql.append(" AND estado = ?");
            params.add(estado);
        }
        
        if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
            sql.append(" AND DATE(fecha_accion) >= ?");
            params.add(fechaDesde);
        }
        
        if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
            sql.append(" AND DATE(fecha_accion) <= ?");
            params.add(fechaHasta);
        }
        
        sql.append(" ORDER BY fecha_accion DESC LIMIT ? OFFSET ?");
        int offset = (page - 1) * size;
        params.add(size);
        params.add(offset);
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            setParameters(pstmt, params.toArray());
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                AuditoriaLog log = new AuditoriaLog();
                log.setIdAuditoria(rs.getInt("id_auditoria"));
                log.setUsuarioId(rs.getInt("usuario_id"));
                log.setUsuarioNombre(rs.getString("usuario_nombre"));
                log.setAccion(rs.getString("accion"));
                log.setModulo(rs.getString("modulo"));
                log.setDescripcion(rs.getString("descripcion"));
                log.setDatosAnteriores(rs.getString("datos_anteriores"));
                log.setDatosNuevos(rs.getString("datos_nuevos"));
                log.setIpAddress(rs.getString("ip_address"));
                log.setUserAgent(rs.getString("user_agent"));
                log.setFechaAccion(rs.getTimestamp("fecha_accion"));
                log.setEstado(rs.getString("estado"));
                log.setMensajeError(rs.getString("mensaje_error"));
                lista.add(log);
            }
        } catch (SQLException e) {
            logger.error("Error al listar auditoría", e);
            throw new RuntimeException("Error al listar registros de auditoría", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return lista;
    }
    
    /**
     * Cuenta el total de registros de auditoría con filtros.
     */
    public int contarAuditoria(String usuarioId, String accion, String modulo, 
                               String estado, String fechaDesde, String fechaHasta) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM auditoria_sistema WHERE 1=1");
        ArrayList<Object> params = new ArrayList<>();
        
        if (usuarioId != null && !usuarioId.trim().isEmpty()) {
            sql.append(" AND usuario_id = ?");
            params.add(Integer.parseInt(usuarioId));
        }
        
        if (accion != null && !accion.trim().isEmpty()) {
            sql.append(" AND accion LIKE ?");
            params.add("%" + accion + "%");
        }
        
        if (modulo != null && !modulo.trim().isEmpty()) {
            sql.append(" AND modulo = ?");
            params.add(modulo);
        }
        
        if (estado != null && !estado.trim().isEmpty()) {
            sql.append(" AND estado = ?");
            params.add(estado);
        }
        
        if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
            sql.append(" AND DATE(fecha_accion) >= ?");
            params.add(fechaDesde);
        }
        
        if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
            sql.append(" AND DATE(fecha_accion) <= ?");
            params.add(fechaHasta);
        }
        
        return count(sql.toString(), params.toArray());
    }
    
    /**
     * Obtiene estadísticas de auditoría para el dashboard.
     */
    public java.util.Map<String, Integer> obtenerEstadisticas() {
        java.util.Map<String, Integer> stats = new java.util.HashMap<>();
        
        // Total de acciones hoy
        String sqlHoy = "SELECT COUNT(*) FROM auditoria_sistema WHERE DATE(fecha_accion) = CURDATE()";
        stats.put("accionesHoy", count(sqlHoy));
        
        // Total de acciones esta semana
        String sqlSemana = "SELECT COUNT(*) FROM auditoria_sistema WHERE fecha_accion >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
        stats.put("accionesSemana", count(sqlSemana));
        
        // Acciones fallidas hoy
        String sqlFallidas = "SELECT COUNT(*) FROM auditoria_sistema WHERE DATE(fecha_accion) = CURDATE() AND estado = 'FALLIDO'";
        stats.put("accionesFallidas", count(sqlFallidas));
        
        // Módulo más activo (últimos 7 días)
        String sqlModulo = """
            SELECT modulo, COUNT(*) as total 
            FROM auditoria_sistema 
            WHERE fecha_accion >= DATE_SUB(NOW(), INTERVAL 7 DAY)
            GROUP BY modulo 
            ORDER BY total DESC 
            LIMIT 1
            """;
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sqlModulo);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                stats.put("moduloMasActivo", rs.getInt("total"));
            } else {
                stats.put("moduloMasActivo", 0);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener estadísticas de módulo", e);
            stats.put("moduloMasActivo", 0);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return stats;
    }
}

