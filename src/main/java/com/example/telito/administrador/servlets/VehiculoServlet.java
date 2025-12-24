package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Vehiculo;
import com.example.telito.administrador.daos.VehiculoDAO;
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

// Gestión de vehículos - CRUD completo
@WebServlet(name = "VehiculoServlet", value = "/administrador/VehiculoServlet")
public class VehiculoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Solo administradores
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a VehiculoServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        String action = request.getParameter("action");
        VehiculoDAO vehiculoDAO = new VehiculoDAO();

        if (action == null) {
            action = "listar";
        }

        switch (action) {
            case "listar":
                int page = 1;
                int size = 5;
                String busqueda = request.getParameter("busqueda");
                try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
                try { size = Integer.parseInt(request.getParameter("size")); } catch (Exception ignored) {}
                if (page < 1) page = 1;
                if (size < 1) size = 5;

                int totalRows = vehiculoDAO.contarVehiculos(busqueda);
                int totalPages = (int) Math.ceil(totalRows / (double) size);
                if (totalPages == 0) totalPages = 1;
                if (page > totalPages) page = totalPages;

                // Estadísticas generales (sin filtros)
                int totalVehiculos = vehiculoDAO.contarTotalVehiculos();
                int vehiculosConPlanes = vehiculoDAO.contarVehiculosConPlanes();
                int vehiculosSinPlanes = vehiculoDAO.contarVehiculosSinPlanes();

                ArrayList<Vehiculo> listaVehiculos = vehiculoDAO.listarVehiculos(busqueda, page, size);
                request.setAttribute("listaVehiculos", listaVehiculos);
                request.setAttribute("currentPage", page);
                request.setAttribute("size", size);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalRows", totalRows);
                request.setAttribute("busqueda", busqueda);
                request.setAttribute("totalVehiculos", totalVehiculos);
                request.setAttribute("vehiculosConPlanes", vehiculosConPlanes);
                request.setAttribute("vehiculosSinPlanes", vehiculosSinPlanes);
                request.setAttribute("baseUrl", request.getContextPath() + "/administrador/VehiculoServlet");
                request.setAttribute("param1Name", "action");
                request.setAttribute("param1Value", "listar");
                request.setAttribute("itemName", "vehículos");

                RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/gestion-vehiculos.jsp");
                dispatcher.forward(request, response);
                break;

            case "crear":
                RequestDispatcher dispatcherCrear = request.getRequestDispatcher("/administrador/crear-vehiculo.jsp");
                dispatcherCrear.forward(request, response);
                break;

            case "editar":
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Vehiculo vehiculoEditar = vehiculoDAO.buscarVehiculoPorId(idEditar);
                request.setAttribute("vehiculo", vehiculoEditar);
                RequestDispatcher dispatcherEditar = request.getRequestDispatcher("/administrador/editar-vehiculo.jsp");
                dispatcherEditar.forward(request, response);
                break;

            case "obtenerVehiculoJson":
                obtenerVehiculoJson(request, response);
                break;

            case "eliminar":
                int idEliminar = Integer.parseInt(request.getParameter("id"));
                try {
                    boolean eliminado = vehiculoDAO.eliminarVehiculo(idEliminar);
                    if (eliminado) {
                        request.getSession().setAttribute("mensaje", "Vehículo eliminado exitosamente.");
                        request.getSession().setAttribute("tipoMensaje", "success");
                    } else {
                        request.getSession().setAttribute("mensaje", "Error al eliminar el vehículo. El vehículo no existe.");
                        request.getSession().setAttribute("tipoMensaje", "danger");
                    }
                } catch (RuntimeException e) {
                    // Capturar el mensaje específico sobre planes de transporte asociados
                    String mensajeError = e.getMessage();
                    if (mensajeError != null && mensajeError.contains("planes de transporte")) {
                        request.getSession().setAttribute("mensaje", mensajeError);
                        request.getSession().setAttribute("tipoMensaje", "warning");
                    } else {
                        request.getSession().setAttribute("mensaje", "Error al eliminar el vehículo: " + (mensajeError != null ? mensajeError : "Error desconocido"));
                        request.getSession().setAttribute("tipoMensaje", "danger");
                    }
                    System.err.println("Error al eliminar vehículo: " + e.getMessage());
                    e.printStackTrace();
                } catch (Exception e) {
                    request.getSession().setAttribute("mensaje", "Error inesperado al eliminar el vehículo.");
                    request.getSession().setAttribute("tipoMensaje", "danger");
                    System.err.println("Error inesperado al eliminar vehículo: " + e.getMessage());
                    e.printStackTrace();
                }
                response.sendRedirect(request.getContextPath() + "/administrador/VehiculoServlet");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Verificar que el usuario tenga rol de administrador
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a VehiculoServlet (POST) desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        VehiculoDAO vehiculoDAO = new VehiculoDAO();
        
        // Log para depuración
        System.out.println("VehiculoServlet POST - Action recibido: " + action);
        System.out.println("VehiculoServlet POST - Parámetros recibidos: id=" + request.getParameter("id") + 
                          ", placa=" + request.getParameter("placa") + 
                          ", marca=" + request.getParameter("marca") + 
                          ", modelo=" + request.getParameter("modelo") + 
                          ", capacidadKg=" + request.getParameter("capacidadKg"));

        if ("guardar".equals(action)) {
            String placa = request.getParameter("placa");
            String marca = request.getParameter("marca");
            String modelo = request.getParameter("modelo");
            int capacidadKg = Integer.parseInt(request.getParameter("capacidadKg"));
            String añoStr = request.getParameter("año");
            String tipoCombustible = request.getParameter("tipoCombustible");
            String numeroSerieVin = request.getParameter("numeroSerieVin");
            String fechaUltimaRevisionStr = request.getParameter("fechaUltimaRevision");
            String fechaVencimientoSoatStr = request.getParameter("fechaVencimientoSoat");

            Vehiculo vehiculo = new Vehiculo();
            vehiculo.setPlaca(placa);
            vehiculo.setMarca(marca);
            vehiculo.setModelo(modelo);
            vehiculo.setCapacidadKg(capacidadKg);
            
            // Nuevos campos
            if (añoStr != null && !añoStr.trim().isEmpty()) {
                try {
                    vehiculo.setAño(Integer.parseInt(añoStr));
                } catch (NumberFormatException e) {
                    vehiculo.setAño(null);
                }
            } else {
                vehiculo.setAño(null);
            }
            vehiculo.setTipoCombustible(tipoCombustible != null && !tipoCombustible.trim().isEmpty() ? tipoCombustible : null);
            vehiculo.setNumeroSerieVin(numeroSerieVin != null && !numeroSerieVin.trim().isEmpty() ? numeroSerieVin : null);
            
            // Convertir fechas de String a Date
            if (fechaUltimaRevisionStr != null && !fechaUltimaRevisionStr.trim().isEmpty()) {
                try {
                    vehiculo.setFechaUltimaRevision(java.sql.Date.valueOf(fechaUltimaRevisionStr));
                } catch (IllegalArgumentException e) {
                    vehiculo.setFechaUltimaRevision(null);
                }
            } else {
                vehiculo.setFechaUltimaRevision(null);
            }
            
            if (fechaVencimientoSoatStr != null && !fechaVencimientoSoatStr.trim().isEmpty()) {
                try {
                    vehiculo.setFechaVencimientoSoat(java.sql.Date.valueOf(fechaVencimientoSoatStr));
                } catch (IllegalArgumentException e) {
                    vehiculo.setFechaVencimientoSoat(null);
                }
            } else {
                vehiculo.setFechaVencimientoSoat(null);
            }

            boolean creado = vehiculoDAO.crearVehiculo(vehiculo);
            if (creado) {
                request.getSession().setAttribute("mensaje", "Vehículo creado exitosamente.");
                request.getSession().setAttribute("tipoMensaje", "success");
            } else {
                request.getSession().setAttribute("mensaje", "Error al crear el vehículo.");
                request.getSession().setAttribute("tipoMensaje", "danger");
            }
            response.sendRedirect(request.getContextPath() + "/administrador/VehiculoServlet");

        } else if ("actualizar".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                String placa = request.getParameter("placa");
                String marca = request.getParameter("marca");
                String modelo = request.getParameter("modelo");
                String capacidadKgStr = request.getParameter("capacidadKg");

                // Validar que los parámetros requeridos no estén vacíos
                if (placa == null || placa.trim().isEmpty()) {
                    throw new IllegalArgumentException("La placa es requerida.");
                }
                if (capacidadKgStr == null || capacidadKgStr.trim().isEmpty()) {
                    throw new IllegalArgumentException("La capacidad es requerida.");
                }

                int capacidadKg;
                try {
                    capacidadKg = Integer.parseInt(capacidadKgStr);
                    if (capacidadKg <= 0) {
                        throw new IllegalArgumentException("La capacidad debe ser mayor a 0.");
                    }
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("La capacidad debe ser un número válido.");
                }

                Vehiculo vehiculo = new Vehiculo();
                vehiculo.setIdVehiculo(id);
                vehiculo.setPlaca(placa.trim());
                vehiculo.setMarca(marca != null ? marca.trim() : null);
                vehiculo.setModelo(modelo != null ? modelo.trim() : null);
                vehiculo.setCapacidadKg(capacidadKg);
                
                // Nuevos campos
                String añoStr = request.getParameter("año");
                String tipoCombustible = request.getParameter("tipoCombustible");
                String numeroSerieVin = request.getParameter("numeroSerieVin");
                String fechaUltimaRevisionStr = request.getParameter("fechaUltimaRevision");
                String fechaVencimientoSoatStr = request.getParameter("fechaVencimientoSoat");
                
                if (añoStr != null && !añoStr.trim().isEmpty()) {
                    try {
                        vehiculo.setAño(Integer.parseInt(añoStr));
                    } catch (NumberFormatException e) {
                        vehiculo.setAño(null);
                    }
                } else {
                    vehiculo.setAño(null);
                }
                vehiculo.setTipoCombustible(tipoCombustible != null && !tipoCombustible.trim().isEmpty() ? tipoCombustible.trim() : null);
                vehiculo.setNumeroSerieVin(numeroSerieVin != null && !numeroSerieVin.trim().isEmpty() ? numeroSerieVin.trim() : null);
                
                // Convertir fechas de String a Date
                if (fechaUltimaRevisionStr != null && !fechaUltimaRevisionStr.trim().isEmpty()) {
                    try {
                        vehiculo.setFechaUltimaRevision(java.sql.Date.valueOf(fechaUltimaRevisionStr));
                    } catch (IllegalArgumentException e) {
                        vehiculo.setFechaUltimaRevision(null);
                    }
                } else {
                    vehiculo.setFechaUltimaRevision(null);
                }
                
                if (fechaVencimientoSoatStr != null && !fechaVencimientoSoatStr.trim().isEmpty()) {
                    try {
                        vehiculo.setFechaVencimientoSoat(java.sql.Date.valueOf(fechaVencimientoSoatStr));
                    } catch (IllegalArgumentException e) {
                        vehiculo.setFechaVencimientoSoat(null);
                    }
                } else {
                    vehiculo.setFechaVencimientoSoat(null);
                }

                boolean actualizado = vehiculoDAO.actualizarVehiculo(vehiculo);
                
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
                        resultado.put("mensaje", "Vehículo actualizado exitosamente.");
                    } else {
                        resultado.put("exito", false);
                        resultado.put("mensaje", "Error al actualizar el vehículo. El vehículo no existe o no se pudo actualizar.");
                    }
                    response.getWriter().write(gson.toJson(resultado));
                } else {
                    if (actualizado) {
                        request.getSession().setAttribute("mensaje", "Vehículo actualizado exitosamente.");
                        request.getSession().setAttribute("tipoMensaje", "success");
                    } else {
                        request.getSession().setAttribute("mensaje", "Error al actualizar el vehículo. El vehículo no existe o no se pudo actualizar.");
                        request.getSession().setAttribute("tipoMensaje", "danger");
                    }
                    response.sendRedirect(request.getContextPath() + "/administrador/VehiculoServlet");
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
                    resultado.put("mensaje", "ID de vehículo inválido.");
                    response.getWriter().write(gson.toJson(resultado));
                } else {
                    request.getSession().setAttribute("mensaje", "ID de vehículo inválido.");
                    request.getSession().setAttribute("tipoMensaje", "danger");
                    response.sendRedirect(request.getContextPath() + "/administrador/VehiculoServlet");
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
                    response.sendRedirect(request.getContextPath() + "/administrador/VehiculoServlet");
                }
            } catch (RuntimeException e) {
                System.err.println("Error al actualizar vehículo: " + e.getMessage());
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
                    resultado.put("mensaje", "Error al actualizar el vehículo: " + e.getMessage());
                    response.getWriter().write(gson.toJson(resultado));
                } else {
                    request.getSession().setAttribute("mensaje", "Error al actualizar el vehículo: " + e.getMessage());
                    request.getSession().setAttribute("tipoMensaje", "danger");
                    response.sendRedirect(request.getContextPath() + "/administrador/VehiculoServlet");
                }
            } catch (Exception e) {
                System.err.println("Error inesperado al actualizar vehículo: " + e.getMessage());
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
                    resultado.put("mensaje", "Error inesperado al actualizar el vehículo.");
                    response.getWriter().write(gson.toJson(resultado));
                } else {
                    request.getSession().setAttribute("mensaje", "Error inesperado al actualizar el vehículo.");
                    request.getSession().setAttribute("tipoMensaje", "danger");
                    response.sendRedirect(request.getContextPath() + "/administrador/VehiculoServlet");
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
                response.sendRedirect(request.getContextPath() + "/administrador/VehiculoServlet");
            }
        }
    }

    private void obtenerVehiculoJson(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        Gson gson = new Gson();
        try {
            int idVehiculo = Integer.parseInt(request.getParameter("id"));
            Vehiculo vehiculo = new VehiculoDAO().buscarVehiculoPorId(idVehiculo);
            if (vehiculo != null) {
                Map<String, Object> vehiculoData = new HashMap<>();
                vehiculoData.put("idVehiculo", vehiculo.getIdVehiculo());
                vehiculoData.put("placa", vehiculo.getPlaca() != null ? vehiculo.getPlaca() : "");
                vehiculoData.put("marca", vehiculo.getMarca() != null ? vehiculo.getMarca() : "");
                vehiculoData.put("modelo", vehiculo.getModelo() != null ? vehiculo.getModelo() : "");
                vehiculoData.put("capacidadKg", vehiculo.getCapacidadKg());
                vehiculoData.put("año", vehiculo.getAño());
                vehiculoData.put("tipoCombustible", vehiculo.getTipoCombustible() != null ? vehiculo.getTipoCombustible() : "");
                vehiculoData.put("numeroSerieVin", vehiculo.getNumeroSerieVin() != null ? vehiculo.getNumeroSerieVin() : "");
                
                // Formatear fechas como string para evitar problemas de serialización
                if (vehiculo.getFechaUltimaRevision() != null) {
                    vehiculoData.put("fechaUltimaRevision", vehiculo.getFechaUltimaRevision().toString());
                } else {
                    vehiculoData.put("fechaUltimaRevision", null);
                }
                if (vehiculo.getFechaVencimientoSoat() != null) {
                    vehiculoData.put("fechaVencimientoSoat", vehiculo.getFechaVencimientoSoat().toString());
                } else {
                    vehiculoData.put("fechaVencimientoSoat", null);
                }
                
                response.getWriter().write(gson.toJson(vehiculoData));
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                Map<String, Object> error = new HashMap<>();
                error.put("exito", false);
                error.put("mensaje", "Vehículo no encontrado");
                response.getWriter().write(gson.toJson(error));
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            Map<String, Object> error = new HashMap<>();
            error.put("exito", false);
            error.put("mensaje", "ID de vehículo inválido");
            response.getWriter().write(gson.toJson(error));
        } catch (Exception e) {
            System.err.println("Error al obtener vehículo en JSON: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            Map<String, Object> error = new HashMap<>();
            error.put("exito", false);
            error.put("mensaje", "Error interno del servidor");
            response.getWriter().write(gson.toJson(error));
        }
    }
}

