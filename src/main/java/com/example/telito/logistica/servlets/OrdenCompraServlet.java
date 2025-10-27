package com.example.telito.logistica.servlets;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.example.telito.logistica.beans.OrdenCompraBean;
import com.example.telito.logistica.beans.ProductoBean;
import com.example.telito.logistica.beans.DistritoBean;
import com.example.telito.logistica.daos.OrdenCompraDao;
import com.example.telito.logistica.daos.ProductoDao;
import com.example.telito.logistica.daos.ProveedorDao;
import com.example.telito.logistica.daos.ZonaDao;
import com.example.telito.logistica.daos.DistritoDao;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "OrdenCompraServlet", value = "/orden-compra")
public class OrdenCompraServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");

        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
        ProductoDao productoDao = new ProductoDao();
        ProveedorDao proveedorDao = new ProveedorDao();
        RequestDispatcher rd;

        switch (action) {
            case "listar":
                // === SECCIÓN MODIFICADA PARA MANEJAR FILTROS ===

                // 1. Leemos los parámetros del formulario de búsqueda
                String busqueda = request.getParameter("busqueda");
                String proveedorId = request.getParameter("proveedor");
                String estado = request.getParameter("estado");

                // 2. Obtenemos la lista de órdenes (ahora filtrada)
                //    Pasamos los filtros al método del DAO
                ArrayList<OrdenCompraBean> listaOrdenes = ordenCompraDao.obtenerOrdenes(busqueda, proveedorId, estado);

                // 3. Obtenemos la lista de proveedores para el menú del filtro
                request.setAttribute("listaProveedores", proveedorDao.listarProveedores());

                // 4. Enviamos la lista de órdenes filtrada a la vista
                request.setAttribute("listaOrdenes", listaOrdenes);

                rd = request.getRequestDispatcher("/logistica/OrdenLista/purchase-order.jsp");
                rd.forward(request, response);
                break;

            case "crear":
                request.setAttribute("listaProductos", productoDao.listarProductos());
                request.setAttribute("listaProductores", proveedorDao.listarProductores());
                ZonaDao zonaDao = new ZonaDao();
                request.setAttribute("listaZonas", zonaDao.listarZonas());
                rd = request.getRequestDispatcher("/logistica/OrdenLista/form_orden_compra.jsp");
                rd.forward(request, response);
                break;
                
            case "obtenerProductosPorProductor":
                // Endpoint JSON: obtener productos de un productor
                int productorId = Integer.parseInt(request.getParameter("productorId"));
                ArrayList<ProductoBean> productos = productoDao.listarProductosPorProductor(productorId);
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                // Construir JSON manualmente
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < productos.size(); i++) {
                    ProductoBean p = productos.get(i);
                    if (i > 0) json.append(",");
                    json.append("{")
                        .append("\"id\":").append(p.getId()).append(",")
                        .append("\"nombre\":\"").append(p.getNombre().replace("\"", "\\\"")).append("\",")
                        .append("\"precio\":").append(p.getPrecio()).append(",")
                        .append("\"unidades_por_paquete\":").append(p.getUnidadesPorPaquete())
                        .append("}");
                }
                json.append("]");
                
                response.getWriter().write(json.toString());
                return;
                
            case "obtenerDistritosPorZona":
                // Endpoint JSON: obtener distritos de una zona
                int zonaId = Integer.parseInt(request.getParameter("zonaId"));
                DistritoDao distritoDao = new DistritoDao();
                ArrayList<DistritoBean> distritos = distritoDao.listarDistritosPorZona(zonaId);
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                // Construir JSON manualmente
                StringBuilder jsonDistritos = new StringBuilder("[");
                for (int i = 0; i < distritos.size(); i++) {
                    DistritoBean d = distritos.get(i);
                    if (i > 0) jsonDistritos.append(",");
                    jsonDistritos.append("{")
                        .append("\"id\":").append(d.getId()).append(",")
                        .append("\"nombre\":\"").append(d.getNombre().replace("\"", "\\\"")).append("\"")
                        .append("}");
                }
                jsonDistritos.append("]");
                
                response.getWriter().write(jsonDistritos.toString());
                return;
                
            case "obtenerDetalle":
                // Endpoint JSON: obtener detalles completos de una orden
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                try {
                    int idOrden = Integer.parseInt(request.getParameter("idOrden"));
                    System.out.println("=== DEBUG SERVLET - OBTENER DETALLE ORDEN ===");
                    System.out.println("ID Orden: " + idOrden);
                    
                    // Obtener detalles de la orden incluyendo el lote
                    Object[] detalle = ordenCompraDao.obtenerDetalleConLote(idOrden);
                    
                    if (detalle != null) {
                        // Construir JSON con los detalles
                        StringBuilder jsonDetalle = new StringBuilder();
                        jsonDetalle.append("{\"success\":true,")
                            .append("\"productor\":\"").append(detalle[0] != null ? detalle[0].toString().replace("\"", "\\\"") : "").append("\",")
                            .append("\"personalResponsable\":\"").append(detalle[1] != null ? detalle[1].toString().replace("\"", "\\\"") : "").append("\",")
                            .append("\"producto\":\"").append(detalle[2] != null ? detalle[2].toString().replace("\"", "\\\"") : "").append("\",")
                            .append("\"sku\":\"").append(detalle[3] != null ? detalle[3].toString() : "").append("\",")
                            .append("\"cantidad\":").append(detalle[4] != null ? detalle[4] : 0).append(",")
                            .append("\"montoTotal\":\"").append(detalle[5] != null ? detalle[5].toString() : "").append("\",")
                            .append("\"estado\":\"").append(detalle[6] != null ? detalle[6].toString() : "").append("\",")
                            .append("\"codigoLote\":\"").append(detalle[7] != null ? detalle[7].toString() : "N/A").append("\",")
                            .append("\"fechaVencimiento\":\"").append(detalle[8] != null ? detalle[8].toString() : "").append("\",")
                            .append("\"stockDisponible\":").append(detalle[9] != null ? detalle[9] : 0).append(",")
                            .append("\"ubicacion\":\"").append(detalle[10] != null ? detalle[10].toString().replace("\"", "\\\"") : "N/A").append("\"")
                            .append("}");
                        
                        System.out.println("✓ Detalle encontrado");
                        response.getWriter().write(jsonDetalle.toString());
                    } else {
                        System.out.println("❌ Orden no encontrada");
                        response.getWriter().write("{\"success\":false,\"message\":\"Orden no encontrada\"}");
                    }
                } catch (NumberFormatException e) {
                    System.err.println("❌ ERROR: ID inválido - " + e.getMessage());
                    response.getWriter().write("{\"success\":false,\"message\":\"ID de orden inválido\"}");
                } catch (Exception e) {
                    System.err.println("❌ ERROR: " + e.getMessage());
                    e.printStackTrace();
                    response.getWriter().write("{\"success\":false,\"message\":\"Error interno\"}");
                }
                return;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // (El método doPost para guardar no cambia)
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();

        if ("guardar".equals(action)) {
            try {
                // Obtener el ID del usuario de logística que está logueado
                com.example.telito.administrador.beans.Usuario usuario = 
                    (com.example.telito.administrador.beans.Usuario) request.getSession().getAttribute("usuario");
                
                if (usuario == null) {
                    response.sendRedirect(request.getContextPath() + "/acceso/login");
                    return;
                }
                
                int usuarioId = usuario.getIdUsuario();
                
                // Parsear parámetros del formulario
                int productorId = Integer.parseInt(request.getParameter("productor_id"));
                int productoId = Integer.parseInt(request.getParameter("producto_id"));
                int cantidad = Integer.parseInt(request.getParameter("cantidad"));
                int distritoId = Integer.parseInt(request.getParameter("distrito_id"));
                double montoTotal = Double.parseDouble(request.getParameter("monto_total"));
                
                System.out.println("=== DEBUG SERVLET - ORDEN DE COMPRA ===");
                System.out.println("Productor ID: " + productorId);
                System.out.println("Producto ID: " + productoId);
                System.out.println("Cantidad: " + cantidad);
                System.out.println("Distrito ID: " + distritoId);
                System.out.println("Monto Total: " + montoTotal);
                System.out.println("Usuario ID (Logística): " + usuarioId);
                
                // Guardar la orden de compra con el ID del usuario logueado
                boolean guardado = ordenCompraDao.crearOrdenCompra(null, productorId, productoId, cantidad, usuarioId, montoTotal, distritoId);
                
                if (guardado) {
                    System.out.println("✓ SERVLET: Orden guardada exitosamente");
                    response.sendRedirect(request.getContextPath() + "/orden-compra");
                } else {
                    System.err.println("❌ SERVLET: Fallo al guardar la orden");
                    response.sendRedirect(request.getContextPath() + "/orden-compra?error=database");
                }
                
            } catch (NumberFormatException e) {
                System.err.println("ERROR: Formato de número inválido - " + e.getMessage());
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/orden-compra?error=formato");
            } catch (Exception e) {
                System.err.println("ERROR: Error al guardar orden de compra - " + e.getMessage());
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/orden-compra?error=sql");
            }
        } else if ("cambiarEstado".equals(action)) {
            // Cambiar el estado de una orden (Aprobar o Rechazar)
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            try {
                int idOrden = Integer.parseInt(request.getParameter("idOrden"));
                String nuevoEstado = request.getParameter("nuevoEstado");
                
                System.out.println("=== DEBUG SERVLET - CAMBIAR ESTADO ORDEN ===");
                System.out.println("ID Orden: " + idOrden);
                System.out.println("Nuevo Estado: " + nuevoEstado);
                
                // Validar que el estado sea válido
                if (!"Aprobado".equals(nuevoEstado) && !"Rechazado".equals(nuevoEstado)) {
                    response.getWriter().write("{\"success\":false,\"message\":\"Estado inválido\"}");
                    return;
                }
                
                OrdenCompraDao ordenCompraDao2 = new OrdenCompraDao();
                boolean actualizado = ordenCompraDao2.actualizarEstadoOrden(idOrden, nuevoEstado);
                
                if (actualizado) {
                    System.out.println("✓ Estado actualizado correctamente");
                    response.getWriter().write("{\"success\":true,\"message\":\"Estado actualizado\"}");
                } else {
                    System.err.println("❌ No se pudo actualizar el estado");
                    response.getWriter().write("{\"success\":false,\"message\":\"No se pudo actualizar el estado\"}");
                }
                
            } catch (NumberFormatException e) {
                System.err.println("❌ ERROR: Parámetros inválidos - " + e.getMessage());
                response.getWriter().write("{\"success\":false,\"message\":\"Parámetros inválidos\"}");
            } catch (Exception e) {
                System.err.println("❌ ERROR: " + e.getMessage());
                e.printStackTrace();
                response.getWriter().write("{\"success\":false,\"message\":\"Error interno\"}");
            }
        } else {
            doGet(request, response);
        }
    }
}