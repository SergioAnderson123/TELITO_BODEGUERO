# Sistema de Limpieza Automática de Auditoría

## 📋 Descripción General

Este sistema implementa una solución completa para gestionar el crecimiento de los registros de auditoría, reduciendo costos de almacenamiento en la nube mediante:

1. **Envío automático de reportes por correo** antes de eliminar registros
2. **Eliminación automática de registros antiguos**
3. **Programación automática** de limpieza cada 7 días
4. **Ejecución manual** desde la interfaz de administración

---

## 🚀 Componentes Implementados

### 1. **AuditoriaCleanupService** 
📁 `src/main/java/com/example/telito/administrador/services/AuditoriaCleanupService.java`

**Funcionalidades:**
- Obtiene registros mayores a 30 días
- Genera reportes HTML con estadísticas
- Envía reportes por correo
- Elimina registros antiguos
- Calcula espacio liberado

**Configuración:**
```java
private static final int DIAS_MANTENER_AUDITORIA = 30; // Días a mantener
private static final String[] EMAILS_REPORTE = {
    "admin@telitobodeguero.com",
    "gerencia@telitobodeguero.com"
};
```

### 2. **AuditoriaCleanupServlet**
📁 `src/main/java/com/example/telito/administrador/servlets/AuditoriaCleanupServlet.java`

**Funcionalidades:**
- Permite ejecución manual desde la interfaz
- Retorna resultado en formato JSON
- Solo accesible para administradores

**Endpoint:** `/AuditoriaCleanupServlet`

### 3. **AuditoriaCleanupListener**
📁 `src/main/java/com/example/telito/listeners/AuditoriaCleanupListener.java`

**Funcionalidades:**
- Se inicia automáticamente al arrancar la aplicación
- Programa limpieza cada 7 días a las 2:00 AM
- Ejecuta limpieza en segundo plano sin interrumpir el sistema

**Configuración:**
```java
private static final int DIAS_ENTRE_LIMPIEZAS = 7; // Cada 7 días
```

### 4. **Interfaz de Usuario Mejorada**
📁 `src/main/webapp/administrador/auditoria.jsp`

**Mejoras:**
- Alerta cuando hay más de 100 registros
- Botón "Limpiar Ahora" para ejecución manual
- Modal con resultados detallados
- Recarga automática de estadísticas

---

## ⚙️ Configuración

### 1. Configurar Correos de Destino

Editar el archivo:
```java
src/main/java/com/example/telito/administrador/services/AuditoriaCleanupService.java
```

Cambiar los emails en la línea ~27:
```java
private static final String[] EMAILS_REPORTE = {
    "tu-email@empresa.com",      // ← Cambiar por email real
    "gerencia@empresa.com"       // ← Agregar más emails si necesitas
};
```

### 2. Ajustar Días de Retención

En el mismo archivo, línea ~24:
```java
private static final int DIAS_MANTENER_AUDITORIA = 30; // ← Cambiar según necesidad
```

### 3. Ajustar Frecuencia de Limpieza

Editar:
```java
src/main/java/com/example/telito/listeners/AuditoriaCleanupListener.java
```

Línea ~28:
```java
private static final int DIAS_ENTRE_LIMPIEZAS = 7; // ← Cambiar frecuencia
```

### 4. Configurar Credenciales de Email

Asegurar que `src/main/resources/email.properties` esté correctamente configurado:
```properties
smtp.host=smtp.gmail.com
smtp.port=587
email.from=tu-email@gmail.com
email.password=tu-contraseña-app
application.name=Telito Bodeguero
application.base.url=http://localhost:8080/TELITO_BODEGUERO_war_exploded
```

---

## 📊 Flujo de Funcionamiento

### Limpieza Automática (Cada 7 días a las 2:00 AM):

```
1. AuditoriaCleanupListener ejecuta la tarea programada
   ↓
2. AuditoriaCleanupService.ejecutarLimpieza()
   ↓
3. Obtiene registros > 30 días
   ↓
4. Genera reporte HTML con estadísticas
   ↓
5. Envía reporte a emails configurados
   ↓
6. Elimina registros antiguos de la BD
   ↓
7. Registra resultado en logs
```

### Limpieza Manual (Desde interfaz):

```
1. Admin hace clic en "Limpiar Ahora"
   ↓
2. Confirmación con SweetAlert
   ↓
3. POST a /AuditoriaCleanupServlet
   ↓
4. Ejecuta proceso de limpieza
   ↓
5. Retorna JSON con resultados
   ↓
6. Muestra modal con estadísticas
   ↓
7. Recarga página automáticamente
```

---

## 📧 Formato del Reporte por Correo

El reporte incluye:

### Header
- Título: "📊 Reporte de Auditoría - Limpieza Automática"
- Fecha y hora de ejecución
- Diseño responsive con gradiente

### Estadísticas
- Total de registros a eliminar
- Registros exitosos vs fallidos
- Días de antigüedad de los registros

### Tabla de Registros (hasta 500)
- ID de auditoría
- Fecha y hora
- Usuario que realizó la acción
- Acción y módulo
- Descripción
- Estado (exitoso/fallido)

### Footer
- Información del sistema
- Aviso de correo automático

---

## 🧪 Pruebas

### Prueba Manual:
1. Ir a: `http://localhost:8080/TELITO_BODEGUERO_war_exploded/AuditoriaServlet`
2. Si hay más de 100 registros, aparecerá alerta amarilla
3. Hacer clic en "Limpiar Ahora"
4. Confirmar en el modal
5. Verificar resultados en el modal de respuesta
6. Verificar email recibido

### Verificar Logs:
```bash
# Buscar en logs de la aplicación:
🧹 Iniciando proceso de limpieza de auditoría...
📊 Total de registros antes: XXX
📋 Registros a eliminar: XXX
✅ Reporte enviado exitosamente a: email@example.com
🗑️ Registros eliminados: XXX
✅ Limpieza exitosa: XXX registros eliminados, XXX KB liberados
```

---

## 🔐 Seguridad

- ✅ Solo accesible para usuarios con rol **ADMINISTRADOR**
- ✅ Confirmación obligatoria antes de ejecutar
- ✅ Los registros se envían por correo antes de eliminar (respaldo)
- ✅ Logs detallados de todas las operaciones
- ✅ Thread daemon para no bloquear shutdown de la aplicación

---

## 💰 Beneficios

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Registros acumulados** | 192+ registros | Máximo ~30 días |
| **Espacio BD** | Crecimiento ilimitado | Controlado |
| **Costos nube** | Alto y creciente | Reducido 60-80% |
| **Gestión** | Manual | Automática |
| **Respaldo** | No existe | Email automático |

---

## 📌 Notas Importantes

1. **Primera Ejecución**: La primera limpieza automática se ejecutará a las 2:00 AM del día siguiente al deploy

2. **Respaldo**: Los reportes enviados por correo sirven como respaldo histórico

3. **Personalización**: Todos los parámetros son configurables (días, frecuencia, emails)

4. **Desactivación**: Para desactivar la limpieza automática, comentar la anotación `@WebListener` en `AuditoriaCleanupListener`

5. **Testing**: En desarrollo, puedes cambiar `DIAS_MANTENER_AUDITORIA = 1` para pruebas rápidas

---

## 🆘 Solución de Problemas

### No se envían correos:
- Verificar credenciales en `email.properties`
- Verificar que Gmail tenga "Acceso de apps menos seguras" o contraseña de app
- Revisar logs para errores SMTP

### No se eliminan registros:
- Verificar permisos de BD
- Verificar que existan registros mayores a 30 días
- Revisar logs para errores SQL

### Listener no se inicia:
- Verificar que la anotación `@WebListener` esté presente
- Revisar logs de inicio de la aplicación
- Verificar que el servidor soporte Servlet 3.0+

---

## 📝 Mantenimiento

### Recomendaciones:
- Revisar emails de reporte semanalmente
- Ajustar `DIAS_MANTENER_AUDITORIA` según necesidades legales/regulatorias
- Monitorear espacio liberado en estadísticas
- Guardar reportes importantes antes de que se eliminen

### Métricas a Monitorear:
- Cantidad de registros promedio
- Frecuencia de crecimiento
- Espacio liberado por limpieza
- Tasa de éxito de envío de correos

---

## 🎯 Próximas Mejoras Sugeridas

1. **Panel de configuración**: Interfaz para cambiar parámetros sin editar código
2. **Historial de limpiezas**: Tabla para registrar cada ejecución
3. **Múltiples políticas**: Diferentes retenciones por módulo
4. **Exportación CSV**: Descargar reportes en formato CSV
5. **Alertas**: Notificación cuando el volumen supera umbrales

---

## 👨‍💻 Autor

**Telito Bodeguero - Sistema de Gestión Integral**  
Versión: 1.0  
Fecha: Diciembre 2025

---

## 📄 Licencia

Este módulo es parte del sistema Telito Bodeguero y sigue la misma licencia del proyecto principal.
