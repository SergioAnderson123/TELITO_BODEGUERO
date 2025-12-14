package com.example.telito.util;

import java.text.SimpleDateFormat;
import java.util.Date;

// Plantillas HTML profesionales para correos (diseño moderno, responsive, identidad visual turquesa)
public class EmailTemplates {
    
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    private static final String APP_NAME = "TELITO BODEGUERO";
    
    // Colores turquesa del sistema
    private static final String COLOR_PRIMARY = "#00a896";
    private static final String COLOR_SECONDARY = "#028f80";
    private static final String COLOR_TERTIARY = "#02796b";
    private static final String COLOR_LIGHT = "#83c5be";
    private static final String COLOR_SUCCESS = "#28a745";
    private static final String COLOR_WARNING = "#ffc107";
    private static final String COLOR_DANGER = "#dc3545";
    
    // Template base HTML con diseño responsive y moderno
    private static String getBaseTemplate(String headerColor, String headerIcon, String headerTitle, 
                                         String content, String footerNote) {
        return """
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>%s</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background: linear-gradient(135deg, #f5f7fa 0%%, #c3cfe2 100%%);">
    <table role="presentation" style="width: 100%%; border-collapse: collapse; padding: 40px 20px;">
        <tr>
            <td align="center">
                <table role="presentation" style="max-width: 600px; width: 100%%; background-color: #ffffff; border-radius: 16px; box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15); overflow: hidden;">
                    
                    <!-- Header con gradiente turquesa -->
                    <tr>
                        <td style="background: linear-gradient(165deg, %s 0%%, %s 50%%, %s 100%%); padding: 40px 30px; text-align: center;">
                            <div style="font-size: 48px; margin-bottom: 15px;">%s</div>
                            <h1 style="margin: 0; color: #ffffff; font-size: 28px; font-weight: 600; text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);">
                                %s
                            </h1>
                            <p style="margin: 10px 0 0 0; color: rgba(255, 255, 255, 0.9); font-size: 14px;">
                                %s
                            </p>
                        </td>
                    </tr>
                    
                    <!-- Contenido principal -->
                    <tr>
                        <td style="padding: 40px 30px;">
                            %s
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="background: linear-gradient(to bottom, #f8f9fa 0%%, #e9ecef 100%%); padding: 30px; text-align: center; border-top: 3px solid %s;">
                            <p style="margin: 0 0 10px 0; color: #666666; font-size: 14px; font-weight: 500;">
                                © %d %s - Sistema de Gestión Logística
                            </p>
                            <p style="margin: 0 0 15px 0; color: #999999; font-size: 12px;">
                                %s
                            </p>
                            <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #dee2e6;">
                                <p style="margin: 0; color: #6c757d; font-size: 11px; line-height: 1.6;">
                                    Este correo fue generado automáticamente el %s<br>
                                    Por favor, no responda a este mensaje
                                </p>
                            </div>
                        </td>
                    </tr>
                    
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
""".formatted(
            headerTitle,
            headerColor, COLOR_SECONDARY, COLOR_TERTIARY, // Gradiente
            headerIcon, headerTitle, APP_NAME,
            content,
            headerColor,
            java.time.Year.now().getValue(), APP_NAME,
            footerNote != null ? footerNote : "Todos los derechos reservados",
            DATE_FORMAT.format(new Date())
        );
    }
    
    /**
     * Genera HTML para una sección de información destacada.
     */
    private static String getInfoBox(String title, String content, String borderColor) {
        return """
            <div style="background: linear-gradient(to right, %s 0%%, rgba(255, 255, 255, 0) 100%%); border-left: 4px solid %s; padding: 20px; border-radius: 8px; margin: 20px 0; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);">
                <p style="margin: 0 0 10px 0; color: #2b2d42; font-size: 16px; font-weight: 600;">
                    %s
                </p>
                <div style="color: #555555; font-size: 14px; line-height: 1.8;">
                    %s
                </div>
            </div>
        """.formatted(
            borderColor.replace("#", "rgba(") + ", 0.05)",
            borderColor,
            title,
            content
        );
    }
    
    /**
     * Genera botón de acción con estilo moderno.
     */
    private static String getActionButton(String text, String url, String color) {
        return """
            <table role="presentation" style="width: 100%%; margin: 25px 0;">
                <tr>
                    <td align="center">
                        <a href="%s" style="display: inline-block; padding: 16px 40px; background: linear-gradient(135deg, %s 0%%, %s 100%%); color: #ffffff; text-decoration: none; border-radius: 10px; font-weight: 600; font-size: 16px; box-shadow: 0 6px 20px rgba(%s, 0.4); transition: all 0.3s ease;">
                            %s →
                        </a>
                    </td>
                </tr>
            </table>
        """.formatted(
            url,
            color, 
            adjustColorBrightness(color, -20),
            hexToRgb(color),
            text
        );
    }
    
    /**
     * Correo de nueva orden de compra para el productor.
     */
    public static String generarCorreoNuevaOrdenProductor(String numeroOrden, String nombreProducto, 
                                                          int cantidad, double montoTotal, String fechaCreacion) {
        String content = """
            <h2 style="margin: 0 0 20px 0; color: #2b2d42; font-size: 24px; font-weight: 600;">
                Nueva Orden Pendiente de Revisión
            </h2>
            <p style="margin: 0 0 20px 0; color: #555555; font-size: 16px; line-height: 1.6;">
                Se ha creado una nueva orden de compra que requiere tu <strong>revisión y respuesta urgente</strong>.
            </p>
            
            %s
            
            %s
            
            %s
        """.formatted(
            getInfoBox("📋 Detalles de la Orden", """
                <table style="width: 100%%; border-collapse: collapse;">
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; font-weight: 500;">Número de Orden:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; font-family: monospace;">%s</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; font-weight: 500; border-top: 1px solid #e9ecef;">Producto:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; border-top: 1px solid #e9ecef;">%s</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; font-weight: 500; border-top: 1px solid #e9ecef;">Cantidad:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; border-top: 1px solid #e9ecef;">%d paquetes</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; font-weight: 500; border-top: 1px solid #e9ecef;">Monto Total:</td>
                        <td style="padding: 8px 0; color: #28a745; font-weight: 700; text-align: right; font-size: 18px; border-top: 1px solid #e9ecef;">S/ %.2f</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; font-weight: 500; border-top: 1px solid #e9ecef;">Fecha de Creación:</td>
                        <td style="padding: 8px 0; color: #2b2d42; text-align: right; border-top: 1px solid #e9ecef;">%s</td>
                    </tr>
                </table>
            """.formatted(numeroOrden, nombreProducto, cantidad, montoTotal, fechaCreacion), COLOR_PRIMARY),
            
            getInfoBox("⚡ Acción Requerida", """
                <ul style="margin: 10px 0; padding-left: 20px; line-height: 2;">
                    <li><strong>Revisa</strong> los detalles de la orden en tu panel de productor</li>
                    <li><strong>Confirma</strong> si puedes cumplir con la orden completa</li>
                    <li><strong>Informa</strong> cualquier observación o limitación</li>
                    <li><strong>Envía</strong> tu respuesta a logística a la brevedad posible</li>
                </ul>
                <p style="margin: 15px 0 0 0; padding: 15px; background-color: #fff3cd; border-radius: 6px; color: #856404; font-size: 13px;">
                    ⏱️ <strong>Tiempo de respuesta:</strong> Por favor, responde dentro de las próximas 24 horas
                </p>
            """, COLOR_WARNING),
            
            getInfoBox("📌 Siguientes Pasos", """
                <ol style="margin: 10px 0; padding-left: 20px; line-height: 2;">
                    <li>Logística revisará tu respuesta</li>
                    <li>Te notificaremos si la orden es <strong>aprobada</strong> o <strong>rechazada</strong></li>
                    <li>Si es aprobada, deberás preparar la mercancía según lo acordado</li>
                    <li>Se coordinará la fecha de recojo o entrega</li>
                </ol>
            """, COLOR_SECONDARY)
        );
        
        return getBaseTemplate(COLOR_PRIMARY, "📦", "Nueva Orden de Compra", content, 
                              "Gestión eficiente de órdenes de compra");
    }
    
    /**
     * Correo de orden aceptada por el productor (para logística).
     */
    public static String generarCorreoOrdenAceptadaLogistica(String numeroOrden, String nombreProducto, 
                                                             int cantidad, double montoTotal, String fechaAceptacion) {
        String content = """
            <h2 style="margin: 0 0 20px 0; color: #2b2d42; font-size: 24px; font-weight: 600;">
                ✅ Orden Aceptada por el Productor
            </h2>
            <p style="margin: 0 0 20px 0; color: #555555; font-size: 16px; line-height: 1.6;">
                El productor ha <strong>aceptado</strong> la orden de compra y está preparando la mercancía.
            </p>
            
            %s
            
            %s
        """.formatted(
            getInfoBox("📦 Detalles de la Orden", """
                <table style="width: 100%%; border-collapse: collapse;">
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d;">Número de Orden:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; font-family: monospace;">%s</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; border-top: 1px solid #e9ecef;">Producto:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; border-top: 1px solid #e9ecef;">%s</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; border-top: 1px solid #e9ecef;">Cantidad:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; border-top: 1px solid #e9ecef;">%d paquetes</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; border-top: 1px solid #e9ecef;">Monto Total:</td>
                        <td style="padding: 8px 0; color: #28a745; font-weight: 700; text-align: right; font-size: 18px; border-top: 1px solid #e9ecef;">S/ %.2f</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; border-top: 1px solid #e9ecef;">Fecha de Aceptación:</td>
                        <td style="padding: 8px 0; color: #2b2d42; text-align: right; border-top: 1px solid #e9ecef;">%s</td>
                    </tr>
                </table>
                <div style="margin-top: 15px; padding: 15px; background-color: #d4edda; border-radius: 6px; text-align: center;">
                    <span style="color: #155724; font-size: 16px; font-weight: 600;">
                        🟢 Estado: En Proceso
                    </span>
                </div>
            """.formatted(numeroOrden, nombreProducto, cantidad, montoTotal, fechaAceptacion), COLOR_SUCCESS),
            
            getInfoBox("📌 Próximos Pasos", """
                <ul style="margin: 10px 0; padding-left: 20px; line-height: 2;">
                    <li>El productor está <strong>preparando la mercancía</strong></li>
                    <li>Se te notificará cuando esté lista para ser recibida en el almacén</li>
                    <li>Coordina con el productor la fecha de entrega</li>
                    <li>Una vez recibida, actualiza el sistema para registrar la entrada</li>
                </ul>
            """, COLOR_PRIMARY)
        );
        
        return getBaseTemplate(COLOR_SUCCESS, "✅", "Orden Aceptada - En Proceso", content, 
                              "Seguimiento de órdenes de compra");
    }
    
    /**
     * Correo de nuevo plan de transporte (para almacén).
     */
    public static String generarCorreoNuevoPlanTransporte(String numeroPlan, String nombreProducto, 
                                                          String codigoLote, int stockDisponible, String fechaEntrega) {
        String content = """
            <h2 style="margin: 0 0 20px 0; color: #2b2d42; font-size: 24px; font-weight: 600;">
                Nuevo Plan de Transporte Creado
            </h2>
            <p style="margin: 0 0 20px 0; color: #555555; font-size: 16px; line-height: 1.6;">
                Se ha creado un nuevo plan de transporte que requiere <strong>preparación de mercancía</strong> desde el almacén.
            </p>
            
            %s
            
            %s
            
            %s
        """.formatted(
            getInfoBox("🚚 Detalles del Plan de Transporte", """
                <table style="width: 100%%; border-collapse: collapse;">
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d;">Número de Plan:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; font-family: monospace;">%s</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; border-top: 1px solid #e9ecef;">Producto:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; border-top: 1px solid #e9ecef;">%s</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; border-top: 1px solid #e9ecef;">Lote:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; font-family: monospace; border-top: 1px solid #e9ecef;">%s</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; border-top: 1px solid #e9ecef;">Stock Disponible:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; border-top: 1px solid #e9ecef;">%d paquetes</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; border-top: 1px solid #e9ecef;">Fecha de Entrega:</td>
                        <td style="padding: 8px 0; color: #dc3545; font-weight: 700; text-align: right; border-top: 1px solid #e9ecef;">%s</td>
                    </tr>
                </table>
            """.formatted(numeroPlan, nombreProducto, codigoLote, stockDisponible, fechaEntrega), COLOR_PRIMARY),
            
            getInfoBox("⚡ Acción Requerida", """
                <ul style="margin: 10px 0; padding-left: 20px; line-height: 2;">
                    <li><strong>Prepara</strong> la mercancía según este plan de transporte</li>
                    <li><strong>Verifica</strong> el stock disponible del lote indicado</li>
                    <li><strong>Registra</strong> la salida en el sistema una vez preparada</li>
                    <li><strong>Coordina</strong> con logística si hay algún inconveniente</li>
                </ul>
                <p style="margin: 15px 0 0 0; padding: 15px; background-color: #d1ecf1; border-radius: 6px; color: #0c5460; font-size: 14px; text-align: center;">
                    💡 <strong>Acceso rápido:</strong> Almacén → Registrar Salidas
                </p>
            """, COLOR_WARNING),
            
            getInfoBox("📋 Instrucciones", """
                <ol style="margin: 10px 0; padding-left: 20px; line-height: 2;">
                    <li>Localiza el lote en el almacén físico</li>
                    <li>Verifica la calidad y fechas de vencimiento</li>
                    <li>Prepara el empaquetado según especificaciones</li>
                    <li>Registra la salida en el sistema</li>
                    <li>Mantén el área de salida organizada</li>
                </ol>
            """, COLOR_SECONDARY)
        );
        
        return getBaseTemplate(COLOR_PRIMARY, "🚚", "Nuevo Plan de Transporte", content, 
                              "Gestión de planes de transporte y salidas");
    }
    
    /**
     * Correo de lote registrado por productor (para logística).
     */
    public static String generarCorreoLoteRegistrado(String codigoLote, String nombreProducto, 
                                                     int cantidad, String fechaVencimiento, String nombreProductor) {
        String content = """
            <h2 style="margin: 0 0 20px 0; color: #2b2d42; font-size: 24px; font-weight: 600;">
                Nuevo Lote Registrado
            </h2>
            <p style="margin: 0 0 20px 0; color: #555555; font-size: 16px; line-height: 1.6;">
                El productor <strong>%s</strong> ha registrado un nuevo lote de producto en el sistema.
            </p>
            
            %s
            
            %s
        """.formatted(
            nombreProductor,
            
            getInfoBox("📦 Información del Lote", """
                <table style="width: 100%%; border-collapse: collapse;">
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d;">Código de Lote:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; font-family: monospace;">%s</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; border-top: 1px solid #e9ecef;">Producto:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; border-top: 1px solid #e9ecef;">%s</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; border-top: 1px solid #e9ecef;">Cantidad:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; border-top: 1px solid #e9ecef;">%d paquetes</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; border-top: 1px solid #e9ecef;">Fecha de Vencimiento:</td>
                        <td style="padding: 8px 0; color: #dc3545; font-weight: 600; text-align: right; border-top: 1px solid #e9ecef;">%s</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #6c757d; border-top: 1px solid #e9ecef;">Productor:</td>
                        <td style="padding: 8px 0; color: #2b2d42; font-weight: 600; text-align: right; border-top: 1px solid #e9ecef;">%s</td>
                    </tr>
                </table>
            """.formatted(codigoLote, nombreProducto, cantidad, fechaVencimiento, nombreProductor), COLOR_PRIMARY),
            
            getInfoBox("📌 Próximos Pasos", """
                <ul style="margin: 10px 0; padding-left: 20px; line-height: 2;">
                    <li>Revisa los detalles del lote en el sistema</li>
                    <li>Coordina con el productor para la recepción en almacén</li>
                    <li>Verifica que la calidad cumpla con los estándares</li>
                    <li>Una vez recibido, el lote estará disponible para planes de transporte</li>
                </ul>
            """, COLOR_SECONDARY)
        );
        
        return getBaseTemplate(COLOR_PRIMARY, "📦", "Nuevo Lote Registrado", content, 
                              "Gestión de lotes y stock");
    }
    
    // ========== MÉTODOS AUXILIARES ==========
    
    /**
     * Ajusta el brillo de un color hexadecimal.
     */
    private static String adjustColorBrightness(String hexColor, int percent) {
        int r = Integer.parseInt(hexColor.substring(1, 3), 16);
        int g = Integer.parseInt(hexColor.substring(3, 5), 16);
        int b = Integer.parseInt(hexColor.substring(5, 7), 16);
        
        r = Math.max(0, Math.min(255, r + (r * percent / 100)));
        g = Math.max(0, Math.min(255, g + (g * percent / 100)));
        b = Math.max(0, Math.min(255, b + (b * percent / 100)));
        
        return String.format("#%02x%02x%02x", r, g, b);
    }
    
    /**
     * Convierte hex a RGB para usar en rgba().
     */
    private static String hexToRgb(String hexColor) {
        int r = Integer.parseInt(hexColor.substring(1, 3), 16);
        int g = Integer.parseInt(hexColor.substring(3, 5), 16);
        int b = Integer.parseInt(hexColor.substring(5, 7), 16);
        return r + ", " + g + ", " + b;
    }
}
