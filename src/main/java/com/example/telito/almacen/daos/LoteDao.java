package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.Lote;
import java.sql.*;
import java.util.ArrayList;

public class LoteDao {

    private final String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
    private final String user = "root";
    private final String pass = "root";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Error al cargar el driver de MySQL", e);
        }
    }

    /**
     * MÉTODO MODIFICADO: Renombrado y filtrado.
     * Lista únicamente los lotes que ya han sido marcados como "Registrado" en el almacén.
     */
    public ArrayList<Lote> listarLotesRegistrados(int pagina) {
        ArrayList<Lote> lista = new ArrayList<>();
        int registrosPorPagina = 10;
        int offset = (pagina - 1) * registrosPorPagina;

        // SE AÑADE LA CONDICIÓN WHERE para filtrar por el estado
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, l.estado, " +
                "p.nombre AS nombre_producto, u.nombre AS nombre_ubicacion " +
                "FROM lotes l " +
                "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                "INNER JOIN ubicaciones u ON l.ubicacion_id = u.id_ubicacion " +
                "WHERE l.estado = 'Registrado' " + // <-- FILTRO AÑADIDO
                "LIMIT ? OFFSET ?";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, registrosPorPagina);
            pstmt.setInt(2, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Lote lote = new Lote();
                    lote.setIdLote(rs.getInt("id_lote"));
                    lote.setCodigoLote(rs.getString("codigo_lote"));
                    lote.setStockActual(rs.getInt("stock_actual"));
                    lote.setFechaVencimiento(rs.getDate("fecha_vencimiento"));
                    lote.setEstado(rs.getString("estado"));
                    lote.setNombreProducto(rs.getString("nombre_producto"));
                    lote.setNombreUbicacion(rs.getString("nombre_ubicacion"));
                    lista.add(lote);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al listar los lotes registrados", e);
        }
        return lista;
    }

    /**
     * MÉTODO MODIFICADO: Renombrado y filtrado.
     * Cuenta el total de lotes que están marcados como "Registrado".
     */
    public int contarTotalLotesRegistrados() {
        String sql = "SELECT COUNT(*) FROM lotes WHERE estado = 'Registrado'";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al contar los lotes registrados", e);
        }
        return 0;
    }

    /**
     * NUEVO MÉTODO
     * Actualiza el estado de un lote, típicamente de 'No Registrado' a 'Registrado'.
     */
    public void actualizarEstado(int idLote, String nuevoEstado) {
        String sql = "UPDATE lotes SET estado = ? WHERE id_lote = ?";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nuevoEstado);
            pstmt.setInt(2, idLote);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Error al actualizar el estado del lote", e);
        }
    }

    /**
     * MÉTODO MODIFICADO
     * Busca los lotes disponibles para un producto, asegurándose de que estén registrados.
     */
    public ArrayList<Lote> buscarLotesPorProducto(int idProducto) {
        ArrayList<Lote> listaLotes = new ArrayList<>();
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, u.nombre AS nombre_ubicacion " +
                "FROM lotes l " +
                "INNER JOIN ubicaciones u ON (l.ubicacion_id = u.id_ubicacion) " +
                "WHERE l.producto_id = ? AND l.stock_actual > 0 AND l.estado = 'Registrado' " + // <-- FILTRO AÑADIDO
                "ORDER BY l.fecha_vencimiento ASC";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idProducto);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Lote lote = new Lote();
                    lote.setIdLote(rs.getInt("id_lote"));
                    lote.setCodigoLote(rs.getString("codigo_lote"));
                    lote.setStockActual(rs.getInt("stock_actual"));
                    lote.setFechaVencimiento(rs.getDate("fecha_vencimiento"));
                    lote.setNombreUbicacion(rs.getString("nombre_ubicacion"));
                    listaLotes.add(lote);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al buscar lotes por producto", e);
        }
        return listaLotes;
    }

    // --- MÉTODOS SIN CAMBIOS ---
    // (Estos métodos siguen siendo necesarios y no requieren modificaciones)

    public void actualizarStock(int idLote, int nuevoStock) {
        String sql = "UPDATE lotes SET stock_actual = ? WHERE id_lote = ?";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, nuevoStock);
            pstmt.setInt(2, idLote);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Error al actualizar el stock", e);
        }
    }

    public Lote buscarLotePorId(int idLote) {
        Lote lote = null;
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, l.estado, " +
                " p.nombre AS nombre_producto, u.nombre AS nombre_ubicacion " +
                " FROM lotes l " +
                " INNER JOIN productos p ON (l.producto_id = p.id_producto) " +
                " INNER JOIN ubicaciones u ON (l.ubicacion_id = u.id_ubicacion) " +
                " WHERE l.id_lote = ?";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idLote);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    lote = new Lote();
                    lote.setIdLote(rs.getInt("id_lote"));
                    lote.setCodigoLote(rs.getString("codigo_lote"));
                    lote.setStockActual(rs.getInt("stock_actual"));
                    lote.setFechaVencimiento(rs.getDate("fecha_vencimiento"));
                    lote.setEstado(rs.getString("estado"));
                    lote.setNombreProducto(rs.getString("nombre_producto"));
                    lote.setNombreUbicacion(rs.getString("nombre_ubicacion"));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al buscar el lote", e);
        }
        return lote;
    }

    public int crearLote(Lote lote) {
        // CORRECCIÓN: Se añade la columna 'estado' a la consulta
        String sql = "INSERT INTO lotes (codigo_lote, stock_actual, fecha_vencimiento, producto_id, ubicacion_id, distrito_id, estado) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        int generatedId = 0;
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, lote.getCodigoLote());
            pstmt.setInt(2, lote.getStockActual());
            pstmt.setDate(3, new java.sql.Date(lote.getFechaVencimiento().getTime()));
            pstmt.setInt(4, lote.getProductoId());
            pstmt.setInt(5, lote.getUbicacionId());
            pstmt.setInt(6, lote.getDistritoId());
            pstmt.setString(7, lote.getEstado()); // <-- SE AÑADE EL ESTADO
            pstmt.executeUpdate();

            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    generatedId = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al crear lote", e);
        }
        return generatedId;
    }
}