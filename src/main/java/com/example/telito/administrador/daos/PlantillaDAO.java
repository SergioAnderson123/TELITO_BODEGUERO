package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.PlantillaConfig;
import com.example.telito.administrador.beans.PlantillaMapeo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PlantillaDAO {

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

    // Carga la lista de plantillas para la tabla principal, pero sin los detalles de mapeo.
    public ArrayList<PlantillaConfig> listarPlantillas() {
        ArrayList<PlantillaConfig> listaPlantillas = new ArrayList<>();
        String sql = "SELECT * FROM plantillas_config ORDER BY nombre";

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                PlantillaConfig plantilla = new PlantillaConfig();
                plantilla.setIdPlantilla(rs.getInt("id_plantilla"));
                plantilla.setNombre(rs.getString("nombre"));
                plantilla.setTipoCarga(rs.getString("tipo_carga"));
                plantilla.setActivo(rs.getBoolean("activo"));
                listaPlantillas.add(plantilla);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaPlantillas;
    }

    // Trae una plantilla con todos sus mapeos para el formulario de edición.
    public PlantillaConfig obtenerPlantillaPorId(int id) {
        PlantillaConfig plantilla = null;
        String sqlPlantilla = "SELECT * FROM plantillas_config WHERE id_plantilla = ?";
        String sqlMapeos = "SELECT * FROM plantillas_mapeo_columnas WHERE plantilla_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmtPlantilla = conn.prepareStatement(sqlPlantilla)) {

            pstmtPlantilla.setInt(1, id);
            try (ResultSet rsPlantilla = pstmtPlantilla.executeQuery()) {
                if (rsPlantilla.next()) {
                    plantilla = new PlantillaConfig();
                    plantilla.setIdPlantilla(rsPlantilla.getInt("id_plantilla"));
                    plantilla.setNombre(rsPlantilla.getString("nombre"));
                    plantilla.setTipoCarga(rsPlantilla.getString("tipo_carga"));
                    plantilla.setActivo(rsPlantilla.getBoolean("activo"));

                    // Ahora que tengo la plantilla, busco sus mapeos.
                    List<PlantillaMapeo> mapeos = new ArrayList<>();
                    try (PreparedStatement pstmtMapeos = conn.prepareStatement(sqlMapeos)) {
                        pstmtMapeos.setInt(1, id);
                        try (ResultSet rsMapeos = pstmtMapeos.executeQuery()) {
                            while (rsMapeos.next()) {
                                PlantillaMapeo mapeo = new PlantillaMapeo();
                                mapeo.setIdMapeo(rsMapeos.getInt("id_mapeo"));
                                mapeo.setColumnaExcel(rsMapeos.getString("columna_excel"));
                                mapeo.setCampoDestino(rsMapeos.getString("campo_destino"));
                                mapeos.add(mapeo);
                            }
                        }
                    }
                    plantilla.setMapeos(mapeos);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return plantilla;
    }

    // Crea una plantilla nueva. Uso una transacción por si algo falla.
    public void crearPlantilla(PlantillaConfig plantilla) throws SQLException {
        String sqlPlantilla = "INSERT INTO plantillas_config (nombre, tipo_carga, activo) VALUES (?, ?, ?)";
        String sqlMapeo = "INSERT INTO plantillas_mapeo_columnas (plantilla_id, columna_excel, campo_destino) VALUES (?, ?, ?)";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Inicio la transacción.

            // 1. Inserto la plantilla y recupero el ID que se autogeneró.
            int plantillaId;
            try (PreparedStatement pstmtPlantilla = conn.prepareStatement(sqlPlantilla, Statement.RETURN_GENERATED_KEYS)) {
                pstmtPlantilla.setString(1, plantilla.getNombre());
                pstmtPlantilla.setString(2, plantilla.getTipoCarga());
                pstmtPlantilla.setBoolean(3, plantilla.isActivo());
                pstmtPlantilla.executeUpdate();

                try (ResultSet generatedKeys = pstmtPlantilla.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        plantillaId = generatedKeys.getInt(1);
                    } else {
                        throw new SQLException("No se pudo obtener el ID de la plantilla creada.");
                    }
                }
            }

            // 2. Inserto todos los mapeos que le corresponden con el ID de arriba.
            if (plantilla.getMapeos() != null && !plantilla.getMapeos().isEmpty()) {
                try (PreparedStatement pstmtMapeo = conn.prepareStatement(sqlMapeo)) {
                    for (PlantillaMapeo mapeo : plantilla.getMapeos()) {
                        pstmtMapeo.setInt(1, plantillaId);
                        pstmtMapeo.setString(2, mapeo.getColumnaExcel());
                        pstmtMapeo.setString(3, mapeo.getCampoDestino());
                        pstmtMapeo.addBatch();
                    }
                    pstmtMapeo.executeBatch();
                }
            }

            conn.commit(); // Si todo salió bien, confirmo los cambios.

        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback(); // Si algo falló, revierto todo.
            }
            e.printStackTrace();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true); // Restauro el modo normal.
                conn.close();
            }
        }
    }

    // Actualiza una plantilla. También uso una transacción.
    public void actualizarPlantilla(PlantillaConfig plantilla) throws SQLException {
        String sqlUpdatePlantilla = "UPDATE plantillas_config SET nombre = ?, tipo_carga = ?, activo = ? WHERE id_plantilla = ?";
        String sqlDeleteMapeos = "DELETE FROM plantillas_mapeo_columnas WHERE plantilla_id = ?";
        String sqlInsertMapeo = "INSERT INTO plantillas_mapeo_columnas (plantilla_id, columna_excel, campo_destino) VALUES (?, ?, ?)";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Inicio la transacción.

            // 1. Actualizo los datos de la plantilla.
            try (PreparedStatement pstmtUpdate = conn.prepareStatement(sqlUpdatePlantilla)) {
                pstmtUpdate.setString(1, plantilla.getNombre());
                pstmtUpdate.setString(2, plantilla.getTipoCarga());
                pstmtUpdate.setBoolean(3, plantilla.isActivo());
                pstmtUpdate.setInt(4, plantilla.getIdPlantilla());
                pstmtUpdate.executeUpdate();
            }

            // 2. Borro todos los mapeos que tenía antes.
            try (PreparedStatement pstmtDelete = conn.prepareStatement(sqlDeleteMapeos)) {
                pstmtDelete.setInt(1, plantilla.getIdPlantilla());
                pstmtDelete.executeUpdate();
            }

            // 3. Inserto los nuevos mapeos que vienen del formulario.
            if (plantilla.getMapeos() != null && !plantilla.getMapeos().isEmpty()) {
                try (PreparedStatement pstmtInsert = conn.prepareStatement(sqlInsertMapeo)) {
                    for (PlantillaMapeo mapeo : plantilla.getMapeos()) {
                        pstmtInsert.setInt(1, plantilla.getIdPlantilla());
                        pstmtInsert.setString(2, mapeo.getColumnaExcel());
                        pstmtInsert.setString(3, mapeo.getCampoDestino());
                        pstmtInsert.addBatch();
                    }
                    pstmtInsert.executeBatch();
                }
            }

            conn.commit(); // Confirmo los cambios.

        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback(); // Revierto todo si hay error.
            }
            e.printStackTrace();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    // Borrado lógico, solo la desactivo.
    public void deshabilitarPlantilla(int id) {
        String sql = "UPDATE plantillas_config SET activo = 0 WHERE id_plantilla = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
