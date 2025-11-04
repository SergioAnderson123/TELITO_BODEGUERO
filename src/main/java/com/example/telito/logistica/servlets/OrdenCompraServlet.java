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
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.administrador.daos.AlertaDAO;
import com.example.telito.util.EmailUtil;

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
                // === SECCIÓN MODIFICADA PARA MANEJAR FILTROS Y PAGINACIÓN ===

                // 1. Leemos los parámetros del formulario de búsqueda
                String busqueda = request.getParameter("busqueda");
                String proveedorId = request.getParameter("proveedor");
                String estado = request.getParameter("estado");

                // 2. Parámetros de paginación
                int page = 1;
                int size = 10;
                try { 
                    page = Integer.parseInt(request.getParameter("page")); 
                } catch (Exception ignored) {}
                try { 
                    size = Integer.parseInt(request.getParameter("size")); 
                } catch (Exception ignored) {}
                if (page < 1) page = 1;
                if (size < 1) size = 10;

                // 3. Obtenemos el total y calculamos páginas
                int totalRows = ordenCompraDao.contarOrdenes(busqueda, proveedorId, estado);
                int totalPages = (int) Math.ceil(totalRows / (double) size);
                if (totalPages == 0) totalPages = 1;
                if (page > totalPages) page = totalPages;

                // 4. Obtenemos la lista de órdenes (ahora paginada)
                ArrayList<OrdenCompraBean> listaOrdenes = ordenCompraDao.obtenerOrdenes(busqueda, proveedorId, estado, page, size);

                // 5. Obtenemos la lista de proveedores para el menú del filtro
                request.setAttribute("listaProveedores", proveedorDao.listarProveedores());

                // 6. Enviamos datos a la vista
                request.setAttribute("listaOrdenes", listaOrdenes);
                request.setAttribute("busqueda", busqueda);
                request.setAttribute("proveedorFiltro", proveedorId);
                request.setAttribute("estadoFiltro", estado);
                request.setAttribute("currentPage", page);
                request.setAttribute("size", size);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalRows", totalRows);
                request.setAttribute("baseUrl", request.getContextPath() + "/orden-compra");
                request.setAttribute("itemName", "órdenes");

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
            ArrayList<String> errores = new ArrayList<>();
            
                // Obtener el ID del usuario de logística que está logueado
                com.example.telito.administrador.beans.Usuario usuario = 
                    (com.example.telito.administrador.beans.Usuario) request.getSession().getAttribute("usuario");
                
                if (usuario == null) {
                    response.sendRedirect(request.getContextPath() + "/acceso/login");
                    return;
                }
                
                int usuarioId = usuario.getIdUsuario();
                
            // ========== VALIDACIONES DE PARÁMETROS ==========
            
            // 1. Validar que los parámetros existan
            String productorIdStr = request.getParameter("productor_id");
            String productoIdStr = request.getParameter("producto_id");
            String cantidadStr = request.getParameter("cantidad");
            String distritoIdStr = request.getParameter("distrito_id");
            String montoTotalStr = request.getParameter("monto_total");
            
            if (productorIdStr == null || productorIdStr.trim().isEmpty()) {
                errores.add("El productor es obligatorio");
            }
            if (productoIdStr == null || productoIdStr.trim().isEmpty()) {
                errores.add("El producto es obligatorio");
            }
            if (cantidadStr == null || cantidadStr.trim().isEmpty()) {
                errores.add("La cantidad es obligatoria");
            }
            if (distritoIdStr == null || distritoIdStr.trim().isEmpty()) {
                errores.add("El distrito de destino es obligatorio");
            }
            if (montoTotalStr == null || montoTotalStr.trim().isEmpty()) {
                errores.add("El monto total es obligatorio");
            }
            
            // Si ya hay errores, no continuar
            if (!errores.isEmpty()) {
                request.setAttribute("errores", errores);
                request.setAttribute("productor_id", productorIdStr);
                request.setAttribute("producto_id", productoIdStr);
                request.setAttribute("cantidad", cantidadStr);
                request.setAttribute("distrito_id", distritoIdStr);
                request.setAttribute("monto_total", montoTotalStr);
                
                // Recargar listas para el formulario
                request.setAttribute("listaProductos", new ProductoDao().listarProductos());
                request.setAttribute("listaProductores", new ProveedorDao().listarProductores());
                request.setAttribute("listaZonas", new ZonaDao().listarZonas());
                
                RequestDispatcher rd = request.getRequestDispatcher("/logistica/OrdenLista/form_orden_compra.jsp");
                rd.forward(request, response);
                return;
            }
            
            // 2. Validar que sean números válidos
            int productorId = 0;
            int productoId = 0;
            int cantidad = 0;
            int distritoId = 0;
            double montoTotal = 0.0;
            
            try {
                productorId = Integer.parseInt(productorIdStr);
                productoId = Integer.parseInt(productoIdStr);
                cantidad = Integer.parseInt(cantidadStr);
                distritoId = Integer.parseInt(distritoIdStr);
                montoTotal = Double.parseDouble(montoTotalStr);
            } catch (NumberFormatException e) {
                errores.add("Los valores numéricos no son válidos. Verifique los datos ingresados.");
                request.setAttribute("errores", errores);
                request.setAttribute("productor_id", productorIdStr);
                request.setAttribute("producto_id", productoIdStr);
                request.setAttribute("cantidad", cantidadStr);
                request.setAttribute("distrito_id", distritoIdStr);
                request.setAttribute("monto_total", montoTotalStr);
                
                request.setAttribute("listaProductos", new ProductoDao().listarProductos());
                request.setAttribute("listaProductores", new ProveedorDao().listarProductores());
                request.setAttribute("listaZonas", new ZonaDao().listarZonas());
                
                RequestDispatcher rd = request.getRequestDispatcher("/logistica/OrdenLista/form_orden_compra.jsp");
                rd.forward(request, response);
                return;
            }
            
            // 3. Validar rangos y lógica de negocio
            if (productorId <= 0) {
                errores.add("El ID del productor no es válido");
            }
            if (productoId <= 0) {
                errores.add("El ID del producto no es válido");
            }
            if (cantidad <= 0) {
                errores.add("La cantidad debe ser mayor a 0");
            }
            if (cantidad > 100000) {
                errores.add("La cantidad no puede exceder 100,000 paquetes");
            }
            if (distritoId <= 0) {
                errores.add("El ID del distrito no es válido");
            }
            if (montoTotal <= 0) {
                errores.add("El monto total debe ser mayor a S/ 0.00");
            }
            if (montoTotal > 10000000) {
                errores.add("El monto total no puede exceder S/ 10,000,000");
            }
            
            // 4. Validar existencia de entidades relacionadas
            ProductoDao productoDao = new ProductoDao();
            ProveedorDao proveedorDao = new ProveedorDao();
            DistritoDao distritoDao = new DistritoDao();
            
            if (!proveedorDao.existeProductor(productorId)) {
                errores.add("El productor seleccionado no existe");
            }
            if (!productoDao.existeProducto(productoId)) {
                errores.add("El producto seleccionado no existe");
            }
            if (!distritoDao.existeDistrito(distritoId)) {
                errores.add("El distrito seleccionado no existe");
            }
            
            // 5. Validar que el producto pertenezca al productor
            if (productorId > 0 && productoId > 0) {
                if (!productoDao.productoPerteneceAProductor(productoId, productorId)) {
                    errores.add("El producto seleccionado no pertenece al productor");
                }
            }
            
            // 6. Validar coherencia del monto (cantidad × precio unitario)
            if (productoId > 0 && cantidad > 0) {
                ProductoBean producto = productoDao.obtenerProductoPorId(productoId);
                if (producto != null && producto.getPrecio() != null) {
                    double precioUnitario = producto.getPrecio().doubleValue();
                    double precioEsperado = cantidad * precioUnitario;
                    double margenError = precioEsperado * 0.01; // 1% de margen
                    
                    if (Math.abs(montoTotal - precioEsperado) > margenError) {
                        errores.add(String.format("El monto total (S/ %.2f) no coincide con el cálculo esperado (S/ %.2f). Verifique los datos.", 
                            montoTotal, precioEsperado));
                    }
                }
            }
            
            // Si hay errores de validación, volver al formulario
            if (!errores.isEmpty()) {
                System.err.println("❌ VALIDACIÓN: Se encontraron " + errores.size() + " errores");
                for (String error : errores) {
                    System.err.println("  - " + error);
                }
                
                request.setAttribute("errores", errores);
                request.setAttribute("productor_id", productorIdStr);
                request.setAttribute("producto_id", productoIdStr);
                request.setAttribute("cantidad", cantidadStr);
                request.setAttribute("distrito_id", distritoIdStr);
                request.setAttribute("monto_total", montoTotalStr);
                
                request.setAttribute("listaProductos", productoDao.listarProductos());
                request.setAttribute("listaProductores", proveedorDao.listarProductores());
                request.setAttribute("listaZonas", new ZonaDao().listarZonas());
                
                RequestDispatcher rd = request.getRequestDispatcher("/logistica/OrdenLista/form_orden_compra.jsp");
                rd.forward(request, response);
                return;
            }
            
            // ========== TODO VÁLIDO - GUARDAR ORDEN ==========
            
            try {
                System.out.println("=== DEBUG SERVLET - ORDEN DE COMPRA ===");
                System.out.println("Productor ID: " + productorId);
                System.out.println("Producto ID: " + productoId);
                System.out.println("Cantidad: " + cantidad);
                System.out.println("Distrito ID: " + distritoId);
                System.out.println("Monto Total: " + montoTotal);
                System.out.println("Usuario ID (Logística): " + usuarioId);
                
                // Guardar la orden de compra con el ID del usuario logueado y obtener el ID
                int idOrdenCreada = ordenCompraDao.crearOrdenCompraYRetornarId(null, productorId, productoId, cantidad, usuarioId, montoTotal, distritoId);
                
                if (idOrdenCreada > 0) {
                    System.out.println("✓ SERVLET: Orden guardada exitosamente con ID: " + idOrdenCreada);
                    
                    // ========== ENVIAR NOTIFICACIÓN AL PRODUCTOR SOBRE LA NUEVA ORDEN ==========
                    try {
                        // Obtener datos de la orden recién creada
                        Object[] datosOrden = ordenCompraDao.obtenerDatosBasicosOrden(idOrdenCreada);
                        if (datosOrden != null) {
                            int productorIdOrd = (Integer) datosOrden[4];
                            String numeroOrden = (String) datosOrden[0];
                            String nombreProducto = (String) datosOrden[1];
                            int cantidadOrd = (Integer) datosOrden[2];
                            double montoTotalOrd = (Double) datosOrden[3];
                            
                            // Obtener email del productor
                            UsuarioDAO usuarioDAO = new UsuarioDAO();
                            String emailProductor = usuarioDAO.obtenerEmailPorId(productorIdOrd);
                            
                            if (emailProductor != null && !emailProductor.trim().isEmpty()) {
                                String mensaje = """
                                    <h2>Nueva Orden de Compra Pendiente de Revisión</h2>
                                    <p>Se ha creado una nueva orden de compra que requiere tu revisión y respuesta.</p>
                                    <p><strong>Número de Orden:</strong> %s</p>
                                    <p><strong>Producto:</strong> %s</p>
                                    <p><strong>Cantidad:</strong> %d paquetes</p>
                                    <p><strong>Monto Total:</strong> S/. %.2f</p>
                                    <p><strong>Fecha de Creación:</strong> %s</p>
                                    <hr>
                                    <p><strong>Acción requerida:</strong></p>
                                    <ul>
                                        <li>Por favor, revisa los detalles de la orden en tu panel de productor</li>
                                        <li>Confirma si puedes cumplir con la orden o si necesitas hacer alguna observación</li>
                                        <li>Una vez revisada, envía tu respuesta a logística</li>
                                    </ul>
                                    <p>Logística revisará tu respuesta y te notificará si la orden es aprobada o rechazada.</p>
                                    """.formatted(
                                        numeroOrden,
                                        nombreProducto,
                                        cantidadOrd,
                                        montoTotalOrd,
                                        new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())
                                    );
                                
                                boolean correoEnviado = EmailUtil.sendSystemAlertHTML(
                                    emailProductor,
                                    "Nueva Orden de Compra - Requiere Revisión",
                                    mensaje
                                );
                                
                                if (correoEnviado) {
                                    System.out.println("✓ Correo enviado al productor: " + emailProductor);
                                } else {
                                    System.err.println("⚠ No se pudo enviar el correo al productor");
                                }
                            } else {
                                System.out.println("⚠ Productor no tiene email configurado. ID: " + productorIdOrd);
                            }
                        }
                    } catch (Exception e) {
                        // No bloquear la operación si falla el correo
                        System.err.println("⚠ Error al enviar correo de notificación de nueva orden: " + e.getMessage());
                        e.printStackTrace();
                    }
                    // ========== FIN ENVÍO DE CORREO ==========
                    
                    response.sendRedirect(request.getContextPath() + "/orden-compra?successMsg=Orden de compra creada exitosamente");
                } else {
                    System.err.println("❌ SERVLET: Fallo al guardar la orden");
                    errores.add("Error al guardar la orden en la base de datos. Por favor, intente nuevamente.");
                    
                    request.setAttribute("errores", errores);
                    request.setAttribute("productor_id", productorIdStr);
                    request.setAttribute("producto_id", productoIdStr);
                    request.setAttribute("cantidad", cantidadStr);
                    request.setAttribute("distrito_id", distritoIdStr);
                    request.setAttribute("monto_total", montoTotalStr);
                    
                    request.setAttribute("listaProductos", productoDao.listarProductos());
                    request.setAttribute("listaProductores", proveedorDao.listarProductores());
                    request.setAttribute("listaZonas", new ZonaDao().listarZonas());
                    
                    RequestDispatcher rd = request.getRequestDispatcher("/logistica/OrdenLista/form_orden_compra.jsp");
                    rd.forward(request, response);
                }
                
            } catch (Exception e) {
                System.err.println("❌ ERROR INESPERADO: " + e.getMessage());
                e.printStackTrace();
                
                errores.add("Error inesperado al procesar la orden. Por favor, contacte al administrador.");
                request.setAttribute("errores", errores);
                request.setAttribute("productor_id", productorIdStr);
                request.setAttribute("producto_id", productoIdStr);
                request.setAttribute("cantidad", cantidadStr);
                request.setAttribute("distrito_id", distritoIdStr);
                request.setAttribute("monto_total", montoTotalStr);
                
                request.setAttribute("listaProductos", productoDao.listarProductos());
                request.setAttribute("listaProductores", proveedorDao.listarProductores());
                request.setAttribute("listaZonas", new ZonaDao().listarZonas());
                
                RequestDispatcher rd = request.getRequestDispatcher("/logistica/OrdenLista/form_orden_compra.jsp");
                rd.forward(request, response);
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
                    
                    // ========== ENVÍO DE CORREO AL PRODUCTOR ==========
                    try {
                        // Obtener datos de la orden
                        Object[] datosOrden = ordenCompraDao2.obtenerDatosBasicosOrden(idOrden);
                        if (datosOrden != null) {
                            int productorId = (Integer) datosOrden[4];
                            String numeroOrden = (String) datosOrden[0];
                            String nombreProducto = (String) datosOrden[1];
                            int cantidad = (Integer) datosOrden[2];
                            double montoTotal = (Double) datosOrden[3];
                            
                            // Obtener email del productor
                            UsuarioDAO usuarioDAO = new UsuarioDAO();
                            String emailProductor = usuarioDAO.obtenerEmailPorId(productorId);
                            
                            if (emailProductor != null && !emailProductor.trim().isEmpty()) {
                                String asunto;
                                String mensaje;
                                
                                if ("Aprobado".equals(nuevoEstado)) {
                                    asunto = "TELITO BODEGUERO - Orden de Compra Aprobada";
                                    mensaje = """
                                        <h2>¡Tu Orden de Compra ha sido Aprobada!</h2>
                                        <p><strong>Número de Orden:</strong> %s</p>
                                        <p><strong>Producto:</strong> %s</p>
                                        <p><strong>Cantidad:</strong> %d paquetes</p>
                                        <p><strong>Monto Total:</strong> S/. %.2f</p>
                                        <p><strong>Fecha de Aprobación:</strong> %s</p>
                                        <hr>
                                        <p><strong>Próximos pasos:</strong></p>
                                        <ul>
                                            <li>Por favor, prepara la mercancía según lo acordado</li>
                                            <li>Una vez lista, regístrala en el sistema como lote</li>
                                            <li>Coordina la entrega con el personal de logística</li>
                                        </ul>
                                        <p>Te notificaremos cuando la mercancía sea recibida en el almacén.</p>
                                        """.formatted(
                                            numeroOrden,
                                            nombreProducto,
                                            cantidad,
                                            montoTotal,
                                            new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())
                                        );
                                    
                                    // ========== ENVÍO DE CORREO A ALMACÉN ==========
                                    // Notificar a almacén que la orden fue aprobada y deben estar preparados para registrar la entrada
                                    try {
                                        AlertaDAO alertaDAO = new AlertaDAO();
                                        
                                        // Intentar obtener emails de usuarios de almacén con diferentes variaciones del nombre del rol
                                        ArrayList<String> emailsAlmacen = alertaDAO.obtenerEmailsPorRol("Almacenero");
                                        System.out.println("Emails encontrados con rol 'Almacenero': " + emailsAlmacen.size());
                                        
                                        if (emailsAlmacen.isEmpty()) {
                                            System.out.println("⚠ No se encontraron emails con rol 'Almacenero', intentando variaciones...");
                                            emailsAlmacen = alertaDAO.obtenerEmailsPorRol("ALMACENERO");
                                            System.out.println("Emails encontrados con rol 'ALMACENERO': " + emailsAlmacen.size());
                                            
                                            if (emailsAlmacen.isEmpty()) {
                                                emailsAlmacen = alertaDAO.obtenerEmailsPorRol("ALMACEN");
                                                System.out.println("Emails encontrados con rol 'ALMACEN': " + emailsAlmacen.size());
                                            }
                                            
                                            if (emailsAlmacen.isEmpty()) {
                                                emailsAlmacen = alertaDAO.obtenerEmailsPorRol("BODEGA");
                                                System.out.println("Emails encontrados con rol 'BODEGA': " + emailsAlmacen.size());
                                            }
                                        }
                                        
                                        if (!emailsAlmacen.isEmpty()) {
                                            String asuntoAlmacen = "TELITO BODEGUERO - Orden de Compra Aprobada - Preparar Registro de Entrada";
                                            String mensajeAlmacen = """
                                                <h2>¡Orden de Compra Aprobada por Logística!</h2>
                                                <p>El personal de logística ha aprobado una nueva orden de compra. El almacén debe estar preparado para registrar la entrada cuando el productor entregue la mercancía.</p>
                                                <p><strong>Número de Orden:</strong> %s</p>
                                                <p><strong>Producto:</strong> %s</p>
                                                <p><strong>Cantidad:</strong> %d paquetes</p>
                                                <p><strong>Monto Total:</strong> S/. %.2f</p>
                                                <p><strong>Fecha de Aprobación:</strong> %s</p>
                                                <hr>
                                                <p><strong>Acción requerida:</strong></p>
                                                <ul>
                                                    <li>Estar preparado para recibir la mercancía del productor</li>
                                                    <li>Una vez que el productor entregue, registrar la entrada en el sistema</li>
                                                    <li>Verificar la cantidad y estado de la mercancía recibida</li>
                                                </ul>
                                                <p>El productor recibirá una notificación para preparar la mercancía. Te notificaremos cuando esté lista para ser recibida.</p>
                                                """.formatted(
                                                    numeroOrden,
                                                    nombreProducto,
                                                    cantidad,
                                                    montoTotal,
                                                    new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())
                                                );
                                            
                                            // Enviar correo a todos los usuarios de almacén
                                            int correosEnviados = 0;
                                            for (String email : emailsAlmacen) {
                                                boolean enviado = EmailUtil.sendSystemAlertHTML(
                                                    email,
                                                    asuntoAlmacen,
                                                    mensajeAlmacen
                                                );
                                                if (enviado) {
                                                    correosEnviados++;
                                                    System.out.println("✓ Correo enviado a almacén: " + email);
                                                }
                                            }
                                            
                                            if (correosEnviados > 0) {
                                                System.out.println("✓✓✓ Se enviaron " + correosEnviados + " correo(s) a almacén sobre la orden aprobada");
                                            } else {
                                                System.err.println("⚠ No se pudo enviar ningún correo a almacén");
                                            }
                                        } else {
                                            System.err.println("⚠ No se encontraron usuarios de almacén con email configurado para notificar");
                                        }
                                    } catch (Exception e) {
                                        // No bloquear la operación si falla el correo a almacén
                                        System.err.println("⚠ Error al enviar correo a almacén: " + e.getMessage());
                                        e.printStackTrace();
                                    }
                                    // ========== FIN ENVÍO DE CORREO A ALMACÉN ==========
                                    
                                } else {
                                    // Rechazado
                                    asunto = "TELITO BODEGUERO - Orden de Compra Rechazada";
                                    mensaje = """
                                        <h2>Orden de Compra Rechazada</h2>
                                        <p>Lamentamos informarte que tu orden de compra ha sido rechazada.</p>
                                        <p><strong>Número de Orden:</strong> %s</p>
                                        <p><strong>Producto:</strong> %s</p>
                                        <p><strong>Cantidad:</strong> %d paquetes</p>
                                        <p><strong>Fecha de Rechazo:</strong> %s</p>
                                        <hr>
                                        <p>Si tienes preguntas sobre el motivo del rechazo, por favor contacta al personal de logística.</p>
                                        """.formatted(
                                            numeroOrden,
                                            nombreProducto,
                                            cantidad,
                                            new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())
                                        );
                                }
                                
                                // Enviar correo HTML
                                boolean correoEnviado = EmailUtil.sendSystemAlertHTML(
                                    emailProductor,
                                    asunto,
                                    mensaje
                                );
                                
                                if (correoEnviado) {
                                    System.out.println("✓ Correo enviado al productor: " + emailProductor);
                                } else {
                                    System.err.println("⚠ No se pudo enviar el correo al productor");
                                }
                            } else {
                                System.out.println("⚠ Productor no tiene email configurado. ID: " + productorId);
                            }
                        }
                    } catch (Exception e) {
                        // No bloquear la operación si falla el correo
                        System.err.println("⚠ Error al enviar correo de notificación: " + e.getMessage());
                        e.printStackTrace();
                    }
                    // ========== FIN ENVÍO DE CORREO ==========
                    
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