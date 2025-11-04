package com.example.telito.productor.servlets;

import com.example.telito.productor.beans.Producto;
import com.example.telito.productor.daos.ProductoDao;
import com.example.telito.util.ExcelUtil;
import com.example.telito.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

@WebServlet(name = "ProductoReporteServlet", value = "/productor/ProductoReporteServlet")
public class ProductoReporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "exportar";
        }

        switch (action) {
            case "exportar":
                exportarExcel(request, response);
                break;
            case "formEnviar":
                mostrarFormularioEnvio(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("enviar".equals(action)) {
            enviarPorCorreo(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
        }
    }

    private void exportarExcel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession();
        com.example.telito.administrador.beans.Usuario usuarioSesion = 
            (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
        
        if (usuarioSesion == null) {
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }

        int idProductor = usuarioSesion.getIdUsuario();
        ProductoDao productoDao = new ProductoDao();

        // Obtener parámetros de filtros de la URL
        String busqueda = request.getParameter("busqueda");
        String categoriaId = request.getParameter("categoria");

        // Obtener todos los productos del productor
        ArrayList<Producto> listaProductos = productoDao.listarProductosPorProductor(idProductor);

        // Aplicar filtros si existen
        if ((busqueda != null && !busqueda.trim().isEmpty()) || 
            (categoriaId != null && !categoriaId.trim().isEmpty())) {
            
            ArrayList<Producto> productosFiltrados = new ArrayList<>();
            for (Producto producto : listaProductos) {
                boolean pasaBusqueda = true;
                boolean pasaCategoria = true;

                if (busqueda != null && !busqueda.trim().isEmpty()) {
                    String busquedaLower = busqueda.toLowerCase();
                    pasaBusqueda = (producto.getNombre() != null && producto.getNombre().toLowerCase().contains(busquedaLower)) ||
                                   (producto.getCodigoSKU() != null && producto.getCodigoSKU().toLowerCase().contains(busquedaLower));
                }

                if (categoriaId != null && !categoriaId.trim().isEmpty()) {
                    int catId = Integer.parseInt(categoriaId);
                    pasaCategoria = producto.getCategoria() != null && 
                                   producto.getCategoria().getIdCategoria() == catId;
                }

                if (pasaBusqueda && pasaCategoria) {
                    productosFiltrados.add(producto);
                }
            }
            listaProductos = productosFiltrados;
        }

        // Construir información de filtros
        StringBuilder filtrosInfo = new StringBuilder();
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            filtrosInfo.append("Búsqueda: ").append(busqueda);
        }
        if (categoriaId != null && !categoriaId.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Categoría ID: ").append(categoriaId);
        }
        if (filtrosInfo.length() == 0) {
            filtrosInfo.append("Todos los productos");
        }

        String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String nombreArchivo = "Reporte_Productos_Productor_" + fecha + ".xlsx";

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");
        response.setCharacterEncoding("UTF-8");

        try (OutputStream out = response.getOutputStream()) {
            ExcelUtil.generarExcelProductosProductor(listaProductos, out, filtrosInfo.toString());
            out.flush();
        } catch (Exception e) {
            System.err.println("Error al generar Excel: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Error al generar el archivo Excel: " + e.getMessage());
        }
    }

    private void mostrarFormularioEnvio(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Preservar parámetros de filtros en el formulario
        String busqueda = request.getParameter("busqueda");
        String categoriaId = request.getParameter("categoria");
        
        if (busqueda != null) {
            request.setAttribute("busqueda", busqueda);
        }
        if (categoriaId != null) {
            request.setAttribute("categoria", categoriaId);
        }

        request.getRequestDispatcher("/productor/enviar-reporte-productos.jsp")
            .forward(request, response);
    }

    private void enviarPorCorreo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        com.example.telito.administrador.beans.Usuario usuarioSesion = 
            (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
        
        if (usuarioSesion == null) {
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }

        int idProductor = usuarioSesion.getIdUsuario();

        String emailDestino = request.getParameter("email_destino");
        String asunto = request.getParameter("asunto");
        String mensaje = request.getParameter("mensaje");

        // Obtener parámetros de filtros (si vienen del formulario)
        String busqueda = request.getParameter("busqueda");
        String categoriaId = request.getParameter("categoria");

        if (emailDestino == null || emailDestino.trim().isEmpty()) {
            session.setAttribute("errorMsg", "El email de destino es obligatorio.");
            String redirectUrl = request.getContextPath() + "/productor/ProductoReporteServlet?action=formEnviar";
            if (busqueda != null) redirectUrl += "&busqueda=" + busqueda;
            if (categoriaId != null) redirectUrl += "&categoria=" + categoriaId;
            response.sendRedirect(redirectUrl);
            return;
        }

        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        if (!emailDestino.matches(emailRegex)) {
            session.setAttribute("errorMsg", "El formato del email no es válido.");
            String redirectUrl = request.getContextPath() + "/productor/ProductoReporteServlet?action=formEnviar";
            if (busqueda != null) redirectUrl += "&busqueda=" + busqueda;
            if (categoriaId != null) redirectUrl += "&categoria=" + categoriaId;
            response.sendRedirect(redirectUrl);
            return;
        }

        ProductoDao productoDao = new ProductoDao();

        // Obtener todos los productos del productor
        ArrayList<Producto> listaProductos = productoDao.listarProductosPorProductor(idProductor);

        // Aplicar filtros si existen
        if ((busqueda != null && !busqueda.trim().isEmpty()) || 
            (categoriaId != null && !categoriaId.trim().isEmpty())) {
            
            ArrayList<Producto> productosFiltrados = new ArrayList<>();
            for (Producto producto : listaProductos) {
                boolean pasaBusqueda = true;
                boolean pasaCategoria = true;

                if (busqueda != null && !busqueda.trim().isEmpty()) {
                    String busquedaLower = busqueda.toLowerCase();
                    pasaBusqueda = (producto.getNombre() != null && producto.getNombre().toLowerCase().contains(busquedaLower)) ||
                                   (producto.getCodigoSKU() != null && producto.getCodigoSKU().toLowerCase().contains(busquedaLower));
                }

                if (categoriaId != null && !categoriaId.trim().isEmpty()) {
                    int catId = Integer.parseInt(categoriaId);
                    pasaCategoria = producto.getCategoria() != null && 
                                   producto.getCategoria().getIdCategoria() == catId;
                }

                if (pasaBusqueda && pasaCategoria) {
                    productosFiltrados.add(producto);
                }
            }
            listaProductos = productosFiltrados;
        }

        // Construir información de filtros
        StringBuilder filtrosInfo = new StringBuilder();
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            filtrosInfo.append("Búsqueda: ").append(busqueda);
        }
        if (categoriaId != null && !categoriaId.trim().isEmpty()) {
            if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
            filtrosInfo.append("Categoría ID: ").append(categoriaId);
        }
        if (filtrosInfo.length() == 0) {
            filtrosInfo.append("Todos los productos");
        }

        File tempFile = null;
        try {
            String tempDir = System.getProperty("java.io.tmpdir");
            File tempDirFile = new File(tempDir);
            if (!tempDirFile.exists()) {
                tempDirFile.mkdirs();
            }

            String fecha = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String nombreArchivo = "Reporte_Productos_Productor_" + fecha + ".xlsx";
            tempFile = new File(tempDirFile, nombreArchivo);

            try (FileOutputStream fos = new FileOutputStream(tempFile)) {
                ExcelUtil.generarExcelProductosProductor(listaProductos, fos, filtrosInfo.toString());
                fos.flush();
            }

            String asuntoFinal = (asunto != null && !asunto.trim().isEmpty()) ?
                asunto : "Reporte de Productos - Productor - TELITO BODEGUERO";

            // Calcular estadísticas
            int totalProductos = listaProductos.size();
            int totalCategorias = 0;
            double valorTotalInventario = 0.0;
            java.util.Set<Integer> categoriasSet = new java.util.HashSet<>();
            
            for (Producto producto : listaProductos) {
                if (producto.getCategoria() != null) {
                    categoriasSet.add(producto.getCategoria().getIdCategoria());
                }
                double precioPorUnidad = producto.getPrecioActual() / producto.getUnidadesPorPaquete();
                valorTotalInventario += producto.getStockTotal() * precioPorUnidad;
            }
            totalCategorias = categoriasSet.size();

            String mensajeHTML = """
                <html>
                <head>
                    <meta charset="UTF-8">
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: #2b2d42; }
                        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                        .header { background: linear-gradient(160deg, #006d77 0%%, #055e68 100%%);
                                 color: white; padding: 25px; border-radius: 8px 8px 0 0; text-align: center; }
                        .content { background: #edf6f9; padding: 25px; border-radius: 0 0 8px 8px; }
                        .info-box { background: white; padding: 20px; border-radius: 5px;
                                   margin: 15px 0; border-left: 4px solid #006d77; }
                        .stats-box { background: white; padding: 15px; border-radius: 5px;
                                    margin: 10px 0; border-left: 4px solid #83c5be; }
                        .footer { margin-top: 20px; padding-top: 15px; border-top: 1px solid #e9ecef;
                                 font-size: 12px; color: #6c757d; text-align: center; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h2>🌱 Reporte de Productos - Productor</h2>
                        </div>
                        <div class="content">
                            <p>Estimado/a,</p>
                            <p>Se adjunta el reporte de Productos generado desde el sistema <strong>TELITO BODEGUERO</strong>.</p>

                            <div class="info-box">
                                <h3 style="margin-top: 0; color: #006d77;">📊 Información del Reporte</h3>
                                <div class="stats-box">
                                    <strong>Total de productos:</strong> %d
                                </div>
                                <div class="stats-box">
                                    <strong>Total de categorías:</strong> %d
                                </div>
                                <div class="stats-box">
                                    <strong>Valor total del inventario:</strong> S/. %s
                                </div>
                                <div class="stats-box">
                                    <strong>Filtros aplicados:</strong> %s
                                </div>
                                <p style="margin-top: 15px;"><strong>Fecha de generación:</strong> %s</p>
                            </div>

                            %s

                            <p><strong>Nota:</strong> El archivo Excel incluye filtros automáticos que puedes usar para ordenar y filtrar los datos directamente en Excel.</p>

                            <div class="footer">
                                <p>Este es un correo automático generado por el sistema TELITO BODEGUERO.</p>
                            </div>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(
                    totalProductos,
                    totalCategorias,
                    String.format("%.2f", valorTotalInventario),
                    filtrosInfo.toString(),
                    new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()),
                    mensaje != null && !mensaje.trim().isEmpty() ?
                        "<p><strong>Mensaje adicional:</strong></p><p>" + mensaje.replace("\n", "<br>") + "</p>" : ""
                );

            boolean enviado = EmailUtil.sendSystemAlertHTMLWithAttachment(
                emailDestino,
                asuntoFinal,
                mensajeHTML,
                tempFile,
                nombreArchivo
            );

            if (enviado) {
                session.setAttribute("mensaje",
                    "Reporte enviado exitosamente a " + emailDestino);
                session.setAttribute("tipoMensaje", "success");
            } else {
                session.setAttribute("mensaje",
                    "Error al enviar el reporte. Verifica la configuración de correo electrónico.");
                session.setAttribute("tipoMensaje", "danger");
            }

        } catch (Exception e) {
            System.err.println("Error al enviar reporte por correo: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("mensaje",
                "Error al generar o enviar el reporte: " + e.getMessage());
            session.setAttribute("tipoMensaje", "danger");
        } finally {
            if (tempFile != null && tempFile.exists()) {
                try {
                    tempFile.delete();
                } catch (Exception e) {
                    System.err.println("Error al eliminar archivo temporal: " + e.getMessage());
                }
            }
        }

        // Redirigir con los mismos filtros
        String redirectUrl = request.getContextPath() + "/ProductorServlet?action=listarProductos";
        StringBuilder params = new StringBuilder();
        if (busqueda != null) params.append("?busqueda=").append(busqueda);
        if (categoriaId != null) params.append(params.length() == 0 ? "?" : "&").append("categoria=").append(categoriaId);
        response.sendRedirect(redirectUrl + params.toString());
    }
}

