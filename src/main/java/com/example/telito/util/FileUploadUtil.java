package com.example.telito.util;

import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/**
 * Utilidad para manejo de carga de archivos
 */
public class FileUploadUtil {
    
    private static final String UPLOAD_DIR = "uploads/perfiles";
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp"};
    
    /**
     * Guarda un archivo de foto de perfil
     * @param part El archivo subido
     * @param uploadPath Ruta base donde se guardarán los archivos
     * @return Nombre del archivo guardado (relativo)
     * @throws IOException Si hay error al guardar
     */
    public static String saveProfilePhoto(Part part, String uploadPath) throws IOException {
        // Validar que el archivo no sea nulo
        if (part == null || part.getSize() == 0) {
            throw new IOException("No se ha seleccionado ningún archivo");
        }
        
        // Validar el tamaño
        if (part.getSize() > MAX_FILE_SIZE) {
            throw new IOException("El archivo excede el tamaño máximo de 5MB");
        }
        
        // Obtener el nombre original del archivo
        String fileName = getFileName(part);
        
        // Validar la extensión
        if (!isValidExtension(fileName)) {
            throw new IOException("Formato de archivo no permitido. Use: JPG, PNG, GIF o WEBP");
        }
        
        // Generar un nombre único para evitar conflictos
        String extension = fileName.substring(fileName.lastIndexOf("."));
        String uniqueFileName = UUID.randomUUID().toString() + extension;
        
        // Crear el directorio si no existe
        Path uploadDir = Paths.get(uploadPath, UPLOAD_DIR);
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }
        
        // Guardar el archivo
        Path filePath = uploadDir.resolve(uniqueFileName);
        try (InputStream input = part.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }
        
        // Retornar la ruta relativa (para guardar en BD)
        return UPLOAD_DIR + "/" + uniqueFileName;
    }
    
    /**
     * Elimina una foto de perfil anterior
     * @param photoPath Ruta de la foto a eliminar
     * @param uploadPath Ruta base de uploads
     */
    public static void deleteProfilePhoto(String photoPath, String uploadPath) {
        if (photoPath == null || photoPath.trim().isEmpty()) {
            return;
        }
        
        // No eliminar si es una URL externa
        if (photoPath.startsWith("http://") || photoPath.startsWith("https://")) {
            return;
        }
        
        try {
            Path filePath = Paths.get(uploadPath, photoPath);
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            System.err.println("Error al eliminar archivo: " + e.getMessage());
        }
    }
    
    /**
     * Obtiene el nombre del archivo de un Part
     */
    private static String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String token : contentDisposition.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "";
    }
    
    /**
     * Valida si la extensión del archivo es permitida
     */
    private static boolean isValidExtension(String fileName) {
        String lowerFileName = fileName.toLowerCase();
        for (String ext : ALLOWED_EXTENSIONS) {
            if (lowerFileName.endsWith(ext)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Obtiene el directorio de uploads
     */
    public static String getUploadDirectory() {
        return UPLOAD_DIR;
    }
}

