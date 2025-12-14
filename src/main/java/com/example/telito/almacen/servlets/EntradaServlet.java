package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.*;
import com.example.telito.almacen.daos.*;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.util.AuthorizationHelper;
import com.example.telito.util.EmailUtil;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

// Gestión de entradas de productos al almacén (recepción de órdenes de compra)
@WebServlet("/almacen/EntradaServlet")
public class EntradaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Solo almaceneros
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAlmacen(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de almacenero intentó acceder a EntradaServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                try {
                    // Paginación
                    int registrosPorPagina = 5;
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

                    // Filtros
                    String busqueda = request.getParameter("busqueda");
                    String proveedorId = request.getParameter("proveedor");
                    String estado = request.getParameter("estado");

                    // Calcular totales y páginas
                    int totalRegistros = ordenCompraDao.contarOrdenesPendientes(busqueda, proveedorId, estado);
                    int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
                    if (totalPaginas == 0) totalPaginas = 1;
                    if (paginaActual > totalPaginas) paginaActual = totalPaginas;
                    
                    // Estadísticas generales (sin filtros)
                    int totalOrdenes = ordenCompraDao.contarTotalOrdenes();
                    int ordenesPendientes = ordenCompraDao.contarOrdenesPendientes(null, null, null);
                    int ordenesRegistradas = ordenCompraDao.contarOrdenesRegistradas();
                    
                    int offset = (paginaActual - 1) * registrosPorPagina;
                    ArrayList<OrdenCompra> listaPaginada = ordenCompraDao.listarOrdenesPaginadas(offset, registrosPorPagina, busqueda, proveedorId, estado);

                    // Cargar productores para filtro
                    request.setAttribute("listaProductores", ordenCompraDao.listarProductores());

                    request.setAttribute("listaOrdenes", listaPaginada);
                    request.setAttribute("currentPage", paginaActual);
                    request.setAttribute("size", registrosPorPagina);
                    request.setAttribute("totalPages", totalPaginas);
                    request.setAttribute("totalRows", totalRegistros);
                    request.setAttribute("totalOrdenes", totalOrdenes);
                    request.setAttribute("ordenesPendientes", ordenesPendientes);
                    request.setAttribute("ordenesRegistradas", ordenesRegistradas);
                    request.setAttribute("baseUrl", request.getContextPath() + "/almacen/EntradaServlet");
                    request.setAttribute("itemName", "órdenes");
                    request.setAttribute("busqueda", busqueda);
                    request.setAttribute("proveedorFiltro", proveedorId);

                    view = request.getRequestDispatcher("/almacen/entradas/listaOrdenes.jsp");
                    view.forward(request, response);
                } catch (Exception e) {
                    System.err.println("Error en EntradaServlet - case lista: " + e.getMessage());
                    e.printStackTrace();
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al cargar la lista de órdenes: " + e.getMessage());
                }
                break;

            case "recibir":
                int idOrden = Integer.parseInt(request.getParameter("id"));
                OrdenCompra oc = ordenCompraDao.buscarOrdenPorId(idOrden);
                request.setAttribute("ordenCompra", oc);

                // Obtener datos del lote asignado por el productor
                if (oc.getLoteId() != 0) {
                    LoteDao loteDao = new LoteDao();
                    Lote loteAsignado = loteDao.buscarLotePorId(oc.getLoteId());
                    request.setAttribute("loteAsignado", loteAsignado);
                }

                UbicacionDao ubicacionDao = new UbicacionDao();
                request.setAttribute("listaUbicaciones", ubicacionDao.listar());

                view = request.getRequestDispatcher("/almacen/entradas/registrarEntrada.jsp");
                view.forward(request, response);
                break;
        }
    }

    /**
     * MÉTODO COMPLETAMENTE MODIFICADO
     * Procesa el formulario para CREAR un nuevo lote y registrar el movimiento.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar que el usuario tenga rol de almacenero
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAlmacen(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de almacenero intentó acceder a EntradaServlet (POST) desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        ArrayList<String> errores = new ArrayList<>();
        com.example.telito.administrador.beans.Usuario usuario = 
            (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
        int usuarioId = (usuario != null) ? usuario.getIdUsuario() : 1;
        
        System.out.println("=== DEBUG: Usuario en sesión ===");
        System.out.println("Usuario ID: " + usuarioId);
        if (usuario != null) {
            System.out.println("Usuario Nombre: " + usuario.getNombres() + " " + usuario.getApellidos());
        }

        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
        LoteDao loteDao = new LoteDao();
        MovimientoDao movimientoDao = new MovimientoDao();

        // ========== VALIDACIONES DE PARÁMETROS ==========
        
        String idOrdenStr = request.getParameter("id_orden_compra");
        String idUbicacionStr = request.getParameter("ubicacion_id");
        String productoVerificacion = request.getParameter("producto_verificacion");
        String codigoLoteVerificacion = request.getParameter("codigo_lote_verificacion");
        String fechaVencimientoVerificacion = request.getParameter("fecha_vencimiento_verificacion");
        
        // 1. Validar que los parámetros obligatorios existan
        if (idOrdenStr == null || idOrdenStr.trim().isEmpty()) {
            errores.add("El ID de la orden de compra es obligatorio");
        }
        if (idUbicacionStr == null || idUbicacionStr.trim().isEmpty()) {
            errores.add("Debe seleccionar una ubicación para el lote");
        }
        if (productoVerificacion == null || productoVerificacion.trim().isEmpty()) {
            errores.add("El nombre del producto es obligatorio");
        }
        if (codigoLoteVerificacion == null || codigoLoteVerificacion.trim().isEmpty()) {
            errores.add("El código del lote es obligatorio");
        }
        if (fechaVencimientoVerificacion == null || fechaVencimientoVerificacion.trim().isEmpty()) {
            errores.add("La fecha de vencimiento es obligatoria");
        }
        
        // Si hay errores, volver al formulario
        if (!errores.isEmpty()) {
            try {
                int idOrden = Integer.parseInt(idOrdenStr);
                OrdenCompra oc = ordenCompraDao.buscarOrdenPorId(idOrden);
                request.setAttribute("errores", errores);
                request.setAttribute("ordenCompra", oc);
                
                if (oc != null && oc.getLoteId() != 0) {
                    request.setAttribute("loteAsignado", loteDao.buscarLotePorId(oc.getLoteId()));
                }
                
                UbicacionDao ubicacionDao = new UbicacionDao();
                request.setAttribute("listaUbicaciones", ubicacionDao.listar());
                
                RequestDispatcher view = request.getRequestDispatcher("/almacen/entradas/registrarEntrada.jsp");
                view.forward(request, response);
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/almacen/EntradaServlet");
            }
            return;
        }
        
        // 2. Validar que sean números válidos
        int idOrden = 0;
        int idUbicacion = 0;
        
        try {
            idOrden = Integer.parseInt(idOrdenStr);
            idUbicacion = Integer.parseInt(idUbicacionStr);
        } catch (NumberFormatException e) {
            errores.add("Los valores numéricos no son válidos");
            request.setAttribute("errores", errores);
            request.setAttribute("producto_verificacion", productoVerificacion);
            request.setAttribute("codigo_lote_verificacion", codigoLoteVerificacion);
            request.setAttribute("fecha_vencimiento_verificacion", fechaVencimientoVerificacion);
            
            UbicacionDao ubicacionDao = new UbicacionDao();
            request.setAttribute("listaUbicaciones", ubicacionDao.listar());
            
            RequestDispatcher view = request.getRequestDispatcher("/almacen/entradas/registrarEntrada.jsp");
            view.forward(request, response);
            return;
        }
        
        // 3. Validar rangos
        if (idOrden <= 0) {
            errores.add("El ID de la orden no es válido");
        }
        if (idUbicacion <= 0) {
            errores.add("Debe seleccionar una ubicación válida");
        }
        if (codigoLoteVerificacion.length() > 50) {
            errores.add("El código del lote no puede exceder 50 caracteres");
        }
        
        // 4. Validar formato de fecha
        java.sql.Date fechaVencimientoSQL = null;
        try {
            SimpleDateFormat formato = new SimpleDateFormat("yyyy-MM-dd");
            formato.setLenient(false);
            java.util.Date utilDate = formato.parse(fechaVencimientoVerificacion);
            fechaVencimientoSQL = new java.sql.Date(utilDate.getTime());
            
            // Validar que la fecha sea futura
            java.sql.Date hoy = new java.sql.Date(System.currentTimeMillis());
            if (fechaVencimientoSQL.before(hoy)) {
                errores.add("La fecha de vencimiento debe ser futura");
            }
            
            // Validar que no sea muy lejana (más de 10 años)
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.add(java.util.Calendar.YEAR, 10);
            java.sql.Date fechaMaxima = new java.sql.Date(cal.getTimeInMillis());
            if (fechaVencimientoSQL.after(fechaMaxima)) {
                errores.add("La fecha de vencimiento no puede ser mayor a 10 años");
            }
            
        } catch (Exception e) {
            errores.add("Formato de fecha inválido. Use YYYY-MM-DD");
        }
        
        // Si hay errores de formato, volver al formulario
        if (!errores.isEmpty()) {
            try {
                OrdenCompra oc = ordenCompraDao.buscarOrdenPorId(idOrden);
                request.setAttribute("errores", errores);
                request.setAttribute("ordenCompra", oc);
                request.setAttribute("producto_verificacion", productoVerificacion);
                request.setAttribute("codigo_lote_verificacion", codigoLoteVerificacion);
                request.setAttribute("fecha_vencimiento_verificacion", fechaVencimientoVerificacion);
                
                if (oc != null && oc.getLoteId() != 0) {
                    request.setAttribute("loteAsignado", loteDao.buscarLotePorId(oc.getLoteId()));
                }
                
                UbicacionDao ubicacionDao = new UbicacionDao();
                request.setAttribute("listaUbicaciones", ubicacionDao.listar());
                
                RequestDispatcher view = request.getRequestDispatcher("/almacen/entradas/registrarEntrada.jsp");
                view.forward(request, response);
            } catch (Exception ex) {
                response.sendRedirect(request.getContextPath() + "/almacen/EntradaServlet");
            }
            return;
        }

        try {
            // Datos esperados de la orden
            String productoEsperado = request.getParameter("producto_esperado");
            String codigoLoteEsperado = request.getParameter("codigo_lote_esperado");
            String fechaVencimientoEsperada = request.getParameter("fecha_vencimiento_esperada");
            
            int idDistrito = 13; // Distrito por defecto: "Cercado de Lima" (ID 13)

            // 2. Buscamos la orden de compra para obtener la cantidad y el ID del producto
            OrdenCompra oc = ordenCompraDao.buscarOrdenPorId(idOrden);
            
            System.out.println("=== VALIDACIÓN DE RECEPCIÓN ===");
            System.out.println("Producto - Esperado: " + productoEsperado + " | Recibido: " + productoVerificacion);
            System.out.println("Lote - Esperado: " + codigoLoteEsperado + " | Recibido: " + codigoLoteVerificacion);
            System.out.println("Fecha - Esperada: " + fechaVencimientoEsperada + " | Recibida: " + fechaVencimientoVerificacion);
            
            // 3. VALIDACIÓN: Verificar que el producto coincida
            if (productoVerificacion == null || !productoVerificacion.trim().equalsIgnoreCase(productoEsperado.trim())) {
                System.err.println("❌ VALIDACIÓN FALLIDA: Producto no coincide");
                
                request.setAttribute("error", "⚠️ CAMPOS INCORRECTOS: El nombre del producto no coincide. Esperado: '" + productoEsperado + "' | Recibido: '" + productoVerificacion + "'");
                request.setAttribute("ordenCompra", oc);
                
                if (oc.getLoteId() != 0) {
                    LoteDao loteDao2 = new LoteDao();
                    request.setAttribute("loteAsignado", loteDao2.buscarLotePorId(oc.getLoteId()));
                }
                
                UbicacionDao ubicacionDao2 = new UbicacionDao();
                request.setAttribute("listaUbicaciones", ubicacionDao2.listar());
                
                RequestDispatcher view = request.getRequestDispatcher("/almacen/entradas/registrarEntrada.jsp");
                view.forward(request, response);
                return;
            }
            
            // 4. VALIDACIÓN: Verificar que el código de lote coincida (si hay lote asignado)
            if (codigoLoteEsperado != null && !codigoLoteEsperado.isEmpty()) {
                if (codigoLoteVerificacion == null || !codigoLoteVerificacion.trim().equals(codigoLoteEsperado.trim())) {
                    System.err.println("❌ VALIDACIÓN FALLIDA: Código de lote no coincide");
                    
                    request.setAttribute("error", "⚠️ CAMPOS INCORRECTOS: El código del lote no coincide. Esperado: '" + codigoLoteEsperado + "' | Recibido: '" + codigoLoteVerificacion + "'");
                    request.setAttribute("ordenCompra", oc);
                    
                    if (oc.getLoteId() != 0) {
                        LoteDao loteDao2 = new LoteDao();
                        request.setAttribute("loteAsignado", loteDao2.buscarLotePorId(oc.getLoteId()));
                    }
                    
                    UbicacionDao ubicacionDao2 = new UbicacionDao();
                    request.setAttribute("listaUbicaciones", ubicacionDao2.listar());
                    
                    RequestDispatcher view = request.getRequestDispatcher("/almacen/entradas/registrarEntrada.jsp");
                    view.forward(request, response);
                    return;
                }
            }
            
            // 5. VALIDACIÓN: Verificar que la fecha de vencimiento coincida (si hay lote asignado)
            if (fechaVencimientoEsperada != null && !fechaVencimientoEsperada.isEmpty()) {
                if (fechaVencimientoVerificacion == null || !fechaVencimientoVerificacion.equals(fechaVencimientoEsperada)) {
                    System.err.println("❌ VALIDACIÓN FALLIDA: Fecha de vencimiento no coincide");
                    
                    request.setAttribute("error", "⚠️ CAMPOS INCORRECTOS: La fecha de vencimiento no coincide. Esperada: '" + fechaVencimientoEsperada + "' | Recibida: '" + fechaVencimientoVerificacion + "'");
                    request.setAttribute("ordenCompra", oc);
                    
                    if (oc.getLoteId() != 0) {
                        LoteDao loteDao2 = new LoteDao();
                        request.setAttribute("loteAsignado", loteDao2.buscarLotePorId(oc.getLoteId()));
                    }
                    
                    UbicacionDao ubicacionDao2 = new UbicacionDao();
                    request.setAttribute("listaUbicaciones", ubicacionDao2.listar());
                    
                    RequestDispatcher view = request.getRequestDispatcher("/almacen/entradas/registrarEntrada.jsp");
                    view.forward(request, response);
                    return;
                }
            }
            
            System.out.println("✓ VALIDACIÓN EXITOSA: Todos los campos coinciden");

            // 6. ACTUALIZAR el lote existente del productor (no crear uno nuevo)
            // El productor ya creó el lote y lo asignó a la orden
            int loteProductorId = oc.getLoteId();
            int cantidadRecibida = oc.getCantidad();
            
            if (loteProductorId <= 0) {
                throw new Exception("La orden no tiene un lote asignado por el productor");
            }
            
            // Obtener el lote del productor
            Lote loteProductor = loteDao.buscarLotePorId(loteProductorId);
            if (loteProductor == null) {
                throw new Exception("No se encontró el lote asignado por el productor: " + loteProductorId);
            }
            
            System.out.println("✓ Lote del productor encontrado:");
            System.out.println("  - ID: " + loteProductor.getIdLote());
            System.out.println("  - Código: " + loteProductor.getCodigoLote());
            System.out.println("  - Stock actual: " + loteProductor.getStockActual());
            System.out.println("  - Ubicación actual: " + loteProductor.getUbicacionId());
            
            // Verificar que el código de lote coincida
            if (!codigoLoteVerificacion.equals(loteProductor.getCodigoLote())) {
                throw new Exception("El código de lote verificado no coincide con el lote asignado");
            }
            
            // Obtener unidades_por_paquete del producto para calcular el stock en unidades
            int unidadesPorPaquete = 1; // Valor por defecto
            String sqlUnidades = "SELECT unidades_por_paquete FROM productos WHERE id_producto = ?";
            Connection connTemp = null;
            PreparedStatement pstmtTemp = null;
            ResultSet rsTemp = null;
            try {
                connTemp = com.example.telito.util.DatabaseConnection.getConnection();
                pstmtTemp = connTemp.prepareStatement(sqlUnidades);
                pstmtTemp.setInt(1, oc.getProductoId());
                rsTemp = pstmtTemp.executeQuery();
                if (rsTemp.next()) {
                    unidadesPorPaquete = rsTemp.getInt("unidades_por_paquete");
                }
            } catch (Exception e) {
                System.err.println("⚠️ Error al obtener unidades_por_paquete: " + e.getMessage());
            } finally {
                try {
                    if (rsTemp != null) rsTemp.close();
                    if (pstmtTemp != null) pstmtTemp.close();
                    if (connTemp != null) connTemp.close();
                } catch (Exception e) {
                    System.err.println("Error al cerrar recursos: " + e.getMessage());
                }
            }
            
            // Calcular la cantidad recibida en unidades
            int cantidadRecibidaUnidades = cantidadRecibida * unidadesPorPaquete;
            
            // RESTAURAR el stock del lote: cuando el almacén recibe la mercancía,
            // el stock debe restaurarse porque ahora está físicamente en el almacén
            // El stock se había descontado cuando el productor asignó el lote a la orden
            int stockActual = loteProductor.getStockActual();
            int nuevoStock = stockActual + cantidadRecibidaUnidades;
            
            System.out.println("=== RESTAURACIÓN DE STOCK ===");
            System.out.println("Cantidad recibida: " + cantidadRecibida + " paquetes = " + cantidadRecibidaUnidades + " unidades");
            System.out.println("Stock actual del lote: " + stockActual + " unidades");
            System.out.println("Nuevo stock después de restaurar: " + nuevoStock + " unidades (" + (nuevoStock / unidadesPorPaquete) + " paquetes)");
            
            // ACTUALIZAR el lote existente: cambiar ubicación, estado y restaurar stock
            loteDao.actualizarUbicacionYEstado(loteProductorId, idUbicacion, idDistrito, "Registrado");
            loteDao.actualizarStock(loteProductorId, nuevoStock);
            System.out.println("✓ Lote actualizado - Nueva ubicación: " + idUbicacion + " | Estado: Registrado | Stock restaurado: " + nuevoStock + " unidades");

            // 7. Registramos el movimiento de entrada (usando el lote existente)
            // IMPORTANTE: Registrar la cantidad en UNIDADES, no en paquetes, para consistencia
            Movimiento movimiento = new Movimiento();
            movimiento.setLoteId(loteProductorId); // Usar el lote existente
            movimiento.setUsuarioId(usuarioId);
            movimiento.setOrdenCompraId(idOrden);
            movimiento.setTipoMovimiento("Entrada");
            movimiento.setCantidad(cantidadRecibidaUnidades); // Registrar en unidades, no en paquetes
            movimiento.setMotivo("Recepción de OC: " + oc.getNumeroOrden());
            movimientoDao.registrarMovimiento(movimiento);

            // 8. Actualizamos el estado de la orden a "Aprobado" (ciclo completo)
            ordenCompraDao.actualizarEstado(idOrden, "Aprobado");

            // 10. ========== ENVÍO DE CORREO A LOGÍSTICA ==========
            // Notificar a logística que la entrada fue registrada exitosamente
            try {
                // Obtener el usuario_id de logística que creó la orden
                int usuarioIdLogistica = ordenCompraDao.obtenerUsuarioIdLogistica(idOrden);
                
                if (usuarioIdLogistica > 0) {
                    System.out.println("=== ENVIANDO CORREO A LOGÍSTICA ===");
                    System.out.println("Usuario ID de logística: " + usuarioIdLogistica);
                    
                    // Obtener email del usuario de logística
                    UsuarioDAO usuarioDAO = new UsuarioDAO();
                    String emailLogistica = usuarioDAO.obtenerEmailPorId(usuarioIdLogistica);
                    
                    if (emailLogistica != null && !emailLogistica.trim().isEmpty()) {
                        System.out.println("✓ Email obtenido: " + emailLogistica);
                        
                        // Obtener información del lote para el correo (ahora es el lote del productor actualizado)
                        Lote loteRegistrado = loteDao.buscarLotePorId(loteProductorId);
                        String codigoLote = (loteRegistrado != null) ? loteRegistrado.getCodigoLote() : "N/A";
                        
                        String asunto = "TELITO BODEGUERO - Entrada de Inventario Registrada";
                        String mensaje = """
                            <h2>¡Entrada de Inventario Registrada Exitosamente!</h2>
                            <p>El personal de almacén ha registrado la entrada de la orden de compra que creaste.</p>
                            <p><strong>Número de Orden:</strong> %s</p>
                            <p><strong>Producto:</strong> %s</p>
                            <p><strong>Cantidad:</strong> %d paquetes</p>
                            <p><strong>Código de Lote:</strong> %s</p>
                            <p><strong>Fecha de Registro:</strong> %s</p>
                            <hr>
                            <p><strong>Estado:</strong> La mercancía ha sido recibida y registrada en el almacén.</p>
                            <p>La orden está ahora completa y el producto está disponible en el inventario.</p>
                            """.formatted(
                                oc.getNumeroOrden(),
                                oc.getNombreProducto(),
                                oc.getCantidad(),
                                codigoLote,
                                new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())
                            );
                        
                        // Enviar correo HTML
                        System.out.println("Enviando correo a: " + emailLogistica);
                        boolean correoEnviado = EmailUtil.sendSystemAlertHTML(
                            emailLogistica,
                            asunto,
                            mensaje
                        );
                        
                        if (correoEnviado) {
                            System.out.println("✓✓✓ Correo enviado exitosamente a logística: " + emailLogistica);
                        } else {
                            System.err.println("⚠⚠⚠ No se pudo enviar el correo a logística: " + emailLogistica);
                        }
                    } else {
                        System.err.println("⚠ Usuario de logística no tiene email configurado. ID: " + usuarioIdLogistica);
                    }
                } else {
                    System.err.println("⚠ No se encontró el usuario de logística para la orden ID: " + idOrden);
                }
            } catch (Exception e) {
                // No bloquear la operación si falla el correo
                System.err.println("⚠ Error al enviar correo a logística: " + e.getMessage());
                e.printStackTrace();
            }
            // ========== FIN ENVÍO DE CORREO A LOGÍSTICA ==========

            // 11. Establecer mensaje de éxito en la sesión
            session.setAttribute("successMsg", "✓ Recepción de productos en el almacén según la orden de compra confirmada exitosamente.");

            // 12. Redirigimos de vuelta al módulo de Registrar Entradas
            response.sendRedirect(request.getContextPath() + "/almacen/EntradaServlet?action=lista");

        } catch (Exception e) {
            e.printStackTrace();
            // Si algo falla, volvemos a mostrar el formulario con un mensaje de error
            request.setAttribute("error", "Ocurrió un error al procesar la entrada. Verifique todos los datos.");
            request.setAttribute("ordenCompra", ordenCompraDao.buscarOrdenPorId(idOrden));
            
            UbicacionDao ubicacionDao3 = new UbicacionDao();
            request.setAttribute("listaUbicaciones", ubicacionDao3.listar());
            
            RequestDispatcher view = request.getRequestDispatcher("/almacen/entradas/registrarEntrada.jsp");
            view.forward(request, response);
        }
    }
}