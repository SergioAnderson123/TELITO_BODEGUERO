package com.example.telito.almacen.servlets;

import com.example.telito.almacen.validators.ExcelValidator;
import com.example.telito.util.AuthorizationHelper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet para validar archivos Excel antes de insertar datos en el almacén.
 * Valida estructura, formato y datos antes de permitir la carga.
 */
@WebServlet("/almacen/ExcelValidacionServlet")
@MultipartConfig(
    maxFileSize = 10485760, // 10 MB
    maxRequestSize = 10485760
)
public class ExcelValidacionServlet extends HttpServlet {
    
    private static final Logger logger = LoggerFactory.getLogger(ExcelValidacionServlet.class);
    private final ExcelValidator excelValidator;
    
    public ExcelValidacionServlet() {
        this.excelValidator = new ExcelValidator();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Verificar que el usuario tenga rol de almacenero
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAlmacen(session)) {
            logger.warn("Acceso denegado: Usuario sin rol de almacenero intentó acceder a ExcelValidacionServlet");
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "form";
        }
        
        if ("form".equals(action)) {
            // Mostrar formulario de carga
            request.getRequestDispatcher("/almacen/entradas/cargarExcel.jsp").forward(request, response);
        } else if ("descargarPlantilla".equals(action)) {
            // Descargar plantilla Excel
            excelValidator.descargarPlantilla(response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Verificar que el usuario tenga rol de almacenero
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAlmacen(session)) {
            logger.warn("Acceso denegado: Usuario sin rol de almacenero intentó acceder a ExcelValidacionServlet (POST)");
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        String action = request.getParameter("action");
        if ("validar".equals(action)) {
            validarExcel(request, response, session);
        } else if ("procesar".equals(action)) {
            procesarExcel(request, response, session);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
        }
    }
    
    /**
     * Valida el archivo Excel sin insertar datos.
     */
    private void validarExcel(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        ArrayList<String> errores = new ArrayList<>();
        Map<String, Object> resultadoValidacion = new HashMap<>();
        
        try {
            // Obtener el archivo subido
            Part filePart = request.getPart("archivoExcel");
            
            if (filePart == null || filePart.getSize() == 0) {
                errores.add("No se ha seleccionado ningún archivo");
                request.setAttribute("errores", errores);
                request.getRequestDispatcher("/almacen/entradas/cargarExcel.jsp").forward(request, response);
                return;
            }
            
            // Validar extensión del archivo
            String fileName = filePart.getSubmittedFileName();
            if (fileName == null || (!fileName.endsWith(".xlsx") && !fileName.endsWith(".xls"))) {
                errores.add("El archivo debe ser un Excel (.xlsx o .xls)");
                request.setAttribute("errores", errores);
                request.getRequestDispatcher("/almacen/entradas/cargarExcel.jsp").forward(request, response);
                return;
            }
            
            // Leer el archivo
            try (InputStream fileContent = filePart.getInputStream()) {
                // Realizar validación completa
                resultadoValidacion = excelValidator.validarArchivoExcel(fileContent, fileName);
                
                // Guardar resultado en sesión para posible procesamiento posterior
                session.setAttribute("resultadoValidacion", resultadoValidacion);
                session.setAttribute("archivoValidado", true);
                session.setAttribute("nombreArchivo", fileName);
                
                // Pasar resultado a la vista
                request.setAttribute("resultadoValidacion", resultadoValidacion);
                request.setAttribute("nombreArchivo", fileName);
                
                // Redirigir a página de resultados
                request.getRequestDispatcher("/almacen/entradas/resultadoValidacion.jsp").forward(request, response);
                
            } catch (Exception e) {
                logger.error("Error al validar archivo Excel: " + fileName, e);
                errores.add("Error al procesar el archivo: " + e.getMessage());
                request.setAttribute("errores", errores);
                request.getRequestDispatcher("/almacen/entradas/cargarExcel.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            logger.error("Error inesperado al validar Excel", e);
            errores.add("Error inesperado: " + e.getMessage());
            request.setAttribute("errores", errores);
            request.getRequestDispatcher("/almacen/entradas/cargarExcel.jsp").forward(request, response);
        }
    }
    
    /**
     * Procesa el archivo Excel validado e inserta los datos.
     * Solo se ejecuta si la validación fue exitosa.
     */
    private void procesarExcel(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        // Verificar que existe una validación previa exitosa
        Boolean archivoValidado = (Boolean) session.getAttribute("archivoValidado");
        Map<String, Object> resultadoValidacion = (Map<String, Object>) session.getAttribute("resultadoValidacion");
        
        if (archivoValidado == null || !archivoValidado || resultadoValidacion == null) {
            session.setAttribute("errorMsg", "Debe validar el archivo primero antes de procesarlo");
            response.sendRedirect(request.getContextPath() + "/almacen/ExcelValidacionServlet?action=form");
            return;
        }
        
        // Verificar que la validación fue exitosa
        Boolean esValido = (Boolean) resultadoValidacion.get("esValido");
        if (esValido == null || !esValido) {
            session.setAttribute("errorMsg", "El archivo no pasó la validación. No se puede procesar.");
            response.sendRedirect(request.getContextPath() + "/almacen/ExcelValidacionServlet?action=form");
            return;
        }
        
        try {
            // Obtener usuario de la sesión
            com.example.telito.administrador.beans.Usuario usuario = 
                (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
            int usuarioId = (usuario != null) ? usuario.getIdUsuario() : 1;
            
            // Procesar e insertar datos
            Map<String, Object> resultadoProcesamiento = excelValidator.procesarDatosValidados(
                resultadoValidacion, usuarioId
            );
            
            // Limpiar sesión
            session.removeAttribute("resultadoValidacion");
            session.removeAttribute("archivoValidado");
            session.removeAttribute("nombreArchivo");
            
            // Mostrar resultado
            request.setAttribute("resultadoProcesamiento", resultadoProcesamiento);
            request.getRequestDispatcher("/almacen/entradas/resultadoProcesamiento.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.error("Error al procesar archivo Excel validado", e);
            session.setAttribute("errorMsg", "Error al procesar el archivo: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/almacen/ExcelValidacionServlet?action=form");
        }
    }
}

