package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.util.AuthorizationHelper;
import com.example.telito.util.FileUploadUtil;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;

@WebServlet(name = "PerfilServlet", value = "/perfil")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,    // 1 MB
    maxFileSize = 1024 * 1024 * 5,      // 5 MB
    maxRequestSize = 1024 * 1024 * 10   // 10 MB
)
public class PerfilServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        // Verificar que el usuario esté autenticado (todos los roles pueden acceder a su perfil)
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }
        
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        Usuario usuarioActualizado = usuarioDAO.obtenerUsuarioPorId(usuario.getIdUsuario());

        if (usuarioActualizado != null) {
            request.setAttribute("usuarioPerfil", usuarioActualizado);
            RequestDispatcher view = request.getRequestDispatcher("/perfil.jsp");
            view.forward(request, response);
        } else {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/acceso/login?errorMsg=Usuario no encontrado.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        // Verificar que el usuario esté autenticado (todos los roles pueden actualizar su perfil)
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }

        // Manejar solicitud de limpiar referer
        String clearReferer = request.getParameter("clearReferer");
        if ("true".equals(clearReferer)) {
            session.removeAttribute("perfilReferer");
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        
        // Obtener los datos del formulario
        String nombres = request.getParameter("nombres");
        String apellidos = request.getParameter("apellidos");
        String fotoPerfilUrl = request.getParameter("fotoPerfil");
        
        // Validaciones básicas
        if (nombres == null || nombres.trim().isEmpty() || 
            apellidos == null || apellidos.trim().isEmpty()) {
            request.setAttribute("error", "Los nombres y apellidos son obligatorios");
            doGet(request, response);
            return;
        }
        
        String fotoPerfil = null;
        
        try {
            // Verificar si se subió un archivo
            Part filePart = request.getPart("fotoPerfilArchivo");
            
            if (filePart != null && filePart.getSize() > 0) {
                // Se subió un archivo local
                String uploadPath = getServletContext().getRealPath("/");
                
                // Eliminar foto anterior si existe y no es URL externa
                String fotoAnterior = usuario.getFotoPerfil();
                if (fotoAnterior != null && !fotoAnterior.startsWith("http")) {
                    FileUploadUtil.deleteProfilePhoto(fotoAnterior, uploadPath);
                }
                
                // Guardar el nuevo archivo
                fotoPerfil = FileUploadUtil.saveProfilePhoto(filePart, uploadPath);
                
            } else if (fotoPerfilUrl != null && !fotoPerfilUrl.trim().isEmpty()) {
                // Se proporcionó una URL
                fotoPerfil = fotoPerfilUrl.trim();
            } else {
                // Mantener la foto actual si no se cambió nada
                fotoPerfil = usuario.getFotoPerfil();
            }
            
            // Actualizar en la base de datos
            UsuarioDAO usuarioDAO = new UsuarioDAO();
            usuarioDAO.actualizarPerfil(usuario.getIdUsuario(), nombres.trim(), apellidos.trim(), fotoPerfil);
            
            // Actualizar el usuario en la sesión
            usuario.setNombres(nombres.trim());
            usuario.setApellidos(apellidos.trim());
            usuario.setFotoPerfil(fotoPerfil);
            session.setAttribute("usuario", usuario);
            session.setAttribute("usuarioNombre", nombres.trim() + " " + apellidos.trim());
            
            // Redirigir con mensaje de éxito
            response.sendRedirect(request.getContextPath() + "/perfil?successMsg=Perfil actualizado correctamente");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al actualizar el perfil: " + e.getMessage());
            doGet(request, response);
        }
    }
}

