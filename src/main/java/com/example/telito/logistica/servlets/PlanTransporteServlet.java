package com.example.telito.logistica.servlets;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.example.telito.logistica.beans.PlanTransporteBean;
import com.example.telito.logistica.daos.ConductorDao;
import com.example.telito.logistica.daos.DistritoDao;
import com.example.telito.logistica.daos.LoteDao;
import com.example.telito.logistica.daos.PlanTransporteDao;
import com.example.telito.logistica.daos.VehiculoDao;
import com.example.telito.administrador.daos.AlertaDAO;
import com.example.telito.util.EmailUtil;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

@WebServlet(name = "PlanTransporteServlet", value = "/planes-transporte")
public class PlanTransporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");

        PlanTransporteDao planTransporteDao = new PlanTransporteDao();
        RequestDispatcher rd;

        switch (action) {
            case "listar":
                String busqueda = request.getParameter("busqueda");
                String conductorId = request.getParameter("conductor");
                String estado = request.getParameter("estado");
                String fechaDesde = request.getParameter("fecha_desde");
                String fechaHasta = request.getParameter("fecha_hasta");

                // Paginación
                int page = 1;
                int size = 10;
                try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
                try { size = Integer.parseInt(request.getParameter("size")); } catch (Exception ignored) {}
                if (page < 1) page = 1;
                if (size < 1) size = 10;

                int totalRows = planTransporteDao.contarPlanes(busqueda, conductorId, estado, fechaDesde, fechaHasta);
                int totalPages = (int) Math.ceil(totalRows / (double) size);
                if (totalPages == 0) totalPages = 1;
                if (page > totalPages) page = totalPages;

                ConductorDao conductorDao = new ConductorDao();
                ArrayList<PlanTransporteBean> listaPlanes = planTransporteDao.listarPlanesDeTransporte(busqueda, conductorId, estado, fechaDesde, fechaHasta, page, size);

                request.setAttribute("listaConductores", conductorDao.listarConductores());
                request.setAttribute("listaPlanes", listaPlanes);
                request.setAttribute("busqueda", busqueda);
                request.setAttribute("conductorFiltro", conductorId);
                request.setAttribute("estadoFiltro", estado);
                request.setAttribute("fechaDesdeFiltro", fechaDesde);
                request.setAttribute("fechaHastaFiltro", fechaHasta);
                request.setAttribute("currentPage", page);
                request.setAttribute("size", size);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalRows", totalRows);
                request.setAttribute("baseUrl", request.getContextPath() + "/planes-transporte");
                request.setAttribute("itemName", "planes de transporte");

                rd = request.getRequestDispatcher("/logistica/Distribucion/distribucion.jsp");
                rd.forward(request, response);
                break;

            case "crear":
                LoteDao loteDao = new LoteDao();
                ConductorDao conductorDaoForm = new ConductorDao();
                VehiculoDao vehiculoDao = new VehiculoDao();
                DistritoDao distritoDao = new DistritoDao();

                request.setAttribute("listaLotes", loteDao.listarLotesDisponibles());
                request.setAttribute("listaConductores", conductorDaoForm.listarConductores());
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

            // 2. Generamos el número de plan secuencial
            int ultimoId = planTransporteDao.obtenerUltimoId();
            int nuevoId = ultimoId + 1;
            String numeroPlan = String.format("PT%03d", nuevoId); // Formato PT001, PT011, etc.

            // 3. Llamamos al DAO para guardar en la BD
            planTransporteDao.crearPlan(numeroPlan, loteId, conductorId, vehiculoId, fechaEntrega, distritoId);

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
                    
                    String mensaje = """
                        <h2>Nuevo Plan de Transporte Creado</h2>
                        <p>Se ha creado un nuevo plan de transporte que requiere preparación en almacén.</p>
                        <p><strong>Número de Plan:</strong> %s</p>
                        <p><strong>Producto:</strong> %s</p>
                        <p><strong>Lote:</strong> %s</p>
                        <p><strong>Stock Disponible:</strong> %d paquetes</p>
                        <p><strong>Fecha de Entrega:</strong> %s</p>
                        <hr>
                        <p>Por favor, prepara la mercancía según este plan de transporte.</p>
                        <p>Puedes acceder a la preparación desde: <strong>Almacén → Registrar Salidas</strong></p>
                        """.formatted(
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