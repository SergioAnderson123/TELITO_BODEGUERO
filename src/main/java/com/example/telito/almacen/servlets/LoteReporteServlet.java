package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.daos.LoteDao;
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

@WebServlet(name = "LoteReporteServlet", value = "/almacen/LoteReporteServlet")
public class LoteReporteServlet extends HttpServlet {

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

    private void exportarExcel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        LoteDao loteDao = new LoteDao();

        // Obtener todos los lotes registrados sin paginación
        ArrayList<Lote> listaLotes = loteDao.listarTodosLotesRegistrados();

        String filtrosInfo = "Todos los lotes registrados";

        String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String nombreArchivo = "Reporte_Lotes_Almacen_" + fecha + ".xlsx";

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");
        response.setCharacterEncoding("UTF-8");

        try (OutputStream out = response.getOutputStream()) {
            ExcelUtil.generarExcelLotesAlmacen(listaLotes, out, filtrosInfo);
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

        request.getRequestDispatcher("/almacen/enviar-reporte-lotes.jsp")
            .forward(request, response);
    }

    private void enviarPorCorreo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String emailDestino = request.getParameter("email_destino");
        String asunto = request.getParameter("asunto");
        String mensaje = request.getParameter("mensaje");

        if (emailDestino == null || emailDestino.trim().isEmpty()) {
            session.setAttribute("errorMsg", "El email de destino es obligatorio.");
            response.sendRedirect(request.getContextPath() + "/almacen/LoteReporteServlet?action=formEnviar");
            return;
        }

        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        if (!emailDestino.matches(emailRegex)) {
            session.setAttribute("errorMsg", "El formato del email no es válido.");
            response.sendRedirect(request.getContextPath() + "/almacen/LoteReporteServlet?action=formEnviar");
            return;
        }

        LoteDao loteDao = new LoteDao();

        // Obtener todos los lotes registrados
        ArrayList<Lote> listaLotes = loteDao.listarTodosLotesRegistrados();

        String filtrosInfo = "Todos los lotes registrados";

        File tempFile = null;
        try {
            String tempDir = System.getProperty("java.io.tmpdir");
            File tempDirFile = new File(tempDir);
            if (!tempDirFile.exists()) {
                tempDirFile.mkdirs();
            }

            String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String nombreArchivo = "Reporte_Lotes_Almacen_" + fecha + ".xlsx";
            tempFile = new File(tempDirFile, nombreArchivo);

            try (FileOutputStream fos = new FileOutputStream(tempFile)) {
                ExcelUtil.generarExcelLotesAlmacen(listaLotes, fos, filtrosInfo);
                fos.flush();
            }

            String asuntoFinal = (asunto != null && !asunto.trim().isEmpty()) ?
                asunto : "Reporte de Lotes - Almacén - TELITO BODEGUERO";

            // Calcular estadísticas
            int totalLotes = listaLotes.size();
            int totalStock = 0;
            int totalPaquetes = 0;
            for (Lote lote : listaLotes) {
                totalStock += lote.getStockActual();
                totalPaquetes += lote.getPaquetesDisponibles();
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
                            <h2>📦 Reporte de Lotes - Almacén</h2>
                        </div>
                        <div class="content">
                            <p>Estimado/a,</p>
                            <p>Se adjunta el reporte de Lotes del Almacén generado desde el sistema <strong>TELITO BODEGUERO</strong>.</p>

                            <div class="info-box">
                                <h3 style="margin-top: 0; color: #006d77;">📊 Información del Reporte</h3>
                                <div class="stats-box">
                                    <strong>Total de lotes:</strong> %d
                                </div>
                                <div class="stats-box">
                                    <strong>Stock total:</strong> %d unidades
                                </div>
                                <div class="stats-box">
                                    <strong>Paquetes totales:</strong> %d paquetes
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
                    totalLotes,
                    totalStock,
                    totalPaquetes,
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

        response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
    }
}

