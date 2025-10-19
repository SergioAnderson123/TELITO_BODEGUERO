package com.example.telito.administrador.utils;

import com.example.telito.administrador.beans.Usuario;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Clase utilitaria para validación robusta de usuarios.
 * Implementa validaciones de negocio y seguridad.
 */
public class UsuarioValidator {
    
    // Patrones de validación
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    );
    
    private static final Pattern NOMBRE_PATTERN = Pattern.compile(
        "^[a-zA-ZáéíóúÁÉÍÓÚñÑ\\s]{2,50}$"
    );
    
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
        "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d@$!%*?&]{8,}$"
    );
    
    /**
     * Resultado de validación con errores específicos.
     */
    public static class ValidationResult {
        private boolean valid;
        private List<String> errors;
        
        public ValidationResult() {
            this.valid = true;
            this.errors = new ArrayList<>();
        }
        
        public void addError(String error) {
            this.valid = false;
            this.errors.add(error);
        }
        
        public boolean isValid() { return valid; }
        public List<String> getErrors() { return errors; }
        
        public String getErrorsAsString() {
            return String.join(", ", errors);
        }
    }
    
    /**
     * Valida un objeto Usuario completo.
     * 
     * @param usuario el usuario a validar
     * @param isUpdate true si es una actualización, false si es creación
     * @return ValidationResult con el resultado de la validación
     */
    public static ValidationResult validateUsuario(Usuario usuario, boolean isUpdate) {
        ValidationResult result = new ValidationResult();
        
        // Validar nombres
        validateNombres(usuario.getNombres(), result);
        validateApellidos(usuario.getApellidos(), result);
        
        // Validar email
        validateEmail(usuario.getEmail(), result);
        
        // Validar contraseña (solo en creación o si se proporciona)
        if (!isUpdate || (usuario.getPassword() != null && !usuario.getPassword().trim().isEmpty())) {
            validatePassword(usuario.getPassword(), result);
        }
        
        // Validar rol
        validateRol(usuario.getRol(), result);
        
        return result;
    }
    
    /**
     * Valida el campo nombres.
     */
    private static void validateNombres(String nombres, ValidationResult result) {
        if (nombres == null || nombres.trim().isEmpty()) {
            result.addError("El nombre es obligatorio");
            return;
        }
        
        if (!NOMBRE_PATTERN.matcher(nombres.trim()).matches()) {
            result.addError("El nombre solo puede contener letras y espacios (2-50 caracteres)");
        }
    }
    
    /**
     * Valida el campo apellidos.
     */
    private static void validateApellidos(String apellidos, ValidationResult result) {
        if (apellidos == null || apellidos.trim().isEmpty()) {
            result.addError("Los apellidos son obligatorios");
            return;
        }
        
        if (!NOMBRE_PATTERN.matcher(apellidos.trim()).matches()) {
            result.addError("Los apellidos solo pueden contener letras y espacios (2-50 caracteres)");
        }
    }
    
    /**
     * Valida el campo email.
     */
    private static void validateEmail(String email, ValidationResult result) {
        if (email == null || email.trim().isEmpty()) {
            result.addError("El email es obligatorio");
            return;
        }
        
        email = email.trim().toLowerCase();
        
        if (!EMAIL_PATTERN.matcher(email).matches()) {
            result.addError("El formato del email no es válido");
        }
        
        if (email.length() > 100) {
            result.addError("El email no puede exceder 100 caracteres");
        }
    }
    
    /**
     * Valida el campo contraseña.
     */
    private static void validatePassword(String password, ValidationResult result) {
        if (password == null || password.trim().isEmpty()) {
            result.addError("La contraseña es obligatoria");
            return;
        }
        
        if (password.length() < 8) {
            result.addError("La contraseña debe tener al menos 8 caracteres");
        }
        
        if (password.length() > 128) {
            result.addError("La contraseña no puede exceder 128 caracteres");
        }
        
        // Validación de complejidad (opcional, comentada para flexibilidad)
        /*
        if (!PASSWORD_PATTERN.matcher(password).matches()) {
            result.addError("La contraseña debe contener al menos una mayúscula, una minúscula y un número");
        }
        */
    }
    
    /**
     * Valida el objeto rol.
     */
    private static void validateRol(com.example.telito.administrador.beans.Rol rol, ValidationResult result) {
        if (rol == null) {
            result.addError("El rol es obligatorio");
            return;
        }
        
        if (rol.getIdRol() <= 0) {
            result.addError("Debe seleccionar un rol válido");
        }
    }
    
    /**
     * Valida parámetros de búsqueda y filtros.
     */
    public static ValidationResult validateSearchParams(String busqueda, String rolId, String estado) {
        ValidationResult result = new ValidationResult();
        
        // Validar búsqueda
        if (busqueda != null && busqueda.length() > 100) {
            result.addError("El término de búsqueda no puede exceder 100 caracteres");
        }
        
        // Validar rolId
        if (rolId != null && !rolId.trim().isEmpty()) {
            try {
                int rol = Integer.parseInt(rolId);
                if (rol <= 0) {
                    result.addError("El ID de rol no es válido");
                }
            } catch (NumberFormatException e) {
                result.addError("El ID de rol debe ser un número válido");
            }
        }
        
        // Validar estado
        if (estado != null && !estado.trim().isEmpty()) {
            if (!estado.equals("0") && !estado.equals("1")) {
                result.addError("El estado debe ser 0 (inactivo) o 1 (activo)");
            }
        }
        
        return result;
    }
}
