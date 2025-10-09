package com.example.telito.bodega.servlets;
import com.example.telito.bodega.daos.LoteDao;
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
import java.util.ArrayList;

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

        // ID del productor logueado (fijo para pruebas, luego se obtendrá de la sesión)
        final int idProductor = 2;
        
        ProductoDao productoDao = new ProductoDao();
        LoteDao loteDao = new LoteDao();
        RequestDispatcher view;

        switch (action) {
            case "listarProductos":
                // 1. Obtenemos la lista de productos desde el DAO
                ArrayList<Producto> listaProductos = productoDao.listarProductosPorProductor(idProductor);

                // 2. Obtenemos los datos para las tarjetas de estadísticas desde el DAO
                int totalProductos = productoDao.contarTotalProductos(idProductor);
                int fueraDeStock = productoDao.contarProductosFueraDeStock(idProductor);
                int totalCategorias = productoDao.contarTotalCategorias(idProductor);

                // 3. Calculamos el número de lotes para cada producto
                for (Producto producto : listaProductos) {
                    int numeroLotes = productoDao.contarLotesPorProducto(producto.getIdProducto());
                    // Podríamos agregar un campo al bean Producto para almacenar esto
                    // Por ahora lo pasaremos como atributo separado en el request
                }

                // 4. Obtenemos todas las categorías para el modal de agregar producto
                ArrayList<Categoria> todasLasCategorias = productoDao.listarTodasLasCategorias();

                // 5. Enviamos todos los datos a la vista (JSP)
                request.setAttribute("listaProductos", listaProductos);
                request.setAttribute("totalProductos", totalProductos);
                request.setAttribute("fueraDeStock", fueraDeStock);
                request.setAttribute("totalCategorias", totalCategorias);
                request.setAttribute("todasLasCategorias", todasLasCategorias);

                // 5. Redirigimos la petición al JSP para que muestre los datos
                view = request.getRequestDispatcher("/productor/misProductos.jsp");
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

        }
    }

    /**
     * Maneja las peticiones POST (generalmente para procesar formularios).
     * Ej: el formulario del modal "Agregar Producto"
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        ProductoDao productoDao = new ProductoDao();
        
        // ID del productor logueado (fijo para pruebas, luego se obtendrá de la sesión)
        final int idProductor = 2;


        switch(action) {
            case "crearProducto":
                // 1. Leemos los datos enviados desde el formulario
                String sku = request.getParameter("productSKU");
                String nombre = request.getParameter("productName");
                String desc = request.getParameter("productDescription");
                double precio = Double.parseDouble(request.getParameter("productPrice"));
                int categoriaId = Integer.parseInt(request.getParameter("productCategory"));

                // 2. Creamos un objeto Producto con los datos recibidos
                Producto producto = new Producto();
                producto.setCodigoSKU(sku);
                producto.setNombre(nombre);
                producto.setDescripcion(desc);
                producto.setPrecioActual(precio);

                Usuario productor = new Usuario();
                productor.setIdUsuario(idProductor);
                producto.setProductor(productor);

                Categoria categoria = new Categoria();
                categoria.setIdCategoria(categoriaId);
                producto.setCategoria(categoria);

                // 3. Llamamos al DAO para que guarde el objeto en la base de datos
                productoDao.crearProducto(producto);

                // 4. Redirigimos al usuario a la lista principal para que vea el nuevo producto
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
                
                request.setAttribute("listaProductos", listaProductosActualizada);
                request.setAttribute("totalProductos", totalProductos);
                request.setAttribute("fueraDeStock", fueraDeStock);
                request.setAttribute("totalCategorias", totalCategorias);
                
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
                String codigoLote = request.getParameter("codigoLote");
                String skuProducto = request.getParameter("skuProducto");
                String cantidadStockStr = request.getParameter("cantidadStock");
                String fechaCaducidad = request.getParameter("fechaCaducidad"); // opcional
                String distrito = request.getParameter("distrito");

                int cantidadStock = 0;
                try {
                    cantidadStock = Integer.parseInt(cantidadStockStr);
                } catch (NumberFormatException e) {
                    cantidadStock = 0;
                }

                boolean ok = false;
                if (codigoLote != null && skuProducto != null && cantidadStock > 0 && distrito != null && !distrito.isEmpty()) {
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
                    request.setAttribute("form_distrito", distrito);
                }

                RequestDispatcher rd = request.getRequestDispatcher("productor/registrarLotes.jsp");
                rd.forward(request, response);
                return;

            // Aquí irían otros 'cases' para guardar otros formularios

        }
    }
}
