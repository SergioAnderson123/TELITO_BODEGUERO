package com.example.telito.util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeBodyPart;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeMultipart;

import java.io.File;
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
    private static String APPLICATION_BASE_URL = ""; // URL base de la aplicación para enlaces en correos
    
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
                APPLICATION_BASE_URL = props.getProperty("application.base.url", "");
                logger.info("✓ Configuración de email cargada desde email.properties");
                if (!APPLICATION_BASE_URL.isEmpty()) {
                    logger.info("✓ URL base de la aplicación: " + APPLICATION_BASE_URL);
                }
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
    
    /**
     * Obtiene la URL base de la aplicación configurada en email.properties.
     * Si no está configurada, retorna una cadena vacía.
     * 
     * @return URL base de la aplicación o cadena vacía si no está configurada
     */
    public static String getApplicationBaseUrl() {
        return APPLICATION_BASE_URL != null ? APPLICATION_BASE_URL : "";
    }
    
    /**
     * Construye la URL completa para un path relativo.
     * Si la URL base está configurada, la usa. Si no, usa el contextPath proporcionado.
     * 
     * @param relativePath Path relativo (ej: "/acceso/login")
     * @param contextPath Context path de la aplicación (usado como fallback)
     * @return URL completa para el path proporcionado
     */
    public static String buildApplicationUrl(String relativePath, String contextPath) {
        if (APPLICATION_BASE_URL != null && !APPLICATION_BASE_URL.isEmpty()) {
            // Asegurar que la URL base no termine con /
            String baseUrl = APPLICATION_BASE_URL.endsWith("/") ? 
                APPLICATION_BASE_URL.substring(0, APPLICATION_BASE_URL.length() - 1) : 
                APPLICATION_BASE_URL;
            // Asegurar que el path relativo comience con /
            String path = relativePath.startsWith("/") ? relativePath : "/" + relativePath;
            return baseUrl + path;
        } else if (contextPath != null && !contextPath.isEmpty()) {
            // Fallback: usar contextPath si la URL base no está configurada
            String basePath = contextPath.endsWith("/") ? 
                contextPath.substring(0, contextPath.length() - 1) : 
                contextPath;
            String path = relativePath.startsWith("/") ? relativePath : "/" + relativePath;
            return basePath + path;
        } else {
            // Último fallback: retornar solo el path relativo
            return relativePath;
        }
    }
    
    /**
     * Envía un correo electrónico con un archivo adjunto.
     * 
     * @param to Dirección de correo del destinatario
     * @param subject Asunto del correo
     * @param messageBody Cuerpo del mensaje (puede ser HTML)
     * @param isHtml true si el mensaje es HTML, false si es texto plano
     * @param attachmentFile Archivo a adjuntar
     * @param attachmentName Nombre del archivo adjunto (opcional, si es null usa el nombre del archivo)
     * @return true si el correo se envió exitosamente, false en caso contrario
     */
    public static boolean sendEmailWithAttachment(String to, String subject, String messageBody, 
                                                   boolean isHtml, File attachmentFile, String attachmentName) {
        if (EMAIL_FROM == null || EMAIL_FROM.isEmpty() || 
            EMAIL_PASSWORD == null || EMAIL_PASSWORD.isEmpty()) {
            logger.severe("✗ Error: Credenciales de email no configuradas.");
            return false;
        }
        
        if (to == null || to.trim().isEmpty()) {
            logger.warning("⚠ Dirección de correo destinatario vacía.");
            return false;
        }
        
        if (attachmentFile == null || !attachmentFile.exists() || !attachmentFile.isFile()) {
            logger.warning("⚠ Archivo adjunto no válido o no existe.");
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
            props.put("mail.debug", "false");
            
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
            
            // Crear el cuerpo del mensaje
            MimeBodyPart messageBodyPart = new MimeBodyPart();
            if (isHtml) {
                messageBodyPart.setContent(messageBody, "text/html; charset=utf-8");
            } else {
                messageBodyPart.setText(messageBody);
            }
            
            // Crear parte del adjunto
            MimeBodyPart attachmentPart = new MimeBodyPart();
            attachmentPart.attachFile(attachmentFile);
            if (attachmentName != null && !attachmentName.trim().isEmpty()) {
                attachmentPart.setFileName(attachmentName);
            }
            
            // Combinar partes en un multipart
            Multipart multipart = new MimeMultipart();
            multipart.addBodyPart(messageBodyPart);
            multipart.addBodyPart(attachmentPart);
            
            // Establecer el contenido del mensaje
            message.setContent(multipart);
            
            // Enviar mensaje
            Transport.send(message);
            
            logger.info("✓ Correo con adjunto enviado exitosamente a: " + to);
            logger.info("   Archivo adjunto: " + (attachmentName != null ? attachmentName : attachmentFile.getName()));
            return true;
            
        } catch (MessagingException e) {
            logger.severe("✗ Error al enviar correo con adjunto a " + to + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (IOException e) {
            logger.severe("✗ Error al leer archivo adjunto: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            logger.severe("✗ Error inesperado al enviar correo con adjunto: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Envía un correo HTML con un archivo adjunto (método de conveniencia).
     * 
     * @param toEmail Email del destinatario
     * @param subject Asunto del correo
     * @param htmlMessage Mensaje HTML
     * @param attachmentFile Archivo a adjuntar
     * @param attachmentName Nombre del archivo adjunto
     * @return true si el correo se envió exitosamente
     */
    public static boolean sendSystemAlertHTMLWithAttachment(String toEmail, String subject, 
                                                             String htmlMessage, File attachmentFile, String attachmentName) {
        String finalSubject = subject.startsWith("TELITO BODEGUERO") ? subject : "TELITO BODEGUERO - " + subject;
        return sendEmailWithAttachment(toEmail, finalSubject, htmlMessage, true, attachmentFile, attachmentName);
    }
}

