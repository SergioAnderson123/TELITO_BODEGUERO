package com.example.telito;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.boot.web.servlet.ServletComponentScan;

/**
 * Clase principal de Spring Boot para TELITO_BODEGUERO
 * 
 * Extiende SpringBootServletInitializer para soportar WAR ejecutable
 * @ServletComponentScan habilita el escaneo automático de Servlets con @WebServlet
 */
@SpringBootApplication
@ServletComponentScan(basePackages = "com.example.telito")
public class Application extends SpringBootServletInitializer {
    
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(Application.class);
    }
    
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

