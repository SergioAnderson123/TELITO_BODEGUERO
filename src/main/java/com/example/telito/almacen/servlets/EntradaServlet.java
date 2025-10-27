package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.*;
import com.example.telito.almacen.daos.*;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

@WebServlet("/almacen/EntradaServlet")
public class EntradaServlet extends HttpServlet {

    /**
     * El método doGet no necesita cambios.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                int registrosPorPagina = 10;
                String pageStr = request.getParameter("page");
                int paginaActual = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
                int totalRegistros = ordenCompraDao.contarOrdenesPendientes();
                int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
                int offset = (paginaActual - 1) * registrosPorPagina;
                ArrayList<OrdenCompra> listaPaginada = ordenCompraDao.listarOrdenesPaginadas(offset, registrosPorPagina);

                request.setAttribute("listaOrdenes", listaPaginada);
                request.setAttribute("paginaActual", paginaActual);
                request.setAttribute("totalPaginas", totalPaginas);

                view = request.getRequestDispatcher("/almacen/entradas/listaOrdenes.jsp");
                view.forward(request, response);
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

        HttpSession session = request.getSession();
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

        int idOrden = Integer.parseInt(request.getParameter("id_orden_compra"));

        try {
            // 1. Leemos los datos del formulario
            int idUbicacion = Integer.parseInt(request.getParameter("ubicacion_id"));
            int idDistrito = 13; // Distrito por defecto: "Cercado de Lima" (ID 13)
            
            // Datos de verificación del almacenero
            String productoVerificacion = request.getParameter("producto_verificacion");
            String codigoLoteVerificacion = request.getParameter("codigo_lote_verificacion");
            String fechaVencimientoVerificacion = request.getParameter("fecha_vencimiento_verificacion");
            
            // Datos esperados de la orden
            String productoEsperado = request.getParameter("producto_esperado");
            String codigoLoteEsperado = request.getParameter("codigo_lote_esperado");
            String fechaVencimientoEsperada = request.getParameter("fecha_vencimiento_esperada");

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

            // 6. El lote ya fue asignado por el productor, usamos ese lote_id
            int loteId = oc.getLoteId();
            
            if (loteId == 0) {
                // Si por alguna razón no hay lote asignado, creamos uno nuevo
                SimpleDateFormat formato = new SimpleDateFormat("yyyy-MM-dd");
                java.util.Date utilDate = formato.parse(fechaVencimientoVerificacion);
                java.sql.Date fechaVencimientoSQL = new java.sql.Date(utilDate.getTime());
                
                Lote nuevoLote = new Lote();
                nuevoLote.setCodigoLote(codigoLoteVerificacion);
                nuevoLote.setStockActual(oc.getCantidad());
                nuevoLote.setFechaVencimiento(fechaVencimientoSQL);
                nuevoLote.setProductoId(oc.getProductoId());
                nuevoLote.setUbicacionId(idUbicacion);
                nuevoLote.setDistritoId(idDistrito);
                nuevoLote.setEstado("Registrado");
                loteId = loteDao.crearLote(nuevoLote);
                System.out.println("⚠️ Se creó un nuevo lote porque no había uno asignado: " + loteId);
            } else {
                System.out.println("✓ Usando lote asignado por productor: " + loteId);
                // Actualizar la ubicación del lote existente
                loteDao.actualizarUbicacion(loteId, idUbicacion);
                // Actualizar el estado a "Registrado" para que aparezca en Gestión de Inventario
                loteDao.registrarLote(loteId);
            }

            // 7. Registramos el movimiento de entrada
            Movimiento movimiento = new Movimiento();
            movimiento.setLoteId(loteId);
            movimiento.setUsuarioId(usuarioId);
            movimiento.setOrdenCompraId(idOrden);
            movimiento.setTipoMovimiento("Entrada");
            movimiento.setCantidad(oc.getCantidad());
            movimiento.setMotivo("Recepción de OC: " + oc.getNumeroOrden());
            movimientoDao.registrarMovimiento(movimiento);

            // 8. Actualizamos el estado de la orden a "Aprobado" (ciclo completo)
            ordenCompraDao.actualizarEstado(idOrden, "Aprobado");

            // 9. Redirigimos a la lista de inventario para ver el lote
            response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");

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