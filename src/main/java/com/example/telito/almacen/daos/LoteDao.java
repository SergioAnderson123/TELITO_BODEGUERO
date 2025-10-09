package com.example.inventario.daos;

import com.example.inventario.beans.Lote;
import java.sql.*;
import java.util.ArrayList;

public class LoteDao {

    private String url = "jdbc:mysql://localhost:3306/telito4";
    private String user = "root";
    private String pass = "chupamela2005";

    public ArrayList<Lote> listarLotes() {
        ArrayList<Lote> lista = new ArrayList<>(); // 1. Prepara una lista vacía
        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
        }catch(ClassNotFoundException e){
            throw new RuntimeException(e);
        }

        // 2. La consulta SQL que une las 3 tablas
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, p.nombre AS nombre_producto, u.nombre AS nombre_ubicacion " +
                " FROM lotes l " + " INNER JOIN productos p ON (l.producto_id = p.id_producto) " +
                " INNER JOIN ubicaciones u ON (l.ubicacion_id = u.id_ubicacion) ";

        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
        }catch(ClassNotFoundException e){
            throw new RuntimeException(e);
        }

        // 3. Bloque try-with-resources para la conexión
        try (
             Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            // 4. Bucle para procesar cada fila del resultado
            while (rs.next()) {

                Lote lote = new Lote();
                lote.setIdLote(rs.getInt("id_lote"));
                lote.setCodigoLote(rs.getString("codigo_lote"));
                lote.setStockActual(rs.getInt("stock_actual"));
                lote.setFechaVencimiento(rs.getDate("fecha_vencimiento"));
                lote.setNombreProducto(rs.getString("nombre_producto"));
                lote.setNombreUbicacion(rs.getString("nombre_ubicacion"));
                lista.add(lote);

            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al listar los lotessss", e);
        }
        return lista; // 7. Devuelve la lista completa
    }

    public void actualizarStock(int idLote, int nuevoStock) {
        String sql = "UPDATE lotes SET stock_actual = ? WHERE id_lote = ?";

        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
        }catch(ClassNotFoundException e){
            throw new RuntimeException(e);
        }

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
        Lote lote = null; // 1. Prepara un objeto 'lote' vacío (nulo)

        // 2. La consulta SQL es casi igual a la de listar, pero con un WHERE
        String sql = " SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, " +
                " p.nombre AS nombre_producto, u.nombre AS nombre_ubicacion " +
                " FROM lotes l " +
                " INNER JOIN productos p ON (l.producto_id = p.id_producto) " +
                " INNER JOIN ubicaciones u ON (l.ubicacion_id = u.id_ubicacion) " +
                " WHERE l.id_lote = ? "; // <-- La parte clave: buscar solo por un ID

        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
        }catch(ClassNotFoundException e){
            throw new RuntimeException(e);
        }

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // 3. Asigna el ID recibido al parámetro de la consulta
            pstmt.setInt(1, idLote);

            // 4. Ejecuta la consulta
            try (ResultSet rs = pstmt.executeQuery()) {

                // 5. Verifica si se encontró un resultado
                if (rs.next()) {
                    lote = new Lote(); // Crea el objeto solo si se encontró la fila

                    // 6. Llena el objeto con los datos encontrados
                    lote.setIdLote(rs.getInt("l.id_lote"));
                    lote.setCodigoLote(rs.getString("l.codigo_lote"));
                    lote.setStockActual(rs.getInt("l.stock_actual"));
                    lote.setFechaVencimiento(rs.getDate("l.fecha_vencimiento"));
                    lote.setNombreProducto(rs.getString("nombre_producto"));
                    lote.setNombreUbicacion(rs.getString("nombre_ubicacion"));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al buscar el lote", e);
        }

        return lote; // 7. Devuelve el objeto 'lote' (o null si no se encontró)
    }

    public int buscarLoteParaDespacho(int idProducto) {
        int idLote = 0; // Se devuelve 0 si no se encuentra un lote válido

        String sql = "SELECT id_lote FROM lotes " +
                "WHERE producto_id = ? AND stock_actual > 0 ";
        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
        }catch(ClassNotFoundException e){
            throw new RuntimeException(e);
        }

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    idLote = rs.getInt("id_lote");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al buscar lote para despacho", e);
        }
        return idLote;
    }

    public int crearLote(Lote lote) {
        String sql = "INSERT INTO lotes (codigo_lote, stock_actual, fecha_vencimiento, producto_id, ubicacion_id) " +
                "VALUES (?, ?, ?, ?, ?)";

        int generatedId = 0;
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, lote.getCodigoLote());
            pstmt.setInt(2, lote.getStockActual());
            pstmt.setDate(3, lote.getFechaVencimiento());
            pstmt.setInt(4, lote.getProductoId());
            pstmt.setInt(5, lote.getUbicacionId());
            pstmt.executeUpdate();

            // Obtener el ID autogenerado del nuevo lote
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
    public ArrayList<Lote> buscarLotesPorProducto(int idProducto) {
        // 1. Prepara una lista vacía para guardar los resultados
        ArrayList<Lote> listaLotes = new ArrayList<>();

        // 2. La consulta SQL
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, u.nombre AS nombre_ubicacion " +
                "FROM lotes l " +
                "INNER JOIN ubicaciones u ON (l.ubicacion_id = u.id_ubicacion) " +
                "WHERE l.producto_id = ? AND l.stock_actual > 0 " +
                "ORDER BY l.fecha_vencimiento ASC";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // 3. Asigna el ID del producto a la consulta
            pstmt.setInt(1, idProducto);

            // 4. Ejecuta la consulta
            try (ResultSet rs = pstmt.executeQuery()) {
                // 5. Recorre todos los lotes encontrados
                while (rs.next()) {
                    Lote lote = new Lote();
                    lote.setIdLote(rs.getInt("id_lote"));
                    lote.setCodigoLote(rs.getString("codigo_lote"));
                    lote.setStockActual(rs.getInt("stock_actual"));
                    lote.setFechaVencimiento(rs.getDate("fecha_vencimiento"));
                    lote.setNombreUbicacion(rs.getString("nombre_ubicacion"));
                    listaLotes.add(lote); // 6. Añade el lote a la lista
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al buscar lotes por producto", e);
        }

        return listaLotes; // 7. Devuelve la lista (puede estar vacía)
    }
}