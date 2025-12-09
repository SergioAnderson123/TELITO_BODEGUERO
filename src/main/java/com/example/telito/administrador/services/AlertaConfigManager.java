package com.example.telito.administrador.services;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.util.HashMap;
import java.util.Map;

/**
 * Gestor de configuración de alertas usando JSON en el campo mensaje_personalizado.
 * Permite almacenar configuración adicional sin modificar la estructura de BD.
 */
public class AlertaConfigManager {
    
    private final Gson gson;
    
    public AlertaConfigManager() {
        this.gson = new Gson();
    }
    
    /**
     * Parsea la configuración JSON del campo mensaje_personalizado.
     * Si no es JSON válido, retorna un mapa vacío.
     */
    public Map<String, Object> parsearConfiguracion(String mensajePersonalizado) {
        Map<String, Object> config = new HashMap<>();
        
        if (mensajePersonalizado == null || mensajePersonalizado.trim().isEmpty()) {
            return config;
        }
        
        try {
            // Intentar parsear como JSON
            JsonObject json = JsonParser.parseString(mensajePersonalizado).getAsJsonObject();
            
            // Extraer valores comunes
            if (json.has("stock_minimo_lote")) {
                config.put("stock_minimo_lote", json.get("stock_minimo_lote").getAsInt());
            }
            if (json.has("stock_critico_lote")) {
                config.put("stock_critico_lote", json.get("stock_critico_lote").getAsInt());
            }
            if (json.has("stock_minimo_producto")) {
                config.put("stock_minimo_producto", json.get("stock_minimo_producto").getAsInt());
            }
            if (json.has("stock_critico_producto")) {
                config.put("stock_critico_producto", json.get("stock_critico_producto").getAsInt());
            }
            if (json.has("dias_vencimiento_proximo")) {
                config.put("dias_vencimiento_proximo", json.get("dias_vencimiento_proximo").getAsInt());
            }
            if (json.has("dias_vencimiento_critico")) {
                config.put("dias_vencimiento_critico", json.get("dias_vencimiento_critico").getAsInt());
            }
            if (json.has("umbral_tipo")) {
                config.put("umbral_tipo", json.get("umbral_tipo").getAsString());
            }
            if (json.has("notificar_email")) {
                config.put("notificar_email", json.get("notificar_email").getAsBoolean());
            }
            if (json.has("notificar_dashboard")) {
                config.put("notificar_dashboard", json.get("notificar_dashboard").getAsBoolean());
            }
            if (json.has("plantilla")) {
                config.put("plantilla", json.get("plantilla").getAsString());
            }
            
        } catch (Exception e) {
            // Si no es JSON válido, asumir que es texto plano (mensaje personalizado tradicional)
            config.put("mensaje_texto", mensajePersonalizado);
        }
        
        return config;
    }
    
    /**
     * Genera JSON de configuración a partir de un mapa.
     */
    public String generarConfiguracionJSON(Map<String, Object> config) {
        if (config == null || config.isEmpty()) {
            return "";
        }
        
        JsonObject json = new JsonObject();
        for (Map.Entry<String, Object> entry : config.entrySet()) {
            Object value = entry.getValue();
            if (value instanceof Integer) {
                json.addProperty(entry.getKey(), (Integer) value);
            } else if (value instanceof Boolean) {
                json.addProperty(entry.getKey(), (Boolean) value);
            } else if (value instanceof String) {
                json.addProperty(entry.getKey(), (String) value);
            }
        }
        
        return gson.toJson(json);
    }
    
    /**
     * Obtiene una plantilla predefinida de configuración.
     */
    public Map<String, Object> obtenerPlantilla(String nombrePlantilla) {
        Map<String, Object> plantilla = new HashMap<>();
        
        switch (nombrePlantilla) {
            case "STOCK_BAJO_LOTE":
                plantilla.put("stock_minimo_lote", 10);
                plantilla.put("stock_critico_lote", 5);
                plantilla.put("umbral_tipo", "VALOR_ABSOLUTO");
                plantilla.put("notificar_email", true);
                plantilla.put("notificar_dashboard", true);
                break;
                
            case "STOCK_BAJO_PRODUCTO":
                plantilla.put("stock_minimo_producto", 50);
                plantilla.put("stock_critico_producto", 25);
                plantilla.put("umbral_tipo", "VALOR_ABSOLUTO");
                plantilla.put("notificar_email", true);
                plantilla.put("notificar_dashboard", true);
                break;
                
            case "VENCIMIENTO_PROXIMO":
                plantilla.put("dias_vencimiento_proximo", 7);
                plantilla.put("dias_vencimiento_critico", 3);
                plantilla.put("notificar_email", true);
                plantilla.put("notificar_dashboard", true);
                break;
                
            case "VENCIMIENTO_VENCIDO":
                plantilla.put("dias_vencimiento_critico", 0);
                plantilla.put("notificar_email", true);
                plantilla.put("notificar_dashboard", true);
                break;
        }
        
        return plantilla;
    }
    
    /**
     * Valida que la configuración sea correcta.
     */
    public boolean validarConfiguracion(Map<String, Object> config, String tipoAlerta) {
        if (config == null) {
            return false;
        }
        
        if (tipoAlerta.startsWith("STOCK_")) {
            return config.containsKey("stock_minimo_lote") || 
                   config.containsKey("stock_minimo_producto");
        } else if ("VENCIMIENTO".equals(tipoAlerta)) {
            return config.containsKey("dias_vencimiento_proximo") || 
                   config.containsKey("dias_vencimiento_critico");
        }
        
        return true;
    }
}

