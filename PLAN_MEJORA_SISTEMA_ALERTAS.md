# 🚀 PLAN DE MEJORA: Sistema de Alertas Avanzado

## 📋 Análisis del Sistema Actual

### Problemas Identificados:
1. **Configuración dispersa**: Stock mínimo en `stock_minimo_config` y alertas en `alertas_configuracion`
2. **Falta de flexibilidad**: Umbrales fijos, difícil personalización
3. **UI compleja**: Múltiples pantallas para configurar lo mismo
4. **Falta de historial**: No se registra cuándo se activó/desactivó una alerta
5. **Sin priorización**: Todas las alertas tienen el mismo peso
6. **Falta de agrupación**: No se pueden crear grupos de alertas

## 🎯 Objetivos del Nuevo Sistema

1. **Unificación**: Una sola interfaz para configurar todo
2. **Flexibilidad**: Múltiples niveles de alerta (Info, Advertencia, Crítico)
3. **Inteligencia**: Alertas basadas en porcentajes y valores absolutos
4. **Historial**: Registro de todas las alertas generadas
5. **Dashboard visual**: Gráficos y métricas de alertas
6. **Notificaciones múltiples**: Email, in-app, SMS (futuro)

## 🏗️ Arquitectura Propuesta

### 1. Nueva Estructura de Base de Datos

```sql
-- Tabla unificada de configuración de alertas
CREATE TABLE alertas_config (
    id_alerta_config INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    tipo_alerta ENUM('STOCK_MINIMO', 'STOCK_CRITICO', 'VENCIMIENTO_PROXIMO', 'VENCIMIENTO_VENCIDO') NOT NULL,
    nivel_prioridad ENUM('INFO', 'ADVERTENCIA', 'CRITICO') DEFAULT 'ADVERTENCIA',
    
    -- Configuración de umbrales (flexible)
    umbral_tipo ENUM('VALOR_ABSOLUTO', 'PORCENTAJE', 'DIAS') NOT NULL,
    umbral_valor DECIMAL(10,2) NOT NULL,
    
    -- Filtros
    aplicar_a ENUM('TODOS', 'PRODUCTO', 'LOTE', 'CATEGORIA', 'DISTRITO') DEFAULT 'TODOS',
    filtro_id INT NULL, -- ID del producto/categoría/distrito específico
    
    -- Notificaciones
    notificar_roles JSON, -- Array de roles: ["LOGISTICA", "ALMACEN"]
    enviar_email BOOLEAN DEFAULT TRUE,
    mostrar_dashboard BOOLEAN DEFAULT TRUE,
    
    -- Mensaje personalizado
    mensaje_template TEXT,
    
    -- Control
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    creado_por INT,
    
    INDEX idx_tipo (tipo_alerta),
    INDEX idx_activo (activo),
    INDEX idx_prioridad (nivel_prioridad)
);

-- Tabla de historial de alertas generadas
CREATE TABLE alertas_historial (
    id_alerta_historial INT PRIMARY KEY AUTO_INCREMENT,
    alerta_config_id INT NOT NULL,
    tipo_alerta VARCHAR(50) NOT NULL,
    nivel_prioridad VARCHAR(20) NOT NULL,
    
    -- Detalles del elemento en alerta
    elemento_tipo ENUM('PRODUCTO', 'LOTE') NOT NULL,
    elemento_id INT NOT NULL,
    elemento_nombre VARCHAR(200),
    
    -- Valores que dispararon la alerta
    valor_actual DECIMAL(10,2),
    umbral_configurado DECIMAL(10,2),
    
    -- Estado
    estado ENUM('ACTIVA', 'RESUELTA', 'DESCARTADA') DEFAULT 'ACTIVA',
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion TIMESTAMP NULL,
    resuelto_por INT NULL,
    
    -- Notificaciones enviadas
    emails_enviados INT DEFAULT 0,
    ultimo_envio TIMESTAMP NULL,
    
    FOREIGN KEY (alerta_config_id) REFERENCES alertas_config(id_alerta_config),
    INDEX idx_estado (estado),
    INDEX idx_fecha (fecha_generacion),
    INDEX idx_elemento (elemento_tipo, elemento_id)
);

-- Tabla de configuración de stock mínimo (simplificada)
CREATE TABLE stock_minimo_config (
    id_stock_minimo INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT NULL, -- NULL = configuración global
    categoria_id INT NULL,
    
    -- Umbrales por nivel
    stock_minimo_paquetes INT DEFAULT 10,
    stock_critico_paquetes INT DEFAULT 5,
    
    -- Porcentajes (opcional)
    stock_minimo_porcentaje DECIMAL(5,2) NULL, -- % del stock inicial
    stock_critico_porcentaje DECIMAL(5,2) NULL,
    
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (producto_id) REFERENCES productos(id_producto),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id_categoria),
    INDEX idx_producto (producto_id),
    INDEX idx_categoria (categoria_id)
);
```

### 2. Nueva Interfaz de Usuario

#### Página Principal: Dashboard de Alertas
- **Vista general** con contadores por nivel (Info, Advertencia, Crítico)
- **Gráficos** de alertas por tipo y tendencias
- **Lista de alertas activas** con filtros
- **Acciones rápidas**: Resolver, Descartar, Ver detalle

#### Página de Configuración Unificada
- **Pestañas**:
  1. **Stock Mínimo**: Configurar umbrales por producto/categoría
  2. **Vencimientos**: Configurar días de anticipación
  3. **Reglas de Alertas**: Crear/editar reglas personalizadas
  4. **Notificaciones**: Configurar destinatarios y canales

#### Características de la UI:
- **Wizard de creación** paso a paso
- **Vista previa** de cómo se verá la alerta
- **Test de alerta** antes de guardar
- **Plantillas predefinidas** para casos comunes
- **Importar/Exportar** configuraciones

### 3. Servicios Mejorados

#### AlertaService (Nuevo)
```java
public class AlertaService {
    // Evaluar todas las reglas activas
    public List<AlertaGenerada> evaluarAlertas();
    
    // Generar alerta específica
    public AlertaGenerada generarAlerta(AlertaConfig config, Elemento elemento);
    
    // Resolver alerta
    public void resolverAlerta(int alertaId, int usuarioId);
    
    // Obtener estadísticas
    public EstadisticasAlertas obtenerEstadisticas(Date desde, Date hasta);
}
```

#### AlertaEvaluator (Nuevo)
```java
public class AlertaEvaluator {
    // Evaluar stock mínimo
    public boolean evaluarStockMinimo(Producto producto, AlertaConfig config);
    
    // Evaluar vencimiento
    public boolean evaluarVencimiento(Lote lote, AlertaConfig config);
    
    // Calcular días hasta vencimiento
    public int calcularDiasVencimiento(Lote lote);
}
```

### 4. Mejoras en Notificaciones

- **Consolidación**: Agrupar múltiples alertas en un solo correo
- **Priorización**: Alertas críticas primero
- **Formato HTML mejorado**: Con gráficos y tablas
- **Enlaces directos**: Botones para ir a la acción requerida
- **Frecuencia configurable**: Diario, semanal, inmediato

## 📝 Plan de Implementación

### Fase 1: Base de Datos (1-2 días)
1. Crear nuevas tablas
2. Migrar datos existentes
3. Crear índices y constraints

### Fase 2: Backend (2-3 días)
1. Crear nuevos DAOs
2. Implementar servicios
3. Crear evaluadores de alertas
4. Actualizar scheduler

### Fase 3: Frontend (2-3 días)
1. Dashboard de alertas
2. Configuración unificada
3. Historial de alertas
4. Mejoras visuales

### Fase 4: Testing y Refinamiento (1-2 días)
1. Pruebas unitarias
2. Pruebas de integración
3. Ajustes de UI/UX

## 🎨 Características Destacadas

1. **Sistema de Plantillas**: Alertas pre-configuradas para casos comunes
2. **Reglas Inteligentes**: Alertas basadas en tendencias (ej: "Stock bajando 20% por semana")
3. **Dashboard Interactivo**: Filtros, búsqueda, exportación
4. **Historial Completo**: Ver todas las alertas históricas
5. **API REST**: Para integraciones futuras
6. **Multi-idioma**: Preparado para internacionalización

## 🔒 Seguridad y Performance

- **Índices optimizados** para consultas rápidas
- **Caché** de configuraciones activas
- **Rate limiting** en notificaciones
- **Logging** completo de todas las acciones
- **Backup automático** de configuraciones

