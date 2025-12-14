package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.NotificacionDAO;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// Gestión de notificaciones web en tiempo real - API JSON
@WebServlet(name = "NotificacionServlet", value = "/NotificacionServlet")
public class NotificacionServlet extends HttpServlet {

    private NotificacionDAO notificacionDAO = new NotificacionDAO();
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            enviarRespuestaJSON(response, false, "Sesión no válida", null);
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        String action = request.getParameter("action");

        if (action == null) {
            action = "obtener";
        }

        switch (action) {
            case "obtener":
                obtenerNotificaciones(request, response, usuario);
                break;
            case "contador":
                obtenerContador(response, usuario);
                break;
            case "recientes":
                obtenerRecientes(response, usuario);
                break;
            default:
                enviarRespuestaJSON(response, false, "Acción no válida", null);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            enviarRespuestaJSON(response, false, "Sesión no válida", null);
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        String action = request.getParameter("action");

        if (action == null) {
            enviarRespuestaJSON(response, false, "Acción requerida", null);
            return;
        }

        switch (action) {
            case "marcarLeida":
                marcarComoLeida(request, response, usuario);
                break;
            case "marcarTodasLeidas":
                marcarTodasComoLeidas(response, usuario);
                break;
            case "eliminar":
                eliminarNotificacion(request, response, usuario);
                break;
            case "eliminarLeidas":
                eliminarNotificacionesLeidas(response, usuario);
                break;
            default:
                enviarRespuestaJSON(response, false, "Acción no válida", null);
                break;
        }
    }

    /**
     * Obtiene todas las notificaciones del usuario con paginación
     */
    private void obtenerNotificaciones(HttpServletRequest request, HttpServletResponse response, Usuario usuario) 
            throws IOException {
        try {
            // Parámetros de paginación
            String limitParam = request.getParameter("limit");
            String offsetParam = request.getParameter("offset");
            String soloNoLeidasParam = request.getParameter("soloNoLeidas");
            
            int limit = (limitParam != null) ? Integer.parseInt(limitParam) : 20;
            int offset = (offsetParam != null) ? Integer.parseInt(offsetParam) : 0;
            boolean soloNoLeidas = "true".equals(soloNoLeidasParam);
            
            List<Map<String, Object>> notificaciones = notificacionDAO.obtenerNotificacionesPorUsuario(
                usuario.getIdUsuario(), limit, offset, soloNoLeidas
            );
            
            int totalNoLeidas = notificacionDAO.contarNotificacionesNoLeidas(usuario.getIdUsuario());
            int totalGeneral = notificacionDAO.contarNotificacionesPorUsuario(usuario.getIdUsuario());
            
            Map<String, Object> resultado = new HashMap<>();
            resultado.put("notificaciones", notificaciones);
            resultado.put("totalNoLeidas", totalNoLeidas);
            resultado.put("totalGeneral", totalGeneral);
            resultado.put("limit", limit);
            resultado.put("offset", offset);
            
            enviarRespuestaJSON(response, true, "Notificaciones obtenidas", resultado);
            
        } catch (Exception e) {
            System.err.println("ERROR al obtener notificaciones: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaJSON(response, false, "Error al obtener notificaciones: " + e.getMessage(), null);
        }
    }

    /**
     * Obtiene solo el contador de notificaciones no leídas
     */
    private void obtenerContador(HttpServletResponse response, Usuario usuario) throws IOException {
        try {
            int contador = notificacionDAO.contarNotificacionesNoLeidas(usuario.getIdUsuario());
            
            Map<String, Object> resultado = new HashMap<>();
            resultado.put("contador", contador);
            resultado.put("tieneNotificaciones", contador > 0);
            
            enviarRespuestaJSON(response, true, "Contador obtenido", resultado);
            
        } catch (Exception e) {
            System.err.println("ERROR al obtener contador: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaJSON(response, false, "Error al obtener contador", null);
        }
    }

    /**
     * Obtiene las últimas 5 notificaciones no leídas (para el dropdown)
     */
    private void obtenerRecientes(HttpServletResponse response, Usuario usuario) throws IOException {
        try {
            List<Map<String, Object>> notificaciones = notificacionDAO.obtenerNotificacionesRecientes(
                usuario.getIdUsuario(), 5
            );
            
            int totalNoLeidas = notificacionDAO.contarNotificacionesNoLeidas(usuario.getIdUsuario());
            
            Map<String, Object> resultado = new HashMap<>();
            resultado.put("notificaciones", notificaciones);
            resultado.put("totalNoLeidas", totalNoLeidas);
            
            enviarRespuestaJSON(response, true, "Notificaciones recientes obtenidas", resultado);
            
        } catch (Exception e) {
            System.err.println("ERROR al obtener notificaciones recientes: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaJSON(response, false, "Error al obtener notificaciones recientes", null);
        }
    }

    /**
     * Marca una notificación específica como leída
     */
    private void marcarComoLeida(HttpServletRequest request, HttpServletResponse response, Usuario usuario) 
            throws IOException {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                enviarRespuestaJSON(response, false, "ID de notificación requerido", null);
                return;
            }
            
            int idNotificacion = Integer.parseInt(idParam);
            
            // Verificar que la notificación pertenece al usuario
            if (!notificacionDAO.notificacionPerteneceAUsuario(idNotificacion, usuario.getIdUsuario())) {
                enviarRespuestaJSON(response, false, "No tiene permiso para marcar esta notificación", null);
                return;
            }
            
            boolean exito = notificacionDAO.marcarComoLeida(idNotificacion);
            
            if (exito) {
                int nuevoContador = notificacionDAO.contarNotificacionesNoLeidas(usuario.getIdUsuario());
                Map<String, Object> resultado = new HashMap<>();
                resultado.put("nuevoContador", nuevoContador);
                
                enviarRespuestaJSON(response, true, "Notificación marcada como leída", resultado);
            } else {
                enviarRespuestaJSON(response, false, "Error al marcar como leída", null);
            }
            
        } catch (NumberFormatException e) {
            enviarRespuestaJSON(response, false, "ID de notificación inválido", null);
        } catch (Exception e) {
            System.err.println("ERROR al marcar como leída: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaJSON(response, false, "Error al marcar como leída: " + e.getMessage(), null);
        }
    }

    /**
     * Marca todas las notificaciones del usuario como leídas
     */
    private void marcarTodasComoLeidas(HttpServletResponse response, Usuario usuario) throws IOException {
        try {
            int notificacionesMarcadas = notificacionDAO.marcarTodasComoLeidas(usuario.getIdUsuario());
            
            Map<String, Object> resultado = new HashMap<>();
            resultado.put("notificacionesMarcadas", notificacionesMarcadas);
            resultado.put("nuevoContador", 0);
            
            enviarRespuestaJSON(response, true, 
                "Se marcaron " + notificacionesMarcadas + " notificación(es) como leídas", 
                resultado);
            
        } catch (Exception e) {
            System.err.println("ERROR al marcar todas como leídas: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaJSON(response, false, "Error al marcar todas como leídas: " + e.getMessage(), null);
        }
    }

    /**
     * Elimina una notificación específica
     */
    private void eliminarNotificacion(HttpServletRequest request, HttpServletResponse response, Usuario usuario) 
            throws IOException {
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                enviarRespuestaJSON(response, false, "ID de notificación requerido", null);
                return;
            }
            
            int idNotificacion = Integer.parseInt(idParam);
            
            // Verificar que la notificación pertenece al usuario
            if (!notificacionDAO.notificacionPerteneceAUsuario(idNotificacion, usuario.getIdUsuario())) {
                enviarRespuestaJSON(response, false, "No tiene permiso para eliminar esta notificación", null);
                return;
            }
            
            boolean exito = notificacionDAO.eliminarNotificacion(idNotificacion);
            
            if (exito) {
                int nuevoContador = notificacionDAO.contarNotificacionesNoLeidas(usuario.getIdUsuario());
                Map<String, Object> resultado = new HashMap<>();
                resultado.put("nuevoContador", nuevoContador);
                
                enviarRespuestaJSON(response, true, "Notificación eliminada", resultado);
            } else {
                enviarRespuestaJSON(response, false, "Error al eliminar notificación", null);
            }
            
        } catch (NumberFormatException e) {
            enviarRespuestaJSON(response, false, "ID de notificación inválido", null);
        } catch (Exception e) {
            System.err.println("ERROR al eliminar notificación: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaJSON(response, false, "Error al eliminar: " + e.getMessage(), null);
        }
    }

    /**
     * Elimina todas las notificaciones leídas del usuario
     */
    private void eliminarNotificacionesLeidas(HttpServletResponse response, Usuario usuario) throws IOException {
        try {
            int notificacionesEliminadas = notificacionDAO.eliminarNotificacionesLeidas(usuario.getIdUsuario());
            
            Map<String, Object> resultado = new HashMap<>();
            resultado.put("notificacionesEliminadas", notificacionesEliminadas);
            
            enviarRespuestaJSON(response, true, 
                "Se eliminaron " + notificacionesEliminadas + " notificación(es) leídas", 
                resultado);
            
        } catch (Exception e) {
            System.err.println("ERROR al eliminar notificaciones leídas: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaJSON(response, false, "Error al eliminar notificaciones: " + e.getMessage(), null);
        }
    }

    /**
     * Envía una respuesta JSON estandarizada
     */
    private void enviarRespuestaJSON(HttpServletResponse response, boolean exito, String mensaje, Object datos) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        Map<String, Object> respuesta = new HashMap<>();
        respuesta.put("exito", exito);
        respuesta.put("mensaje", mensaje);
        respuesta.put("datos", datos);
        respuesta.put("timestamp", System.currentTimeMillis());
        
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(respuesta));
        out.flush();
    }
}
