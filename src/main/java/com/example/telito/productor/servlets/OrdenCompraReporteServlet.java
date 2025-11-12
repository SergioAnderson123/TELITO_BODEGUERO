package com.example.telito.productor.servlets;

import com.example.telito.productor.daos.OrdenCompraDao;
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
import java.util.Date;
import java.util.List;

@WebServlet(name = "ProductorOrdenCompraReporteServlet", value = "/productor/OrdenCompraReporteServlet")
public class OrdenCompraReporteServlet extends HttpServlet {

    @Override
    public void init() throws ServletException {
        super.init();
        System.out.println("=== OrdenCompraReporteServlet inicializado correctamente ===");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== OrdenCompraReporteServlet.doGet() llamado ===");
        String action = request.getParameter("action");
        System.out.println("Action recibido: " + action);
        
        if (action == null) {
            action = "exportar";
        }

        switch (action) {
            case "exportar":
                System.out.println("Ejecutando exportarExcel...");
                exportarExcel(request, response);
                break;
            case "formEnviar":
                System.out.println("Ejecutando mostrarFormularioEnvio...");
                mostrarFormularioEnvio(request, response);
                break;
            default:
                System.out.println("Acción no válida: " + action);
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== OrdenCompraReporteServlet.doPost() llamado ===");
        String action = request.getParameter("action");
        System.out.println("Action recibido en POST: " + action);
        
        if ("enviar".equals(action)) {
            System.out.println("Ejecutando enviarPorCorreo...");
            enviarPorCorreo(request, response);
        } else {
            System.out.println("Acción no válida en POST: " + action);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
        }
    }

    private void exportarExcel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession();
        com.example.telito.administrador.beans.Usuario usuarioSesion = 
            (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
        
        if (usuarioSesion == null) {
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }

        int idProductor = usuarioSesion.getIdUsuario();
        System.out.println("ID Productor: " + idProductor);
        
        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();

        // Obtener todas las órdenes del productor
        List<Object[]> listaOrdenes = ordenCompraDao.listarOrdenesPorProductor(idProductor);
        System.out.println("Órdenes encontradas: " + listaOrdenes.size());

        String filtrosInfo = "Todas las órdenes";

        String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String nombreArchivo = "Reporte_OrdenesCompra_Productor_" + fecha + ".xlsx";

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");
        response.setCharacterEncoding("UTF-8");

        try (OutputStream out = response.getOutputStream()) {
            // Convertir List a ArrayList para el método de ExcelUtil
            java.util.ArrayList<Object[]> arrayListOrdenes = new java.util.ArrayList<>(listaOrdenes);
            ExcelUtil.generarExcelOrdenesCompraProductor(arrayListOrdenes, out, filtrosInfo);
            out.flush();
        } catch (Exception e) {
            System.err.println("Error al generar Excel: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Error al generar el archivo Excel: " + e.getMessage());
        }
    }

    private void mostrarFormularioEnvio(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== mostrarFormularioEnvio() llamado ===");
        System.out.println("Redirigiendo a: /productor/enviar-reporte-ordenes.jsp");
        
        request.getRequestDispatcher("/productor/enviar-reporte-ordenes.jsp")
            .forward(request, response);
    }

    private void enviarPorCorreo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        com.example.telito.administrador.beans.Usuario usuarioSesion = 
            (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
        
        if (usuarioSesion == null) {
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }

        int idProductor = usuarioSesion.getIdUsuario();
        System.out.println("ID Productor en enviarPorCorreo: " + idProductor);

        String emailDestino = request.getParameter("email_destino");
        String asunto = request.getParameter("asunto");
        String mensaje = request.getParameter("mensaje");
        
        System.out.println("Email destino: " + emailDestino);
        System.out.println("Asunto: " + asunto);

        if (emailDestino == null || emailDestino.trim().isEmpty()) {
            session.setAttribute("errorMsg", "El email de destino es obligatorio.");
            response.sendRedirect(request.getContextPath() + "/productor/OrdenCompraReporteServlet?action=formEnviar");
            return;
        }

        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        if (!emailDestino.matches(emailRegex)) {
            session.setAttribute("errorMsg", "El formato del email no es válido.");
            response.sendRedirect(request.getContextPath() + "/productor/OrdenCompraReporteServlet?action=formEnviar");
            return;
        }

        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();

        // Obtener todas las órdenes del productor
        List<Object[]> listaOrdenes = ordenCompraDao.listarOrdenesPorProductor(idProductor);
        System.out.println("Órdenes encontradas para correo: " + listaOrdenes.size());

        String filtrosInfo = "Todas las órdenes";

        File tempFile = null;
        try {
            String tempDir = System.getProperty("java.io.tmpdir");
            File tempDirFile = new File(tempDir);
            if (!tempDirFile.exists()) {
                tempDirFile.mkdirs();
            }

            String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String nombreArchivo = "Reporte_OrdenesCompra_Productor_" + fecha + ".xlsx";
            tempFile = new File(tempDirFile, nombreArchivo);

            try (FileOutputStream fos = new FileOutputStream(tempFile)) {
                // Convertir List a ArrayList para el método de ExcelUtil
                java.util.ArrayList<Object[]> arrayListOrdenes = new java.util.ArrayList<>(listaOrdenes);
                ExcelUtil.generarExcelOrdenesCompraProductor(arrayListOrdenes, fos, filtrosInfo);
                fos.flush();
            }

            String asuntoFinal = (asunto != null && !asunto.trim().isEmpty()) ?
                asunto : "Reporte de Órdenes de Compra - Productor - TELITO BODEGUERO";

            // Calcular estadísticas
            int totalOrdenes = listaOrdenes.size();
            double montoTotalGeneral = 0.0;
            int ordenesPendientes = 0;
            int ordenesCompletadas = 0;
            
            for (Object[] orden : listaOrdenes) {
                if (orden[4] != null) {
                    montoTotalGeneral += (Double) orden[4]; // monto_total
                }
                String estado = (String) orden[6];
                if ("Pendiente".equals(estado) || "Aprobado".equals(estado)) {
                    ordenesPendientes++;
                } else if ("Recibido".equals(estado)) {
                    ordenesCompletadas++;
                }
            }

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
                        .stats-box { background: white; padding: 15px; border-radius: 5px;
                                    margin: 10px 0; border-left: 4px solid #83c5be; }
                        .footer { margin-top: 20px; padding-top: 15px; border-top: 1px solid #e9ecef;
                                 font-size: 12px; color: #6c757d; text-align: center; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h2>📋 Reporte de Órdenes de Compra - Productor</h2>
                        </div>
                        <div class="content">
                            <p>Estimado/a,</p>
                            <p>Se adjunta el reporte de Órdenes de Compra generado desde el sistema <strong>TELITO BODEGUERO</strong>.</p>

                            <div class="info-box">
                                <h3 style="margin-top: 0; color: #006d77;">📊 Información del Reporte</h3>
                                <div class="stats-box">
                                    <strong>Total de órdenes:</strong> %d
                                </div>
                                <div class="stats-box">
                                    <strong>Órdenes pendientes:</strong> %d
                                </div>
                                <div class="stats-box">
                                    <strong>Órdenes completadas:</strong> %d
                                </div>
                                <div class="stats-box">
                                    <strong>Monto total:</strong> S/. %s
                                </div>
                                <div class="stats-box">
                                    <strong>Filtros aplicados:</strong> %s
                                </div>
                                <p style="margin-top: 15px;"><strong>Fecha de generación:</strong> %s</p>
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
                    totalOrdenes,
                    ordenesPendientes,
                    ordenesCompletadas,
                    String.format("%.2f", montoTotalGeneral),
                    filtrosInfo,
                    new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()),
                    mensaje != null && !mensaje.trim().isEmpty() ?
                        "<p><strong>Mensaje adicional:</strong></p><p>" + mensaje.replace("\n", "<br>") + "</p>" : ""
                );

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
            if (tempFile != null && tempFile.exists()) {
                try {
                    tempFile.delete();
                } catch (Exception e) {
                    System.err.println("Error al eliminar archivo temporal: " + e.getMessage());
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/ProductorServlet?action=ordenesCompra");
    }
}

