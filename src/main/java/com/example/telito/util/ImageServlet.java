package com.example.telito.util;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

// Servlet para servir imágenes subidas por los usuarios (fotos de perfil)
@WebServlet(name = "ImageServlet", value = "/uploads/*")
public class ImageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Obtener ruta de la imagen solicitada
        String requestedImage = request.getPathInfo();
        
        if (requestedImage == null || requestedImage.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        
        // Construir ruta completa del archivo
        String uploadPath = getServletContext().getRealPath("/");
        Path imagePath = Paths.get(uploadPath, "uploads", requestedImage.substring(1));
        
        File imageFile = imagePath.toFile();
        
        // Verificar que el archivo existe
        if (!imageFile.exists() || !imageFile.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        
        // Determinar tipo de contenido
        String contentType = getServletContext().getMimeType(imageFile.getName());
        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        
        // Configurar respuesta
        response.setContentType(contentType);
        response.setContentLengthLong(imageFile.length());
        
        // Configurar cache (1 día)
        response.setHeader("Cache-Control", "max-age=86400");
        
        // Enviar archivo
        Files.copy(imagePath, response.getOutputStream());
    }
}

