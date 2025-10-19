# Guía de Prueba - Sistema de Notificaciones

## Pasos para probar el sistema de notificaciones

### 1. Preparar la base de datos
```sql
-- Ejecutar el script de la tabla alertas_evento
-- database_scripts/alertas_evento.sql
```

### 2. Configurar reglas de alerta en Administrador
1. Ir a `/administrador/gestion-alertas.jsp`
2. Crear una regla de "STOCK_MINIMO" dirigida al rol de Logística (ID 3)
3. Crear una regla de "PROXIMO_A_VENCER" dirigida al rol de Logística (ID 3)

### 3. Generar datos de prueba
```sql
-- Insertar productos con stock bajo
INSERT INTO productos (nombre, codigo_sku, stock, stock_minimo, categoria_id) 
VALUES ('Producto Test', 'TEST001', 2, 5, 1);

-- Insertar lotes próximos a vencer
INSERT INTO lotes (producto_id, numero_lote, fecha_vencimiento, cantidad) 
VALUES (1, 'LOTE001', DATE_ADD(CURDATE(), INTERVAL 5 DAY), 100);
```

### 4. Evaluar alertas
1. Ir a `/administrador/gestion-alertas.jsp`
2. Hacer clic en "Evaluar Alertas"
3. Verificar que se generen eventos en la tabla `alertas_evento`

### 5. Verificar notificaciones en Logística
1. Ir a `/logistica/NotificacionServlet`
2. Verificar que aparezcan las notificaciones generadas
3. Probar marcar como leídas

### 6. Verificar contador en el menú
1. Ir a `/logistica/index.jsp`
2. Verificar que aparezca el badge con el número de notificaciones no leídas

## URLs importantes para probar

- **Administrador - Gestión de Alertas**: `/administrador/gestion-alertas.jsp`
- **Evaluar Alertas**: `/EvaluarAlertasServlet?action=evaluar`
- **Logística - Notificaciones**: `/logistica/NotificacionServlet`
- **Logística - Dashboard**: `/logistica/index.jsp`

## Verificaciones en base de datos

```sql
-- Ver todas las notificaciones
SELECT * FROM alertas_evento ORDER BY creado_en DESC;

-- Ver notificaciones no leídas para logística
SELECT * FROM alertas_evento WHERE rol_destino_id = 3 AND leido = 0;

-- Contar notificaciones por severidad
SELECT severidad, COUNT(*) FROM alertas_evento GROUP BY severidad;
```

## Posibles problemas y soluciones

1. **No aparecen notificaciones**: Verificar que el rol de logística tenga ID 3
2. **Error de conexión**: Verificar credenciales de BD en los servlets
3. **Contador no se actualiza**: Verificar que el JavaScript esté cargando correctamente
