package com.example.telito.utils;

import java.io.*;
import java.nio.file.*;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Utilidad para verificar y corregir problemas de codificación UTF-8 en archivos JSP.
 * Este script verifica que todos los archivos JSP tengan la declaración correcta de UTF-8.
 */
public class JSPUTF8Fixer {
    
    public static void main(String[] args) {
        String projectPath = "C:\\Users\\sergi\\IdeaProjects\\TELITO_BODEGUERO\\src\\main\\webapp";
        
        try {
            List<Path> jspFiles = Files.walk(Paths.get(projectPath))
                .filter(path -> path.toString().endsWith(".jsp"))
                .collect(Collectors.toList());
            
            System.out.println("🔍 Verificando archivos JSP para problemas de UTF-8...");
            System.out.println("📁 Total de archivos JSP encontrados: " + jspFiles.size());
            
            int fixedCount = 0;
            int alreadyCorrectCount = 0;
            
            for (Path jspFile : jspFiles) {
                if (fixJSPUTF8(jspFile)) {
                    fixedCount++;
                } else {
                    alreadyCorrectCount++;
                }
            }
            
            System.out.println("\n✅ Resumen de correcciones:");
            System.out.println("🔧 Archivos corregidos: " + fixedCount);
            System.out.println("✅ Archivos ya correctos: " + alreadyCorrectCount);
            System.out.println("📊 Total procesados: " + jspFiles.size());
            
        } catch (IOException e) {
            System.err.println("❌ Error procesando archivos: " + e.getMessage());
        }
    }
    
    /**
     * Verifica y corrige un archivo JSP para asegurar codificación UTF-8.
     * 
     * @param jspFile ruta del archivo JSP
     * @return true si el archivo fue corregido, false si ya estaba correcto
     */
    private static boolean fixJSPUTF8(Path jspFile) {
        try {
            String content = Files.readString(jspFile, java.nio.charset.StandardCharsets.UTF_8);
            
            // Verificar si ya tiene la declaración UTF-8
            if (content.contains("contentType=\"text/html;charset=UTF-8\"")) {
                return false; // Ya está correcto
            }
            
            // Verificar si tiene alguna declaración de página
            if (content.contains("<%@ page")) {
                // Reemplazar la primera declaración de página
                content = content.replaceFirst(
                    "<%@\\s+page\\s+[^%]*%>",
                    "<%@ page contentType=\"text/html;charset=UTF-8\" language=\"java\" %>"
                );
            } else {
                // Agregar declaración al inicio del archivo
                content = "<%@ page contentType=\"text/html;charset=UTF-8\" language=\"java\" %>\n" + content;
            }
            
            // Escribir el archivo corregido
            Files.write(jspFile, content.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            
            System.out.println("🔧 Corregido: " + jspFile.getFileName());
            return true;
            
        } catch (IOException e) {
            System.err.println("❌ Error procesando " + jspFile.getFileName() + ": " + e.getMessage());
            return false;
        }
    }
}
