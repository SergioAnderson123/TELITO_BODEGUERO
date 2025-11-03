package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.AlertaConfig;
import com.example.telito.administrador.beans.Categoria;
import com.example.telito.administrador.beans.Rol;
import com.example.telito.util.DatabaseConnection;
import com.example.telito.util.EmailUtil;

import java.sql.*;
import java.util.ArrayList;

public class AlertaDAO {
    // Las credenciales ahora están centralizadas en DatabaseConnection

    // Cuenta las reglas de alerta que están activas para el contador del menú.
    public int contarReglasDeAlertaActivas() {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM alertas_configuracion WHERE activo = 1";
        try (Connection conn = DatabaseConnection.getConnection();
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
        return listarAlertas(1, 10);
    }

    public ArrayList<AlertaConfig> listarAlertas(int page, int size) {
        ArrayList<AlertaConfig> listaAlertas = new ArrayList<>();
        String sql = "SELECT a.*, c.nombre AS nombre_categoria " +
                "FROM alertas_configuracion a " +
                "LEFT JOIN categorias c ON a.categoria_id = c.id_categoria " +
                "ORDER BY a.id_alerta_config LIMIT ? OFFSET ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            int limit = Math.max(1, size);
            int offset = Math.max(0, (Math.max(1, page) - 1) * size);
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    listaAlertas.add(mapResultSetToAlertaConfig(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaAlertas;
    }

    public int contarAlertas() {
        String sql = "SELECT COUNT(*) FROM alertas_configuracion";
        int total = 0;
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) total = rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    // Obtiene una alerta específica para poder editarla.
    public AlertaConfig obtenerAlertaPorId(int id) {
        AlertaConfig alerta = null;
        String sql = "SELECT a.*, c.nombre AS nombre_categoria " +
                "FROM alertas_configuracion a " +
                "LEFT JOIN categorias c ON a.categoria_id = c.id_categoria " +
                "WHERE a.id_alerta_config = ?";

        try (Connection conn = DatabaseConnection.getConnection();
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
        try (Connection conn = DatabaseConnection.getConnection();
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
        try (Connection conn = DatabaseConnection.getConnection();
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
        try (Connection conn = DatabaseConnection.getConnection();
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

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmtReglas = conn.createStatement();
             ResultSet rsReglas = stmtReglas.executeQuery(sqlReglas)) {

            while (rsReglas.next()) {
                String tipoAlerta = rsReglas.getString("tipo_alerta");
                Integer categoriaId = rsReglas.getObject("categoria_id", Integer.class);
                String sqlConteo = "";

                if ("STOCK_MINIMO_LOTE".equals(tipoAlerta)) {
                    sqlConteo = "SELECT COUNT(*) FROM lotes l " +
                            "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                            "LEFT JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id " +
                            "WHERE l.estado = 'Registrado' AND p.activo = 1 AND smc.activo = 1 " +
                            "AND FLOOR(l.stock_actual / p.unidades_por_paquete) <= smc.stock_minimo_lote";
                    if (categoriaId != null) {
                        sqlConteo += " AND p.categoria_id = " + categoriaId;
                    }
                } else if ("STOCK_CRITICO_LOTE".equals(tipoAlerta)) {
                    sqlConteo = "SELECT COUNT(*) FROM lotes l " +
                            "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                            "LEFT JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id " +
                            "WHERE l.estado = 'Registrado' AND p.activo = 1 AND smc.activo = 1 " +
                            "AND FLOOR(l.stock_actual / p.unidades_por_paquete) <= smc.stock_critico_lote";
                    if (categoriaId != null) {
                        sqlConteo += " AND p.categoria_id = " + categoriaId;
                    }
                } else if ("STOCK_MINIMO_TOTAL".equals(tipoAlerta)) {
                    sqlConteo = "SELECT COUNT(DISTINCT p.id_producto) FROM productos p " +
                            "INNER JOIN lotes l ON p.id_producto = l.producto_id AND l.estado = 'Registrado' " +
                            "LEFT JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id " +
                            "WHERE p.activo = 1 AND smc.activo = 1 " +
                            (categoriaId != null ? "AND p.categoria_id = " + categoriaId + " " : "") +
                            "GROUP BY p.id_producto HAVING SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)) <= MAX(smc.stock_minimo_producto)";
                } else if ("STOCK_CRITICO_TOTAL".equals(tipoAlerta)) {
                    sqlConteo = "SELECT COUNT(DISTINCT p.id_producto) FROM productos p " +
                            "INNER JOIN lotes l ON p.id_producto = l.producto_id AND l.estado = 'Registrado' " +
                            "LEFT JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id " +
                            "WHERE p.activo = 1 AND smc.activo = 1 " +
                            (categoriaId != null ? "AND p.categoria_id = " + categoriaId + " " : "") +
                            "GROUP BY p.id_producto HAVING SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)) <= MAX(smc.stock_critico_producto)";
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
        // Usar UPPER() para comparación case-insensitive
        String sqlReglas = """
            SELECT ac.*, r.nombre AS nombre_rol
            FROM alertas_configuracion ac
            INNER JOIN roles r ON ac.rol_a_notificar = r.id_rol
            WHERE ac.activo = 1 AND UPPER(r.nombre) = UPPER(?)
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sqlReglas)) {
            pstmt.setString(1, rolNombre);
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
                    } else if ("STOCK_MINIMO_LOTE".equals(tipoAlerta)) {
                        String sql = "SELECT l.codigo_lote, p.nombre, FLOOR(l.stock_actual / p.unidades_por_paquete) AS paquetes, smc.stock_minimo_lote " +
                                     "FROM lotes l " +
                                     "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                                     "JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id AND smc.activo = 1 " +
                                     "WHERE l.estado = 'Registrado' " +
                                     (categoriaId != null ? "AND p.categoria_id = ? " : "") +
                                     "HAVING paquetes <= smc.stock_minimo_lote LIMIT 20";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            if (categoriaId != null) ps.setInt(1, categoriaId);
                            try (ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    String lote = rs.getString("codigo_lote");
                                    String prod = rs.getString("nombre");
                                    int paquetes = rs.getInt("paquetes");
                                    int umbral = rs.getInt("stock_minimo_lote");
                                    String msg;
                                    if (plantilla != null && !plantilla.isEmpty()) {
                                        msg = plantilla
                                                .replace("{lote}", lote != null ? lote : "")
                                                .replace("{producto}", prod != null ? prod : "")
                                                .replace("{stock_actual}", paquetes + " paquetes")
                                                .replace("{umbral}", umbral + " paquetes");
                                    } else {
                                        msg = "Stock mínimo en lote: " + lote + " (" + prod + ") con " + paquetes + " paquetes (mínimo " + umbral + ")";
                                    }
                                    mensajes.add(msg);
                                }
                            }
                        }
                    } else if ("STOCK_CRITICO_LOTE".equals(tipoAlerta)) {
                        String sql = "SELECT l.codigo_lote, p.nombre, FLOOR(l.stock_actual / p.unidades_por_paquete) AS paquetes, smc.stock_critico_lote " +
                                     "FROM lotes l " +
                                     "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                                     "JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id AND smc.activo = 1 " +
                                     "WHERE l.estado = 'Registrado' " +
                                     (categoriaId != null ? "AND p.categoria_id = ? " : "") +
                                     "HAVING paquetes <= smc.stock_critico_lote LIMIT 20";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            if (categoriaId != null) ps.setInt(1, categoriaId);
                            try (ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    String lote = rs.getString("codigo_lote");
                                    String prod = rs.getString("nombre");
                                    int paquetes = rs.getInt("paquetes");
                                    int umbral = rs.getInt("stock_critico_lote");
                                    String msg;
                                    if (plantilla != null && !plantilla.isEmpty()) {
                                        msg = plantilla
                                                .replace("{lote}", lote != null ? lote : "")
                                                .replace("{producto}", prod != null ? prod : "")
                                                .replace("{stock_actual}", paquetes + " paquetes")
                                                .replace("{umbral}", umbral + " paquetes");
                                    } else {
                                        msg = "¡Stock crítico en lote!: " + lote + " (" + prod + ") con " + paquetes + " paquetes (crítico " + umbral + ")";
                                    }
                                    mensajes.add(msg);
                                }
                            }
                        }
                    } else if ("STOCK_MINIMO_TOTAL".equals(tipoAlerta)) {
                        String sql = "SELECT p.nombre, SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)) AS paquetes_total, smc.stock_minimo_producto " +
                                     "FROM productos p " +
                                     "INNER JOIN lotes l ON p.id_producto = l.producto_id AND l.estado = 'Registrado' " +
                                     "JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id AND smc.activo = 1 " +
                                     (categoriaId != null ? "WHERE p.categoria_id = ? " : "") +
                                     "GROUP BY p.id_producto, smc.stock_minimo_producto HAVING paquetes_total <= smc.stock_minimo_producto LIMIT 20";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            if (categoriaId != null) ps.setInt(1, categoriaId);
                            try (ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    String prod = rs.getString("nombre");
                                    int paquetes = rs.getInt("paquetes_total");
                                    int umbral = rs.getInt("stock_minimo_producto");
                                    String msg;
                                    if (plantilla != null && !plantilla.isEmpty()) {
                                        msg = plantilla
                                                .replace("{producto}", prod != null ? prod : "")
                                                .replace("{stock_actual}", paquetes + " paquetes")
                                                .replace("{umbral}", umbral + " paquetes");
                                    } else {
                                        msg = "Stock mínimo total: Producto " + prod + " con " + paquetes + " paquetes (mínimo " + umbral + ")";
                                    }
                                    mensajes.add(msg);
                                }
                            }
                        }
                    } else if ("STOCK_CRITICO_TOTAL".equals(tipoAlerta)) {
                        String sql = "SELECT p.nombre, SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)) AS paquetes_total, smc.stock_critico_producto " +
                                     "FROM productos p " +
                                     "INNER JOIN lotes l ON p.id_producto = l.producto_id AND l.estado = 'Registrado' " +
                                     "JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id AND smc.activo = 1 " +
                                     (categoriaId != null ? "WHERE p.categoria_id = ? " : "") +
                                     "GROUP BY p.id_producto, smc.stock_critico_producto HAVING paquetes_total <= smc.stock_critico_producto LIMIT 20";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            if (categoriaId != null) ps.setInt(1, categoriaId);
                            try (ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    String prod = rs.getString("nombre");
                                    int paquetes = rs.getInt("paquetes_total");
                                    int umbral = rs.getInt("stock_critico_producto");
                                    String msg;
                                    if (plantilla != null && !plantilla.isEmpty()) {
                                        msg = plantilla
                                                .replace("{producto}", prod != null ? prod : "")
                                                .replace("{stock_actual}", paquetes + " paquetes")
                                                .replace("{umbral}", umbral + " paquetes");
                                    } else {
                                        msg = "¡Stock crítico total!: Producto " + prod + " con " + paquetes + " paquetes (crítico " + umbral + ")";
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
    
    /**
     * Obtiene todos los emails de usuarios activos de un rol específico.
     * 
     * @param rolNombre Nombre del rol (ej: "LOGISTICA", "ALMACEN", etc.)
     * @return Lista de emails de usuarios activos con ese rol
     */
    public ArrayList<String> obtenerEmailsPorRol(String rolNombre) {
        ArrayList<String> emails = new ArrayList<>();
        // Usar UPPER() en ambos lados para comparación case-insensitive
        String sql = "SELECT DISTINCT u.email FROM usuarios u " +
                     "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                     "WHERE UPPER(r.nombre) = UPPER(?) AND u.activo = 1 AND u.email IS NOT NULL AND u.email != ''";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, rolNombre); // Ya no necesitamos .toUpperCase() porque usamos UPPER() en SQL
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    String email = rs.getString("email");
                    if (email != null && !email.trim().isEmpty()) {
                        emails.add(email.trim());
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return emails;
    }
    
    /**
     * Envía correos electrónicos de alerta a todos los usuarios de un rol específico.
     * 
     * @param rolNombre Nombre del rol a notificar
     * @param alertTitle Título de la alerta
     * @param alertMessages Lista de mensajes de alerta
     * @return Número de correos enviados exitosamente
     */
    public int enviarAlertasPorCorreo(String rolNombre, String alertTitle, ArrayList<String> alertMessages) {
        if (alertMessages == null || alertMessages.isEmpty()) {
            return 0;
        }
        
        ArrayList<String> emails = obtenerEmailsPorRol(rolNombre);
        if (emails.isEmpty()) {
            System.out.println("⚠ No se encontraron usuarios activos con email para el rol: " + rolNombre);
            return 0;
        }
        
        // Construir mensaje consolidado
        StringBuilder mensajeConsolidado = new StringBuilder();
        mensajeConsolidado.append("Se han detectado ").append(alertMessages.size()).append(" alerta(s):\n\n");
        for (int i = 0; i < alertMessages.size(); i++) {
            mensajeConsolidado.append((i + 1)).append(". ").append(alertMessages.get(i)).append("\n");
        }
        
        // Enviar correos
        int enviados = 0;
        for (String email : emails) {
            boolean enviado = EmailUtil.sendSystemAlert(email, alertTitle, mensajeConsolidado.toString());
            if (enviado) {
                enviados++;
            }
        }
        
        System.out.println("✓ Se enviaron " + enviados + " correo(s) de alerta al rol: " + rolNombre);
        return enviados;
    }
    
    /**
     * Obtiene la lista de roles únicos que tienen alertas activas configuradas.
     * Útil para el scheduler de alertas automáticas.
     * 
     * @return Lista de nombres de roles que tienen alertas activas
     */
    public ArrayList<String> obtenerRolesConAlertasActivas() {
        ArrayList<String> roles = new ArrayList<>();
        String sql = """
            SELECT DISTINCT r.nombre
            FROM alertas_configuracion ac
            INNER JOIN roles r ON ac.rol_a_notificar = r.id_rol
            WHERE ac.activo = 1
            """;
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                String rolNombre = rs.getString("nombre");
                if (rolNombre != null && !rolNombre.trim().isEmpty()) {
                    roles.add(rolNombre.trim());
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener roles con alertas activas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return roles;
    }
    
    /**
     * Obtiene todas las alertas sin paginación.
     * Útil para exportar a Excel.
     * 
     * @return Lista completa de alertas configuradas
     */
    public ArrayList<AlertaConfig> listarTodasAlertas() {
        ArrayList<AlertaConfig> listaAlertas = new ArrayList<>();
        String sql = "SELECT a.*, c.nombre AS nombre_categoria " +
                "FROM alertas_configuracion a " +
                "LEFT JOIN categorias c ON a.categoria_id = c.id_categoria " +
                "ORDER BY a.id_alerta_config";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                listaAlertas.add(mapResultSetToAlertaConfig(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaAlertas;
    }
}