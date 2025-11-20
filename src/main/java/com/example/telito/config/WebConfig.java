package com.example.telito.config;

import org.springframework.context.annotation.Configuration;
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
        // Los recursos estáticos están en webapp/ y Spring Boot los sirve automáticamente
        // No necesitamos configuración adicional para un WAR ejecutable
    }
}

