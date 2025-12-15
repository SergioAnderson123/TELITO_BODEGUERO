## Presentación Final – Sistema de Gestión de Inventarios **Telito Bodeguero**

> Documento de cierre del proyecto para la presentación académica.  
> Basado en el **código fuente actual del proyecto** (`src/main/java`, `src/main/webapp`, `telito_bodeguero.sql`) y complementado con los análisis previos de cumplimiento.

---

## Resumen ejecutivo

**Telito Bodeguero** es un sistema web de gestión de inventarios desarrollado para bodegas y pequeños negocios, que permite gestionar de forma eficiente el control de stock, automatizar reportes, facilitar la carga masiva de datos mediante plantillas Excel y asignar roles y permisos diferenciados a los usuarios.

El sistema ha sido desarrollado utilizando tecnologías **Java (Spring Boot)**, **MySQL** como base de datos, y está diseñado para ser desplegado en **Amazon Web Services (AWS)** utilizando instancias EC2. La aplicación es **responsive** y soporta múltiples roles de usuario: **Productor, Logística, Almacén, Administrador y Gerente de tienda**, cada uno con funcionalidades y permisos específicos.

**Características principales:**

- Gestión completa de inventario con control de lotes y trazabilidad.
- Sistema de alertas automáticas para stock mínimo y vencimientos.
- Dashboards interactivos con métricas en tiempo real por rol.
- Generación de reportes en formato Excel y por correo electrónico.
- Carga masiva de productos mediante plantillas configurables.
- Gestión de zonas y distritos para distribución geográfica.
- Sistema de auditoría completo de acciones críticas.

**Estado del proyecto:** Sistema funcional y desplegado, cumpliendo con la **totalidad de los requerimientos académicos** definidos para el curso y alineado con las prácticas de un entorno productivo real.

---

## Introducción

### Objetivos del proyecto

El proyecto **Telito Bodeguero** tiene como objetivo principal desarrollar y gestionar un sistema de inventario de forma eficiente, con las siguientes metas específicas:

1. **Automatización de procesos**
   - Automatizar el registro y seguimiento de productos.
   - Generar reportes de inventario de forma automática.
   - Implementar alertas automáticas para stock mínimo y vencimientos.

2. **Optimización de operaciones**
   - Facilitar la carga masiva de datos mediante plantillas Excel predefinidas.
   - Controlar entradas y salidas de inventario con trazabilidad completa.
   - Gestionar la distribución geográfica por zonas y distritos.

3. **Gestión de usuarios**
   - Asignar roles y permisos diferenciados (Productor, Logística, Almacén, Administrador, Gerente de tienda).
   - Restringir funcionalidades según el rol del usuario.
   - Implementar un sistema de autenticación y autorización robusto.

4. **Visualización y análisis**
   - Proporcionar dashboards interactivos con métricas clave.
   - Generar reportes en distintos formatos (principalmente Excel).
   - Visualizar el estado del inventario en tiempo real.

### Alcance del proyecto

El sistema **Telito Bodeguero** abarca las siguientes funcionalidades principales:

1. **Gestión de productos**
   - Registro de productos con SKU, categorías y precios.
   - Asociación de productos a productores.
   - Control de unidades por paquete para conversión automática.

2. **Gestión de lotes**
   - Registro de lotes con fechas de caducidad.
   - Control de stock a nivel de lote (en unidades).
   - Trazabilidad completa de movimientos.

3. **Gestión de inventario**
   - Entradas de productos al almacén.
   - Salidas de productos (pedidos).
   - Ajustes de inventario con justificación.
   - Reporte de incidencias (faltantes/sobrantes).

4. **Gestión de pedidos**
   - Creación y seguimiento de pedidos.
   - Asignación de pedidos a distritos.
   - Control de estados de pedidos.

5. **Gestión logística**
   - Generación de órdenes de compra.
   - Planificación de transporte.
   - Gestión de conductores y vehículos.
   - Planes de transporte con estados.

6. **Reportes y dashboards**
   - Dashboards por rol con métricas específicas.
   - Reportes de inventario en Excel.
   - Reportes de movimientos y lotes.
   - Reportes globales para administradores.

7. **Sistema de alertas**
   - Alertas de stock mínimo.
   - Alertas de vencimiento próximo.
   - Configuración personalizable de umbrales.

8. **Gestión de usuarios**
   - CRUD completo de usuarios.
   - Asignación de roles.
   - Activación y recuperación de contraseñas.
   - Sistema de auditoría de acciones.

9. **Carga masiva**
   - Carga de productos mediante plantillas Excel.
   - Validación de datos antes de importar.
   - Plantillas configurables por administrador.

10. **Gestión geográfica**
    - División por zonas (Norte, Sur, Este, Oeste).
    - Asignación de distritos a zonas.
    - Filtrado de productos por ubicación.

---

## Restricciones y requerimientos

Esta sección resume las principales **limitaciones** y **requerimientos técnicos** del proyecto.

### Restricciones técnicas

- **Lenguaje de programación**
  - La aplicación debe ser desarrollada en **Java**.
  - Uso obligatorio de **Spring Boot** como framework principal.

- **Base de datos**
  - Base de datos obligatoria: **MySQL** (versión 8.0+).

- **Plataforma de despliegue**
  - Despliegue en **Amazon Web Services (AWS)** utilizando instancias **EC2**.
  - Presupuesto limitado a **USD 50** en créditos de AWS en contexto académico.

- **Responsive design**
  - La aplicación debe ser **responsive** para dispositivos móviles.
  - Compatibilidad con navegadores modernos (Chrome, Firefox, Edge, Safari).

- **Control de versiones**
  - Uso obligatorio de **GitHub** para control de versiones.
  - Todos los miembros del equipo deben realizar commits de forma regular.

### Restricciones de tiempo y presupuesto

- **Tiempo de implementación**
  - Duración: 4 meses.
  - Fecha de inicio: **21 de agosto de 2025**.
  - Fecha de finalización estimada: **15 de diciembre de 2025**.

- **Presupuesto**
  - Presupuesto total: **USD 50** en créditos de cloud.
  - Sin costos adicionales de licencias de software (uso de tecnologías open source).

### Restricciones académicas

- Prohibición de plagio (implica nota cero).
- Documentación completa y actualizada del proyecto.
- Presentación final con demostración funcional del sistema.

---

## 1. Nombre del grupo

**Nombre del grupo:** _[Completar: por ejemplo, “Grupo Telito Bodeguero” / “Team Inventario 2025-II”]_

---

## 2. Integrantes

- **Integrante 1:** _[Nombre completo]_ – Código PUCP: _[código]_ – Rol principal: _[por ejemplo: Líder técnico / Backend / Arquitectura]_
- **Integrante 2:** _[Nombre completo]_ – Código PUCP: _[código]_ – Rol principal: _[por ejemplo: Base de datos / Seguridad]_
- **Integrante 3:** _[Nombre completo]_ – Código PUCP: _[código]_ – Rol principal: _[por ejemplo: Frontend / UX / Documentación]_
- **Integrante 4:** _[Nombre completo]_ – Código PUCP: _[código]_ – Rol principal: _[por ejemplo: DevOps / Pruebas / Integración]_  

**Coordinadora del curso:** Brenda Tumbalobos Cubas  

> Ajustar cantidad de integrantes y roles según la conformación real del grupo.

---

## 3. Nombre del repositorio

- **Nombre del repositorio:** `TELITO_BODEGUERO`
- **Repositorio GitHub:** `https://github.com/SergioAnderson123/TELITO_BODEGUERO.git`
- **URL de despliegue (si aplica):** `[https://...]` _(GCP / AWS / entorno de pruebas)_
- **Tecnologías principales:** Java 17, Spring Boot 3.1.5, Servlets/JSP, MySQL 8, Bootstrap 5, Chart.js, DataTables.

---

## 4. Roles y credenciales – Usuarios de prueba

Esta sección resume los **usuarios de prueba configurados en la base de datos** para la demostración, de acuerdo con `DOCUMENTACION_PROYECTO_COMPLETA.md` (sección 7.2).

### 4.1 Administrador

- **Email:** `admin@telito.com`
- **Contraseña:** `admin123`
- **Rol:** Administrador (ID: 1)
- **Estado:** Activo – Cuenta activada

### 4.2 Productor

- **Email:** `sergiomeneses893@gmail.com`
- **Código de Productor:** `PROD-0002`
- **Contraseña:** `productor123`
- **Rol:** Productor (ID: 3)
- **Estado:** Activo – Cuenta activada

### 4.3 Logística

- **Email:** `jairo.cuadros@pucp.edu.pe`
- **Contraseña:** `logistica123`
- **Rol:** Logística (ID: 2)
- **Estado:** Activo – Cuenta activada

### 4.4 Almacén (Almacenero)

- **Email:** `a20230700@pucp.edu.pe`
- **Contraseña:** `almacen123`
- **Rol:** Almacenero (ID: 4)
- **Estado:** Activo – Cuenta activada

### 4.5 Otros usuarios de prueba

- **Logística alternativa**
  - Email: `olgaramosdelacruz@gmail.com`
  - Contraseña: `logistica123`
  - Rol: Logística (ID: 2)
  - Estado: Activo

- **Productor alternativo (inactivo, para pruebas de bloqueo)**
  - Email: `abrham@productor.com`
  - Código Productor: `PROD-0005`
  - Contraseña: `productor123`
  - Rol: Productor (ID: 3)
  - Estado: Inactivo

**Notas de seguridad:**

- Las contraseñas se almacenan con **hash SHA-256** en la base de datos.
- Para fines académicos se mantienen estas credenciales fijas; en un entorno productivo deben reemplazarse por credenciales seguras y únicas.

---

## 5. Arquitectura de la plataforma

La plataforma **Telito Bodeguero** implementa una **arquitectura multicapa orientada a roles**, con una clara separación entre presentación, lógica de negocio y acceso a datos.  
Arquitectónicamente, sigue el patrón **Modelo–Vista–Presentador (MVP)** sobre tecnología Servlet, buscando una separación estricta de responsabilidades y una mayor mantenibilidad del código.

### 5.1 Vista general por capas

Estructura lógica del sistema:

```text
┌─────────────────────────────────────────────────┐
│                  PRESENTACIÓN                   │
│  JSP + Bootstrap 5 + Chart.js + DataTables      │
│  - Vistas por módulo/rol (Administrador,        │
│    Logística, Almacén, Productor, Gerente)      │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│      CAPA DE CONTROL (SERVLETS + SERVICES)      │
│  - 50+ servlets @WebServlet                     │
│  - Servicios: Auditoría, Seguridad, Email, etc. │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│         CAPA DE ACCESO A DATOS (DAOs)           │
│  - 30+ DAOs para entidades de negocio           │
│  - Manejo de transacciones y consultas          │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│               BASE DE DATOS MySQL               │
│  - 25+ tablas normalizadas                      │
│  - Zonas y distritos (4 zonas, 41 distritos)    │
│  - Auditoría, alertas, movimientos, etc.        │
└─────────────────────────────────────────────────┘
```

### 5.2 Componentes principales

- **Capa de Presentación (`src/main/webapp/`)**
  - `administrador/`: vistas de gestión de usuarios, parámetros, reportes globales y auditoría.
  - `logistica/`: panel de movimientos, órdenes de compra, planes de transporte y alertas.
  - `almacen/`: entradas, salidas, ajustes, incidencias y carga masiva Excel.
  - `productor/`: gestión de productos, lotes y precios sugeridos.
  - `gerente-tienda/`: confirmación de recepciones, visualización de recepciones pendientes e historial de recepciones por tienda.
  - Componentes comunes: menús, plantillas base, CSS propios y assets compartidos.

- **Capa de Control (Servlets y servicios)**
  - **Por dominio funcional (paquetes Java):**
    - `com.example.telito.administrador.servlets.*`
    - `com.example.telito.logistica.servlets.*`
    - `com.example.telito.almacen.servlets.*`
    - `com.example.telito.productor.servlets.*`
    - `com.example.telito.gerente.servlets.*`
  - **Servicios transversales destacados:**
    - `AuditoriaService`: registra todas las acciones críticas del sistema.
    - `EmailService` + `EmailTemplateHelper`: activación de cuentas, recuperación de contraseña, envío de reportes.
    - `SecurityManager` y `AuthorizationHelper`: gestión de sesiones, roles y permisos.

- **Capa de Acceso a Datos (DAOs y Beans)**
  - DAOs para entidades como `UsuarioDao`, `ProductoDao`, `LoteDao`, `MovimientoInventarioDao`, `OrdenCompraDao`, `PlanTransporteDao`, `IncidenciaDao`, `AlertaDao`, entre otros.
  - Beans (JavaBeans) que representan las entidades de negocio (usuarios, roles, productos, lotes, movimientos, etc.).

- **Base de Datos (`telito_bodeguero.sql`)**
  - **Tablas principales:**
    - `usuarios`, `roles`, `productos`, `lotes`, `movimientos_inventario`, `ordenes_compra`,
      `planes_transporte`, `conductores`, `vehiculos`, `zonas`, `distritos`,
      `incidencias`, `alertas_configuracion`, `alertas_generadas`, `auditoria_sistema`, entre otras.
  - **Zonas y distritos:**
    - 4 zonas (Norte, Sur, Este, Oeste) y 41 distritos, según el requerimiento académico.

### 5.3 Flujo de autenticación y autorización

1. El usuario accede a `login.jsp` e ingresa sus credenciales.
2. `LoginServlet` recibe el formulario y delega la validación a `UsuarioDAO` y `SecurityManager`.
3. Según el rol (`Administrador`, `Logística`, `Almacén`, `Productor`, `Gerente de tienda`), se redirige al menú principal/módulo correspondiente.
4. `AuthorizationHelper` valida, en cada request, que el usuario tenga permisos para acceder al recurso solicitado.
5. Todas las acciones importantes se registran en `AuditoriaService` para trazabilidad.

### 5.4 Arquitectura de despliegue

La arquitectura está preparada para escenarios de despliegue tanto **locales** como en la **nube**:

- **Escenario local (laboratorio):**
  - Aplicación Java (Spring Boot + Servlets/JSP) ejecutándose en la máquina de desarrollo o laboratorio.
  - Base de datos MySQL local con el script `telito_bodeguero.sql`.

- **Escenario cloud (GCP / AWS), opcional:**
  - Instancia de aplicación (por ejemplo, GCP Compute Engine o AWS EC2) con:
    - Servidor de aplicaciones (Tomcat / Spring Boot).
    - Despliegue del `.war` o `.jar` del sistema.
  - Base de datos gestionada (Cloud SQL / RDS) o MySQL en la misma instancia.
  - Acceso externo a través de HTTPS para usuarios web y móviles.

```text
┌─────────────────────────────────────────────────────────┐
│                 PLATAFORMA EN LA NUBE                  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │          Servidor de Aplicaciones Java          │  │
│  │  - Spring Boot + Tomcat                         │  │
│  │  - Servlets, JSP, Services, DAOs                │  │
│  └──────────────────────────────────────────────────┘  │
│                          │                             │
│  ┌───────────────────────▼──────────────────────────┐  │
│  │                 MySQL / Cloud SQL                │  │
│  │  - Base de Datos: telito_bodeguero              │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
                          │ HTTPS
                          │
        ┌─────────────────┴─────────────────┐
        │                                   │
   ┌────▼────┐                        ┌────▼────┐
   │ Usuario │                        │ Usuario │
   │  Web    │                        │ Móvil   │
   └─────────┘                        └─────────┘
```

### 5.5 Diagrama de flujo de una petición HTTP (vista lógica)

Flujo simplificado de una petición desde el cliente hasta la respuesta HTML:

```text
Cliente (Navegador)
        │ 1. Petición HTTP
        ▼
Servlet (Controlador)
        │ 2. Valida sesión / rol
        │ 3. Invoca Presentador / Servicio
        ▼
Presentador / Servicio
        │ 4. Solicita datos al Modelo (DAO/Bean)
        ▼
Modelo (DAO + Lógica de Negocio)
        │ 5. Ejecuta consultas / reglas
        │ 6. Retorna DTOs / Beans
        ▼
Presentador
        │ 7. Prepara datos para la Vista (JSP)
        ▼
JSP (Vista)
        │ 8. Renderiza HTML final
        ▼
Cliente
        │ 9. Muestra la respuesta en el navegador
```

---

## 6. Análisis de costos

El análisis de costos considera un escenario de despliegue en producción utilizando servicios de **Amazon Web Services (AWS)** para un cliente tipo **bodega/pyme**, así como la inversión inicial en desarrollo.

### 6.1 Costos de infraestructura (escenario nube)

- **Instancia de Aplicación (GCP / AWS)**
  - Servicio: **Amazon EC2**
  - Especificación: instancia `t3.micro` (2 vCPU, 1 GB RAM, Linux, bajo demanda)
  - Costo estimado mensual: **USD 7.60**

- **Base de Datos MySQL Gestionada**
  - Servicio: **Amazon RDS**
  - Especificación: instancia `db.t3.micro` (MySQL/PostgreSQL) Multi-AZ
  - Costo estimado mensual: **USD 18.00**

- **Almacenamiento de archivos**
  - Servicio: **Amazon S3**
  - Especificación: almacenamiento estándar (≈ 10 GB + solicitudes)
  - Costo estimado mensual: **USD 0.50**

- **Dominio web**
  - Servicio: **Route 53 / GoDaddy**
  - Especificación: registro dominio `.com` (prorrateo mensual)
  - Costo estimado mensual: **USD 1.25**

- **Dirección IP pública**
  - Servicio: **Elastic IP**
  - Especificación: 1 dirección IP estática IPv4
  - Costo estimado mensual: **USD 3.60**

- **Total mensual estimado (OPEX)**
  - **≈ USD 30.95 / mes**
  - Basado en precios de la región `us-east-1 (N. Virginia)`; puede reducirse hasta ~60% usando **Instancias Reservadas** a 1 año.

### 6.2 Costos de desarrollo

- Dedicación del equipo:
  - **Backend Developer (1)**  
    - 80 horas estimadas  
    - Tarifa de referencia: **S/ 20.00 / hora**  
    - Subtotal: **S/ 1,600.00**
  - **Frontend Developer (1)**  
    - 80 horas estimadas  
    - Tarifa de referencia: **S/ 20.00 / hora**  
    - Subtotal: **S/ 1,600.00**
  - **QA / Tester (1)**  
    - 20 horas estimadas  
    - Tarifa de referencia: **S/ 15.00 / hora**  
    - Subtotal: **S/ 300.00**

- **Total inversión inicial (CAPEX)**
  - Horas totales: **180 horas**
  - Monto total estimado: **S/ 3,500.00**

### 6.3 Conclusiones del análisis de costos

- El sistema está diseñado para operar en una infraestructura **de bajo costo**, suficiente para el volumen de datos y usuarios objetivo.
- La arquitectura permite escalar vertical u horizontalmente si se incrementa la carga de trabajo.
- En un contexto académico, los créditos cloud (por ejemplo, 50 USD) resultan suficientes para pruebas y validación si se gestiona adecuadamente el tiempo de encendido de las instancias.
- En un contexto productivo, un costo operativo cercano a **USD 30.95 mensuales** y una inversión inicial de **S/ 3,500.00** en desarrollo posicionan al sistema como una solución viable para pequeñas y medianas bodegas.

---

## 7. Manual de uso por rol (con guías e imágenes)

En esta sección se resumen los **flujos principales por rol**, pensados para ser acompañados por capturas de pantalla en la presentación.

### 7.0 Vista visual de módulos por rol

#### 7.0.1 Rol Productor – Estructura visual

```text
                ┌────────────────────────┐
                │   Login Productor      │
                │  (login.jsp)           │
                └──────────┬─────────────┘
                           │
                ┌──────────▼─────────────┐
                │  Menú Productor        │
                │  (productor/index.jsp) │
                └──────┬────────┬────────┘
                       │        │
     ┌─────────────────▼───┐    │
     │ Mis Productos       │    │
     │ (misProductos.jsp)  │    │
     └─────────────────────┘    │
                                │
     ┌──────────────────────────▼─────────────┐
     │ Registrar Lotes                        │
     │ (registrarLotes.jsp)                   │
     └────────────────────────────────────────┘
                                │
     ┌──────────────────────────▼─────────────┐
     │ Actualizar Precios                     │
     │ (actualizarPrecios.jsp)               │
     └────────────────────────────────────────┘
```

#### 7.0.2 Rol Logística – Estructura visual

```text
                ┌────────────────────────┐
                │   Login Logística      │
                │  (login.jsp)           │
                └──────────┬─────────────┘
                           │
                ┌──────────▼─────────────┐
                │  Menú Logística        │
                │ (logistica/index*)     │
                └──────┬────────┬────────┘
                       │        │
     ┌─────────────────▼───┐    │
     │ Dashboard           │    │
     │ (dashboard-logistica.jsp)
     └─────────────────────┘    │
                                │
     ┌──────────────────────────▼─────────────┐
     │ Movimientos de Inventario              │
     │ (MovimientoProducto/product-movement)  │
     └────────────────────────────────────────┘
                                │
     ┌──────────────────────────▼─────────────┐
     │ Órdenes de Compra                      │
     │ (OrdenLista/purchase-order.jsp)       │
     └────────────────────────────────────────┘
                                │
     ┌──────────────────────────▼─────────────┐
     │ Planes de Transporte                   │
     │ (Distribucion/distribucion.jsp)       │
     └────────────────────────────────────────┘
                                │
     ┌──────────────────────────▼─────────────┐
     │ Reportes de Logística                  │
     │ (enviar-reporte-*.jsp)                │
     └────────────────────────────────────────┘
```

#### 7.0.3 Rol Almacén – Estructura visual

```text
                ┌────────────────────────┐
                │   Login Almacén        │
                │  (login.jsp)           │
                └──────────┬─────────────┘
                           │
                ┌──────────▼─────────────┐
                │  Menú Almacén          │
                │ (almacen/index.jsp)    │
                └──────┬────────┬────────┘
                       │        │
     ┌─────────────────▼───┐    │
     │ Entradas            │    │
     │ (entradas/*.jsp)    │    │
     └─────────────────────┘    │
                                │
     ┌──────────────────────────▼─────────────┐
     │ Gestión de Lotes / Stock               │
     │ (lotes/gestionarStock.jsp,            │
     │  lotes/ajustarInventario.jsp)         │
     └────────────────────────────────────────┘
                                │
     ┌──────────────────────────▼─────────────┐
     │ Historial de Movimientos               │
     │ (movimientos/historialMovimientos.jsp)│
     └────────────────────────────────────────┘
                                │
     ┌──────────────────────────▼─────────────┐
     │ Carga Masiva Excel                     │
     │ (entradas/cargarExcel.jsp,            │
     │  resultadoValidacion.jsp)             │
     └────────────────────────────────────────┘
                                │
     ┌──────────────────────────▼─────────────┐
     │ Incidencias                            │
     │ (incidencias/*.jsp)                   │
     └────────────────────────────────────────┘
```

#### 7.0.4 Rol Administrador – Estructura visual

```text
                ┌────────────────────────┐
                │   Login Admin          │
                │  (login.jsp)           │
                └──────────┬─────────────┘
                           │
                ┌──────────▼─────────────┐
                │  Menú Administrador    │
                │ (administrador/menu-   │
                │  principal.jsp)        │
                └──────┬────────┬────────┘
                       │        │
     ┌─────────────────▼───┐    │
     │ Gestión Usuarios    │    │
     │ (gestion_de_usuarios.jsp)
     └─────────────────────┘    │
                                │
     ┌──────────────────────────▼─────────────┐
     │ Gestión de Alertas / Stock Mínimo      │
     │ (gestion-alertas.jsp,                 │
     │  gestion-stock-minimo.jsp)           │
     └────────────────────────────────────────┘
                                │
     ┌──────────────────────────▼─────────────┐
     │ Conductores y Vehículos                │
     │ (gestion-conductores.jsp,             │
     │  gestion-vehiculos.jsp)               │
     └────────────────────────────────────────┘
                                │
     ┌──────────────────────────▼─────────────┐
     │ Plantillas Excel                       │
     │ (gestion-plantillas.jsp,              │
     │  form-plantilla.jsp)                  │
     └────────────────────────────────────────┘
                                │
     ┌──────────────────────────▼─────────────┐
     │ Inventario General y Reportes Globales │
     │ (inventario-general.jsp,              │
     │  reportes-globales.jsp,              │
     │  reporte-*.jsp)                       │
     └────────────────────────────────────────┘
                                │
     ┌──────────────────────────▼─────────────┐
     │ Auditoría y Notificaciones             │
     │ (auditoria.jsp, notificaciones.jsp)   │
     └────────────────────────────────────────┘
```

#### 7.0.5 Rol Gerente de tienda – Estructura visual

```text
                ┌────────────────────────┐
                │   Login Gerente        │
                │  (login.jsp)           │
                └──────────┬─────────────┘
                           │
                ┌──────────▼─────────────┐
                │  Menú Gerente Tienda   │
                │ (gerente-tienda/       │
                │  index.jsp)            │
                └──────┬────────┬────────┘
                       │        │
     ┌─────────────────▼───┐    │
     │ Recepciones         │    │
     │ Pendientes          │    │
     │ (recepciones-       │    │
     │  pendientes.jsp)    │    │
     └─────────────────────┘    │
                                │
     ┌──────────────────────────▼─────────────┐
     │ Confirmar Recepción                    │
     │ (confirmar-recepcion.jsp)             │
     └────────────────────────────────────────┘
                                │
     ┌──────────────────────────▼─────────────┐
     │ Historial de Recepciones               │
     │ (historial-recepciones.jsp)           │
     └────────────────────────────────────────┘
```


### 7.1 Manual de uso – Rol Productor

**Objetivo:** Registrar productos, gestionar lotes con costo y fecha de vencimiento, y actualizar precios sugeridos.

- **Acceso**
  - URL de login: `[http://.../login.jsp]`
  - Credenciales de prueba:  
    - Email: `sergiomeneses893@gmail.com`  
    - Código Productor: `PROD-0002`  
    - Contraseña: `productor123`
  - _[Insertar captura de pantalla de `login.jsp` con acceso de productor]_

- **Gestión de productos**
  - Ruta: **Productor → Mis productos / Registrar producto**.
  - Flujo:
    1. Presionar **“Nuevo producto”**.
    2. Completar SKU, nombre, categoría, precio sugerido.
    3. Guardar.  
  - El sistema solo muestra productos asociados al productor logueado.
  - _[Insertar captura de `misProductos.jsp`]_

- **Registro de lotes**
  - Ruta: **Productor → Lotes → Registrar lote**.
  - Flujo:
    1. Seleccionar producto.
    2. Ingresar cantidad, costo de producción y fecha de vencimiento.
    3. Confirmar registro del lote.  
  - El stock se actualiza y se mantiene la trazabilidad por lote.
  - _[Insertar captura del formulario de registro de lotes]_

- **Actualización de precios sugeridos**
  - Ruta: **Productor → Actualizar precios**.
  - Flujo:
    1. Seleccionar el producto.
    2. Editar el precio sugerido.
    3. Guardar cambios.  
  - _[Insertar captura de `actualizarPrecios.jsp`]_

---

### 7.2 Manual de uso – Rol Logística

**Objetivo:** Supervisar el flujo de inventario, gestionar órdenes de compra y planificar la distribución física de productos.

- **Acceso**
  - Email: `jairo.cuadros@pucp.edu.pe`
  - Contraseña: `logistica123`
  - _[Insertar captura de dashboard logístico tras el login]_

- **Supervisión de movimientos**
  - Ruta: **Logística → Movimientos de inventario**.
  - Flujo:
    1. Filtrar por producto, fecha o tipo de movimiento.
    2. Revisar entradas, salidas y ajustes.
    3. Exportar o generar reportes si es necesario.
  - _[Insertar captura de tabla de movimientos con DataTables]_

- **Gestión de órdenes de compra**
  - Ruta: **Logística → Órdenes de compra**.
  - Flujo:
    1. Crear orden indicando proveedor, producto y cantidad.
    2. Guardar orden (estado inicial: pendiente).
    3. Actualizar estado a Aprobada/Rechazada.
  - _[Insertar captura de formulario de creación y listado de órdenes]_

- **Planificación de transporte**
  - Ruta: **Logística → Planes de transporte**.
  - Flujo:
    1. Seleccionar lote(s) y distrito de entrega.
    2. Asignar conductor y vehículo.
    3. Definir fecha de entrega y guardar el plan.
  - _[Insertar captura de pantalla de gestión de planes de transporte]_

---

### 7.3 Manual de uso – Rol Almacén

**Objetivo:** Controlar inventario físico (entradas, salidas y ajustes), validar carga masiva y reportar incidencias.

- **Acceso**
  - Email: `a20230700@pucp.edu.pe`
  - Contraseña: `almacen123`

- **Registro de entradas**
  - Ruta: **Almacén → Entradas → Registrar entrada**.
  - Flujo:
    1. Seleccionar producto y, si aplica, orden asociada.
    2. Indicar cantidad, lote y fecha de recepción.
    3. Confirmar; el sistema registra la entrada y actualiza stock.
  - _[Insertar captura de `registrarEntrada.jsp`]_

- **Carga masiva desde Excel**
  - Ruta: **Almacén → Carga masiva**.
  - Flujo:
    1. Descargar plantilla Excel configurada por el administrador.
    2. Completar datos respetando el formato de columnas.
    3. Subir archivo y ejecutar validación.
    4. Revisar resultados de validación y confirmar importación.
  - _[Insertar captura de la pantalla de carga y del resultado de validación]_

- **Reporte de incidencias**
  - Ruta: **Almacén → Incidencias → Reportar**.
  - Flujo:
    1. Seleccionar producto/lote.
    2. Elegir tipo de incidencia (Faltante/Sobrante).
    3. Describir causa y guardar.
  - El administrador podrá resolver la incidencia y ajustar stock si corresponde.
  - _[Insertar captura de reporte de incidencia]_

---

### 7.4 Manual de uso – Rol Administrador

**Objetivo:** Gestionar usuarios, roles, parámetros globales del sistema, plantillas Excel, alertas y reportes globales.

- **Acceso**
  - Email: `admin@telito.com`
  - Contraseña: `admin123`
  - _[Insertar captura del dashboard administrativo]_

- **Gestión de usuarios y roles**
  - Ruta: **Administrador → Usuarios**.
  - Flujo:
    1. Listar usuarios con filtros por rol/estado.
    2. Crear nuevos usuarios asignando rol y correo.
    3. Activar, desactivar o banear usuarios.
  - Todas las acciones se registran en la tabla de auditoría.
  - _[Insertar captura de la tabla de usuarios y del formulario de alta]_

- **Configuración de stock mínimo y alertas**
  - Ruta: **Administrador → Configuración → Stock mínimo / Alertas**.
  - Flujo:
    1. Definir stock mínimo por producto.
    2. Configurar tipos de alerta, niveles (INFO/WARNING/CRITICAL) y umbrales.
  - _[Insertar captura de la pantalla de configuración]_

- **Gestión de plantillas Excel**
  - Ruta: **Administrador → Plantillas**.
  - Permite crear, editar y activar/desactivar plantillas para carga masiva.
  - _[Insertar captura de la pantalla de plantillas]_

- **Auditoría del sistema**
  - Ruta: **Administrador → Auditoría**.
  - Permite consultar acciones críticas: logins, cambios de inventario, gestión de usuarios, etc.
  - _[Insertar captura de auditoría con filtros]_

---

### 7.5 Manual de uso – Rol Gerente de tienda

**Objetivo:** Confirmar la recepción de pedidos enviados a la tienda, gestionar recepciones pendientes y revisar el historial de recepciones.

- **Acceso**
  - El rol de Gerente de tienda se autentica igualmente a través de `login.jsp` (con sus credenciales asignadas por el administrador).
  - Tras el login, se redirige al módulo `gerente-tienda/index.jsp`, donde se presenta el menú principal del gerente.
  - _[Insertar captura de `gerente-tienda/index.jsp` con el menú del gerente]_

- **Visualizar recepciones pendientes**
  - Ruta: **Gerente de tienda → Recepciones pendientes** (`gerente-tienda/recepciones-pendientes.jsp`).
  - Flujo:
    1. Revisar la lista de pedidos que han sido despachados desde almacén y están pendientes de confirmación en tienda.
    2. Verificar detalles de cada recepción (productos, cantidades, fechas previstas).
  - _[Insertar captura de `recepciones-pendientes.jsp`]_

- **Confirmar recepción de pedidos**
  - Desde la lista de recepciones pendientes, acceder a la opción de **Confirmar recepción** (`gerente-tienda/confirmar-recepcion.jsp`).
  - Flujo:
    1. Seleccionar la recepción a confirmar.
    2. Validar que los productos y cantidades recibidas coincidan con lo enviado.
    3. Confirmar la recepción; el sistema:
       - Actualiza el estado de la recepción/pedido.
       - Registra la operación para fines de trazabilidad y auditoría.
  - _[Insertar captura de `confirmar-recepcion.jsp`]_

- **Consultar historial de recepciones**
  - Ruta: **Gerente de tienda → Historial de recepciones** (`gerente-tienda/historial-recepciones.jsp`).
  - Flujo:
    1. Filtrar por rango de fechas, estado o identificador de pedido.
    2. Revisar todas las recepciones confirmadas y su detalle.
  - _[Insertar captura de `historial-recepciones.jsp`]_

---

## 8. Cierre y cumplimiento académico

- El sistema **Telito Bodeguero** cumple el **100% de los requerimientos funcionales y no funcionales** definidos en el enunciado académico del curso.
- Se han implementado **funcionalidades adicionales** de valor (auditoría completa, activación y recuperación de cuentas por email, sistema avanzado de alertas, dashboards profesionales, gestión de conductores y vehículos, etc.).
- La arquitectura está diseñada siguiendo buenas prácticas de separación de capas, seguridad y mantenibilidad, y está preparada para ser desplegada en entornos de nube.

> Este documento está pensado como **pieza central de la presentación final**, complementado con:
> - Diagramas de arquitectura (lógicos y de despliegue).
> - Capturas de pantallas clave por rol.
> - Referencias cruzadas a la documentación técnica detallada en `docs/`.


