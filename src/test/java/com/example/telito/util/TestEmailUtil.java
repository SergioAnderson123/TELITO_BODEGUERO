package com.example.telito.util;

/**
 * Clase de prueba para verificar el envío de correos electrónicos.
 * 
 * Ejecuta este método main para probar el envío de correos.
 * Asegúrate de que el archivo email.properties esté configurado correctamente.
 */
public class TestEmailUtil {
    
    public static void main(String[] args) {
        System.out.println("=== PRUEBA DE ENVÍO DE CORREOS - TELITO BODEGUERO ===\n");
        
        // 1. Verificar si la configuración está completa
        System.out.println("1. Verificando configuración de email...");
        if (!EmailUtil.isEmailConfigured()) {
            System.out.println("✗ ERROR: La configuración de email no está completa.");
            System.out.println("  Por favor, verifica el archivo: src/main/resources/email.properties");
            System.out.println("  Asegúrate de que 'email.from' y 'email.password' estén configurados.");
            return;
        }
        System.out.println("✓ Configuración de email encontrada.\n");
        
        // 2. Solicitar email de destino
        String emailDestino;
        if (args.length > 0) {
            emailDestino = args[0];
        } else {
            // Email por defecto para pruebas (puedes cambiarlo)
            emailDestino = "sergiomeneses893@gmail.com";
            System.out.println("2. Usando email de destino: " + emailDestino);
            System.out.println("   (Puedes pasar un email diferente como argumento: java TestEmailUtil tu@email.com)\n");
        }
        
        // 3. Enviar correo de prueba simple
        System.out.println("3. Enviando correo de prueba (texto plano)...");
        boolean enviado1 = EmailUtil.sendEmail(
            emailDestino,
            "TELITO BODEGUERO - Prueba de Correo",
            "Este es un correo de prueba del sistema TELITO BODEGUERO.\n\n" +
            "Si recibiste este correo, significa que la configuración de email está funcionando correctamente.\n\n" +
            "Saludos,\n" +
            "Sistema TELITO BODEGUERO"
        );
        
        if (enviado1) {
            System.out.println("✓ Correo de texto plano enviado exitosamente!\n");
        } else {
            System.out.println("✗ Error al enviar correo de texto plano.\n");
        }
        
        // 4. Enviar correo HTML de prueba
        System.out.println("4. Enviando correo de prueba (HTML)...");
        boolean enviado2 = EmailUtil.sendEmail(
            emailDestino,
            "TELITO BODEGUERO - Prueba de Correo HTML",
            "<h1>Prueba de Correo HTML</h1>" +
            "<p>Este es un correo de prueba en formato <strong>HTML</strong> del sistema TELITO BODEGUERO.</p>" +
            "<p>Si recibiste este correo con formato, significa que el envío HTML está funcionando correctamente.</p>" +
            "<hr>" +
            "<p><em>Sistema TELITO BODEGUERO</em></p>",
            true  // isHtml = true
        );
        
        if (enviado2) {
            System.out.println("✓ Correo HTML enviado exitosamente!\n");
        } else {
            System.out.println("✗ Error al enviar correo HTML.\n");
        }
        
        // 5. Enviar alerta del sistema
        System.out.println("5. Enviando alerta del sistema...");
        boolean enviado3 = EmailUtil.sendSystemAlert(
            emailDestino,
            "Prueba de Alerta",
            "Este es un mensaje de alerta de prueba del sistema."
        );
        
        if (enviado3) {
            System.out.println("✓ Alerta del sistema enviada exitosamente!\n");
        } else {
            System.out.println("✗ Error al enviar alerta del sistema.\n");
        }
        
        // 6. Enviar alerta HTML del sistema
        System.out.println("6. Enviando alerta HTML del sistema...");
        boolean enviado4 = EmailUtil.sendSystemAlertHTML(
            emailDestino,
            "Prueba de Alerta HTML",
            "Este es un mensaje de alerta en formato HTML de prueba del sistema."
        );
        
        if (enviado4) {
            System.out.println("✓ Alerta HTML del sistema enviada exitosamente!\n");
        } else {
            System.out.println("✗ Error al enviar alerta HTML del sistema.\n");
        }
        
        System.out.println("=== PRUEBA COMPLETADA ===");
        System.out.println("\nRevisa tu bandeja de entrada (y spam) en: " + emailDestino);
        System.out.println("Si todos los correos llegaron correctamente, el sistema está funcionando bien.");
    }
}

