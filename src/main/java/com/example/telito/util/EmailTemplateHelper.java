package com.example.telito.util;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

/**
 * Clase helper para generar plantillas de correo HTML.
 * Extrae la construcción de mensajes HTML del código del servlet.
 */
public class EmailTemplateHelper {

    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    /**
     * Genera el mensaje HTML de bienvenida para nuevos usuarios.
     * 
     * @param nombres Nombre del usuario
     * @param apellidos Apellidos del usuario
     * @param email Email del usuario
     * @param passwordContraseña temporal
     * @param nombreRol Nombre del rol asignado
     * @param contextPath Context path de la aplicación
     * @return Mensaje HTML formateado
     */
    public static String generarMensajeBienvenida(String nombres, String apellidos, String email, 
                                                   String password, String nombreRol, String contextPath) {
        return """
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #2b2d42; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: linear-gradient(160deg, #006d77 0%%, #055e68 100%%); 
                             color: white; padding: 25px; border-radius: 8px 8px 0 0; text-align: center; }
                    .content { background: #edf6f9; padding: 25px; border-radius: 0 0 8px 8px; }
                    .credentials { background: white; padding: 20px; border-radius: 5px; 
                                 margin: 15px 0; border-left: 4px solid #006d77; }
                    .credential-item { padding: 12px 0; border-bottom: 1px solid #e9ecef; }
                    .credential-item:last-child { border-bottom: none; }
                    .label { font-weight: 600; color: #00a896; }
                    .value { color: #2b2d42; font-family: monospace; }
                    .warning { background: #fff3cd; padding: 15px; border-radius: 5px; 
                              border-left: 4px solid #ffc107; margin: 15px 0; }
                    .footer { margin-top: 20px; padding-top: 15px; border-top: 1px solid #e9ecef; 
                             font-size: 12px; color: #6c757d; text-align: center; }
                    .button { display: inline-block; padding: 16px 40px; background: linear-gradient(135deg, #00a896 0%%, #028f80 100%%); 
                            color: #ffffff; text-decoration: none; border-radius: 10px; 
                            margin: 20px 0; transition: all 0.3s; border: none; 
                            font-weight: 600; box-shadow: 0 6px 20px rgba(0,168,150,0.4); }
                    .button:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(0,168,150,0.5); }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h2>¡Bienvenido a TELITO BODEGUERO!</h2>
                    </div>
                    <div class="content">
                        <p>Estimado/a <strong>%s %s</strong>,</p>
                        <p>Nos complace informarte que tu cuenta ha sido creada exitosamente en el sistema <strong>TELITO BODEGUERO</strong>.</p>
                        
                        <div class="credentials">
                            <h3 style="margin-top: 0; color: #006d77;">📋 Credenciales de Acceso</h3>
                            <div class="credential-item">
                                <span class="label">Email:</span> <span class="value">%s</span>
                            </div>
                            <div class="credential-item">
                                <span class="label">Contraseña temporal:</span> <span class="value">%s</span>
                            </div>
                            <div class="credential-item">
                                <span class="label">Rol asignado:</span> <span class="value">%s</span>
                            </div>
                        </div>
                        
                        <div class="warning">
                            <strong>⚠️ Importante:</strong>
                            <ul style="margin: 10px 0;">
                                <li>Por seguridad, cambia tu contraseña al iniciar sesión por primera vez</li>
                                <li>Guarda estas credenciales en un lugar seguro</li>
                                <li>Si no solicitaste esta cuenta, contacta al administrador inmediatamente</li>
                            </ul>
                        </div>
                        
                        <p><strong>Próximos pasos:</strong></p>
                        <ol>
                            <li>Accede al sistema usando las credenciales proporcionadas</li>
                            <li>Cambia tu contraseña temporal por una contraseña segura</li>
                            <li>Revisa tu perfil y completa tu información</li>
                        </ol>
                        
                        <p style="text-align: center;">
                            <a href="%s" class="button">Iniciar Sesión</a>
                        </p>
                        
                        <div class="footer">
                            <p>Este es un correo automático generado por el sistema TELITO BODEGUERO.</p>
                            <p>Fecha de creación: %s</p>
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(nombres, apellidos, email, password, nombreRol, 
                          EmailUtil.buildApplicationUrl("/acceso/login", contextPath != null ? contextPath : ""), 
                          DATE_FORMAT.format(new Date()));
    }

    /**
     * Genera el mensaje HTML de confirmación de actualización de perfil.
     * 
     * @param nombres Nombre del usuario
     * @param apellidos Apellidos del usuario
     * @param cambios Lista de cambios realizados
     * @param passwordCambiada Indica si la contraseña fue cambiada
     * @param email Email actualizado
     * @param nombreRol Rol actualizado
     * @param activo Estado actualizado
     * @return Mensaje HTML formateado
     */
    public static String generarMensajeActualizacion(String nombres, String apellidos, ArrayList<String> cambios,
                                                     boolean passwordCambiada, String email, String nombreRol, 
                                                     boolean activo) {
        StringBuilder cambiosLista = new StringBuilder();
        for (String cambio : cambios) {
            cambiosLista.append("<li>").append(cambio).append("</li>");
        }

        String warningPassword = passwordCambiada ? 
            "<ul><li>Si solicitaste el cambio de contraseña, ya puedes iniciar sesión con la nueva contraseña</li>" +
            "<li>Si NO solicitaste este cambio, contacta al administrador inmediatamente</li></ul>" :
            "<p>No se realizaron cambios en tu contraseña.</p>";

        return """
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #2b2d42; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: linear-gradient(160deg, #006d77 0%%, #055e68 100%%); 
                             color: white; padding: 25px; border-radius: 8px 8px 0 0; text-align: center; }
                    .content { background: #edf6f9; padding: 25px; border-radius: 0 0 8px 8px; }
                    .changes { background: white; padding: 20px; border-radius: 8px; 
                             margin: 15px 0; border-left: 4px solid #00a896; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
                    .warning { background: #fff3cd; padding: 15px; border-radius: 5px; 
                              border-left: 4px solid #ffc107; margin: 15px 0; }
                    .footer { margin-top: 20px; padding-top: 15px; border-top: 1px solid #e9ecef; 
                             font-size: 12px; color: #6c757d; text-align: center; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h2>✅ Perfil Actualizado</h2>
                    </div>
                    <div class="content">
                        <p>Estimado/a <strong>%s %s</strong>,</p>
                        <p>Tu perfil de usuario ha sido actualizado exitosamente en el sistema <strong>TELITO BODEGUERO</strong>.</p>
                        
                        <div class="changes">
                            <h3 style="margin-top: 0; color: #006d77;">📝 Cambios Realizados</h3>
                            <ul>
                                %s
                            </ul>
                        </div>
                        
                        <div class="warning">
                            <strong>⚠️ Importante:</strong>
                            %s
                        </div>
                        
                        <p><strong>Información actualizada:</strong></p>
                        <ul>
                            <li><strong>Email:</strong> %s</li>
                            <li><strong>Rol:</strong> %s</li>
                            <li><strong>Estado:</strong> %s</li>
                        </ul>
                        
                        <p>Si no realizaste estos cambios, contacta al administrador inmediatamente.</p>
                        
                        <div class="footer">
                            <p>Este es un correo automático generado por el sistema TELITO BODEGUERO.</p>
                            <p>Fecha de actualización: %s</p>
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(nombres, apellidos, cambiosLista.toString(), warningPassword, email, nombreRol,
                          activo ? "Activo" : "Inactivo", DATE_FORMAT.format(new Date()));
    }
}

