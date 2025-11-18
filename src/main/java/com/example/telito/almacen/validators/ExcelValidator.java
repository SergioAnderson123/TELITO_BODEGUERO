package com.example.telito.almacen.validators;

import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.beans.Ubicacion;
import com.example.telito.almacen.beans.Movimiento;
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.almacen.daos.MovimientoDao;
import com.example.telito.almacen.daos.UbicacionDao;
import com.example.telito.administrador.daos.ProductoDAO;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Clase para validar archivos Excel de entradas de inventario.
 * Valida estructura, formato y datos antes de permitir la inserción.
 */
public class ExcelValidator {
    
    private static final Logger logger = LoggerFactory.getLogger(ExcelValidator.class);
    
    // Columnas esperadas en el Excel (en orden)
    private static final String[] COLUMNAS_ESPERADAS = {
        "Código Lote",
        "Código SKU Producto",
        "Cantidad",
        "Fecha Vencimiento",
        "Ubicación",
        "Orden Compra"
    };
    
    private final LoteDao loteDao;
    private final ProductoDAO productoDAO;
    private final UbicacionDao ubicacionDao;
    private final MovimientoDao movimientoDao;
    
    public ExcelValidator() {
        this.loteDao = new LoteDao();
        this.productoDAO = new ProductoDAO();
        this.ubicacionDao = new UbicacionDao();
        this.movimientoDao = new MovimientoDao();
    }
    
    /**
     * Valida un archivo Excel completo.
     * @param inputStream Stream del archivo Excel
     * @param fileName Nombre del archivo
     * @return Map con resultado de validación
     */
    public Map<String, Object> validarArchivoExcel(InputStream inputStream, String fileName) {
        Map<String, Object> resultado = new HashMap<>();
        List<Map<String, Object>> filasValidadas = new ArrayList<>();
        List<String> errores = new ArrayList<>();
        List<String> advertencias = new ArrayList<>();
        int totalFilas = 0;
        int filasValidas = 0;
        int filasConErrores = 0;
        
        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet sheet = workbook.getSheetAt(0);
            
            // Validar estructura básica
            if (sheet.getPhysicalNumberOfRows() < 2) {
                errores.add("El archivo debe tener al menos una fila de encabezados y una fila de datos");
                resultado.put("esValido", false);
                resultado.put("errores", errores);
                return resultado;
            }
            
            // Validar encabezados
            Row headerRow = sheet.getRow(0);
            if (headerRow == null) {
                errores.add("No se encontró la fila de encabezados");
                resultado.put("esValido", false);
                resultado.put("errores", errores);
                return resultado;
            }
            
            List<String> erroresEstructura = validarEstructura(headerRow);
            if (!erroresEstructura.isEmpty()) {
                errores.addAll(erroresEstructura);
                resultado.put("esValido", false);
                resultado.put("errores", errores);
                return resultado;
            }
            
            // Validar datos fila por fila
            totalFilas = sheet.getLastRowNum();
            for (int i = 1; i <= totalFilas; i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                
                Map<String, Object> validacionFila = validarFila(row, i + 1);
                filasValidadas.add(validacionFila);
                
                Boolean esValida = (Boolean) validacionFila.get("esValida");
                if (esValida != null && esValida) {
                    filasValidas++;
                } else {
                    filasConErrores++;
                    List<String> erroresFila = (List<String>) validacionFila.get("errores");
                    if (erroresFila != null) {
                        errores.addAll(erroresFila);
                    }
                }
                
                List<String> advertenciasFila = (List<String>) validacionFila.get("advertencias");
                if (advertenciasFila != null) {
                    advertencias.addAll(advertenciasFila);
                }
            }
            
            // Determinar si el archivo es válido
            boolean esValido = filasConErrores == 0 && errores.isEmpty();
            
            resultado.put("esValido", esValido);
            resultado.put("totalFilas", totalFilas);
            resultado.put("filasValidas", filasValidas);
            resultado.put("filasConErrores", filasConErrores);
            resultado.put("filasValidadas", filasValidadas);
            resultado.put("errores", errores);
            resultado.put("advertencias", advertencias);
            resultado.put("datos", extraerDatos(sheet));
            
        } catch (Exception e) {
            logger.error("Error al validar archivo Excel", e);
            errores.add("Error al leer el archivo: " + e.getMessage());
            resultado.put("esValido", false);
            resultado.put("errores", errores);
        }
        
        return resultado;
    }
    
    /**
     * Valida la estructura del archivo (encabezados).
     */
    private List<String> validarEstructura(Row headerRow) {
        List<String> errores = new ArrayList<>();
        
        // Verificar número de columnas
        int numColumnas = headerRow.getLastCellNum();
        if (numColumnas < COLUMNAS_ESPERADAS.length) {
            errores.add(String.format(
                "El archivo debe tener al menos %d columnas. Se encontraron %d",
                COLUMNAS_ESPERADAS.length, numColumnas
            ));
            return errores;
        }
        
        // Verificar nombres de columnas
        for (int i = 0; i < COLUMNAS_ESPERADAS.length; i++) {
            Cell cell = headerRow.getCell(i);
            String valorEsperado = COLUMNAS_ESPERADAS[i];
            String valorObtenido = obtenerValorCelda(cell);
            
            if (!valorEsperado.equalsIgnoreCase(valorObtenido)) {
                errores.add(String.format(
                    "Columna %d: Se esperaba '%s' pero se encontró '%s'",
                    i + 1, valorEsperado, valorObtenido
                ));
            }
        }
        
        return errores;
    }
    
    /**
     * Valida una fila de datos.
     */
    private Map<String, Object> validarFila(Row row, int numeroFila) {
        Map<String, Object> resultado = new HashMap<>();
        List<String> errores = new ArrayList<>();
        List<String> advertencias = new ArrayList<>();
        Map<String, Object> datos = new HashMap<>();
        
        // Leer valores de las celdas
        String codigoLote = obtenerValorCelda(row.getCell(0));
        String codigoSKU = obtenerValorCelda(row.getCell(1));
        String cantidadStr = obtenerValorCelda(row.getCell(2));
        String fechaVencimientoStr = obtenerValorCelda(row.getCell(3));
        String ubicacion = obtenerValorCelda(row.getCell(4));
        String ordenCompra = obtenerValorCelda(row.getCell(5));
        
        // Validar que no esté vacía
        if (codigoLote == null || codigoLote.trim().isEmpty()) {
            errores.add(String.format("Fila %d: El código de lote es obligatorio", numeroFila));
        } else {
            datos.put("codigoLote", codigoLote.trim());
        }
        
        if (codigoSKU == null || codigoSKU.trim().isEmpty()) {
            errores.add(String.format("Fila %d: El código SKU del producto es obligatorio", numeroFila));
        } else {
            datos.put("codigoSKU", codigoSKU.trim());
            // Validar que el producto exista
            if (!productoDAO.existeProductoPorSKU(codigoSKU.trim())) {
                errores.add(String.format("Fila %d: El producto con SKU '%s' no existe en el sistema", numeroFila, codigoSKU.trim()));
            }
        }
        
        // Validar cantidad
        int cantidad = 0;
        if (cantidadStr == null || cantidadStr.trim().isEmpty()) {
            errores.add(String.format("Fila %d: La cantidad es obligatoria", numeroFila));
        } else {
            try {
                cantidad = Integer.parseInt(cantidadStr.trim());
                if (cantidad <= 0) {
                    errores.add(String.format("Fila %d: La cantidad debe ser mayor a 0", numeroFila));
                } else {
                    datos.put("cantidad", cantidad);
                }
            } catch (NumberFormatException e) {
                errores.add(String.format("Fila %d: La cantidad '%s' no es un número válido", numeroFila, cantidadStr));
            }
        }
        
        // Validar fecha de vencimiento
        Date fechaVencimiento = null;
        if (fechaVencimientoStr == null || fechaVencimientoStr.trim().isEmpty()) {
            errores.add(String.format("Fila %d: La fecha de vencimiento es obligatoria", numeroFila));
        } else {
            try {
                fechaVencimiento = parseFecha(fechaVencimientoStr.trim());
                if (fechaVencimiento == null) {
                    errores.add(String.format("Fila %d: La fecha de vencimiento '%s' no tiene un formato válido (dd/MM/yyyy o yyyy-MM-dd)", numeroFila, fechaVencimientoStr));
                } else {
                    datos.put("fechaVencimiento", fechaVencimiento);
                    // Advertencia si la fecha es muy próxima
                    long diasHastaVencimiento = (fechaVencimiento.getTime() - System.currentTimeMillis()) / (1000 * 60 * 60 * 24);
                    if (diasHastaVencimiento < 30) {
                        advertencias.add(String.format("Fila %d: El producto vence en menos de 30 días", numeroFila));
                    }
                }
            } catch (Exception e) {
                errores.add(String.format("Fila %d: Error al procesar fecha de vencimiento: %s", numeroFila, e.getMessage()));
            }
        }
        
        // Validar ubicación
        if (ubicacion == null || ubicacion.trim().isEmpty()) {
            errores.add(String.format("Fila %d: La ubicación es obligatoria", numeroFila));
        } else {
            datos.put("ubicacion", ubicacion.trim());
            // Validar que la ubicación exista
            if (!ubicacionDao.existeUbicacionPorNombre(ubicacion.trim())) {
                errores.add(String.format("Fila %d: La ubicación '%s' no existe en el sistema", numeroFila, ubicacion.trim()));
            }
        }
        
        // Orden de compra (opcional)
        if (ordenCompra != null && !ordenCompra.trim().isEmpty()) {
            datos.put("ordenCompra", ordenCompra.trim());
        }
        
        resultado.put("numeroFila", numeroFila);
        resultado.put("esValida", errores.isEmpty());
        resultado.put("errores", errores);
        resultado.put("advertencias", advertencias);
        resultado.put("datos", datos);
        
        return resultado;
    }
    
    /**
     * Extrae los datos validados del Excel.
     */
    private List<Map<String, Object>> extraerDatos(Sheet sheet) {
        List<Map<String, Object>> datos = new ArrayList<>();
        
        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            if (row == null) continue;
            
            Map<String, Object> fila = new HashMap<>();
            fila.put("codigoLote", obtenerValorCelda(row.getCell(0)));
            fila.put("codigoSKU", obtenerValorCelda(row.getCell(1)));
            fila.put("cantidad", obtenerValorCelda(row.getCell(2)));
            fila.put("fechaVencimiento", obtenerValorCelda(row.getCell(3)));
            fila.put("ubicacion", obtenerValorCelda(row.getCell(4)));
            fila.put("ordenCompra", obtenerValorCelda(row.getCell(5)));
            
            datos.add(fila);
        }
        
        return datos;
    }
    
    /**
     * Obtiene el valor de una celda como String.
     */
    private String obtenerValorCelda(Cell cell) {
        if (cell == null) {
            return null;
        }
        
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                if (DateUtil.isCellDateFormatted(cell)) {
                    return new SimpleDateFormat("dd/MM/yyyy").format(cell.getDateCellValue());
                } else {
                    // Evitar notación científica
                    double numValue = cell.getNumericCellValue();
                    if (numValue == (long) numValue) {
                        return String.valueOf((long) numValue);
                    } else {
                        return String.valueOf(numValue);
                    }
                }
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                return cell.getCellFormula();
            default:
                return null;
        }
    }
    
    /**
     * Parsea una fecha desde String.
     */
    private Date parseFecha(String fechaStr) {
        if (fechaStr == null || fechaStr.trim().isEmpty()) {
            return null;
        }
        
        SimpleDateFormat[] formatos = {
            new SimpleDateFormat("dd/MM/yyyy"),
            new SimpleDateFormat("yyyy-MM-dd"),
            new SimpleDateFormat("dd-MM-yyyy")
        };
        
        for (SimpleDateFormat formato : formatos) {
            try {
                formato.setLenient(false);
                java.util.Date fecha = formato.parse(fechaStr.trim());
                return new Date(fecha.getTime());
            } catch (Exception e) {
                // Intentar siguiente formato
            }
        }
        
        return null;
    }
    
    /**
     * Descarga una plantilla Excel vacía.
     */
    public void descargarPlantilla(HttpServletResponse response) throws IOException {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=plantilla_entradas_almacen.xlsx");
        
        try (Workbook workbook = new XSSFWorkbook();
             OutputStream out = response.getOutputStream()) {
            
            Sheet sheet = workbook.createSheet("Entradas");
            
            // Crear estilo para encabezados
            CellStyle headerStyle = workbook.createCellStyle();
            Font font = workbook.createFont();
            font.setBold(true);
            font.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(font);
            headerStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);
            
            // Crear fila de encabezados
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < COLUMNAS_ESPERADAS.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(COLUMNAS_ESPERADAS[i]);
                cell.setCellStyle(headerStyle);
            }
            
            // Ajustar ancho de columnas
            for (int i = 0; i < COLUMNAS_ESPERADAS.length; i++) {
                sheet.autoSizeColumn(i);
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }
            
            // Crear fila de ejemplo
            Row ejemploRow = sheet.createRow(1);
            ejemploRow.createCell(0).setCellValue("L-0001");
            ejemploRow.createCell(1).setCellValue("SKU001");
            ejemploRow.createCell(2).setCellValue(100);
            ejemploRow.createCell(3).setCellValue("31/12/2025");
            ejemploRow.createCell(4).setCellValue("Estante A01");
            ejemploRow.createCell(5).setCellValue("OC001");
            
            workbook.write(out);
        }
    }
    
    /**
     * Procesa los datos validados e inserta en la base de datos.
     */
    public Map<String, Object> procesarDatosValidados(Map<String, Object> resultadoValidacion, int usuarioId) {
        Map<String, Object> resultado = new HashMap<>();
        List<String> errores = new ArrayList<>();
        int registrosInsertados = 0;
        int registrosConError = 0;
        
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> filasValidadas = (List<Map<String, Object>>) resultadoValidacion.get("filasValidadas");
        
        if (filasValidadas == null || filasValidadas.isEmpty()) {
            errores.add("No hay datos válidos para procesar");
            resultado.put("exito", false);
            resultado.put("errores", errores);
            return resultado;
        }
        
        for (Map<String, Object> fila : filasValidadas) {
            Boolean esValida = (Boolean) fila.get("esValida");
            if (esValida == null || !esValida) {
                registrosConError++;
                continue;
            }
            
            @SuppressWarnings("unchecked")
            Map<String, Object> datos = (Map<String, Object>) fila.get("datos");
            if (datos == null) {
                registrosConError++;
                continue;
            }
            
            try {
                // Extraer datos de la fila
                String codigoLote = (String) datos.get("codigoLote");
                String codigoSKU = (String) datos.get("codigoSKU");
                Integer cantidad = (Integer) datos.get("cantidad");
                Date fechaVencimiento = (Date) datos.get("fechaVencimiento");
                String nombreUbicacion = (String) datos.get("ubicacion");
                String ordenCompraStr = (String) datos.get("ordenCompra");
                
                // Obtener IDs necesarios
                com.example.telito.administrador.beans.Producto producto = productoDAO.obtenerProductoPorSKU(codigoSKU);
                if (producto == null) {
                    errores.add("Fila " + fila.get("numeroFila") + ": Producto con SKU '" + codigoSKU + "' no encontrado");
                    registrosConError++;
                    continue;
                }
                
                Ubicacion ubicacion = obtenerUbicacionPorNombre(nombreUbicacion);
                if (ubicacion == null) {
                    errores.add("Fila " + fila.get("numeroFila") + ": Ubicación '" + nombreUbicacion + "' no encontrada");
                    registrosConError++;
                    continue;
                }
                
                // Obtener distrito (usar el primero disponible o un valor por defecto)
                // Por ahora usaremos distrito_id = 1 como valor por defecto
                // TODO: Mejorar esto para obtener el distrito correcto
                int distritoId = 1;
                
                // Verificar si el lote ya existe
                Lote loteExistente = loteDao.buscarLotePorCodigo(codigoLote);
                if (loteExistente != null) {
                    // Si existe, actualizar stock y crear movimiento
                    int stockAnterior = loteExistente.getStockActual();
                    loteDao.actualizarStock(loteExistente.getIdLote(), stockAnterior + cantidad);
                    
                    // Crear movimiento de entrada
                    Movimiento movimiento = new Movimiento();
                    movimiento.setLoteId(loteExistente.getIdLote());
                    movimiento.setUsuarioId(usuarioId);
                    movimiento.setTipoMovimiento("Entrada");
                    movimiento.setCantidad(cantidad);
                    movimiento.setMotivo("Carga masiva desde Excel - Orden: " + (ordenCompraStr != null ? ordenCompraStr : "N/A"));
                    movimiento.setPedidoId(null);
                    movimiento.setOrdenCompraId(null);
                    movimientoDao.registrarMovimiento(movimiento);
                    
                    registrosInsertados++;
                } else {
                    // Crear nuevo lote
                    Lote nuevoLote = new Lote();
                    nuevoLote.setCodigoLote(codigoLote);
                    nuevoLote.setStockActual(cantidad);
                    nuevoLote.setFechaVencimiento(fechaVencimiento);
                    nuevoLote.setProductoId(producto.getIdProducto());
                    nuevoLote.setUbicacionId(ubicacion.getIdUbicacion());
                    nuevoLote.setDistritoId(distritoId);
                    nuevoLote.setEstado("Registrado"); // Lote registrado directamente desde Excel
                    
                    int idLoteCreado = loteDao.crearLote(nuevoLote);
                    
                    // Crear movimiento de entrada
                    Movimiento movimiento = new Movimiento();
                    movimiento.setLoteId(idLoteCreado);
                    movimiento.setUsuarioId(usuarioId);
                    movimiento.setTipoMovimiento("Entrada");
                    movimiento.setCantidad(cantidad);
                    movimiento.setMotivo("Carga masiva desde Excel - Orden: " + (ordenCompraStr != null ? ordenCompraStr : "N/A"));
                    movimiento.setPedidoId(null);
                    movimiento.setOrdenCompraId(null);
                    movimientoDao.registrarMovimiento(movimiento);
                    
                    registrosInsertados++;
                }
                
            } catch (Exception e) {
                logger.error("Error al insertar registro", e);
                errores.add("Error al insertar fila " + fila.get("numeroFila") + ": " + e.getMessage());
                registrosConError++;
            }
        }
        
        resultado.put("exito", registrosConError == 0);
        resultado.put("registrosInsertados", registrosInsertados);
        resultado.put("registrosConError", registrosConError);
        resultado.put("errores", errores);
        
        return resultado;
    }
    
    /**
     * Obtiene una ubicación por su nombre.
     */
    private Ubicacion obtenerUbicacionPorNombre(String nombre) {
        ArrayList<Ubicacion> ubicaciones = ubicacionDao.listar();
        for (Ubicacion u : ubicaciones) {
            if (u.getNombre().equalsIgnoreCase(nombre)) {
                return u;
            }
        }
        return null;
    }
}

