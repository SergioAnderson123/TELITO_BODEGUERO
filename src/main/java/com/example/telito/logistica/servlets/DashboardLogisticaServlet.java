package com.example.telito.logistica.servlets;

import com.example.telito.logistica.daos.OrdenCompraDao;
import com.example.telito.logistica.daos.PlanTransporteDao;
import com.example.telito.logistica.daos.MovimientoInventarioDao;
import com.example.telito.logistica.daos.InventarioDao;
import com.example.telito.logistica.beans.OrdenCompraBean;
import com.example.telito.logistica.beans.MovimientoInventarioBean;
import com.example.telito.util.AuthorizationHelper;
import com.google.gson.Gson;
import java.util.Map;
import java.util.LinkedHashMap;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.example.telito.util.DatabaseConnection;

// Dashboard principal de logística con métricas y actividad reciente
@WebServlet("/logistica/DashboardLogisticaServlet")
public class DashboardLogisticaServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Solo logística
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederLogistica(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de logística intentó acceder a DashboardLogisticaServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        try {
            // Obtener métricas principales
            MetricasLogistica metricas = obtenerMetricas();
            
            // Actividad reciente
            java.util.List<OrdenCompraBean> ultimasOrdenes = obtenerUltimasOrdenes(5);
            java.util.List<MovimientoInventarioBean> ultimosMovimientos = obtenerUltimosMovimientos(5);
            
            // Datos para gráfico (órdenes por mes - últimos 6 meses)
            Map<String, Integer> ordenesPorMes = obtenerOrdenesPorMes(6);
            
            request.setAttribute("metricas", metricas);
            request.setAttribute("ultimasOrdenes", ultimasOrdenes != null ? ultimasOrdenes : new java.util.ArrayList<>());
            request.setAttribute("ultimosMovimientos", ultimosMovimientos != null ? ultimosMovimientos : new java.util.ArrayList<>());
            request.setAttribute("ordenesPorMesJson", ordenesPorMes != null && !ordenesPorMes.isEmpty() ? 
                new Gson().toJson(new java.util.ArrayList<>(ordenesPorMes.keySet())) : "[]");
            request.setAttribute("ordenesPorMesDataJson", ordenesPorMes != null && !ordenesPorMes.isEmpty() ? 
                new Gson().toJson(new java.util.ArrayList<>(ordenesPorMes.values())) : "[]");
            
            RequestDispatcher dispatcher = request.getRequestDispatcher("/logistica/dashboard-logistica.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            System.err.println("❌ ERROR en DashboardLogisticaServlet: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al cargar el dashboard: " + e.getMessage());
        }
    }
    
    // Obtiene todas las métricas para el dashboard
    private MetricasLogistica obtenerMetricas() {
        MetricasLogistica metricas = new MetricasLogistica();
        
        try {
            OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
            PlanTransporteDao planTransporteDao = new PlanTransporteDao();
            InventarioDao inventarioDao = new InventarioDao();
            
            // Órdenes pendientes
            try {
                metricas.ordenesPendientes = ordenCompraDao.contarOrdenes(null, null, "Pendiente");
            } catch (Exception e) {
                System.err.println("Error al contar órdenes pendientes: " + e.getMessage());
            }
            
            try {
                metricas.ordenesEnProceso = ordenCompraDao.contarOrdenes(null, null, "En Proceso");
            } catch (Exception e) {
                System.err.println("Error al contar órdenes en proceso: " + e.getMessage());
            }
            
            try {
                metricas.ordenesRecibidas = ordenCompraDao.contarOrdenes(null, null, "Recibido");
            } catch (Exception e) {
                System.err.println("Error al contar órdenes recibidas: " + e.getMessage());
            }
            
            try {
                metricas.totalOrdenes = ordenCompraDao.contarOrdenes(null, null, null);
            } catch (Exception e) {
                System.err.println("Error al contar total órdenes: " + e.getMessage());
            }
            
            // Planes de transporte
            try {
                metricas.planesActivos = planTransporteDao.contarPlanes(null, null, "En Ruta", null, null);
            } catch (Exception e) {
                System.err.println("Error al contar planes activos: " + e.getMessage());
            }
            
            try {
                metricas.planesPendientes = planTransporteDao.contarPlanes(null, null, "Pendiente", null, null);
            } catch (Exception e) {
                System.err.println("Error al contar planes pendientes: " + e.getMessage());
            }
            
            try {
                metricas.planesCompletados = planTransporteDao.contarPlanes(null, null, "Completado", null, null);
            } catch (Exception e) {
                System.err.println("Error al contar planes completados: " + e.getMessage());
            }
            
            try {
                metricas.totalPlanes = planTransporteDao.contarPlanes(null, null, null, null, null);
            } catch (Exception e) {
                System.err.println("Error al contar total planes: " + e.getMessage());
            }
            
            // Métricas de inventario
            try {
                metricas.productosStockBajo = inventarioDao.contarInventarioAgrupado(null, "Poco stock");
            } catch (Exception e) {
                System.err.println("Error al contar productos con stock bajo: " + e.getMessage());
            }
            
            try {
                metricas.productosSinStock = inventarioDao.contarInventarioAgrupado(null, "Sin stock");
            } catch (Exception e) {
                System.err.println("Error al contar productos sin stock: " + e.getMessage());
            }
            
            // Alertas críticas
            try {
                metricas.alertasCriticas = contarAlertasCriticas();
            } catch (Exception e) {
                System.err.println("Error al contar alertas críticas: " + e.getMessage());
            }
        } catch (Exception e) {
            System.err.println("Error general al obtener métricas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return metricas;
    }
    
    /**
     * Obtiene las últimas N órdenes de compra.
     */
    private java.util.List<OrdenCompraBean> obtenerUltimasOrdenes(int limite) {
        try {
            OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
            return new java.util.ArrayList<>(ordenCompraDao.obtenerOrdenes(null, null, null, 1, limite));
        } catch (Exception e) {
            System.err.println("Error al obtener últimas órdenes: " + e.getMessage());
            e.printStackTrace();
            return new java.util.ArrayList<>();
        }
    }
    
    /**
     * Obtiene los últimos N movimientos de inventario.
     */
    private java.util.List<MovimientoInventarioBean> obtenerUltimosMovimientos(int limite) {
        try {
            MovimientoInventarioDao movimientoDao = new MovimientoInventarioDao();
            return new java.util.ArrayList<>(movimientoDao.obtenerMovimientos(null, null, null, null, 1, limite));
        } catch (Exception e) {
            System.err.println("Error al obtener últimos movimientos: " + e.getMessage());
            e.printStackTrace();
            return new java.util.ArrayList<>();
        }
    }
    
    /**
     * Obtiene el conteo de órdenes por mes (últimos N meses).
     * Intenta usar fecha_creacion si existe, si no, muestra el total de órdenes.
     */
    private Map<String, Integer> obtenerOrdenesPorMes(int meses) {
        Map<String, Integer> ordenesPorMes = new LinkedHashMap<>();
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Primero intentar con fecha_creacion si existe
            String sql = """
                SELECT 
                    DATE_FORMAT(fecha_creacion, '%Y-%m') AS mes,
                    COUNT(*) AS total
                FROM ordenes_compra
                WHERE fecha_creacion >= DATE_SUB(CURDATE(), INTERVAL ? MONTH)
                GROUP BY DATE_FORMAT(fecha_creacion, '%Y-%m')
                ORDER BY mes ASC
                """;
            
            try {
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, meses);
                rs = pstmt.executeQuery();
                
                boolean tieneDatos = false;
                while (rs.next()) {
                    tieneDatos = true;
                    String mes = rs.getString("mes");
                    if (mes != null && !mes.isEmpty()) {
                        String[] partes = mes.split("-");
                        if (partes.length >= 2) {
                            try {
                                String[] mesesNombres = {"Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"};
                                int mesNum = Integer.parseInt(partes[1]) - 1;
                                if (mesNum >= 0 && mesNum < 12) {
                                    String mesFormateado = mesesNombres[mesNum] + " " + partes[0];
                                    ordenesPorMes.put(mesFormateado, rs.getInt("total"));
                                }
                            } catch (NumberFormatException e) {
                                System.err.println("Error al formatear mes: " + mes);
                            }
                        }
                    }
                }
                
                if (tieneDatos) {
                    return ordenesPorMes; // Si funcionó, retornar
                }
            } catch (SQLException e) {
                // Si falla, la columna no existe, continuar con alternativa
                System.err.println("Columna fecha_creacion no existe, usando total de órdenes: " + e.getMessage());
            } finally {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
            }
            
            // Alternativa: Mostrar el total de órdenes en el mes actual
            String sqlTotal = "SELECT COUNT(*) as total FROM ordenes_compra";
            pstmt = conn.prepareStatement(sqlTotal);
            rs = pstmt.executeQuery();
            
            int totalOrdenes = 0;
            if (rs.next()) {
                totalOrdenes = rs.getInt("total");
            }
            
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            
            // Si hay órdenes, mostrar el total en el mes actual
            if (totalOrdenes > 0) {
                java.util.Calendar cal = java.util.Calendar.getInstance();
                String[] mesesNombres = {"Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"};
                int mesActual = cal.get(java.util.Calendar.MONTH);
                int añoActual = cal.get(java.util.Calendar.YEAR);
                
                String mesFormateado = mesesNombres[mesActual] + " " + añoActual;
                ordenesPorMes.put(mesFormateado, totalOrdenes);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener órdenes por mes: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return ordenesPorMes;
    }
    
    /**
     * Cuenta las alertas críticas (órdenes pendientes por más de 7 días, planes retrasados).
     */
    private int contarAlertasCriticas() {
        try {
            // Intentar con fecha_creacion, si no existe solo contar planes retrasados
            String sql = """
                SELECT 
                    (SELECT COUNT(*) FROM planes_transporte WHERE estado = 'En Ruta' AND fecha_entrega < CURDATE()) as total
                """;
            return ejecutarCount(sql);
        } catch (Exception e) {
            System.err.println("Error al contar alertas críticas: " + e.getMessage());
            return 0;
        }
    }
    
    /**
     * Ejecuta una consulta COUNT y retorna el resultado.
     */
    private int ejecutarCount(String sql) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return 0;
    }
    
    /**
     * Clase interna para almacenar las métricas del dashboard.
     */
    public static class MetricasLogistica {
        public int ordenesPendientes;
        public int ordenesEnProceso;
        public int ordenesRecibidas;
        public int totalOrdenes;
        public int planesActivos;
        public int planesPendientes;
        public int planesCompletados;
        public int totalPlanes;
        public int productosStockBajo;
        public int productosSinStock;
        public int alertasCriticas;
        
        // Getters para JSP
        public int getOrdenesPendientes() { return ordenesPendientes; }
        public int getOrdenesEnProceso() { return ordenesEnProceso; }
        public int getOrdenesRecibidas() { return ordenesRecibidas; }
        public int getTotalOrdenes() { return totalOrdenes; }
        public int getPlanesActivos() { return planesActivos; }
        public int getPlanesPendientes() { return planesPendientes; }
        public int getPlanesCompletados() { return planesCompletados; }
        public int getTotalPlanes() { return totalPlanes; }
        public int getProductosStockBajo() { return productosStockBajo; }
        public int getProductosSinStock() { return productosSinStock; }
        public int getAlertasCriticas() { return alertasCriticas; }
    }
}

