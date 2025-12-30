package com.example.telito.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewResolverRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.springframework.web.servlet.view.JstlView;

/**
 * Configuración de Spring MVC para JSPs y recursos estáticos
 * Los JSPs están en webapp/ y se empaquetan en el JAR
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void configureViewResolvers(ViewResolverRegistry registry) {
        InternalResourceViewResolver resolver = new InternalResourceViewResolver();
        // Los JSPs están en webapp/ directamente
        // En un WAR ejecutable, Spring Boot puede servir JSPs desde webapp/
        resolver.setPrefix("/");
        resolver.setSuffix(".jsp");
        resolver.setViewClass(JstlView.class);
        resolver.setOrder(1);
        registry.viewResolver(resolver);
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Configurar recursos estáticos con orden bajo para que los servlets tengan prioridad
        // Esto asegura que rutas como /logout se resuelvan como servlets, no como recursos estáticos
        // Los recursos estáticos se servirán automáticamente desde webapp/ por Spring Boot
        // pero con menor prioridad que los servlets registrados con @WebServlet
        registry.setOrder(Ordered.LOWEST_PRECEDENCE);
    }
}

