package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.administrador.beans.Rol;
import com.example.telito.util.EmailUtil;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

@WebServlet(name = "UsuarioServlet", value = "/UsuarioServlet")
public class UsuarioServlet extends HttpServlet {

    // doGet para mostrar las vistas o para acciones simples que no vienen de un form.
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        HttpSession session = request.getSession();
        RequestDispatcher view;

        switch (action) {

            case "listar":
                // Recojo todos los parámetros de los filtros de la página.
                String busqueda = request.getParameter("busqueda");
                String rolId = request.getParameter("rol");
                String estado = request.getParameter("estado");
                String sortBy = request.getParameter("sortBy");
                String sortOrder = request.getParameter("sortOrder");
                // Paginación
                int page = 1;
                int size = 10;
                try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
                try { size = Integer.parseInt(request.getParameter("size")); } catch (Exception ignored) {}
                if (page < 1) page = 1;
                if (size < 1) size = 10;

                // Le paso todo al DAO para que arme la consulta SQL.
                int totalRows = usuarioDAO.contarUsuarios(busqueda, rolId, estado);
                int totalPages = (int) Math.ceil(totalRows / (double) size);
                if (totalPages == 0) totalPages = 1;
                if (page > totalPages) page = totalPages;
                ArrayList<Usuario> listaUsuarios = usuarioDAO.listarUsuarios(busqueda, rolId, estado, sortBy, sortOrder, page, size);

                // Devuelvo los datos a la página para que se muestre la tabla.
                request.setAttribute("lista", listaUsuarios);
                // También devuelvo los filtros para que se queden seleccionados.
                request.setAttribute("busqueda", busqueda);
                request.setAttribute("rolFiltro", rolId);
                request.setAttribute("estadoFiltro", estado);
                request.setAttribute("sortBy", sortBy);
                request.setAttribute("sortOrder", sortOrder);
                // Atributos de paginación
                request.setAttribute("currentPage", page);
                request.setAttribute("size", size);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalRows", totalRows);

                view = request.getRequestDispatcher("/administrador/gestion_de_usuarios.jsp");
                view.forward(request, response);
                break;

            case "formCrear":
                // Solo me lleva al JSP para crear un usuario.
                view = request.getRequestDispatcher("/administrador/crear-usuario.jsp");
                view.forward(request, response);
                break;

            case "editar":
                // Busco el usuario en la BD y lo mando al JSP para que rellene el formulario.
                try {
                    int idUsuario = Integer.parseInt(request.getParameter("id"));
                    Usuario usuario = usuarioDAO.obtenerUsuarioPorId(idUsuario);
                    if (usuario != null) {
                        request.setAttribute("usuario", usuario);
                        view = request.getRequestDispatcher("/administrador/editar-usuario.jsp");
                        view.forward(request, response);
                    } else {
                        session.setAttribute("errorMsg", "El usuario que se intenta editar no existe.");
                        response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "El ID del usuario no es válido.");
                    response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                }
                break;

            case "borrar":
                // Deshabilita al usuario (borrado lógico).
                try {
                    int idADeshabilitar = Integer.parseInt(request.getParameter("id"));
                    usuarioDAO.deshabilitarUsuario(idADeshabilitar);
                    session.setAttribute("successMsg", "Usuario deshabilitado con éxito.");
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "El ID para deshabilitar no es válido.");
                }
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                break;
        }
    }

    // doPost para cuando se envía un formulario (crear o actualizar).
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        HttpSession session = request.getSession();

        switch (action) {
            case "guardar":
                // ========== VALIDACIONES DE USUARIO ==========
                ArrayList<String> errores = new ArrayList<>();
                
                // 1. Validar que los parámetros obligatorios existan
                String nombres = request.getParameter("nombres");
                String apellidos = request.getParameter("apellidos");
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                String rolIdStr = request.getParameter("rol_id");
                
                if (nombres == null || nombres.trim().isEmpty()) {
                    errores.add("El nombre es obligatorio");
                }
                if (apellidos == null || apellidos.trim().isEmpty()) {
                    errores.add("Los apellidos son obligatorios");
                }
                if (email == null || email.trim().isEmpty()) {
                    errores.add("El email es obligatorio");
                }
                if (password == null || password.trim().isEmpty()) {
                    errores.add("La contraseña es obligatoria");
                }
                if (rolIdStr == null || rolIdStr.trim().isEmpty()) {
                    errores.add("Debe seleccionar un rol");
                }
                
                // 2. Validar longitudes máximas
                if (nombres != null && nombres.length() > 100) {
                    errores.add("El nombre no puede exceder 100 caracteres");
                }
                if (apellidos != null && apellidos.length() > 100) {
                    errores.add("Los apellidos no pueden exceder 100 caracteres");
                }
                if (email != null && email.length() > 100) {
                    errores.add("El email no puede exceder 100 caracteres");
                }
                if (password != null && password.length() > 100) {
                    errores.add("La contraseña no puede exceder 100 caracteres");
                }
                
                // 3. Validar formato de email
                if (email != null && !email.trim().isEmpty()) {
                    String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
                    if (!email.matches(emailRegex)) {
                        errores.add("El formato del email no es válido");
                    }
                }
                
                // 4. Validar complejidad de contraseña
                if (password != null && !password.trim().isEmpty()) {
                    if (password.length() < 4) {
                        errores.add("La contraseña debe tener al menos 4 caracteres");
                    }
                }
                
                // 5. Validar que el rol_id sea un número válido
                int rolId = 0;
                try {
                    rolId = Integer.parseInt(rolIdStr);
                    if (rolId <= 0) {
                        errores.add("El ID del rol no es válido");
                    }
                } catch (NumberFormatException e) {
                    errores.add("El ID del rol debe ser un número válido");
                }
                
                // 6. Validar que el email no esté registrado
                if (email != null && !email.trim().isEmpty()) {
                    if (usuarioDAO.existeEmail(email)) {
                        errores.add("El email '" + email + "' ya está registrado");
                    }
                }
                
                // Si hay errores, volver al formulario
                if (!errores.isEmpty()) {
                    request.setAttribute("errores", errores);
                    request.setAttribute("nombres", nombres);
                    request.setAttribute("apellidos", apellidos);
                    request.setAttribute("email", email);
                    request.setAttribute("rol_id", rolIdStr);
                    
                    RequestDispatcher view = request.getRequestDispatcher("/administrador/crear-usuario.jsp");
                    view.forward(request, response);
                    return;
                }
                
                // ========== TODO VÁLIDO - CREAR USUARIO ==========
                try {
                    Usuario usuarioNuevo = mapearUsuarioDesdeRequest(request);
                    String passwordOriginal = password; // Guardar antes de encriptar
                    
                    // Verificar si existe un usuario inactivo con ese email para reactivarlo
                    int idUsuarioInactivo = usuarioDAO.obtenerIdUsuarioPorEmail(email);
                    boolean creado = false;
                    
                    if (idUsuarioInactivo > 0) {
                        // Existe un usuario inactivo con ese email, reactivarlo y actualizarlo
                        System.out.println("🔄 Usuario inactivo encontrado con ese email (ID: " + idUsuarioInactivo + "). Reactivando...");
                        Usuario usuarioExistente = usuarioDAO.obtenerUsuarioPorId(idUsuarioInactivo);
                        if (usuarioExistente != null && !usuarioExistente.isActivo()) {
                            // Asegurar que el email esté asignado correctamente
                            if (usuarioExistente.getEmail() == null || usuarioExistente.getEmail().trim().isEmpty()) {
                                usuarioExistente.setEmail(email); // Usar el email del request
                            }
                            
                            // Actualizar datos del usuario existente
                            usuarioExistente.setNombres(usuarioNuevo.getNombres());
                            usuarioExistente.setApellidos(usuarioNuevo.getApellidos());
                            usuarioExistente.setPassword(usuarioNuevo.getPassword());
                            usuarioExistente.setRol(usuarioNuevo.getRol());
                            usuarioExistente.setActivo(true); // Reactivar
                            
                            creado = usuarioDAO.actualizarUsuarioConPassword(usuarioExistente);
                            
                            // Usar el usuario existente (con su ID) para el correo
                            if (creado) {
                                System.out.println("✓ Usuario reactivado exitosamente. Email: " + usuarioExistente.getEmail());
                                usuarioNuevo = usuarioExistente;
                            } else {
                                System.err.println("⚠ ERROR: No se pudo reactivar el usuario");
                            }
                        }
                    } else {
                        System.out.println("➕ Creando nuevo usuario con email: " + email);
                    }
                    
                    if (!creado) {
                        // No existe usuario inactivo, crear uno nuevo
                        creado = usuarioDAO.crearUsuario(usuarioNuevo);
                    }
                    
                    if (creado) {
                        // ========== ENVIAR CORREO DE BIENVENIDA AL NUEVO USUARIO ==========
                        try {
                            // Verificar que el usuario tenga email válido
                            String emailDestino = usuarioNuevo.getEmail();
                            if (emailDestino == null || emailDestino.trim().isEmpty()) {
                                System.err.println("⚠ ERROR: El usuario no tiene un email válido para enviar correo");
                            } else {
                                System.out.println("📧 Preparando envío de correo de bienvenida a: " + emailDestino);
                                
                                String nombreRol = usuarioDAO.obtenerNombreRolPorId(usuarioNuevo.getRol().getIdRol());
                                nombreRol = (nombreRol != null) ? nombreRol : "Usuario";
                                
                                // Construir el mensaje HTML escapando los % en los colores CSS
                                String mensaje = """
                                <html>
                                <head>
                                    <meta charset="UTF-8">
                                    <style>
                                        body { font-family: Arial, sans-serif; line-height: 1.6; color: #2b2d42; }
                                        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                                        .header { background: linear-gradient(160deg, #006d77 0%%, #055e68 100%%); 
                                                 color: white; padding: 25px; border-radius: 8px 8px 0 0; text-align: center; }
                                        .content { background: #edf6f9; padding: 25px; border-radius: 0 0 8px 8px; }
                                        .credentials { background: white; padding: 20px; border-radius: 5px; 
                                                     margin: 15px 0; border-left: 4px solid #006d77; }
                                        .credential-item { padding: 8px 0; border-bottom: 1px solid #e9ecef; }
                                        .credential-item:last-child { border-bottom: none; }
                                        .label { font-weight: bold; color: #006d77; }
                                        .value { color: #2b2d42; font-family: monospace; }
                                        .warning { background: #fff3cd; padding: 15px; border-radius: 5px; 
                                                  border-left: 4px solid #ffc107; margin: 15px 0; }
                                        .footer { margin-top: 20px; padding-top: 15px; border-top: 1px solid #e9ecef; 
                                                 font-size: 12px; color: #6c757d; text-align: center; }
                                        .button { display: inline-block; padding: 12px 30px; background: #006d77; 
                                                color: white; text-decoration: none; border-radius: 5px; 
                                                margin: 15px 0; transition: background 0.3s; }
                                        .button:hover { background: #055e68; }
                                    </style>
                                </head>
                                <body>
                                    <div class="container">
                                        <div class="header">
                                            <h2>¡Bienvenido a TELITO BODEGUERO!</h2>
                                        </div>
                                        <div class="content">
                                            <p>Estimado/a <strong>%s %s</strong>,</p>
                                            <p>Nos complace informarte que tu cuenta ha sido creada exitosamente en el sistema <strong>TELITO BODEGUERO</strong>.</p>
                                            
                                            <div class="credentials">
                                                <h3 style="margin-top: 0; color: #006d77;">📋 Credenciales de Acceso</h3>
                                                <div class="credential-item">
                                                    <span class="label">Email:</span> <span class="value">%s</span>
                                                </div>
                                                <div class="credential-item">
                                                    <span class="label">Contraseña temporal:</span> <span class="value">%s</span>
                                                </div>
                                                <div class="credential-item">
                                                    <span class="label">Rol asignado:</span> <span class="value">%s</span>
                                                </div>
                                            </div>
                                            
                                            <div class="warning">
                                                <strong>⚠️ Importante:</strong>
                                                <ul style="margin: 10px 0;">
                                                    <li>Por seguridad, cambia tu contraseña al iniciar sesión por primera vez</li>
                                                    <li>Guarda estas credenciales en un lugar seguro</li>
                                                    <li>Si no solicitaste esta cuenta, contacta al administrador inmediatamente</li>
                                                </ul>
                                            </div>
                                            
                                            <p><strong>Próximos pasos:</strong></p>
                                            <ol>
                                                <li>Accede al sistema usando las credenciales proporcionadas</li>
                                                <li>Cambia tu contraseña temporal por una contraseña segura</li>
                                                <li>Revisa tu perfil y completa tu información</li>
                                            </ol>
                                            
                                            <p style="text-align: center;">
                                                <a href="%s/acceso/login" class="button">Iniciar Sesión</a>
                                            </p>
                                            
                                            <div class="footer">
                                                <p>Este es un correo automático generado por el sistema TELITO BODEGUERO.</p>
                                                <p>Fecha de creación: %s</p>
                                            </div>
                                        </div>
                                    </div>
                                </body>
                                </html>
                                """.formatted(
                                    usuarioNuevo.getNombres(),
                                    usuarioNuevo.getApellidos(),
                                    usuarioNuevo.getEmail(),
                                    passwordOriginal,
                                    nombreRol,
                                    request.getContextPath(),
                                    new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())
                                );
                            
                                boolean correoEnviado = EmailUtil.sendSystemAlertHTML(
                                    emailDestino,
                                    "Bienvenido a TELITO BODEGUERO - Credenciales de Acceso",
                                    mensaje
                                );
                                
                                if (correoEnviado) {
                                    System.out.println("✓ Correo de bienvenida enviado exitosamente a: " + emailDestino);
                                } else {
                                    System.err.println("⚠ ERROR: No se pudo enviar el correo de bienvenida a: " + emailDestino);
                                    System.err.println("   Verifica la configuración de email en email.properties");
                                }
                            }
                        } catch (Exception e) {
                            // No bloquear la creación si falla el correo
                            System.err.println("⚠ ERROR al enviar correo de bienvenida: " + e.getMessage());
                            System.err.println("   Detalles completos del error:");
                            e.printStackTrace();
                        }
                        // ========== FIN ENVÍO DE CORREO ==========
                        
                        session.setAttribute("successMsg", "Usuario creado con éxito.");
                        response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                    } else {
                        errores.add("Error al guardar el usuario en la base de datos");
                        request.setAttribute("errores", errores);
                        request.setAttribute("nombres", nombres);
                        request.setAttribute("apellidos", apellidos);
                        request.setAttribute("email", email);
                        request.setAttribute("rol_id", rolIdStr);
                        
                        RequestDispatcher view = request.getRequestDispatcher("/administrador/crear-usuario.jsp");
                        view.forward(request, response);
                    }
                } catch (Exception e) {
                    System.err.println("Error al crear usuario: " + e.getMessage());
                    e.printStackTrace();
                    
                    errores.add("Error inesperado al crear el usuario. Por favor, contacte al administrador.");
                    request.setAttribute("errores", errores);
                    request.setAttribute("nombres", nombres);
                    request.setAttribute("apellidos", apellidos);
                    request.setAttribute("email", email);
                    request.setAttribute("rol_id", rolIdStr);
                    
                    RequestDispatcher view = request.getRequestDispatcher("/administrador/crear-usuario.jsp");
                    view.forward(request, response);
                }
                break;

            case "actualizar":
                // Lee los datos del form, actualiza la BD y redirige.
                try {
                    Usuario usuarioActualizado = mapearUsuarioDesdeRequest(request);
                    
                    // Obtener datos anteriores para comparar cambios
                    Usuario usuarioAnterior = usuarioDAO.obtenerUsuarioPorId(usuarioActualizado.getIdUsuario());
                    String passwordNueva = request.getParameter("password");
                    boolean passwordCambiada = passwordNueva != null && !passwordNueva.trim().isEmpty();
                    
                    usuarioDAO.actualizarUsuario(usuarioActualizado);
                    
                    // ========== ENVIAR CORREO DE CONFIRMACIÓN DE ACTUALIZACIÓN ==========
                    try {
                        if (usuarioAnterior != null) {
                            String nombreRol = usuarioDAO.obtenerNombreRolPorId(usuarioActualizado.getRol().getIdRol());
                            nombreRol = (nombreRol != null) ? nombreRol : "Usuario";
                            
                            // Detectar qué cambió
                            ArrayList<String> cambios = new ArrayList<>();
                            if (!usuarioAnterior.getNombres().equals(usuarioActualizado.getNombres()) || 
                                !usuarioAnterior.getApellidos().equals(usuarioActualizado.getApellidos())) {
                                cambios.add("Nombre y/o apellidos");
                            }
                            if (!usuarioAnterior.getEmail().equals(usuarioActualizado.getEmail())) {
                                cambios.add("Email: " + usuarioAnterior.getEmail() + " → " + usuarioActualizado.getEmail());
                            }
                            if (usuarioAnterior.getRol().getIdRol() != usuarioActualizado.getRol().getIdRol()) {
                                String nombreRolAnterior = usuarioDAO.obtenerNombreRolPorId(usuarioAnterior.getRol().getIdRol());
                                cambios.add("Rol: " + nombreRolAnterior + " → " + nombreRol);
                            }
                            if (usuarioAnterior.isActivo() != usuarioActualizado.isActivo()) {
                                cambios.add("Estado: " + (usuarioAnterior.isActivo() ? "Activo" : "Inactivo") + " → " + 
                                          (usuarioActualizado.isActivo() ? "Activo" : "Inactivo"));
                            }
                            
                            if (passwordCambiada) {
                                cambios.add("Contraseña (se cambió tu contraseña)");
                            }
                            
                            if (!cambios.isEmpty()) {
                                StringBuilder cambiosLista = new StringBuilder();
                                for (String cambio : cambios) {
                                    cambiosLista.append("<li>").append(cambio).append("</li>");
                                }
                                
                                // Construir el mensaje HTML escapando los % en los colores CSS
                                String mensaje = """
                                    <html>
                                    <head>
                                        <meta charset="UTF-8">
                                        <style>
                                            body { font-family: Arial, sans-serif; line-height: 1.6; color: #2b2d42; }
                                            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                                            .header { background: linear-gradient(160deg, #006d77 0%%, #055e68 100%%); 
                                                     color: white; padding: 25px; border-radius: 8px 8px 0 0; text-align: center; }
                                            .content { background: #edf6f9; padding: 25px; border-radius: 0 0 8px 8px; }
                                            .changes { background: white; padding: 20px; border-radius: 5px; 
                                                     margin: 15px 0; border-left: 4px solid #83c5be; }
                                            .warning { background: #fff3cd; padding: 15px; border-radius: 5px; 
                                                      border-left: 4px solid #ffc107; margin: 15px 0; }
                                            .footer { margin-top: 20px; padding-top: 15px; border-top: 1px solid #e9ecef; 
                                                     font-size: 12px; color: #6c757d; text-align: center; }
                                        </style>
                                    </head>
                                    <body>
                                        <div class="container">
                                            <div class="header">
                                                <h2>✅ Perfil Actualizado</h2>
                                            </div>
                                            <div class="content">
                                                <p>Estimado/a <strong>%s %s</strong>,</p>
                                                <p>Tu perfil de usuario ha sido actualizado exitosamente en el sistema <strong>TELITO BODEGUERO</strong>.</p>
                                                
                                                <div class="changes">
                                                    <h3 style="margin-top: 0; color: #006d77;">📝 Cambios Realizados</h3>
                                                    <ul>
                                                        %s
                                                    </ul>
                                                </div>
                                                
                                                <div class="warning">
                                                    <strong>⚠️ Importante:</strong>
                                                    %s
                                                </div>
                                                
                                                <p><strong>Información actualizada:</strong></p>
                                                <ul>
                                                    <li><strong>Email:</strong> %s</li>
                                                    <li><strong>Rol:</strong> %s</li>
                                                    <li><strong>Estado:</strong> %s</li>
                                                </ul>
                                                
                                                <p>Si no realizaste estos cambios, contacta al administrador inmediatamente.</p>
                                                
                                                <div class="footer">
                                                    <p>Este es un correo automático generado por el sistema TELITO BODEGUERO.</p>
                                                    <p>Fecha de actualización: %s</p>
                                                </div>
                                            </div>
                                        </div>
                                    </body>
                                    </html>
                                    """.formatted(
                                        usuarioActualizado.getNombres(),
                                        usuarioActualizado.getApellidos(),
                                        cambiosLista.toString(),
                                        passwordCambiada ? 
                                            "<ul><li>Si solicitaste el cambio de contraseña, ya puedes iniciar sesión con la nueva contraseña</li>" +
                                            "<li>Si NO solicitaste este cambio, contacta al administrador inmediatamente</li></ul>" :
                                            "<p>No se realizaron cambios en tu contraseña.</p>",
                                        usuarioActualizado.getEmail(),
                                        nombreRol,
                                        usuarioActualizado.isActivo() ? "Activo" : "Inactivo",
                                        new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())
                                    );
                                
                                // Determinar email de destino (si cambió el email, usar el anterior para enviar la notificación)
                                String emailDestino = !usuarioAnterior.getEmail().equals(usuarioActualizado.getEmail()) ? 
                                    usuarioAnterior.getEmail() : usuarioActualizado.getEmail();
                                
                                boolean correoEnviado = EmailUtil.sendSystemAlertHTML(
                                    emailDestino,
                                    "Perfil Actualizado - TELITO BODEGUERO",
                                    mensaje
                                );
                                
                                if (correoEnviado) {
                                    System.out.println("✓ Correo de confirmación de actualización enviado a: " + emailDestino);
                                } else {
                                    System.err.println("⚠ No se pudo enviar el correo de confirmación");
                                }
                            }
                        }
                    } catch (Exception e) {
                        // No bloquear la actualización si falla el correo
                        System.err.println("⚠ Error al enviar correo de confirmación de actualización: " + e.getMessage());
                        e.printStackTrace();
                    }
                    // ========== FIN ENVÍO DE CORREO ==========
                    
                    session.setAttribute("successMsg", "Usuario actualizado con éxito.");
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "Error al procesar los datos para actualizar.");
                }
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                break;
        }
    }

    // Helper para no repetir código. Convierte los datos del form a un objeto Usuario.
    private Usuario mapearUsuarioDesdeRequest(HttpServletRequest request) throws NumberFormatException {
        Usuario usuario = new Usuario();
        String idUsuarioStr = request.getParameter("id_usuario");
        if (idUsuarioStr != null && !idUsuarioStr.isEmpty()) {
            usuario.setIdUsuario(Integer.parseInt(idUsuarioStr));
        }

        usuario.setNombres(request.getParameter("nombres"));
        usuario.setApellidos(request.getParameter("apellidos"));
        usuario.setEmail(request.getParameter("email"));

        String password = request.getParameter("password");
        if (password != null) {
            usuario.setPassword(password);
        }

        // Si el checkbox de 'activo' está marcado, llega el parámetro. Si no, llega nulo.
        String activoParam = request.getParameter("activo");
        usuario.setActivo(activoParam != null && activoParam.equals("true"));

        Rol rol = new Rol();
        rol.setIdRol(Integer.parseInt(request.getParameter("rol_id")));
        usuario.setRol(rol);

        return usuario;
    }
}
