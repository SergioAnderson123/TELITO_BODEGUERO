package com.example.telito.administrador.services;

import com.example.telito.administrador.beans.AuditoriaLog;
import com.example.telito.administrador.daos.AuditoriaDAO;
import com.example.telito.util.EmailUtil;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileOutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;

/**
 * Servicio para gestionar la limpieza automática de registros de auditoría.
 * 
 * FUNCIONALIDADES:
 * - Envía reportes de auditoría por correo antes de eliminar
 * - Elimina automáticamente registros antiguos
 * - Mantiene un historial mínimo de seguridad
 * - Reduce costos de almacenamiento en la nube
 * 
 * @author Telito Bodeguero
 * @version 1.0
 */
public class AuditoriaCleanupService extends com.example.telito.util.DAOBase {
    
    private static final Logger logger = LoggerFactory.getLogger(AuditoriaCleanupService.class);
    
    // Configuración: mantener registros de los últimos X días
    // 7 días = Limpieza semanal (recomendado para costos de nube)
    // 30 días = Retención mensual (si necesitas más historial)
    private static final int DIAS_MANTENER_AUDITORIA = 3; // Configuración: 3 días
    
    // Configuración: enviar reporte a estos emails
    // IMPORTANTE: Estos son los DESTINATARIOS (quienes reciben el reporte)
    // Pueden ser cualquier correo válido (Gmail, Outlook, etc.)
    private static final String[] EMAILS_REPORTE = {
        "a20223291@pucp.edu.pe"  // ← Cambia por TU correo donde quieres recibir los reportes
        // "otro-correo@hotmail.com"     // ← Puedes agregar más destinatarios si quieres
    };
    
    /**
     * Ejecuta el proceso completo de limpieza:
     * 1. Obtiene registros antiguos
     * 2. Envía reporte por correo
     * 3. Elimina registros antiguos
     * 4. Retorna resultado de la operación
     */
    public ResultadoLimpieza ejecutarLimpieza() {
        logger.info("🧹 Iniciando proceso de limpieza de auditoría...");
        
        ResultadoLimpieza resultado = new ResultadoLimpieza();
        resultado.fechaEjecucion = LocalDateTime.now();
        
        try {
            // 1. Contar registros totales antes de limpieza
            resultado.registrosTotalesAntes = contarRegistrosTotales();
            logger.info("📊 Total de registros antes: {}", resultado.registrosTotalesAntes);
            
            // 2. Obtener registros antiguos para el reporte
            ArrayList<AuditoriaLog> registrosAntiguos = obtenerRegistrosAntiguos(DIAS_MANTENER_AUDITORIA);
            resultado.registrosAEliminar = registrosAntiguos.size();
            logger.info("📋 Registros a eliminar (más de {} días): {}", DIAS_MANTENER_AUDITORIA, resultado.registrosAEliminar);
            
            if (registrosAntiguos.isEmpty()) {
                logger.info("✅ No hay registros antiguos para eliminar.");
                resultado.exito = true;
                resultado.mensaje = String.format(
                    "No hay registros que eliminar. Todos los registros tienen menos de %d días de antigüedad.", 
                    DIAS_MANTENER_AUDITORIA
                );
                resultado.registrosTotalesDespues = resultado.registrosTotalesAntes;
                return resultado;
            }
            
            // 3. Enviar reporte por correo
            boolean reporteEnviado = enviarReporteAuditoria(registrosAntiguos, DIAS_MANTENER_AUDITORIA);
            resultado.reporteEnviado = reporteEnviado;
            
            if (!reporteEnviado) {
                logger.warn("⚠️ No se pudo enviar el reporte por correo, pero continuaremos con la eliminación.");
            }
            
            // 4. Eliminar registros antiguos
            int registrosEliminados = eliminarRegistrosAntiguos(DIAS_MANTENER_AUDITORIA);
            resultado.registrosEliminados = registrosEliminados;
            logger.info("🗑️ Registros eliminados: {}", registrosEliminados);
            
            // 5. Contar registros después de limpieza
            resultado.registrosTotalesDespues = contarRegistrosTotales();
            logger.info("📊 Total de registros después: {}", resultado.registrosTotalesDespues);
            
            // 6. Calcular espacio liberado (estimado)
            resultado.espacioLiberadoKB = (long) (registrosEliminados * 2.5); // Estimado: 2.5KB por registro
            
            resultado.exito = true;
            resultado.mensaje = String.format("Limpieza exitosa: %d registros eliminados, %d KB liberados.",
                    registrosEliminados, resultado.espacioLiberadoKB);
            
            logger.info("✅ " + resultado.mensaje);
            
        } catch (Exception e) {
            resultado.exito = false;
            resultado.mensaje = "Error durante la limpieza: " + e.getMessage();
            logger.error("❌ Error en limpieza de auditoría", e);
        }
        
        return resultado;
    }
    
    /**
     * Obtiene los registros de auditoría antiguos para incluir en el reporte.
     */
    private ArrayList<AuditoriaLog> obtenerRegistrosAntiguos(int diasMantener) {
        ArrayList<AuditoriaLog> lista = new ArrayList<>();
        
        String sql = """
            SELECT id_auditoria, usuario_id, usuario_nombre, accion, modulo, descripcion,
                   datos_anteriores, datos_nuevos, ip_address, user_agent, fecha_accion, estado, mensaje_error
            FROM auditoria_sistema
            WHERE fecha_accion < DATE_SUB(NOW(), INTERVAL ? DAY)
            ORDER BY fecha_accion DESC
            LIMIT 500
            """; // Limitamos a 500 registros para el reporte
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, diasMantener);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                AuditoriaLog log = new AuditoriaLog();
                log.setIdAuditoria(rs.getInt("id_auditoria"));
                log.setUsuarioId(rs.getInt("usuario_id"));
                log.setUsuarioNombre(rs.getString("usuario_nombre"));
                log.setAccion(rs.getString("accion"));
                log.setModulo(rs.getString("modulo"));
                log.setDescripcion(rs.getString("descripcion"));
                log.setDatosAnteriores(rs.getString("datos_anteriores"));
                log.setDatosNuevos(rs.getString("datos_nuevos"));
                log.setIpAddress(rs.getString("ip_address"));
                log.setUserAgent(rs.getString("user_agent"));
                log.setFechaAccion(rs.getTimestamp("fecha_accion"));
                log.setEstado(rs.getString("estado"));
                log.setMensajeError(rs.getString("mensaje_error"));
                lista.add(log);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener registros antiguos", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return lista;
    }
    
    /**
     * Elimina los registros de auditoría más antiguos que X días.
     */
    private int eliminarRegistrosAntiguos(int diasMantener) {
        String sql = """
            DELETE FROM auditoria_sistema
            WHERE fecha_accion < DATE_SUB(NOW(), INTERVAL ? DAY)
            """;
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, diasMantener);
            int rowsDeleted = pstmt.executeUpdate();
            logger.info("✅ Eliminados {} registros de auditoría antiguos", rowsDeleted);
            return rowsDeleted;
        } catch (SQLException e) {
            logger.error("❌ Error al eliminar registros antiguos", e);
            return 0;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    
    /**
     * Cuenta el total de registros de auditoría en la base de datos.
     */
    private int contarRegistrosTotales() {
        String sql = "SELECT COUNT(*) FROM auditoria_sistema";
        return count(sql);
    }
    
    /**
     * Envía un reporte por correo con los registros de auditoría antes de eliminarlos.
     */
    private boolean enviarReporteAuditoria(ArrayList<AuditoriaLog> registros, int diasMantener) {
        try {
            java.text.SimpleDateFormat dateFormatter = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
            String asunto = String.format("Reporte de Auditoría - Limpieza Automática (%s)", 
                    dateFormatter.format(new java.util.Date()));
            
            // Generar archivo Excel
            File archivoExcel = generarExcelAuditoria(registros, diasMantener);
            if (archivoExcel == null) {
                logger.error("❌ No se pudo generar el archivo Excel");
                return false;
            }
            
            String cuerpoHtml = generarHtmlReporte(registros, diasMantener);
            
            boolean todosEnviados = true;
            for (String email : EMAILS_REPORTE) {
                boolean enviado = EmailUtil.sendEmailWithAttachment(
                    email, 
                    asunto, 
                    cuerpoHtml, 
                    true,  // isHtml = true
                    archivoExcel,
                    "Auditoria_" + new java.text.SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date()) + ".xlsx"
                );
                
                if (!enviado) {
                    logger.warn("⚠️ No se pudo enviar reporte a: {}", email);
                    todosEnviados = false;
                } else {
                    logger.info("✅ Reporte enviado exitosamente a: {}", email);
                }
            }
            
            // Eliminar archivo temporal
            if (archivoExcel.exists()) {
                archivoExcel.delete();
            }
            
            return todosEnviados;
            
        } catch (Exception e) {
            logger.error("❌ Error al enviar reporte de auditoría", e);
            return false;
        }
    }
    
    /**
     * Genera un archivo Excel con los registros de auditoría.
     */
    private File generarExcelAuditoria(ArrayList<AuditoriaLog> registros, int diasMantener) {
        try {
            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Auditoría Eliminada");
            
            // Estilos
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.SEA_GREEN.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);
            
            CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);
            
            // Encabezados
            Row headerRow = sheet.createRow(0);
            String[] columnas = {"ID", "Fecha", "Usuario ID", "Usuario", "Acción", "Módulo", 
                                 "Descripción", "Estado", "IP", "User Agent", "Mensaje Error"};
            
            for (int i = 0; i < columnas.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columnas[i]);
                cell.setCellStyle(headerStyle);
            }
            
            // Datos
            java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
            int rowNum = 1;
            for (AuditoriaLog log : registros) {
                Row row = sheet.createRow(rowNum++);
                
                row.createCell(0).setCellValue(log.getIdAuditoria());
                row.createCell(1).setCellValue(formatter.format(log.getFechaAccion()));
                row.createCell(2).setCellValue(log.getUsuarioId() != null ? log.getUsuarioId() : 0);
                row.createCell(3).setCellValue(log.getUsuarioNombre() != null ? log.getUsuarioNombre() : "Sistema");
                row.createCell(4).setCellValue(log.getAccion());
                row.createCell(5).setCellValue(log.getModulo());
                row.createCell(6).setCellValue(log.getDescripcion() != null ? log.getDescripcion() : "");
                row.createCell(7).setCellValue(log.getEstado());
                row.createCell(8).setCellValue(log.getIpAddress() != null ? log.getIpAddress() : "");
                row.createCell(9).setCellValue(log.getUserAgent() != null ? log.getUserAgent() : "");
                row.createCell(10).setCellValue(log.getMensajeError() != null ? log.getMensajeError() : "");
                
                // Aplicar estilo a las celdas
                for (int i = 0; i < columnas.length; i++) {
                    row.getCell(i).setCellStyle(dataStyle);
                }
            }
            
            // Ajustar ancho de columnas
            for (int i = 0; i < columnas.length; i++) {
                sheet.autoSizeColumn(i);
            }
            
            // Guardar en archivo temporal
            File tempFile = File.createTempFile("auditoria_", ".xlsx");
            try (FileOutputStream fileOut = new FileOutputStream(tempFile)) {
                workbook.write(fileOut);
            }
            workbook.close();
            
            logger.info("✅ Archivo Excel generado: {} registros", registros.size());
            return tempFile;
            
        } catch (Exception e) {
            logger.error("❌ Error al generar archivo Excel", e);
            return null;
        }
    }
    
    /**
     * Genera el HTML del reporte de auditoría.
     */
    private String generarHtmlReporte(ArrayList<AuditoriaLog> registros, int diasMantener) {
        StringBuilder html = new StringBuilder();
        java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        
        // Calcular estadísticas del reporte
        int totalExitosos = (int) registros.stream().filter(r -> "EXITOSO".equals(r.getEstado())).count();
        int totalFallidos = (int) registros.stream().filter(r -> "FALLIDO".equals(r.getEstado())).count();
        
        html.append("<!DOCTYPE html>");
        html.append("<html lang='es'>");
        html.append("<head>");
        html.append("<meta charset='UTF-8'>");
        html.append("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        html.append("<style>");
        html.append("body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #edf6f9; margin: 0; padding: 20px; }");
        html.append(".container { max-width: 900px; margin: 0 auto; background-color: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); overflow: hidden; }");
        html.append(".header { background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%); color: white; padding: 30px; text-align: center; }");
        html.append(".header h1 { margin: 0; font-size: 28px; font-weight: 600; }");
        html.append(".header p { margin: 10px 0 0 0; opacity: 0.9; font-size: 14px; }");
        html.append(".stats { display: flex; justify-content: space-around; padding: 20px; background-color: #f8f9fa; }");
        html.append(".stat-box { text-align: center; flex: 1; padding: 15px; }");
        html.append(".stat-box h3 { margin: 0; color: #495057; font-size: 14px; text-transform: uppercase; font-weight: 600; }");
        html.append(".stat-box p { margin: 10px 0 0 0; font-size: 32px; font-weight: bold; color: #00a896; }");
        html.append(".content { padding: 30px; }");
        html.append(".warning-box { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin-bottom: 20px; border-radius: 5px; }");
        html.append(".warning-box h3 { margin: 0 0 10px 0; color: #856404; font-size: 16px; }");
        html.append(".warning-box p { margin: 0; color: #856404; font-size: 14px; line-height: 1.6; }");
        html.append(".info-box { background-color: #e7f6f5; border-left: 4px solid #00a896; padding: 15px; margin-bottom: 20px; border-radius: 5px; }");
        html.append(".info-box h3 { margin: 0 0 10px 0; color: #028f80; font-size: 16px; }");
        html.append(".info-box p { margin: 0; color: #028f80; font-size: 14px; line-height: 1.6; }");
        html.append(".footer { background-color: #f8f9fa; padding: 20px; text-align: center; color: #6c757d; font-size: 12px; }");
        html.append(".footer p { margin: 5px 0; }");
        html.append("</style>");
        html.append("</head>");
        html.append("<body>");
        html.append("<div class='container'>");
        
        // Header
        html.append("<div class='header'>");
        html.append("<h1>Reporte de Auditoría - Limpieza Automática</h1>");
        html.append("<p>Sistema de Gestión Telito Bodeguero</p>");
        html.append("<p>Fecha: ").append(formatter.format(new java.util.Date())).append("</p>");
        html.append("</div>");
        
        // Estadísticas
        html.append("<div class='stats'>");
        html.append("<div class='stat-box'><h3>Total Registros</h3><p>").append(registros.size()).append("</p></div>");
        html.append("<div class='stat-box'><h3>Exitosos</h3><p style='color: #28a745;'>").append(totalExitosos).append("</p></div>");
        html.append("<div class='stat-box'><h3>Fallidos</h3><p style='color: #dc3545;'>").append(totalFallidos).append("</p></div>");
        html.append("<div class='stat-box'><h3>Días Antigüedad</h3><p style='color: #ffc107;'>").append(diasMantener).append("+</p></div>");
        html.append("</div>");
        
        // Contenido
        html.append("<div class='content'>");
        
        // Warning box
        html.append("<div class='warning-box'>");
        html.append("<h3>Aviso de Limpieza Automática</h3>");
        html.append("<p>Este reporte contiene los registros de auditoría que fueron <strong>eliminados automáticamente</strong> ");
        html.append("por tener más de <strong>").append(diasMantener).append(" días</strong> de antigüedad. ");
        html.append("Los registros se conservan por correo como respaldo histórico.</p>");
        html.append("</div>");
        
        // Info box para Excel
        html.append("<div class='info-box'>");
        html.append("<h3>Archivo Adjunto: Excel</h3>");
        html.append("<p>Los <strong>").append(registros.size()).append(" registros eliminados</strong> se encuentran detallados en el archivo Excel adjunto a este correo. ");
        html.append("El archivo incluye todas las columnas: ID, Fecha, Usuario, Acción, Módulo, Descripción, Estado, IP y User Agent.</p>");
        html.append("<ul style='margin: 10px 0 0 20px; color: #028f80;'>");
        html.append("<li>Total exitosos: <strong>").append(totalExitosos).append("</strong></li>");
        html.append("<li>Total fallidos: <strong>").append(totalFallidos).append("</strong></li>");
        html.append("<li>Periodo eliminado: Registros mayores a ").append(diasMantener).append(" días</li>");
        html.append("</ul>");
        html.append("</div>");
        
        html.append("</div>");
        
        // Footer
        html.append("<div class='footer'>");
        html.append("<p><strong>Telito Bodeguero</strong> - Sistema de Gestión Integral</p>");
        html.append("<p>Este es un correo automático generado por el sistema. No responder.</p>");
        html.append("<p>Para consultas contactar al administrador del sistema.</p>");
        html.append("</div>");
        
        html.append("</div>");
        html.append("</body>");
        html.append("</html>");
        
        return html.toString();
    }
    
    /**
     * Clase para almacenar el resultado de una operación de limpieza.
     */
    public static class ResultadoLimpieza {
        public boolean exito;
        public String mensaje;
        public int registrosTotalesAntes;
        public int registrosTotalesDespues;
        public int registrosAEliminar;
        public int registrosEliminados;
        public boolean reporteEnviado;
        public long espacioLiberadoKB;
        public LocalDateTime fechaEjecucion;
        
        @Override
        public String toString() {
            return String.format(
                "ResultadoLimpieza{exito=%s, registrosAntes=%d, registrosDespues=%d, eliminados=%d, reporteEnviado=%s, espacioLiberado=%dKB}",
                exito, registrosTotalesAntes, registrosTotalesDespues, registrosEliminados, reporteEnviado, espacioLiberadoKB
            );
        }
    }
}
