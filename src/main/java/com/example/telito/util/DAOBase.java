package com.example.telito.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// Clase base abstracta para todos los DAOs (métodos comunes de conexión y operaciones)
public abstract class DAOBase {
    
    protected static final Logger logger = LoggerFactory.getLogger(DAOBase.class);
    
    // Obtiene conexión a la base de datos
    protected Connection getConnection() throws SQLException {
        return DatabaseConnection.getConnection();
    }
    
    // Cierra conexión de forma segura
    protected void closeConnection(Connection conn) {
        DatabaseConnection.closeConnection(conn);
    }
    
    // Cierra PreparedStatement de forma segura
    protected void closePreparedStatement(PreparedStatement pstmt) {
        if (pstmt != null) {
            try {
                pstmt.close();
            } catch (SQLException e) {
                logger.error("Error al cerrar PreparedStatement", e);
            }
        }
    }
    
    // Cierra Statement de forma segura
    protected void closeStatement(Statement stmt) {
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                logger.error("Error al cerrar Statement", e);
            }
        }
    }
    
    // Cierra ResultSet de forma segura
    protected void closeResultSet(ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                logger.error("Error al cerrar ResultSet", e);
            }
        }
    }
    
    // Cierra todos los recursos (Connection, Statement, ResultSet)
    protected void closeResources(Connection conn, Statement stmt, ResultSet rs) {
        closeResultSet(rs);
        closeStatement(stmt);
        closeConnection(conn);
    }
    
    // Cierra todos los recursos (Connection, PreparedStatement, ResultSet)
    protected void closeResources(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        closeResultSet(rs);
        closePreparedStatement(pstmt);
        closeConnection(conn);
    }
    
    // Ejecuta consulta SELECT y retorna número de filas (sin parámetros)
    protected int count(String sql) {
        return count(sql, null);
    }
    
    // Ejecuta consulta SELECT con parámetros y retorna número de filas
    protected int count(String sql, Object... params) {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            
            if (params != null) {
                setParameters(pstmt, params);
            }
            
            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al ejecutar count: " + sql, e);
            throw new RuntimeException("Error al contar registros", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return count;
    }
    
    // Ejecuta INSERT/UPDATE/DELETE (sin parámetros)
    protected int executeUpdate(String sql) {
        return executeUpdate(sql, null);
    }
    
    // Ejecuta INSERT/UPDATE/DELETE con parámetros
    protected int executeUpdate(String sql, Object... params) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        int rowsAffected = 0;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            
            if (params != null) {
                setParameters(pstmt, params);
            }
            
            rowsAffected = pstmt.executeUpdate();
            logger.debug("Filas afectadas: {} para consulta: {}", rowsAffected, sql);
        } catch (SQLException e) {
            logger.error("Error al ejecutar update: " + sql, e);
            throw new RuntimeException("Error al ejecutar operación de actualización", e);
        } finally {
            closeResources(conn, pstmt, null);
        }
        
        return rowsAffected;
    }
    
    /**
     * Ejecuta una consulta INSERT y retorna el ID generado.
     * 
     * @param sql Consulta SQL INSERT
     * @param params Parámetros para la consulta
     * @return ID generado (generated key)
     */
    protected int executeInsert(String sql, Object... params) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int generatedId = -1;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            
            if (params != null) {
                setParameters(pstmt, params);
            }
            
            pstmt.executeUpdate();
            
            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                generatedId = rs.getInt(1);
            }
            
            logger.debug("ID generado: {} para consulta: {}", generatedId, sql);
        } catch (SQLException e) {
            logger.error("Error al ejecutar insert: " + sql, e);
            throw new RuntimeException("Error al ejecutar operación de inserción", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return generatedId;
    }
    
    /**
     * Establece los parámetros en un PreparedStatement.
     * 
     * @param pstmt PreparedStatement
     * @param params Parámetros a establecer
     * @throws SQLException si hay un error al establecer los parámetros
     */
    protected void setParameters(PreparedStatement pstmt, Object... params) throws SQLException {
        if (params == null) {
            return;
        }
        
        for (int i = 0; i < params.length; i++) {
            int index = i + 1;
            Object param = params[i];
            
            if (param == null) {
                pstmt.setNull(index, Types.NULL);
            } else if (param instanceof Integer) {
                pstmt.setInt(index, (Integer) param);
            } else if (param instanceof Long) {
                pstmt.setLong(index, (Long) param);
            } else if (param instanceof Double) {
                pstmt.setDouble(index, (Double) param);
            } else if (param instanceof Float) {
                pstmt.setFloat(index, (Float) param);
            } else if (param instanceof Boolean) {
                pstmt.setBoolean(index, (Boolean) param);
            } else if (param instanceof Date) {
                pstmt.setDate(index, (Date) param);
            } else if (param instanceof Timestamp) {
                pstmt.setTimestamp(index, (Timestamp) param);
            } else if (param instanceof String) {
                pstmt.setString(index, (String) param);
            } else {
                pstmt.setObject(index, param);
            }
        }
    }
    
    /**
     * Ejecuta una consulta SELECT y retorna un ResultSet.
     * Este método debe ser usado con cuidado ya que requiere cerrar manualmente los recursos.
     * Se recomienda usar los métodos específicos que manejan el ResultSet automáticamente.
     * 
     * @param sql Consulta SQL
     * @return ResultSet
     * @throws SQLException si hay un error al ejecutar la consulta
     */
    protected ResultSet executeQuery(String sql) throws SQLException {
        return executeQuery(sql, null);
    }
    
    /**
     * Ejecuta una consulta SELECT con parámetros y retorna un ResultSet.
     * Este método debe ser usado con cuidado ya que requiere cerrar manualmente los recursos.
     * 
     * @param sql Consulta SQL con placeholders (?)
     * @param params Parámetros para la consulta
     * @return ResultSet
     * @throws SQLException si hay un error al ejecutar la consulta
     */
    protected ResultSet executeQuery(String sql, Object... params) throws SQLException {
        Connection conn = getConnection();
        PreparedStatement pstmt = conn.prepareStatement(sql);
        
        if (params != null) {
            setParameters(pstmt, params);
        }
        
        return pstmt.executeQuery();
    }
    
    /**
     * Inicia una transacción.
     * 
     * @param conn Conexión
     * @throws SQLException si hay un error al iniciar la transacción
     */
    protected void beginTransaction(Connection conn) throws SQLException {
        if (conn != null && !conn.isClosed()) {
            conn.setAutoCommit(false);
            logger.debug("Transacción iniciada");
        }
    }
    
    /**
     * Confirma una transacción.
     * 
     * @param conn Conexión
     * @throws SQLException si hay un error al confirmar la transacción
     */
    protected void commitTransaction(Connection conn) throws SQLException {
        if (conn != null && !conn.isClosed()) {
            conn.commit();
            conn.setAutoCommit(true);
            logger.debug("Transacción confirmada");
        }
    }
    
    /**
     * Revierte una transacción.
     * 
     * @param conn Conexión
     */
    protected void rollbackTransaction(Connection conn) {
        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    conn.rollback();
                    conn.setAutoCommit(true);
                    logger.debug("Transacción revertida");
                }
            } catch (SQLException e) {
                logger.error("Error al revertir transacción", e);
            }
        }
    }
    
    /**
     * Verifica si existe un registro con el ID especificado en una tabla.
     * 
     * @param tableName Nombre de la tabla
     * @param idColumnName Nombre de la columna de ID
     * @param id Valor del ID
     * @return true si existe, false en caso contrario
     */
    protected boolean exists(String tableName, String idColumnName, Object id) {
        String sql = "SELECT COUNT(*) FROM " + tableName + " WHERE " + idColumnName + " = ?";
        return count(sql, id) > 0;
    }
    
    /**
     * Verifica si existe un registro con condiciones específicas.
     * 
     * @param tableName Nombre de la tabla
     * @param conditions Condiciones WHERE (sin la palabra WHERE)
     * @param params Parámetros para las condiciones
     * @return true si existe, false en caso contrario
     */
    protected boolean exists(String tableName, String conditions, Object... params) {
        String sql = "SELECT COUNT(*) FROM " + tableName + " WHERE " + conditions;
        return count(sql, params) > 0;
    }
}

