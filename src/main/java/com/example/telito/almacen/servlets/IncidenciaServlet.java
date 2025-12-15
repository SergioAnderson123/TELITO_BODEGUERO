package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.Incidencia;
import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.daos.IncidenciaDAO;
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.administrador.services.AuditoriaService;
import com.example.telito.util.AuthorizationHelper;
import com.example.telito.util.EmailUtil;
import com.example.telito.util.NotificacionService;
import com.example.telito.util.EmailTemplates;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;

// Gestión de incidencias del almacén (almaceneros reportan, administradores resuelven)
@WebServlet("/almacen/IncidenciaServlet")
public class IncidenciaServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Almaceneros pueden reportar y ver sus incidencias
        // Administradores pueden ver todas y resolver
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }
        
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        String rol = usuario.getRol() != null ? usuario.getRol().getNombre() : "";
        boolean esAlmacenero = AuthorizationHelper.puedeAccederAlmacen(session);
        boolean esAdministrador = AuthorizationHelper.puedeAccederAdministrador(session);
        
        if (!esAlmacenero && !esAdministrador) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin permisos intentó acceder a IncidenciaServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "listar";
        }
        
        IncidenciaDAO incidenciaDAO = new IncidenciaDAO();
        
        switch (action) {
            case "listar":
                listarIncidencias(request, response, incidenciaDAO, esAdministrador);
                break;
                
            case "formReportar":
                if (!esAlmacenero) {
                    response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
                    return;
                }
                mostrarFormularioReporte(request, response);
                break;
                
            case "ver":
                verIncidencia(request, response, incidenciaDAO);
                break;
                
            case "formResolver":
                if (!esAdministrador) {
                    response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
                    return;
                }
                mostrarFormularioResolucion(request, response, incidenciaDAO);
                break;
                
            default:
                listarIncidencias(request, response, incidenciaDAO, esAdministrador);
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }
        
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        String action = request.getParameter("action");
        
        IncidenciaDAO incidenciaDAO = new IncidenciaDAO();
        
        switch (action) {
            case "reportar":
                if (!AuthorizationHelper.puedeAccederAlmacen(session)) {
                    response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
                    return;
                }
                reportarIncidencia(request, response, session, usuario, incidenciaDAO);
                break;
                
            case "resolver":
                if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
                    response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
                    return;
                }
                resolverIncidencia(request, response, session, usuario, incidenciaDAO);
                break;
                
            default:
                response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
                break;
        }
    }
    
    private void listarIncidencias(HttpServletRequest request, HttpServletResponse response,
                                   IncidenciaDAO incidenciaDAO, boolean esAdministrador)
            throws ServletException, IOException {
        
        try {
            String estado = request.getParameter("estado");
            String tipo = request.getParameter("tipo");
            String busqueda = request.getParameter("busqueda");
            
            int page = 1;
            int size = 5;
            try {
                String pageParam = request.getParameter("page");
                if (pageParam != null && !pageParam.isEmpty()) {
                    page = Integer.parseInt(pageParam);
                }
            } catch (NumberFormatException e) {
                // Usar valor por defecto
            }
            if (page < 1) page = 1;
            
            ArrayList<Incidencia> incidencias = incidenciaDAO.listarIncidencias(estado, tipo, busqueda, page, size);
            int totalRegistros = incidenciaDAO.contarIncidencias(estado, tipo, busqueda);
            int totalPages = (int) Math.ceil((double) totalRegistros / size);
            if (totalPages == 0) totalPages = 1;
            if (page > totalPages) page = totalPages;
            
            // Calcular estadísticas (sin filtros para obtener totales reales)
            int totalIncidencias = incidenciaDAO.contarTotalIncidencias();
            int incidenciasPendientes = incidenciaDAO.contarIncidenciasPendientes();
            int incidenciasResueltas = incidenciaDAO.contarIncidenciasResueltas();
            
            request.setAttribute("incidencias", incidencias);
            request.setAttribute("totalRegistros", totalRegistros);
            request.setAttribute("currentPage", page);
            request.setAttribute("page", page);
            request.setAttribute("size", size);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalRows", totalRegistros);
            request.setAttribute("totalIncidencias", totalIncidencias);
            request.setAttribute("incidenciasPendientes", incidenciasPendientes);
            request.setAttribute("incidenciasResueltas", incidenciasResueltas);
            request.setAttribute("estado", estado);
            request.setAttribute("tipo", tipo);
            request.setAttribute("busqueda", busqueda);
            request.setAttribute("esAdministrador", esAdministrador);
            request.setAttribute("baseUrl", request.getContextPath() + "/almacen/IncidenciaServlet");
            request.setAttribute("itemName", "incidencias");
            
            RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/incidencias/listaIncidencias.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            System.err.println("Error en IncidenciaServlet - listarIncidencias: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al cargar la lista de incidencias: " + e.getMessage());
        }
    }
    
    private void mostrarFormularioReporte(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idLoteStr = request.getParameter("idLote");
        if (idLoteStr == null || idLoteStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
            return;
        }
        
        try {
            int idLote = Integer.parseInt(idLoteStr);
            LoteDao loteDao = new LoteDao();
            Lote lote = loteDao.buscarLotePorId(idLote);
            
            if (lote == null) {
                response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
                return;
            }
            
            request.setAttribute("lote", lote);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/incidencias/reportarIncidencia.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
        }
    }
    
    private void reportarIncidencia(HttpServletRequest request, HttpServletResponse response,
                                   HttpSession session, Usuario usuario, IncidenciaDAO incidenciaDAO)
            throws IOException {
        
        try {
            int loteId = Integer.parseInt(request.getParameter("loteId"));
            int cantidadReportadaPaquetes = Integer.parseInt(request.getParameter("cantidadReportada"));
            String tipoIncidencia = request.getParameter("tipoIncidencia");
            String motivo = request.getParameter("motivo");
            String descripcion = request.getParameter("descripcion");
            
            LoteDao loteDao = new LoteDao();
            Lote lote = loteDao.buscarLotePorId(loteId);
            
            if (lote == null) {
                session.setAttribute("errorMsg", "Lote no encontrado");
                response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
                return;
            }
            
            // Validar que el lote tenga un producto_id válido
            if (lote.getProductoId() <= 0) {
                session.setAttribute("errorMsg", "Error: El lote no tiene un producto asociado válido.");
                response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet?action=formReportar&idLote=" + 
                                    request.getParameter("loteId"));
                return;
            }
            
            // Convertir paquetes a unidades
            int unidadesPorPaquete = lote.getUnidadesPorPaquete() > 0 ? lote.getUnidadesPorPaquete() : 1;
            int cantidadReportada = cantidadReportadaPaquetes * unidadesPorPaquete;
            
            int cantidadSistema = lote.getStockActual(); // En unidades
            int diferencia = cantidadReportada - cantidadSistema;
            
            // Validar que el tipo de incidencia coincida con la diferencia
            if (diferencia < 0 && !"Faltante".equals(tipoIncidencia)) {
                tipoIncidencia = "Faltante";
            } else if (diferencia > 0 && !"Sobrante".equals(tipoIncidencia)) {
                tipoIncidencia = "Sobrante";
            }
            
            Incidencia incidencia = new Incidencia();
            incidencia.setLoteId(loteId);
            incidencia.setProductoId(lote.getProductoId());
            incidencia.setTipoIncidencia(tipoIncidencia);
            incidencia.setCantidadReportada(cantidadReportada);
            incidencia.setCantidadSistema(cantidadSistema);
            incidencia.setDiferencia(diferencia);
            incidencia.setMotivo(motivo);
            incidencia.setDescripcion(descripcion);
            incidencia.setEstado("Pendiente");
            incidencia.setUsuarioReporteId(usuario.getIdUsuario());
            
            int idIncidencia = incidenciaDAO.crearIncidencia(incidencia);
            
            if (idIncidencia <= 0) {
                session.setAttribute("errorMsg", "Error: No se pudo crear la incidencia en la base de datos.");
                response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet?action=formReportar&idLote=" + 
                                    request.getParameter("loteId"));
                return;
            }
            
            // Registrar en auditoría
            AuditoriaService.registrarAccion(
                usuario,
                "REPORTAR_INCIDENCIA",
                AuditoriaService.MODULO_ALMACEN,
                "Incidencia reportada: " + tipoIncidencia + " - Lote: " + lote.getCodigoLote() + 
                " (ID: " + idIncidencia + ")",
                request
            );
            
            // NO notificar al administrador - este es un flujo interno del almacenero
            // La incidencia se cerrará automáticamente cuando se haga el ajuste
            
            session.setAttribute("successMsg", "Incidencia reportada exitosamente. La fila aparecerá en rojo en Gestión de Inventario hasta que realices el ajuste.");
            response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Error: Datos inválidos. Verifique que los campos numéricos sean correctos.");
            response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet?action=formReportar&idLote=" + 
                                request.getParameter("loteId"));
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Error al reportar incidencia: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMsg", "Error al reportar la incidencia: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet?action=formReportar&idLote=" + 
                                request.getParameter("loteId"));
        }
    }
    
    private void verIncidencia(HttpServletRequest request, HttpServletResponse response,
                              IncidenciaDAO incidenciaDAO) throws ServletException, IOException {
        
        try {
            int idIncidencia = Integer.parseInt(request.getParameter("id"));
            Incidencia incidencia = incidenciaDAO.obtenerIncidenciaPorId(idIncidencia);
            
            if (incidencia == null) {
                response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
                return;
            }
            
            request.setAttribute("incidencia", incidencia);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/incidencias/verIncidencia.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
        }
    }
    
    private void mostrarFormularioResolucion(HttpServletRequest request, HttpServletResponse response,
                                            IncidenciaDAO incidenciaDAO) throws ServletException, IOException {
        
        try {
            int idIncidencia = Integer.parseInt(request.getParameter("id"));
            Incidencia incidencia = incidenciaDAO.obtenerIncidenciaPorId(idIncidencia);
            
            if (incidencia == null) {
                response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
                return;
            }
            
            request.setAttribute("incidencia", incidencia);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/incidencias/resolverIncidencia.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
        }
    }
    
    private void resolverIncidencia(HttpServletRequest request, HttpServletResponse response,
                                   HttpSession session, Usuario usuario, IncidenciaDAO incidenciaDAO)
            throws IOException {
        
        try {
            int idIncidencia = Integer.parseInt(request.getParameter("idIncidencia"));
            String estado = request.getParameter("estado");
            String observaciones = request.getParameter("observaciones");
            
            Incidencia incidencia = incidenciaDAO.obtenerIncidenciaPorId(idIncidencia);
            if (incidencia == null) {
                session.setAttribute("errorMsg", "Incidencia no encontrada");
                response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
                return;
            }
            
            incidencia.setEstado(estado);
            incidencia.setUsuarioResolucionId(usuario.getIdUsuario());
            incidencia.setFechaResolucion(new Timestamp(System.currentTimeMillis()));
            incidencia.setObservacionesResolucion(observaciones);
            
            incidenciaDAO.actualizarIncidencia(incidencia);
            
            // Registrar en auditoría
            AuditoriaService.registrarAccion(
                usuario,
                "RESOLVER_INCIDENCIA",
                AuditoriaService.MODULO_ALMACEN,
                "Incidencia resuelta: " + estado + " - ID: " + idIncidencia,
                request
            );
            
            session.setAttribute("successMsg", "Incidencia actualizada exitosamente.");
            response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet?action=ver&id=" + idIncidencia);
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Error al resolver la incidencia: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet?action=formResolver&id=" + 
                                request.getParameter("idIncidencia"));
        }
    }
    
    /**
     * Envía notificación por email al administrador sobre una nueva incidencia.
     */
    private void enviarNotificacionAdministrador(Incidencia incidencia, Lote lote) {
        try {
            // Obtener lista de administradores
            UsuarioDAO usuarioDAO = new UsuarioDAO();
            // Obtener ID del rol Administrador (asumiendo que es 1, ajustar según tu BD)
            ArrayList<Usuario> administradores = usuarioDAO.listarUsuarios(null, "1", "1", null, null, 1, 100);
            
            if (administradores.isEmpty()) {
                return;
            }
            
            String asunto = "Nueva Incidencia de Inventario Reportada";
            String mensaje = construirMensajeIncidencia(incidencia, lote);
            
            for (Usuario admin : administradores) {
                if (admin.getEmail() != null && !admin.getEmail().isEmpty()) {
                    EmailUtil.sendEmail(admin.getEmail(), asunto, mensaje, true); // true = HTML
                }
            }
        } catch (Exception e) {
            System.err.println("Error al enviar notificación de incidencia: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Construye el mensaje HTML para la notificación de incidencia.
     */
    private String construirMensajeIncidencia(Incidencia incidencia, Lote lote) {
        StringBuilder cuerpo = new StringBuilder();
        cuerpo.append("<table style='width:100%; border-collapse: collapse; margin-top: 10px;'>");
        cuerpo.append("<tr><td style='padding:8px;border-bottom:1px solid #e9ecef;'><strong>Tipo:</strong></td><td style='padding:8px;border-bottom:1px solid #e9ecef;'>")
              .append(incidencia.getTipoIncidencia()).append("</td></tr>");
        cuerpo.append("<tr><td style='padding:8px;border-bottom:1px solid #e9ecef;'><strong>Producto:</strong></td><td style='padding:8px;border-bottom:1px solid #e9ecef;'>")
              .append(lote.getNombreProducto()).append("</td></tr>");
        cuerpo.append("<tr><td style='padding:8px;border-bottom:1px solid #e9ecef;'><strong>Código Lote:</strong></td><td style='padding:8px;border-bottom:1px solid #e9ecef;'>")
              .append(lote.getCodigoLote()).append("</td></tr>");
        cuerpo.append("<tr><td style='padding:8px;border-bottom:1px solid #e9ecef;'><strong>Cantidad Sistema:</strong></td><td style='padding:8px;border-bottom:1px solid #e9ecef;'>")
              .append(incidencia.getCantidadSistema()).append("</td></tr>");
        cuerpo.append("<tr><td style='padding:8px;border-bottom:1px solid #e9ecef;'><strong>Cantidad Reportada:</strong></td><td style='padding:8px;border-bottom:1px solid #e9ecef;'>")
              .append(incidencia.getCantidadReportada()).append("</td></tr>");
        cuerpo.append("<tr><td style='padding:8px;border-bottom:1px solid #e9ecef;'><strong>Diferencia:</strong></td><td style='padding:8px;border-bottom:1px solid #e9ecef;'>")
              .append(incidencia.getDiferencia()).append("</td></tr>");
        cuerpo.append("<tr><td style='padding:8px;border-bottom:1px solid #e9ecef;'><strong>Motivo:</strong></td><td style='padding:8px;border-bottom:1px solid #e9ecef;'>")
              .append(incidencia.getMotivo()).append("</td></tr>");
        if (incidencia.getDescripcion() != null && !incidencia.getDescripcion().isEmpty()) {
            cuerpo.append("<tr><td style='padding:8px;border-bottom:1px solid #e9ecef;'><strong>Descripción:</strong></td><td style='padding:8px;border-bottom:1px solid #e9ecef;'>")
                  .append(incidencia.getDescripcion()).append("</td></tr>");
        }
        cuerpo.append("</table>");
        cuerpo.append("<p style='margin-top:16px; font-size:14px; color:#555555;'>Por favor, revisa y resuelve la incidencia en el sistema de TELITO BODEGUERO.</p>");

        return EmailTemplates.generarCorreoAlertaBasica(
            "Nueva Incidencia de Inventario",
            "Se ha reportado una nueva incidencia en el almacén.",
            cuerpo.toString()
        );
    }
}

