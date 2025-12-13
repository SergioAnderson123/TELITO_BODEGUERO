package com.example.telito.util;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFColor;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFFont;

import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Date;

/**
 * Clase utilitaria para generar archivos Excel.
 * Proporciona métodos para crear archivos Excel con formato, filtros automáticos y estilos.
 */
public class ExcelUtil {
    
    /**
     * Genera un archivo Excel con la lista de usuarios.
     * Incluye filtros automáticos en las columnas y formato profesional.
     * 
     * @param listaUsuarios Lista de usuarios a exportar
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelUsuarios(ArrayList<?> listaUsuarios, OutputStream outputStream, String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            // Crear hoja de cálculo
            XSSFSheet sheet = workbook.createSheet("Usuarios");
            
            // Crear estilos
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);
            
            int rowNum = 0;
            
            // Título del reporte
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("REPORTE DE USUARIOS - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 5));
            
            // Fecha de generación
            Row dateRow = sheet.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 5));
            
            // Filtros aplicados (si existen)
            if (filtrosInformacion != null && !filtrosInformacion.trim().isEmpty()) {
                Row filterRow = sheet.createRow(rowNum++);
                Cell filterCell = filterRow.createCell(0);
                filterCell.setCellValue("Filtros aplicados: " + filtrosInformacion);
                filterCell.setCellStyle(dataStyle);
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 5));
            }
            
            // Fila en blanco
            rowNum++;
            
            // Encabezados - guardar el índice de esta fila para el autoFilter
            int headerRowIndex = rowNum;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"ID", "Nombres", "Apellidos", "Correo Electrónico", "Rol", "Estado"};
            int colNum = 0;
            for (String header : headers) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }
            
            // Datos de usuarios
            // Usamos reflexión para acceder a los métodos getter de forma genérica
            for (Object obj : listaUsuarios) {
                Row row = sheet.createRow(rowNum++);
                try {
                    // ID
                    int id = (Integer) obj.getClass().getMethod("getIdUsuario").invoke(obj);
                    Cell cell = row.createCell(0);
                    cell.setCellValue(id);
                    cell.setCellStyle(dataStyle);
                    
                    // Nombres
                    String nombres = (String) obj.getClass().getMethod("getNombres").invoke(obj);
                    cell = row.createCell(1);
                    cell.setCellValue(nombres != null ? nombres : "");
                    cell.setCellStyle(dataStyle);
                    
                    // Apellidos
                    String apellidos = (String) obj.getClass().getMethod("getApellidos").invoke(obj);
                    cell = row.createCell(2);
                    cell.setCellValue(apellidos != null ? apellidos : "");
                    cell.setCellStyle(dataStyle);
                    
                    // Email
                    String email = (String) obj.getClass().getMethod("getEmail").invoke(obj);
                    cell = row.createCell(3);
                    cell.setCellValue(email != null ? email : "");
                    cell.setCellStyle(dataStyle);
                    
                    // Rol
                    Object rolObj = obj.getClass().getMethod("getRol").invoke(obj);
                    String rolNombre = "";
                    if (rolObj != null) {
                        rolNombre = (String) rolObj.getClass().getMethod("getNombre").invoke(rolObj);
                    }
                    cell = row.createCell(4);
                    cell.setCellValue(rolNombre != null ? rolNombre : "");
                    cell.setCellStyle(dataStyle);
                    
                    // Estado
                    boolean activo = (Boolean) obj.getClass().getMethod("isActivo").invoke(obj);
                    cell = row.createCell(5);
                    cell.setCellValue(activo ? "Activo" : "Inactivo");
                    cell.setCellStyle(dataStyle);
                    
                } catch (Exception e) {
                    System.err.println("Error al procesar usuario: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            // Ajustar ancho de columnas
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // Agregar un poco más de espacio
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }
            
            // Aplicar filtro automático a los encabezados (en la misma fila de encabezados)
            // headerRowIndex ya fue guardado anteriormente cuando se creó la fila de encabezados
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndex, headerRowIndex, 0, headers.length - 1));
            
            // Congelar paneles (dejar visibles los encabezados al hacer scroll)
            sheet.createFreezePane(0, headerRowIndex + 1);
            
            // Escribir al stream
            workbook.write(outputStream);
        }
    }
    
    /**
     * Crea un estilo para los encabezados de la tabla.
     */
    private static CellStyle crearEstiloEncabezado(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        
        font.setBold(true);
        font.setFontHeightInPoints((short) 11);
        font.setColor(IndexedColors.WHITE.getIndex());
        
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setBottomBorderColor(IndexedColors.BLACK.getIndex());
        style.setTopBorderColor(IndexedColors.BLACK.getIndex());
        style.setLeftBorderColor(IndexedColors.BLACK.getIndex());
        style.setRightBorderColor(IndexedColors.BLACK.getIndex());
        
        return style;
    }
    
    /**
     * Crea un estilo para los encabezados de la tabla con color verde (#28a745).
     * Similar al color usado en los sidebars de administrador.
     */
    private static CellStyle crearEstiloEncabezadoVerde(Workbook workbook) {
        if (!(workbook instanceof XSSFWorkbook)) {
            // Si no es XSSFWorkbook, usar el estilo estándar
            return crearEstiloEncabezado(workbook);
        }
        
        XSSFWorkbook xssfWorkbook = (XSSFWorkbook) workbook;
        XSSFCellStyle style = xssfWorkbook.createCellStyle();
        XSSFFont font = xssfWorkbook.createFont();
        
        font.setBold(true);
        font.setFontHeightInPoints((short) 11);
        font.setColor(IndexedColors.WHITE.getIndex());
        
        style.setFont(font);
        
        // Color verde #28a745 = RGB(40, 167, 69)
        java.awt.Color javaColor = new java.awt.Color(40, 167, 69);
        XSSFColor greenColor = new XSSFColor(javaColor, null);
        style.setFillForegroundColor(greenColor);
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setBottomBorderColor(IndexedColors.BLACK.getIndex());
        style.setTopBorderColor(IndexedColors.BLACK.getIndex());
        style.setLeftBorderColor(IndexedColors.BLACK.getIndex());
        style.setRightBorderColor(IndexedColors.BLACK.getIndex());
        
        return style;
    }
    
    /**
     * Crea un estilo para los datos de la tabla.
     */
    private static CellStyle crearEstiloDatos(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        
        style.setAlignment(HorizontalAlignment.LEFT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setBottomBorderColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setTopBorderColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setLeftBorderColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setRightBorderColor(IndexedColors.GREY_25_PERCENT.getIndex());
        
        // Alternar colores de fondo
        style.setFillForegroundColor(IndexedColors.WHITE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        
        return style;
    }
    
    /**
     * Crea un estilo para el título del reporte.
     */
    private static CellStyle crearEstiloTitulo(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        
        font.setBold(true);
        font.setFontHeightInPoints((short) 16);
        font.setColor(IndexedColors.DARK_BLUE.getIndex());
        
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        
        return style;
    }
    
    /**
     * Genera un archivo Excel con la lista de conductores.
     * Incluye filtros automáticos en las columnas y formato profesional.
     * 
     * @param listaConductores Lista de conductores a exportar
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelConductores(ArrayList<?> listaConductores, OutputStream outputStream, String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            // Crear hoja de cálculo
            XSSFSheet sheet = workbook.createSheet("Conductores");
            
            // Crear estilos
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);
            
            int rowNum = 0;
            
            // Título del reporte
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("REPORTE DE CONDUCTORES - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 2));
            
            // Fecha de generación
            Row dateRow = sheet.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 2));
            
            // Filtros aplicados (si existen)
            if (filtrosInformacion != null && !filtrosInformacion.trim().isEmpty()) {
                Row filterRow = sheet.createRow(rowNum++);
                Cell filterCell = filterRow.createCell(0);
                filterCell.setCellValue("Filtros aplicados: " + filtrosInformacion);
                filterCell.setCellStyle(dataStyle);
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 2));
            }
            
            // Fila en blanco
            rowNum++;
            
            // Encabezados - guardar el índice de esta fila para el autoFilter
            int headerRowIndex = rowNum;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"ID", "Nombre Completo", "Licencia"};
            int colNum = 0;
            for (String header : headers) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }
            
            // Datos de conductores
            for (Object obj : listaConductores) {
                Row row = sheet.createRow(rowNum++);
                try {
                    // ID
                    int id = (Integer) obj.getClass().getMethod("getIdConductor").invoke(obj);
                    Cell cell = row.createCell(0);
                    cell.setCellValue(id);
                    cell.setCellStyle(dataStyle);
                    
                    // Nombre Completo
                    String nombreCompleto = (String) obj.getClass().getMethod("getNombreCompleto").invoke(obj);
                    cell = row.createCell(1);
                    cell.setCellValue(nombreCompleto != null ? nombreCompleto : "");
                    cell.setCellStyle(dataStyle);
                    
                    // Licencia
                    String licencia = (String) obj.getClass().getMethod("getLicencia").invoke(obj);
                    cell = row.createCell(2);
                    cell.setCellValue(licencia != null ? licencia : "");
                    cell.setCellStyle(dataStyle);
                    
                } catch (Exception e) {
                    System.err.println("Error al procesar conductor: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            // Ajustar ancho de columnas
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // Agregar un poco más de espacio
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }
            
            // Aplicar filtro automático a los encabezados (en la misma fila de encabezados)
            // headerRowIndex ya fue guardado anteriormente cuando se creó la fila de encabezados
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndex, headerRowIndex, 0, headers.length - 1));
            
            // Congelar paneles (dejar visibles los encabezados al hacer scroll)
            sheet.createFreezePane(0, headerRowIndex + 1);
            
            // Escribir al stream
            workbook.write(outputStream);
        }
    }
    
    /**
     * Genera un archivo Excel con la lista de alertas.
     * Incluye filtros automáticos en las columnas y formato profesional.
     * 
     * @param listaAlertas Lista de alertas a exportar
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelAlertas(ArrayList<?> listaAlertas, OutputStream outputStream, String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            // Crear hoja de cálculo
            XSSFSheet sheet = workbook.createSheet("Alertas");
            
            // Crear estilos
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);
            
            int rowNum = 0;
            
            // Título del reporte
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("REPORTE DE ALERTAS - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 6));
            
            // Fecha de generación
            Row dateRow = sheet.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 6));
            
            // Filtros aplicados (si existen)
            if (filtrosInformacion != null && !filtrosInformacion.trim().isEmpty()) {
                Row filterRow = sheet.createRow(rowNum++);
                Cell filterCell = filterRow.createCell(0);
                filterCell.setCellValue("Filtros aplicados: " + filtrosInformacion);
                filterCell.setCellStyle(dataStyle);
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 6));
            }
            
            // Fila en blanco
            rowNum++;
            
            // Encabezados - guardar el índice de esta fila para el autoFilter
            int headerRowIndex = rowNum;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"ID", "Nombre", "Tipo", "Condición", "Categoría", "Rol a Notificar", "Estado"};
            int colNum = 0;
            for (String header : headers) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }
            
            // Datos de alertas
            for (Object obj : listaAlertas) {
                Row row = sheet.createRow(rowNum++);
                try {
                    // ID
                    int id = (Integer) obj.getClass().getMethod("getIdAlertaConfig").invoke(obj);
                    Cell cell = row.createCell(0);
                    cell.setCellValue(id);
                    cell.setCellStyle(dataStyle);
                    
                    // Nombre
                    String nombre = (String) obj.getClass().getMethod("getNombre").invoke(obj);
                    cell = row.createCell(1);
                    cell.setCellValue(nombre != null ? nombre : "");
                    cell.setCellStyle(dataStyle);
                    
                    // Tipo
                    String tipoAlerta = (String) obj.getClass().getMethod("getTipoAlerta").invoke(obj);
                    String tipoDisplay = tipoAlerta != null ? tipoAlerta : "";
                    // Formatear tipo para mejor legibilidad
                    if (tipoAlerta != null) {
                        switch (tipoAlerta) {
                            case "STOCK_MINIMO_LOTE": tipoDisplay = "Stock Mín. Lote"; break;
                            case "STOCK_CRITICO_LOTE": tipoDisplay = "Stock Crít. Lote"; break;
                            case "STOCK_MINIMO_TOTAL": tipoDisplay = "Stock Mín. Total"; break;
                            case "STOCK_CRITICO_TOTAL": tipoDisplay = "Stock Crít. Total"; break;
                            case "VENCIMIENTO": tipoDisplay = "Vencimiento"; break;
                            case "MOVIMIENTO": tipoDisplay = "Movimiento"; break;
                        }
                    }
                    cell = row.createCell(2);
                    cell.setCellValue(tipoDisplay);
                    cell.setCellStyle(dataStyle);
                    
                    // Condición
                    Integer umbralDias = (Integer) obj.getClass().getMethod("getUmbralDias").invoke(obj);
                    String condicion = "";
                    if (umbralDias != null && tipoAlerta != null && tipoAlerta.equals("VENCIMIENTO")) {
                        condicion = "Vence en " + umbralDias + " días";
                    } else {
                        condicion = "Según configuración";
                    }
                    cell = row.createCell(3);
                    cell.setCellValue(condicion);
                    cell.setCellStyle(dataStyle);
                    
                    // Categoría
                    Object categoriaObj = obj.getClass().getMethod("getCategoria").invoke(obj);
                    String categoriaNombre = "";
                    if (categoriaObj != null) {
                        try {
                            categoriaNombre = (String) categoriaObj.getClass().getMethod("getNombre").invoke(categoriaObj);
                        } catch (Exception e) {
                            // Si no tiene nombre, dejar vacío
                        }
                    }
                    cell = row.createCell(4);
                    cell.setCellValue(categoriaNombre != null ? categoriaNombre : "");
                    cell.setCellStyle(dataStyle);
                    
                    // Rol a Notificar
                    Object rolObj = obj.getClass().getMethod("getRolANotificar").invoke(obj);
                    String rolNombre = "";
                    if (rolObj != null) {
                        try {
                            rolNombre = (String) rolObj.getClass().getMethod("getNombre").invoke(rolObj);
                        } catch (Exception e) {
                            // Si no tiene nombre, dejar vacío
                        }
                    }
                    cell = row.createCell(5);
                    cell.setCellValue(rolNombre != null ? rolNombre : "");
                    cell.setCellStyle(dataStyle);
                    
                    // Estado
                    boolean activo = (Boolean) obj.getClass().getMethod("isActivo").invoke(obj);
                    cell = row.createCell(6);
                    cell.setCellValue(activo ? "Activa" : "Inactiva");
                    cell.setCellStyle(dataStyle);
                    
                } catch (Exception e) {
                    System.err.println("Error al procesar alerta: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            // Ajustar ancho de columnas
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // Agregar un poco más de espacio
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }
            
            // Aplicar filtro automático a los encabezados (en la misma fila de encabezados)
            // headerRowIndex ya fue guardado anteriormente cuando se creó la fila de encabezados
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndex, headerRowIndex, 0, headers.length - 1));
            
            // Congelar paneles (dejar visibles los encabezados al hacer scroll)
            sheet.createFreezePane(0, headerRowIndex + 1);
            
            // Escribir al stream
            workbook.write(outputStream);
        }
    }
    
    /**
     * Genera un archivo Excel con el Inventario General consolidado.
     * Incluye tres hojas separadas: Logística, Almacén y Productores.
     * Cada hoja tiene filtros automáticos y formato profesional.
     * 
     * @param listaLogistica Lista de inventario de logística
     * @param listaAlmacen Lista de lotes del almacén
     * @param listaProductores Lista de productos de productores
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelInventarioGeneral(ArrayList<?> listaLogistica, 
                                                      ArrayList<?> listaAlmacen, 
                                                      ArrayList<?> listaProductores,
                                                      OutputStream outputStream, 
                                                      String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            
            // ========== HOJA 1: LOGÍSTICA ==========
            XSSFSheet sheetLogistica = workbook.createSheet("Logística");
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);
            
            int rowNum = 0;
            
            // Título de la hoja
            Row titleRow = sheetLogistica.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("INVENTARIO LOGÍSTICA - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheetLogistica.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 5));
            
            // Fecha
            Row dateRow = sheetLogistica.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheetLogistica.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 5));
            
            // Fila en blanco
            rowNum++;
            
            // Encabezados Logística - guardar el índice de esta fila para el autoFilter
            int headerRowIndexLogistica = rowNum;
            Row headerRow = sheetLogistica.createRow(rowNum++);
            String[] headersLogistica = {"SKU", "Producto", "Paquetes", "Precio por Paquete", "Costo por Unidad", "Estado"};
            int colNum = 0;
            for (String header : headersLogistica) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }
            
            // Datos Logística
            for (Object obj : listaLogistica) {
                Row row = sheetLogistica.createRow(rowNum++);
                try {
                    Cell cell = row.createCell(0);
                    cell.setCellValue((String) obj.getClass().getMethod("getCodigoSKU").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(1);
                    cell.setCellValue((String) obj.getClass().getMethod("getNombreProducto").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(2);
                    cell.setCellValue((Integer) obj.getClass().getMethod("getPaquetesDisponibles").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(3);
                    cell.setCellValue((Double) obj.getClass().getMethod("getPrecioPorPaquete").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(4);
                    cell.setCellValue((Double) obj.getClass().getMethod("getCostoPorUnidad").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    String estadoStock = (String) obj.getClass().getMethod("getEstadoStock").invoke(obj);
                    cell = row.createCell(5);
                    cell.setCellValue(estadoStock != null ? estadoStock : "");
                    cell.setCellStyle(dataStyle);
                } catch (Exception e) {
                    System.err.println("Error al procesar inventario logística: " + e.getMessage());
                }
            }
            
            // Ajustar columnas y filtros Logística
            // headerRowIndexLogistica ya fue guardado anteriormente cuando se creó la fila de encabezados
            for (int i = 0; i < headersLogistica.length; i++) {
                sheetLogistica.autoSizeColumn(i);
                sheetLogistica.setColumnWidth(i, sheetLogistica.getColumnWidth(i) + 1000);
            }
            sheetLogistica.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndexLogistica, headerRowIndexLogistica, 0, headersLogistica.length - 1));
            sheetLogistica.createFreezePane(0, headerRowIndexLogistica + 1);
            
            // ========== HOJA 2: ALMACÉN ==========
            XSSFSheet sheetAlmacen = workbook.createSheet("Almacén");
            rowNum = 0;
            
            titleRow = sheetAlmacen.createRow(rowNum++);
            titleCell = titleRow.createCell(0);
            titleCell.setCellValue("INVENTARIO ALMACÉN - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheetAlmacen.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 5));
            
            dateRow = sheetAlmacen.createRow(rowNum++);
            dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheetAlmacen.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 5));
            
            // Fila en blanco
            rowNum++;
            
            // Encabezados Almacén - guardar el índice de esta fila para el autoFilter
            int headerRowIndexAlmacen = rowNum;
            headerRow = sheetAlmacen.createRow(rowNum++);
            String[] headersAlmacen = {"Código Lote", "Producto", "Ubicación", "Stock", "Vencimiento", "Estado"};
            colNum = 0;
            for (String header : headersAlmacen) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }
            
            // Datos Almacén
            for (Object obj : listaAlmacen) {
                Row row = sheetAlmacen.createRow(rowNum++);
                try {
                    Cell cell = row.createCell(0);
                    cell.setCellValue((String) obj.getClass().getMethod("getCodigoLote").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(1);
                    cell.setCellValue((String) obj.getClass().getMethod("getNombreProducto").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(2);
                    cell.setCellValue((String) obj.getClass().getMethod("getNombreUbicacion").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(3);
                    cell.setCellValue((Integer) obj.getClass().getMethod("getStockActual").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    java.sql.Date fechaVenc = (java.sql.Date) obj.getClass().getMethod("getFechaVencimiento").invoke(obj);
                    cell = row.createCell(4);
                    if (fechaVenc != null) {
                        cell.setCellValue(new java.text.SimpleDateFormat("dd/MM/yyyy").format(fechaVenc));
                    } else {
                        cell.setCellValue("");
                    }
                    cell.setCellStyle(dataStyle);
                    
                    String estado = (String) obj.getClass().getMethod("getEstado").invoke(obj);
                    cell = row.createCell(5);
                    cell.setCellValue(estado != null ? estado : "");
                    cell.setCellStyle(dataStyle);
                } catch (Exception e) {
                    System.err.println("Error al procesar lote almacén: " + e.getMessage());
                }
            }
            
            // Ajustar columnas y filtros Almacén
            // headerRowIndexAlmacen ya fue guardado anteriormente cuando se creó la fila de encabezados
            for (int i = 0; i < headersAlmacen.length; i++) {
                sheetAlmacen.autoSizeColumn(i);
                sheetAlmacen.setColumnWidth(i, sheetAlmacen.getColumnWidth(i) + 1000);
            }
            sheetAlmacen.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndexAlmacen, headerRowIndexAlmacen, 0, headersAlmacen.length - 1));
            sheetAlmacen.createFreezePane(0, headerRowIndexAlmacen + 1);
            
            // ========== HOJA 3: PRODUCTORES ==========
            XSSFSheet sheetProductores = workbook.createSheet("Productores");
            rowNum = 0;
            
            titleRow = sheetProductores.createRow(rowNum++);
            titleCell = titleRow.createCell(0);
            titleCell.setCellValue("INVENTARIO PRODUCTORES - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheetProductores.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 3));
            
            dateRow = sheetProductores.createRow(rowNum++);
            dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheetProductores.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 3));
            
            // Fila en blanco
            rowNum++;
            
            // Encabezados Productores - guardar el índice de esta fila para el autoFilter
            int headerRowIndexProductores = rowNum;
            headerRow = sheetProductores.createRow(rowNum++);
            String[] headersProductores = {"SKU", "Producto", "Categoría", "Stock Total"};
            colNum = 0;
            for (String header : headersProductores) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }
            
            // Datos Productores
            for (Object obj : listaProductores) {
                Row row = sheetProductores.createRow(rowNum++);
                try {
                    Cell cell = row.createCell(0);
                    cell.setCellValue((String) obj.getClass().getMethod("getCodigoSku").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(1);
                    cell.setCellValue((String) obj.getClass().getMethod("getNombre").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    String categoriaNombre = (String) obj.getClass().getMethod("getCategoriaNombre").invoke(obj);
                    cell = row.createCell(2);
                    cell.setCellValue(categoriaNombre != null ? categoriaNombre : "");
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(3);
                    cell.setCellValue((Integer) obj.getClass().getMethod("getStock").invoke(obj));
                    cell.setCellStyle(dataStyle);
                } catch (Exception e) {
                    System.err.println("Error al procesar producto: " + e.getMessage());
                }
            }
            
            // Ajustar columnas y filtros Productores
            // headerRowIndexProductores ya fue guardado anteriormente cuando se creó la fila de encabezados
            for (int i = 0; i < headersProductores.length; i++) {
                sheetProductores.autoSizeColumn(i);
                sheetProductores.setColumnWidth(i, sheetProductores.getColumnWidth(i) + 1000);
            }
            sheetProductores.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndexProductores, headerRowIndexProductores, 0, headersProductores.length - 1));
            sheetProductores.createFreezePane(0, headerRowIndexProductores + 1);
            
            // Escribir al stream
            workbook.write(outputStream);
        }
    }
    
    /**
     * Genera un archivo Excel con la lista de configuraciones de Stock Mínimo.
     * Incluye filtros automáticos en las columnas y formato profesional.
     *
     * @param listaStockMinimo Lista de configuraciones de stock mínimo a exportar
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelStockMinimo(ArrayList<?> listaStockMinimo, OutputStream outputStream, String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            // Crear hoja de cálculo
            XSSFSheet sheet = workbook.createSheet("Stock Mínimo");

            // Crear estilos
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);

            int rowNum = 0;

            // Título del reporte
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("REPORTE DE STOCK MÍNIMO - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 7));

            // Fecha de generación
            Row dateRow = sheet.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 7));

            // Filtros aplicados (si existen)
            if (filtrosInformacion != null && !filtrosInformacion.trim().isEmpty()) {
                Row filterRow = sheet.createRow(rowNum++);
                Cell filterCell = filterRow.createCell(0);
                filterCell.setCellValue("Filtros aplicados: " + filtrosInformacion);
                filterCell.setCellStyle(dataStyle);
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 7));
            }

            // Fila en blanco
            rowNum++;

            // Encabezados - guardar el índice de esta fila para el autoFilter
            int headerRowIndex = rowNum;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"Producto", "Código", "Stock Mín. Lote", "Stock Crít. Lote", "Stock Mín. Total", "Stock Crít. Total", "Estado", "Última Actualización"};
            int colNum = 0;
            for (String header : headers) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }

            // Datos de configuraciones de stock mínimo
            for (Object obj : listaStockMinimo) {
                Row row = sheet.createRow(rowNum++);
                try {
                    // Producto (nombre)
                    Object productoObj = obj.getClass().getMethod("getProducto").invoke(obj);
                    String nombreProducto = "";
                    if (productoObj != null) {
                        nombreProducto = (String) productoObj.getClass().getMethod("getNombre").invoke(productoObj);
                    }
                    Cell cell = row.createCell(0);
                    cell.setCellValue(nombreProducto != null ? nombreProducto : "");
                    cell.setCellStyle(dataStyle);

                    // Código (SKU)
                    String codigoSku = "";
                    if (productoObj != null) {
                        codigoSku = (String) productoObj.getClass().getMethod("getCodigoSku").invoke(productoObj);
                    }
                    cell = row.createCell(1);
                    cell.setCellValue(codigoSku != null ? codigoSku : "");
                    cell.setCellStyle(dataStyle);

                    // Stock Mínimo Lote
                    int stockMinimoLote = (Integer) obj.getClass().getMethod("getStockMinimoLote").invoke(obj);
                    cell = row.createCell(2);
                    cell.setCellValue(stockMinimoLote);
                    cell.setCellStyle(dataStyle);

                    // Stock Crítico Lote
                    int stockCriticoLote = (Integer) obj.getClass().getMethod("getStockCriticoLote").invoke(obj);
                    cell = row.createCell(3);
                    cell.setCellValue(stockCriticoLote);
                    cell.setCellStyle(dataStyle);

                    // Stock Mínimo Total (Producto)
                    int stockMinimoProducto = (Integer) obj.getClass().getMethod("getStockMinimoProducto").invoke(obj);
                    cell = row.createCell(4);
                    cell.setCellValue(stockMinimoProducto);
                    cell.setCellStyle(dataStyle);

                    // Stock Crítico Total (Producto)
                    int stockCriticoProducto = (Integer) obj.getClass().getMethod("getStockCriticoProducto").invoke(obj);
                    cell = row.createCell(5);
                    cell.setCellValue(stockCriticoProducto);
                    cell.setCellStyle(dataStyle);

                    // Estado
                    boolean activo = (Boolean) obj.getClass().getMethod("isActivo").invoke(obj);
                    cell = row.createCell(6);
                    cell.setCellValue(activo ? "Activo" : "Inactivo");
                    cell.setCellStyle(dataStyle);

                    // Última Actualización
                    java.sql.Timestamp fechaActualizacion = (java.sql.Timestamp) obj.getClass().getMethod("getFechaActualizacion").invoke(obj);
                    cell = row.createCell(7);
                    if (fechaActualizacion != null) {
                        cell.setCellValue(new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(fechaActualizacion));
                    } else {
                        cell.setCellValue("");
                    }
                    cell.setCellStyle(dataStyle);

                } catch (Exception e) {
                    System.err.println("Error al procesar configuración de stock mínimo: " + e.getMessage());
                    e.printStackTrace();
                }
            }

            // Ajustar ancho de columnas
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // Agregar un poco más de espacio
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }

            // Aplicar filtro automático a los encabezados (en la misma fila de encabezados)
            // headerRowIndex ya fue guardado anteriormente cuando se creó la fila de encabezados
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndex, headerRowIndex, 0, headers.length - 1));

            // Congelar paneles (dejar visibles los encabezados al hacer scroll)
            sheet.createFreezePane(0, headerRowIndex + 1);

            // Escribir al stream
            workbook.write(outputStream);
        }
    }

    /**
     * Genera un archivo Excel con el inventario de logística.
     * Incluye filtros automáticos en las columnas y formato profesional.
     * 
     * @param listaInventario Lista de inventario a exportar
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelInventarioLogistica(ArrayList<?> listaInventario, 
                                                       OutputStream outputStream, 
                                                       String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            // Crear hoja de cálculo
            XSSFSheet sheet = workbook.createSheet("Inventario Logística");

            // Crear estilos
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);
            CellStyle currencyStyle = crearEstiloMoneda(workbook);

            int rowNum = 0;

            // Título del reporte
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("REPORTE DE INVENTARIO LOGÍSTICA - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 6));

            // Fecha de generación
            Row dateRow = sheet.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 6));

            // Filtros aplicados (si existen)
            if (filtrosInformacion != null && !filtrosInformacion.trim().isEmpty()) {
                Row filterRow = sheet.createRow(rowNum++);
                Cell filterCell = filterRow.createCell(0);
                filterCell.setCellValue("Filtros aplicados: " + filtrosInformacion);
                filterCell.setCellStyle(dataStyle);
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 6));
            }

            // Fila en blanco
            rowNum++;

            // Encabezados - guardar el índice de esta fila para el autoFilter
            int headerRowIndex = rowNum;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"SKU", "Nombre Producto", "Paquetes Disponibles", 
                               "Precio por Paquete", "Costo por Unidad", "Estado de Stock", "Valor Total"};
            int colNum = 0;
            for (String header : headers) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }

            // Datos de inventario
            double valorTotalGeneral = 0.0;
            for (Object obj : listaInventario) {
                Row row = sheet.createRow(rowNum++);
                try {
                    // SKU
                    Cell cell = row.createCell(0);
                    cell.setCellValue((String) obj.getClass().getMethod("getCodigoSKU").invoke(obj));
                    cell.setCellStyle(dataStyle);

                    // Nombre Producto
                    cell = row.createCell(1);
                    cell.setCellValue((String) obj.getClass().getMethod("getNombreProducto").invoke(obj));
                    cell.setCellStyle(dataStyle);

                    // Paquetes Disponibles
                    int paquetes = (Integer) obj.getClass().getMethod("getPaquetesDisponibles").invoke(obj);
                    cell = row.createCell(2);
                    cell.setCellValue(paquetes);
                    cell.setCellStyle(dataStyle);

                    // Precio por Paquete
                    double precioPorPaquete = (Double) obj.getClass().getMethod("getPrecioPorPaquete").invoke(obj);
                    cell = row.createCell(3);
                    cell.setCellValue(precioPorPaquete);
                    cell.setCellStyle(currencyStyle);

                    // Costo por Unidad
                    double costoPorUnidad = (Double) obj.getClass().getMethod("getCostoPorUnidad").invoke(obj);
                    cell = row.createCell(4);
                    cell.setCellValue(costoPorUnidad);
                    cell.setCellStyle(currencyStyle);

                    // Estado de Stock
                    String estadoStock = (String) obj.getClass().getMethod("getEstadoStock").invoke(obj);
                    cell = row.createCell(5);
                    cell.setCellValue(estadoStock != null ? estadoStock : "");
                    cell.setCellStyle(dataStyle);

                    // Valor Total (Paquetes × Precio)
                    double valorTotal = paquetes * precioPorPaquete;
                    valorTotalGeneral += valorTotal;
                    cell = row.createCell(6);
                    cell.setCellValue(valorTotal);
                    cell.setCellStyle(currencyStyle);

                } catch (Exception e) {
                    System.err.println("Error al procesar inventario: " + e.getMessage());
                    e.printStackTrace();
                }
            }

            // Fila de totales
            rowNum++;
            Row totalRow = sheet.createRow(rowNum++);
            Cell totalLabelCell = totalRow.createCell(0);
            totalLabelCell.setCellValue("TOTAL GENERAL:");
            totalLabelCell.setCellStyle(headerStyle);
            
            Cell totalValueCell = totalRow.createCell(6);
            totalValueCell.setCellValue(valorTotalGeneral);
            totalValueCell.setCellStyle(currencyStyle);

            // Ajustar ancho de columnas
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // Agregar un poco más de espacio
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }

            // Aplicar filtro automático a los encabezados (en la misma fila de encabezados)
            // headerRowIndex ya fue guardado anteriormente cuando se creó la fila de encabezados
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndex, headerRowIndex, 0, headers.length - 1));

            // Congelar paneles (dejar visibles los encabezados al hacer scroll)
            sheet.createFreezePane(0, headerRowIndex + 1);

            // Escribir al stream
            workbook.write(outputStream);
        }
    }

    /**
     * Genera un archivo Excel con las órdenes de compra del módulo de almacén.
     * Incluye filtros automáticos en las columnas y formato profesional.
     * 
     * @param listaOrdenes Lista de órdenes de compra a exportar
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelOrdenesCompra(ArrayList<?> listaOrdenes, 
                                                 OutputStream outputStream, 
                                                 String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            // Crear hoja de cálculo
            XSSFSheet sheet = workbook.createSheet("Órdenes de Compra");

            // Crear estilos
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);
            CellStyle currencyStyle = crearEstiloMoneda(workbook);

            int rowNum = 0;

            // Título del reporte
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("REPORTE DE ÓRDENES DE COMPRA - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 8));

            // Fecha de generación
            Row dateRow = sheet.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 8));

            // Filtros aplicados (si existen)
            if (filtrosInformacion != null && !filtrosInformacion.trim().isEmpty()) {
                Row filterRow = sheet.createRow(rowNum++);
                Cell filterCell = filterRow.createCell(0);
                filterCell.setCellValue("Filtros aplicados: " + filtrosInformacion);
                filterCell.setCellStyle(dataStyle);
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 8));
            }

            // Fila en blanco
            rowNum++;

            // Encabezados - guardar el índice de esta fila para el autoFilter
            int headerRowIndex = rowNum;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"N° de Orden", "SKU", "Producto", "Proveedor", "Cantidad", 
                               "Costo Total", "Fecha Pedido", "Fecha Entrega", "Estado"};
            int colNum = 0;
            for (String header : headers) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }

            // Datos de órdenes usando el bean de almacén OrdenCompra
            double montoTotalGeneral = 0.0;
            for (Object obj : listaOrdenes) {
                Row row = sheet.createRow(rowNum++);
                try {
                    com.example.telito.almacen.beans.OrdenCompra orden = (com.example.telito.almacen.beans.OrdenCompra) obj;
                    
                    // N° de Orden
                    Cell cell = row.createCell(0);
                    cell.setCellValue(orden.getNumeroOrden() != null ? orden.getNumeroOrden() : "");
                    cell.setCellStyle(dataStyle);

                    // SKU del Producto
                    cell = row.createCell(1);
                    cell.setCellValue(orden.getProductoSku() != null ? orden.getProductoSku() : "");
                    cell.setCellStyle(dataStyle);

                    // Producto
                    cell = row.createCell(2);
                    cell.setCellValue(orden.getNombreProducto() != null ? orden.getNombreProducto() : "");
                    cell.setCellStyle(dataStyle);

                    // Proveedor
                    cell = row.createCell(3);
                    cell.setCellValue(orden.getNombreProveedor() != null ? orden.getNombreProveedor() : "");
                    cell.setCellStyle(dataStyle);

                    // Cantidad
                    cell = row.createCell(4);
                    cell.setCellValue(orden.getCantidad());
                    cell.setCellStyle(dataStyle);

                    // Costo Total
                    double monto = 0.0;
                    if (orden.getCostoTotal() != null) {
                        monto = orden.getCostoTotal().doubleValue();
                        montoTotalGeneral += monto;
                    }
                    cell = row.createCell(5);
                    cell.setCellValue(monto);
                    cell.setCellStyle(currencyStyle);

                    // Fecha de Pedido
                    cell = row.createCell(6);
                    if (orden.getFechaPedido() != null) {
                        cell.setCellValue(new java.text.SimpleDateFormat("dd/MM/yyyy").format(orden.getFechaPedido()));
                    } else {
                        cell.setCellValue("");
                    }
                    cell.setCellStyle(dataStyle);

                    // Fecha de Entrega Esperada
                    cell = row.createCell(7);
                    if (orden.getFechaEntregaEsperada() != null) {
                        cell.setCellValue(new java.text.SimpleDateFormat("dd/MM/yyyy").format(orden.getFechaEntregaEsperada()));
                    } else {
                        cell.setCellValue("");
                    }
                    cell.setCellStyle(dataStyle);

                    // Estado
                    cell = row.createCell(8);
                    cell.setCellValue(orden.getEstado() != null ? orden.getEstado() : "");
                    cell.setCellStyle(dataStyle);

                } catch (Exception e) {
                    System.err.println("Error al procesar orden de compra: " + e.getMessage());
                    e.printStackTrace();
                }
            }

            // Fila de totales
            rowNum++;
            Row totalRow = sheet.createRow(rowNum++);
            Cell totalLabelCell = totalRow.createCell(0);
            totalLabelCell.setCellValue("TOTAL GENERAL:");
            totalLabelCell.setCellStyle(headerStyle);
            
            Cell totalValueCell = totalRow.createCell(5);
            totalValueCell.setCellValue(montoTotalGeneral);
            totalValueCell.setCellStyle(currencyStyle);

            // Ajustar ancho de columnas
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // Agregar un poco más de espacio
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }

            // Aplicar filtro automático a los encabezados (en la misma fila de encabezados)
            // headerRowIndex ya fue guardado anteriormente cuando se creó la fila de encabezados
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndex, headerRowIndex, 0, headers.length - 1));

            // Congelar paneles (dejar visibles los encabezados al hacer scroll)
            sheet.createFreezePane(0, headerRowIndex + 1);

            // Escribir al stream
            workbook.write(outputStream);
        }
    }

    /**
     * Genera un archivo Excel con los movimientos de inventario.
     * Incluye filtros automáticos en las columnas y formato profesional.
     * Incluye totales por tipo de movimiento.
     * 
     * @param listaMovimientos Lista de movimientos de inventario a exportar
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelMovimientosInventario(ArrayList<?> listaMovimientos, 
                                                         OutputStream outputStream, 
                                                         String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            // Crear hoja de cálculo
            XSSFSheet sheet = workbook.createSheet("Movimientos Inventario");

            // Crear estilos
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);
            CellStyle summaryStyle = crearEstiloResumen(workbook);

            int rowNum = 0;

            // Título del reporte
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("REPORTE DE MOVIMIENTOS DE INVENTARIO - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 7));

            // Fecha de generación
            Row dateRow = sheet.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 7));

            // Filtros aplicados (si existen)
            if (filtrosInformacion != null && !filtrosInformacion.trim().isEmpty()) {
                Row filterRow = sheet.createRow(rowNum++);
                Cell filterCell = filterRow.createCell(0);
                filterCell.setCellValue("Filtros aplicados: " + filtrosInformacion);
                filterCell.setCellStyle(dataStyle);
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 7));
            }

            // Fila en blanco
            rowNum++;

            // Encabezados - guardar el índice de esta fila para el autoFilter
            int headerRowIndex = rowNum;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"Fecha", "Producto", "Tipo de Movimiento", "Cantidad", 
                               "Lote", "Destino/Origen", "Personal Responsable", "Observaciones"};
            int colNum = 0;
            for (String header : headers) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }

            // Datos de movimientos y contadores por tipo
            int totalEntradas = 0;
            int totalSalidas = 0;
            int totalAjustes = 0;
            int cantidadTotalEntradas = 0;
            int cantidadTotalSalidas = 0;
            int cantidadTotalAjustes = 0;

            for (Object obj : listaMovimientos) {
                Row row = sheet.createRow(rowNum++);
                try {
                    // Fecha
                    Cell cell = row.createCell(0);
                    cell.setCellValue((String) obj.getClass().getMethod("getFechaFormateada").invoke(obj));
                    cell.setCellStyle(dataStyle);

                    // Producto
                    cell = row.createCell(1);
                    cell.setCellValue((String) obj.getClass().getMethod("getNombreProducto").invoke(obj));
                    cell.setCellStyle(dataStyle);

                    // Tipo de Movimiento
                    String tipo = (String) obj.getClass().getMethod("getTipo").invoke(obj);
                    cell = row.createCell(2);
                    cell.setCellValue(tipo != null ? tipo : "");
                    cell.setCellStyle(dataStyle);

                    // Contar por tipo y sumar cantidades
                    if (tipo != null) {
                        if (tipo.equalsIgnoreCase("Entrada")) {
                            totalEntradas++;
                        } else if (tipo.equalsIgnoreCase("Salida")) {
                            totalSalidas++;
                        } else if (tipo.equalsIgnoreCase("Ajuste")) {
                            totalAjustes++;
                        }
                    }

                    // Cantidad
                    int cantidad = (Integer) obj.getClass().getMethod("getCantidad").invoke(obj);
                    cell = row.createCell(3);
                    cell.setCellValue(cantidad);
                    cell.setCellStyle(dataStyle);

                    // Sumar cantidades por tipo
                    if (tipo != null) {
                        if (tipo.equalsIgnoreCase("Entrada")) {
                            cantidadTotalEntradas += cantidad;
                        } else if (tipo.equalsIgnoreCase("Salida")) {
                            cantidadTotalSalidas += cantidad;
                        } else if (tipo.equalsIgnoreCase("Ajuste")) {
                            cantidadTotalAjustes += cantidad;
                        }
                    }

                    // Lote
                    cell = row.createCell(4);
                    cell.setCellValue((String) obj.getClass().getMethod("getCodigoLote").invoke(obj));
                    cell.setCellStyle(dataStyle);

                    // Destino/Origen
                    cell = row.createCell(5);
                    cell.setCellValue((String) obj.getClass().getMethod("getDestino").invoke(obj));
                    cell.setCellStyle(dataStyle);

                    // Personal Responsable
                    cell = row.createCell(6);
                    cell.setCellValue((String) obj.getClass().getMethod("getResponsable").invoke(obj));
                    cell.setCellStyle(dataStyle);

                    // Observaciones
                    cell = row.createCell(7);
                    cell.setCellValue((String) obj.getClass().getMethod("getObservaciones").invoke(obj));
                    cell.setCellStyle(dataStyle);

                } catch (Exception e) {
                    System.err.println("Error al procesar movimiento: " + e.getMessage());
                    e.printStackTrace();
                }
            }

            // Fila en blanco
            rowNum++;

            // Sección de resumen por tipo
            Row summaryTitleRow = sheet.createRow(rowNum++);
            Cell summaryTitleCell = summaryTitleRow.createCell(0);
            summaryTitleCell.setCellValue("RESUMEN POR TIPO DE MOVIMIENTO:");
            summaryTitleCell.setCellStyle(summaryStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 7));

            // Entradas
            Row entradaRow = sheet.createRow(rowNum++);
            Cell entradaLabelCell = entradaRow.createCell(0);
            entradaLabelCell.setCellValue("Entradas:");
            entradaLabelCell.setCellStyle(summaryStyle);
            Cell entradaCantidadCell = entradaRow.createCell(2);
            entradaCantidadCell.setCellValue("Cantidad: " + cantidadTotalEntradas);
            entradaCantidadCell.setCellStyle(summaryStyle);
            Cell entradaTotalCell = entradaRow.createCell(4);
            entradaTotalCell.setCellValue("Total registros: " + totalEntradas);
            entradaTotalCell.setCellStyle(summaryStyle);

            // Salidas
            Row salidaRow = sheet.createRow(rowNum++);
            Cell salidaLabelCell = salidaRow.createCell(0);
            salidaLabelCell.setCellValue("Salidas:");
            salidaLabelCell.setCellStyle(summaryStyle);
            Cell salidaCantidadCell = salidaRow.createCell(2);
            salidaCantidadCell.setCellValue("Cantidad: " + cantidadTotalSalidas);
            salidaCantidadCell.setCellStyle(summaryStyle);
            Cell salidaTotalCell = salidaRow.createCell(4);
            salidaTotalCell.setCellValue("Total registros: " + totalSalidas);
            salidaTotalCell.setCellStyle(summaryStyle);

            // Ajustes
            Row ajusteRow = sheet.createRow(rowNum++);
            Cell ajusteLabelCell = ajusteRow.createCell(0);
            ajusteLabelCell.setCellValue("Ajustes:");
            ajusteLabelCell.setCellStyle(summaryStyle);
            Cell ajusteCantidadCell = ajusteRow.createCell(2);
            ajusteCantidadCell.setCellValue("Cantidad: " + cantidadTotalAjustes);
            ajusteCantidadCell.setCellStyle(summaryStyle);
            Cell ajusteTotalCell = ajusteRow.createCell(4);
            ajusteTotalCell.setCellValue("Total registros: " + totalAjustes);
            ajusteTotalCell.setCellStyle(summaryStyle);

            // Total general
            rowNum++;
            Row totalGeneralRow = sheet.createRow(rowNum++);
            Cell totalGeneralLabelCell = totalGeneralRow.createCell(0);
            totalGeneralLabelCell.setCellValue("TOTAL GENERAL:");
            totalGeneralLabelCell.setCellStyle(headerStyle);
            Cell totalGeneralCantidadCell = totalGeneralRow.createCell(2);
            totalGeneralCantidadCell.setCellValue("Cantidad total: " + (cantidadTotalEntradas + cantidadTotalSalidas + cantidadTotalAjustes));
            totalGeneralCantidadCell.setCellStyle(headerStyle);
            Cell totalGeneralRegistrosCell = totalGeneralRow.createCell(4);
            totalGeneralRegistrosCell.setCellValue("Total registros: " + listaMovimientos.size());
            totalGeneralRegistrosCell.setCellStyle(headerStyle);

            // Ajustar ancho de columnas
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // Agregar un poco más de espacio
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }

            // Aplicar filtro automático a los encabezados (en la misma fila de encabezados)
            // headerRowIndex ya fue guardado anteriormente cuando se creó la fila de encabezados
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndex, headerRowIndex, 0, headers.length - 1));

            // Congelar paneles (dejar visibles los encabezados al hacer scroll)
            sheet.createFreezePane(0, headerRowIndex + 1);

            // Escribir al stream
            workbook.write(outputStream);
        }
    }

    /**
     * Crea un estilo de celda para valores monetarios.
     */
    private static CellStyle crearEstiloMoneda(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setFontHeightInPoints((short) 11);
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.RIGHT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setDataFormat(workbook.getCreationHelper().createDataFormat().getFormat("#,##0.00"));
        return style;
    }

    /**
     * Crea un estilo de celda para resúmenes y totales.
     */
    private static CellStyle crearEstiloResumen(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 11);
        font.setColor(IndexedColors.DARK_GREEN.getIndex());
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.LEFT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setFillForegroundColor(IndexedColors.LIGHT_GREEN.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return style;
    }

    /**
     * Genera un archivo Excel con los planes de distribución y transporte.
     * Incluye filtros automáticos en las columnas y formato profesional.
     * Incluye estadísticas por conductor y vehículo.
     * 
     * @param listaPlanes Lista de planes de transporte agrupados por viaje
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelDistribucionTransporte(ArrayList<?> listaPlanes, 
                                                         OutputStream outputStream, 
                                                         String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            // Crear hoja de cálculo principal
            XSSFSheet sheet = workbook.createSheet("Distribución y Transporte");

            // Crear estilos
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);
            CellStyle summaryStyle = crearEstiloResumen(workbook);

            int rowNum = 0;

            // Título del reporte
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("REPORTE DE DISTRIBUCIÓN Y TRANSPORTE - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 7));

            // Fecha de generación
            Row dateRow = sheet.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 7));

            // Filtros aplicados (si existen)
            if (filtrosInformacion != null && !filtrosInformacion.trim().isEmpty()) {
                Row filterRow = sheet.createRow(rowNum++);
                Cell filterCell = filterRow.createCell(0);
                filterCell.setCellValue("Filtros aplicados: " + filtrosInformacion);
                filterCell.setCellStyle(dataStyle);
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 7));
            }

            // Fila en blanco
            rowNum++;

            // Encabezados - guardar el índice de esta fila para el autoFilter
            int headerRowIndex = rowNum;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"N° Viaje", "Conductor", "Vehículo (Placa)", "Fecha Salida", 
                               "Fecha Entrega Estimada", "Estado", "Destino/Distrito", "Cantidad de Lotes"};
            int colNum = 0;
            for (String header : headers) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }

            // Mapas para estadísticas
            java.util.Map<String, Integer> viajesPorConductor = new java.util.HashMap<>();
            java.util.Map<String, Integer> lotesPorConductor = new java.util.HashMap<>();
            java.util.Map<String, Integer> viajesPorVehiculo = new java.util.HashMap<>();
            java.util.Map<String, Integer> lotesPorVehiculo = new java.util.HashMap<>();
            java.util.Map<String, Integer> viajesPorEstado = new java.util.HashMap<>();

            // Datos de planes
            int totalViajes = 0;
            int totalLotes = 0;

            for (Object obj : listaPlanes) {
                Row row = sheet.createRow(rowNum++);
                try {
                    // N° Viaje
                    Cell cell = row.createCell(0);
                    cell.setCellValue((String) obj.getClass().getMethod("getNumeroViaje").invoke(obj));
                    cell.setCellStyle(dataStyle);

                    // Conductor
                    String conductor = (String) obj.getClass().getMethod("getNombreConductor").invoke(obj);
                    cell = row.createCell(1);
                    cell.setCellValue(conductor != null ? conductor : "");
                    cell.setCellStyle(dataStyle);

                    // Vehículo (Placa)
                    String placa = (String) obj.getClass().getMethod("getPlacaVehiculo").invoke(obj);
                    cell = row.createCell(2);
                    cell.setCellValue(placa != null ? placa : "");
                    cell.setCellStyle(dataStyle);

                    // Fecha Salida
                    String fechaSalida = (String) obj.getClass().getMethod("getFechaSalida").invoke(obj);
                    cell = row.createCell(3);
                    cell.setCellValue(fechaSalida != null ? fechaSalida : "N/A");
                    cell.setCellStyle(dataStyle);

                    // Fecha Entrega Estimada
                    String fechaEntrega = (String) obj.getClass().getMethod("getFechaEntrega").invoke(obj);
                    cell = row.createCell(4);
                    cell.setCellValue(fechaEntrega != null ? fechaEntrega : "");
                    cell.setCellStyle(dataStyle);

                    // Estado
                    String estado = (String) obj.getClass().getMethod("getEstado").invoke(obj);
                    cell = row.createCell(5);
                    cell.setCellValue(estado != null ? estado : "");
                    cell.setCellStyle(dataStyle);

                    // Destino/Distrito
                    String destino = (String) obj.getClass().getMethod("getNombreDestino").invoke(obj);
                    cell = row.createCell(6);
                    cell.setCellValue(destino != null ? destino : "");
                    cell.setCellStyle(dataStyle);

                    // Cantidad de Lotes
                    int cantidadLotes = (Integer) obj.getClass().getMethod("getCantidadLotes").invoke(obj);
                    cell = row.createCell(7);
                    cell.setCellValue(cantidadLotes);
                    cell.setCellStyle(dataStyle);

                    // Acumular estadísticas
                    totalViajes++;
                    totalLotes += cantidadLotes;

                    if (conductor != null) {
                        viajesPorConductor.put(conductor, viajesPorConductor.getOrDefault(conductor, 0) + 1);
                        lotesPorConductor.put(conductor, lotesPorConductor.getOrDefault(conductor, 0) + cantidadLotes);
                    }

                    if (placa != null) {
                        viajesPorVehiculo.put(placa, viajesPorVehiculo.getOrDefault(placa, 0) + 1);
                        lotesPorVehiculo.put(placa, lotesPorVehiculo.getOrDefault(placa, 0) + cantidadLotes);
                    }

                    if (estado != null) {
                        viajesPorEstado.put(estado, viajesPorEstado.getOrDefault(estado, 0) + 1);
                    }

                } catch (Exception e) {
                    System.err.println("Error al procesar plan: " + e.getMessage());
                    e.printStackTrace();
                }
            }

            // Fila en blanco
            rowNum++;

            // Sección de estadísticas por conductor
            Row statsTitleRow = sheet.createRow(rowNum++);
            Cell statsTitleCell = statsTitleRow.createCell(0);
            statsTitleCell.setCellValue("ESTADÍSTICAS POR CONDUCTOR:");
            statsTitleCell.setCellStyle(summaryStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 7));

            // Encabezados de estadísticas de conductor
            Row statsHeaderRow = sheet.createRow(rowNum++);
            Cell statsHeaderCell1 = statsHeaderRow.createCell(0);
            statsHeaderCell1.setCellValue("Conductor");
            statsHeaderCell1.setCellStyle(headerStyle);
            Cell statsHeaderCell2 = statsHeaderRow.createCell(1);
            statsHeaderCell2.setCellValue("Viajes");
            statsHeaderCell2.setCellStyle(headerStyle);
            Cell statsHeaderCell3 = statsHeaderRow.createCell(2);
            statsHeaderCell3.setCellValue("Total Lotes");
            statsHeaderCell3.setCellStyle(headerStyle);

            // Datos de estadísticas por conductor
            for (java.util.Map.Entry<String, Integer> entry : viajesPorConductor.entrySet().stream()
                    .sorted((a, b) -> b.getValue().compareTo(a.getValue())).toList()) {
                Row statsRow = sheet.createRow(rowNum++);
                Cell cell = statsRow.createCell(0);
                cell.setCellValue(entry.getKey());
                cell.setCellStyle(summaryStyle);
                cell = statsRow.createCell(1);
                cell.setCellValue(entry.getValue());
                cell.setCellStyle(summaryStyle);
                cell = statsRow.createCell(2);
                cell.setCellValue(lotesPorConductor.getOrDefault(entry.getKey(), 0));
                cell.setCellStyle(summaryStyle);
            }

            // Fila en blanco
            rowNum++;

            // Sección de estadísticas por vehículo
            Row vehiculoTitleRow = sheet.createRow(rowNum++);
            Cell vehiculoTitleCell = vehiculoTitleRow.createCell(0);
            vehiculoTitleCell.setCellValue("ESTADÍSTICAS POR VEHÍCULO:");
            vehiculoTitleCell.setCellStyle(summaryStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 7));

            // Encabezados de estadísticas de vehículo
            Row vehiculoHeaderRow = sheet.createRow(rowNum++);
            Cell vehiculoHeaderCell1 = vehiculoHeaderRow.createCell(0);
            vehiculoHeaderCell1.setCellValue("Vehículo (Placa)");
            vehiculoHeaderCell1.setCellStyle(headerStyle);
            Cell vehiculoHeaderCell2 = vehiculoHeaderRow.createCell(1);
            vehiculoHeaderCell2.setCellValue("Viajes");
            vehiculoHeaderCell2.setCellStyle(headerStyle);
            Cell vehiculoHeaderCell3 = vehiculoHeaderRow.createCell(2);
            vehiculoHeaderCell3.setCellValue("Total Lotes");
            vehiculoHeaderCell3.setCellStyle(headerStyle);

            // Datos de estadísticas por vehículo
            for (java.util.Map.Entry<String, Integer> entry : viajesPorVehiculo.entrySet().stream()
                    .sorted((a, b) -> b.getValue().compareTo(a.getValue())).toList()) {
                Row vehiculoRow = sheet.createRow(rowNum++);
                Cell cell = vehiculoRow.createCell(0);
                cell.setCellValue(entry.getKey());
                cell.setCellStyle(summaryStyle);
                cell = vehiculoRow.createCell(1);
                cell.setCellValue(entry.getValue());
                cell.setCellStyle(summaryStyle);
                cell = vehiculoRow.createCell(2);
                cell.setCellValue(lotesPorVehiculo.getOrDefault(entry.getKey(), 0));
                cell.setCellStyle(summaryStyle);
            }

            // Fila en blanco
            rowNum++;

            // Resumen por estado
            Row estadoTitleRow = sheet.createRow(rowNum++);
            Cell estadoTitleCell = estadoTitleRow.createCell(0);
            estadoTitleCell.setCellValue("RESUMEN POR ESTADO:");
            estadoTitleCell.setCellStyle(summaryStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 7));

            // Datos de resumen por estado
            for (java.util.Map.Entry<String, Integer> entry : viajesPorEstado.entrySet()) {
                Row estadoRow = sheet.createRow(rowNum++);
                Cell cell = estadoRow.createCell(0);
                cell.setCellValue(entry.getKey() + ":");
                cell.setCellStyle(summaryStyle);
                cell = estadoRow.createCell(1);
                cell.setCellValue(entry.getValue() + " viajes");
                cell.setCellStyle(summaryStyle);
            }

            // Total general
            rowNum++;
            Row totalGeneralRow = sheet.createRow(rowNum++);
            Cell totalGeneralLabelCell = totalGeneralRow.createCell(0);
            totalGeneralLabelCell.setCellValue("TOTAL GENERAL:");
            totalGeneralLabelCell.setCellStyle(headerStyle);
            Cell totalGeneralViajesCell = totalGeneralRow.createCell(2);
            totalGeneralViajesCell.setCellValue("Total Viajes: " + totalViajes);
            totalGeneralViajesCell.setCellStyle(headerStyle);
            Cell totalGeneralLotesCell = totalGeneralRow.createCell(4);
            totalGeneralLotesCell.setCellValue("Total Lotes: " + totalLotes);
            totalGeneralLotesCell.setCellStyle(headerStyle);

            // Ajustar ancho de columnas
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // Agregar un poco más de espacio
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }

            // Aplicar filtro automático a los encabezados (en la misma fila de encabezados)
            // headerRowIndex ya fue guardado anteriormente cuando se creó la fila de encabezados
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndex, headerRowIndex, 0, headers.length - 1));

            // Congelar paneles (dejar visibles los encabezados al hacer scroll)
            sheet.createFreezePane(0, headerRowIndex + 1);

            // Escribir al stream
            workbook.write(outputStream);
        }
    }

    /**
     * Genera un archivo Excel con la lista de productos del productor.
     * Incluye filtros automáticos en las columnas y formato profesional.
     * 
     * @param listaProductos Lista de productos del productor a exportar
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelProductosProductor(ArrayList<?> listaProductos, OutputStream outputStream, String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            XSSFSheet sheet = workbook.createSheet("Mis Productos");
            
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);
            CellStyle currencyStyle = crearEstiloMoneda(workbook);
            
            int rowNum = 0;
            
            // Título del reporte
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("REPORTE DE PRODUCTOS - PRODUCTOR - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 7));
            
            // Fecha de generación
            Row dateRow = sheet.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 7));
            
            // Filtros aplicados (si existen)
            if (filtrosInformacion != null && !filtrosInformacion.trim().isEmpty()) {
                Row filterRow = sheet.createRow(rowNum++);
                Cell filterCell = filterRow.createCell(0);
                filterCell.setCellValue("Filtros aplicados: " + filtrosInformacion);
                filterCell.setCellStyle(dataStyle);
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 7));
            }
            
            // Fila en blanco
            rowNum++;
            
            // Encabezados - guardar el índice de esta fila para el autoFilter
            int headerRowIndex = rowNum;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"SKU", "Producto", "Descripción", "Categoría", "Precio por Paquete", "Unidades por Paquete", "Stock Total", "N° de Lotes"};
            int colNum = 0;
            for (String header : headers) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }
            
            double valorTotalInventario = 0.0;
            for (Object obj : listaProductos) {
                Row row = sheet.createRow(rowNum++);
                try {
                    Cell cell = row.createCell(0);
                    cell.setCellValue((String) obj.getClass().getMethod("getCodigoSKU").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(1);
                    cell.setCellValue((String) obj.getClass().getMethod("getNombre").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(2);
                    String descripcion = (String) obj.getClass().getMethod("getDescripcion").invoke(obj);
                    cell.setCellValue(descripcion != null ? descripcion : "");
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(3);
                    Object categoriaObj = obj.getClass().getMethod("getCategoria").invoke(obj);
                    String categoriaNombre = (String) categoriaObj.getClass().getMethod("getNombre").invoke(categoriaObj);
                    cell.setCellValue(categoriaNombre != null ? categoriaNombre : "");
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(4);
                    double precio = (Double) obj.getClass().getMethod("getPrecioActual").invoke(obj);
                    cell.setCellValue(precio);
                    cell.setCellStyle(currencyStyle);
                    
                    cell = row.createCell(5);
                    int unidades = (Integer) obj.getClass().getMethod("getUnidadesPorPaquete").invoke(obj);
                    cell.setCellValue(unidades);
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(6);
                    double stockTotal = (Double) obj.getClass().getMethod("getStockTotal").invoke(obj);
                    cell.setCellValue(stockTotal);
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(7);
                    int numLotes = (Integer) obj.getClass().getMethod("getNumeroLotes").invoke(obj);
                    cell.setCellValue(numLotes);
                    cell.setCellStyle(dataStyle);
                    
                    // Calcular valor total del inventario (stock * precio por unidad)
                    double precioPorUnidad = precio / unidades;
                    valorTotalInventario += stockTotal * precioPorUnidad;
                    
                } catch (Exception e) {
                    System.err.println("Error al procesar producto: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            rowNum++;
            Row totalRow = sheet.createRow(rowNum++);
            Cell totalLabelCell = totalRow.createCell(0);
            totalLabelCell.setCellValue("VALOR TOTAL DEL INVENTARIO:");
            totalLabelCell.setCellStyle(headerStyle);
            
            Cell totalValueCell = totalRow.createCell(4);
            totalValueCell.setCellValue(valorTotalInventario);
            totalValueCell.setCellStyle(currencyStyle);
            
            // Ajustar ancho de columnas
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // Agregar un poco más de espacio
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }
            
            // Aplicar filtro automático a los encabezados (en la misma fila de encabezados)
            // headerRowIndex ya fue guardado anteriormente cuando se creó la fila de encabezados
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndex, headerRowIndex, 0, headers.length - 1));
            
            // Congelar paneles (dejar visibles los encabezados al hacer scroll)
            sheet.createFreezePane(0, headerRowIndex + 1);
            
            // Escribir al stream
            workbook.write(outputStream);
        }
    }

    /**
     * Genera un archivo Excel con la lista de lotes del productor.
     * Incluye filtros automáticos en las columnas y formato profesional.
     * 
     * @param listaLotes Lista de lotes del productor a exportar
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelLotesProductor(ArrayList<?> listaLotes, OutputStream outputStream, String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            XSSFSheet sheet = workbook.createSheet("Mis Lotes");
            
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);
            
            int rowNum = 0;
            
            // Título del reporte
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("REPORTE DE LOTES - PRODUCTOR - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 8));
            
            // Fecha de generación
            Row dateRow = sheet.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 8));
            
            // Filtros aplicados (si existen)
            if (filtrosInformacion != null && !filtrosInformacion.trim().isEmpty()) {
                Row filterRow = sheet.createRow(rowNum++);
                Cell filterCell = filterRow.createCell(0);
                filterCell.setCellValue("Filtros aplicados: " + filtrosInformacion);
                filterCell.setCellStyle(dataStyle);
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 8));
            }
            
            // Fila en blanco
            rowNum++;
            
            // Encabezados - guardar el índice de esta fila para el autoFilter
            int headerRowIndex = rowNum;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"Código Lote", "Producto", "SKU", "Stock Actual", "Fecha Vencimiento", "Ubicación", "Distrito", "Estado"};
            int colNum = 0;
            for (String header : headers) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }
            
            int totalStock = 0;
            for (Object obj : listaLotes) {
                Row row = sheet.createRow(rowNum++);
                try {
                    // Si el objeto es un Object[], usarlo directamente
                    if (obj instanceof Object[]) {
                        Object[] lote = (Object[]) obj;
                        // [0] = codigo_lote, [1] = producto_nombre, [2] = codigo_sku, 
                        // [3] = ubicacion, [4] = stock_actual, [5] = fecha_vencimiento, 
                        // [6] = distrito, [7] = estado
                        
                        Cell cell = row.createCell(0);
                        cell.setCellValue(lote[0] != null ? lote[0].toString() : "");
                        cell.setCellStyle(dataStyle);
                        
                        cell = row.createCell(1);
                        cell.setCellValue(lote[1] != null ? lote[1].toString() : "");
                        cell.setCellStyle(dataStyle);
                        
                        cell = row.createCell(2);
                        cell.setCellValue(lote[2] != null ? lote[2].toString() : "");
                        cell.setCellStyle(dataStyle);
                        
                        cell = row.createCell(3);
                        int stock = lote[4] != null ? (Integer) lote[4] : 0;
                        cell.setCellValue(stock);
                        cell.setCellStyle(dataStyle);
                        totalStock += stock;
                        
                        cell = row.createCell(4);
                        if (lote[5] != null && lote[5] instanceof java.sql.Date) {
                            cell.setCellValue(new java.text.SimpleDateFormat("dd/MM/yyyy").format((java.sql.Date) lote[5]));
                        } else {
                            cell.setCellValue("");
                        }
                        cell.setCellStyle(dataStyle);
                        
                        cell = row.createCell(5);
                        cell.setCellValue(lote[3] != null ? lote[3].toString() : "");
                        cell.setCellStyle(dataStyle);
                        
                        cell = row.createCell(6);
                        cell.setCellValue(lote[6] != null ? lote[6].toString() : "");
                        cell.setCellStyle(dataStyle);
                        
                        cell = row.createCell(7);
                        cell.setCellValue(lote[7] != null ? lote[7].toString() : "");
                        cell.setCellStyle(dataStyle);
                    } else {
                        // Si es un bean, usar reflexión
                        Cell cell = row.createCell(0);
                        cell.setCellValue((String) obj.getClass().getMethod("getCodigoLote").invoke(obj));
                        cell.setCellStyle(dataStyle);
                        
                        cell = row.createCell(1);
                        String nombreProducto = (String) obj.getClass().getMethod("getNombreProducto").invoke(obj);
                        cell.setCellValue(nombreProducto != null ? nombreProducto : "");
                        cell.setCellStyle(dataStyle);
                        
                        cell = row.createCell(2);
                        String sku = (String) obj.getClass().getMethod("getCodigoSKU").invoke(obj);
                        cell.setCellValue(sku != null ? sku : "");
                        cell.setCellStyle(dataStyle);
                        
                        cell = row.createCell(3);
                        int stock = (Integer) obj.getClass().getMethod("getStockActual").invoke(obj);
                        cell.setCellValue(stock);
                        cell.setCellStyle(dataStyle);
                        totalStock += stock;
                        
                        cell = row.createCell(4);
                        java.sql.Date fechaVenc = (java.sql.Date) obj.getClass().getMethod("getFechaVencimiento").invoke(obj);
                        if (fechaVenc != null) {
                            cell.setCellValue(new java.text.SimpleDateFormat("dd/MM/yyyy").format(fechaVenc));
                        } else {
                            cell.setCellValue("");
                        }
                        cell.setCellStyle(dataStyle);
                        
                        cell = row.createCell(5);
                        String ubicacion = (String) obj.getClass().getMethod("getNombreUbicacion").invoke(obj);
                        cell.setCellValue(ubicacion != null ? ubicacion : "");
                        cell.setCellStyle(dataStyle);
                        
                        cell = row.createCell(6);
                        String distrito = (String) obj.getClass().getMethod("getNombreDistrito").invoke(obj);
                        cell.setCellValue(distrito != null ? distrito : "");
                        cell.setCellStyle(dataStyle);
                        
                        cell = row.createCell(7);
                        String estado = (String) obj.getClass().getMethod("getEstado").invoke(obj);
                        cell.setCellValue(estado != null ? estado : "");
                        cell.setCellStyle(dataStyle);
                    }
                } catch (Exception e) {
                    System.err.println("Error al procesar lote: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            rowNum++;
            Row totalRow = sheet.createRow(rowNum++);
            Cell totalLabelCell = totalRow.createCell(0);
            totalLabelCell.setCellValue("STOCK TOTAL:");
            totalLabelCell.setCellStyle(headerStyle);
            
            Cell totalValueCell = totalRow.createCell(3);
            totalValueCell.setCellValue(totalStock);
            totalValueCell.setCellStyle(dataStyle);
            
            // Ajustar ancho de columnas
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // Agregar un poco más de espacio
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }
            
            // Aplicar filtro automático a los encabezados (en la misma fila de encabezados)
            // headerRowIndex ya fue guardado anteriormente cuando se creó la fila de encabezados
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndex, headerRowIndex, 0, headers.length - 1));
            
            // Congelar paneles (dejar visibles los encabezados al hacer scroll)
            sheet.createFreezePane(0, headerRowIndex + 1);
            
            // Escribir al stream
            workbook.write(outputStream);
        }
    }

    /**
     * Genera un archivo Excel con la lista de lotes del almacén.
     * Incluye filtros automáticos en las columnas y formato profesional.
     * 
     * @param listaLotes Lista de lotes del almacén a exportar
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelLotesAlmacen(ArrayList<?> listaLotes, OutputStream outputStream, String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            XSSFSheet sheet = workbook.createSheet("Lotes Almacén");
            
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);
            
            int rowNum = 0;
            
            // Título del reporte
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("REPORTE DE LOTES - ALMACÉN - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 8));
            
            // Fecha de generación
            Row dateRow = sheet.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 8));
            
            // Filtros aplicados (si existen)
            if (filtrosInformacion != null && !filtrosInformacion.trim().isEmpty()) {
                Row filterRow = sheet.createRow(rowNum++);
                Cell filterCell = filterRow.createCell(0);
                filterCell.setCellValue("Filtros aplicados: " + filtrosInformacion);
                filterCell.setCellStyle(dataStyle);
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 8));
            }
            
            // Fila en blanco
            rowNum++;
            
            // Encabezados - guardar el índice de esta fila para el autoFilter
            int headerRowIndex = rowNum;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"Código Lote", "Producto", "SKU", "Stock Actual", "Paquetes Disponibles", 
                               "Fecha Vencimiento", "Ubicación", "Estado Stock", "Estado"};
            int colNum = 0;
            for (String header : headers) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }
            
            int totalStock = 0;
            int totalPaquetes = 0;
            for (Object obj : listaLotes) {
                Row row = sheet.createRow(rowNum++);
                try {
                    Cell cell = row.createCell(0);
                    cell.setCellValue((String) obj.getClass().getMethod("getCodigoLote").invoke(obj));
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(1);
                    String nombreProducto = (String) obj.getClass().getMethod("getNombreProducto").invoke(obj);
                    cell.setCellValue(nombreProducto != null ? nombreProducto : "");
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(2);
                    String sku = (String) obj.getClass().getMethod("getCodigoSKU").invoke(obj);
                    cell.setCellValue(sku != null ? sku : "");
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(3);
                    int stock = (Integer) obj.getClass().getMethod("getStockActual").invoke(obj);
                    cell.setCellValue(stock);
                    cell.setCellStyle(dataStyle);
                    totalStock += stock;
                    
                    cell = row.createCell(4);
                    int paquetes = (Integer) obj.getClass().getMethod("getPaquetesDisponibles").invoke(obj);
                    cell.setCellValue(paquetes);
                    cell.setCellStyle(dataStyle);
                    totalPaquetes += paquetes;
                    
                    cell = row.createCell(5);
                    java.sql.Date fechaVenc = (java.sql.Date) obj.getClass().getMethod("getFechaVencimiento").invoke(obj);
                    if (fechaVenc != null) {
                        cell.setCellValue(new java.text.SimpleDateFormat("dd/MM/yyyy").format(fechaVenc));
                    } else {
                        cell.setCellValue("");
                    }
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(6);
                    String ubicacion = (String) obj.getClass().getMethod("getNombreUbicacion").invoke(obj);
                    cell.setCellValue(ubicacion != null ? ubicacion : "");
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(7);
                    String estadoStock = (String) obj.getClass().getMethod("getEstadoStock").invoke(obj);
                    cell.setCellValue(estadoStock != null ? estadoStock : "");
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(8);
                    String estado = (String) obj.getClass().getMethod("getEstado").invoke(obj);
                    cell.setCellValue(estado != null ? estado : "");
                    cell.setCellStyle(dataStyle);
                } catch (Exception e) {
                    System.err.println("Error al procesar lote: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            rowNum++;
            Row totalRow = sheet.createRow(rowNum++);
            Cell totalLabelCell = totalRow.createCell(0);
            totalLabelCell.setCellValue("STOCK TOTAL:");
            totalLabelCell.setCellStyle(headerStyle);
            
            Cell totalValueCell = totalRow.createCell(3);
            totalValueCell.setCellValue(totalStock);
            totalValueCell.setCellStyle(headerStyle);
            
            Cell totalPaquetesLabelCell = totalRow.createCell(4);
            totalPaquetesLabelCell.setCellValue("PAQUETES TOTALES:");
            totalPaquetesLabelCell.setCellStyle(headerStyle);
            
            Cell totalPaquetesValueCell = totalRow.createCell(5);
            totalPaquetesValueCell.setCellValue(totalPaquetes);
            totalPaquetesValueCell.setCellStyle(headerStyle);
            
            // Ajustar ancho de columnas
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // Agregar un poco más de espacio
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }
            
            // Aplicar filtro automático a los encabezados (en la misma fila de encabezados)
            // headerRowIndex ya fue guardado anteriormente cuando se creó la fila de encabezados
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndex, headerRowIndex, 0, headers.length - 1));
            
            // Congelar paneles (dejar visibles los encabezados al hacer scroll)
            sheet.createFreezePane(0, headerRowIndex + 1);
            
            // Escribir al stream
            workbook.write(outputStream);
        }
    }

    /**
     * Genera un archivo Excel con la lista de órdenes de compra del productor.
     * Incluye filtros automáticos en las columnas y formato profesional.
     * 
     * @param listaOrdenes Lista de órdenes de compra del productor a exportar
     * @param outputStream Stream de salida donde se escribirá el archivo Excel
     * @param filtrosInformacion Texto descriptivo de los filtros aplicados (opcional)
     * @throws IOException Si ocurre un error al escribir el archivo
     */
    public static void generarExcelOrdenesCompraProductor(ArrayList<?> listaOrdenes, OutputStream outputStream, String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            XSSFSheet sheet = workbook.createSheet("Órdenes de Compra");
            
            CellStyle headerStyle = crearEstiloEncabezadoVerde(workbook);
            CellStyle dataStyle = crearEstiloDatos(workbook);
            CellStyle titleStyle = crearEstiloTitulo(workbook);
            CellStyle currencyStyle = crearEstiloMoneda(workbook);
            
            int rowNum = 0;
            
            // Título del reporte
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("REPORTE DE ÓRDENES DE COMPRA - PRODUCTOR - TELITO BODEGUERO");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 6));
            
            // Fecha de generación
            Row dateRow = sheet.createRow(rowNum++);
            Cell dateCell = dateRow.createCell(0);
            dateCell.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
            dateCell.setCellStyle(dataStyle);
            sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 6));
            
            // Filtros aplicados (si existen)
            if (filtrosInformacion != null && !filtrosInformacion.trim().isEmpty()) {
                Row filterRow = sheet.createRow(rowNum++);
                Cell filterCell = filterRow.createCell(0);
                filterCell.setCellValue("Filtros aplicados: " + filtrosInformacion);
                filterCell.setCellStyle(dataStyle);
                sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rowNum - 1, rowNum - 1, 0, 6));
            }
            
            // Fila en blanco
            rowNum++;
            
            // Encabezados - guardar el índice de esta fila para el autoFilter
            int headerRowIndex = rowNum;
            Row headerRow = sheet.createRow(rowNum++);
            String[] headers = {"N° de Orden", "Producto", "Cantidad", "Monto Total", "Usuario Logística", "Estado", "Lote Asignado"};
            int colNum = 0;
            for (String header : headers) {
                Cell cell = headerRow.createCell(colNum++);
                cell.setCellValue(header);
                cell.setCellStyle(headerStyle);
            }
            
            double montoTotalGeneral = 0.0;
            for (Object obj : listaOrdenes) {
                Row row = sheet.createRow(rowNum++);
                try {
                    // Objeto es un Object[] con: [id, numeroOrden, productoNombre, cantidad, montoTotal, usuarioLogistica, estado, loteId]
                    Object[] orden = (Object[]) obj;
                    
                    Cell cell = row.createCell(0);
                    cell.setCellValue((String) orden[1]);
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(1);
                    cell.setCellValue((String) orden[2]);
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(2);
                    cell.setCellValue((Integer) orden[3]);
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(3);
                    double monto = (Double) orden[4];
                    cell.setCellValue(monto);
                    cell.setCellStyle(currencyStyle);
                    montoTotalGeneral += monto;
                    
                    cell = row.createCell(4);
                    cell.setCellValue((String) orden[5]);
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(5);
                    String estado = (String) orden[6];
                    cell.setCellValue(estado != null ? estado : "");
                    cell.setCellStyle(dataStyle);
                    
                    cell = row.createCell(6);
                    Object loteId = orden[7];
                    cell.setCellValue(loteId != null ? "Asignado (ID: " + loteId.toString() + ")" : "Sin asignar");
                    cell.setCellStyle(dataStyle);
                    
                } catch (Exception e) {
                    System.err.println("Error al procesar orden de compra: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            rowNum++;
            Row totalRow = sheet.createRow(rowNum++);
            Cell totalLabelCell = totalRow.createCell(0);
            totalLabelCell.setCellValue("TOTAL GENERAL:");
            totalLabelCell.setCellStyle(headerStyle);
            
            Cell totalValueCell = totalRow.createCell(3);
            totalValueCell.setCellValue(montoTotalGeneral);
            totalValueCell.setCellStyle(currencyStyle);
            
            // Ajustar ancho de columnas
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                // Agregar un poco más de espacio
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }
            
            // Aplicar filtro automático a los encabezados (en la misma fila de encabezados)
            // headerRowIndex ya fue guardado anteriormente cuando se creó la fila de encabezados
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(
                headerRowIndex, headerRowIndex, 0, headers.length - 1));
            
            // Congelar paneles (dejar visibles los encabezados al hacer scroll)
            sheet.createFreezePane(0, headerRowIndex + 1);
            
            // Escribir al stream
            workbook.write(outputStream);
        }
    }

    /**
     * Genera un archivo Excel con la lista de pedidos del almacén
     */
    public static void generarExcelPedidos(ArrayList<?> listaPedidos, OutputStream outputStream, String filtrosInformacion) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            XSSFSheet sheet = workbook.createSheet("Pedidos de Salida");

            // ===== ESTILOS =====
            CellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFillForegroundColor(IndexedColors.DARK_TEAL.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);

            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerFont.setFontHeightInPoints((short) 12);
            headerStyle.setFont(headerFont);

            CellStyle titleStyle = workbook.createCellStyle();
            Font titleFont = workbook.createFont();
            titleFont.setBold(true);
            titleFont.setFontHeightInPoints((short) 16);
            titleFont.setColor(IndexedColors.DARK_TEAL.getIndex());
            titleStyle.setFont(titleFont);
            titleStyle.setAlignment(HorizontalAlignment.CENTER);

            CellStyle infoStyle = workbook.createCellStyle();
            Font infoFont = workbook.createFont();
            infoFont.setItalic(true);
            infoFont.setFontHeightInPoints((short) 10);
            infoFont.setColor(IndexedColors.GREY_50_PERCENT.getIndex());
            infoStyle.setFont(infoFont);

            CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setAlignment(HorizontalAlignment.LEFT);
            dataStyle.setVerticalAlignment(VerticalAlignment.CENTER);
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);

            CellStyle numberStyle = workbook.createCellStyle();
            numberStyle.cloneStyleFrom(dataStyle);
            numberStyle.setAlignment(HorizontalAlignment.RIGHT);

            CellStyle dateStyle = workbook.createCellStyle();
            dateStyle.cloneStyleFrom(dataStyle);
            dateStyle.setAlignment(HorizontalAlignment.CENTER);
            CreationHelper createHelper = workbook.getCreationHelper();
            dateStyle.setDataFormat(createHelper.createDataFormat().getFormat("dd/mm/yyyy hh:mm"));

            // ===== TÍTULO =====
            int rowIndex = 0;
            Row titleRow = sheet.createRow(rowIndex++);
            titleRow.setHeightInPoints(25);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("📦 REPORTE DE PEDIDOS DE SALIDA - ALMACÉN");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 5));

            // ===== INFORMACIÓN DE FILTROS =====
            Row infoRow1 = sheet.createRow(rowIndex++);
            Cell infoCell1 = infoRow1.createCell(0);
            infoCell1.setCellValue("Filtros aplicados: " + filtrosInformacion);
            infoCell1.setCellStyle(infoStyle);
            sheet.addMergedRegion(new CellRangeAddress(rowIndex - 1, rowIndex - 1, 0, 5));

            Row infoRow2 = sheet.createRow(rowIndex++);
            Cell infoCell2 = infoRow2.createCell(0);
            infoCell2.setCellValue("Fecha de generación: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new java.util.Date()));
            infoCell2.setCellStyle(infoStyle);
            sheet.addMergedRegion(new CellRangeAddress(rowIndex - 1, rowIndex - 1, 0, 5));

            rowIndex++; // Fila vacía

            // ===== ENCABEZADOS =====
            int headerRowIndex = rowIndex;
            Row headerRow = sheet.createRow(rowIndex++);
            headerRow.setHeightInPoints(20);

            String[] headers = {
                "N° Pedido", 
                "Cliente", 
                "Destino", 
                "Fecha Creación", 
                "Estado", 
                "Productos"
            };

            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // ===== DATOS =====
            for (Object obj : listaPedidos) {
                com.example.telito.almacen.beans.Pedido pedido = (com.example.telito.almacen.beans.Pedido) obj;
                Row dataRow = sheet.createRow(rowIndex++);

                Cell c0 = dataRow.createCell(0);
                c0.setCellValue(pedido.getNumeroPedido());
                c0.setCellStyle(dataStyle);

                Cell c1 = dataRow.createCell(1);
                c1.setCellValue(pedido.getCliente() != null ? pedido.getCliente().getNombre() : "");
                c1.setCellStyle(dataStyle);

                Cell c2 = dataRow.createCell(2);
                c2.setCellValue(pedido.getDestino() != null ? pedido.getDestino() : "");
                c2.setCellStyle(dataStyle);

                Cell c3 = dataRow.createCell(3);
                if (pedido.getFechaCreacion() != null) {
                    c3.setCellValue(pedido.getFechaCreacion());
                    c3.setCellStyle(dateStyle);
                } else {
                    c3.setCellValue("");
                    c3.setCellStyle(dataStyle);
                }

                Cell c4 = dataRow.createCell(4);
                c4.setCellValue(pedido.getEstadoPreparacion() != null ? pedido.getEstadoPreparacion() : "");
                c4.setCellStyle(dataStyle);

                Cell c5 = dataRow.createCell(5);
                int cantidadProductos = pedido.getItems() != null ? pedido.getItems().size() : 0;
                c5.setCellValue(cantidadProductos + " producto(s)");
                c5.setCellStyle(numberStyle);
            }

            // ===== AJUSTAR ANCHO DE COLUMNAS =====
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                int currentWidth = sheet.getColumnWidth(i);
                sheet.setColumnWidth(i, currentWidth + 1000);
            }

            // Aplicar filtro automático
            sheet.setAutoFilter(new CellRangeAddress(headerRowIndex, headerRowIndex, 0, headers.length - 1));
            
            // Congelar paneles
            sheet.createFreezePane(0, headerRowIndex + 1);

            // Escribir al stream
            workbook.write(outputStream);
        }
    }
}


