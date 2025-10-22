package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.AlertaConfig;
import com.example.telito.administrador.beans.Categoria;
import com.example.telito.administrador.beans.Rol;

import java.sql.*;
import java.util.ArrayList;

public class AlertaDAO {

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

    // Cuenta las reglas de alerta que están activas para el contador del menú.
    public int contarReglasDeAlertaActivas() {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM alertas_configuracion WHERE activo = 1";
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    // Carga la lista de alertas para la tabla de gestión.
    public ArrayList<AlertaConfig> listarAlertas() {
        ArrayList<AlertaConfig> listaAlertas = new ArrayList<>();
        String sql = "SELECT a.*, c.nombre AS nombre_categoria " +
                "FROM alertas_configuracion a " +
                "LEFT JOIN categorias c ON a.categoria_id = c.id_categoria " +
                "ORDER BY a.id_alerta_config";

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                listaAlertas.add(mapResultSetToAlertaConfig(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaAlertas;
    }

    // Obtiene una alerta específica para poder editarla.
    public AlertaConfig obtenerAlertaPorId(int id) {
        AlertaConfig alerta = null;
        String sql = "SELECT a.*, c.nombre AS nombre_categoria " +
                "FROM alertas_configuracion a " +
                "LEFT JOIN categorias c ON a.categoria_id = c.id_categoria " +
                "WHERE a.id_alerta_config = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    alerta = mapResultSetToAlertaConfig(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return alerta;
    }

    // Guarda una nueva regla de alerta en la base de datos.
    public void crearAlerta(AlertaConfig alerta) {
        String sql = "INSERT INTO alertas_configuracion (nombre, tipo_alerta, umbral_dias, categoria_id, rol_a_notificar, mensaje_personalizado, activo) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            setAlertaParams(pstmt, alerta);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Actualiza una regla de alerta que ya existe.
    public void actualizarAlerta(AlertaConfig alerta) {
        String sql = "UPDATE alertas_configuracion SET nombre = ?, tipo_alerta = ?, umbral_dias = ?, " +
                "categoria_id = ?, rol_a_notificar = ?, mensaje_personalizado = ?, activo = ? WHERE id_alerta_config = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            setAlertaParams(pstmt, alerta);
            pstmt.setInt(8, alerta.getIdAlertaConfig());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Borrado lógico, solo cambia el estado a inactivo.
    public void deshabilitarAlerta(int id) {
        String sql = "UPDATE alertas_configuracion SET activo = 0 WHERE id_alerta_config = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Este método es más complejo, revisa los productos/lotes que de verdad están en alerta (stock bajo, etc).
    public int contarAlertasAbiertas() {
        int totalAlertas = 0;
        String sqlReglas = "SELECT * FROM alertas_configuracion WHERE activo = 1";

        try (Connection conn = getConnection();
             Statement stmtReglas = conn.createStatement();
             ResultSet rsReglas = stmtReglas.executeQuery(sqlReglas)) {

            while (rsReglas.next()) {
                String tipoAlerta = rsReglas.getString("tipo_alerta");
                Integer categoriaId = rsReglas.getObject("categoria_id", Integer.class);
                String sqlConteo = "";

                if ("STOCK_MINIMO".equals(tipoAlerta)) {
                    sqlConteo = "SELECT COUNT(*) FROM productos p " +
                            "LEFT JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id " +
                            "LEFT JOIN lotes l ON p.id_producto = l.producto_id " +
                            "WHERE p.activo = 1 AND smc.activo = 1 " +
                            "AND COALESCE(SUM(l.stock_actual), 0) <= smc.stock_minimo";
                    if (categoriaId != null) {
                        sqlConteo += " AND p.categoria_id = " + categoriaId;
                    }
                    sqlConteo += " GROUP BY p.id_producto";
                } else if ("STOCK_CRITICO".equals(tipoAlerta)) {
                    sqlConteo = "SELECT COUNT(*) FROM productos p " +
                            "LEFT JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id " +
                            "LEFT JOIN lotes l ON p.id_producto = l.producto_id " +
                            "WHERE p.activo = 1 AND smc.activo = 1 " +
                            "AND COALESCE(SUM(l.stock_actual), 0) <= smc.stock_critico";
                    if (categoriaId != null) {
                        sqlConteo += " AND p.categoria_id = " + categoriaId;
                    }
                    sqlConteo += " GROUP BY p.id_producto";
                } else if ("VENCIMIENTO".equals(tipoAlerta)) {
                    Integer umbralDias = rsReglas.getObject("umbral_dias", Integer.class);
                    if (umbralDias != null) {
                        sqlConteo = "SELECT COUNT(*) FROM lotes l ";
                        if (categoriaId != null) {
                            sqlConteo += "JOIN productos p ON l.producto_id = p.id_producto ";
                        }
                        sqlConteo += "WHERE DATEDIFF(l.fecha_vencimiento, CURDATE()) BETWEEN 0 AND " + umbralDias;
                        if (categoriaId != null) {
                            sqlConteo += " AND p.categoria_id = " + categoriaId;
                        }
                    }
                }

                if (!sqlConteo.isEmpty()) {
                    try (Statement stmtConteo = conn.createStatement();
                         ResultSet rsConteo = stmtConteo.executeQuery(sqlConteo)) {
                        if (rsConteo.next()) {
                            totalAlertas += rsConteo.getInt(1);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return totalAlertas;
    }

    // Retorna mensajes de alertas calculadas dinámicamente para el rol indicado
    public ArrayList<String> listarAlertasParaRol(String rolNombre) {
        ArrayList<String> mensajes = new ArrayList<>();
        String sqlReglas = "SELECT * FROM alertas_configuracion WHERE activo = 1 AND rol_a_notificar = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sqlReglas)) {
            pstmt.setString(1, rolNombre.toUpperCase());
            try (ResultSet rsReglas = pstmt.executeQuery()) {
                while (rsReglas.next()) {
                    String tipoAlerta = rsReglas.getString("tipo_alerta");
                    Integer categoriaId = rsReglas.getObject("categoria_id", Integer.class);
                    Integer umbralDias = rsReglas.getObject("umbral_dias", Integer.class);
                    String plantilla = rsReglas.getString("mensaje_personalizado");

                    if (("VENCIMIENTO".equals(tipoAlerta) || "CADUCIDAD_PROXIMA".equals(tipoAlerta)) && umbralDias != null) {
                        String sql = "SELECT l.codigo_lote, p.nombre, DATEDIFF(l.fecha_vencimiento, CURDATE()) AS dias " +
                                     "FROM lotes l JOIN productos p ON l.producto_id = p.id_producto " +
                                     "WHERE DATEDIFF(l.fecha_vencimiento, CURDATE()) BETWEEN 0 AND ?" +
                                     (categoriaId != null ? " AND p.categoria_id = ?" : "") + " ORDER BY dias ASC LIMIT 10";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            ps.setInt(1, umbralDias);
                            if (categoriaId != null) ps.setInt(2, categoriaId);
                            try (ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    String lote = rs.getString("codigo_lote");
                                    String prod = rs.getString("nombre");
                                    int dias = rs.getInt("dias");
                                    String msg;
                                    if (plantilla != null && !plantilla.isEmpty()) {
                                        msg = plantilla
                                                .replace("{lote}", lote != null ? lote : "")
                                                .replace("{producto}", prod != null ? prod : "")
                                                .replace("{dias_restantes}", String.valueOf(dias));
                                    } else {
                                        msg = "Lote " + lote + " (" + prod + ") vence en " + dias + " días";
                                    }
                                    mensajes.add(msg);
                                }
                            }
                        }
                    } else if ("CADUCIDAD_VENCIDA".equals(tipoAlerta)) {
                        String sql = "SELECT l.codigo_lote, p.nombre, DATEDIFF(l.fecha_vencimiento, CURDATE()) AS dias " +
                                     "FROM lotes l JOIN productos p ON l.producto_id = p.id_producto " +
                                     (categoriaId != null ? "WHERE p.categoria_id = ? AND " : "WHERE ") +
                                     "DATEDIFF(l.fecha_vencimiento, CURDATE()) < 0 ORDER BY dias ASC LIMIT 10";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            if (categoriaId != null) ps.setInt(1, categoriaId);
                            try (ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    String lote = rs.getString("codigo_lote");
                                    String prod = rs.getString("nombre");
                                    int dias = Math.abs(rs.getInt("dias"));
                                    String msg;
                                    if (plantilla != null && !plantilla.isEmpty()) {
                                        msg = plantilla
                                                .replace("{lote}", lote != null ? lote : "")
                                                .replace("{producto}", prod != null ? prod : "")
                                                .replace("{dias_restantes}", String.valueOf(-dias));
                                    } else {
                                        msg = "Lote " + lote + " (" + prod + ") vencido hace " + dias + " días";
                                    }
                                    mensajes.add(msg);
                                }
                            }
                        }
                    } else if ("STOCK_MINIMO".equals(tipoAlerta)) {
                        String sql = "SELECT p.nombre, COALESCE(SUM(l.stock_actual),0) AS stock, smc.stock_minimo " +
                                     "FROM productos p " +
                                     "JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id AND smc.activo = 1 " +
                                     "LEFT JOIN lotes l ON p.id_producto = l.producto_id " +
                                     (categoriaId != null ? "WHERE p.categoria_id = ? " : "") +
                                     "GROUP BY p.id_producto, smc.stock_minimo HAVING stock <= smc.stock_minimo LIMIT 20";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            if (categoriaId != null) ps.setInt(1, categoriaId);
                            try (ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    String prod = rs.getString("nombre");
                                    int stock = rs.getInt("stock");
                                    int umbral = rs.getInt("stock_minimo");
                                    String msg;
                                    if (plantilla != null && !plantilla.isEmpty()) {
                                        msg = plantilla
                                                .replace("{producto}", prod != null ? prod : "")
                                                .replace("{stock_actual}", String.valueOf(stock))
                                                .replace("{umbral}", String.valueOf(umbral));
                                    } else {
                                        msg = "Stock mínimo: Producto " + prod + " con " + stock + " unidades (mínimo " + umbral + ")";
                                    }
                                    mensajes.add(msg);
                                }
                            }
                        }
                    } else if ("STOCK_CRITICO".equals(tipoAlerta)) {
                        String sql = "SELECT p.nombre, COALESCE(SUM(l.stock_actual),0) AS stock, smc.stock_critico " +
                                     "FROM productos p " +
                                     "JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id AND smc.activo = 1 " +
                                     "LEFT JOIN lotes l ON p.id_producto = l.producto_id " +
                                     (categoriaId != null ? "WHERE p.categoria_id = ? " : "") +
                                     "GROUP BY p.id_producto, smc.stock_critico HAVING stock <= smc.stock_critico LIMIT 20";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            if (categoriaId != null) ps.setInt(1, categoriaId);
                            try (ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    String prod = rs.getString("nombre");
                                    int stock = rs.getInt("stock");
                                    int umbral = rs.getInt("stock_critico");
                                    String msg;
                                    if (plantilla != null && !plantilla.isEmpty()) {
                                        msg = plantilla
                                                .replace("{producto}", prod != null ? prod : "")
                                                .replace("{stock_actual}", String.valueOf(stock))
                                                .replace("{umbral}", String.valueOf(umbral));
                                    } else {
                                        msg = "Stock crítico: Producto " + prod + " con " + stock + " unidades (crítico " + umbral + ")";
                                    }
                                    mensajes.add(msg);
                                }
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return mensajes;
    }

    // Mapea el resultado de la consulta a un objeto AlertaConfig.
    private AlertaConfig mapResultSetToAlertaConfig(ResultSet rs) throws SQLException {
        AlertaConfig alerta = new AlertaConfig();
        alerta.setIdAlertaConfig(rs.getInt("id_alerta_config"));
        alerta.setNombre(rs.getString("nombre"));
        alerta.setTipoAlerta(rs.getString("tipo_alerta"));
        alerta.setUmbralDias(rs.getObject("umbral_dias", Integer.class));
        alerta.setActivo(rs.getBoolean("activo"));

        if (rs.getObject("categoria_id") != null) {
            Categoria categoria = new Categoria();
            categoria.setIdCategoria(rs.getInt("categoria_id"));
            categoria.setNombre(rs.getString("nombre_categoria"));
            alerta.setCategoria(categoria);
        }

        // Para la nueva estructura, rol_a_notificar es un ENUM string
        String rolString = rs.getString("rol_a_notificar");
        if (rolString != null) {
            Rol rol = new Rol();
            rol.setNombre(rolString);
            alerta.setRolANotificar(rol);
        }

        return alerta;
    }

    // Asigna los parámetros al PreparedStatement para crear/actualizar.
    private void setAlertaParams(PreparedStatement pstmt, AlertaConfig alerta) throws SQLException {
        pstmt.setString(1, alerta.getNombre());
        pstmt.setString(2, alerta.getTipoAlerta());

        if (alerta.getUmbralDias() != null) {
            pstmt.setInt(3, alerta.getUmbralDias());
        } else {
            pstmt.setNull(3, Types.INTEGER);
        }

        if (alerta.getCategoria() != null && alerta.getCategoria().getIdCategoria() > 0) {
            pstmt.setInt(4, alerta.getCategoria().getIdCategoria());
        } else {
            pstmt.setNull(4, Types.INTEGER);
        }

        pstmt.setString(5, alerta.getRolANotificar().getNombre());
        pstmt.setString(6, alerta.getMensajePersonalizado());
        pstmt.setBoolean(7, alerta.isActivo());
    }
}