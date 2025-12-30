package com.example.telito.administrador.servlets;

import com.example.telito.logistica.beans.InventarioBean;
import com.example.telito.logistica.daos.InventarioDao;
import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.administrador.beans.Producto;
import com.example.telito.administrador.daos.ProductoDAO;
import com.example.telito.logistica.daos.ProveedorDao;
import com.example.telito.logistica.beans.ProveedorBean;
import com.example.telito.logistica.daos.OrdenCompraDao;
import com.example.telito.almacen.daos.MovimientoDao;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// Vista consolidada de inventario desde todas las perspectivas (Logística, Almacén, Productores)
@WebServlet(name = "InventarioGeneralServlet", value = "/administrador/inventario-general")
public class InventarioGeneralServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Solo administradores
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a InventarioGeneralServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        // Obtener filtros
        String tab = request.getParameter("tab");
        String filtroProductor = request.getParameter("filtroProductor");
        String filtroLogistica = request.getParameter("filtroLogistica");
        String filtroAlmacen = request.getParameter("filtroAlmacen");
        String busquedaLogistica = request.getParameter("busquedaLogistica");
        String busquedaProductores = request.getParameter("busquedaProductores");
        
        // Preservar el tab activo
        if (tab == null || tab.isEmpty()) {
            tab = "logistica"; // Por defecto
        }
        request.setAttribute("tabActivo", tab);
        
        // Inventario desde perspectiva de Logística: Mostrar ÓRDENES DE COMPRA (exclusivo de logística)
        com.example.telito.logistica.daos.OrdenCompraDao ordenCompraDao = new com.example.telito.logistica.daos.OrdenCompraDao();
        
        // Obtener filtro de usuario de logística
        String filtroUsuarioLogistica = request.getParameter("filtroUsuarioLogistica");
        
        // Obtener órdenes de compra con filtros (sin filtro de productor, ya que no es relevante para logística)
        ArrayList<com.example.telito.logistica.beans.OrdenCompraBean> listaOrdenesCompra = 
            ordenCompraDao.obtenerOrdenes(busquedaLogistica, null, filtroLogistica, 1, 100);
        
        // Obtener lista de usuarios de logística para el filtro
        com.example.telito.administrador.daos.UsuarioDAO usuarioDAO = new com.example.telito.administrador.daos.UsuarioDAO();
        ArrayList<com.example.telito.administrador.beans.Usuario> usuariosLogistica = usuarioDAO.listarUsuarios(null, "2", "1", null, null, 1, 1000); // Rol 2 = Logística
        
        // Filtrar por usuario de logística si se especifica (filtrar por nombre del personal responsable)
        if (filtroUsuarioLogistica != null && !filtroUsuarioLogistica.trim().isEmpty()) {
            int usuarioId = Integer.parseInt(filtroUsuarioLogistica);
            // Obtener el nombre del usuario para comparar
            String nombreUsuarioFiltro = null;
            for (com.example.telito.administrador.beans.Usuario u : usuariosLogistica) {
                if (u.getIdUsuario() == usuarioId) {
                    nombreUsuarioFiltro = u.getNombres() + " " + u.getApellidos();
                    break;
                }
            }
            if (nombreUsuarioFiltro != null) {
                final String nombreFinal = nombreUsuarioFiltro;
                listaOrdenesCompra.removeIf(orden -> !orden.getPersonalResponsable().equals(nombreFinal));
            }
        }
        
        request.setAttribute("listaOrdenesCompra", listaOrdenesCompra);
        request.setAttribute("busquedaLogistica", busquedaLogistica);
        request.setAttribute("usuariosLogistica", usuariosLogistica);
        request.setAttribute("filtroUsuarioLogistica", filtroUsuarioLogistica);

        // Inventario desde perspectiva de Almacén: Mostrar MOVIMIENTOS DE INVENTARIO (exclusivo de almacén)
        MovimientoDao movimientoDao = new MovimientoDao();
        String busquedaAlmacen = request.getParameter("busquedaAlmacen");
        String filtroTipoMovimiento = request.getParameter("filtroTipoMovimiento");
        String filtroUsuarioAlmacen = request.getParameter("filtroUsuarioAlmacen");
        
        // Obtener lista de usuarios de almacén para el filtro
        com.example.telito.administrador.daos.UsuarioDAO usuarioDAOAlmacen = new com.example.telito.administrador.daos.UsuarioDAO();
        ArrayList<com.example.telito.administrador.beans.Usuario> usuariosAlmacen = usuarioDAOAlmacen.listarUsuarios(null, "4", "1", null, null, 1, 1000); // Rol 4 = Almacenero
        
        // Obtener nombre del usuario si se especifica el filtro
        String responsableNombre = null;
        if (filtroUsuarioAlmacen != null && !filtroUsuarioAlmacen.trim().isEmpty()) {
            int usuarioId = Integer.parseInt(filtroUsuarioAlmacen);
            for (com.example.telito.administrador.beans.Usuario u : usuariosAlmacen) {
                if (u.getIdUsuario() == usuarioId) {
                    responsableNombre = u.getNombres() + " " + u.getApellidos();
                    break;
                }
            }
        }
        
        // Obtener movimientos de inventario con filtros
        ArrayList<com.example.telito.almacen.beans.Movimiento> listaMovimientos = 
            movimientoDao.listarMovimientosPaginado(100, 0, busquedaAlmacen, filtroTipoMovimiento, responsableNombre);
        
        request.setAttribute("listaMovimientos", listaMovimientos);
        request.setAttribute("busquedaAlmacen", busquedaAlmacen);
        request.setAttribute("filtroTipoMovimiento", filtroTipoMovimiento);
        request.setAttribute("usuariosAlmacen", usuariosAlmacen);
        request.setAttribute("filtroUsuarioAlmacen", filtroUsuarioAlmacen);
        request.setAttribute("filtroLogistica", filtroLogistica);
        request.setAttribute("filtroProductor", filtroProductor);
        request.setAttribute("busquedaProductores", busquedaProductores);

        // Inventario desde perspectiva de Productores: Mostrar LOTES REGISTRADOS (exclusivo de productores)
        String filtroEstadoLote = request.getParameter("filtroEstadoLote");
        
        // Obtener todos los productores para el filtro
        ProveedorDao proveedorDao = new ProveedorDao();
        ArrayList<ProveedorBean> listaProductoresUsuarios = proveedorDao.listarProductores();
        
        // Obtener lotes con información del productor
        ArrayList<Map<String, Object>> listaLotesProductores = obtenerLotesConProductor(busquedaProductores, filtroProductor, filtroEstadoLote);
        
        request.setAttribute("listaLotesProductores", listaLotesProductores);
        request.setAttribute("listaProductoresUsuarios", listaProductoresUsuarios);
        request.setAttribute("filtroProductor", filtroProductor);
        request.setAttribute("busquedaProductores", busquedaProductores);
        request.setAttribute("filtroEstadoLote", filtroEstadoLote);

        RequestDispatcher rd = request.getRequestDispatcher("/administrador/inventario-general.jsp");
        rd.forward(request, response);
    }
    
    /**
     * Obtiene lotes con información del productor (exclusivo de productores)
     */
    private ArrayList<Map<String, Object>> obtenerLotesConProductor(String busqueda, String filtroProductor, String filtroEstado) {
        ArrayList<Map<String, Object>> listaLotes = new ArrayList<>();
        
        String sql = "SELECT " +
                "l.codigo_lote, " +
                "p.nombre AS nombre_producto, " +
                "l.stock_actual AS cantidad, " +
                "l.costo_produccion, " +
                "l.fecha_vencimiento, " +
                "l.estado, " +
                "CONCAT(u.nombres, ' ', u.apellidos) AS nombre_productor, " +
                "u.id_usuario AS productor_id " +
                "FROM lotes l " +
                "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                "INNER JOIN usuarios u ON p.productor_id = u.id_usuario " +
                "WHERE 1=1";
        
        java.util.List<Object> params = new java.util.ArrayList<>();
        
        // Filtro por productor
        if (filtroProductor != null && !filtroProductor.trim().isEmpty()) {
            sql += " AND u.id_usuario = ?";
            params.add(Integer.parseInt(filtroProductor));
        }
        
        // Filtro por estado
        if (filtroEstado != null && !filtroEstado.trim().isEmpty()) {
            sql += " AND l.estado = ?";
            params.add(filtroEstado);
        }
        
        // Filtro por búsqueda (código lote, producto, productor)
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (l.codigo_lote LIKE ? OR p.nombre LIKE ? OR CONCAT(u.nombres, ' ', u.apellidos) LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
            params.add(busquedaParam);
        }
        
        sql += " ORDER BY l.codigo_lote DESC";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = com.example.telito.util.DatabaseConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            
            // Establecer parámetros
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> lote = new HashMap<>();
                lote.put("codigoLote", rs.getString("codigo_lote"));
                lote.put("nombreProducto", rs.getString("nombre_producto"));
                lote.put("cantidad", rs.getInt("cantidad"));
                lote.put("costoProduccion", rs.getBigDecimal("costo_produccion"));
                lote.put("fechaVencimiento", rs.getDate("fecha_vencimiento"));
                lote.put("estado", rs.getString("estado"));
                lote.put("nombreProductor", rs.getString("nombre_productor"));
                lote.put("productorId", rs.getInt("productor_id"));
                listaLotes.add(lote);
            }
        } catch (Exception e) {
            System.err.println("Error al obtener lotes de productores: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                System.err.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
        
        return listaLotes;
    }
    
    /**
     * Obtiene los últimos movimientos de inventario para un producto específico
     */
    private List<Object> obtenerMovimientosPorProducto(int productoId, MovimientoDao movimientoDao) {
        List<Object> movimientos = new ArrayList<>();
        
        String sql = "SELECT " +
                "m.id_movimiento, m.tipo, m.cantidad, m.motivo, m.fecha, " +
                "l.codigo_lote, " +
                "p.nombre AS nombre_producto, " +
                "CONCAT(u.nombres, ' ', u.apellidos) AS nombre_usuario, " +
                "ped.numero_pedido, " +
                "oc.numero_orden " +
                "FROM movimientos_inventario m " +
                "INNER JOIN lotes l ON (m.lote_id = l.id_lote) " +
                "INNER JOIN productos p ON (l.producto_id = p.id_producto) " +
                "INNER JOIN usuarios u ON (m.usuario_id = u.id_usuario) " +
                "LEFT JOIN pedidos ped ON (m.pedido_id = ped.id_pedido) " +
                "LEFT JOIN ordenes_compra oc ON (m.orden_compra_id = oc.id_orden_compra) " +
                "WHERE p.id_producto = ? " +
                "ORDER BY m.fecha DESC " +
                "LIMIT 10";
        
        java.sql.Connection conn = null;
        java.sql.PreparedStatement pstmt = null;
        java.sql.ResultSet rs = null;
        
        try {
            conn = com.example.telito.util.DatabaseConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productoId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> movimiento = new HashMap<>();
                movimiento.put("id", rs.getInt("id_movimiento"));
                movimiento.put("tipo", rs.getString("tipo"));
                movimiento.put("cantidad", rs.getInt("cantidad"));
                movimiento.put("motivo", rs.getString("motivo"));
                movimiento.put("fecha", rs.getTimestamp("fecha"));
                movimiento.put("codigoLote", rs.getString("codigo_lote"));
                movimiento.put("nombreProducto", rs.getString("nombre_producto"));
                movimiento.put("nombreUsuario", rs.getString("nombre_usuario"));
                movimiento.put("numeroPedido", rs.getString("numero_pedido"));
                movimiento.put("numeroOrden", rs.getString("numero_orden"));
                movimientos.add(movimiento);
            }
        } catch (java.sql.SQLException e) {
            System.err.println("Error al obtener movimientos por producto: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (java.sql.SQLException e) {
                System.err.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
        
        return movimientos;
    }
}
