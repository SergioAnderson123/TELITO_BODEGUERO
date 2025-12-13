package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.*; // Importa todos tus beans
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.almacen.daos.MovimientoDao;
import com.example.telito.almacen.daos.PedidoDao;
import com.example.telito.almacen.daos.PlanTransporteDao;
import com.example.telito.administrador.daos.AlertaDAO;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.util.AuthorizationHelper;
import com.example.telito.util.EmailUtil;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // Importante para obtener el usuario

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

@WebServlet("/almacen/PedidoServlet")
public class PedidoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar que el usuario tenga rol de almacenero
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAlmacen(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de almacenero intentó acceder a PedidoServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        // --- TU MÉTODO doGet ESTÁ PERFECTO, NO NECESITA CAMBIOS ---
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        PedidoDao pedidoDao = new PedidoDao();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                try {
                    int registrosPorPagina = 5;
                    
                    // Paginación para PEDIDOS
                    String pageStr = request.getParameter("page");
                    int paginaActual = 1;
                    try {
                        if (pageStr != null && !pageStr.isEmpty()) {
                            paginaActual = Integer.parseInt(pageStr);
                        }
                    } catch (NumberFormatException e) {
                        paginaActual = 1;
                    }
                    if (paginaActual < 1) paginaActual = 1;

                    // Parámetros de filtros
                    String busqueda = request.getParameter("busqueda");
                    String estado = request.getParameter("estado");

                    int totalRegistros = pedidoDao.contarPedidos(busqueda, estado);
                    int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
                    if (totalPaginas == 0) totalPaginas = 1;
                    if (paginaActual > totalPaginas) paginaActual = totalPaginas;
                    
                    // Calcular estadísticas (sin filtros para obtener totales reales)
                    int totalPedidos = pedidoDao.contarTotalPedidos();
                    int pedidosPendientes = pedidoDao.contarPedidosPendientes();
                    int pedidosDespachados = pedidoDao.contarPedidosDespachados();
                    
                    int offset = (paginaActual - 1) * registrosPorPagina;
                    ArrayList<Pedido> listaPaginada = pedidoDao.listarPedidosPaginados(offset, registrosPorPagina, busqueda, estado);

                    // Paginación para PLANES DE TRANSPORTE
                    PlanTransporteDao planTransporteDao = new PlanTransporteDao();
                    String pagePlanesStr = request.getParameter("pagePlanes");
                    int paginaPlanes = 1;
                    try {
                        if (pagePlanesStr != null && !pagePlanesStr.isEmpty()) {
                            paginaPlanes = Integer.parseInt(pagePlanesStr);
                        }
                    } catch (NumberFormatException e) {
                        paginaPlanes = 1;
                    }
                    if (paginaPlanes < 1) paginaPlanes = 1;

                    int totalPlanes = planTransporteDao.contarTotalPlanes();
                    int totalPaginasPlanes = (int) Math.ceil((double) totalPlanes / registrosPorPagina);
                    if (totalPaginasPlanes == 0) totalPaginasPlanes = 1;
                    if (paginaPlanes > totalPaginasPlanes) paginaPlanes = totalPaginasPlanes;
                    
                    int offsetPlanes = (paginaPlanes - 1) * registrosPorPagina;
                    ArrayList<PlanTransporte> listaPlanes = planTransporteDao.listarPlanesPaginados(offsetPlanes, registrosPorPagina);

                    // Atributos para tabla de PEDIDOS
                    request.setAttribute("listaPedidos", listaPaginada);
                    request.setAttribute("currentPage", paginaActual);
                    request.setAttribute("size", registrosPorPagina);
                    request.setAttribute("totalPages", totalPaginas);
                    request.setAttribute("totalRows", totalRegistros);
                    request.setAttribute("baseUrl", request.getContextPath() + "/almacen/PedidoServlet");
                    request.setAttribute("itemName", "pedidos");
                    
                    // Atributos para tabla de PLANES
                    request.setAttribute("listaPlanes", listaPlanes);
                    request.setAttribute("currentPagePlanes", paginaPlanes);
                    request.setAttribute("sizePlanes", registrosPorPagina);
                    request.setAttribute("totalPagesPlanes", totalPaginasPlanes);
                    request.setAttribute("totalRowsPlanes", totalPlanes);
                    request.setAttribute("baseUrlPlanes", request.getContextPath() + "/almacen/PedidoServlet");
                    request.setAttribute("itemNamePlanes", "planes");
                    
                    // Estadísticas
                    request.setAttribute("totalPedidos", totalPedidos);
                    request.setAttribute("pedidosPendientes", pedidosPendientes);
                    request.setAttribute("pedidosDespachados", pedidosDespachados);
                    
                    // Filtros
                    request.setAttribute("busqueda", busqueda);
                    request.setAttribute("estadoFiltro", estado);

                    view = request.getRequestDispatcher("/almacen/pedidos/listaPedidos.jsp");
                    view.forward(request, response);
                } catch (Exception e) {
                    System.err.println("Error en PedidoServlet - case lista: " + e.getMessage());
                    e.printStackTrace();
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al cargar la lista de pedidos: " + e.getMessage());
                }
                break;

            case "preparar":
                int idPedido = Integer.parseInt(request.getParameter("id"));
                Pedido pedido = pedidoDao.buscarPedidoPorId(idPedido);

                if (pedido != null) {
                    request.setAttribute("pedido", pedido);
                    view = request.getRequestDispatcher("/almacen/pedidos/prepararPedido.jsp");
                    view.forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/almacen/PedidoServlet");
                }
                break;

            case "prepararPlan":
                int idPlan = Integer.parseInt(request.getParameter("id"));
                PlanTransporteDao planDao = new PlanTransporteDao();
                PlanTransporte plan = planDao.buscarPlanPorId(idPlan);

                if (plan != null) {
                    request.setAttribute("plan", plan);
                    view = request.getRequestDispatcher("/almacen/pedidos/prepararPlanTransporte.jsp");
                    view.forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/almacen/PedidoServlet");
                }
                break;
        }
    }

    /**
     * MÉTODO COMPLETAMENTE IMPLEMENTADO
     * Procesa el formulario de "Finalizar preparación", descuenta el stock y registra los movimientos.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar que el usuario tenga rol de almacenero
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAlmacen(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de almacenero intentó acceder a PedidoServlet (POST) desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        // Obtenemos el usuario de la sesión para registrar quién hizo el movimiento
        com.example.telito.administrador.beans.Usuario usuarioSesion = 
            (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
        int usuarioId = (usuarioSesion != null) ? usuarioSesion.getIdUsuario() : 1; // Usamos 1 como fallback si no hay sesión

        String action = request.getParameter("action");

        // Si es preparación de Plan de Transporte
        if ("prepararPlanTransporte".equals(action)) {
            procesarPlanTransporte(request, response, usuarioId);
            return;
        }

        // Si no, es preparación de pedido normal (lógica existente)
        // Instanciamos los DAOs
        PedidoDao pedidoDao = new PedidoDao();
        LoteDao loteDao = new LoteDao();
        MovimientoDao movimientoDao = new MovimientoDao();

        int idPedido = Integer.parseInt(request.getParameter("id_pedido"));

        // Volvemos a buscar el pedido para tener la información completa de sus items
        Pedido pedido = pedidoDao.buscarPedidoPorId(idPedido);

        if (pedido != null) {
            boolean stockSuficiente = true;

            // --- PASO 1: BUCLE DE VERIFICACIÓN ---
            // Primero, revisamos que todo esté en orden antes de hacer cambios en la BD.
            for (PedidoItem item : pedido.getItems()) {
                // Leemos el ID del lote que el usuario seleccionó para este producto
                String idLoteSeleccionadoStr = request.getParameter("lote_seleccionado_" + item.getProductoId());

                if (idLoteSeleccionadoStr == null || idLoteSeleccionadoStr.isEmpty()) {
                    stockSuficiente = false;
                    request.setAttribute("error", "Debe seleccionar un lote para el producto: " + item.getNombreProducto());
                    break;
                }

                int idLote = Integer.parseInt(idLoteSeleccionadoStr);
                Lote lote = loteDao.buscarLotePorId(idLote);

                if (lote == null || lote.getStockActual() < item.getCantidadRequerida()) {
                    stockSuficiente = false;
                    request.setAttribute("error", "Stock insuficiente en el lote seleccionado para: " + item.getNombreProducto());
                    break;
                }
            }

            // --- PASO 2: EJECUCIÓN ---
            // Si todas las verificaciones pasaron, procedemos a actualizar la base de datos.
            if (stockSuficiente) {
                for (PedidoItem item : pedido.getItems()) {
                    int idLote = Integer.parseInt(request.getParameter("lote_seleccionado_" + item.getProductoId()));
                    Lote lote = loteDao.buscarLotePorId(idLote);

                    int nuevoStock = lote.getStockActual() - item.getCantidadRequerida();

                    // 1. Actualizamos el stock del lote
                    loteDao.actualizarStock(idLote, nuevoStock);

                    // 2. Registramos el movimiento de salida
                    Movimiento movimiento = new Movimiento();
                    movimiento.setLoteId(idLote);
                    movimiento.setPedidoId(idPedido);
                    movimiento.setUsuarioId(usuarioId); // Guardamos quién hizo el despacho
                    movimiento.setTipoMovimiento("Salida");
                    movimiento.setCantidad(item.getCantidadRequerida());
                    movimiento.setMotivo("Pedido cliente"); // Motivo estandarizado
                    movimientoDao.registrarMovimiento(movimiento);
                }

                // 3. Actualizamos el estado del pedido a "Despachado"
                pedidoDao.actualizarEstado(idPedido, "Despachado");

                // 4. ENVIAR NOTIFICACIONES POR CORREO
                try {
                    // Notificar a usuarios de logística sobre el pedido despachado
                    AlertaDAO alertaDAO = new AlertaDAO();
                    UsuarioDAO usuarioDAO = new UsuarioDAO();
                    
                    // Obtener emails de usuarios del rol LOGISTICA
                    ArrayList<String> emailsLogistica = alertaDAO.obtenerEmailsPorRol("LOGISTICA");
                    
                    if (!emailsLogistica.isEmpty() && pedido != null) {
                        String mensaje = """
                            <h2>Pedido Despachado - Requiere Plan de Transporte</h2>
                            <p>Se ha despachado un pedido que requiere coordinación de transporte.</p>
                            <p><strong>Número de Pedido:</strong> %s</p>
                            <p><strong>Cliente:</strong> %s</p>
                            <p><strong>Destino:</strong> %s</p>
                            <p><strong>Fecha de Despacho:</strong> %s</p>
                            <hr>
                            <p><strong>Productos:</strong></p>
                            <ul>
                            """.formatted(
                                pedido.getNumeroPedido(),
                                pedido.getCliente() != null ? pedido.getCliente().getNombre() : "N/A",
                                pedido.getDestino(),
                                new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())
                            );
                        
                        // Agregar productos del pedido
                        if (pedido.getItems() != null && !pedido.getItems().isEmpty()) {
                            for (PedidoItem item : pedido.getItems()) {
                                mensaje += String.format(
                                    "<li>%s - Cantidad: %d</li>%n",
                                    item.getNombreProducto(),
                                    item.getCantidadRequerida()
                                );
                            }
                        }
                        mensaje += """
                            </ul>
                            <p>Por favor, coordina el plan de transporte para este pedido.</p>
                            """;
                        
                        // Enviar correo a todos los usuarios de logística
                        int correosEnviados = 0;
                        for (String email : emailsLogistica) {
                            boolean enviado = EmailUtil.sendSystemAlertHTML(
                                email,
                                "Pedido Despachado - Requiere Transporte",
                                mensaje
                            );
                            if (enviado) {
                                correosEnviados++;
                            }
                        }
                        
                        if (correosEnviados > 0) {
                            System.out.println("✓ Se enviaron " + correosEnviados + " correo(s) a logística sobre el pedido despachado");
                        }
                    }
                } catch (Exception e) {
                    // No bloquear la operación si falla el correo
                    System.err.println("⚠ Error al enviar correo de notificación de pedido despachado: " + e.getMessage());
                    e.printStackTrace();
                }
                // ========== FIN ENVÍO DE CORREO ==========

                // 5. Redirigimos a la lista de pedidos
                response.sendRedirect(request.getContextPath() + "/almacen/PedidoServlet");
            } else {
                // Si hubo un error, volvemos a cargar la página de preparación mostrando el mensaje de error
                request.setAttribute("pedido", pedidoDao.buscarPedidoPorId(idPedido));
                RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/pedidos/prepararPedido.jsp");
                dispatcher.forward(request, response);
            }
        } else {
            // Si por alguna razón el pedido no se encuentra, volvemos a la lista
            response.sendRedirect(request.getContextPath() + "/almacen/PedidoServlet");
        }
    }

    /**
     * MÉTODO PARA PROCESAR LA PREPARACIÓN DE UN PLAN DE TRANSPORTE
     */
    private void procesarPlanTransporte(HttpServletRequest request, HttpServletResponse response, int usuarioId)
            throws ServletException, IOException {

        PlanTransporteDao planDao = new PlanTransporteDao();
        LoteDao loteDao = new LoteDao();
        MovimientoDao movimientoDao = new MovimientoDao();

        int idPlan = Integer.parseInt(request.getParameter("id_plan"));
        
        // Buscar el plan de transporte
        PlanTransporte plan = planDao.buscarPlanPorId(idPlan);

        if (plan != null && "Pendiente".equals(plan.getEstado())) {
            // Obtener el lote
            Lote lote = loteDao.buscarLotePorId(plan.getIdLote());

            if (lote != null && lote.getStockActual() > 0) {
                // Todo el stock del lote se considera para el plan de transporte
                int cantidadADespachar = lote.getStockActual();

                // 1. Descontar todo el stock del lote (dejar en 0)
                loteDao.actualizarStock(plan.getIdLote(), 0);

                // 2. Registrar el movimiento de salida
                Movimiento movimiento = new Movimiento();
                movimiento.setLoteId(plan.getIdLote());
                movimiento.setPedidoId(null); // No es un pedido
                movimiento.setOrdenCompraId(null); // No es una orden de compra
                movimiento.setUsuarioId(usuarioId);
                movimiento.setTipoMovimiento("Salida");
                movimiento.setCantidad(cantidadADespachar);
                movimiento.setMotivo("Plan de transporte: " + plan.getNumeroPlan());
                movimientoDao.registrarMovimiento(movimiento);

                // 3. Cambiar el estado del plan de transporte a "Salida"
                planDao.actualizarEstado(idPlan, "Salida");

                // 4. ENVIAR NOTIFICACIÓN A LOGÍSTICA SOBRE EL DESPACHO DEL PLAN
                try {
                    AlertaDAO alertaDAO = new AlertaDAO();
                    
                    // Obtener emails de usuarios del rol LOGISTICA
                    ArrayList<String> emailsLogistica = alertaDAO.obtenerEmailsPorRol("LOGISTICA");
                    
                    if (!emailsLogistica.isEmpty() && plan != null) {
                        // Obtener información del lote para el correo
                        Lote loteDespachado = loteDao.buscarLotePorId(plan.getIdLote());
                        String codigoLote = (loteDespachado != null) ? loteDespachado.getCodigoLote() : "N/A";
                        
                        String mensaje = """
                            <h2>Plan de Transporte Despachado</h2>
                            <p>El plan de transporte ha sido despachado exitosamente desde almacén.</p>
                            <p><strong>Número de Plan:</strong> %s</p>
                            <p><strong>Lote:</strong> %s</p>
                            <p><strong>Cantidad Despachada:</strong> %d paquetes</p>
                            <p><strong>Fecha de Despacho:</strong> %s</p>
                            <hr>
                            <p>La mercancía está lista para ser transportada según el plan de transporte.</p>
                            <p>Por favor, coordina el transporte para la fecha de entrega programada.</p>
                            """.formatted(
                                plan.getNumeroPlan(),
                                codigoLote,
                                cantidadADespachar,
                                new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())
                            );
                        
                        // Enviar correo a todos los usuarios de logística
                        int correosEnviados = 0;
                        for (String email : emailsLogistica) {
                            boolean enviado = EmailUtil.sendSystemAlertHTML(
                                email,
                                "Plan de Transporte Despachado - Listo para Transporte",
                                mensaje
                            );
                            if (enviado) {
                                correosEnviados++;
                            }
                        }
                        
                        if (correosEnviados > 0) {
                            System.out.println("✓ Se enviaron " + correosEnviados + " correo(s) a logística sobre el plan de transporte despachado");
                        }
                    }
                } catch (Exception e) {
                    // No bloquear la operación si falla el correo
                    System.err.println("⚠ Error al enviar correo de notificación de plan de transporte despachado: " + e.getMessage());
                    e.printStackTrace();
                }
                // ========== FIN ENVÍO DE CORREO ==========

                // 5. Redirigir a la lista
                response.sendRedirect(request.getContextPath() + "/almacen/PedidoServlet");
            } else {
                // Stock insuficiente
                request.setAttribute("error", "El lote no tiene stock disponible.");
                request.setAttribute("plan", plan);
                RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/pedidos/prepararPlanTransporte.jsp");
                dispatcher.forward(request, response);
            }
        } else {
            // Plan no encontrado o ya procesado
            response.sendRedirect(request.getContextPath() + "/almacen/PedidoServlet");
        }
    }
}