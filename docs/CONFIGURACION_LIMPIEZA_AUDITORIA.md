# ⚙️ Configuración Rápida - Sistema de Limpieza de Auditoría

## 🔧 Pasos de Configuración (5 minutos)

### 1️⃣ Configurar Emails de Destino ✉️

**Archivo:** [AuditoriaCleanupService.java](../src/main/java/com/example/telito/administrador/services/AuditoriaCleanupService.java)

**Buscar línea ~27:**
```java
private static final String[] EMAILS_REPORTE = {
    "admin@telitobodeguero.com",  // ← CAMBIAR POR TU EMAIL
    "gerencia@telitobodeguero.com"
};
```

**Cambiar por:**
```java
private static final String[] EMAILS_REPORTE = {
    "tu-email@empresa.com",        // ← Tu email real
    "otro-email@empresa.com"       // ← Agregar más si necesitas
};
```

---

### 2️⃣ Ajustar Días de Retención 📅

**Mismo archivo, línea ~24:**
```java
private static final int DIAS_MANTENER_AUDITORIA = 30;
```

**Opciones recomendadas:**
- `7` días = Limpieza muy agresiva (solo para testing)
- `30` días = **Recomendado** (balance costo/historial)
- `60` días = Para empresas con requisitos legales
- `90` días = Retención extendida

---

### 3️⃣ Ajustar Frecuencia de Limpieza ⏰

**Archivo:** [AuditoriaCleanupListener.java](../src/main/java/com/example/telito/listeners/AuditoriaCleanupListener.java)

**Buscar línea ~28:**
```java
private static final int DIAS_ENTRE_LIMPIEZAS = 7;
```

**Opciones:**
- `1` día = Diario (solo para testing)
- `7` días = **Recomendado** (semanal)
- `14` días = Quincenal
- `30` días = Mensual

---

### 4️⃣ Verificar Credenciales de Email 📧

**Archivo:** `src/main/resources/email.properties`

```properties
smtp.host=smtp.gmail.com
smtp.port=587
email.from=tu-email@gmail.com           # ← Tu email
email.password=tu-contraseña-app         # ← Contraseña de app de Gmail
application.name=Telito Bodeguero
application.base.url=http://localhost:8080/TELITO_BODEGUERO_war_exploded
```

**⚠️ Para Gmail:**
1. Ir a: https://myaccount.google.com/security
2. Activar "Verificación en 2 pasos"
3. Crear "Contraseña de aplicación"
4. Usar esa contraseña en `email.password`

---

## 🚀 Despliegue

### Opción 1: Compilar y Desplegar

```bash
mvn clean package
# Copiar target/TELITO_BODEGUERO.war a Tomcat/webapps/
```

### Opción 2: IDE (IntelliJ/Eclipse)

1. **Run** → **Restart Server**
2. El listener se iniciará automáticamente
3. Verás en logs: `🚀 Iniciando servicio de limpieza automática de auditoría...`

---

## ✅ Verificación

### 1. Verificar que el Listener está activo

**Buscar en logs:**
```
🚀 Iniciando servicio de limpieza automática de auditoría...
📅 Programando limpieza automática cada 7 días
⏰ Primera ejecución en XXX minutos (aprox. a las 2:00 AM)
✅ Servicio de limpieza automática iniciado correctamente
```

### 2. Probar Limpieza Manual

1. Ir a: http://localhost:8080/TELITO_BODEGUERO_war_exploded/AuditoriaServlet
2. Si hay más de 100 registros, verás una **alerta amarilla**
3. Hacer clic en **"Limpiar Ahora"**
4. Confirmar en el modal
5. Verificar resultados

### 3. Verificar Email Recibido

Deberías recibir un correo con:
- ✅ Asunto: "📊 Reporte de Auditoría - Limpieza Automática"
- ✅ Estadísticas: Total, Exitosos, Fallidos
- ✅ Tabla con registros eliminados
- ✅ Diseño profesional y responsive

---

## 🧪 Testing

### Ejecutar Script de Verificación

```sql
-- Ejecutar en MySQL:
source database/verificar_limpieza_auditoria.sql
```

Este script muestra:
- 📊 Estadísticas actuales
- 📅 Distribución por antigüedad
- 🔍 Simulación de limpieza
- 📈 Registros que se eliminarían

### Generar Datos de Prueba (Opcional)

Si tienes pocos registros y quieres probar:

```sql
-- Ver sección 7 del script: verificar_limpieza_auditoria.sql
-- Descomentar y ejecutar para generar 100 registros antiguos
```

---

## 📊 Métricas Esperadas

### Antes de implementar:
- ❌ 192+ registros acumulados
- ❌ ~480 KB en base de datos
- ❌ Crecimiento ilimitado
- ❌ Costos crecientes en nube

### Después de implementar:
- ✅ Máximo ~30-40 registros recientes
- ✅ ~75-100 KB en base de datos
- ✅ Crecimiento controlado
- ✅ **Reducción de costos: 60-80%**

---

## 🔍 Monitoreo

### Logs a Monitorear

**Ejecución automática exitosa:**
```
🕐 Ejecutando limpieza automática programada de auditoría...
🧹 Iniciando proceso de limpieza de auditoría...
📊 Total de registros antes: 192
📋 Registros a eliminar (más de 30 días): 150
✅ Reporte enviado exitosamente a: admin@empresa.com
🗑️ Registros eliminados: 150
✅ Limpieza exitosa: 150 registros eliminados, 375 KB liberados.
```

**Errores a investigar:**
```
❌ Error al eliminar registros antiguos
⚠️ No se pudo enviar el reporte por correo
❌ Error crítico durante limpieza automática
```

---

## 🛠️ Solución de Problemas

### ❌ No se envían correos

**Causa:** Credenciales incorrectas

**Solución:**
1. Verificar `email.properties`
2. Usar contraseña de aplicación de Gmail (no la contraseña normal)
3. Verificar logs: `✗ Credenciales de email no configuradas`

---

### ❌ No se eliminan registros

**Causa:** No hay registros antiguos

**Solución:**
1. Ejecutar: `SELECT COUNT(*) FROM auditoria_sistema WHERE fecha_accion < DATE_SUB(NOW(), INTERVAL 30 DAY);`
2. Si retorna 0, no hay nada que eliminar
3. Para testing, cambiar temporalmente a `DIAS_MANTENER_AUDITORIA = 1`

---

### ❌ Listener no se inicia

**Causa:** Servidor no soporta Servlet 3.0+

**Solución:**
1. Verificar versión de Tomcat (9.0+ requerido)
2. Verificar que `@WebListener` esté en la clase
3. Verificar logs de inicio del servidor

---

## 📋 Checklist Final

Antes de considerar la configuración completa:

- [ ] ✅ Emails de destino configurados
- [ ] ✅ Días de retención ajustados (30 días recomendado)
- [ ] ✅ Frecuencia de limpieza configurada (7 días recomendado)
- [ ] ✅ Credenciales de email verificadas
- [ ] ✅ Servidor reiniciado
- [ ] ✅ Logs verificados (listener iniciado)
- [ ] ✅ Prueba manual ejecutada con éxito
- [ ] ✅ Email de reporte recibido
- [ ] ✅ Registros eliminados correctamente

---

## 📞 Soporte

Si tienes problemas:

1. **Revisar logs** del servidor
2. **Ejecutar script** de verificación SQL
3. **Probar manualmente** desde la interfaz
4. **Verificar** credenciales de email

---

## 🎯 Resultado Final

### Lo que tendrás funcionando:

✅ **Limpieza Automática:**
- Se ejecuta cada 7 días a las 2:00 AM
- No requiere intervención manual
- Funciona en segundo plano

✅ **Respaldo por Email:**
- Reportes HTML profesionales
- Enviados automáticamente antes de eliminar
- Sirven como historial archivado

✅ **Control de Costos:**
- Máximo 30-40 registros en BD
- Reducción de 60-80% en espacio
- Crecimiento controlado

✅ **Interfaz Mejorada:**
- Alerta cuando hay muchos registros
- Botón para limpieza manual
- Modal con resultados detallados

---

**¡Configuración Completa! 🎉**

El sistema está listo para reducir tus costos de nube manteniendo un historial seguro por email.
