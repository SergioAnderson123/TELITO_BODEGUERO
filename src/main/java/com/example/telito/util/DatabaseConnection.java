package com.example.telito.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

// Gestión centralizada de conexiones a la base de datos
public class DatabaseConnection {
    
    // Configuración de la base de datos (se carga desde application.properties)
    private static String URL = "jdbc:mysql://localhost:3306/telito_bodeguero?useUnicode=true&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=America/Lima";
    private static String USER = "root";
    private static String PASSWORD = "root";
    
    // Carga del driver MySQL y configuración una sola vez
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            loadDatabaseConfig();
            System.out.println("✓ Driver MySQL cargado correctamente");
        } catch (ClassNotFoundException e) {
            System.err.println("✗ Error al cargar el driver de MySQL");
            throw new RuntimeException("Error al cargar el driver de MySQL", e);
        }
    }
    
    // Carga configuración desde application-prod.properties o application.properties
    private static void loadDatabaseConfig() {
        Properties props = new Properties();
        
        // Primero intenta cargar application-prod.properties (producción)
        try (InputStream input = DatabaseConnection.class.getClassLoader()
                .getResourceAsStream("application-prod.properties")) {
            if (input != null) {
                props.load(input);
                System.out.println("✓ Cargando configuración desde application-prod.properties");
            }
        } catch (Exception e) {
            // Si no existe, intenta application.properties
        }
        
        // Si no se cargó prod, intenta application.properties
        if (props.isEmpty()) {
            try (InputStream input = DatabaseConnection.class.getClassLoader()
                    .getResourceAsStream("application.properties")) {
                if (input != null) {
                    props.load(input);
                    System.out.println("✓ Cargando configuración desde application.properties");
                }
            } catch (Exception e) {
                System.err.println("⚠ No se pudo cargar application.properties. Usando valores por defecto.");
            }
        }
        
        // Lee las propiedades (Spring Boot usa spring.datasource.*)
        String url = props.getProperty("spring.datasource.url");
        String user = props.getProperty("spring.datasource.username");
        String password = props.getProperty("spring.datasource.password");
        
        if (url != null && !url.isEmpty()) {
            URL = url;
        }
        if (user != null && !user.isEmpty()) {
            USER = user;
        }
        if (password != null && !password.isEmpty()) {
            PASSWORD = password;
        }
        
        System.out.println("✓ Configuración de BD: " + URL.replace(PASSWORD, "***"));
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
            // Asegurar que la conexión use UTF-8
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("SET NAMES 'utf8mb4'");
                stmt.execute("SET CHARACTER SET utf8mb4");
                stmt.execute("SET character_set_connection=utf8mb4");
            }
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

