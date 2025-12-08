# 🔄 RENOVACIÓN COMPLETA: Sistema de Alertas (Sin Cambios en BD)

## 📊 Estructura de BD Existente (NO MODIFICAR)

### Tablas disponibles:
1. **`stock_minimo_config`**
   - `producto_id`, `stock_minimo`, `stock_critico`, `activo`

2. **`alertas_configuracion`**
   - `nombre`, `tipo_alerta`, `umbral_dias`, `categoria_id`, `rol_a_notificar`, `mensaje_personalizado`, `activo`

3. **`alertas_generadas`**
   - `alerta_config_id`, `producto_id`, `lote_id`, `mensaje`, `nivel`, `leida`, `fecha_generacion`, `fecha_lectura`

## 🎯 Estrategia: Usar campos existentes de forma inteligente

### Campo `mensaje_personalizado` como JSON
Almacenaremos configuración adicional en JSON sin cambiar la BD:
```json
{
  "umbral_tipo": "VALOR_ABSOLUTO|PORCENTAJE",
  "stock_minimo_lote": 10,
  "stock_critico_lote": 5,
  "stock_minimo_producto": 50,
  "stock_critico_producto": 25,
  "dias_vencimiento_proximo": 7,
  "dias_vencimiento_critico": 3,
  "notificar_email": true,
  "notificar_dashboard": true,
  "plantilla": "STOCK_BAJO|VENCIMIENTO_PROXIMO"
}
```

## 🏗️ Arquitectura Nueva (Backend)

### 1. Servicio Unificado de Alertas
```java
AlertaService
├── evaluarTodasLasAlertas()
├── evaluarStockMinimo()
├── evaluarVencimientos()
├── generarAlerta()
└── obtenerEstadisticas()
```

### 2. Evaluadores Especializados
```java
StockAlertaEvaluator
├── evaluarStockLote()
├── evaluarStockProducto()
└── obtenerConfiguracionStock()

VencimientoAlertaEvaluator
├── evaluarVencimientoProximo()
├── evaluarVencimientoVencido()
└── calcularDiasRestantes()
```

### 3. Gestor de Configuración
```java
AlertaConfigManager
├── parsearConfiguracionJSON()
├── guardarConfiguracionJSON()
├── obtenerPlantillas()
└── validarConfiguracion()
```

## 🎨 Interfaz de Usuario Renovada

### Dashboard Principal de Alertas
- **Métricas en tiempo real**: Contadores por nivel (Info, Warning, Critical)
- **Gráficos**: Alertas por tipo, tendencias semanales
- **Lista de alertas activas**: Con filtros avanzados
- **Acciones rápidas**: Marcar como leída, Resolver, Descartar

### Configuración Unificada (Nueva Página)
- **Pestaña 1: Stock Mínimo**
  - Tabla de productos con configuración inline
  - Valores por lote y por producto total
  - Vista previa de alertas que se generarían
  
- **Pestaña 2: Vencimientos**
  - Configuración de días de anticipación
  - Alertas por proximidad (7 días, 3 días, vencido)
  
- **Pestaña 3: Reglas de Alertas**
  - Lista mejorada con más información
  - Wizard de creación mejorado
  - Plantillas predefinidas

- **Pestaña 4: Historial**
  - Todas las alertas generadas
  - Filtros por fecha, tipo, nivel
  - Exportación a Excel

## 📋 Plan de Implementación

### Fase 1: Backend - Servicios (Día 1-2)
1. ✅ Crear `AlertaService` unificado
2. ✅ Crear evaluadores especializados
3. ✅ Crear `AlertaConfigManager` para JSON
4. ✅ Mejorar `AlertaDAO` con métodos optimizados

### Fase 2: Backend - Lógica de Negocio (Día 2-3)
1. ✅ Implementar evaluación inteligente de stock
2. ✅ Implementar evaluación de vencimientos
3. ✅ Sistema de plantillas predefinidas
4. ✅ Consolidación de notificaciones

### Fase 3: Frontend - Dashboard (Día 3-4)
1. ✅ Dashboard principal con métricas
2. ✅ Gráficos con Chart.js
3. ✅ Lista de alertas con filtros
4. ✅ Acciones rápidas

### Fase 4: Frontend - Configuración (Día 4-5)
1. ✅ Página de configuración unificada
2. ✅ Gestión de stock mínimo mejorada
3. ✅ Configuración de vencimientos
4. ✅ Wizard de creación mejorado

### Fase 5: Mejoras y Testing (Día 5-6)
1. ✅ Optimización de performance
2. ✅ Mejoras visuales
3. ✅ Testing completo
4. ✅ Documentación

## 🚀 Características Destacadas

1. **Configuración JSON en mensaje_personalizado**: Sin cambiar BD
2. **Plantillas predefinidas**: 5-10 plantillas comunes
3. **Dashboard interactivo**: Con gráficos y métricas
4. **Evaluación inteligente**: Caché y optimización
5. **Notificaciones mejoradas**: HTML consolidado
6. **Historial completo**: Usando tabla alertas_generadas

