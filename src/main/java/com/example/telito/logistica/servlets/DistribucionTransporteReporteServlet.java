package com.example.telito.logistica.servlets;

import com.example.telito.logistica.beans.PlanTransporteBean;
import com.example.telito.logistica.daos.PlanTransporteDao;
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
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "DistribucionTransporteReporteServlet", value = "/logistica/DistribucionTransporteReporteServlet")
public class DistribucionTransporteReporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Verificar que el usuario tenga rol de logística
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederLogistica(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de logística intentó acceder a DistribucionTransporteReporteServlet desde: " + 
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
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de logística intentó acceder a DistribucionTransporteReporteServlet (POST) desde: " + 
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

        PlanTransporteDao planDao = new PlanTransporteDao();

        // Obtener parámetros de filtros de la URL
        String busqueda = request.getParameter("busqueda");
        String conductorId = request.getParameter("conductor");
        String estado = request.getParameter("estado");
        String fechaDesde = request.getParameter("fecha_desde");
        String fechaHasta = request.getParameter("fecha_hasta");

        // Obtener todos los registros agrupados por viaje sin paginación
        ArrayList<PlanTransporteBean> listaPlanes = planDao.listarTodosPlanesAgrupadosPorViaje(
            busqueda, conductorId, estado, fechaDesde, fechaHasta);

        // Construir información de filtros
        StringBuilder filtrosInfo = new StringBuilder();
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            filtrosInfo.append("Búsqueda: ").append(busqueda);
        }
        if (conductorId != null && !conductorId.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Conductor: ").append(conductorId);
        }
        if (estado != null && !estado.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Estado: ").append(estado);
        }
        if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Desde: ").append(fechaDesde);
        }
        if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Hasta: ").append(fechaHasta);
        }
        if (filtrosInfo.length() == 0) {
            filtrosInfo.append("Todos los viajes");
        }

        String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String nombreArchivo = "Reporte_DistribucionTransporte_" + fecha + ".xlsx";

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");
        response.setCharacterEncoding("UTF-8");

        try (OutputStream out = response.getOutputStream()) {
            ExcelUtil.generarExcelDistribucionTransporte(listaPlanes, out, filtrosInfo.toString());
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
        String conductorId = request.getParameter("conductor");
        String estado = request.getParameter("estado");
        String fechaDesde = request.getParameter("fecha_desde");
        String fechaHasta = request.getParameter("fecha_hasta");
        
        if (busqueda != null) {
            request.setAttribute("busqueda", busqueda);
        }
        if (conductorId != null) {
            request.setAttribute("conductor", conductorId);
        }
        if (estado != null) {
            request.setAttribute("estado", estado);
        }
        if (fechaDesde != null) {
            request.setAttribute("fecha_desde", fechaDesde);
        }
        if (fechaHasta != null) {
            request.setAttribute("fecha_hasta", fechaHasta);
        }

        request.getRequestDispatcher("/logistica/enviar-reporte-distribucion.jsp")
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
        String conductorId = request.getParameter("conductor");
        String estado = request.getParameter("estado");
        String fechaDesde = request.getParameter("fecha_desde");
        String fechaHasta = request.getParameter("fecha_hasta");

        if (emailDestino == null || emailDestino.trim().isEmpty()) {
            session.setAttribute("errorMsg", "El email de destino es obligatorio.");
            String redirectUrl = request.getContextPath() + "/logistica/DistribucionTransporteReporteServlet?action=formEnviar";
            if (busqueda != null) redirectUrl += "&busqueda=" + busqueda;
            if (conductorId != null) redirectUrl += "&conductor=" + conductorId;
            if (estado != null) redirectUrl += "&estado=" + estado;
            if (fechaDesde != null) redirectUrl += "&fecha_desde=" + fechaDesde;
            if (fechaHasta != null) redirectUrl += "&fecha_hasta=" + fechaHasta;
            response.sendRedirect(redirectUrl);
            return;
        }

        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        if (!emailDestino.matches(emailRegex)) {
            session.setAttribute("errorMsg", "El formato del email no es válido.");
            String redirectUrl = request.getContextPath() + "/logistica/DistribucionTransporteReporteServlet?action=formEnviar";
            if (busqueda != null) redirectUrl += "&busqueda=" + busqueda;
            if (conductorId != null) redirectUrl += "&conductor=" + conductorId;
            if (estado != null) redirectUrl += "&estado=" + estado;
            if (fechaDesde != null) redirectUrl += "&fecha_desde=" + fechaDesde;
            if (fechaHasta != null) redirectUrl += "&fecha_hasta=" + fechaHasta;
            response.sendRedirect(redirectUrl);
            return;
        }

        PlanTransporteDao planDao = new PlanTransporteDao();

        // Obtener todos los registros agrupados por viaje sin paginación con los mismos filtros
        ArrayList<PlanTransporteBean> listaPlanes = planDao.listarTodosPlanesAgrupadosPorViaje(
            busqueda, conductorId, estado, fechaDesde, fechaHasta);

        // Construir información de filtros
        StringBuilder filtrosInfo = new StringBuilder();
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            filtrosInfo.append("Búsqueda: ").append(busqueda);
        }
        if (conductorId != null && !conductorId.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Conductor: ").append(conductorId);
        }
        if (estado != null && !estado.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Estado: ").append(estado);
        }
        if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Desde: ").append(fechaDesde);
        }
        if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Hasta: ").append(fechaHasta);
        }
        if (filtrosInfo.length() == 0) {
            filtrosInfo.append("Todos los viajes");
        }

        File tempFile = null;
        try {
            String tempDir = System.getProperty("java.io.tmpdir");
            File tempDirFile = new File(tempDir);
            if (!tempDirFile.exists()) {
                tempDirFile.mkdirs();
            }

            String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String nombreArchivo = "Reporte_DistribucionTransporte_" + fecha + ".xlsx";
            tempFile = new File(tempDirFile, nombreArchivo);

            try (FileOutputStream fos = new FileOutputStream(tempFile)) {
                ExcelUtil.generarExcelDistribucionTransporte(listaPlanes, fos, filtrosInfo.toString());
                fos.flush();
            }

            String asuntoFinal = (asunto != null && !asunto.trim().isEmpty()) ?
                asunto : "Reporte de Distribución y Transporte - TELITO BODEGUERO";

            // Calcular estadísticas
            int totalViajes = listaPlanes.size();
            int totalLotes = 0;
            Map<String, Integer> viajesPorConductor = new HashMap<>();
            Map<String, Integer> lotesPorConductor = new HashMap<>();
            Map<String, Integer> viajesPorVehiculo = new HashMap<>();
            Map<String, Integer> lotesPorVehiculo = new HashMap<>();
            Map<String, Integer> viajesPorEstado = new HashMap<>();

            for (PlanTransporteBean plan : listaPlanes) {
                int cantidadLotes = plan.getCantidadLotes();
                totalLotes += cantidadLotes;

                String conductor = plan.getNombreConductor();
                if (conductor != null) {
                    viajesPorConductor.put(conductor, viajesPorConductor.getOrDefault(conductor, 0) + 1);
                    lotesPorConductor.put(conductor, lotesPorConductor.getOrDefault(conductor, 0) + cantidadLotes);
                }

                String placa = plan.getPlacaVehiculo();
                if (placa != null) {
                    viajesPorVehiculo.put(placa, viajesPorVehiculo.getOrDefault(placa, 0) + 1);
                    lotesPorVehiculo.put(placa, lotesPorVehiculo.getOrDefault(placa, 0) + cantidadLotes);
                }

                String estadoPlan = plan.getEstado();
                if (estadoPlan != null) {
                    viajesPorEstado.put(estadoPlan, viajesPorEstado.getOrDefault(estadoPlan, 0) + 1);
                }
            }

            // Construir resumen de estadísticas
            StringBuilder estadisticasHTML = new StringBuilder();
            estadisticasHTML.append("<div class='summary-box'><h4 style='margin-top: 0; color: #0ea5e9;'>📊 Estadísticas por Conductor</h4>");
            for (Map.Entry<String, Integer> entry : viajesPorConductor.entrySet().stream()
                    .sorted((a, b) -> b.getValue().compareTo(a.getValue())).toList()) {
                estadisticasHTML.append("<div class='stats-box'>")
                    .append("<strong>").append(entry.getKey()).append(":</strong> ")
                    .append(entry.getValue()).append(" viajes, ")
                    .append(lotesPorConductor.getOrDefault(entry.getKey(), 0)).append(" lotes")
                    .append("</div>");
            }
            estadisticasHTML.append("</div>");

            estadisticasHTML.append("<div class='summary-box'><h4 style='margin-top: 0; color: #0ea5e9;'>🚚 Estadísticas por Vehículo</h4>");
            for (Map.Entry<String, Integer> entry : viajesPorVehiculo.entrySet().stream()
                    .sorted((a, b) -> b.getValue().compareTo(a.getValue())).toList()) {
                estadisticasHTML.append("<div class='stats-box'>")
                    .append("<strong>").append(entry.getKey()).append(":</strong> ")
                    .append(entry.getValue()).append(" viajes, ")
                    .append(lotesPorVehiculo.getOrDefault(entry.getKey(), 0)).append(" lotes")
                    .append("</div>");
            }
            estadisticasHTML.append("</div>");

            estadisticasHTML.append("<div class='summary-box'><h4 style='margin-top: 0; color: #0ea5e9;'>📈 Resumen por Estado</h4>");
            for (Map.Entry<String, Integer> entry : viajesPorEstado.entrySet()) {
                estadisticasHTML.append("<div class='stats-box'>")
                    .append("<strong>").append(entry.getKey()).append(":</strong> ")
                    .append(entry.getValue()).append(" viajes")
                    .append("</div>");
            }
            estadisticasHTML.append("</div>");

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
                            <h2>🚚 Reporte de Distribución y Transporte</h2>
                        </div>
                        <div class="content">
                            <p>Estimado/a,</p>
                            <p>Se adjunta el reporte de Distribución y Transporte generado desde el sistema <strong>TELITO BODEGUERO</strong>.</p>

                            <div class="info-box">
                                <h3 style="margin-top: 0; color: #006d77;">📊 Información del Reporte</h3>
                                <div class="stats-box">
                                    <strong>Total de viajes:</strong> %d
                                </div>
                                <div class="stats-box">
                                    <strong>Total de lotes:</strong> %d
                                </div>
                                <div class="stats-box">
                                    <strong>Filtros aplicados:</strong> %s
                                </div>
                                <p style="margin-top: 15px;"><strong>Fecha de generación:</strong> %s</p>
                            </div>

                            %s

                            %s

                            <p><strong>Nota:</strong> El archivo Excel incluye filtros automáticos y un resumen detallado por conductor y vehículo que puedes usar para análisis de rutas y seguimiento de entregas.</p>

                            <div class="footer">
                                <p>Este es un correo automático generado por el sistema TELITO BODEGUERO.</p>
                            </div>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(
                    totalViajes,
                    totalLotes,
                    filtrosInfo.toString(),
                    new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()),
                    estadisticasHTML.toString(),
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
        String redirectUrl = request.getContextPath() + "/planes-transporte";
        StringBuilder params = new StringBuilder();
        if (busqueda != null) params.append("?busqueda=").append(busqueda);
        if (conductorId != null) params.append(params.length() == 0 ? "?" : "&").append("conductor=").append(conductorId);
        if (estado != null) params.append(params.length() == 0 ? "?" : "&").append("estado=").append(estado);
        if (fechaDesde != null) params.append(params.length() == 0 ? "?" : "&").append("fecha_desde=").append(fechaDesde);
        if (fechaHasta != null) params.append(params.length() == 0 ? "?" : "&").append("fecha_hasta=").append(fechaHasta);
        response.sendRedirect(redirectUrl + params.toString());
    }
}

