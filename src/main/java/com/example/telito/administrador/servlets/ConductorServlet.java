package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Conductor;
import com.example.telito.administrador.daos.ConductorDAO;
import com.example.telito.util.AuthorizationHelper;
import com.google.gson.Gson;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

// Gestión de conductores - CRUD completo
@WebServlet(name = "ConductorServlet", value = "/administrador/ConductorServlet")
public class ConductorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Solo administradores
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a ConductorServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        String action = request.getParameter("action");
        ConductorDAO conductorDAO = new ConductorDAO();

        if (action == null) {
            action = "listar";
        }

        switch (action) {
            case "listar":
                int page = 1;
                int size = 5;
                String busqueda = request.getParameter("busqueda");
                String dni = request.getParameter("dni");
                String fechaVencimiento = request.getParameter("fechaVencimiento");
                try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
                try { size = Integer.parseInt(request.getParameter("size")); } catch (Exception ignored) {}
                if (page < 1) page = 1;
                if (size < 1) size = 5;

                int totalRows = conductorDAO.contarConductores(busqueda, dni, fechaVencimiento);
                int totalPages = (int) Math.ceil(totalRows / (double) size);
                if (totalPages == 0) totalPages = 1;
                if (page > totalPages) page = totalPages;

                // Estadísticas generales (sin filtros)
                int totalConductores = conductorDAO.contarTotalConductores();
                int conductoresConPlanes = conductorDAO.contarConductoresConPlanes();
                int conductoresSinPlanes = conductorDAO.contarConductoresSinPlanes();

                ArrayList<Conductor> listaConductores = conductorDAO.listarConductores(busqueda, dni, fechaVencimiento, page, size);
                request.setAttribute("listaConductores", listaConductores);
                request.setAttribute("currentPage", page);
                request.setAttribute("size", size);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalRows", totalRows);
                request.setAttribute("busqueda", busqueda);
                request.setAttribute("dni", dni);
                request.setAttribute("fechaVencimiento", fechaVencimiento);
                request.setAttribute("totalConductores", totalConductores);
                request.setAttribute("conductoresConPlanes", conductoresConPlanes);
                request.setAttribute("conductoresSinPlanes", conductoresSinPlanes);
                request.setAttribute("baseUrl", request.getContextPath() + "/administrador/ConductorServlet");
                request.setAttribute("param1Name", "action");
                request.setAttribute("param1Value", "listar");
                request.setAttribute("itemName", "conductores");

                RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/gestion-conductores.jsp");
                dispatcher.forward(request, response);
                break;

            case "crear":
                RequestDispatcher dispatcherCrear = request.getRequestDispatcher("/administrador/crear-conductor.jsp");
                dispatcherCrear.forward(request, response);
                break;

            case "editar":
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Conductor conductorEditar = conductorDAO.buscarConductorPorId(idEditar);
                request.setAttribute("conductor", conductorEditar);
                RequestDispatcher dispatcherEditar = request.getRequestDispatcher("/administrador/editar-conductor.jsp");
                dispatcherEditar.forward(request, response);
                break;

            case "obtenerConductorJson":
                obtenerConductorJson(request, response);
                break;

            case "eliminar":
                int idEliminar = Integer.parseInt(request.getParameter("id"));
                try {
                    boolean eliminado = conductorDAO.eliminarConductor(idEliminar);
                    if (eliminado) {
                        request.getSession().setAttribute("mensaje", "Conductor eliminado exitosamente.");
                        request.getSession().setAttribute("tipoMensaje", "success");
                    } else {
                        request.getSession().setAttribute("mensaje", "Error al eliminar el conductor. El conductor no existe.");
                        request.getSession().setAttribute("tipoMensaje", "danger");
                    }
                } catch (RuntimeException e) {
                    // Capturar el mensaje específico sobre planes de transporte asociados
                    String mensajeError = e.getMessage();
                    if (mensajeError != null && mensajeError.contains("planes de transporte")) {
                        request.getSession().setAttribute("mensaje", mensajeError);
                        request.getSession().setAttribute("tipoMensaje", "warning");
                    } else {
                        request.getSession().setAttribute("mensaje", "Error al eliminar el conductor: " + (mensajeError != null ? mensajeError : "Error desconocido"));
                        request.getSession().setAttribute("tipoMensaje", "danger");
                    }
                    System.err.println("Error al eliminar conductor: " + e.getMessage());
                    e.printStackTrace();
                } catch (Exception e) {
                    request.getSession().setAttribute("mensaje", "Error inesperado al eliminar el conductor.");
                    request.getSession().setAttribute("tipoMensaje", "danger");
                    System.err.println("Error inesperado al eliminar conductor: " + e.getMessage());
                    e.printStackTrace();
                }
                response.sendRedirect(request.getContextPath() + "/administrador/ConductorServlet");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Verificar que el usuario tenga rol de administrador
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a ConductorServlet (POST) desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        ConductorDAO conductorDAO = new ConductorDAO();
        
        // Log para depuración
        System.out.println("ConductorServlet POST - Action recibido: " + action);
        System.out.println("ConductorServlet POST - Parámetros recibidos: id=" + request.getParameter("id") + 
                          ", nombreCompleto=" + request.getParameter("nombreCompleto") + 
                          ", licencia=" + request.getParameter("licencia"));

        if ("guardar".equals(action)) {
            String nombreCompleto = request.getParameter("nombreCompleto");
            String licencia = request.getParameter("licencia");
            String telefono = request.getParameter("telefono");
            String email = request.getParameter("email");
            String dni = request.getParameter("dni");
            String tipoLicencia = request.getParameter("tipoLicencia");
            String fechaVencimientoLicenciaStr = request.getParameter("fechaVencimientoLicencia");

            Conductor conductor = new Conductor();
            conductor.setNombreCompleto(nombreCompleto);
            conductor.setLicencia(licencia);
            conductor.setTelefono(telefono != null && !telefono.trim().isEmpty() ? telefono : null);
            conductor.setEmail(email != null && !email.trim().isEmpty() ? email : null);
            conductor.setDni(dni != null && !dni.trim().isEmpty() ? dni : null);
            conductor.setTipoLicencia(tipoLicencia != null && !tipoLicencia.trim().isEmpty() ? tipoLicencia : null);
            
            // Convertir fecha de String a Date
            if (fechaVencimientoLicenciaStr != null && !fechaVencimientoLicenciaStr.trim().isEmpty()) {
                try {
                    conductor.setFechaVencimientoLicencia(java.sql.Date.valueOf(fechaVencimientoLicenciaStr));
                } catch (IllegalArgumentException e) {
                    conductor.setFechaVencimientoLicencia(null);
                }
            } else {
                conductor.setFechaVencimientoLicencia(null);
            }

            boolean creado = conductorDAO.crearConductor(conductor);
            if (creado) {
                request.getSession().setAttribute("mensaje", "Conductor creado exitosamente.");
                request.getSession().setAttribute("tipoMensaje", "success");
            } else {
                request.getSession().setAttribute("mensaje", "Error al crear el conductor.");
                request.getSession().setAttribute("tipoMensaje", "danger");
            }
            response.sendRedirect(request.getContextPath() + "/administrador/ConductorServlet");

        } else if ("actualizar".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                String nombreCompleto = request.getParameter("nombreCompleto");
                String licencia = request.getParameter("licencia");
                String telefono = request.getParameter("telefono");
                String email = request.getParameter("email");
                String dni = request.getParameter("dni");
                String tipoLicencia = request.getParameter("tipoLicencia");
                String fechaVencimientoLicenciaStr = request.getParameter("fechaVencimientoLicencia");

                // Validar que los parámetros no estén vacíos
                if (nombreCompleto == null || nombreCompleto.trim().isEmpty()) {
                    throw new IllegalArgumentException("El nombre completo es requerido.");
                }
                if (licencia == null || licencia.trim().isEmpty()) {
                    throw new IllegalArgumentException("El número de licencia es requerido.");
                }

                Conductor conductor = new Conductor();
                conductor.setIdConductor(id);
                conductor.setNombreCompleto(nombreCompleto.trim());
                conductor.setLicencia(licencia.trim());
                conductor.setTelefono(telefono != null && !telefono.trim().isEmpty() ? telefono.trim() : null);
                conductor.setEmail(email != null && !email.trim().isEmpty() ? email.trim() : null);
                conductor.setDni(dni != null && !dni.trim().isEmpty() ? dni.trim() : null);
                conductor.setTipoLicencia(tipoLicencia != null && !tipoLicencia.trim().isEmpty() ? tipoLicencia.trim() : null);
                
                // Convertir fecha de String a Date
                if (fechaVencimientoLicenciaStr != null && !fechaVencimientoLicenciaStr.trim().isEmpty()) {
                    try {
                        conductor.setFechaVencimientoLicencia(java.sql.Date.valueOf(fechaVencimientoLicenciaStr));
                    } catch (IllegalArgumentException e) {
                        conductor.setFechaVencimientoLicencia(null);
                    }
                } else {
                    conductor.setFechaVencimientoLicencia(null);
                }

                boolean actualizado = conductorDAO.actualizarConductor(conductor);
                
                // Verificar si es una petición AJAX
                String acceptHeader = request.getHeader("Accept");
                boolean isAjaxRequest = acceptHeader != null && acceptHeader.contains("application/json");
                
                if (isAjaxRequest) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    Gson gson = new Gson();
                    Map<String, Object> resultado = new HashMap<>();
                    if (actualizado) {
                        resultado.put("exito", true);
                        resultado.put("mensaje", "Conductor actualizado exitosamente.");
                    } else {
                        resultado.put("exito", false);
                        resultado.put("mensaje", "Error al actualizar el conductor. El conductor no existe o no se pudo actualizar.");
                    }
                    response.getWriter().write(gson.toJson(resultado));
                } else {
                    if (actualizado) {
                        request.getSession().setAttribute("mensaje", "Conductor actualizado exitosamente.");
                        request.getSession().setAttribute("tipoMensaje", "success");
                    } else {
                        request.getSession().setAttribute("mensaje", "Error al actualizar el conductor. El conductor no existe o no se pudo actualizar.");
                        request.getSession().setAttribute("tipoMensaje", "danger");
                    }
                    response.sendRedirect(request.getContextPath() + "/administrador/ConductorServlet");
                }
            } catch (NumberFormatException e) {
                String acceptHeader = request.getHeader("Accept");
                boolean isAjaxRequest = acceptHeader != null && acceptHeader.contains("application/json");
                
                if (isAjaxRequest) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    Gson gson = new Gson();
                    Map<String, Object> resultado = new HashMap<>();
                    resultado.put("exito", false);
                    resultado.put("mensaje", "ID de conductor inválido.");
                    response.getWriter().write(gson.toJson(resultado));
                } else {
                    request.getSession().setAttribute("mensaje", "ID de conductor inválido.");
                    request.getSession().setAttribute("tipoMensaje", "danger");
                    response.sendRedirect(request.getContextPath() + "/administrador/ConductorServlet");
                }
            } catch (IllegalArgumentException e) {
                String acceptHeader = request.getHeader("Accept");
                boolean isAjaxRequest = acceptHeader != null && acceptHeader.contains("application/json");
                
                if (isAjaxRequest) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    Gson gson = new Gson();
                    Map<String, Object> resultado = new HashMap<>();
                    resultado.put("exito", false);
                    resultado.put("mensaje", e.getMessage());
                    response.getWriter().write(gson.toJson(resultado));
                } else {
                    request.getSession().setAttribute("mensaje", e.getMessage());
                    request.getSession().setAttribute("tipoMensaje", "danger");
                    response.sendRedirect(request.getContextPath() + "/administrador/ConductorServlet");
                }
            } catch (RuntimeException e) {
                System.err.println("Error al actualizar conductor: " + e.getMessage());
                e.printStackTrace();
                
                String acceptHeader = request.getHeader("Accept");
                boolean isAjaxRequest = acceptHeader != null && acceptHeader.contains("application/json");
                
                if (isAjaxRequest) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    Gson gson = new Gson();
                    Map<String, Object> resultado = new HashMap<>();
                    resultado.put("exito", false);
                    resultado.put("mensaje", "Error al actualizar el conductor: " + e.getMessage());
                    response.getWriter().write(gson.toJson(resultado));
                } else {
                    request.getSession().setAttribute("mensaje", "Error al actualizar el conductor: " + e.getMessage());
                    request.getSession().setAttribute("tipoMensaje", "danger");
                    response.sendRedirect(request.getContextPath() + "/administrador/ConductorServlet");
                }
            } catch (Exception e) {
                System.err.println("Error inesperado al actualizar conductor: " + e.getMessage());
                e.printStackTrace();
                
                String acceptHeader = request.getHeader("Accept");
                boolean isAjaxRequest = acceptHeader != null && acceptHeader.contains("application/json");
                
                if (isAjaxRequest) {
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    Gson gson = new Gson();
                    Map<String, Object> resultado = new HashMap<>();
                    resultado.put("exito", false);
                    resultado.put("mensaje", "Error inesperado al actualizar el conductor.");
                    response.getWriter().write(gson.toJson(resultado));
                } else {
                    request.getSession().setAttribute("mensaje", "Error inesperado al actualizar el conductor.");
                    request.getSession().setAttribute("tipoMensaje", "danger");
                    response.sendRedirect(request.getContextPath() + "/administrador/ConductorServlet");
                }
            }
        } else {
            // Si la acción no es reconocida, devolver error
            String acceptHeader = request.getHeader("Accept");
            boolean isAjaxRequest = acceptHeader != null && acceptHeader.contains("application/json");
            
            if (isAjaxRequest) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                Gson gson = new Gson();
                Map<String, Object> resultado = new HashMap<>();
                resultado.put("exito", false);
                resultado.put("mensaje", "Acción no reconocida: " + (action != null ? action : "null"));
                response.getWriter().write(gson.toJson(resultado));
            } else {
                request.getSession().setAttribute("mensaje", "Acción no reconocida.");
                request.getSession().setAttribute("tipoMensaje", "danger");
                response.sendRedirect(request.getContextPath() + "/administrador/ConductorServlet");
            }
        }
    }

    private void obtenerConductorJson(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        Gson gson = new Gson();
        try {
            int idConductor = Integer.parseInt(request.getParameter("id"));
            Conductor conductor = new ConductorDAO().buscarConductorPorId(idConductor);
            if (conductor != null) {
                Map<String, Object> conductorData = new HashMap<>();
                conductorData.put("idConductor", conductor.getIdConductor());
                conductorData.put("nombreCompleto", conductor.getNombreCompleto() != null ? conductor.getNombreCompleto() : "");
                conductorData.put("licencia", conductor.getLicencia() != null ? conductor.getLicencia() : "");
                conductorData.put("telefono", conductor.getTelefono() != null ? conductor.getTelefono() : "");
                conductorData.put("email", conductor.getEmail() != null ? conductor.getEmail() : "");
                conductorData.put("dni", conductor.getDni() != null ? conductor.getDni() : "");
                conductorData.put("tipoLicencia", conductor.getTipoLicencia() != null ? conductor.getTipoLicencia() : "");
                
                // Formatear la fecha como string para evitar problemas de serialización
                if (conductor.getFechaVencimientoLicencia() != null) {
                    conductorData.put("fechaVencimientoLicencia", conductor.getFechaVencimientoLicencia().toString());
                } else {
                    conductorData.put("fechaVencimientoLicencia", null);
                }
                
                response.getWriter().write(gson.toJson(conductorData));
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                Map<String, Object> error = new HashMap<>();
                error.put("exito", false);
                error.put("mensaje", "Conductor no encontrado");
                response.getWriter().write(gson.toJson(error));
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            Map<String, Object> error = new HashMap<>();
            error.put("exito", false);
            error.put("mensaje", "ID de conductor inválido");
            response.getWriter().write(gson.toJson(error));
        } catch (Exception e) {
            System.err.println("Error al obtener conductor en JSON: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            Map<String, Object> error = new HashMap<>();
            error.put("exito", false);
            error.put("mensaje", "Error interno del servidor: " + e.getMessage());
            response.getWriter().write(gson.toJson(error));
        }
    }
}

