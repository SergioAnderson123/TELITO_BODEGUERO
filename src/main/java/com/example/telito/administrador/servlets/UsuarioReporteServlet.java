package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.util.ExcelUtil;
import com.example.telito.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Date;
import java.text.SimpleDateFormat;

/**
 * Servlet para manejar la exportación de reportes de usuarios a Excel
 * y el envío de estos reportes por correo electrónico.
 */
@WebServlet(name = "UsuarioReporteServlet", value = "/UsuarioReporteServlet")
public class UsuarioReporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "exportar";
        }
        
        switch (action) {
            case "exportar":
                exportarExcel(request, response);
                break;
            case "formEnviar":
                mostrarFormularioEnvio(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if ("enviar".equals(action)) {
            enviarPorCorreo(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
        }
    }
    
    /**
     * Exporta la lista de usuarios a Excel y la descarga.
     */
    private void exportarExcel(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        // Obtener filtros actuales
        String busqueda = request.getParameter("busqueda");
        String rolId = request.getParameter("rol");
        String estado = request.getParameter("estado");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        
        // Obtener todos los usuarios con los filtros aplicados
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        ArrayList<Usuario> listaUsuarios = usuarioDAO.listarTodosUsuarios(
            busqueda, rolId, estado, sortBy, sortOrder
        );
        
        // Construir texto de filtros aplicados
        StringBuilder filtrosInfo = new StringBuilder();
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            filtrosInfo.append("Búsqueda: ").append(busqueda).append("; ");
        }
        if (rolId != null && !rolId.trim().isEmpty()) {
            String nombreRol = usuarioDAO.obtenerNombreRolPorId(Integer.parseInt(rolId));
            filtrosInfo.append("Rol: ").append(nombreRol != null ? nombreRol : rolId).append("; ");
        }
        if (estado != null && !estado.trim().isEmpty()) {
            filtrosInfo.append("Estado: ").append("1".equals(estado) ? "Activo" : "Inactivo").append("; ");
        }
        if (filtrosInfo.length() == 0) {
            filtrosInfo.append("Sin filtros aplicados");
        } else {
            // Remover último "; "
            filtrosInfo.setLength(filtrosInfo.length() - 2);
        }
        
        // Generar nombre de archivo con fecha
        String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String nombreArchivo = "Reporte_Usuarios_" + fecha + ".xlsx";
        
        // Configurar respuesta para descargar Excel
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");
        response.setCharacterEncoding("UTF-8");
        
        // Generar Excel
        try (OutputStream out = response.getOutputStream()) {
            ExcelUtil.generarExcelUsuarios(listaUsuarios, out, filtrosInfo.toString());
            out.flush();
        } catch (Exception e) {
            System.err.println("Error al generar Excel: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Error al generar el archivo Excel: " + e.getMessage());
        }
    }
    
    /**
     * Muestra el formulario para enviar el reporte por correo.
     */
    private void mostrarFormularioEnvio(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Mantener los filtros actuales
        String busqueda = request.getParameter("busqueda");
        String rolId = request.getParameter("rol");
        String estado = request.getParameter("estado");
        
        request.setAttribute("busqueda", busqueda);
        request.setAttribute("rol", rolId);
        request.setAttribute("estado", estado);
        
        request.getRequestDispatcher("/administrador/enviar-reporte-usuarios.jsp")
            .forward(request, response);
    }
    
    /**
     * Genera el Excel y lo envía por correo electrónico.
     */
    private void enviarPorCorreo(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Obtener parámetros del formulario
        String emailDestino = request.getParameter("email_destino");
        String asunto = request.getParameter("asunto");
        String mensaje = request.getParameter("mensaje");
        
        // Obtener filtros actuales
        String busqueda = request.getParameter("busqueda");
        String rolId = request.getParameter("rol");
        String estado = request.getParameter("estado");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        
        // Validaciones
        if (emailDestino == null || emailDestino.trim().isEmpty()) {
            session.setAttribute("errorMsg", "El email de destino es obligatorio.");
            response.sendRedirect(request.getContextPath() + "/UsuarioReporteServlet?action=formEnviar" +
                (busqueda != null ? "&busqueda=" + busqueda : "") +
                (rolId != null ? "&rol=" + rolId : "") +
                (estado != null ? "&estado=" + estado : ""));
            return;
        }
        
        // Validar formato de email
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        if (!emailDestino.matches(emailRegex)) {
            session.setAttribute("errorMsg", "El formato del email no es válido.");
            response.sendRedirect(request.getContextPath() + "/UsuarioReporteServlet?action=formEnviar" +
                (busqueda != null ? "&busqueda=" + busqueda : "") +
                (rolId != null ? "&rol=" + rolId : "") +
                (estado != null ? "&estado=" + estado : ""));
            return;
        }
        
        // Obtener usuarios
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        ArrayList<Usuario> listaUsuarios = usuarioDAO.listarTodosUsuarios(
            busqueda, rolId, estado, sortBy, sortOrder
        );
        
        // Construir información de filtros
        StringBuilder filtrosInfo = new StringBuilder();
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            filtrosInfo.append("Búsqueda: ").append(busqueda).append("; ");
        }
        if (rolId != null && !rolId.trim().isEmpty()) {
            String nombreRol = usuarioDAO.obtenerNombreRolPorId(Integer.parseInt(rolId));
            filtrosInfo.append("Rol: ").append(nombreRol != null ? nombreRol : rolId).append("; ");
        }
        if (estado != null && !estado.trim().isEmpty()) {
            filtrosInfo.append("Estado: ").append("1".equals(estado) ? "Activo" : "Inactivo").append("; ");
        }
        if (filtrosInfo.length() == 0) {
            filtrosInfo.append("Sin filtros aplicados");
        } else {
            filtrosInfo.setLength(filtrosInfo.length() - 2);
        }
        
        // Crear archivo temporal
        File tempFile = null;
        try {
            // Crear directorio temporal si no existe
            String tempDir = System.getProperty("java.io.tmpdir");
            File tempDirFile = new File(tempDir);
            if (!tempDirFile.exists()) {
                tempDirFile.mkdirs();
            }
            
            // Generar nombre de archivo
            String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String nombreArchivo = "Reporte_Usuarios_" + fecha + ".xlsx";
            tempFile = new File(tempDirFile, nombreArchivo);
            
            // Generar Excel en archivo temporal
            try (FileOutputStream fos = new FileOutputStream(tempFile)) {
                ExcelUtil.generarExcelUsuarios(listaUsuarios, fos, filtrosInfo.toString());
                fos.flush();
            }
            
            // Preparar mensaje HTML
            String asuntoFinal = (asunto != null && !asunto.trim().isEmpty()) ? 
                asunto : "Reporte de Usuarios - TELITO BODEGUERO";
            
            String mensajeHTML = """
                <html>
                <head>
                    <meta charset="UTF-8">
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: #2b2d42; }
                        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                        .header { background: linear-gradient(160deg, #006d77 0%%, #055e68 100%%); 
                                 color: white; padding: 25px; border-radius: 8px 8px 0 0; text-align: center; }
                        .content { background: #edf6f9; padding: 25px; border-radius: 0 0 8px 8px; }
                        .info-box { background: white; padding: 20px; border-radius: 5px; 
                                   margin: 15px 0; border-left: 4px solid #006d77; }
                        .footer { margin-top: 20px; padding-top: 15px; border-top: 1px solid #e9ecef; 
                                 font-size: 12px; color: #6c757d; text-align: center; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h2>📊 Reporte de Usuarios</h2>
                        </div>
                        <div class="content">
                            <p>Estimado/a,</p>
                            <p>Se adjunta el reporte de usuarios generado desde el sistema <strong>TELITO BODEGUERO</strong>.</p>
                            
                            <div class="info-box">
                                <h3 style="margin-top: 0; color: #006d77;">📋 Información del Reporte</h3>
                                <p><strong>Total de usuarios:</strong> %d</p>
                                <p><strong>Filtros aplicados:</strong> %s</p>
                                <p><strong>Fecha de generación:</strong> %s</p>
                            </div>
                            
                            %s
                            
                            <p><strong>Nota:</strong> El archivo Excel incluye filtros automáticos que puedes usar para ordenar y filtrar los datos directamente en Excel.</p>
                            
                            <div class="footer">
                                <p>Este es un correo automático generado por el sistema TELITO BODEGUERO.</p>
                            </div>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(
                    listaUsuarios.size(),
                    filtrosInfo.toString(),
                    new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()),
                    mensaje != null && !mensaje.trim().isEmpty() ? 
                        "<p><strong>Mensaje adicional:</strong></p><p>" + mensaje.replace("\n", "<br>") + "</p>" : ""
                );
            
            // Enviar correo
            boolean enviado = EmailUtil.sendSystemAlertHTMLWithAttachment(
                emailDestino,
                asuntoFinal,
                mensajeHTML,
                tempFile,
                nombreArchivo
            );
            
            if (enviado) {
                session.setAttribute("successMsg", 
                    "Reporte enviado exitosamente a " + emailDestino);
            } else {
                session.setAttribute("errorMsg", 
                    "Error al enviar el reporte. Verifica la configuración de correo electrónico.");
            }
            
        } catch (Exception e) {
            System.err.println("Error al enviar reporte por correo: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMsg", 
                "Error al generar o enviar el reporte: " + e.getMessage());
        } finally {
            // Eliminar archivo temporal
            if (tempFile != null && tempFile.exists()) {
                try {
                    tempFile.delete();
                } catch (Exception e) {
                    System.err.println("Error al eliminar archivo temporal: " + e.getMessage());
                }
            }
        }
        
        // Redirigir a la gestión de usuarios
        response.sendRedirect(request.getContextPath() + "/UsuarioServlet?action=listar" +
            (busqueda != null ? "&busqueda=" + busqueda : "") +
            (rolId != null ? "&rol=" + rolId : "") +
            (estado != null ? "&estado=" + estado : ""));
    }
}

