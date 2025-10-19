package com.example.telito.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Clase abstracta BaseDao que centraliza la lógica de conexión a la base de datos.
 * 
 * Esta clase implementa el patrón de diseño DAO Base para evitar la repetición
 * del código de conexión en todas las clases DAO del proyecto.
 * 
 * Características:
 * - Clase abstracta: No puede ser instanciada directamente
 * - Método getConnection(): Maneja la carga del driver y creación de conexión
 * - Configuración centralizada de credenciales de base de datos
 */
public abstract class BaseDao {
    
    // Configuración de la base de datos
    private static final String DB_URL = "jdbc:mysql://localhost:3306/telito_bodeguero";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "root";
    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    
    /**
     * Estático para cargar el driver una sola vez al inicio de la aplicación
     */
    static {
        try {
            Class.forName(DB_DRIVER);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Error al cargar el driver de MySQL: " + e.getMessage(), e);
        }
    }
    
    /**
     * Método protegido para obtener una conexión a la base de datos.
     * 
     * Este método maneja:
     * - La carga del driver MySQL (ya cargado en el bloque estático)
     * - La creación de la conexión con las credenciales configuradas
     * - El manejo de excepciones SQL
     * 
     * @return Connection objeto de conexión a la base de datos
     * @throws SQLException si ocurre un error al establecer la conexión
     */
    protected Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }
    
    /**
     * Método utilitario para cerrar recursos de base de datos de forma segura.
     * 
     * @param connection conexión a cerrar
     */
    protected void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                System.err.println("Error al cerrar la conexión: " + e.getMessage());
            }
        }
    }
}
