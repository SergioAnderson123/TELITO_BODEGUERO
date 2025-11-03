package com.example.telito.util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Clase utilitaria para el envío de correos electrónicos.
 * Implementa el sistema de notificaciones por email del sistema TELITO_BODEGUERO.
 * Basado en Jakarta Mail API 2.0.1.
 */
public class EmailUtil {
    
    private static final Logger logger = Logger.getLogger(EmailUtil.class.getName());
    
    // Configuración por defecto (Gmail SMTP)
    private static String SMTP_HOST = "smtp.gmail.com";
    private static String SMTP_PORT = "587";
    private static String EMAIL_FROM = ""; // Configurar en propiedades
    private static String EMAIL_PASSWORD = ""; // Configurar en propiedades
    
    // Cargar configuración desde archivo de propiedades
    static {
        loadEmailConfig();
    }
    
    /**
     * Carga la configuración de email desde un archivo de propiedades.
     * Si no existe el archivo, usa valores por defecto.
     */
    private static void loadEmailConfig() {
        Properties props = new Properties();
        try (InputStream input = EmailUtil.class.getClassLoader()
                .getResourceAsStream("email.properties")) {
            if (input != null) {
                props.load(input);
                SMTP_HOST = props.getProperty("smtp.host", SMTP_HOST);
                SMTP_PORT = props.getProperty("smtp.port", SMTP_PORT);
                EMAIL_FROM = props.getProperty("email.from", "");
                EMAIL_PASSWORD = props.getProperty("email.password", "");
                logger.info("✓ Configuración de email cargada desde email.properties");
            } else {
                logger.warning("⚠ Archivo email.properties no encontrado. Usando valores por defecto.");
                logger.warning("⚠ Por favor, configura las credenciales de email.");
            }
        } catch (IOException e) {
            logger.warning("⚠ Error al cargar email.properties: " + e.getMessage());
        }
    }
    
    /**
     * Constructor privado para evitar instanciación
     */
    private EmailUtil() {
        // No se permite instanciar esta clase
    }
    
    /**
     * Envía un correo electrónico de texto plano.
     * 
     * @param to Dirección de correo del destinatario
     * @param subject Asunto del correo
     * @param messageBody Cuerpo del mensaje (texto plano)
     * @return true si el correo se envió exitosamente, false en caso contrario
     */
    public static boolean sendEmail(String to, String subject, String messageBody) {
        return sendEmail(to, subject, messageBody, false);
    }
    
    /**
     * Envía un correo electrónico.
     * 
     * @param to Dirección de correo del destinatario
     * @param subject Asunto del correo
     * @param messageBody Cuerpo del mensaje
     * @param isHtml true si el mensaje es HTML, false si es texto plano
     * @return true si el correo se envió exitosamente, false en caso contrario
     */
    public static boolean sendEmail(String to, String subject, String messageBody, boolean isHtml) {
        if (EMAIL_FROM == null || EMAIL_FROM.isEmpty() || 
            EMAIL_PASSWORD == null || EMAIL_PASSWORD.isEmpty()) {
            logger.severe("✗ Error: Credenciales de email no configuradas.");
            logger.severe("✗ Por favor, configura EMAIL_FROM y EMAIL_PASSWORD en email.properties");
            return false;
        }
        
        if (to == null || to.trim().isEmpty()) {
            logger.warning("⚠ Dirección de correo destinatario vacía.");
            return false;
        }
        
        try {
            // Configurar propiedades SMTP
            Properties props = new Properties();
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.ssl.trust", SMTP_HOST);
            props.put("mail.debug", "false"); // Cambiar a true para debug
            
            // Crear sesión con autenticación
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_FROM, EMAIL_PASSWORD);
                }
            });
            
            // Crear mensaje
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(EMAIL_FROM));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            
            // Configurar tipo de contenido (HTML o texto plano)
            if (isHtml) {
                message.setContent(messageBody, "text/html; charset=utf-8");
            } else {
                message.setText(messageBody);
            }
            
            // Enviar mensaje
            Transport.send(message);
            
            logger.info("✓ Correo enviado exitosamente a: " + to);
            return true;
            
        } catch (MessagingException e) {
            logger.severe("✗ Error al enviar correo a " + to + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            logger.severe("✗ Error inesperado al enviar correo: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Envía un correo de confirmación de registro de perro.
     * Método específico para el ejemplo de VetClinic, puede ser usado como plantilla.
     * 
     * @param toEmail Email del destinatario
     * @param dogName Nombre del perro registrado
     * @return true si el correo se envió exitosamente
     */
    public static boolean sendDogRegistrationConfirmation(String toEmail, String dogName) {
        String subject = "VetCare - Dog Registration Confirmation";
        String message = "Hello,\n\n" +
                        "Your dog \"" + dogName + "\" has been successfully registered at VetClinic.\n\n" +
                        "Thank you!";
        return sendEmail(toEmail, subject, message);
    }
    
    /**
     * Envía un correo de alerta del sistema TELITO_BODEGUERO.
     * 
     * @param toEmail Email del destinatario
     * @param alertTitle Título de la alerta
     * @param alertMessage Mensaje de la alerta
     * @return true si el correo se envió exitosamente
     */
    public static boolean sendSystemAlert(String toEmail, String alertTitle, String alertMessage) {
        String subject = "TELITO BODEGUERO - " + alertTitle;
        String message = "Estimado usuario,\n\n" +
                        alertMessage + "\n\n" +
                        "Este es un mensaje automático del sistema TELITO BODEGUERO.\n" +
                        "Por favor, no responda a este correo.\n\n" +
                        "Saludos,\n" +
                        "Sistema TELITO BODEGUERO";
        return sendEmail(toEmail, subject, message);
    }
    
    /**
     * Envía un correo HTML de alerta del sistema.
     * 
     * @param toEmail Email del destinatario
     * @param alertTitle Título de la alerta
     * @param alertMessage Mensaje de la alerta (puede contener HTML)
     * @return true si el correo se envió exitosamente
     */
    public static boolean sendSystemAlertHTML(String toEmail, String alertTitle, String alertMessage) {
        if (toEmail == null || toEmail.trim().isEmpty()) {
            logger.warning("⚠ Dirección de correo destinatario vacía en sendSystemAlertHTML");
            return false;
        }
        
        String subject = alertTitle.startsWith("TELITO BODEGUERO") ? alertTitle : "TELITO BODEGUERO - " + alertTitle;
        
        // Si el mensaje ya contiene HTML completo (tiene <html>), enviarlo tal cual
        // Si no, envolverlo en un template HTML básico
        String htmlMessage;
        if (alertMessage != null && alertMessage.trim().toLowerCase().contains("<html>")) {
            // El mensaje ya es HTML completo, usarlo directamente
            htmlMessage = alertMessage;
            logger.info("📧 Detectado HTML completo en el mensaje, usando directamente");
        } else {
            // El mensaje es texto plano o HTML parcial, envolverlo en template
            htmlMessage = "<!DOCTYPE html>" +
                        "<html>" +
                        "<head>" +
                        "<meta charset='UTF-8'>" +
                        "<style>" +
                        "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }" +
                        ".container { max-width: 600px; margin: 0 auto; padding: 20px; }" +
                        ".header { background-color: #006d77; color: white; padding: 20px; text-align: center; }" +
                        ".content { padding: 20px; background-color: #f9f9f9; }" +
                        ".footer { padding: 20px; text-align: center; color: #666; font-size: 12px; }" +
                        "</style>" +
                        "</head>" +
                        "<body>" +
                        "<div class='container'>" +
                        "<div class='header'><h2>TELITO BODEGUERO</h2></div>" +
                        "<div class='content'>" +
                        "<h3>" + alertTitle + "</h3>" +
                        (alertMessage != null ? alertMessage.replace("\n", "<br>") : "") +
                        "<p><em>Este es un mensaje automático del sistema. Por favor, no responda a este correo.</em></p>" +
                        "</div>" +
                        "<div class='footer'>" +
                        "<p>Sistema TELITO BODEGUERO - Gestión Logística</p>" +
                        "</div>" +
                        "</div>" +
                        "</body>" +
                        "</html>";
            logger.info("📧 Mensaje es texto plano, envolviendo en template HTML");
        }
        
        logger.info("📧 Enviando correo HTML a: " + toEmail);
        logger.info("   Asunto: " + subject);
        boolean resultado = sendEmail(toEmail, subject, htmlMessage, true);
        if (resultado) {
            logger.info("✓ Correo HTML enviado exitosamente a: " + toEmail);
        } else {
            logger.severe("✗ Error al enviar correo HTML a: " + toEmail);
        }
        return resultado;
    }
    
    /**
     * Configura las credenciales de email manualmente.
     * Útil si no se puede usar el archivo de propiedades.
     * 
     * @param emailFrom Email del remitente
     * @param emailPassword Contraseña de aplicación del remitente
     * @param smtpHost Host SMTP (opcional, usa Gmail por defecto)
     * @param smtpPort Puerto SMTP (opcional, usa 587 por defecto)
     */
    public static void configureEmail(String emailFrom, String emailPassword, 
                                      String smtpHost, String smtpPort) {
        EMAIL_FROM = emailFrom;
        EMAIL_PASSWORD = emailPassword;
        if (smtpHost != null && !smtpHost.isEmpty()) {
            SMTP_HOST = smtpHost;
        }
        if (smtpPort != null && !smtpPort.isEmpty()) {
            SMTP_PORT = smtpPort;
        }
        logger.info("✓ Configuración de email actualizada manualmente");
    }
    
    /**
     * Verifica si la configuración de email está completa.
     * 
     * @return true si las credenciales están configuradas
     */
    public static boolean isEmailConfigured() {
        return EMAIL_FROM != null && !EMAIL_FROM.isEmpty() && 
               EMAIL_PASSWORD != null && !EMAIL_PASSWORD.isEmpty();
    }
}

