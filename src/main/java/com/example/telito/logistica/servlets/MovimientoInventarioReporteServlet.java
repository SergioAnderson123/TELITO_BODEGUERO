package com.example.telito.logistica.servlets;

import com.example.telito.logistica.beans.MovimientoInventarioBean;
import com.example.telito.logistica.daos.MovimientoInventarioDao;
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

@WebServlet(name = "MovimientoInventarioReporteServlet", value = "/logistica/MovimientoInventarioReporteServlet")
public class MovimientoInventarioReporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Verificar que el usuario tenga rol de logística
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederLogistica(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de logística intentó acceder a MovimientoInventarioReporteServlet desde: " + 
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
        // Verificar que el usuario tenga rol de logística
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederLogistica(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de logística intentó acceder a MovimientoInventarioReporteServlet (POST) desde: " + 
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

    private void exportarExcel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        MovimientoInventarioDao movimientoDao = new MovimientoInventarioDao();

        // Obtener parámetros de filtros de la URL
        String busqueda = request.getParameter("busqueda");
        String tipo = request.getParameter("tipo");
        String fechaDesde = request.getParameter("fecha_desde");
        String fechaHasta = request.getParameter("fecha_hasta");

        // Obtener todos los registros sin paginación
        ArrayList<MovimientoInventarioBean> listaMovimientos = movimientoDao.listarTodosMovimientos(busqueda, tipo, fechaDesde, fechaHasta);

        // Construir información de filtros
        StringBuilder filtrosInfo = new StringBuilder();
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            filtrosInfo.append("Búsqueda: ").append(busqueda);
        }
        if (tipo != null && !tipo.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Tipo: ").append(tipo);
        }
        if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Fecha Desde: ").append(fechaDesde);
        }
        if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Fecha Hasta: ").append(fechaHasta);
        }
        if (filtrosInfo.length() == 0) {
            filtrosInfo.append("Todos los movimientos");
        }

        String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String nombreArchivo = "Reporte_MovimientosInventario_" + fecha + ".xlsx";

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");
        response.setCharacterEncoding("UTF-8");

        try (OutputStream out = response.getOutputStream()) {
            ExcelUtil.generarExcelMovimientosInventario(listaMovimientos, out, filtrosInfo.toString());
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

        // Preservar parámetros de filtros en el formulario
        String busqueda = request.getParameter("busqueda");
        String tipo = request.getParameter("tipo");
        String fechaDesde = request.getParameter("fecha_desde");
        String fechaHasta = request.getParameter("fecha_hasta");
        
        if (busqueda != null) {
            request.setAttribute("busqueda", busqueda);
        }
        if (tipo != null) {
            request.setAttribute("tipo", tipo);
        }
        if (fechaDesde != null) {
            request.setAttribute("fecha_desde", fechaDesde);
        }
        if (fechaHasta != null) {
            request.setAttribute("fecha_hasta", fechaHasta);
        }

        request.getRequestDispatcher("/logistica/enviar-reporte-movimientos.jsp")
            .forward(request, response);
    }

    private void enviarPorCorreo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String emailDestino = request.getParameter("email_destino");
        String asunto = request.getParameter("asunto");
        String mensaje = request.getParameter("mensaje");

        // Obtener parámetros de filtros (si vienen del formulario)
        String busqueda = request.getParameter("busqueda");
        String tipo = request.getParameter("tipo");
        String fechaDesde = request.getParameter("fecha_desde");
        String fechaHasta = request.getParameter("fecha_hasta");

        if (emailDestino == null || emailDestino.trim().isEmpty()) {
            session.setAttribute("errorMsg", "El email de destino es obligatorio.");
            String redirectUrl = request.getContextPath() + "/logistica/MovimientoInventarioReporteServlet?action=formEnviar";
            if (busqueda != null) redirectUrl += "&busqueda=" + busqueda;
            if (tipo != null) redirectUrl += "&tipo=" + tipo;
            if (fechaDesde != null) redirectUrl += "&fecha_desde=" + fechaDesde;
            if (fechaHasta != null) redirectUrl += "&fecha_hasta=" + fechaHasta;
            response.sendRedirect(redirectUrl);
            return;
        }

        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        if (!emailDestino.matches(emailRegex)) {
            session.setAttribute("errorMsg", "El formato del email no es válido.");
            String redirectUrl = request.getContextPath() + "/logistica/MovimientoInventarioReporteServlet?action=formEnviar";
            if (busqueda != null) redirectUrl += "&busqueda=" + busqueda;
            if (tipo != null) redirectUrl += "&tipo=" + tipo;
            if (fechaDesde != null) redirectUrl += "&fecha_desde=" + fechaDesde;
            if (fechaHasta != null) redirectUrl += "&fecha_hasta=" + fechaHasta;
            response.sendRedirect(redirectUrl);
            return;
        }

        MovimientoInventarioDao movimientoDao = new MovimientoInventarioDao();

        // Obtener todos los registros sin paginación con los mismos filtros
        ArrayList<MovimientoInventarioBean> listaMovimientos = movimientoDao.listarTodosMovimientos(busqueda, tipo, fechaDesde, fechaHasta);

        // Construir información de filtros
        StringBuilder filtrosInfo = new StringBuilder();
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            filtrosInfo.append("Búsqueda: ").append(busqueda);
        }
        if (tipo != null && !tipo.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Tipo: ").append(tipo);
        }
        if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Fecha Desde: ").append(fechaDesde);
        }
        if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Fecha Hasta: ").append(fechaHasta);
        }
        if (filtrosInfo.length() == 0) {
            filtrosInfo.append("Todos los movimientos");
        }

        File tempFile = null;
        try {
            String tempDir = System.getProperty("java.io.tmpdir");
            File tempDirFile = new File(tempDir);
            if (!tempDirFile.exists()) {
                tempDirFile.mkdirs();
            }

            String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String nombreArchivo = "Reporte_MovimientosInventario_" + fecha + ".xlsx";
            tempFile = new File(tempDirFile, nombreArchivo);

            try (FileOutputStream fos = new FileOutputStream(tempFile)) {
                ExcelUtil.generarExcelMovimientosInventario(listaMovimientos, fos, filtrosInfo.toString());
                fos.flush();
            }

            String asuntoFinal = (asunto != null && !asunto.trim().isEmpty()) ?
                asunto : "Reporte de Movimientos de Inventario - TELITO BODEGUERO";

            // Calcular estadísticas
            int totalEntradas = 0;
            int totalSalidas = 0;
            int totalAjustes = 0;
            int cantidadTotalEntradas = 0;
            int cantidadTotalSalidas = 0;
            int cantidadTotalAjustes = 0;

            for (MovimientoInventarioBean movimiento : listaMovimientos) {
                String tipoMov = movimiento.getTipo();
                int cantidad = movimiento.getCantidad();
                
                if (tipoMov != null) {
                    if (tipoMov.equalsIgnoreCase("Entrada")) {
                        totalEntradas++;
                        cantidadTotalEntradas += cantidad;
                    } else if (tipoMov.equalsIgnoreCase("Salida")) {
                        totalSalidas++;
                        cantidadTotalSalidas += cantidad;
                    } else if (tipoMov.equalsIgnoreCase("Ajuste")) {
                        totalAjustes++;
                        cantidadTotalAjustes += cantidad;
                    }
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
                        .summary-box { background: #f0f9ff; padding: 15px; border-radius: 5px;
                                      margin: 10px 0; border-left: 4px solid #0ea5e9; }
                        .footer { margin-top: 20px; padding-top: 15px; border-top: 1px solid #e9ecef;
                                 font-size: 12px; color: #6c757d; text-align: center; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h2>🔄 Reporte de Movimientos de Inventario</h2>
                        </div>
                        <div class="content">
                            <p>Estimado/a,</p>
                            <p>Se adjunta el reporte de Movimientos de Inventario generado desde el sistema <strong>TELITO BODEGUERO</strong>.</p>

                            <div class="info-box">
                                <h3 style="margin-top: 0; color: #006d77;">📊 Información del Reporte</h3>
                                <div class="stats-box">
                                    <strong>Total de movimientos:</strong> %d
                                </div>
                                <div class="stats-box">
                                    <strong>Filtros aplicados:</strong> %s
                                </div>
                                <p style="margin-top: 15px;"><strong>Fecha de generación:</strong> %s</p>
                            </div>

                            <div class="summary-box">
                                <h4 style="margin-top: 0; color: #0ea5e9;">📈 Resumen por Tipo de Movimiento</h4>
                                <div class="stats-box">
                                    <strong>✅ Entradas:</strong> %d registros, Cantidad total: %d
                                </div>
                                <div class="stats-box">
                                    <strong>❌ Salidas:</strong> %d registros, Cantidad total: %d
                                </div>
                                <div class="stats-box">
                                    <strong>⚙️ Ajustes:</strong> %d registros, Cantidad total: %d
                                </div>
                                <div class="stats-box" style="border-left: 4px solid #006d77;">
                                    <strong>📊 Total General:</strong> %d registros, Cantidad total: %d
                                </div>
                            </div>

                            %s

                            <p><strong>Nota:</strong> El archivo Excel incluye filtros automáticos y un resumen detallado por tipo de movimiento que puedes usar para análisis y auditoría.</p>

                            <div class="footer">
                                <p>Este es un correo automático generado por el sistema TELITO BODEGUERO.</p>
                            </div>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(
                    listaMovimientos.size(),
                    filtrosInfo.toString(),
                    new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()),
                    totalEntradas, cantidadTotalEntradas,
                    totalSalidas, cantidadTotalSalidas,
                    totalAjustes, cantidadTotalAjustes,
                    listaMovimientos.size(),
                    cantidadTotalEntradas + cantidadTotalSalidas + cantidadTotalAjustes,
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

        // Redirigir con los mismos filtros
        String redirectUrl = request.getContextPath() + "/MovimientoProductoServlet";
        StringBuilder params = new StringBuilder();
        if (busqueda != null) params.append("?busqueda=").append(busqueda);
        if (tipo != null) params.append(params.length() == 0 ? "?" : "&").append("tipo=").append(tipo);
        if (fechaDesde != null) params.append(params.length() == 0 ? "?" : "&").append("fecha_desde=").append(fechaDesde);
        if (fechaHasta != null) params.append(params.length() == 0 ? "?" : "&").append("fecha_hasta=").append(fechaHasta);
        response.sendRedirect(redirectUrl + params.toString());
    }
}

