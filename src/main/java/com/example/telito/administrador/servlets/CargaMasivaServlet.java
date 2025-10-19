package com.example.telito.administrador.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.InputStream;
import java.sql.*;

@WebServlet(name = "CargaMasivaServlet", value = "/CargaMasivaServlet")
@MultipartConfig
public class CargaMasivaServlet extends HttpServlet {

    private String user = "root";
    private String pass = "root";
    private String url = "jdbc:mysql://localhost:3306/telito_bodeguero";

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        return DriverManager.getConnection(url, user, pass);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Part filePart = request.getPart("archivo");
        if (filePart == null || filePart.getSize() == 0) {
            request.getSession().setAttribute("errorMsg", "Seleccione un archivo .xlsx");
            response.sendRedirect(request.getContextPath() + "/administrador/carga-masiva.jsp");
            return;
        }

        int insertados = 0, actualizados = 0, lotes = 0;

        try (InputStream inputStream = filePart.getInputStream();
             Workbook workbook = new XSSFWorkbook(inputStream);
             Connection conn = getConnection()) {

            Sheet sheet = workbook.getSheetAt(0);
            if (sheet == null) throw new IllegalArgumentException("Hoja 0 no encontrada");

            // Encabezados esperados
            Row header = sheet.getRow(0);
            if (header == null) throw new IllegalArgumentException("Encabezados no encontrados");

            conn.setAutoCommit(false);

            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                String sku = getString(row, 0);
                String nombre = getString(row, 1);
                String descripcion = getString(row, 2);
                Double precio = getDouble(row, 3);
                String categoriaNombre = getString(row, 4);
                Integer unidadesPorPaquete = getInteger(row, 5);
                String loteCodigo = getString(row, 6);
                String ubicacionNombre = getString(row, 7);
                Integer stock = getInteger(row, 8);
                java.sql.Date fechaVenc = getDate(row, 9);

                if (sku == null || nombre == null || precio == null || categoriaNombre == null) {
                    continue; // fila inválida mínima
                }

                int categoriaId = ensureCategoria(conn, categoriaNombre);
                int productorId = ensureProductorGenerico(conn); // productor genérico si no aplica

                // Upsert producto por SKU
                Integer productoId = getProductoIdPorSku(conn, sku);
                if (productoId == null) {
                    productoId = insertarProducto(conn, sku, nombre, descripcion, precio, unidadesPorPaquete, productorId, categoriaId);
                    insertados++;
                } else {
                    actualizarProducto(conn, productoId, nombre, descripcion, precio, unidadesPorPaquete, categoriaId);
                    actualizados++;
                }

                // Lote opcional
                if (loteCodigo != null && ubicacionNombre != null && stock != null) {
                    int ubicacionId = ensureUbicacion(conn, ubicacionNombre);
                    upsertLote(conn, loteCodigo, productoId, ubicacionId, stock, fechaVenc);
                    lotes++;
                }
            }

            conn.commit();
            request.getSession().setAttribute("successMsg", String.format("Procesado OK. Productos: %d nuevos, %d actualizados. Lotes: %d.", insertados, actualizados, lotes));
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Error procesando Excel: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/administrador/carga-masiva.jsp");
    }

    private static String getString(Row row, int idx){ Cell c=row.getCell(idx); return c==null?null:c.getCellType()==CellType.NUMERIC?String.valueOf((long)c.getNumericCellValue()):c.getStringCellValue().trim(); }
    private static Double getDouble(Row row, int idx){ Cell c=row.getCell(idx); try{ return c==null?null:c.getNumericCellValue(); }catch(Exception ex){ try{ return Double.parseDouble(c.getStringCellValue()); }catch(Exception e){ return null; } } }
    private static Integer getInteger(Row row, int idx){ Double d=getDouble(row, idx); return d==null?null:d.intValue(); }
    private static java.sql.Date getDate(Row row, int idx){
        try{
            Cell c=row.getCell(idx); if(c==null) return null;
            if (c.getCellType()==CellType.NUMERIC && DateUtil.isCellDateFormatted(c)) {
                return new java.sql.Date(c.getDateCellValue().getTime());
            } else {
                String s=c.getStringCellValue();
                return java.sql.Date.valueOf(s);
            }
        }catch(Exception e){ return null; }
    }

    private Integer getProductoIdPorSku(Connection conn, String sku) throws SQLException {
        String sql = "SELECT id_producto FROM productos WHERE codigo_sku = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)){
            ps.setString(1, sku);
            try(ResultSet rs = ps.executeQuery()){
                if (rs.next()) return rs.getInt(1);
            }
        }
        return null;
    }

    private int insertarProducto(Connection conn, String sku, String nombre, String descripcion, Double precio, Integer upp, int productorId, int categoriaId) throws SQLException {
        String sql = "INSERT INTO productos (codigo_sku, nombre, descripcion, precio_actual, unidades_por_paquete, productor_id, categoria_id) VALUES (?,?,?,?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)){
            ps.setString(1, sku);
            ps.setString(2, nombre);
            ps.setString(3, descripcion);
            ps.setBigDecimal(4, java.math.BigDecimal.valueOf(precio));
            ps.setInt(5, upp!=null?upp:1);
            ps.setInt(6, productorId);
            ps.setInt(7, categoriaId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()){
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("No se pudo insertar producto");
    }

    private void actualizarProducto(Connection conn, int productoId, String nombre, String descripcion, Double precio, Integer upp, int categoriaId) throws SQLException {
        String sql = "UPDATE productos SET nombre=?, descripcion=?, precio_actual=?, unidades_por_paquete=?, categoria_id=? WHERE id_producto=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)){
            ps.setString(1, nombre);
            ps.setString(2, descripcion);
            ps.setBigDecimal(3, java.math.BigDecimal.valueOf(precio));
            ps.setInt(4, upp!=null?upp:1);
            ps.setInt(5, categoriaId);
            ps.setInt(6, productoId);
            ps.executeUpdate();
        }
    }

    private void upsertLote(Connection conn, String codigoLote, int productoId, int ubicacionId, int stock, java.sql.Date fechaVenc) throws SQLException {
        Integer loteId = getLoteIdPorCodigo(conn, codigoLote);
        if (loteId == null) {
            String ins = "INSERT INTO lotes (codigo_lote, producto_id, ubicacion_id, stock_actual, fecha_vencimiento, distrito_id) VALUES (?,?,?,?,?, (SELECT idDistrito FROM distritos LIMIT 1))";
            try (PreparedStatement ps = conn.prepareStatement(ins)){
                ps.setString(1, codigoLote);
                ps.setInt(2, productoId);
                ps.setInt(3, ubicacionId);
                ps.setInt(4, stock);
                if (fechaVenc != null) ps.setDate(5, fechaVenc); else ps.setNull(5, Types.DATE);
                ps.executeUpdate();
            }
        } else {
            String upd = "UPDATE lotes SET stock_actual=?, fecha_vencimiento=?, ubicacion_id=? WHERE id_lote=?";
            try (PreparedStatement ps = conn.prepareStatement(upd)){
                ps.setInt(1, stock);
                if (fechaVenc != null) ps.setDate(2, fechaVenc); else ps.setNull(2, Types.DATE);
                ps.setInt(3, ubicacionId);
                ps.setInt(4, loteId);
                ps.executeUpdate();
            }
        }
    }

    private Integer getLoteIdPorCodigo(Connection conn, String codigoLote) throws SQLException {
        String sql = "SELECT id_lote FROM lotes WHERE codigo_lote = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)){
            ps.setString(1, codigoLote);
            try (ResultSet rs = ps.executeQuery()){
                if (rs.next()) return rs.getInt(1);
            }
        }
        return null;
    }

    private int ensureCategoria(Connection conn, String nombre) throws SQLException {
        String sel = "SELECT id_categoria FROM categorias WHERE nombre = ?";
        try (PreparedStatement ps = conn.prepareStatement(sel)){
            ps.setString(1, nombre);
            try (ResultSet rs = ps.executeQuery()){
                if (rs.next()) return rs.getInt(1);
            }
        }
        String ins = "INSERT INTO categorias (nombre) VALUES (?)";
        try (PreparedStatement ps = conn.prepareStatement(ins, Statement.RETURN_GENERATED_KEYS)){
            ps.setString(1, nombre);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()){
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("No se pudo asegurar categoria");
    }

    private int ensureUbicacion(Connection conn, String nombre) throws SQLException {
        String sel = "SELECT id_ubicacion FROM ubicaciones WHERE nombre = ?";
        try (PreparedStatement ps = conn.prepareStatement(sel)){
            ps.setString(1, nombre);
            try (ResultSet rs = ps.executeQuery()){
                if (rs.next()) return rs.getInt(1);
            }
        }
        String ins = "INSERT INTO ubicaciones (nombre) VALUES (?)";
        try (PreparedStatement ps = conn.prepareStatement(ins, Statement.RETURN_GENERATED_KEYS)){
            ps.setString(1, nombre);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()){
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("No se pudo asegurar ubicacion");
    }

    private int ensureProductorGenerico(Connection conn) throws SQLException {
        // Garantiza un productor genérico para asociar productos importados
        String correo = "productor@telito.com";
        String sel = "SELECT id_usuario FROM usuarios WHERE email = ?";
        try (PreparedStatement ps = conn.prepareStatement(sel)){
            ps.setString(1, correo);
            try (ResultSet rs = ps.executeQuery()){
                if (rs.next()) return rs.getInt(1);
            }
        }
        // Crear si no existe, con rol Productor
        Integer rolProductorId = getRolId(conn, "Productor");
        if (rolProductorId == null) throw new SQLException("Rol 'Productor' no existe");
        String ins = "INSERT INTO usuarios (nombres, apellidos, email, password, activo, rol_id) VALUES ('Productor','Genérico',?, '123456', 1, ?)";
        try (PreparedStatement ps = conn.prepareStatement(ins, Statement.RETURN_GENERATED_KEYS)){
            ps.setString(1, correo);
            ps.setInt(2, rolProductorId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()){
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("No se pudo asegurar productor genérico");
    }

    private Integer getRolId(Connection conn, String nombre) throws SQLException {
        String sql = "SELECT id_rol FROM roles WHERE nombre = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)){
            ps.setString(1, nombre);
            try (ResultSet rs = ps.executeQuery()){
                if (rs.next()) return rs.getInt(1);
            }
        }
        return null;
    }
}


