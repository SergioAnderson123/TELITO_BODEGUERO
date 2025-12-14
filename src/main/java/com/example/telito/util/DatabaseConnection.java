package com.example.telito.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

// Gestión centralizada de conexiones a la base de datos
public class DatabaseConnection {
    
    // Configuración de la base de datos
    private static final String URL = "jdbc:mysql://localhost:3306/telito_bodeguero";
    private static final String USER = "root";
    private static final String PASSWORD = "root";
    
    // Carga del driver MySQL una sola vez
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✓ Driver MySQL cargado correctamente");
        } catch (ClassNotFoundException e) {
            System.err.println("✗ Error al cargar el driver de MySQL");
            throw new RuntimeException("Error al cargar el driver de MySQL", e);
        }
    }
    
    // Constructor privado (clase utilitaria)
    private DatabaseConnection() {
    }
    
    // Obtiene nueva conexión a la base de datos
    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            // Configuración adicional de la conexión
            conn.setAutoCommit(true);
            return conn;
        } catch (SQLException e) {
            System.err.println("✗ Error al obtener conexión a la base de datos: " + e.getMessage());
            throw new SQLException("No se pudo establecer conexión con la base de datos", e);
        }
    }
    
    // Cierra conexión de forma segura
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("✗ Error al cerrar la conexión: " + e.getMessage());
            }
        }
    }
    
    // Verifica si la conexión a la base de datos está disponible
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("✗ Test de conexión fallido: " + e.getMessage());
            return false;
        }
    }
}

