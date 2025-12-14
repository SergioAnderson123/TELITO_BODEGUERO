package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.PlantillaConfig;
import com.example.telito.administrador.beans.PlantillaMapeo;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// DAO para gestión de plantillas de carga masiva
public class PlantillaDAO extends DAOBase {

    // Lista todas las plantillas (sin detalles de mapeo)
    public ArrayList<PlantillaConfig> listarPlantillas() {
        ArrayList<PlantillaConfig> listaPlantillas = new ArrayList<>();
        String sql = "SELECT * FROM plantillas_config ORDER BY nombre";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                PlantillaConfig plantilla = new PlantillaConfig();
                plantilla.setIdPlantilla(rs.getInt("id_plantilla"));
                plantilla.setNombre(rs.getString("nombre"));
                plantilla.setTipoCarga(rs.getString("tipo_carga"));
                plantilla.setActivo(rs.getBoolean("activo"));
                listaPlantillas.add(plantilla);
            }
        } catch (SQLException e) {
            logger.error("Error al listar plantillas", e);
            throw new RuntimeException("Error al listar plantillas", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return listaPlantillas;
    }

    // Obtiene una plantilla completa con todos sus mapeos de columnas
    public PlantillaConfig obtenerPlantillaPorId(int id) {
        PlantillaConfig plantilla = null;
        String sqlPlantilla = "SELECT * FROM plantillas_config WHERE id_plantilla = ?";
        String sqlMapeos = "SELECT * FROM plantillas_mapeo_columnas WHERE plantilla_id = ?";

        Connection conn = null;
        PreparedStatement pstmtPlantilla = null;
        ResultSet rsPlantilla = null;
        PreparedStatement pstmtMapeos = null;
        ResultSet rsMapeos = null;

        try {
            conn = getConnection();
            pstmtPlantilla = conn.prepareStatement(sqlPlantilla);
            pstmtPlantilla.setInt(1, id);
            rsPlantilla = pstmtPlantilla.executeQuery();

            if (rsPlantilla.next()) {
                plantilla = new PlantillaConfig();
                plantilla.setIdPlantilla(rsPlantilla.getInt("id_plantilla"));
                plantilla.setNombre(rsPlantilla.getString("nombre"));
                plantilla.setTipoCarga(rsPlantilla.getString("tipo_carga"));
                plantilla.setActivo(rsPlantilla.getBoolean("activo"));

                // Ahora que tengo la plantilla, busco sus mapeos.
                List<PlantillaMapeo> mapeos = new ArrayList<>();
                pstmtMapeos = conn.prepareStatement(sqlMapeos);
                pstmtMapeos.setInt(1, id);
                rsMapeos = pstmtMapeos.executeQuery();

                while (rsMapeos.next()) {
                    PlantillaMapeo mapeo = new PlantillaMapeo();
                    mapeo.setIdMapeo(rsMapeos.getInt("id_mapeo"));
                    mapeo.setColumnaExcel(rsMapeos.getString("columna_excel"));
                    mapeo.setCampoDestino(rsMapeos.getString("campo_destino"));
                    mapeos.add(mapeo);
                }
                plantilla.setMapeos(mapeos);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener plantilla por ID: " + id, e);
            throw new RuntimeException("Error al obtener plantilla", e);
        } finally {
            closeResultSet(rsMapeos);
            closePreparedStatement(pstmtMapeos);
            closeResultSet(rsPlantilla);
            closePreparedStatement(pstmtPlantilla);
            closeConnection(conn);
        }
        return plantilla;
    }

    // Crea una plantilla nueva. Uso una transacción por si algo falla.
    public void crearPlantilla(PlantillaConfig plantilla) throws SQLException {
        String sqlPlantilla = "INSERT INTO plantillas_config (nombre, tipo_carga, activo) VALUES (?, ?, ?)";
        String sqlMapeo = "INSERT INTO plantillas_mapeo_columnas (plantilla_id, columna_excel, campo_destino) VALUES (?, ?, ?)";

        Connection conn = null;
        PreparedStatement pstmtPlantilla = null;
        ResultSet generatedKeys = null;
        PreparedStatement pstmtMapeo = null;

        try {
            conn = getConnection();
            beginTransaction(conn);

            // 1. Inserto la plantilla y recupero el ID que se autogeneró.
            int plantillaId;
            pstmtPlantilla = conn.prepareStatement(sqlPlantilla, Statement.RETURN_GENERATED_KEYS);
            pstmtPlantilla.setString(1, plantilla.getNombre());
            pstmtPlantilla.setString(2, plantilla.getTipoCarga());
            pstmtPlantilla.setBoolean(3, plantilla.isActivo());
            pstmtPlantilla.executeUpdate();

            generatedKeys = pstmtPlantilla.getGeneratedKeys();
            if (generatedKeys.next()) {
                plantillaId = generatedKeys.getInt(1);
            } else {
                throw new SQLException("No se pudo obtener el ID de la plantilla creada.");
            }

            // 2. Inserto todos los mapeos que le corresponden con el ID de arriba.
            if (plantilla.getMapeos() != null && !plantilla.getMapeos().isEmpty()) {
                pstmtMapeo = conn.prepareStatement(sqlMapeo);
                for (PlantillaMapeo mapeo : plantilla.getMapeos()) {
                    pstmtMapeo.setInt(1, plantillaId);
                    pstmtMapeo.setString(2, mapeo.getColumnaExcel());
                    pstmtMapeo.setString(3, mapeo.getCampoDestino());
                    pstmtMapeo.addBatch();
                }
                pstmtMapeo.executeBatch();
            }

            commitTransaction(conn);

        } catch (SQLException e) {
            rollbackTransaction(conn);
            logger.error("Error al crear plantilla", e);
            throw e;
        } finally {
            closeResultSet(generatedKeys);
            closePreparedStatement(pstmtMapeo);
            closePreparedStatement(pstmtPlantilla);
            closeConnection(conn);
        }
    }

    // Actualiza una plantilla. También uso una transacción.
    public void actualizarPlantilla(PlantillaConfig plantilla) throws SQLException {
        String sqlUpdatePlantilla = "UPDATE plantillas_config SET nombre = ?, tipo_carga = ?, activo = ? WHERE id_plantilla = ?";
        String sqlDeleteMapeos = "DELETE FROM plantillas_mapeo_columnas WHERE plantilla_id = ?";
        String sqlInsertMapeo = "INSERT INTO plantillas_mapeo_columnas (plantilla_id, columna_excel, campo_destino) VALUES (?, ?, ?)";

        Connection conn = null;
        PreparedStatement pstmtUpdate = null;
        PreparedStatement pstmtDelete = null;
        PreparedStatement pstmtInsert = null;

        try {
            conn = getConnection();
            beginTransaction(conn);

            // 1. Actualizo los datos de la plantilla.
            pstmtUpdate = conn.prepareStatement(sqlUpdatePlantilla);
            pstmtUpdate.setString(1, plantilla.getNombre());
            pstmtUpdate.setString(2, plantilla.getTipoCarga());
            pstmtUpdate.setBoolean(3, plantilla.isActivo());
            pstmtUpdate.setInt(4, plantilla.getIdPlantilla());
            pstmtUpdate.executeUpdate();

            // 2. Borro todos los mapeos que tenía antes.
            pstmtDelete = conn.prepareStatement(sqlDeleteMapeos);
            pstmtDelete.setInt(1, plantilla.getIdPlantilla());
            pstmtDelete.executeUpdate();

            // 3. Inserto los nuevos mapeos que vienen del formulario.
            if (plantilla.getMapeos() != null && !plantilla.getMapeos().isEmpty()) {
                pstmtInsert = conn.prepareStatement(sqlInsertMapeo);
                for (PlantillaMapeo mapeo : plantilla.getMapeos()) {
                    pstmtInsert.setInt(1, plantilla.getIdPlantilla());
                    pstmtInsert.setString(2, mapeo.getColumnaExcel());
                    pstmtInsert.setString(3, mapeo.getCampoDestino());
                    pstmtInsert.addBatch();
                }
                pstmtInsert.executeBatch();
            }

            commitTransaction(conn);

        } catch (SQLException e) {
            rollbackTransaction(conn);
            logger.error("Error al actualizar plantilla", e);
            throw e;
        } finally {
            closePreparedStatement(pstmtInsert);
            closePreparedStatement(pstmtDelete);
            closePreparedStatement(pstmtUpdate);
            closeConnection(conn);
        }
    }

    // Borrado lógico, solo la desactivo.
    public void deshabilitarPlantilla(int id) {
        String sql = "UPDATE plantillas_config SET activo = 0 WHERE id_plantilla = ?";
        executeUpdate(sql, id);
    }
}
