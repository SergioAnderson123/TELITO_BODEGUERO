package com.example.telito.administrador.servlets;

import com.example.telito.logistica.beans.InventarioBean;
import com.example.telito.logistica.daos.InventarioDao;
import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.administrador.beans.Producto;
import com.example.telito.administrador.daos.ProductoDAO;
import com.example.telito.logistica.daos.ProveedorDao;
import com.example.telito.logistica.beans.ProveedorBean;
import com.example.telito.productor.daos.OrdenCompraDao;
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
        
        // Inventario desde perspectiva de Logística (agrupado por producto)
        InventarioDao inventarioDao = new InventarioDao();
        ArrayList<InventarioBean> listaLogistica = inventarioDao.obtenerInventarioAgrupado(busquedaLogistica, null, 1, 100);
        request.setAttribute("listaLogistica", listaLogistica);
        request.setAttribute("busquedaLogistica", busquedaLogistica);

        // Inventario desde perspectiva de Almacén (lotes registrados)
        com.example.telito.almacen.daos.LoteDao loteDao = new com.example.telito.almacen.daos.LoteDao();
        String busquedaAlmacen = request.getParameter("busquedaAlmacen");
        // El filtro de almacén se aplica por estado (Activo, Vencido, Por Vencer)
        // pero el método listarLotesRegistrados usa estadoStock (En Stock, Poco Stock, Sin Stock)
        // Por ahora, solo aplicamos la búsqueda
        ArrayList<com.example.telito.almacen.beans.Lote> listaAlmacen = loteDao.listarLotesRegistrados(1, busquedaAlmacen, null);
        request.setAttribute("listaAlmacen", listaAlmacen);
        request.setAttribute("busquedaAlmacen", busquedaAlmacen);
        request.setAttribute("filtroAlmacen", filtroAlmacen);
        request.setAttribute("filtroLogistica", filtroLogistica);
        request.setAttribute("filtroProductor", filtroProductor);
        request.setAttribute("busquedaProductores", busquedaProductores);

        // Inventario desde perspectiva de Productores - AGRUPADO POR PRODUCTOR
        ProductoDAO productoDao = new ProductoDAO();
        
        // Obtener todos los productores
        ProveedorDao proveedorDao = new ProveedorDao();
        ArrayList<ProveedorBean> listaProductoresUsuarios = proveedorDao.listarProductores();
        
        // Agrupar productos por productor con órdenes de compra y movimientos
        Map<Integer, Map<String, Object>> inventarioPorProductor = new HashMap<>();
        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
        MovimientoDao movimientoDao = new MovimientoDao();
        
        for (ProveedorBean productor : listaProductoresUsuarios) {
            int productorId = productor.getId();
            String nombreProductor = productor.getNombre();
            
            // Aplicar filtro por productor
            if (filtroProductor != null && !filtroProductor.trim().isEmpty()) {
                if (!String.valueOf(productorId).equals(filtroProductor.trim())) {
                    continue; // Saltar este productor si no coincide con el filtro
                }
            }
            
            // Obtener productos de este productor
            ArrayList<Producto> productos = productoDao.listarProductosPorProductor(productorId);
            
            // Aplicar búsqueda de productos si existe
            if (busquedaProductores != null && !busquedaProductores.trim().isEmpty()) {
                String busquedaLower = busquedaProductores.toLowerCase().trim();
                ArrayList<Producto> productosFiltrados = new ArrayList<>();
                for (Producto p : productos) {
                    if ((p.getCodigoSku() != null && p.getCodigoSku().toLowerCase().contains(busquedaLower)) ||
                        (p.getNombre() != null && p.getNombre().toLowerCase().contains(busquedaLower)) ||
                        (p.getCategoriaNombre() != null && p.getCategoriaNombre().toLowerCase().contains(busquedaLower))) {
                        productosFiltrados.add(p);
                    }
                }
                productos = productosFiltrados;
            }
            
            // Limitar a 9 productos por productor
            if (productos.size() > 9) {
                productos = new ArrayList<>(productos.subList(0, 9));
            }
            
            // Solo agregar si tiene productos o si no hay filtro aplicado
            if (!productos.isEmpty() || (filtroProductor == null || filtroProductor.trim().isEmpty())) {
                Map<String, Object> datosProductor = new HashMap<>();
                datosProductor.put("id", productorId);
                datosProductor.put("nombre", nombreProductor);
                datosProductor.put("productos", productos);
                
                // Obtener estadísticas del productor
                int totalProductos = productos.size();
                int totalStock = productos.stream().mapToInt(Producto::getStock).sum();
                datosProductor.put("totalProductos", totalProductos);
                datosProductor.put("totalStock", totalStock);
                
                // Obtener órdenes de compra del productor
                try {
                    List<Object[]> ordenesCompra = ordenCompraDao.listarOrdenesPorProductor(productorId);
                    datosProductor.put("ordenesCompra", ordenesCompra);
                    datosProductor.put("totalOrdenes", ordenesCompra.size());
                } catch (Exception e) {
                    System.err.println("Error al obtener órdenes de compra para productor " + productorId + ": " + e.getMessage());
                    datosProductor.put("ordenesCompra", new ArrayList<>());
                    datosProductor.put("totalOrdenes", 0);
                }
                
                // Obtener movimientos por cada producto del productor
                Map<Integer, List<Object>> movimientosPorProducto = new HashMap<>();
                int totalMovimientos = 0;
                
                for (Producto producto : productos) {
                    try {
                        // Obtener movimientos del producto (últimos 10)
                        List<Object> movimientos = obtenerMovimientosPorProducto(producto.getIdProducto(), movimientoDao);
                        movimientosPorProducto.put(producto.getIdProducto(), movimientos);
                        totalMovimientos += movimientos.size();
                    } catch (Exception e) {
                        System.err.println("Error al obtener movimientos para producto " + producto.getIdProducto() + ": " + e.getMessage());
                        movimientosPorProducto.put(producto.getIdProducto(), new ArrayList<>());
                    }
                }
                
                datosProductor.put("movimientosPorProducto", movimientosPorProducto);
                datosProductor.put("totalMovimientos", totalMovimientos);
                
                inventarioPorProductor.put(productorId, datosProductor);
            }
        }
        
        request.setAttribute("inventarioPorProductor", inventarioPorProductor);
        request.setAttribute("listaProductoresUsuarios", listaProductoresUsuarios);
        request.setAttribute("filtroProductor", filtroProductor);
        request.setAttribute("busquedaProductores", busquedaProductores);
        
        // Para compatibilidad con el JSP existente
        ArrayList<Producto> listaProductores = productoDao.listarProductos();
        request.setAttribute("listaProductores", listaProductores);

        RequestDispatcher rd = request.getRequestDispatcher("/administrador/inventario-general.jsp");
        rd.forward(request, response);
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
