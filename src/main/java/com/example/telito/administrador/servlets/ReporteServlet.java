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

                Map<String, Integer> rendimientoConductores = reporteDAO.obtenerRendimientoConductores();
                request.setAttribute("conductoresLabelsJson", gson.toJson(new ArrayList<>(rendimientoConductores.keySet())));
                request.setAttribute("conductoresDataJson", gson.toJson(new ArrayList<>(rendimientoConductores.values())));

                Map<String, Integer> pedidosMes = reporteDAO.obtenerHistorialPedidosDespachados();
                request.setAttribute("pedidosMesLabelsJson", gson.toJson(new ArrayList<>(pedidosMes.keySet())));
                request.setAttribute("pedidosMesDataJson", gson.toJson(new ArrayList<>(pedidosMes.values())));

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

                // 3. Gráfico de Motivos de Ajuste de Inventario
                Map<String, Integer> motivosAjuste = reporteDAO.getMotivosDeAjuste();
                request.setAttribute("ajustesLabelsJson", gson.toJson(new ArrayList<>(motivosAjuste.keySet())));
                request.setAttribute("ajustesDataJson", gson.toJson(new ArrayList<>(motivosAjuste.values())));

                // 4. Gráfico de Actividad de Inventario (Últimos 30 días)
                List<Map<String, Object>> actividadDiaria = reporteDAO.getActividadDiaria30Dias();
                List<String> dias = actividadDiaria.stream().map(map -> (String) map.get("dia")).collect(Collectors.toList());
                List<Integer> entradas = actividadDiaria.stream().map(map -> (Integer) map.get("entradas")).collect(Collectors.toList());
                List<Integer> salidas = actividadDiaria.stream().map(map -> (Integer) map.get("salidas")).collect(Collectors.toList());

                request.setAttribute("actividadLabelsJson", gson.toJson(dias));
                request.setAttribute("actividadEntradasJson", gson.toJson(entradas));
                request.setAttribute("actividadSalidasJson", gson.toJson(salidas));

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

                RequestDispatcher view = request.getRequestDispatcher("/administrador/reporte-productor.jsp");
                view.forward(request, response);
                break;
            }
        }
    }
}