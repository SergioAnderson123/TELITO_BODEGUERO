package com.example.telito.administrador.servlets;

import com.example.telito.administrador.daos.ReporteDAO;
import com.example.telito.administrador.dtos.UsuariosPorRolDto;
import com.example.telito.administrador.dtos.ProductosPorCategoriaDto;
import com.example.telito.administrador.dtos.MovimientosInventarioDto;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;

/**
 * Servlet para manejar reportes y estadísticas del sistema.
 * Utiliza DTOs para transferir datos complejos entre capas.
 */
@WebServlet(name = "ReporteServlet", value = "/ReporteServlet")
public class ReporteServlet extends HttpServlet {

    /**
     * Maneja las solicitudes GET para mostrar diferentes tipos de reportes.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Verificar sesión de usuario
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioSesion") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }
        
        String tipoReporte = request.getParameter("tipo") != null ? 
                           request.getParameter("tipo") : "general";
        
        ReporteDAO reporteDAO = new ReporteDAO();
        RequestDispatcher view;
        
        switch (tipoReporte) {
            case "usuarios":
                // Reporte de usuarios por rol usando DTO
                ArrayList<UsuariosPorRolDto> usuariosPorRol = reporteDAO.obtenerUsuariosPorRol();
                request.setAttribute("reporteUsuarios", usuariosPorRol);
                view = request.getRequestDispatcher("/administrador/reporte-usuarios.jsp");
                break;
                
            case "productos":
                // Reporte de productos por categoría usando DTO
                ArrayList<ProductosPorCategoriaDto> productosPorCategoria = reporteDAO.obtenerProductosPorCategoria();
                request.setAttribute("reporteProductos", productosPorCategoria);
                view = request.getRequestDispatcher("/administrador/reporte-productos.jsp");
                break;
                
            case "movimientos":
                // Reporte de movimientos por período usando DTO
                String fechaInicioStr = request.getParameter("fechaInicio");
                String fechaFinStr = request.getParameter("fechaFin");
                
                LocalDate fechaInicio = fechaInicioStr != null ? 
                    LocalDate.parse(fechaInicioStr, DateTimeFormatter.ISO_LOCAL_DATE) : 
                    LocalDate.now().minusDays(30);
                LocalDate fechaFin = fechaFinStr != null ? 
                    LocalDate.parse(fechaFinStr, DateTimeFormatter.ISO_LOCAL_DATE) : 
                    LocalDate.now();
                
                ArrayList<MovimientosInventarioDto> movimientosPorPeriodo = 
                    reporteDAO.obtenerMovimientosPorPeriodo(fechaInicio, fechaFin);
                
                request.setAttribute("reporteMovimientos", movimientosPorPeriodo);
                request.setAttribute("fechaInicio", fechaInicio);
                request.setAttribute("fechaFin", fechaFin);
                view = request.getRequestDispatcher("/administrador/reporte-movimientos.jsp");
                break;
                
            case "general":
            default:
                // Estadísticas generales del sistema
                ArrayList<String> estadisticasGenerales = reporteDAO.obtenerEstadisticasGenerales();
                request.setAttribute("estadisticasGenerales", estadisticasGenerales);
                view = request.getRequestDispatcher("/administrador/reportes-globales.jsp");
                break;
        }
        
        view.forward(request, response);
    }

    /**
     * Maneja las solicitudes POST para generar reportes con filtros.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Verificar sesión de usuario
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioSesion") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }
        
        String tipoReporte = request.getParameter("tipoReporte");
        
        // Redirigir según el tipo de reporte solicitado
        switch (tipoReporte) {
            case "usuarios":
                response.sendRedirect(request.getContextPath() + "/ReporteServlet?tipo=usuarios");
                break;
            case "productos":
                response.sendRedirect(request.getContextPath() + "/ReporteServlet?tipo=productos");
                break;
            case "movimientos":
                String fechaInicio = request.getParameter("fechaInicio");
                String fechaFin = request.getParameter("fechaFin");
                response.sendRedirect(request.getContextPath() + 
                    "/ReporteServlet?tipo=movimientos&fechaInicio=" + fechaInicio + 
                    "&fechaFin=" + fechaFin);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/ReporteServlet?tipo=general");
                break;
        }
    }
}