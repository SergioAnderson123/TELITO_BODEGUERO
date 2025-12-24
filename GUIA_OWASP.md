# 🔒 Guía de Seguridad OWASP para TELITO_BODEGUERO

## 📋 Resumen
Esta guía te ayudará a configurar y usar herramientas OWASP para analizar la seguridad de tu aplicación.

---

## 🛠️ HERRAMIENTA 1: OWASP Dependency-Check

### ✅ ¿Qué necesitas instalar?
**NADA** - Ya está configurado en tu `pom.xml` como plugin de Maven.

### 📝 ¿Qué hace?
Analiza todas tus dependencias (MySQL Connector, JSTL, Spring Boot, etc.) y detecta si tienen vulnerabilidades conocidas (CVEs).

### 🚀 Cómo usarlo:

#### Opción A: Desde la línea de comandos (Maven)
```bash
# Abre PowerShell o CMD en la carpeta del proyecto
mvn dependency-check:check
```

#### Opción B: Desde IntelliJ IDEA / Eclipse
1. Abre la ventana de Maven (View → Tool Windows → Maven)
2. Expande: `TELITO_BODEGUERO` → `Plugins` → `dependency-check`
3. Haz doble clic en `dependency-check:check`

### 📊 Ver resultados:
Después de ejecutar, abre el archivo:
```
target/dependency-check-report/dependency-check-report.html
```

Este archivo HTML te mostrará:
- ✅ Dependencias seguras
- ⚠️ Dependencias con vulnerabilidades conocidas
- 📝 Recomendaciones de actualización

### ⏱️ Tiempo estimado:
- Primera ejecución: 5-10 minutos (descarga base de datos de CVEs)
- Ejecuciones siguientes: 2-5 minutos

---

## 🛠️ HERRAMIENTA 2: OWASP ZAP (Zed Attack Proxy)

### ✅ ¿Qué necesitas instalar?
**Solo descargar 1 archivo** (no requiere instalación compleja)

### 📥 Descarga:
1. Ve a: https://www.zaproxy.org/download/
2. Descarga: **OWASP ZAP Windows Installer** (archivo `.exe`)
3. Ejecuta el instalador (siguiente, siguiente, siguiente...)
4. Listo ✅

### 📝 ¿Qué hace?
Simula ataques reales a tu aplicación web:
- SQL Injection
- Cross-Site Scripting (XSS)
- Cross-Site Request Forgery (CSRF)
- Y muchas más vulnerabilidades

### 🚀 Cómo usarlo:

#### Paso 1: Inicia tu aplicación
```bash
# Asegúrate de que tu app esté corriendo en:
http://localhost:8080/TELITO_BODEGUERO
```

#### Paso 2: Abre OWASP ZAP
- Busca "OWASP ZAP" en el menú de inicio de Windows
- Se abrirá una ventana con un navegador integrado

#### Paso 3: Escaneo rápido (Quick Start)
1. En la ventana de ZAP, verás un botón **"Quick Start"**
2. Ingresa la URL: `http://localhost:8080/TELITO_BODEGUERO`
3. Haz clic en **"Attack"**
4. Espera a que termine (5-15 minutos dependiendo del tamaño)

#### Paso 4: Ver resultados
1. Ve a la pestaña **"Alerts"** (Alertas)
2. Verás vulnerabilidades encontradas clasificadas por:
   - 🔴 **High** (Alta)
   - 🟡 **Medium** (Media)
   - 🟢 **Low** (Baja)
   - ℹ️ **Informational** (Informativo)

### 📊 Reporte:
1. Menú: **Report** → **Generate HTML Report**
2. Guarda el reporte donde quieras
3. Ábrelo en tu navegador para ver detalles

### ⚠️ Nota importante:
- ZAP puede generar **falsos positivos** (reporta problemas que no son reales)
- Revisa cada alerta manualmente
- Las alertas "Informational" generalmente son solo advertencias

### ⏱️ Tiempo estimado:
- Instalación: 2 minutos
- Escaneo: 5-15 minutos
- Revisión de resultados: 10-30 minutos

---

## 📝 Checklist de Seguridad Rápida

### ✅ Después de ejecutar Dependency-Check:
- [ ] Revisar dependencias con vulnerabilidades **High** o **Critical**
- [ ] Actualizar dependencias vulnerables a versiones más recientes
- [ ] Verificar que las actualizaciones no rompan tu código

### ✅ Después de ejecutar ZAP:
- [ ] Revisar alertas **High** y **Medium**
- [ ] Verificar si son falsos positivos
- [ ] Corregir vulnerabilidades reales encontradas

---

## 🎯 Ejemplo de Comandos Rápidos

### Ejecutar Dependency-Check:
```bash
# Desde la carpeta del proyecto
mvn dependency-check:check

# Ver el reporte
start target/dependency-check-report/dependency-check-report.html
```

### Ejecutar ZAP:
1. Abre OWASP ZAP
2. Quick Start → Ingresa URL → Attack
3. Espera resultados

---

## ❓ Preguntas Frecuentes

### ¿Necesito instalar Java o Maven?
- **Maven**: Ya lo tienes (estás usando `pom.xml`)
- **Java**: Ya lo tienes (tu proyecto usa Java 17)

### ¿Puedo ejecutar esto en producción?
- **Dependency-Check**: Sí, es seguro
- **ZAP**: Solo en desarrollo/testing. **NO** ejecutes ZAP contra servidores de producción sin autorización.

### ¿Qué hago si encuentro vulnerabilidades?
1. **Dependency-Check**: Actualiza las dependencias vulnerables
2. **ZAP**: Revisa si son falsos positivos, si no, corrige el código

### ¿Cuánto tiempo toma todo?
- **Dependency-Check**: 5-10 minutos (primera vez), 2-5 minutos (siguientes)
- **ZAP**: 5-15 minutos de escaneo + tiempo de revisión

---

## 📚 Recursos Adicionales

- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **Dependency-Check Docs**: https://jeremylong.github.io/DependencyCheck/
- **ZAP Documentation**: https://www.zaproxy.org/docs/

---

## ✅ Listo para empezar

1. **Ejecuta Dependency-Check**: `mvn dependency-check:check`
2. **Descarga e instala ZAP**: https://www.zaproxy.org/download/
3. **Escanea tu aplicación** con ZAP

¡Buena suerte con la seguridad! 🔒


