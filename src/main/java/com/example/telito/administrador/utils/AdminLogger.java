package com.example.telito.administrador.utils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Sistema de logging simple pero efectivo para el módulo administrador.
 * En producción se recomienda usar Log4j o SLF4J.
 */
public class AdminLogger {
    
    private static final String LOG_FILE = "logs/admin.log";
    private static final DateTimeFormatter TIMESTAMP_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    
    public enum LogLevel {
        INFO, WARN, ERROR, DEBUG
    }
    
    /**
     * Registra un mensaje de información.
     */
    public static void info(String message) {
        log(LogLevel.INFO, message, null);
    }
    
    /**
     * Registra un mensaje de advertencia.
     */
    public static void warn(String message) {
        log(LogLevel.WARN, message, null);
    }
    
    /**
     * Registra un mensaje de error.
     */
    public static void error(String message) {
        log(LogLevel.ERROR, message, null);
    }
    
    /**
     * Registra un mensaje de error con excepción.
     */
    public static void error(String message, Throwable throwable) {
        log(LogLevel.ERROR, message, throwable);
    }
    
    /**
     * Registra un mensaje de debug.
     */
    public static void debug(String message) {
        log(LogLevel.DEBUG, message, null);
    }
    
    /**
     * Método principal de logging.
     */
    private static void log(LogLevel level, String message, Throwable throwable) {
        String timestamp = LocalDateTime.now().format(TIMESTAMP_FORMAT);
        String logEntry = String.format("[%s] [%s] %s", timestamp, level, message);
        
        // También imprimir en consola para desarrollo
        System.out.println(logEntry);
        
        if (throwable != null) {
            System.out.println("Exception: " + throwable.getMessage());
            throwable.printStackTrace();
        }
        
        // Escribir en archivo de log
        try (PrintWriter writer = new PrintWriter(new FileWriter(LOG_FILE, true))) {
            writer.println(logEntry);
            if (throwable != null) {
                writer.println("Exception: " + throwable.getMessage());
                throwable.printStackTrace(writer);
            }
        } catch (IOException e) {
            System.err.println("Error writing to log file: " + e.getMessage());
        }
    }
    
    /**
     * Registra el inicio de una operación de usuario.
     */
    public static void logUserOperation(String operation, String userEmail, String details) {
        info(String.format("USER_OPERATION: %s by %s - %s", operation, userEmail, details));
    }
    
    /**
     * Registra intentos de login.
     */
    public static void logLoginAttempt(String email, boolean success) {
        if (success) {
            info(String.format("LOGIN_SUCCESS: %s", email));
        } else {
            warn(String.format("LOGIN_FAILED: %s", email));
        }
    }
    
    /**
     * Registra operaciones de base de datos.
     */
    public static void logDatabaseOperation(String operation, String table, boolean success) {
        LogLevel level = success ? LogLevel.INFO : LogLevel.ERROR;
        log(level, String.format("DB_OPERATION: %s on %s - %s", operation, table, success ? "SUCCESS" : "FAILED"), null);
    }
}
