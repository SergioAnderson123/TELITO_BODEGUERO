package com.example.telito.administrador.daos;

import com.example.telito.administrador.dtos.UsuariosPorRolDto;
import com.example.telito.administrador.dtos.ProductosPorCategoriaDto;
import com.example.telito.administrador.dtos.MovimientosInventarioDto;
import com.example.telito.dao.BaseDao;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;

/**
 * DAO para generar reportes complejos usando DTOs.
 * Extiende de BaseDao para heredar la funcionalidad de conexión.
 */
public class ReporteDAO extends BaseDao {

    /**
     * Obtiene estadísticas de usuarios agrupados por rol.
     * 
     * @return ArrayList<UsuariosPorRolDto> lista de estadísticas por rol
     */
    public ArrayList<UsuariosPorRolDto> obtenerUsuariosPorRol() {
        ArrayList<UsuariosPorRolDto> listaReporte = new ArrayList<>();
        String sql = "SELECT r.nombre AS nombre_rol, " +
                    "COUNT(u.id_usuario) AS cantidad_usuarios, " +
                    "SUM(CASE WHEN u.activo = 1 THEN 1 ELSE 0 END) AS usuarios_activos, " +
                    "SUM(CASE WHEN u.activo = 0 THEN 1 ELSE 0 END) AS usuarios_inactivos " +
                    "FROM roles r " +
                    "LEFT JOIN usuarios u ON r.id_rol = u.rol_id " +
                    "GROUP BY r.id_rol, r.nombre " +
                    "ORDER BY cantidad_usuarios DESC";

        try (Connection conn = this.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                UsuariosPorRolDto dto = new UsuariosPorRolDto();
                dto.setNombreRol(rs.getString("nombre_rol"));
                dto.setCantidadUsuarios(rs.getInt("cantidad_usuarios"));
                dto.setUsuariosActivos(rs.getInt("usuarios_activos"));
                dto.setUsuariosInactivos(rs.getInt("usuarios_inactivos"));
                listaReporte.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaReporte;
    }

    /**
     * Obtiene estadísticas de productos agrupados por categoría.
     * 
     * @return ArrayList<ProductosPorCategoriaDto> lista de estadísticas por categoría
     */
    public ArrayList<ProductosPorCategoriaDto> obtenerProductosPorCategoria() {
        ArrayList<ProductosPorCategoriaDto> listaReporte = new ArrayList<>();
        String sql = "SELECT c.nombre AS nombre_categoria, " +
                    "COUNT(p.id_producto) AS cantidad_productos, " +
                    "AVG(p.precio_actual) AS precio_promedio, " +
                    "MIN(p.precio_actual) AS precio_minimo, " +
                    "MAX(p.precio_actual) AS precio_maximo, " +
                    "SUM(p.stock) AS stock_total, " +
                    "SUM(CASE WHEN p.stock <= p.stock_minimo THEN 1 ELSE 0 END) AS productos_con_stock_bajo " +
                    "FROM categorias c " +
                    "LEFT JOIN productos p ON c.id_categoria = p.categoria_id " +
                    "GROUP BY c.id_categoria, c.nombre " +
                    "ORDER BY cantidad_productos DESC";

        try (Connection conn = this.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                ProductosPorCategoriaDto dto = new ProductosPorCategoriaDto();
                dto.setNombreCategoria(rs.getString("nombre_categoria"));
                dto.setCantidadProductos(rs.getInt("cantidad_productos"));
                dto.setPrecioPromedio(rs.getBigDecimal("precio_promedio"));
                dto.setPrecioMinimo(rs.getBigDecimal("precio_minimo"));
                dto.setPrecioMaximo(rs.getBigDecimal("precio_maximo"));
                dto.setStockTotal(rs.getInt("stock_total"));
                dto.setProductosConStockBajo(rs.getInt("productos_con_stock_bajo"));
                listaReporte.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaReporte;
    }

    /**
     * Obtiene estadísticas de movimientos de inventario por fecha.
     * 
     * @param fechaInicio fecha de inicio del período
     * @param fechaFin fecha de fin del período
     * @return ArrayList<MovimientosInventarioDto> lista de estadísticas por período
     */
    public ArrayList<MovimientosInventarioDto> obtenerMovimientosPorPeriodo(LocalDate fechaInicio, LocalDate fechaFin) {
        ArrayList<MovimientosInventarioDto> listaReporte = new ArrayList<>();
        String sql = "SELECT DATE(m.fecha_movimiento) AS fecha, " +
                    "m.tipo_movimiento, " +
                    "COUNT(m.id_movimiento) AS cantidad_movimientos, " +
                    "COUNT(DISTINCT m.producto_id) AS cantidad_productos, " +
                    "(SELECT p.nombre FROM productos p " +
                    " INNER JOIN movimientos m2 ON p.id_producto = m2.producto_id " +
                    " WHERE DATE(m2.fecha_movimiento) = DATE(m.fecha_movimiento) " +
                    " GROUP BY p.id_producto " +
                    " ORDER BY COUNT(m2.id_movimiento) DESC " +
                    " LIMIT 1) AS producto_mas_movido, " +
                    "(SELECT u.nombre FROM ubicaciones u " +
                    " INNER JOIN movimientos m3 ON u.id_ubicacion = m3.ubicacion_id " +
                    " WHERE DATE(m3.fecha_movimiento) = DATE(m.fecha_movimiento) " +
                    " GROUP BY u.id_ubicacion " +
                    " ORDER BY COUNT(m3.id_movimiento) DESC " +
                    " LIMIT 1) AS ubicacion_mas_activa " +
                    "FROM movimientos m " +
                    "WHERE DATE(m.fecha_movimiento) BETWEEN ? AND ? " +
                    "GROUP BY DATE(m.fecha_movimiento), m.tipo_movimiento " +
                    "ORDER BY fecha DESC";

        try (Connection conn = this.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setDate(1, Date.valueOf(fechaInicio));
            pstmt.setDate(2, Date.valueOf(fechaFin));
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    MovimientosInventarioDto dto = new MovimientosInventarioDto();
                    dto.setFecha(rs.getDate("fecha").toLocalDate());
                    dto.setTipoMovimiento(rs.getString("tipo_movimiento"));
                    dto.setCantidadMovimientos(rs.getInt("cantidad_movimientos"));
                    dto.setCantidadProductos(rs.getInt("cantidad_productos"));
                    dto.setProductoMasMovido(rs.getString("producto_mas_movido"));
                    dto.setUbicacionMasActiva(rs.getString("ubicacion_mas_activa"));
                    listaReporte.add(dto);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaReporte;
    }

    /**
     * Obtiene estadísticas generales del sistema.
     * 
     * @return ArrayList<String> lista con estadísticas clave
     */
    public ArrayList<String> obtenerEstadisticasGenerales() {
        ArrayList<String> estadisticas = new ArrayList<>();
        
        // Consultas individuales para estadísticas clave
        String[] consultas = {
            "SELECT COUNT(*) FROM usuarios WHERE activo = 1",
            "SELECT COUNT(*) FROM productos WHERE stock > 0",
            "SELECT COUNT(*) FROM productos WHERE stock <= stock_minimo",
            "SELECT COUNT(*) FROM movimientos WHERE DATE(fecha_movimiento) = CURDATE()"
        };
        
        String[] etiquetas = {
            "Usuarios Activos",
            "Productos con Stock",
            "Productos con Stock Bajo",
            "Movimientos Hoy"
        };
        
        try (Connection conn = this.getConnection()) {
            for (int i = 0; i < consultas.length; i++) {
                try (PreparedStatement pstmt = conn.prepareStatement(consultas[i]);
                     ResultSet rs = pstmt.executeQuery()) {
                    
                    if (rs.next()) {
                        estadisticas.add(etiquetas[i] + ": " + rs.getInt(1));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return estadisticas;
    }
}