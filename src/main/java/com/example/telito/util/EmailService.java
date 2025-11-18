package com.example.telito.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

/**
 * Servicio mejorado para el envío de correos electrónicos.
 * 
 * MEJORAS SOBRE TELITO_RRHH:
 * - Templates HTML más profesionales y modernos
 * - Diseño responsive
 * - Mejor organización del código
 * - Soporte para múltiples tipos de email
 * - Logging detallado
 * - Manejo de errores mejorado
 * 
 * @author Telito Bodeguero
 * @version 2.0
 */
public class EmailService {
    
    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);
    
    // Configuración SMTP (se carga desde email.properties)
    private static String SMTP_HOST = "smtp.gmail.com";
    private static String SMTP_PORT = "587";
    private static String EMAIL_FROM = "";
    private static String EMAIL_PASSWORD = "";
    private static String APPLICATION_NAME = "Telito Bodeguero";
    private static String APPLICATION_BASE_URL = "http://localhost:8080/TELITO_BODEGUERO_war_exploded";
    
    // Cargar configuración al inicializar
    static {
        loadEmailConfig();
    }
    
    /**
     * Carga la configuración de email desde email.properties.
     */
    private static void loadEmailConfig() {
        try {
            java.io.InputStream input = EmailService.class.getClassLoader()
                    .getResourceAsStream("email.properties");
            if (input != null) {
                java.util.Properties props = new java.util.Properties();
                props.load(input);
                SMTP_HOST = props.getProperty("smtp.host", SMTP_HOST);
                SMTP_PORT = props.getProperty("smtp.port", SMTP_PORT);
                EMAIL_FROM = props.getProperty("email.from", "");
                EMAIL_PASSWORD = props.getProperty("email.password", "");
                APPLICATION_NAME = props.getProperty("application.name", APPLICATION_NAME);
                APPLICATION_BASE_URL = props.getProperty("application.base.url", APPLICATION_BASE_URL);
                logger.info("✓ Configuración de email cargada desde email.properties");
            } else {
                logger.warn("⚠ Archivo email.properties no encontrado. Usando valores por defecto.");
            }
        } catch (Exception e) {
            logger.error("Error al cargar configuración de email", e);
        }
    }
    
    /**
     * Envía un correo de activación de cuenta.
     * 
     * @param destinatario Email del destinatario
     * @param nombreUsuario Nombre del usuario
     * @param tokenActivacion Token de activación
     * @param contextPath Context path de la aplicación
     * @return true si se envió correctamente
     */
    public static boolean enviarCorreoActivacion(String destinatario, String nombreUsuario, 
                                                 String tokenActivacion, String contextPath) {
        // Usar APPLICATION_BASE_URL del archivo de propiedades (siempre se carga)
        String baseUrl = APPLICATION_BASE_URL;
        
        // Si contextPath ya incluye protocolo y dominio completo, usarlo directamente
        if (contextPath != null && !contextPath.trim().isEmpty() && 
            (contextPath.startsWith("http://") || contextPath.startsWith("https://"))) {
            baseUrl = contextPath;
        }
        
        // Asegurar que baseUrl no termine con /
        if (baseUrl.endsWith("/")) {
            baseUrl = baseUrl.substring(0, baseUrl.length() - 1);
        }
        
        String linkActivacion = baseUrl + "/acceso/activar?token=" + tokenActivacion;
        String asunto = "Activa tu cuenta en " + APPLICATION_NAME;
        
        String htmlContent = generarTemplateActivacion(nombreUsuario, linkActivacion, tokenActivacion);
        
        return enviarCorreo(destinatario, asunto, htmlContent);
    }
    
    /**
     * Envía un correo de recuperación de contraseña.
     * 
     * @param destinatario Email del destinatario
     * @param nombreUsuario Nombre del usuario
     * @param tokenRecuperacion Token de recuperación
     * @param contextPath Context path de la aplicación
     * @return true si se envió correctamente
     */
    public static boolean enviarCorreoRecuperacion(String destinatario, String nombreUsuario, 
                                                   String tokenRecuperacion, String contextPath) {
        // Usar APPLICATION_BASE_URL del archivo de propiedades (siempre se carga)
        String baseUrl = APPLICATION_BASE_URL;
        
        // Si contextPath ya incluye protocolo y dominio completo, usarlo directamente
        if (contextPath != null && !contextPath.trim().isEmpty() && 
            (contextPath.startsWith("http://") || contextPath.startsWith("https://"))) {
            baseUrl = contextPath;
        }
        
        // Asegurar que baseUrl no termine con /
        if (baseUrl.endsWith("/")) {
            baseUrl = baseUrl.substring(0, baseUrl.length() - 1);
        }
        
        String linkRecuperacion = baseUrl + "/acceso/recuperar?token=" + tokenRecuperacion;
        String asunto = "Recuperación de contraseña - " + APPLICATION_NAME;
        
        String htmlContent = generarTemplateRecuperacion(nombreUsuario, linkRecuperacion, tokenRecuperacion);
        
        return enviarCorreo(destinatario, asunto, htmlContent);
    }
    
    /**
     * Envía un correo genérico.
     * 
     * @param destinatario Email del destinatario
     * @param asunto Asunto del correo
     * @param contenidoHTML Contenido HTML del correo
     * @return true si se envió correctamente
     */
    public static boolean enviarCorreo(String destinatario, String asunto, String contenidoHTML) {
        if (EMAIL_FROM == null || EMAIL_FROM.isEmpty() || 
            EMAIL_PASSWORD == null || EMAIL_PASSWORD.isEmpty()) {
            logger.error("✗ Credenciales de email no configuradas");
            return false;
        }
        
        if (destinatario == null || destinatario.trim().isEmpty()) {
            logger.warn("⚠ Dirección de correo destinatario vacía");
            return false;
        }
        
        try {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.ssl.trust", SMTP_HOST);
            props.put("mail.smtp.ssl.protocols", "TLSv1.2");
            
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_FROM, EMAIL_PASSWORD);
                }
            });
            
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(EMAIL_FROM, APPLICATION_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
            message.setSubject(asunto);
            message.setContent(contenidoHTML, "text/html; charset=utf-8");
            
            Transport.send(message);
            
            logger.info("✓ Correo enviado exitosamente a: {}", destinatario);
            return true;
            
        } catch (Exception e) {
            logger.error("✗ Error al enviar correo a {}: {}", destinatario, e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * Genera el template HTML para activación de cuenta.
     */
    private static String generarTemplateActivacion(String nombreUsuario, String linkActivacion, String tokenBackup) {
        return "<!DOCTYPE html>" +
               "<html lang='es'>" +
               "<head>" +
               "    <meta charset='UTF-8'>" +
               "    <meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
               "    <title>Activa tu cuenta</title>" +
               "</head>" +
               "<body style='margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif; background-color: #f4f4f4;'>" +
               "    <table role='presentation' style='width: 100%; border-collapse: collapse;'>" +
               "        <tr>" +
               "            <td style='padding: 40px 20px;'>" +
               "                <table role='presentation' style='max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); overflow: hidden;'>" +
               "                    <!-- Header con gradiente -->" +
               "                    <tr>" +
               "                        <td style='background: linear-gradient(135deg, #006d77 0%, #83c5be 100%); padding: 40px 30px; text-align: center;'>" +
               "                            <h1 style='margin: 0; color: #ffffff; font-size: 28px; font-weight: 600;'>" +
               "                                🎉 ¡Bienvenido a " + APPLICATION_NAME + "!" +
               "                            </h1>" +
               "                        </td>" +
               "                    </tr>" +
               "                    <!-- Contenido principal -->" +
               "                    <tr>" +
               "                        <td style='padding: 40px 30px;'>" +
               "                            <h2 style='margin: 0 0 20px 0; color: #2b2d42; font-size: 24px; font-weight: 600;'>" +
               "                                Hola " + nombreUsuario + "," +
               "                            </h2>" +
               "                            <p style='margin: 0 0 20px 0; color: #555555; font-size: 16px; line-height: 1.6;'>" +
               "                                Gracias por registrarte en <strong>" + APPLICATION_NAME + "</strong>. " +
               "                                Estás a un paso de comenzar a gestionar tu bodega de manera eficiente." +
               "                            </p>" +
               "                            <p style='margin: 0 0 30px 0; color: #555555; font-size: 16px; line-height: 1.6;'>" +
               "                                Para completar tu registro y activar tu cuenta, haz clic en el siguiente botón:" +
               "                            </p>" +
               "                            <!-- Botón de activación -->" +
               "                            <table role='presentation' style='width: 100%; margin: 30px 0;'>" +
               "                                <tr>" +
               "                                    <td style='text-align: center;'>" +
               "                                        <a href='" + linkActivacion + "' " +
               "                                           style='display: inline-block; padding: 16px 40px; background: linear-gradient(135deg, #006d77 0%, #83c5be 100%); " +
               "                                           color: #ffffff; text-decoration: none; border-radius: 8px; " +
               "                                           font-weight: 600; font-size: 16px; box-shadow: 0 4px 6px rgba(0, 109, 119, 0.3);'>" +
               "                                            ✅ Activar mi cuenta" +
               "                                        </a>" +
               "                                    </td>" +
               "                                </tr>" +
               "                            </table>" +
               "                            <!-- Información adicional -->" +
               "                            <div style='background-color: #f8f9fa; border-left: 4px solid #006d77; padding: 20px; border-radius: 4px; margin: 30px 0;'>" +
               "                                <p style='margin: 0 0 10px 0; color: #2b2d42; font-size: 14px; font-weight: 600;'>" +
               "                                    ℹ️ Información importante:" +
               "                                </p>" +
               "                                <ul style='margin: 0; padding-left: 20px; color: #555555; font-size: 14px; line-height: 1.8;'>" +
               "                                    <li>Este enlace expirará en <strong>48 horas</strong></li>" +
               "                                    <li>Solo puede ser usado <strong>una vez</strong></li>" +
               "                                    <li>Si no creaste esta cuenta, puedes ignorar este correo</li>" +
               "                                </ul>" +
               "                            </div>" +
               "                            <!-- Link alternativo -->" +
               "                            <p style='margin: 30px 0 0 0; color: #888888; font-size: 14px; line-height: 1.6;'>" +
               "                                Si el botón no funciona, copia y pega este enlace en tu navegador:" +
               "                            </p>" +
               "                            <p style='margin: 10px 0 0 0; word-break: break-all; color: #006d77; font-size: 12px; font-family: monospace; background-color: #f8f9fa; padding: 10px; border-radius: 4px;'>" +
               "                                " + linkActivacion +
               "                            </p>" +
               "                        </td>" +
               "                    </tr>" +
               "                    <!-- Footer -->" +
               "                    <tr>" +
               "                        <td style='background-color: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #e9ecef;'>" +
               "                            <p style='margin: 0 0 10px 0; color: #666666; font-size: 14px;'>" +
               "                                © " + java.time.Year.now() + " " + APPLICATION_NAME + ". Todos los derechos reservados." +
               "                            </p>" +
               "                            <p style='margin: 0; color: #999999; font-size: 12px;'>" +
               "                                Este correo fue generado automáticamente. Por favor, no responda a este mensaje." +
               "                            </p>" +
               "                        </td>" +
               "                    </tr>" +
               "                </table>" +
               "            </td>" +
               "        </tr>" +
               "    </table>" +
               "</body>" +
               "</html>";
    }
    
    /**
     * Genera el template HTML para recuperación de contraseña.
     */
    private static String generarTemplateRecuperacion(String nombreUsuario, String linkRecuperacion, String tokenBackup) {
        return "<!DOCTYPE html>" +
               "<html lang='es'>" +
               "<head>" +
               "    <meta charset='UTF-8'>" +
               "    <meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
               "    <title>Recuperación de contraseña</title>" +
               "</head>" +
               "<body style='margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif; background-color: #f4f4f4;'>" +
               "    <table role='presentation' style='width: 100%; border-collapse: collapse;'>" +
               "        <tr>" +
               "            <td style='padding: 40px 20px;'>" +
               "                <table role='presentation' style='max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); overflow: hidden;'>" +
               "                    <!-- Header con gradiente (rojo/naranja para alerta) -->" +
               "                    <tr>" +
               "                        <td style='background: linear-gradient(135deg, #dc3545 0%, #ff6b6b 100%); padding: 40px 30px; text-align: center;'>" +
               "                            <h1 style='margin: 0; color: #ffffff; font-size: 28px; font-weight: 600;'>" +
               "                                🔐 Recuperación de Contraseña" +
               "                            </h1>" +
               "                        </td>" +
               "                    </tr>" +
               "                    <!-- Contenido principal -->" +
               "                    <tr>" +
               "                        <td style='padding: 40px 30px;'>" +
               "                            <h2 style='margin: 0 0 20px 0; color: #2b2d42; font-size: 24px; font-weight: 600;'>" +
               "                                Hola " + nombreUsuario + "," +
               "                            </h2>" +
               "                            <p style='margin: 0 0 20px 0; color: #555555; font-size: 16px; line-height: 1.6;'>" +
               "                                Hemos recibido una solicitud para restablecer la contraseña de tu cuenta en <strong>" + APPLICATION_NAME + "</strong>." +
               "                            </p>" +
               "                            <p style='margin: 0 0 30px 0; color: #555555; font-size: 16px; line-height: 1.6;'>" +
               "                                Para crear una nueva contraseña, haz clic en el siguiente botón:" +
               "                            </p>" +
               "                            <!-- Botón de recuperación -->" +
               "                            <table role='presentation' style='width: 100%; margin: 30px 0;'>" +
               "                                <tr>" +
               "                                    <td style='text-align: center;'>" +
               "                                        <a href='" + linkRecuperacion + "' " +
               "                                           style='display: inline-block; padding: 16px 40px; background: linear-gradient(135deg, #dc3545 0%, #ff6b6b 100%); " +
               "                                           color: #ffffff; text-decoration: none; border-radius: 8px; " +
               "                                           font-weight: 600; font-size: 16px; box-shadow: 0 4px 6px rgba(220, 53, 69, 0.3);'>" +
               "                                            🔑 Restablecer mi contraseña" +
               "                                        </a>" +
               "                                    </td>" +
               "                                </tr>" +
               "                            </table>" +
               "                            <!-- Advertencia de seguridad -->" +
               "                            <div style='background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 20px; border-radius: 4px; margin: 30px 0;'>" +
               "                                <p style='margin: 0 0 10px 0; color: #856404; font-size: 14px; font-weight: 600;'>" +
               "                                    ⚠️ Importante - Seguridad:" +
               "                                </p>" +
               "                                <ul style='margin: 0; padding-left: 20px; color: #856404; font-size: 14px; line-height: 1.8;'>" +
               "                                    <li>Este enlace expirará en <strong>1 hora</strong></li>" +
               "                                    <li>Solo puede ser usado <strong>una vez</strong></li>" +
               "                                    <li>Si <strong>NO</strong> solicitaste este cambio, ignora este correo</li>" +
               "                                    <li>Tu cuenta seguirá siendo segura si no haces nada</li>" +
               "                                </ul>" +
               "                            </div>" +
               "                            <!-- Link alternativo -->" +
               "                            <p style='margin: 30px 0 0 0; color: #888888; font-size: 14px; line-height: 1.6;'>" +
               "                                Si el botón no funciona, copia y pega este enlace en tu navegador:" +
               "                            </p>" +
               "                            <p style='margin: 10px 0 0 0; word-break: break-all; color: #dc3545; font-size: 12px; font-family: monospace; background-color: #f8f9fa; padding: 10px; border-radius: 4px;'>" +
               "                                " + linkRecuperacion +
               "                            </p>" +
               "                        </td>" +
               "                    </tr>" +
               "                    <!-- Footer -->" +
               "                    <tr>" +
               "                        <td style='background-color: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #e9ecef;'>" +
               "                            <p style='margin: 0 0 10px 0; color: #666666; font-size: 14px;'>" +
               "                                © " + java.time.Year.now() + " " + APPLICATION_NAME + ". Todos los derechos reservados." +
               "                            </p>" +
               "                            <p style='margin: 0; color: #999999; font-size: 12px;'>" +
               "                                Este correo fue generado automáticamente. Por favor, no responda a este mensaje." +
               "                            </p>" +
               "                        </td>" +
               "                    </tr>" +
               "                </table>" +
               "            </td>" +
               "        </tr>" +
               "    </table>" +
               "</body>" +
               "</html>";
    }
}

