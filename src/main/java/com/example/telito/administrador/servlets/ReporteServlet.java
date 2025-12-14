package com.example.telito.administrador.servlets;

import com.example.telito.administrador.daos.ReporteDAO;
import com.example.telito.util.AuthorizationHelper;
import com.google.gson.Gson;
import com.example.telito.administrador.beans.Usuario;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

// Visualización de reportes y estadísticas del sistema
@WebServlet(name = "ReporteServlet", value = "/administrador/reportes")
public class ReporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Solo administradores
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a ReporteServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        ReporteDAO reporteDAO = new ReporteDAO();
        Gson gson = new Gson();

        switch (action) {
            case "globales": {
                int rutasActivas = reporteDAO.contarRutasActivas();
                int eficiencia = reporteDAO.calcularEficienciaLogistica();
                int productores = reporteDAO.contarProductores();
                int lotes = reporteDAO.contarLotes();
                int productos = reporteDAO.contarProductos();
                int ubicaciones = reporteDAO.contarUbicaciones();

                request.setAttribute("rutasActivas", rutasActivas);
                request.setAttribute("eficiencia", eficiencia);
                request.setAttribute("productores", productores);
                request.setAttribute("lotes", lotes);
                request.setAttribute("productos", productos);
                request.setAttribute("ubicaciones", ubicaciones);

                RequestDispatcher view = request.getRequestDispatcher("/administrador/reportes-globales.jsp");
                view.forward(request, response);
                break;
            }

            case "logistica": {
                // Reporte de logística con gráficos
                Map<String, Integer> conteoPlanes = reporteDAO.obtenerConteoPlanesPorEstado();
                request.setAttribute("planesLabelsJson", gson.toJson(new ArrayList<>(conteoPlanes.keySet())));
                request.setAttribute("planesDataJson", gson.toJson(new ArrayList<>(conteoPlanes.values())));

                Map<String, Integer> productosSalida = reporteDAO.obtenerProductosMasTransportados();
                request.setAttribute("productosSalidaLabelsJson", gson.toJson(new ArrayList<>(productosSalida.keySet())));
                request.setAttribute("productosSalidaDataJson", gson.toJson(new ArrayList<>(productosSalida.values())));

                // Reportes adicionales
                Map<String, Integer> planesPorDistrito = reporteDAO.obtenerDistribucionPlanesPorDistrito();
                request.setAttribute("distritosLabelsJson", gson.toJson(new ArrayList<>(planesPorDistrito.keySet())));
                request.setAttribute("distritosDataJson", gson.toJson(new ArrayList<>(planesPorDistrito.values())));

                Map<String, Integer> ordenesPorEstado = reporteDAO.obtenerOrdenesCompraPorEstado();
                request.setAttribute("ordenesEstadoLabelsJson", gson.toJson(new ArrayList<>(ordenesPorEstado.keySet())));
                request.setAttribute("ordenesEstadoDataJson", gson.toJson(new ArrayList<>(ordenesPorEstado.values())));

                Map<String, Integer> tendenciasPlanes = reporteDAO.obtenerTendenciasPlanesPorMes();
                request.setAttribute("tendenciasLabelsJson", gson.toJson(new ArrayList<>(tendenciasPlanes.keySet())));
                request.setAttribute("tendenciasDataJson", gson.toJson(new ArrayList<>(tendenciasPlanes.values())));

                // Nuevos reportes funcionales
                Map<String, Integer> planesPorZona = reporteDAO.obtenerDistribucionPlanesPorZona();
                request.setAttribute("zonasLabelsJson", gson.toJson(new ArrayList<>(planesPorZona.keySet())));
                request.setAttribute("zonasDataJson", gson.toJson(new ArrayList<>(planesPorZona.values())));

                Map<String, Integer> vehiculosUtilizados = reporteDAO.obtenerVehiculosMasUtilizados();
                request.setAttribute("vehiculosLabelsJson", gson.toJson(new ArrayList<>(vehiculosUtilizados.keySet())));
                request.setAttribute("vehiculosDataJson", gson.toJson(new ArrayList<>(vehiculosUtilizados.values())));

                Map<String, Integer> productosSolicitados = reporteDAO.obtenerProductosMasSolicitadosOrdenes();
                request.setAttribute("productosSolicitadosLabelsJson", gson.toJson(new ArrayList<>(productosSolicitados.keySet())));
                request.setAttribute("productosSolicitadosDataJson", gson.toJson(new ArrayList<>(productosSolicitados.values())));

                Map<String, Integer> comparativaPlanes = reporteDAO.obtenerComparativaPlanesPendientesVsCompletados();
                request.setAttribute("comparativaLabelsJson", gson.toJson(new ArrayList<>(comparativaPlanes.keySet())));
                request.setAttribute("comparativaDataJson", gson.toJson(new ArrayList<>(comparativaPlanes.values())));

                RequestDispatcher view = request.getRequestDispatcher("/administrador/reporte-logistica.jsp");
                view.forward(request, response);
                break;
            }

            case "almacen": {
                // 1. Gráfico de Movimientos últimos 7 días (barras apiladas)
                List<Map<String, Object>> mov7d = reporteDAO.getMovimientosUltimos7Dias();
                List<String> m7dias = mov7d.stream().map(map -> (String) map.get("dia")).collect(Collectors.toList());
                List<Integer> m7Entradas = mov7d.stream().map(map -> (Integer) map.get("entradas")).collect(Collectors.toList());
                List<Integer> m7Salidas = mov7d.stream().map(map -> (Integer) map.get("salidas")).collect(Collectors.toList());
                List<Integer> m7Ajustes = mov7d.stream().map(map -> (Integer) map.get("ajustes")).collect(Collectors.toList());
                request.setAttribute("mov7dLabelsJson", gson.toJson(m7dias));
                request.setAttribute("mov7dEntradasJson", gson.toJson(m7Entradas));
                request.setAttribute("mov7dSalidasJson", gson.toJson(m7Salidas));
                request.setAttribute("mov7dAjustesJson", gson.toJson(m7Ajustes));

                // 2. Gráfico de Top 5 Productos con Más Stock
                Map<String, Integer> topProductos = reporteDAO.getTop5ProductosConStock();
                request.setAttribute("topProductosLabelsJson", gson.toJson(new ArrayList<>(topProductos.keySet())));
                request.setAttribute("topProductosDataJson", gson.toJson(new ArrayList<>(topProductos.values())));

                // 3. Gráfico de Actividad de Inventario (Últimos 30 días)
                List<Map<String, Object>> actividadDiaria = reporteDAO.getActividadDiaria30Dias();
                List<String> dias = actividadDiaria.stream().map(map -> (String) map.get("dia")).collect(Collectors.toList());
                List<Integer> entradas = actividadDiaria.stream().map(map -> (Integer) map.get("entradas")).collect(Collectors.toList());
                List<Integer> salidas = actividadDiaria.stream().map(map -> (Integer) map.get("salidas")).collect(Collectors.toList());

                request.setAttribute("actividadLabelsJson", gson.toJson(dias));
                request.setAttribute("actividadEntradasJson", gson.toJson(entradas));
                request.setAttribute("actividadSalidasJson", gson.toJson(salidas));

                // Nuevos reportes de almacén
                // 4. Distribución de Stock por Ubicación
                Map<String, Integer> stockUbicacion = reporteDAO.obtenerDistribucionStockPorUbicacion();
                request.setAttribute("stockUbicacionLabelsJson", gson.toJson(new ArrayList<>(stockUbicacion.keySet())));
                request.setAttribute("stockUbicacionDataJson", gson.toJson(new ArrayList<>(stockUbicacion.values())));

                // 5. Productos con Stock Mínimo/Crítico
                Map<String, Integer> productosStockMinimo = reporteDAO.obtenerProductosStockMinimo();
                request.setAttribute("productosStockMinimoLabelsJson", gson.toJson(new ArrayList<>(productosStockMinimo.keySet())));
                request.setAttribute("productosStockMinimoDataJson", gson.toJson(new ArrayList<>(productosStockMinimo.values())));

                // 6. Almaceneros Más Activos
                Map<String, Integer> almacenerosActivos = reporteDAO.obtenerAlmacenerosMasActivos();
                request.setAttribute("almacenerosActivosLabelsJson", gson.toJson(new ArrayList<>(almacenerosActivos.keySet())));
                request.setAttribute("almacenerosActivosDataJson", gson.toJson(new ArrayList<>(almacenerosActivos.values())));

                // 7. Lotes Próximos a Vencer
                Map<String, Integer> lotesVencer = reporteDAO.obtenerLotesProximosAVencer();
                request.setAttribute("lotesVencerLabelsJson", gson.toJson(new ArrayList<>(lotesVencer.keySet())));
                request.setAttribute("lotesVencerDataJson", gson.toJson(new ArrayList<>(lotesVencer.values())));

                // 8. Tendencias Entradas vs Salidas por Mes
                Map<String, Map<String, Integer>> tendenciasMes = reporteDAO.obtenerTendenciasEntradasSalidasPorMes();
                List<String> mesesLabels = new ArrayList<>(tendenciasMes.keySet());
                List<Integer> entradasMes = new ArrayList<>();
                List<Integer> salidasMes = new ArrayList<>();
                for (String mes : mesesLabels) {
                    Map<String, Integer> datos = tendenciasMes.get(mes);
                    entradasMes.add(datos.getOrDefault("entradas", 0));
                    salidasMes.add(datos.getOrDefault("salidas", 0));
                }
                request.setAttribute("tendenciasMesLabelsJson", gson.toJson(mesesLabels));
                request.setAttribute("tendenciasMesEntradasJson", gson.toJson(entradasMes));
                request.setAttribute("tendenciasMesSalidasJson", gson.toJson(salidasMes));

                // 9. Productos con Mayor Rotación
                Map<String, Integer> productosRotacion = reporteDAO.obtenerProductosMayorRotacion();
                request.setAttribute("productosRotacionLabelsJson", gson.toJson(new ArrayList<>(productosRotacion.keySet())));
                request.setAttribute("productosRotacionDataJson", gson.toJson(new ArrayList<>(productosRotacion.values())));

                RequestDispatcher view = request.getRequestDispatcher("/administrador/reporte-almacen.jsp");
                view.forward(request, response);
                break;
            }

            case "productor": {
                // --- LÓGICA PARA REPORTE PRODUCTOR ---
                int productorId = 3; // fallback por defecto
                // Reutilizar la variable session ya declarada al inicio del método
                if (session != null) {
                    Object u = session.getAttribute("usuario");
                    if (u instanceof Usuario) {
                        Usuario usr = (Usuario) u;
                        if (usr.getRol() != null && usr.getRol().getNombre() != null && usr.getRol().getNombre().equalsIgnoreCase("Productor")) {
                            productorId = usr.getIdUsuario();
                        }
                    }
                }

                Map<String, Integer> topProductos = reporteDAO.getTop5ProductosPorProductor(productorId);
                request.setAttribute("topProductosLabelsJson", gson.toJson(new ArrayList<>(topProductos.keySet())));
                request.setAttribute("topProductosDataJson", gson.toJson(new ArrayList<>(topProductos.values())));

                Map<String, Double> valorCategoria = reporteDAO.getValorInventarioPorCategoria(productorId);
                request.setAttribute("valorCategoriaLabelsJson", gson.toJson(new ArrayList<>(valorCategoria.keySet())));
                request.setAttribute("valorCategoriaDataJson", gson.toJson(new ArrayList<>(valorCategoria.values())));

                Map<String, Integer> lotesVencer = reporteDAO.getLotesProximosAVencer(productorId);
                request.setAttribute("lotesVencerLabelsJson", gson.toJson(new ArrayList<>(lotesVencer.keySet())));
                request.setAttribute("lotesVencerDataJson", gson.toJson(new ArrayList<>(lotesVencer.values())));

                Map<String, Integer> lotesUbicacion = reporteDAO.getDistribucionLotesPorUbicacion(productorId);
                request.setAttribute("lotesUbicacionLabelsJson", gson.toJson(new ArrayList<>(lotesUbicacion.keySet())));
                request.setAttribute("lotesUbicacionDataJson", gson.toJson(new ArrayList<>(lotesUbicacion.values())));

                // Nuevos reportes agregados de TODOS los productores
                Map<String, Integer> distribucionProductores = reporteDAO.obtenerDistribucionProductoresPorCantidadProductos();
                request.setAttribute("distribucionProductoresLabelsJson", gson.toJson(new ArrayList<>(distribucionProductores.keySet())));
                request.setAttribute("distribucionProductoresDataJson", gson.toJson(new ArrayList<>(distribucionProductores.values())));

                Map<String, Integer> topProductoresStock = reporteDAO.obtenerTopProductoresPorStockTotal();
                request.setAttribute("topProductoresStockLabelsJson", gson.toJson(new ArrayList<>(topProductoresStock.keySet())));
                request.setAttribute("topProductoresStockDataJson", gson.toJson(new ArrayList<>(topProductoresStock.values())));

                Map<String, Integer> productosComunes = reporteDAO.obtenerProductosMasComunesEntreProductores();
                request.setAttribute("productosComunesLabelsJson", gson.toJson(new ArrayList<>(productosComunes.keySet())));
                request.setAttribute("productosComunesDataJson", gson.toJson(new ArrayList<>(productosComunes.values())));

                Map<String, Integer> ordenesPorProductor = reporteDAO.obtenerDistribucionOrdenesCompraPorProductor();
                request.setAttribute("ordenesPorProductorLabelsJson", gson.toJson(new ArrayList<>(ordenesPorProductor.keySet())));
                request.setAttribute("ordenesPorProductorDataJson", gson.toJson(new ArrayList<>(ordenesPorProductor.values())));

                Map<String, Double> valorInventarioProductores = reporteDAO.obtenerComparativaValorInventarioPorProductor();
                request.setAttribute("valorInventarioProductoresLabelsJson", gson.toJson(new ArrayList<>(valorInventarioProductores.keySet())));
                request.setAttribute("valorInventarioProductoresDataJson", gson.toJson(new ArrayList<>(valorInventarioProductores.values())));

                RequestDispatcher view = request.getRequestDispatcher("/administrador/reporte-productor.jsp");
                view.forward(request, response);
                break;
            }
        }
    }
}