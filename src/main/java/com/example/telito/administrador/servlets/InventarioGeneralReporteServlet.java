package com.example.telito.administrador.servlets;

import com.example.telito.logistica.beans.InventarioBean;
import com.example.telito.logistica.daos.InventarioDao;
import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.administrador.beans.Producto;
import com.example.telito.administrador.daos.ProductoDAO;
import com.example.telito.util.AuthorizationHelper;
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
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

/**
 * Servlet para manejar la exportación de reportes del Inventario General a Excel
 * y el envío de estos reportes por correo electrónico.
 * Genera un Excel con múltiples hojas: Logística, Almacén y Productores.
 */
@WebServlet(name = "InventarioGeneralReporteServlet", value = "/administrador/InventarioGeneralReporteServlet")
public class InventarioGeneralReporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Verificar que el usuario tenga rol de administrador
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a InventarioGeneralReporteServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
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
        // Verificar que el usuario tenga rol de administrador
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a InventarioGeneralReporteServlet (POST) desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        String action = request.getParameter("action");
        if ("enviar".equals(action)) {
            enviarPorCorreo(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
        }
    }
    
    /**
     * Exporta el inventario general a Excel y lo descarga.
     * El Excel contiene 3 hojas: Logística, Almacén y Productores.
     */
    private void exportarExcel(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        // Obtener todas las listas
        InventarioDao inventarioDao = new InventarioDao();
        LoteDao loteDao = new LoteDao();
        ProductoDAO productoDAO = new ProductoDAO();
        
        ArrayList<InventarioBean> listaLogistica = inventarioDao.obtenerInventarioAgrupado(null, null);
        ArrayList<Lote> listaAlmacen = loteDao.listarTodosLotesRegistrados();
        ArrayList<Producto> listaProductores = productoDAO.listarProductos();
        
        // Construir texto de filtros aplicados
        String filtrosInfo = "Inventario completo - Todas las secciones";
        
        // Generar nombre de archivo con fecha
        String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String nombreArchivo = "Reporte_InventarioGeneral_" + fecha + ".xlsx";
        
        // Configurar respuesta para descargar Excel
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");
        response.setCharacterEncoding("UTF-8");
        
        // Generar Excel
        try (OutputStream out = response.getOutputStream()) {
            ExcelUtil.generarExcelInventarioGeneral(listaLogistica, listaAlmacen, listaProductores, out, filtrosInfo);
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
        
        request.getRequestDispatcher("/administrador/enviar-reporte-inventario.jsp")
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
        
        // Validaciones
        if (emailDestino == null || emailDestino.trim().isEmpty()) {
            session.setAttribute("errorMsg", "El email de destino es obligatorio.");
            response.sendRedirect(request.getContextPath() + "/administrador/InventarioGeneralReporteServlet?action=formEnviar");
            return;
        }
        
        // Validar formato de email
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        if (!emailDestino.matches(emailRegex)) {
            session.setAttribute("errorMsg", "El formato del email no es válido.");
            response.sendRedirect(request.getContextPath() + "/administrador/InventarioGeneralReporteServlet?action=formEnviar");
            return;
        }
        
        // Obtener todas las listas
        InventarioDao inventarioDao = new InventarioDao();
        LoteDao loteDao = new LoteDao();
        ProductoDAO productoDAO = new ProductoDAO();
        
        ArrayList<InventarioBean> listaLogistica = inventarioDao.obtenerInventarioAgrupado(null, null);
        ArrayList<Lote> listaAlmacen = loteDao.listarTodosLotesRegistrados();
        ArrayList<Producto> listaProductores = productoDAO.listarProductos();
        
        // Construir información de filtros
        String filtrosInfo = "Inventario completo - Todas las secciones";
        
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
            String nombreArchivo = "Reporte_InventarioGeneral_" + fecha + ".xlsx";
            tempFile = new File(tempDirFile, nombreArchivo);
            
            // Generar Excel en archivo temporal
            try (FileOutputStream fos = new FileOutputStream(tempFile)) {
                ExcelUtil.generarExcelInventarioGeneral(listaLogistica, listaAlmacen, listaProductores, fos, filtrosInfo);
                fos.flush();
            }
            
            // Preparar mensaje HTML
            String asuntoFinal = (asunto != null && !asunto.trim().isEmpty()) ? 
                asunto : "Reporte de Inventario General - TELITO BODEGUERO";
            
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
                        .section-box { background: white; padding: 15px; border-radius: 5px; 
                                      margin: 10px 0; border-left: 4px solid #83c5be; }
                        .footer { margin-top: 20px; padding-top: 15px; border-top: 1px solid #e9ecef; 
                                 font-size: 12px; color: #6c757d; text-align: center; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h2>📊 Reporte de Inventario General</h2>
                        </div>
                        <div class="content">
                            <p>Estimado/a,</p>
                            <p>Se adjunta el reporte de Inventario General generado desde el sistema <strong>TELITO BODEGUERO</strong>.</p>
                            
                            <div class="info-box">
                                <h3 style="margin-top: 0; color: #006d77;">📋 Información del Reporte</h3>
                                <div class="section-box">
                                    <strong>🚚 Logística:</strong> %d productos
                                </div>
                                <div class="section-box">
                                    <strong>🏭 Almacén:</strong> %d lotes
                                </div>
                                <div class="section-box">
                                    <strong>🌱 Productores:</strong> %d productos
                                </div>
                                <p style="margin-top: 15px;"><strong>Fecha de generación:</strong> %s</p>
                            </div>
                            
                            %s
                            
                            <p><strong>Nota:</strong> El archivo Excel contiene <strong>3 hojas separadas</strong>:</p>
                            <ul>
                                <li><strong>Logística:</strong> Inventario agrupado por producto con precios y estados de stock</li>
                                <li><strong>Almacén:</strong> Lotes registrados con ubicación, stock y fechas de vencimiento</li>
                                <li><strong>Productores:</strong> Productos con categorías y stock total</li>
                            </ul>
                            <p>Cada hoja incluye filtros automáticos que puedes usar para ordenar y filtrar los datos directamente en Excel.</p>
                            
                            <div class="footer">
                                <p>Este es un correo automático generado por el sistema TELITO BODEGUERO.</p>
                            </div>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(
                    listaLogistica.size(),
                    listaAlmacen.size(),
                    listaProductores.size(),
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
                session.setAttribute("mensaje", 
                    "Reporte enviado exitosamente a " + emailDestino);
                session.setAttribute("tipoMensaje", "success");
            } else {
                session.setAttribute("mensaje", 
                    "Error al enviar el reporte. Verifica la configuración de correo electrónico.");
                session.setAttribute("tipoMensaje", "danger");
            }
            
        } catch (Exception e) {
            System.err.println("Error al enviar reporte por correo: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("mensaje", 
                "Error al generar o enviar el reporte: " + e.getMessage());
            session.setAttribute("tipoMensaje", "danger");
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
        
        // Redirigir al inventario general
        response.sendRedirect(request.getContextPath() + "/administrador/inventario-general");
    }
}

