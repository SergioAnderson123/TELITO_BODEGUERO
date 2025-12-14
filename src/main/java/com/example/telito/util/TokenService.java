package com.example.telito.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.UUID;

// Servicio para gestión segura de tokens (activación y recuperación de contraseña)
// Tokens hasheados SHA-256, rate limiting, auditoría y prevención de reutilización
public class TokenService {
    
    private static final Logger logger = LoggerFactory.getLogger(TokenService.class);
    
    // Configuración de expiración
    private static final int HORAS_EXPIRACION_ACTIVACION = 48; // 48 horas para activación
    private static final int HORAS_EXPIRACION_RECUPERACION = 1; // 1 hora para recuperación
    
    // Límites de seguridad
    private static final int MAX_INTENTOS_ACTIVACION = 5; // Máximo 5 intentos de activación
    private static final int MAX_TOKENS_PENDIENTES = 3; // Máximo 3 tokens pendientes por usuario
    
    // Genera token único y seguro (128 caracteres)
    public static String generarToken() {
        // Combinar UUID + timestamp + random para mayor seguridad
        String token = UUID.randomUUID().toString().replace("-", "") +
                      UUID.randomUUID().toString().replace("-", "") +
                      System.currentTimeMillis() +
                      new SecureRandom().nextInt(1000000);
        
        // Asegurar que tenga exactamente 128 caracteres
        while (token.length() < 128) {
            token += UUID.randomUUID().toString().replace("-", "");
        }
        
        return token.substring(0, 128);
    }
    
    // Genera hash SHA-256 de un token para almacenamiento seguro
    public static String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes());
            StringBuilder hexString = new StringBuilder();
            
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            logger.error("Error al generar hash del token", e);
            throw new RuntimeException("Error al generar hash del token", e);
        }
    }
    
    // Crea token de activación para un usuario (retorna token original para enviar por email)
    public static String crearTokenActivacion(int usuarioId, String ipAddress, String userAgent) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            // Verificar límites de seguridad
            if (!validarLimitesActivacion(usuarioId)) {
                logger.warn("Límite de tokens de activación alcanzado para usuario ID: {}", usuarioId);
                throw new SecurityException("Se ha alcanzado el límite de solicitudes de activación. Por favor, contacte al administrador.");
            }
            
            // Generar token único
            String tokenOriginal = generarToken();
            String tokenHash = hashToken(tokenOriginal);
            
            // Calcular fecha de expiración
            Timestamp fechaExpiracion = Timestamp.valueOf(
                LocalDateTime.now().plusHours(HORAS_EXPIRACION_ACTIVACION)
            );
            
            conn = DatabaseConnection.getConnection();
            
            // Insertar token en base de datos
            String sql = "INSERT INTO tokens_activacion " +
                        "(usuario_id, token, token_original, fecha_expiracion, ip_creacion, user_agent) " +
                        "VALUES (?, ?, ?, ?, ?, ?)";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            pstmt.setString(2, tokenHash);
            pstmt.setString(3, tokenOriginal); // Guardar original para comparación
            pstmt.setTimestamp(4, fechaExpiracion);
            pstmt.setString(5, ipAddress);
            pstmt.setString(6, userAgent);
            
            pstmt.executeUpdate();
            
            // Registrar en auditoría
            registrarAuditoria("ACTIVACION", usuarioId, null, "CREADO", ipAddress, userAgent, 
                             "Token de activación creado");
            
            logger.info("✓ Token de activación creado para usuario ID: {}", usuarioId);
            
            return tokenOriginal; // Retornar token original (sin hash) para enviar por email
            
        } catch (SQLException e) {
            logger.error("Error al crear token de activación", e);
            throw new RuntimeException("Error al crear token de activación", e);
        } finally {
            DatabaseConnection.closeConnection(conn);
            if (pstmt != null) {
                try { pstmt.close(); } catch (SQLException e) { logger.error("Error al cerrar PreparedStatement", e); }
            }
        }
    }
    
    // Valida y usa un token de activación (retorna ID del usuario si es válido, -1 si no)
    public static int validarYUsarTokenActivacion(String token, String ipAddress, String userAgent) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            String tokenHash = hashToken(token);
            
            conn = DatabaseConnection.getConnection();
            
            // Buscar token válido (no usado)
            String sql = "SELECT usuario_id, fecha_expiracion, usado " +
                        "FROM tokens_activacion " +
                        "WHERE token = ? AND usado = FALSE";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, tokenHash);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                // Token no encontrado o ya usado
                registrarAuditoria("ACTIVACION", null, null, "INVALIDO", ipAddress, userAgent, 
                                 "Token no encontrado o ya usado");
                logger.warn("Intento de usar token de activación inválido desde IP: {}", ipAddress);
                return -1;
            }
            
            int usuarioId = rs.getInt("usuario_id");
            Timestamp fechaExpiracion = rs.getTimestamp("fecha_expiracion");
            boolean usado = rs.getBoolean("usado");
            
            // Verificar expiración
            if (fechaExpiracion.before(new Timestamp(System.currentTimeMillis()))) {
                // Marcar como usado para evitar reutilización
                marcarTokenComoUsado("ACTIVACION", tokenHash, ipAddress, userAgent);
                registrarAuditoria("ACTIVACION", usuarioId, null, "EXPIRADO", ipAddress, userAgent, 
                                 "Token expirado");
                logger.warn("Intento de usar token de activación expirado para usuario ID: {}", usuarioId);
                return -1;
            }
            
            // Marcar token como usado
            marcarTokenComoUsado("ACTIVACION", tokenHash, ipAddress, userAgent);
            
            // Activar cuenta del usuario
            activarCuentaUsuario(usuarioId);
            
            // Incrementar intentos de activación
            incrementarIntentosActivacion(usuarioId);
            
            registrarAuditoria("ACTIVACION", usuarioId, null, "USADO", ipAddress, userAgent, 
                             "Token usado exitosamente para activar cuenta");
            
            logger.info("✓ Token de activación usado exitosamente para usuario ID: {}", usuarioId);
            
            return usuarioId;
            
        } catch (SQLException e) {
            logger.error("Error al validar token de activación", e);
            return -1;
        } finally {
            DatabaseConnection.closeConnection(conn);
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { logger.error("Error al cerrar ResultSet", e); }
            }
            if (pstmt != null) {
                try { pstmt.close(); } catch (SQLException e) { logger.error("Error al cerrar PreparedStatement", e); }
            }
        }
    }
    
    /**
     * Crea un token de recuperación de contraseña.
     * 
     * @param email Email del usuario
     * @param ipAddress IP desde donde se solicita
     * @param userAgent User agent del navegador
     * @return Token original (sin hashear) si el email existe, null si no existe
     */
    public static String crearTokenRecuperacion(String email, String ipAddress, String userAgent) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Buscar usuario por email
            String sqlBuscar = "SELECT id_usuario FROM usuarios WHERE email = ?";
            pstmt = conn.prepareStatement(sqlBuscar);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                // Email no existe - pero no lo revelamos por seguridad
                registrarAuditoria("RECUPERACION", null, email, "INVALIDO", ipAddress, userAgent, 
                                 "Email no encontrado (no se revela al usuario)");
                logger.warn("Intento de recuperación para email inexistente: {} desde IP: {}", email, ipAddress);
                return null; // Retornar null pero no revelar que el email no existe
            }
            
            int usuarioId = rs.getInt("id_usuario");
            rs.close();
            pstmt.close();
            
            // Verificar límites de seguridad
            if (!validarLimitesRecuperacion(usuarioId)) {
                logger.warn("Límite de tokens de recuperación alcanzado para usuario ID: {}", usuarioId);
                throw new SecurityException("Se ha alcanzado el límite de solicitudes de recuperación. Por favor, espere antes de intentar nuevamente.");
            }
            
            // Generar token único
            String tokenOriginal = generarToken();
            String tokenHash = hashToken(tokenOriginal);
            
            // Calcular fecha de expiración
            Timestamp fechaExpiracion = Timestamp.valueOf(
                LocalDateTime.now().plusHours(HORAS_EXPIRACION_RECUPERACION)
            );
            
            // Insertar token en base de datos
            String sqlInsert = "INSERT INTO tokens_recuperacion " +
                              "(usuario_id, token, token_original, fecha_expiracion, ip_solicitud, user_agent) " +
                              "VALUES (?, ?, ?, ?, ?, ?)";
            
            pstmt = conn.prepareStatement(sqlInsert);
            pstmt.setInt(1, usuarioId);
            pstmt.setString(2, tokenHash);
            pstmt.setString(3, tokenOriginal);
            pstmt.setTimestamp(4, fechaExpiracion);
            pstmt.setString(5, ipAddress);
            pstmt.setString(6, userAgent);
            
            pstmt.executeUpdate();
            
            // Registrar en auditoría
            registrarAuditoria("RECUPERACION", usuarioId, email, "CREADO", ipAddress, userAgent, 
                             "Token de recuperación creado");
            
            logger.info("✓ Token de recuperación creado para usuario ID: {} (email: {})", usuarioId, email);
            
            return tokenOriginal; // Retornar el token original para enviar por email
            
        } catch (SQLException e) {
            logger.error("Error al crear token de recuperación", e);
            throw new RuntimeException("Error al crear token de recuperación", e);
        } finally {
            DatabaseConnection.closeConnection(conn);
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { logger.error("Error al cerrar ResultSet", e); }
            }
            if (pstmt != null) {
                try { pstmt.close(); } catch (SQLException e) { logger.error("Error al cerrar PreparedStatement", e); }
            }
        }
    }
    
    /**
     * Valida un token de recuperación de contraseña.
     * 
     * @param token Token original (sin hash)
     * @param ipAddress IP desde donde se usa
     * @param userAgent User agent del navegador
     * @return ID del usuario si el token es válido, -1 si no es válido
     */
    public static int validarTokenRecuperacion(String token, String ipAddress, String userAgent) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            String tokenHash = hashToken(token);
            
            conn = DatabaseConnection.getConnection();
            
            // Buscar token válido
            String sql = "SELECT usuario_id, fecha_expiracion, usado, intentos_uso " +
                        "FROM tokens_recuperacion " +
                        "WHERE token = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, tokenHash);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                registrarAuditoria("RECUPERACION", null, null, "INVALIDO", ipAddress, userAgent, 
                                 "Token no encontrado");
                logger.warn("Intento de usar token de recuperación inválido desde IP: {}", ipAddress);
                return -1;
            }
            
            int usuarioId = rs.getInt("usuario_id");
            Timestamp fechaExpiracion = rs.getTimestamp("fecha_expiracion");
            boolean usado = rs.getBoolean("usado");
            int intentosUso = rs.getInt("intentos_uso");
            
            // Verificar si ya fue usado
            if (usado) {
                registrarAuditoria("RECUPERACION", usuarioId, null, "INVALIDO", ipAddress, userAgent, 
                                 "Token ya fue usado anteriormente");
                logger.warn("Intento de reutilizar token de recuperación para usuario ID: {}", usuarioId);
                return -1;
            }
            
            // Verificar expiración
            if (fechaExpiracion.before(new Timestamp(System.currentTimeMillis()))) {
                marcarTokenComoUsado("RECUPERACION", tokenHash, ipAddress, userAgent);
                registrarAuditoria("RECUPERACION", usuarioId, null, "EXPIRADO", ipAddress, userAgent, 
                                 "Token expirado");
                logger.warn("Intento de usar token de recuperación expirado para usuario ID: {}", usuarioId);
                return -1;
            }
            
            // Incrementar intentos de uso (para tracking)
            incrementarIntentosUsoRecuperacion(tokenHash);
            
            registrarAuditoria("RECUPERACION", usuarioId, null, "USADO", ipAddress, userAgent, 
                             "Token validado para cambio de contraseña");
            
            logger.info("✓ Token de recuperación validado para usuario ID: {}", usuarioId);
            
            return usuarioId;
            
        } catch (SQLException e) {
            logger.error("Error al validar token de recuperación", e);
            return -1;
        } finally {
            DatabaseConnection.closeConnection(conn);
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { logger.error("Error al cerrar ResultSet", e); }
            }
            if (pstmt != null) {
                try { pstmt.close(); } catch (SQLException e) { logger.error("Error al cerrar PreparedStatement", e); }
            }
        }
    }
    
    /**
     * Marca un token de recuperación como usado después de cambiar la contraseña.
     */
    public static void marcarTokenRecuperacionComoUsado(String token, String ipAddress, String userAgent) {
        String tokenHash = hashToken(token);
        marcarTokenComoUsado("RECUPERACION", tokenHash, ipAddress, userAgent);
    }
    
    // ========== MÉTODOS PRIVADOS ==========
    
    private static boolean validarLimitesActivacion(int usuarioId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Contar tokens pendientes (no usados y no expirados)
            String sql = "SELECT COUNT(*) as total " +
                        "FROM tokens_activacion " +
                        "WHERE usuario_id = ? AND usado = FALSE AND fecha_expiracion > NOW()";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                int total = rs.getInt("total");
                return total < MAX_TOKENS_PENDIENTES;
            }
            
            return true;
            
        } catch (SQLException e) {
            logger.error("Error al validar límites de activación", e);
            return false;
        } finally {
            DatabaseConnection.closeConnection(conn);
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) {}
            }
            if (pstmt != null) {
                try { pstmt.close(); } catch (SQLException e) {}
            }
        }
    }
    
    private static boolean validarLimitesRecuperacion(int usuarioId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Contar tokens pendientes en las últimas 24 horas
            String sql = "SELECT COUNT(*) as total " +
                        "FROM tokens_recuperacion " +
                        "WHERE usuario_id = ? AND usado = FALSE AND fecha_expiracion > NOW() " +
                        "AND fecha_creacion > DATE_SUB(NOW(), INTERVAL 24 HOUR)";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                int total = rs.getInt("total");
                return total < MAX_TOKENS_PENDIENTES;
            }
            
            return true;
            
        } catch (SQLException e) {
            logger.error("Error al validar límites de recuperación", e);
            return false;
        } finally {
            DatabaseConnection.closeConnection(conn);
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) {}
            }
            if (pstmt != null) {
                try { pstmt.close(); } catch (SQLException e) {}
            }
        }
    }
    
    private static void marcarTokenComoUsado(String tipo, String tokenHash, String ipAddress, String userAgent) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            String tabla = tipo.equals("ACTIVACION") ? "tokens_activacion" : "tokens_recuperacion";
            String campoIp = tipo.equals("ACTIVACION") ? "" : ", ip_uso = ?";
            
            String sql = "UPDATE " + tabla + " " +
                        "SET usado = TRUE, fecha_uso = NOW()" + campoIp + " " +
                        "WHERE token = ?";
            
            pstmt = conn.prepareStatement(sql);
            if (tipo.equals("RECUPERACION")) {
                pstmt.setString(1, ipAddress);
                pstmt.setString(2, tokenHash);
            } else {
                pstmt.setString(1, tokenHash);
            }
            
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            logger.error("Error al marcar token como usado", e);
        } finally {
            DatabaseConnection.closeConnection(conn);
            if (pstmt != null) {
                try { pstmt.close(); } catch (SQLException e) {}
            }
        }
    }
    
    private static void activarCuentaUsuario(int usuarioId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            String sql = "UPDATE usuarios " +
                        "SET cuenta_activada = TRUE, fecha_activacion = NOW() " +
                        "WHERE id_usuario = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            pstmt.executeUpdate();
            
            logger.info("✓ Cuenta activada para usuario ID: {}", usuarioId);
            
        } catch (SQLException e) {
            logger.error("Error al activar cuenta de usuario", e);
            throw new RuntimeException("Error al activar cuenta", e);
        } finally {
            DatabaseConnection.closeConnection(conn);
            if (pstmt != null) {
                try { pstmt.close(); } catch (SQLException e) {}
            }
        }
    }
    
    private static void incrementarIntentosActivacion(int usuarioId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            String sql = "UPDATE usuarios " +
                        "SET intentos_activacion = intentos_activacion + 1, " +
                        "ultimo_intento_activacion = NOW() " +
                        "WHERE id_usuario = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            logger.error("Error al incrementar intentos de activación", e);
        } finally {
            DatabaseConnection.closeConnection(conn);
            if (pstmt != null) {
                try { pstmt.close(); } catch (SQLException e) {}
            }
        }
    }
    
    private static void incrementarIntentosUsoRecuperacion(String tokenHash) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            String sql = "UPDATE tokens_recuperacion " +
                        "SET intentos_uso = intentos_uso + 1 " +
                        "WHERE token = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, tokenHash);
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            logger.error("Error al incrementar intentos de uso de recuperación", e);
        } finally {
            DatabaseConnection.closeConnection(conn);
            if (pstmt != null) {
                try { pstmt.close(); } catch (SQLException e) {}
            }
        }
    }
    
    private static void registrarAuditoria(String tipoToken, Integer usuarioId, String email, 
                                          String accion, String ipAddress, String userAgent, String detalles) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            String sql = "INSERT INTO auditoria_tokens " +
                        "(tipo_token, usuario_id, email_solicitado, accion, ip_address, user_agent, detalles) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?)";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, tipoToken);
            if (usuarioId != null) {
                pstmt.setInt(2, usuarioId);
            } else {
                pstmt.setNull(2, Types.INTEGER);
            }
            pstmt.setString(3, email);
            pstmt.setString(4, accion);
            pstmt.setString(5, ipAddress);
            pstmt.setString(6, userAgent);
            pstmt.setString(7, detalles);
            
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            logger.error("Error al registrar auditoría de token", e);
            // No lanzar excepción para no interrumpir el flujo principal
        } finally {
            DatabaseConnection.closeConnection(conn);
            if (pstmt != null) {
                try { pstmt.close(); } catch (SQLException e) {}
            }
        }
    }
}

