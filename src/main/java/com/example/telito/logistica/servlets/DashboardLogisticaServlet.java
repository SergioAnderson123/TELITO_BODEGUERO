package com.example.telito.logistica.servlets;

import com.example.telito.logistica.daos.OrdenCompraDao;
import com.example.telito.logistica.daos.PlanTransporteDao;
import com.example.telito.logistica.daos.MovimientoInventarioDao;
import com.example.telito.util.AuthorizationHelper;
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

@WebServlet("/logistica/DashboardLogisticaServlet")
public class DashboardLogisticaServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederLogistica(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de logística intentó acceder a DashboardLogisticaServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        // Obtener métricas del dashboard
        MetricasLogistica metricas = obtenerMetricas();
        
        request.setAttribute("metricas", metricas);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/logistica/dashboard-logistica.jsp");
        dispatcher.forward(request, response);
    }
    
    /**
     * Obtiene todas las métricas para el dashboard logístico.
     */
    private MetricasLogistica obtenerMetricas() {
        MetricasLogistica metricas = new MetricasLogistica();
        
        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
        PlanTransporteDao planTransporteDao = new PlanTransporteDao();
        
        // Órdenes pendientes
        metricas.ordenesPendientes = ordenCompraDao.contarOrdenes(null, null, "Pendiente");
        metricas.ordenesEnProceso = ordenCompraDao.contarOrdenes(null, null, "En Proceso");
        metricas.ordenesRecibidas = ordenCompraDao.contarOrdenes(null, null, "Recibido");
        metricas.totalOrdenes = ordenCompraDao.contarOrdenes(null, null, null);
        
        // Planes de transporte
        metricas.planesActivos = planTransporteDao.contarPlanes(null, null, "En Ruta", null, null);
        metricas.planesPendientes = planTransporteDao.contarPlanes(null, null, "Pendiente", null, null);
        metricas.planesCompletados = planTransporteDao.contarPlanes(null, null, "Completado", null, null);
        metricas.totalPlanes = planTransporteDao.contarPlanes(null, null, null, null, null);
        
        // Eficiencia de entregas
        metricas.eficienciaEntregas = calcularEficienciaEntregas();
        
        // Movimientos recientes
        metricas.movimientosHoy = contarMovimientosHoy();
        metricas.movimientosSemana = contarMovimientosSemana();
        
        // Alertas críticas
        metricas.alertasCriticas = contarAlertasCriticas();
        
        return metricas;
    }
    
    /**
     * Calcula la eficiencia de entregas (porcentaje de entregas completadas a tiempo).
     */
    private double calcularEficienciaEntregas() {
        String sql = """
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN pt.estado = 'Completado' AND pt.fecha_entrega <= CURDATE() THEN 1 ELSE 0 END) as completados_a_tiempo
            FROM planes_transporte pt
            WHERE pt.fecha_entrega IS NOT NULL
            AND pt.fecha_entrega >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
            """;
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                int total = rs.getInt("total");
                int completadosATiempo = rs.getInt("completados_a_tiempo");
                
                if (total > 0) {
                    return (completadosATiempo * 100.0) / total;
                }
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
        
        return 0.0;
    }
    
    /**
     * Cuenta los movimientos de inventario realizados hoy.
     */
    private int contarMovimientosHoy() {
        String sql = "SELECT COUNT(*) as total FROM movimientos_inventario WHERE DATE(fecha) = CURDATE()";
        return ejecutarCount(sql);
    }
    
    /**
     * Cuenta los movimientos de inventario de la última semana.
     */
    private int contarMovimientosSemana() {
        String sql = "SELECT COUNT(*) as total FROM movimientos_inventario WHERE fecha >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
        return ejecutarCount(sql);
    }
    
    /**
     * Cuenta las alertas críticas (órdenes pendientes por más de 7 días, planes retrasados).
     */
    private int contarAlertasCriticas() {
        String sql = """
            SELECT 
                (SELECT COUNT(*) FROM ordenes_compra WHERE estado = 'Pendiente' AND fecha_creacion < DATE_SUB(CURDATE(), INTERVAL 7 DAY)) +
                (SELECT COUNT(*) FROM planes_transporte WHERE estado = 'En Ruta' AND fecha_entrega < CURDATE()) as total
            """;
        return ejecutarCount(sql);
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
        public double eficienciaEntregas;
        public int movimientosHoy;
        public int movimientosSemana;
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
        public double getEficienciaEntregas() { return eficienciaEntregas; }
        public int getMovimientosHoy() { return movimientosHoy; }
        public int getMovimientosSemana() { return movimientosSemana; }
        public int getAlertasCriticas() { return alertasCriticas; }
    }
}

