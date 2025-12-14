package com.example.telito.administrador.validators;

import com.example.telito.administrador.daos.UsuarioDAO;

import java.util.ArrayList;

// Validador centralizado para datos de usuario
public class UsuarioValidator {

    private static final int MAX_LENGTH_NOMBRE = 100;
    private static final int MAX_LENGTH_EMAIL = 100;
    private static final int MAX_LENGTH_PASSWORD = 100;
    private static final int MIN_LENGTH_PASSWORD = 4;
    private static final String EMAIL_REGEX = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";

    // Valida datos de usuario para creación o actualización
    public static ArrayList<String> validarUsuario(String nombres, String apellidos, String email,
                                                    String password, String rolIdStr,
                                                    UsuarioDAO usuarioDAO, boolean verificarEmailDuplicado) {
        ArrayList<String> errores = new ArrayList<>();

        // Validar campos obligatorios
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

        // Validar longitudes máximas
        if (nombres != null && nombres.length() > MAX_LENGTH_NOMBRE) {
            errores.add("El nombre no puede exceder " + MAX_LENGTH_NOMBRE + " caracteres");
        }
        if (apellidos != null && apellidos.length() > MAX_LENGTH_NOMBRE) {
            errores.add("Los apellidos no pueden exceder " + MAX_LENGTH_NOMBRE + " caracteres");
        }
        if (email != null && email.length() > MAX_LENGTH_EMAIL) {
            errores.add("El email no puede exceder " + MAX_LENGTH_EMAIL + " caracteres");
        }
        if (password != null && password.length() > MAX_LENGTH_PASSWORD) {
            errores.add("La contraseña no puede exceder " + MAX_LENGTH_PASSWORD + " caracteres");
        }

        // Validar formato de email
        if (email != null && !email.trim().isEmpty()) {
            if (!email.matches(EMAIL_REGEX)) {
                errores.add("El formato del email no es válido");
            }
        }

        // Validar longitud mínima de contraseña
        if (password != null && !password.trim().isEmpty()) {
            if (password.length() < MIN_LENGTH_PASSWORD) {
                errores.add("La contraseña debe tener al menos " + MIN_LENGTH_PASSWORD + " caracteres");
            }
        }

        // 5. Validar que el rol_id sea un número válido
        if (rolIdStr != null && !rolIdStr.trim().isEmpty()) {
            try {
                int rolId = Integer.parseInt(rolIdStr);
                if (rolId <= 0) {
                    errores.add("El ID del rol no es válido");
                }
            } catch (NumberFormatException e) {
                errores.add("El ID del rol debe ser un número válido");
            }
        }

        // 6. Validar que el email no esté registrado (solo para creación)
        if (verificarEmailDuplicado && email != null && !email.trim().isEmpty() && usuarioDAO != null) {
            if (usuarioDAO.existeEmail(email)) {
                errores.add("El email '" + email + "' ya está registrado");
            }
        }

        return errores;
    }

    /**
     * Valida los datos de un usuario para actualización.
     * Similar a validarUsuario pero sin validar contraseña ni email duplicado.
     * 
     * @param nombres Nombre del usuario
     * @param apellidos Apellidos del usuario
     * @param email Email del usuario
     * @param rolIdStr ID del rol (como String)
     * @return Lista de errores encontrados (vacía si no hay errores)
     */
    public static ArrayList<String> validarUsuarioActualizacion(String nombres, String apellidos, 
                                                                 String email, String rolIdStr) {
        ArrayList<String> errores = new ArrayList<>();

        // Validar campos obligatorios
        if (nombres == null || nombres.trim().isEmpty()) {
            errores.add("El nombre es obligatorio");
        }
        if (apellidos == null || apellidos.trim().isEmpty()) {
            errores.add("Los apellidos son obligatorios");
        }
        if (email == null || email.trim().isEmpty()) {
            errores.add("El email es obligatorio");
        }
        if (rolIdStr == null || rolIdStr.trim().isEmpty()) {
            errores.add("Debe seleccionar un rol");
        }

        // Validar longitudes máximas
        if (nombres != null && nombres.length() > MAX_LENGTH_NOMBRE) {
            errores.add("El nombre no puede exceder " + MAX_LENGTH_NOMBRE + " caracteres");
        }
        if (apellidos != null && apellidos.length() > MAX_LENGTH_NOMBRE) {
            errores.add("Los apellidos no pueden exceder " + MAX_LENGTH_NOMBRE + " caracteres");
        }
        if (email != null && email.length() > MAX_LENGTH_EMAIL) {
            errores.add("El email no puede exceder " + MAX_LENGTH_EMAIL + " caracteres");
        }

        // Validar formato de email
        if (email != null && !email.trim().isEmpty()) {
            if (!email.matches(EMAIL_REGEX)) {
                errores.add("El formato del email no es válido");
            }
        }

        // Validar que el rol_id sea un número válido
        if (rolIdStr != null && !rolIdStr.trim().isEmpty()) {
            try {
                int rolId = Integer.parseInt(rolIdStr);
                if (rolId <= 0) {
                    errores.add("El ID del rol no es válido");
                }
            } catch (NumberFormatException e) {
                errores.add("El ID del rol debe ser un número válido");
            }
        }

        return errores;
    }
}

