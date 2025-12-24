package com.example.telito.logistica.servlets;

import com.example.telito.util.AuthorizationHelper;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.example.telito.logistica.beans.PlanTransporteBean;
import com.example.telito.logistica.daos.ConductorDao;
import com.example.telito.logistica.daos.DistritoDao;
import com.example.telito.logistica.daos.LoteDao;
import com.example.telito.logistica.daos.PlanTransporteDao;
import com.example.telito.logistica.daos.ProveedorDao;
import com.example.telito.logistica.daos.VehiculoDao;
import com.example.telito.administrador.daos.AlertaDAO;
import com.example.telito.util.EmailUtil;
import com.example.telito.util.NotificacionService;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

// Gestión de planes de transporte - CRUD completo con filtros y paginación
@WebServlet(name = "PlanTransporteServlet", value = "/planes-transporte")
public class PlanTransporteServlet extends HttpServlet {

    @Override
    public void init() throws ServletException {
        super.init();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Solo logística
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederLogistica(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de logística intentó acceder a PlanTransporteServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");

        PlanTransporteDao planTransporteDao = new PlanTransporteDao();
        LoteDao loteDao = new LoteDao();
        ConductorDao conductorDao = new ConductorDao();
        VehiculoDao vehiculoDao = new VehiculoDao();
        DistritoDao distritoDao = new DistritoDao();
        RequestDispatcher rd;

        switch (action) {
            case "listar":
                // Obtener parámetros de búsqueda
                String busqueda = request.getParameter("busqueda");
                String conductorId = request.getParameter("conductor");
                String estado = request.getParameter("estado");
                String fechaDesde = request.getParameter("fecha_desde");
                String fechaHasta = request.getParameter("fecha_hasta");

                // Paginación
                int page = 1;
                int size = 5;
                try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
                try { size = Integer.parseInt(request.getParameter("size")); } catch (Exception ignored) {}
                if (page < 1) page = 1;
                if (size < 1) size = 5;

                int totalRows = planTransporteDao.contarPlanes(busqueda, conductorId, estado, fechaDesde, fechaHasta);
                int totalPages = (int) Math.ceil(totalRows / (double) size);
                if (totalPages == 0) totalPages = 1;
                if (page > totalPages) page = totalPages;

                // Estadísticas generales (sin filtros)
                int totalPlanes = planTransporteDao.contarPlanes(null, null, null, null, null);
                int planesEnRuta = planTransporteDao.contarPlanes(null, null, "En Ruta", null, null);
                int planesEntregados = planTransporteDao.contarPlanes(null, null, "Entregado", null, null);
                int planesCancelados = planTransporteDao.contarPlanes(null, null, "Cancelado", null, null);
                int planesSalida = planTransporteDao.contarPlanes(null, null, "Salida", null, null);
                int planesPendientes = planTransporteDao.contarPlanes(null, null, "Pendiente", null, null);

                ArrayList<PlanTransporteBean> listaPlanes = planTransporteDao.listarPlanesDeTransporte(busqueda, conductorId, estado, fechaDesde, fechaHasta, page, size);

                // Cargar datos para modales y filtros
                request.setAttribute("listaConductores", conductorDao.listarConductores());
                request.setAttribute("listaPlanes", listaPlanes);
                request.setAttribute("listaLotes", loteDao.listarLotesDisponibles());
                request.setAttribute("listaVehiculos", vehiculoDao.listarVehiculos());
                request.setAttribute("listaDistritos", distritoDao.listarDistritos());
                request.setAttribute("busqueda", busqueda);
                request.setAttribute("conductorFiltro", conductorId);
                request.setAttribute("estadoFiltro", estado);
                request.setAttribute("fechaDesdeFiltro", fechaDesde);
                request.setAttribute("fechaHastaFiltro", fechaHasta);
                request.setAttribute("currentPage", page);
                request.setAttribute("size", size);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalRows", totalRows);
                request.setAttribute("totalPlanes", totalPlanes);
                request.setAttribute("planesEnRuta", planesEnRuta);
                request.setAttribute("planesEntregados", planesEntregados);
                request.setAttribute("planesCancelados", planesCancelados);
                request.setAttribute("planesSalida", planesSalida);
                request.setAttribute("planesPendientes", planesPendientes);
                request.setAttribute("baseUrl", request.getContextPath() + "/planes-transporte");
                request.setAttribute("itemName", "planes de transporte");

                rd = request.getRequestDispatcher("/logistica/Distribucion/distribucion.jsp");
                rd.forward(request, response);
                break;

            case "obtenerLotesPorProductor":
                // Endpoint AJAX para obtener lotes por productor
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                try {
                    int productorId = Integer.parseInt(request.getParameter("productorId"));
                    LoteDao loteDaoAjax = new LoteDao();
                    ArrayList<com.example.telito.logistica.beans.LoteBean> lotes = loteDaoAjax.listarLotesDisponiblesPorProductor(productorId);
                    
                    StringBuilder json = new StringBuilder();
                    json.append("{\"success\":true,\"lotes\":[");
                    for (int i = 0; i < lotes.size(); i++) {
                        com.example.telito.logistica.beans.LoteBean lote = lotes.get(i);
                        if (i > 0) json.append(",");
                        json.append("{")
                            .append("\"id\":").append(lote.getId()).append(",")
                            .append("\"codigoLote\":\"").append(lote.getCodigoLote().replace("\"", "\\\"")).append("\",")
                            .append("\"nombreProducto\":\"").append(lote.getNombreProducto().replace("\"", "\\\"")).append("\"")
                            .append("}");
                    }
                    json.append("]}");
                    response.getWriter().write(json.toString());
                } catch (Exception e) {
                    response.getWriter().write("{\"success\":false,\"message\":\"Error al obtener lotes: " + e.getMessage() + "\"}");
                }
                return;

            case "crear":
                request.setAttribute("listaLotes", loteDao.listarLotesDisponibles());
                request.setAttribute("listaConductores", conductorDao.listarConductores());
                request.setAttribute("listaVehiculos", vehiculoDao.listarVehiculos());
                request.setAttribute("listaDistritos", distritoDao.listarDistritos());

                rd = request.getRequestDispatcher("/logistica/Distribucion/form_plan_transporte.jsp");
                rd.forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Verificar que el usuario tenga rol de logística
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederLogistica(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de logística intentó acceder a PlanTransporteServlet (POST) desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        // === LÓGICA PARA GUARDAR EL NUEVO PLAN ===

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        PlanTransporteDao planTransporteDao = new PlanTransporteDao();

        if ("guardar".equals(action)) {
            // 1. Leemos los datos enviados desde el formulario
            int loteId = Integer.parseInt(request.getParameter("lote_id"));
            int conductorId = Integer.parseInt(request.getParameter("conductor_id"));
            int vehiculoId = Integer.parseInt(request.getParameter("vehiculo_id"));
            String fechaEntrega = request.getParameter("fecha_entrega");
            int distritoId = Integer.parseInt(request.getParameter("distrito_id"));
            
            // 1.1. Leer cantidad de paquetes y convertir a unidades
            int cantidadPaquetes = Integer.parseInt(request.getParameter("cantidad_paquetes"));
            
            // Validar cantidad de paquetes
            if (cantidadPaquetes <= 0) {
                request.setAttribute("error", "La cantidad de paquetes debe ser mayor a 0");
                request.getRequestDispatcher("/logistica/Distribucion/form_plan_transporte.jsp").forward(request, response);
                return;
            }
            
            // Obtener información del lote para validar stock
            LoteDao loteDao = new LoteDao();
            String sqlLote = "SELECT l.stock_actual, p.unidades_por_paquete FROM lotes l " +
                            "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                            "WHERE l.id_lote = ?";
            
            int stockActual = 0;
            int unidadesPorPaquete = 1;
            
            try (java.sql.Connection conn = com.example.telito.util.DatabaseConnection.getConnection();
                 java.sql.PreparedStatement pstmt = conn.prepareStatement(sqlLote)) {
                pstmt.setInt(1, loteId);
                try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        stockActual = rs.getInt("stock_actual");
                        unidadesPorPaquete = rs.getInt("unidades_por_paquete");
                    }
                }
            } catch (Exception e) {
                logger.error("Error al obtener información del lote", e);
                request.setAttribute("error", "Error al obtener información del lote");
                request.getRequestDispatcher("/logistica/Distribucion/form_plan_transporte.jsp").forward(request, response);
                return;
            }
            
            // Calcular cantidad de unidades
            int cantidadUnidades = cantidadPaquetes * unidadesPorPaquete;
            
            // Validar que no exceda el stock disponible
            if (cantidadUnidades > stockActual) {
                request.setAttribute("error", "La cantidad solicitada (" + cantidadUnidades + " unidades) excede el stock disponible (" + stockActual + " unidades)");
                request.getRequestDispatcher("/logistica/Distribucion/form_plan_transporte.jsp").forward(request, response);
                return;
            }

            // 2. Generamos el número de plan secuencial
            int ultimoId = planTransporteDao.obtenerUltimoId();
            int nuevoId = ultimoId + 1;
            String numeroPlan = String.format("PT%03d", nuevoId); // Formato PT001, PT011, etc.

            // 3. Llamamos al DAO para guardar en la BD
            planTransporteDao.crearPlan(numeroPlan, loteId, conductorId, vehiculoId, fechaEntrega, distritoId, cantidadUnidades);

            // 3.5. ========== NOTIFICACIÓN WEB A ALMACÉN ==========
            try {
                // Obtener información del lote y destino para la notificación
                LoteDao loteDao = new LoteDao();
                DistritoDao distritoDao = new DistritoDao();
                
                String sqlLote = "SELECT l.codigo_lote, p.nombre AS nombre_producto, " +
                                "FLOOR(l.stock_actual / p.unidades_por_paquete) AS paquetes " +
                                "FROM lotes l " +
                                "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                                "WHERE l.id_lote = ?";
                
                String nombreProducto = "";
                String nombreDestino = "";
                int paquetes = 0;
                
                try (java.sql.Connection conn = com.example.telito.util.DatabaseConnection.getConnection();
                     java.sql.PreparedStatement pstmt = conn.prepareStatement(sqlLote)) {
                    pstmt.setInt(1, loteId);
                    try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            nombreProducto = rs.getString("nombre_producto");
                            paquetes = rs.getInt("paquetes");
                        }
                    }
                }
                
                // Obtener nombre del distrito
                try {
                    com.example.telito.logistica.beans.DistritoBean distrito = distritoDao.obtenerDistritoPorId(distritoId);
                    if (distrito != null) {
                        nombreDestino = distrito.getNombre();
                    }
                } catch (Exception e) {
                    nombreDestino = "Destino " + distritoId;
                }
                
                // Crear notificación web para Almacén
                NotificacionService.notificarPlanTransporteCreado(
                    numeroPlan,
                    nombreProducto,
                    nombreDestino,
                    paquetes
                );
                
                // Crear notificación web para Gerente de Tienda del distrito
                NotificacionService.notificarPlanTransporteDestinado(
                    numeroPlan,
                    nombreProducto,
                    nombreDestino,
                    fechaEntrega,
                    distritoId
                );
            } catch (Exception e) {
                System.err.println("⚠ Error al crear notificación web de plan de transporte: " + e.getMessage());
                e.printStackTrace();
            }
            // ========== FIN NOTIFICACIÓN WEB ==========

            // 4. ENVIAR NOTIFICACIÓN A ALMACÉN SOBRE EL NUEVO PLAN DE TRANSPORTE
            try {
                AlertaDAO alertaDAO = new AlertaDAO();
                
                // Obtener emails de usuarios del rol Almacenero (nombre exacto en la BD)
                System.out.println("=== DEBUG: Buscando emails de usuarios de almacén ===");
                ArrayList<String> emailsAlmacen = alertaDAO.obtenerEmailsPorRol("Almacenero");
                System.out.println("Emails encontrados con rol 'Almacenero': " + emailsAlmacen.size());
                
                // Si no se encontraron emails, intentar con variaciones del nombre del rol
                if (emailsAlmacen.isEmpty()) {
                    System.out.println("⚠ No se encontraron emails con rol 'Almacenero', intentando variaciones...");
                    emailsAlmacen = alertaDAO.obtenerEmailsPorRol("ALMACENERO");
                    System.out.println("Emails encontrados con rol 'ALMACENERO': " + emailsAlmacen.size());
                }
                if (emailsAlmacen.isEmpty()) {
                    emailsAlmacen = alertaDAO.obtenerEmailsPorRol("ALMACEN");
                    System.out.println("Emails encontrados con rol 'ALMACEN': " + emailsAlmacen.size());
                }
                if (emailsAlmacen.isEmpty()) {
                    emailsAlmacen = alertaDAO.obtenerEmailsPorRol("BODEGA");
                    System.out.println("Emails encontrados con rol 'BODEGA': " + emailsAlmacen.size());
                }
                
                if (!emailsAlmacen.isEmpty()) {
                    System.out.println("✓ Se encontraron " + emailsAlmacen.size() + " email(s) para notificar");
                    // Obtener información del plan recién creado para el correo
                    LoteDao loteDao = new LoteDao();
                    ConductorDao conductorDao = new ConductorDao();
                    DistritoDao distritoDao = new DistritoDao();
                    VehiculoDao vehiculoDao = new VehiculoDao();
                    
                    // Obtener datos básicos del lote
                    String sqlLote = "SELECT l.codigo_lote, p.nombre AS nombre_producto, l.stock_actual " +
                                    "FROM lotes l " +
                                    "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                                    "WHERE l.id_lote = ?";
                    
                    String codigoLote = "";
                    String nombreProducto = "";
                    int stock = 0;
                    
                    try (java.sql.Connection conn = com.example.telito.util.DatabaseConnection.getConnection();
                         java.sql.PreparedStatement pstmt = conn.prepareStatement(sqlLote)) {
                        pstmt.setInt(1, loteId);
                        try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                            if (rs.next()) {
                                codigoLote = rs.getString("codigo_lote");
                                nombreProducto = rs.getString("nombre_producto");
                                stock = rs.getInt("stock_actual");
                            }
                        }
                    }
                    
                    // Usar plantilla profesional
                    String mensaje = com.example.telito.util.EmailTemplates.generarCorreoNuevoPlanTransporte(
                        numeroPlan,
                        nombreProducto,
                        codigoLote,
                        stock,
                        fechaEntrega
                    );
                    
                    // Enviar correo a todos los usuarios de almacén
                    int correosEnviados = 0;
                    for (String email : emailsAlmacen) {
                        boolean enviado = EmailUtil.sendSystemAlertHTML(
                            email,
                            "Nuevo Plan de Transporte - Requiere Preparación",
                            mensaje
                        );
                        if (enviado) {
                            correosEnviados++;
                        }
                    }
                    
                    if (correosEnviados > 0) {
                        System.out.println("✓ Se enviaron " + correosEnviados + " correo(s) a almacén sobre el nuevo plan de transporte");
                    } else {
                        System.err.println("⚠ No se pudo enviar ningún correo a almacén");
                    }
                } else {
                    System.err.println("⚠ No se encontraron usuarios de almacén con email configurado para notificar");
                }
            } catch (Exception e) {
                // No bloquear la operación si falla el correo
                System.err.println("⚠ Error al enviar correo de notificación de plan de transporte: " + e.getMessage());
                e.printStackTrace();
            }
            // ========== FIN ENVÍO DE CORREO ==========

            // 5. Redirigimos al usuario a la lista para que vea el nuevo plan
            response.sendRedirect(request.getContextPath() + "/planes-transporte");

        } else {
            // Si la acción no es "guardar", simplemente mostramos la lista
            doGet(request, response);
        }
    }
}