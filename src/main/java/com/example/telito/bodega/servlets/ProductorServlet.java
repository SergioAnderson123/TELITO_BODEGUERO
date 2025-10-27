package com.example.telito.bodega.servlets;
import com.example.telito.bodega.daos.LoteDao;
import com.example.telito.bodega.daos.OrdenCompraDao;
import com.example.telito.bodega.beans.Categoria;
import com.example.telito.bodega.beans.Producto;
import com.example.telito.bodega.beans.Usuario;
import com.example.telito.bodega.daos.ProductoDao;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Este Servlet actúa como el Controlador para todas las acciones
 * relacionadas con el rol de Productor.
 */
@WebServlet("/ProductorServlet")
public class ProductorServlet extends HttpServlet {

    /**
     * Maneja las peticiones GET (generalmente para mostrar páginas).
     * Ej: /ProductorServlet?action=listarProductos
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {


        // Si no se especifica una acción, la acción por defecto será 'listarProductos'
        String action = request.getParameter("action") == null ? "listarProductos" : request.getParameter("action");

        // Obtener el ID del productor desde la sesión
        com.example.telito.administrador.beans.Usuario usuarioSesion = 
            (com.example.telito.administrador.beans.Usuario) request.getSession().getAttribute("usuario");
        
        if (usuarioSesion == null) {
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }
        
        final int idProductor = usuarioSesion.getIdUsuario();
        
        ProductoDao productoDao = new ProductoDao();
        LoteDao loteDao = new LoteDao();

        switch (action) {
            case "listarProductos":
                // Obtener la lista de productos del productor logueado
                ArrayList<Producto> listaProductos = productoDao.listarProductosPorProductor(idProductor);

                // Obtener estadísticas del productor
                int totalProductos = productoDao.contarTotalProductos(idProductor);
                int fueraDeStock = productoDao.contarProductosFueraDeStock(idProductor);
                int totalCategorias = productoDao.contarTotalCategorias(idProductor);
                ArrayList<Categoria> todasLasCategorias = productoDao.listarTodasLasCategorias();

                // Enviar datos a la vista
                request.setAttribute("listaProductos", listaProductos);
                request.setAttribute("totalProductos", totalProductos);
                request.setAttribute("fueraDeStock", fueraDeStock);
                request.setAttribute("totalCategorias", totalCategorias);
                request.setAttribute("todasLasCategorias", todasLasCategorias);

                RequestDispatcher view = request.getRequestDispatcher("productor/misProductos.jsp");
                view.forward(request, response);
                break;

            case "formRegistrarLote":
                // Simplemente redirige al formulario de registro de lotes
                view = request.getRequestDispatcher("productor/registrarLotes.jsp");
                view.forward(request, response);
                break;

            case "formActualizarPrecios":
                // Buscar por SKU (si viene) y mostrar el formulario de actualización de precio
                String skuBusqueda = request.getParameter("sku");
                if (skuBusqueda != null && !skuBusqueda.trim().isEmpty()) {
                    Producto prod = productoDao.obtenerProductoPorSku(skuBusqueda.trim());
                    if (prod != null) {
                        // También enviamos el SKU para mantenerlo en la URL si lo necesitas
                        request.setAttribute("producto", prod);
                    }
                }
                view = request.getRequestDispatcher("productor/actualizarPrecios.jsp");
                view.forward(request, response);
                break;

            case "ordenesCompra":
                // Cargar las órdenes de compra del productor logueado
                OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
                List<Object[]> listaOrdenes = ordenCompraDao.listarOrdenesPorProductor(idProductor);
                
                request.setAttribute("listaOrdenes", listaOrdenes);
                view = request.getRequestDispatcher("productor/ordenesDeCompra.jsp");
                view.forward(request, response);
                break;
                
            case "verDetalleOrden":
                // Ver detalle de una orden de compra (JSON o JSP)
                int idOrden = Integer.parseInt(request.getParameter("idOrden"));
                OrdenCompraDao ordenDao = new OrdenCompraDao();
                Object[] detalleOrden = ordenDao.obtenerDetalleOrden(idOrden);
                
                if (detalleOrden != null) {
                    request.setAttribute("detalleOrden", detalleOrden);
                    view = request.getRequestDispatcher("productor/ordenesDeCompra.jsp");
                    view.forward(request, response);
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Orden no encontrada");
                }
                break;
            // Aquí puedes agregar más 'cases' para navegar a otras páginas
            case "buscarProductoPorSkuJson":
                String sku = request.getParameter("sku");
                String sanitizedSku = (sku == null) ? "" : sku.trim();

                // Usamos el método que ya existe en LoteDao
                String nombreProducto = null;
                if (!sanitizedSku.isEmpty()) {
                    nombreProducto = loteDao.obtenerNombreProductoPorSKU(sanitizedSku);
                }

                // Configuramos la respuesta para que sea de tipo JSON
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");

                // Respuesta JSON segura
                String safeNombre = (nombreProducto == null) ? "" : nombreProducto.replace("\\", "\\\\").replace("\"", "\\\"");
                String json = "{\"nombre\": \"" + safeNombre + "\"}";
                response.getWriter().write(json);
                return; // Usamos 'return' para terminar aquí, ya que no es una página completa

            case "obtenerNuevoSKU":
                // Endpoint para obtener el siguiente SKU disponible
                ProductoDao productoDAO = new ProductoDao();
                String nuevoSKU = productoDAO.generarNuevoSKU();
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"sku\": \"" + nuevoSKU + "\"}");
                return;

            case "obtenerNuevoCodigoLote":
                // Endpoint para obtener el siguiente código de lote disponible
                LoteDao loteDaoGet = new LoteDao();
                String nuevoCodigo = loteDaoGet.generarNuevoCodigoLote();
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"codigo\": \"" + nuevoCodigo + "\"}");
                return;

            case "obtenerLotesParaOrden":
                // Endpoint para obtener los lotes disponibles para asignar a una orden
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                try {
                    int idOrdenLotes = Integer.parseInt(request.getParameter("idOrden"));
                    
                    System.out.println("=== DEBUG SERVLET - OBTENER LOTES PARA ORDEN ===");
                    System.out.println("ID Orden: " + idOrdenLotes);
                    
                    // Obtener el producto_id de la orden
                    OrdenCompraDao ordenCompraDao2 = new OrdenCompraDao();
                    Object[] detalleOrden2 = ordenCompraDao2.obtenerDetalleOrden(idOrdenLotes);
                    
                    if (detalleOrden2 == null) {
                        response.getWriter().write("{\"success\": false, \"message\": \"Orden no encontrada\"}");
                        return;
                    }
                    
                    // Necesitamos obtener el producto_id de la orden
                    // Para esto, necesitamos modificar el método obtenerDetalleOrden o crear uno nuevo
                    // Por ahora, vamos a hacer una consulta directa
                    int productoId = obtenerProductoIdDeOrden(idOrdenLotes);
                    
                    if (productoId == 0) {
                        response.getWriter().write("{\"success\": false, \"message\": \"No se pudo obtener el producto de la orden\"}");
                        return;
                    }
                    
                    // Obtener los lotes disponibles para este producto
                    LoteDao loteDao2 = new LoteDao();
                    List<Object[]> lotes = loteDao2.obtenerLotesDisponiblesParaProducto(productoId);
                    
                    System.out.println("✓ Producto ID: " + productoId);
                    System.out.println("✓ Lotes encontrados: " + lotes.size());
                    
                    // Construir JSON de respuesta
                    StringBuilder jsonLotes = new StringBuilder();
                    jsonLotes.append("{\"success\":true,\"productoId\":").append(productoId).append(",\"lotes\":[");
                    
                    for (int i = 0; i < lotes.size(); i++) {
                        Object[] lote = lotes.get(i);
                        if (i > 0) jsonLotes.append(",");
                        
                        // Debug: Imprimir cada campo del lote
                        System.out.println("  Lote " + i + ":");
                        System.out.println("    [0] ID: " + lote[0]);
                        System.out.println("    [1] Código: " + lote[1]);
                        System.out.println("    [2] SKU: " + lote[2]);
                        System.out.println("    [3] Producto: " + lote[3]);
                        System.out.println("    [4] Paquetes: " + lote[4]);
                        System.out.println("    [5] Stock Actual: " + lote[5]);
                        System.out.println("    [6] Fecha Venc: " + lote[6]);
                        
                        String codigoLote = (lote[1] != null) ? lote[1].toString() : "";
                        String skuLote = (lote[2] != null) ? lote[2].toString() : "";
                        String productoNombre = (lote[3] != null) ? lote[3].toString().replace("\"", "\\\"") : "";
                        String fechaVenc = (lote[6] != null) ? lote[6].toString() : "";
                        
                        jsonLotes.append("{")
                            .append("\"id\":").append(lote[0]).append(",")
                            .append("\"codigoLote\":\"").append(codigoLote).append("\",")
                            .append("\"sku\":\"").append(skuLote).append("\",")
                            .append("\"producto\":\"").append(productoNombre).append("\",")
                            .append("\"paquetes\":").append(lote[4]).append(",")
                            .append("\"stockActual\":").append(lote[5]).append(",")
                            .append("\"fechaVencimiento\":\"").append(fechaVenc).append("\"")
                            .append("}");
                    }
                    
                    jsonLotes.append("]}");
                    
                    String jsonResponse = jsonLotes.toString();
                    System.out.println("✓ JSON completo: " + jsonResponse);
                    response.getWriter().write(jsonResponse);
                    
                } catch (NumberFormatException e) {
                    System.err.println("❌ ERROR: ID de orden inválido");
                    response.getWriter().write("{\"success\": false, \"message\": \"ID de orden inválido\"}");
                } catch (Exception e) {
                    System.err.println("❌ ERROR: " + e.getMessage());
                    e.printStackTrace();
                    response.getWriter().write("{\"success\": false, \"message\": \"Error interno del servidor\"}");
                }
                return;

        }
    }
    
    /**
     * Método auxiliar para obtener el producto_id de una orden
     */
    private int obtenerProductoIdDeOrden(int idOrden) {
        String sql = "SELECT producto_id FROM ordenes_compra WHERE id_orden_compra = ?";
        try (Connection conn = com.example.telito.util.DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idOrden);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("producto_id");
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR: Error al obtener producto_id de orden: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Maneja las peticiones POST (generalmente para procesar formularios).
     * Ej: el formulario del modal "Agregar Producto"
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        ProductoDao productoDao = new ProductoDao();
        
        // Obtener el ID del productor desde la sesión
        com.example.telito.administrador.beans.Usuario usuarioSesion = 
            (com.example.telito.administrador.beans.Usuario) request.getSession().getAttribute("usuario");
        
        if (usuarioSesion == null) {
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }
        
        final int idProductor = usuarioSesion.getIdUsuario();

        switch(action) {
            case "crearProducto":
                // 1. Leemos los datos enviados desde el formulario
                String nombre = request.getParameter("productName");
                String desc = request.getParameter("productDescription");
                double precio = Double.parseDouble(request.getParameter("productPrice"));
                int categoriaId = Integer.parseInt(request.getParameter("productCategory"));
                int unidadesPorPaquete = Integer.parseInt(request.getParameter("productUnits"));

                // 2. GENERAR SKU AUTOMÁTICAMENTE
                String skuGenerado = productoDao.generarNuevoSKU();

                // 3. Creamos un objeto Producto con los datos recibidos
                Producto producto = new Producto();
                producto.setCodigoSKU(skuGenerado); // Usar SKU generado automáticamente
                producto.setNombre(nombre);
                producto.setDescripcion(desc);
                producto.setPrecioActual(precio);
                producto.setUnidadesPorPaquete(unidadesPorPaquete); // Campo nuevo

                Usuario productor = new Usuario();
                productor.setIdUsuario(idProductor);
                producto.setProductor(productor);

                Categoria categoria = new Categoria();
                categoria.setIdCategoria(categoriaId);
                producto.setCategoria(categoria);

                // 4. Llamamos al DAO para que guarde el objeto en la base de datos
                productoDao.crearProducto(producto);

                // 5. Redirigimos al usuario a la lista principal para que vea el nuevo producto
                response.sendRedirect(request.getContextPath() + "/ProductorServlet");
                break;

            case "actualizarPrecio":
                // Actualiza el precio del producto y redirige al formulario con el SKU
                int idProductoUpdate = Integer.parseInt(request.getParameter("idProducto"));
                double nuevoPrecio = Double.parseDouble(request.getParameter("nuevoPrecio"));

                productoDao.actualizarPrecio(idProductoUpdate, nuevoPrecio);

                // Opcional: volver al formulario de actualización manteniendo contexto
                // Si conoces el SKU, podrías reenviarlo; aquí solo volvemos a listar productos
                response.sendRedirect(request.getContextPath() + "/ProductorServlet?action=listarProductos");
                break;

            case "desactivarProducto":
                // Desactiva un producto (soft delete) y recarga la lista
                int idProductoDesactivar = Integer.parseInt(request.getParameter("idProducto"));
                boolean desactivado = productoDao.desactivarProducto(idProductoDesactivar);
                
                // Recargar la lista de productos después de desactivar (tanto si fue exitoso como si falló)
                ArrayList<Producto> listaProductosActualizada = productoDao.listarProductosPorProductor(idProductor);
                int totalProductos = productoDao.contarTotalProductos(idProductor);
                int fueraDeStock = productoDao.contarProductosFueraDeStock(idProductor);
                int totalCategorias = productoDao.contarTotalCategorias(idProductor);
                ArrayList<Categoria> todasLasCategoriasDesactivar = productoDao.listarTodasLasCategorias();
                
                request.setAttribute("listaProductos", listaProductosActualizada);
                request.setAttribute("totalProductos", totalProductos);
                request.setAttribute("fueraDeStock", fueraDeStock);
                request.setAttribute("totalCategorias", totalCategorias);
                request.setAttribute("todasLasCategorias", todasLasCategoriasDesactivar);
                
                if (desactivado) {
                    request.setAttribute("alertType", "success");
                    request.setAttribute("alertMessage", "Producto eliminado correctamente.");
                } else {
                    request.setAttribute("alertType", "danger");
                    request.setAttribute("alertMessage", "No se pudo eliminar el producto.");
                }
                
                // Forward a la lista de productos con mensaje
                RequestDispatcher rdDesactivar = request.getRequestDispatcher("productor/misProductos.jsp");
                rdDesactivar.forward(request, response);
                return;

            case "registrarLote":
                // Procesar el formulario de registro de lotes y permanecer en la misma página con mensaje
                LoteDao loteDaoPost = new LoteDao();
                String skuProducto = request.getParameter("skuProducto");
                String cantidadStockStr = request.getParameter("cantidadStock");
                String fechaCaducidad = request.getParameter("fechaCaducidad"); // opcional

                // GENERAR CÓDIGO DE LOTE AUTOMÁTICAMENTE
                String codigoLote = loteDaoPost.generarNuevoCodigoLote();
                
                // Usar distrito por defecto
                String distrito = "Cercado";

                int cantidadStock = 0;
                try {
                    cantidadStock = Integer.parseInt(cantidadStockStr);
                } catch (NumberFormatException e) {
                    cantidadStock = 0;
                }

                boolean ok = false;
                if (codigoLote != null && skuProducto != null && cantidadStock > 0) {
                    ok = loteDaoPost.registrarLote(codigoLote.trim(), skuProducto.trim(), cantidadStock,
                            (fechaCaducidad != null ? fechaCaducidad.trim() : null), distrito.trim());
                }

                request.setAttribute("alertType", ok ? "success" : "danger");
                request.setAttribute("alertMessage", ok ? "Lote registrado correctamente." : "No se pudo registrar el lote. Verifica los datos e inténtalo nuevamente.");

                // Mantener valores ingresados si falló (pequeña UX)
                if (!ok) {
                    request.setAttribute("form_codigoLote", codigoLote);
                    request.setAttribute("form_skuProducto", skuProducto);
                    request.setAttribute("form_cantidadStock", cantidadStockStr);
                    request.setAttribute("form_fechaCaducidad", fechaCaducidad);
                }

                RequestDispatcher rd = request.getRequestDispatcher("productor/registrarLotes.jsp");
                rd.forward(request, response);
                return;

            case "cambiarEstadoOrden":
                // Cambiar el estado de una orden de compra
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                try {
                    int idOrden = Integer.parseInt(request.getParameter("idOrden"));
                    String nuevoEstado = request.getParameter("nuevoEstado");
                    
                    System.out.println("=== DEBUG SERVLET - CAMBIAR ESTADO ORDEN ===");
                    System.out.println("ID Orden: " + idOrden);
                    System.out.println("Nuevo Estado: " + nuevoEstado);
                    
                    OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
                    boolean actualizado = ordenCompraDao.actualizarEstadoOrden(idOrden, nuevoEstado);
                    
                    if (actualizado) {
                        response.getWriter().write("{\"success\": true, \"message\": \"Estado actualizado correctamente\"}");
                        System.out.println("✓ Estado actualizado correctamente");
                    } else {
                        response.getWriter().write("{\"success\": false, \"message\": \"No se pudo actualizar el estado\"}");
                        System.err.println("❌ No se pudo actualizar el estado");
                    }
                } catch (NumberFormatException e) {
                    response.getWriter().write("{\"success\": false, \"message\": \"ID de orden inválido\"}");
                    System.err.println("❌ ERROR: ID de orden inválido - " + e.getMessage());
                } catch (Exception e) {
                    response.getWriter().write("{\"success\": false, \"message\": \"Error interno del servidor\"}");
                    System.err.println("❌ ERROR: Error al cambiar estado - " + e.getMessage());
                    e.printStackTrace();
                }
                return;

            case "asignarLoteAOrden":
                // Asignar un lote específico a una orden de compra
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                try {
                    int idOrden2 = Integer.parseInt(request.getParameter("idOrden"));
                    int idLote = Integer.parseInt(request.getParameter("idLote"));
                    
                    System.out.println("=== DEBUG SERVLET - ASIGNAR LOTE A ORDEN ===");
                    System.out.println("ID Orden: " + idOrden2);
                    System.out.println("ID Lote: " + idLote);
                    
                    // Actualizar la orden con el lote asignado
                    OrdenCompraDao ordenCompraDao3 = new OrdenCompraDao();
                    boolean asignado = ordenCompraDao3.completarOrden(idOrden2, idLote);
                    
                    if (asignado) {
                        System.out.println("✓ Lote asignado correctamente a la orden");
                        response.getWriter().write("{\"success\": true, \"message\": \"Lote asignado correctamente\"}");
                    } else {
                        System.err.println("❌ No se pudo asignar el lote");
                        response.getWriter().write("{\"success\": false, \"message\": \"No se pudo asignar el lote\"}");
                    }
                    
                } catch (NumberFormatException e) {
                    System.err.println("❌ ERROR: Parámetros inválidos - " + e.getMessage());
                    response.getWriter().write("{\"success\": false, \"message\": \"Parámetros inválidos\"}");
                } catch (Exception e) {
                    System.err.println("❌ ERROR: Error al asignar lote - " + e.getMessage());
                    e.printStackTrace();
                    response.getWriter().write("{\"success\": false, \"message\": \"Error interno del servidor\"}");
                }
                return;

            // Aquí irían otros 'cases' para guardar otros formularios

        }
    }
}
