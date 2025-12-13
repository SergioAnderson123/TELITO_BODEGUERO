package com.example.telito.productor.servlets;

import com.example.telito.productor.daos.ProductoDao;
import com.example.telito.productor.daos.LoteDao;
import com.example.telito.productor.daos.OrdenCompraDao;
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

@WebServlet("/productor/DashboardProductorServlet")
public class DashboardProductorServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederProductor(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de productor intentó acceder a DashboardProductorServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        // Redirigir al dashboard correcto (inicio-productor.jsp a través de ProductorServlet)
        response.sendRedirect(request.getContextPath() + "/ProductorServlet?action=inicio");
    }
    
    /**
     * Obtiene todas las métricas para el dashboard del productor.
     */
    private MetricasProductor obtenerMetricas(int idProductor) {
        MetricasProductor metricas = new MetricasProductor();
        
        ProductoDao productoDao = new ProductoDao();
        LoteDao loteDao = new LoteDao();
        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
        
        // Productos activos
        metricas.productosActivos = productoDao.contarProductosPorProductor(idProductor);
        
        // Lotes registrados este mes
        metricas.lotesEsteMes = contarLotesEsteMes(idProductor);
        
        // Órdenes pendientes
        metricas.ordenesPendientes = contarOrdenesPendientes(idProductor);
        
        // Órdenes en proceso
        metricas.ordenesEnProceso = contarOrdenesEnProceso(idProductor);
        
        // Total de órdenes
        metricas.totalOrdenes = contarTotalOrdenes(idProductor);
        
        // Stock total
        metricas.stockTotal = calcularStockTotal(idProductor);
        
        // Lotes próximos a vencer (próximos 30 días)
        metricas.lotesProximosVencer = contarLotesProximosVencer(idProductor);
        
        return metricas;
    }
    
    /**
     * Cuenta los lotes registrados este mes por el productor.
     */
    private int contarLotesEsteMes(int idProductor) {
        // Si no existe fecha_creacion, usar id_lote como aproximación (lotes más recientes)
        String sql = """
            SELECT COUNT(*) as total
            FROM lotes l
            INNER JOIN productos p ON l.producto_id = p.id_producto
            WHERE p.productor_id = ?
            AND l.id_lote >= (
                SELECT GREATEST(COALESCE(MAX(id_lote), 100) - 100, 0)
                FROM lotes l2
                INNER JOIN productos p2 ON l2.producto_id = p2.id_producto
                WHERE p2.productor_id = ?
            )
            """;
        // Ejecutar con dos parámetros (idProductor dos veces)
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idProductor);
            pstmt.setInt(2, idProductor);
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
     * Cuenta las órdenes pendientes del productor.
     */
    private int contarOrdenesPendientes(int idProductor) {
        String sql = """
            SELECT COUNT(*) as total
            FROM ordenes_compra
            WHERE productor_id = ? AND estado = 'Pendiente'
            """;
        return ejecutarCount(sql, idProductor);
    }
    
    /**
     * Cuenta las órdenes en proceso del productor.
     */
    private int contarOrdenesEnProceso(int idProductor) {
        String sql = """
            SELECT COUNT(*) as total
            FROM ordenes_compra
            WHERE productor_id = ? AND estado = 'En Proceso'
            """;
        return ejecutarCount(sql, idProductor);
    }
    
    /**
     * Cuenta el total de órdenes del productor.
     */
    private int contarTotalOrdenes(int idProductor) {
        String sql = """
            SELECT COUNT(*) as total
            FROM ordenes_compra
            WHERE productor_id = ?
            """;
        return ejecutarCount(sql, idProductor);
    }
    
    /**
     * Calcula el stock total de todos los productos del productor.
     */
    private int calcularStockTotal(int idProductor) {
        String sql = """
            SELECT COALESCE(SUM(l.stock_actual), 0) as total
            FROM lotes l
            INNER JOIN productos p ON l.producto_id = p.id_producto
            WHERE p.productor_id = ?
            """;
        return ejecutarCount(sql, idProductor);
    }
    
    /**
     * Cuenta los lotes que vencen en los próximos 30 días.
     */
    private int contarLotesProximosVencer(int idProductor) {
        String sql = """
            SELECT COUNT(*) as total
            FROM lotes l
            INNER JOIN productos p ON l.producto_id = p.id_producto
            WHERE p.productor_id = ?
            AND l.fecha_vencimiento IS NOT NULL
            AND l.fecha_vencimiento BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
            """;
        return ejecutarCount(sql, idProductor);
    }
    
    /**
     * Ejecuta una consulta COUNT y retorna el resultado.
     */
    private int ejecutarCount(String sql, int idProductor) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idProductor);
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
    public static class MetricasProductor {
        public int productosActivos;
        public int lotesEsteMes;
        public int ordenesPendientes;
        public int ordenesEnProceso;
        public int totalOrdenes;
        public int stockTotal;
        public int lotesProximosVencer;
        
        // Getters para JSP
        public int getProductosActivos() { return productosActivos; }
        public int getLotesEsteMes() { return lotesEsteMes; }
        public int getOrdenesPendientes() { return ordenesPendientes; }
        public int getOrdenesEnProceso() { return ordenesEnProceso; }
        public int getTotalOrdenes() { return totalOrdenes; }
        public int getStockTotal() { return stockTotal; }
        public int getLotesProximosVencer() { return lotesProximosVencer; }
    }
}

