package com.example.telito.administrador.services;

import com.example.telito.administrador.beans.AuditoriaLog;
import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.AuditoriaDAO;
import com.example.telito.administrador.daos.ConfiguracionSistemaDAO;
import jakarta.servlet.http.HttpServletRequest;

// Servicio para registrar acciones en el log de auditoría
public class AuditoriaService {
    
    private static final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();
    private static final ConfiguracionSistemaDAO configDAO = new ConfiguracionSistemaDAO();
    
    // Verifica si la auditoría está habilitada en la configuración
    private static boolean isAuditoriaHabilitada() {
        return configDAO.obtenerValorBoolean("sistema.auditoria.enabled", true);
    }
    
    // Registra una acción exitosa básica
    public static void registrarAccion(Usuario usuario, String accion, String modulo, 
                                      String descripcion, HttpServletRequest request) {
        registrarAccionInterno(usuario, accion, modulo, descripcion, null, null, "EXITOSO", null, request);
    }
    
    // Registra una acción con datos anteriores y nuevos (para actualizaciones)
    public static void registrarAccion(Usuario usuario, String accion, String modulo, 
                                      String descripcion, String datosAnteriores, 
                                      String datosNuevos, HttpServletRequest request) {
        registrarAccionInterno(usuario, accion, modulo, descripcion, datosAnteriores, datosNuevos, "EXITOSO", null, request);
    }
    
    // Registra una acción fallida
    public static void registrarAccionFallida(Usuario usuario, String accion, String modulo, 
                                             String descripcion, String mensajeError, 
                                             HttpServletRequest request) {
        registrarAccionInterno(usuario, accion, modulo, descripcion, null, null, "FALLIDO", mensajeError, request);
    }
    
    // Método completo con todos los parámetros
    public static void registrarAccion(Usuario usuario, String accion, String modulo, 
                                      String descripcion, String datosAnteriores, 
                                      String datosNuevos, String estado, String mensajeError,
                                      HttpServletRequest request) {
        registrarAccionInterno(usuario, accion, modulo, descripcion, datosAnteriores, datosNuevos, estado, mensajeError, request);
    }
    
    // Método interno que hace el registro real
    private static void registrarAccionInterno(Usuario usuario, String accion, String modulo, 
                                       String descripcion, String datosAnteriores, 
                                       String datosNuevos, String estado, String mensajeError,
                                       HttpServletRequest request) {
        
        // Si la auditoría está deshabilitada, no registrar nada
        if (!isAuditoriaHabilitada()) {
            return;
        }
        
        try {
            AuditoriaLog log = new AuditoriaLog();
            
            if (usuario != null) {
                log.setUsuarioId(usuario.getIdUsuario());
                log.setUsuarioNombre(usuario.getNombres() + " " + usuario.getApellidos());
            } else {
                // Para acciones sin usuario autenticado (ej: login fallido)
                // usuario_id será NULL en la base de datos
                log.setUsuarioId(null); // Cambiado de 0 a null
                log.setUsuarioNombre("Usuario no autenticado");
            }
            
            log.setAccion(accion);
            log.setModulo(modulo);
            log.setDescripcion(descripcion);
            log.setDatosAnteriores(datosAnteriores);
            log.setDatosNuevos(datosNuevos);
            log.setEstado(estado);
            log.setMensajeError(mensajeError);
            
            if (request != null) {
                log.setIpAddress(obtenerIpAddress(request));
                String userAgent = request.getHeader("User-Agent");
                if (userAgent != null && userAgent.length() > 500) {
                    userAgent = userAgent.substring(0, 500);
                }
                log.setUserAgent(userAgent);
            }
            
            auditoriaDAO.registrarAccion(log);
            
        } catch (Exception e) {
            // No lanzar excepción para no interrumpir el flujo principal
            System.err.println("Error al registrar acción de auditoría: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Obtiene la dirección IP del cliente.
     */
    private static String obtenerIpAddress(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }
    
    // Constantes para acciones comunes
    public static final String ACCION_CREAR_USUARIO = "CREAR_USUARIO";
    public static final String ACCION_EDITAR_USUARIO = "EDITAR_USUARIO";
    public static final String ACCION_ELIMINAR_USUARIO = "ELIMINAR_USUARIO";
    public static final String ACCION_BANEAR_USUARIO = "BANEAR_USUARIO";
    public static final String ACCION_DESBANEAR_USUARIO = "DESBANEAR_USUARIO";
    public static final String ACCION_CREAR_PRODUCTO = "CREAR_PRODUCTO";
    public static final String ACCION_EDITAR_PRODUCTO = "EDITAR_PRODUCTO";
    public static final String ACCION_ELIMINAR_PRODUCTO = "ELIMINAR_PRODUCTO";
    public static final String ACCION_LOGIN = "LOGIN";
    public static final String ACCION_LOGOUT = "LOGOUT";
    public static final String ACCION_CAMBIAR_PASSWORD = "CAMBIAR_PASSWORD";
    public static final String ACCION_ACTUALIZAR_CONFIGURACION = "ACTUALIZAR_CONFIGURACION";
    public static final String ACCION_ENVIAR_CORREO = "ENVIAR_CORREO";
    public static final String ACCION_GENERAR_REPORTE = "GENERAR_REPORTE";
    
    // Constantes para módulos
    public static final String MODULO_USUARIOS = "USUARIOS";
    public static final String MODULO_PRODUCTOS = "PRODUCTOS";
    public static final String MODULO_INVENTARIO = "INVENTARIO";
    public static final String MODULO_ALMACEN = "ALMACEN";
    public static final String MODULO_LOGISTICA = "LOGISTICA";
    public static final String MODULO_PRODUCTOR = "PRODUCTOR";
    public static final String MODULO_SISTEMA = "SISTEMA";
    public static final String MODULO_SEGURIDAD = "SEGURIDAD";
    public static final String MODULO_REPORTES = "REPORTES";
}

