package com.example.telito.administrador.services;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.beans.Rol;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.util.EmailTemplateHelper;
import com.example.telito.util.EmailUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;

/**
 * Servicio para manejar la lógica de negocio relacionada con usuarios.
 * Extrae la lógica del servlet para mejorar la separación de responsabilidades.
 */
public class UsuarioService {

    private static final Logger logger = LoggerFactory.getLogger(UsuarioService.class);
    private final UsuarioDAO usuarioDAO;

    public UsuarioService() {
        this.usuarioDAO = new UsuarioDAO();
    }

    /**
     * Crea un nuevo usuario o reactiva uno inactivo si existe.
     * 
     * @param usuarioNuevo Usuario a crear
     * @param passwordOriginal Contraseña original antes de encriptar
     * @param contextPath Context path de la aplicación para los emails
     * @return Resultado de la operación con el usuario creado/reactivado
     */
    public ResultadoCreacionUsuario crearOReactivarUsuario(Usuario usuarioNuevo, String passwordOriginal, String contextPath) {
        String email = usuarioNuevo.getEmail();
        boolean creado = false;
        Usuario usuarioFinal = null;

        try {
            // Verificar si existe un usuario inactivo con ese email para reactivarlo
            int idUsuarioInactivo = usuarioDAO.obtenerIdUsuarioPorEmail(email);
            
            if (idUsuarioInactivo > 0) {
                logger.info("Usuario inactivo encontrado con ese email (ID: {}). Reactivando...", idUsuarioInactivo);
                Usuario usuarioExistente = usuarioDAO.obtenerUsuarioPorId(idUsuarioInactivo);
                
                if (usuarioExistente != null && !usuarioExistente.isActivo()) {
                    // Asegurar que el email esté asignado correctamente
                    if (usuarioExistente.getEmail() == null || usuarioExistente.getEmail().trim().isEmpty()) {
                        usuarioExistente.setEmail(email);
                    }
                    
                    // Actualizar datos del usuario existente
                    usuarioExistente.setNombres(usuarioNuevo.getNombres());
                    usuarioExistente.setApellidos(usuarioNuevo.getApellidos());
                    usuarioExistente.setPassword(usuarioNuevo.getPassword());
                    usuarioExistente.setRol(usuarioNuevo.getRol());
                    usuarioExistente.setActivo(true); // Reactivar
                    
                    creado = usuarioDAO.actualizarUsuarioConPassword(usuarioExistente);
                    
                    if (creado) {
                        logger.info("Usuario reactivado exitosamente. Email: {}", usuarioExistente.getEmail());
                        usuarioFinal = usuarioExistente;
                    } else {
                        logger.error("ERROR: No se pudo reactivar el usuario");
                    }
                }
            } else {
                logger.info("Creando nuevo usuario con email: {}", email);
            }
            
            if (!creado) {
                // No existe usuario inactivo, crear uno nuevo
                creado = usuarioDAO.crearUsuario(usuarioNuevo);
                if (creado) {
                    usuarioFinal = usuarioNuevo;
                }
            }
            
            if (creado && usuarioFinal != null) {
                // Enviar correo de bienvenida
                enviarCorreoBienvenida(usuarioFinal, passwordOriginal, contextPath);
                return new ResultadoCreacionUsuario(true, usuarioFinal, null);
            } else {
                String error = "Error al guardar el usuario en la base de datos";
                logger.error(error);
                return new ResultadoCreacionUsuario(false, null, error);
            }
            
        } catch (Exception e) {
            logger.error("Error inesperado al crear el usuario: {}", e.getMessage(), e);
            return new ResultadoCreacionUsuario(false, null, 
                "Error inesperado al crear el usuario. Por favor, contacte al administrador.");
        }
    }

    /**
     * Envía correo de bienvenida al nuevo usuario.
     * 
     * @param usuario Usuario al que se envía el correo
     * @param passwordOriginal Contraseña original antes de encriptar
     * @param contextPath Context path de la aplicación
     */
    private void enviarCorreoBienvenida(Usuario usuario, String passwordOriginal, String contextPath) {
        try {
            String emailDestino = usuario.getEmail();
            if (emailDestino == null || emailDestino.trim().isEmpty()) {
                logger.warn("El usuario no tiene un email válido para enviar correo");
                return;
            }
            
            logger.info("Preparando envío de correo de bienvenida a: {}", emailDestino);
            
            String nombreRol = usuarioDAO.obtenerNombreRolPorId(usuario.getRol().getIdRol());
            nombreRol = (nombreRol != null) ? nombreRol : "Usuario";
            
            String mensaje = EmailTemplateHelper.generarMensajeBienvenida(
                usuario.getNombres(),
                usuario.getApellidos(),
                usuario.getEmail(),
                passwordOriginal,
                nombreRol,
                contextPath != null ? contextPath : ""
            );
            
            boolean correoEnviado = EmailUtil.sendSystemAlertHTML(
                emailDestino,
                "Bienvenido a TELITO BODEGUERO - Credenciales de Acceso",
                mensaje
            );
            
            if (correoEnviado) {
                logger.info("Correo de bienvenida enviado exitosamente a: {}", emailDestino);
            } else {
                logger.warn("No se pudo enviar el correo de bienvenida a: {}. Verifica la configuración de email", emailDestino);
            }
        } catch (Exception e) {
            // No bloquear la creación si falla el correo
            logger.error("Error al enviar correo de bienvenida: {}", e.getMessage(), e);
        }
    }

    /**
     * Actualiza un usuario y envía correo de confirmación si hay cambios.
     * 
     * @param usuarioActualizado Usuario con datos actualizados
     * @param passwordNueva Nueva contraseña (puede ser null si no se cambió)
     * @param contextPath Context path de la aplicación para los emails
     * @return true si la actualización fue exitosa
     */
    public boolean actualizarUsuario(Usuario usuarioActualizado, String passwordNueva, String contextPath) {
        try {
            // Obtener datos anteriores para comparar cambios
            Usuario usuarioAnterior = usuarioDAO.obtenerUsuarioPorId(usuarioActualizado.getIdUsuario());
            boolean passwordCambiada = passwordNueva != null && !passwordNueva.trim().isEmpty();
            
            usuarioDAO.actualizarUsuario(usuarioActualizado);
            
            // Enviar correo de confirmación si hay cambios
            if (usuarioAnterior != null) {
                enviarCorreoConfirmacionActualizacion(usuarioAnterior, usuarioActualizado, passwordCambiada, contextPath);
            }
            
            logger.info("Usuario actualizado exitosamente. ID: {}", usuarioActualizado.getIdUsuario());
            return true;
        } catch (Exception e) {
            logger.error("Error al actualizar usuario: {}", e.getMessage(), e);
            return false;
        }
    }

    /**
     * Envía correo de confirmación cuando se actualiza un usuario.
     * 
     * @param usuarioAnterior Usuario antes de la actualización
     * @param usuarioActualizado Usuario después de la actualización
     * @param passwordCambiada Indica si la contraseña fue cambiada
     * @param contextPath Context path de la aplicación
     */
    private void enviarCorreoConfirmacionActualizacion(Usuario usuarioAnterior, Usuario usuarioActualizado,
                                                      boolean passwordCambiada, String contextPath) {
        try {
            String nombreRol = usuarioDAO.obtenerNombreRolPorId(usuarioActualizado.getRol().getIdRol());
            nombreRol = (nombreRol != null) ? nombreRol : "Usuario";
            
            // Detectar qué cambió
            ArrayList<String> cambios = detectarCambios(usuarioAnterior, usuarioActualizado, passwordCambiada);
            
            if (!cambios.isEmpty()) {
                String mensaje = EmailTemplateHelper.generarMensajeActualizacion(
                    usuarioActualizado.getNombres(),
                    usuarioActualizado.getApellidos(),
                    cambios,
                    passwordCambiada,
                    usuarioActualizado.getEmail(),
                    nombreRol,
                    usuarioActualizado.isActivo()
                );
                
                // Determinar email de destino (si cambió el email, usar el anterior para enviar la notificación)
                String emailDestino = !usuarioAnterior.getEmail().equals(usuarioActualizado.getEmail()) ? 
                    usuarioAnterior.getEmail() : usuarioActualizado.getEmail();
                
                boolean correoEnviado = EmailUtil.sendSystemAlertHTML(
                    emailDestino,
                    "Perfil Actualizado - TELITO BODEGUERO",
                    mensaje
                );
                
                if (correoEnviado) {
                    logger.info("Correo de confirmación de actualización enviado a: {}", emailDestino);
                } else {
                    logger.warn("No se pudo enviar el correo de confirmación de actualización");
                }
            }
        } catch (Exception e) {
            // No bloquear la actualización si falla el correo
            logger.error("Error al enviar correo de confirmación de actualización: {}", e.getMessage(), e);
        }
    }

    /**
     * Detecta qué campos del usuario fueron modificados.
     * 
     * @param usuarioAnterior Usuario antes de la actualización
     * @param usuarioActualizado Usuario después de la actualización
     * @param passwordCambiada Indica si la contraseña fue cambiada
     * @return Lista de cambios detectados
     */
    private ArrayList<String> detectarCambios(Usuario usuarioAnterior, Usuario usuarioActualizado, 
                                             boolean passwordCambiada) {
        ArrayList<String> cambios = new ArrayList<>();
        
        if (!usuarioAnterior.getNombres().equals(usuarioActualizado.getNombres()) || 
            !usuarioAnterior.getApellidos().equals(usuarioActualizado.getApellidos())) {
            cambios.add("Nombre y/o apellidos");
        }
        if (!usuarioAnterior.getEmail().equals(usuarioActualizado.getEmail())) {
            cambios.add("Email: " + usuarioAnterior.getEmail() + " → " + usuarioActualizado.getEmail());
        }
        if (usuarioAnterior.getRol().getIdRol() != usuarioActualizado.getRol().getIdRol()) {
            String nombreRolAnterior = usuarioDAO.obtenerNombreRolPorId(usuarioAnterior.getRol().getIdRol());
            String nombreRolNuevo = usuarioDAO.obtenerNombreRolPorId(usuarioActualizado.getRol().getIdRol());
            cambios.add("Rol: " + nombreRolAnterior + " → " + nombreRolNuevo);
        }
        if (usuarioAnterior.isActivo() != usuarioActualizado.isActivo()) {
            cambios.add("Estado: " + (usuarioAnterior.isActivo() ? "Activo" : "Inactivo") + " → " + 
                      (usuarioActualizado.isActivo() ? "Activo" : "Inactivo"));
        }
        if (passwordCambiada) {
            cambios.add("Contraseña (se cambió tu contraseña)");
        }
        
        return cambios;
    }

    /**
     * Clase interna para representar el resultado de la creación de usuario.
     */
    public static class ResultadoCreacionUsuario {
        private final boolean exito;
        private final Usuario usuario;
        private final String error;

        public ResultadoCreacionUsuario(boolean exito, Usuario usuario, String error) {
            this.exito = exito;
            this.usuario = usuario;
            this.error = error;
        }

        public boolean isExito() {
            return exito;
        }

        public Usuario getUsuario() {
            return usuario;
        }

        public String getError() {
            return error;
        }
    }
}

