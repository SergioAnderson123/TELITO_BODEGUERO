package com.example.telito.listeners;

import com.example.telito.administrador.services.AuditoriaCleanupService;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Listener que programa la ejecución automática de limpieza de auditoría.
 * 
 * CONFIGURACIÓN:
 * - Se ejecuta automáticamente cada 7 días
 * - Envía reporte por correo antes de eliminar
 * - Elimina registros mayores a 30 días
 * - Reduce costos de almacenamiento en nube
 * 
 * @author Telito Bodeguero
 * @version 1.0
 */
@WebListener
public class AuditoriaCleanupListener implements ServletContextListener {
    
    private static final Logger logger = LoggerFactory.getLogger(AuditoriaCleanupListener.class);
    
    // Configuración: ejecutar cada X días
    private static final int DIAS_ENTRE_LIMPIEZAS = 7; // Cada 7 días
    
    private ScheduledExecutorService scheduler;
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        logger.info("🚀 Iniciando servicio de limpieza automática de auditoría...");
        
        // Crear scheduler para tareas programadas
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread thread = new Thread(r);
            thread.setName("AuditoriaCleanupThread");
            thread.setDaemon(true); // Thread daemon para no bloquear shutdown
            return thread;
        });
        
        // Calcular tiempo inicial de espera (ejecutar a las 2:00 AM del próximo día)
        long initialDelay = calcularDelayHasta2AM();
        long period = TimeUnit.DAYS.toMinutes(DIAS_ENTRE_LIMPIEZAS);
        
        logger.info("📅 Programando limpieza automática cada {} días", DIAS_ENTRE_LIMPIEZAS);
        logger.info("⏰ Primera ejecución en {} minutos (aprox. a las 2:00 AM)", initialDelay);
        
        // Programar la tarea
        scheduler.scheduleAtFixedRate(
            this::ejecutarLimpiezaAutomatica,
            initialDelay,  // Delay inicial
            period,        // Período entre ejecuciones
            TimeUnit.MINUTES
        );
        
        logger.info("✅ Servicio de limpieza automática iniciado correctamente");
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        logger.info("🛑 Deteniendo servicio de limpieza automática de auditoría...");
        
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            try {
                if (!scheduler.awaitTermination(10, TimeUnit.SECONDS)) {
                    scheduler.shutdownNow();
                }
                logger.info("✅ Servicio de limpieza detenido correctamente");
            } catch (InterruptedException e) {
                logger.error("❌ Error al detener el scheduler", e);
                scheduler.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
    }
    
    /**
     * Ejecuta la limpieza automática de auditoría.
     */
    private void ejecutarLimpiezaAutomatica() {
        logger.info("🕐 Ejecutando limpieza automática programada de auditoría...");
        
        try {
            AuditoriaCleanupService cleanupService = new AuditoriaCleanupService();
            AuditoriaCleanupService.ResultadoLimpieza resultado = cleanupService.ejecutarLimpieza();
            
            if (resultado.exito) {
                logger.info("✅ Limpieza automática completada exitosamente: {}", resultado);
            } else {
                logger.error("❌ Error en limpieza automática: {}", resultado.mensaje);
            }
            
        } catch (Exception e) {
            logger.error("❌ Error crítico durante limpieza automática", e);
        }
    }
    
    /**
     * Calcula el delay en minutos hasta las 2:00 AM del día siguiente.
     */
    private long calcularDelayHasta2AM() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime next2AM = now.toLocalDate().atTime(2, 0);
        
        // Si ya pasaron las 2 AM de hoy, programar para mañana
        if (now.isAfter(next2AM)) {
            next2AM = next2AM.plusDays(1);
        }
        
        long minutesUntil2AM = ChronoUnit.MINUTES.between(now, next2AM);
        
        // Si falta menos de 1 hora, esperar hasta mañana
        if (minutesUntil2AM < 60) {
            minutesUntil2AM += TimeUnit.DAYS.toMinutes(1);
        }
        
        return minutesUntil2AM;
    }
}
