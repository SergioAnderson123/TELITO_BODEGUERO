package com.example.telito.administrador.utils;

import com.example.telito.administrador.beans.Rol;
import com.example.telito.administrador.beans.Categoria;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Sistema de cache simple para datos frecuentemente consultados.
 * En producción se recomienda usar Redis o Hazelcast.
 */
public class AdminCache {
    
    private static final ConcurrentHashMap<String, CacheEntry> cache = new ConcurrentHashMap<>();
    private static final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    
    // Tiempo de vida del cache en minutos
    private static final int CACHE_TTL_MINUTES = 30;
    
    static {
        // Limpiar cache cada 10 minutos
        scheduler.scheduleAtFixedRate(AdminCache::cleanExpiredEntries, 10, 10, TimeUnit.MINUTES);
    }
    
    /**
     * Entrada del cache con timestamp de expiración.
     */
    private static class CacheEntry {
        private final Object data;
        private final long expirationTime;
        
        public CacheEntry(Object data, int ttlMinutes) {
            this.data = data;
            this.expirationTime = System.currentTimeMillis() + (ttlMinutes * 60 * 1000);
        }
        
        public Object getData() { return data; }
        public boolean isExpired() { return System.currentTimeMillis() > expirationTime; }
    }
    
    /**
     * Almacena datos en el cache.
     * 
     * @param key clave del cache
     * @param data datos a almacenar
     * @param ttlMinutes tiempo de vida en minutos
     */
    public static void put(String key, Object data, int ttlMinutes) {
        cache.put(key, new CacheEntry(data, ttlMinutes));
        AdminLogger.debug(String.format("Cache PUT: %s (TTL: %d minutes)", key, ttlMinutes));
    }
    
    /**
     * Almacena datos en el cache con TTL por defecto.
     * 
     * @param key clave del cache
     * @param data datos a almacenar
     */
    public static void put(String key, Object data) {
        put(key, data, CACHE_TTL_MINUTES);
    }
    
    /**
     * Obtiene datos del cache.
     * 
     * @param key clave del cache
     * @return datos almacenados o null si no existe o ha expirado
     */
    @SuppressWarnings("unchecked")
    public static <T> T get(String key) {
        CacheEntry entry = cache.get(key);
        if (entry == null || entry.isExpired()) {
            if (entry != null) {
                cache.remove(key);
            }
            AdminLogger.debug(String.format("Cache MISS: %s", key));
            return null;
        }
        
        AdminLogger.debug(String.format("Cache HIT: %s", key));
        return (T) entry.getData();
    }
    
    /**
     * Obtiene datos del cache con callback para cargar datos si no están en cache.
     * 
     * @param key clave del cache
     * @param loader función para cargar datos si no están en cache
     * @return datos del cache o cargados por el loader
     */
    public static <T> T get(String key, CacheLoader<T> loader) {
        T data = get(key);
        if (data == null) {
            data = loader.load();
            if (data != null) {
                put(key, data);
            }
        }
        return data;
    }
    
    /**
     * Elimina una entrada específica del cache.
     * 
     * @param key clave a eliminar
     */
    public static void remove(String key) {
        cache.remove(key);
        AdminLogger.debug(String.format("Cache REMOVE: %s", key));
    }
    
    /**
     * Limpia todo el cache.
     */
    public static void clear() {
        cache.clear();
        AdminLogger.info("Cache cleared");
    }
    
    /**
     * Elimina entradas expiradas del cache.
     */
    private static void cleanExpiredEntries() {
        int removed = 0;
        for (String key : cache.keySet()) {
            CacheEntry entry = cache.get(key);
            if (entry != null && entry.isExpired()) {
                cache.remove(key);
                removed++;
            }
        }
        if (removed > 0) {
            AdminLogger.debug(String.format("Cleaned %d expired cache entries", removed));
        }
    }
    
    /**
     * Obtiene estadísticas del cache.
     * 
     * @return información sobre el estado del cache
     */
    public static String getStats() {
        int total = cache.size();
        int expired = 0;
        for (CacheEntry entry : cache.values()) {
            if (entry.isExpired()) {
                expired++;
            }
        }
        return String.format("Cache Stats - Total: %d, Expired: %d, Active: %d", 
                           total, expired, total - expired);
    }
    
    /**
     * Interfaz para cargar datos cuando no están en cache.
     */
    @FunctionalInterface
    public interface CacheLoader<T> {
        T load();
    }
    
    /**
     * Cierra el scheduler del cache.
     */
    public static void shutdown() {
        scheduler.shutdown();
        AdminLogger.info("Cache scheduler shutdown");
    }
}
