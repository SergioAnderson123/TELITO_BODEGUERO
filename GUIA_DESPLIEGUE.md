# GUÍA RÁPIDA: Desarrollo y Despliegue

## 🔄 Flujo de trabajo recomendado

### **Opción 1: Configurar IntelliJ (RECOMENDADO - solo una vez)**

1. En IntelliJ IDEA:
   - `File → Settings → Build, Execution, Deployment → Compiler`
   - ✅ Marcar: **"Build project automatically"**
   - ✅ Marcar: **"Compile independent modules in parallel"**

2. En la configuración de Tomcat:
   - `Run → Edit Configurations → Tomcat Server`
   - En "Deployment" → ✅ Marcar: **"Deploy applications configured in Tomcat instance"**
   - En "Before launch" → Asegurar que esté: **"Build 'TELITO_BODEGUERO:war exploded' artifact"**

3. **Ya no necesitarás scripts manuales** - IntelliJ lo hará automáticamente

---

### **Opción 2: Script Manual (temporal)**

Si IntelliJ no está configurado, **ANTES de cada reinicio de Tomcat**:

```powershell
.\sync-project.ps1
```

Este script copia automáticamente:
- ✅ Archivos de configuración (.properties, .xml)
- ✅ Archivos JSP modificados
- ✅ Recursos estáticos (CSS, JS, imágenes)

---

## 🚀 Pasos para probar cambios

### **Con IntelliJ configurado:**
1. Editar archivo JSP/Java
2. `Ctrl + F9` (Build Project)
3. Reiniciar Tomcat (botón ⟳ en IntelliJ)
4. Refrescar navegador `F5`

### **Sin configurar (manual):**
1. Editar archivo JSP/Java
2. Ejecutar: `.\sync-project.ps1`
3. Reiniciar Tomcat en IntelliJ
4. Refrescar navegador `F5`

---

## 📝 Archivos importantes

### **Scripts disponibles:**
- `sync-project.ps1` - Sincroniza TODO (recursos + JSPs)
- `copy-resources.ps1` - Solo recursos (.properties, .xml)

### **Directorios clave:**
- **Fuente:** `src/main/webapp/` (editas aquí)
- **Deployment:** `out/artifacts/TELITO_BODEGUERO-1.0-SNAPSHOT/` (Tomcat lee de aquí)

---

## ⚠️ Problemas comunes

### **Error 500 / Whitelabel Error:**
**Causa:** Archivos JSP no sincronizados
**Solución:** Ejecutar `.\sync-project.ps1` y reiniciar Tomcat

### **Cambios no se ven:**
**Causa:** Caché del navegador
**Solución:** `Ctrl + Shift + R` (hard refresh)

### **application.properties no encontrado:**
**Causa:** Recursos no copiados a WEB-INF/classes
**Solución:** Ejecutar `.\sync-project.ps1`

---

## 🎯 Para el sistema de notificaciones

Después de modificar:
- `header_admin.jsp`
- `notificaciones.jsp`
- `NotificacionServlet.java`

**Ejecutar:**
```powershell
.\sync-project.ps1
```

Luego reiniciar Tomcat en IntelliJ.

---

## ✅ Verificación rápida

**¿Todo está sincronizado?**
```powershell
# Verificar que existen los archivos actualizados
Test-Path "out\artifacts\TELITO_BODEGUERO-1.0-SNAPSHOT\administrador\notificaciones.jsp"
Test-Path "out\artifacts\TELITO_BODEGUERO-1.0-SNAPSHOT\WEB-INF\classes\application.properties"
```

Si ambos devuelven `True`, estás listo.

---

**Última actualización:** 10 de diciembre de 2025
