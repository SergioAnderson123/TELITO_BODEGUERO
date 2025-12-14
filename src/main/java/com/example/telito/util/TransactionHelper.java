package com.example.telito.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.SQLException;

// Helper para manejar transacciones de base de datos (commit/rollback automático)
public class TransactionHelper {

    private static final Logger logger = LoggerFactory.getLogger(TransactionHelper.class);

    // Ejecuta operación dentro de una transacción (rollback automático si hay error)
    public static <T> T executeInTransaction(TransactionOperation<T> operation) throws SQLException {
        Connection conn = null;
        boolean originalAutoCommit = true;
        
        try {
            conn = DatabaseConnection.getConnection();
            originalAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            
            logger.debug("Iniciando transacción");
            
            T result = operation.execute(conn);
            
            conn.commit();
            logger.debug("Transacción confirmada exitosamente");
            
            return result;
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    logger.warn("Transacción revertida debido a error: {}", e.getMessage());
                } catch (SQLException rollbackEx) {
                    logger.error("Error al hacer rollback: {}", rollbackEx.getMessage(), rollbackEx);
                }
            }
            throw e;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    logger.warn("Transacción revertida debido a excepción: {}", e.getMessage());
                } catch (SQLException rollbackEx) {
                    logger.error("Error al hacer rollback: {}", rollbackEx.getMessage(), rollbackEx);
                }
            }
            throw new SQLException("Error en transacción: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(originalAutoCommit);
                    conn.close();
                } catch (SQLException e) {
                    logger.error("Error al restaurar autoCommit o cerrar conexión: {}", e.getMessage(), e);
                }
            }
        }
    }

    // Ejecuta operación sin retorno dentro de una transacción
    public static void executeInTransactionVoid(TransactionOperationVoid operation) throws SQLException {
        executeInTransaction(conn -> {
            operation.execute(conn);
            return null;
        });
    }

    // Interfaz funcional para operaciones que retornan un valor
    @FunctionalInterface
    public interface TransactionOperation<T> {
        T execute(Connection conn) throws SQLException;
    }

    // Interfaz funcional para operaciones que no retornan valor
    @FunctionalInterface
    public interface TransactionOperationVoid {
        void execute(Connection conn) throws SQLException;
    }
}

