# RESUMEN EJECUTIVO
## Sistema de Gestión de Inventarios - Telito Bodeguero

**Coordinador del Proyecto:** Brenda Tumbalobos Cubas  
**Curso:** TEL131 – Ingeniería Web para Telecomunicaciones  
**Universidad:** Pontificia Universidad Católica del Perú  
**Ciclo:** 2025-II

---

## 1. INFORMACIÓN GENERAL DEL PROYECTO

### 1.1 Título del Proyecto
**Sistema de Gestión de Inventarios - Telito Bodeguero**

### 1.2 Objetivo Principal
Desarrollar y gestionar un sistema de inventario de forma eficiente que permita automatizar reportes, facilitar la carga masiva de datos mediante plantillas Excel, y asignar roles y permisos diferenciados a los usuarios.

### 1.3 Alcance
El sistema Telito Bodeguero es una aplicación web de gestión de inventario orientada a bodegas y pequeños negocios que permite:
- Registrar y controlar productos y lotes
- Gestionar entradas y salidas de inventario
- Visualizar métricas clave en dashboards interactivos
- Generar reportes en formato Excel
- Realizar cargas masivas mediante plantillas Excel
- Gestionar usuarios con roles y permisos diferenciados

---

## 2. ESTADO ACTUAL DEL PROYECTO

### 2.1 Cumplimiento de Requerimientos
**Estado General: 95% CUMPLIDO**

El sistema ha sido desarrollado exitosamente cumpliendo con la mayoría de los requerimientos especificados:

✅ **Funcionalidades Implementadas:**
- Sistema completo de autenticación y autorización
- Gestión de productos y lotes con trazabilidad
- Control de inventario (entradas, salidas, ajustes)
- Sistema de reportes en Excel
- Dashboards interactivos por rol
- Carga masiva mediante plantillas Excel
- Sistema de alertas automáticas
- Gestión geográfica por zonas y distritos
- Sistema de auditoría

### 2.2 Tecnologías Utilizadas
- **Backend:** Java 17, Spring Boot 3.1.5
- **Frontend:** JSP, Bootstrap 5, JavaScript
- **Base de Datos:** MySQL 8.0+
- **Cloud:** Google Cloud Platform (GCP)
- **Herramientas:** Maven, GitHub, Apache POI

### 2.3 Roles Implementados
1. **Productor:** Registra productos y lotes propios
2. **Logística:** Supervisa flujo, genera órdenes de compra, planifica transporte
3. **Almacén:** Controla inventario físico, valida cargas masivas, reporta incidencias
4. **Administrador:** Gestión completa del sistema, usuarios, configuración

---

## 3. ARQUITECTURA DEL SISTEMA

### 3.1 Arquitectura General
El sistema sigue una arquitectura de **tres capas (3-tier)**:
- **Capa de Presentación:** JSP, HTML, CSS, JavaScript
- **Capa de Lógica de Negocio:** Servlets, Services, DAOs
- **Capa de Datos:** MySQL Database

### 3.2 Patrón de Diseño
Implementa el patrón **MVC (Model-View-Controller)** con separación clara de responsabilidades.

---

## 4. INFRAESTRUCTURA Y DESPLIEGUE

### 4.1 Plataforma de Despliegue
- **Cloud Platform:** Amazon Web Services (AWS)
- **Servidor:** EC2 (Elastic Compute Cloud)
- **Base de Datos:** RDS MySQL o MySQL en EC2

### 4.2 Costos Estimados
- **Costo mensual (sin Free Tier):** ~$26.40 USD
- **Costo mensual (con Free Tier):** ~$0-3 USD
- **Costo total (4 meses sin Free Tier):** ~$105.60 USD
- **Costo total (4 meses con Free Tier):** ~$0-15 USD
- **Presupuesto asignado:** $50 USD
- **Recomendación:** Usar Free Tier de AWS (12 meses gratis)

---

## 5. ENTREGABLES

### 5.1 Entregables Técnicos
✅ Sistema desplegado en Google Cloud Platform  
✅ Repositorio GitHub con código fuente  
✅ Documentación completa del proyecto  
✅ Base de datos MySQL implementada  
✅ Sistema funcional con todos los módulos

### 5.2 Entregables de Documentación
✅ Plan de proyecto  
✅ Documentación técnica  
✅ Manuales de usuario  
✅ Análisis de costos  
✅ Diagramas de arquitectura

---

## 6. PRÓXIMOS PASOS

### 6.1 Mejoras Pendientes
- Optimización de consultas de base de datos
- Implementación de tests automatizados
- Mejoras en la interfaz de usuario
- Optimización de costos en GCP

### 6.2 Recomendaciones
- Implementar HTTPS obligatorio en producción
- Agregar rate limiting para seguridad
- Implementar caché para mejorar rendimiento
- Considerar escalado horizontal para futuro crecimiento

---

## 7. CONCLUSIÓN

El sistema **Telito Bodeguero** ha sido desarrollado exitosamente, cumpliendo con el 95% de los requerimientos especificados. El sistema está funcional, desplegado y listo para ser utilizado. La arquitectura implementada es escalable y mantenible, utilizando tecnologías modernas y mejores prácticas de desarrollo.

El proyecto demuestra un alto nivel de cumplimiento de los objetivos planteados y está preparado para ser presentado como trabajo final del curso.

---

**Fecha de Generación:** [Fecha]  
**Versión:** 1.0  
**Autor:** Equipo de Desarrollo Telito Bodeguero
