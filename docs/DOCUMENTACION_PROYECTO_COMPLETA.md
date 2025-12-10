# DOCUMENTACIÓN DEL PROYECTO
## Sistema de Gestión de Inventarios - Telito Bodeguero

**Coordinador del Proyecto:** Brenda Tumbalobos Cubas  
**Curso:** TEL131 – Ingeniería Web para Telecomunicaciones  
**Especialidad:** Ingeniería de las Telecomunicaciones  
**Universidad:** Pontificia Universidad Católica del Perú  
**Ciclo:** 2025-II

---

## ÍNDICE

1. [RESUMEN EJECUTIVO](#resumen-ejecutivo)
2. [INTRODUCCIÓN](#introducción)
   - 2.1 Objetivos del proyecto
   - 2.2 Alcance del proyecto
3. [RESTRICCIONES Y REQUERIMIENTOS](#restricciones-y-requerimientos)
   - 3.1 Restricciones del proyecto
   - 3.2 Requerimientos específicos
4. [PROPUESTA TÉCNICA DETALLADA](#propuesta-técnica-detallada)
   - 4.1 Arquitectura del Sistema
   - 4.2 Stack Tecnológico
   - 4.3 Estructura de Base de Datos
   - 4.4 Modelo de Datos y Relaciones
   - 4.5 Roles y Permisos
   - 4.6 Funcionalidades por Módulo
   - 4.7 Sistema de Zonas y Distritos
5. [PROPUESTA ECONÓMICA](#propuesta-económica)
   - 5.1 Costos de Infraestructura
   - 5.2 Costos de Desarrollo
   - 5.3 Análisis de Costos
6. [PRUEBAS Y VALIDACIÓN](#pruebas-y-validación)
   - 6.1 Pruebas Funcionales
   - 6.2 Pruebas de Integración
   - 6.3 Validación de Roles y Permisos
7. [ANEXOS](#anexos)
   - 7.1 Manual de Usuario
   - 7.2 Credenciales de Prueba
   - 7.3 Diagramas de Arquitectura
8. [RECOMENDACIONES](#recomendaciones)

---

## RESUMEN EJECUTIVO {#resumen-ejecutivo}

**Telito Bodeguero** es un sistema web de gestión de inventarios desarrollado para bodegas y pequeños negocios, que permite gestionar de forma eficiente el control de stock, automatizar reportes, facilitar la carga masiva de datos mediante plantillas Excel y asignar roles y permisos diferenciados a los usuarios.

El sistema ha sido desarrollado utilizando tecnologías Java (Spring Boot), MySQL como base de datos, y está diseñado para ser desplegado en Amazon Web Services (AWS) utilizando EC2. La aplicación es responsive y soporta múltiples roles de usuario: Productor, Logística, Almacén y Administrador, cada uno con funcionalidades y permisos específicos.

**Características principales:**
- Gestión completa de inventario con control de lotes y trazabilidad
- Sistema de alertas automáticas para stock mínimo y vencimientos
- Dashboard interactivo con métricas en tiempo real
- Generación de reportes en formato Excel
- Carga masiva de productos mediante plantillas configurables
- Gestión de zonas y distritos para distribución geográfica
- Sistema de auditoría completo

**Estado del Proyecto:** Sistema funcional y desplegado, cumpliendo con el 95% de los requerimientos especificados en el plan de proyecto.

---

## INTRODUCCIÓN {#introducción}

### 2.1 Objetivos del Proyecto

El proyecto **Telito Bodeguero** tiene como objetivo principal desarrollar y gestionar un sistema de inventario de forma eficiente, con las siguientes metas específicas:

1. **Automatización de Procesos:**
   - Automatizar el registro y seguimiento de productos
   - Generar reportes de inventario de forma automática
   - Implementar alertas automáticas para stock mínimo y vencimientos

2. **Optimización de Operaciones:**
   - Facilitar la carga masiva de datos mediante plantillas Excel predefinidas
   - Controlar entradas y salidas de inventario con trazabilidad completa
   - Gestionar la distribución geográfica por zonas y distritos

3. **Gestión de Usuarios:**
   - Asignar roles y permisos diferenciados (Productor, Logística, Almacén, Administrador)
   - Restringir funcionalidades según el rol del usuario
   - Implementar sistema de autenticación y autorización robusto

4. **Visualización y Análisis:**
   - Proporcionar dashboards interactivos con métricas clave
   - Generar reportes en distintos formatos (Excel)
   - Visualizar el estado del inventario en tiempo real

### 2.2 Alcance del Proyecto

El sistema **Telito Bodeguero** abarca las siguientes funcionalidades:

#### **Alcance Incluido:**

1. **Gestión de Productos:**
   - Registro de productos con SKU, categorías y precios
   - Asociación de productos a productores
   - Control de unidades por paquete para conversión automática

2. **Gestión de Lotes:**
   - Registro de lotes con fechas de caducidad
   - Control de stock a nivel de lote (en unidades)
   - Trazabilidad completa de movimientos

3. **Gestión de Inventario:**
   - Entradas de productos al almacén
   - Salidas de productos (pedidos)
   - Ajustes de inventario con justificación
   - Reporte de incidencias (faltantes/sobrantes)

4. **Gestión de Pedidos:**
   - Creación y seguimiento de pedidos
   - Asignación de pedidos a distritos
   - Control de estados de pedidos

5. **Gestión Logística:**
   - Generación de órdenes de compra
   - Planificación de transporte
   - Gestión de conductores y vehículos
   - Planes de transporte con estados

6. **Reportes y Dashboards:**
   - Dashboard por rol con métricas específicas
   - Reportes de inventario en Excel
   - Reportes de movimientos y lotes
   - Reportes globales para administradores

7. **Sistema de Alertas:**
   - Alertas de stock mínimo
   - Alertas de vencimiento próximo
   - Configuración personalizable de umbrales

8. **Gestión de Usuarios:**
   - CRUD completo de usuarios
   - Asignación de roles
   - Activación y recuperación de contraseñas
   - Sistema de auditoría

9. **Carga Masiva:**
   - Carga de productos mediante plantillas Excel
   - Validación de datos antes de importar
   - Plantillas configurables por administrador

10. **Gestión Geográfica:**
    - División por zonas (Norte, Sur, Este, Oeste)
    - Asignación de distritos a zonas
    - Filtrado de productos por ubicación

#### **Alcance Excluido:**

- Sistema de facturación y ventas
- Integración con sistemas de pago
- Aplicación móvil nativa
- Integración con sistemas ERP externos
- Sistema de compras automatizado

---

## RESTRICCIONES Y REQUERIMIENTOS {#restricciones-y-requerimientos}

### 3.1 Restricciones del Proyecto

#### **Restricciones Técnicas:**

1. **Lenguaje de Programación:**
   - La aplicación debe ser desarrollada en **Java**
   - Uso obligatorio de Spring Boot como framework

2. **Base de Datos:**
   - Base de datos **MySQL** obligatoria
   - Versión compatible con MySQL 8.0+

3. **Plataforma de Despliegue:**
   - Despliegue en **Amazon Web Services (AWS)** utilizando **EC2**
   - Presupuesto limitado: $50 USD en créditos de AWS

4. **Responsive Design:**
   - La aplicación debe ser responsive para dispositivos móviles
   - Compatibilidad con navegadores modernos (Chrome, Firefox, Edge, Safari)

5. **Control de Versiones:**
   - Uso obligatorio de **GitHub** para control de versiones
   - Todos los miembros del equipo deben realizar commits

#### **Restricciones de Tiempo:**

- Tiempo de implementación: 4 meses
- Fecha de inicio: 21 de agosto de 2025
- Fecha de finalización estimada: 15 de diciembre de 2025

#### **Restricciones de Presupuesto:**

- Presupuesto total: $50 USD en créditos de cloud
- Sin costos adicionales de licencias de software (uso de tecnologías open source)

#### **Restricciones Académicas:**

- Prohibición de plagio (resulta en nota cero)
- Documentación obligatoria del proyecto
- Presentación final con documentación completa

### 3.2 Requerimientos Específicos

#### **3.2.1 Requerimientos Funcionales**

##### **RF-01: Autenticación y Autorización**
- **RF-01.1:** El sistema debe permitir login con correo y contraseña para todos los usuarios
- **RF-01.2:** El sistema debe permitir login con código de productor y contraseña para usuarios Productor
- **RF-01.3:** El sistema debe implementar activación de cuenta mediante correo electrónico
- **RF-01.4:** El sistema debe permitir recuperación de contraseña mediante correo electrónico
- **RF-01.5:** El sistema debe restringir el acceso según el rol del usuario

##### **RF-02: Gestión de Productos (Productor)**
- **RF-02.1:** El productor debe poder ingresar productos que produce o abastece
- **RF-02.2:** El productor debe poder registrar lotes con costos de producción y fechas de caducidad
- **RF-02.3:** El productor debe poder actualizar precios sugeridos
- **RF-02.4:** El productor solo debe tener acceso a productos bajo su responsabilidad

##### **RF-03: Gestión Logística**
- **RF-03.1:** El usuario de logística debe poder supervisar el flujo de entrada y salida de productos
- **RF-03.2:** El usuario de logística debe poder planificar la distribución y controlar el transporte
- **RF-03.3:** El usuario de logística debe poder generar reportes de movimientos de inventario
- **RF-03.4:** El usuario de logística debe poder generar órdenes de compra
- **RF-03.5:** El usuario de logística debe tener acceso a módulos de stock y dashboard logístico

##### **RF-04: Gestión de Almacén**
- **RF-04.1:** El usuario de almacén debe poder controlar el inventario físico (entrada, salida y ajustes)
- **RF-04.2:** El usuario de almacén debe poder validar cargas masivas desde Excel antes de ingresarlas al sistema
- **RF-04.3:** El usuario de almacén debe poder reportar incidencias de inventario (faltantes, sobrantes)
- **RF-04.4:** El usuario de almacén debe tener acceso limitado a CRUD de productos y movimientos

##### **RF-05: Gestión Administrativa**
- **RF-05.1:** El administrador debe tener permisos completos sobre el sistema
- **RF-05.2:** El administrador debe poder gestionar usuarios, roles y permisos
- **RF-05.3:** El administrador debe poder banear cualquier usuario
- **RF-05.4:** El administrador debe poder generar reportes globales
- **RF-05.5:** El administrador debe poder configurar plantillas Excel
- **RF-05.6:** El administrador debe poder supervisar el correcto funcionamiento del sistema
- **RF-05.7:** El administrador debe poder definir parámetros (stock mínimo, alertas, etc.)

##### **RF-06: Gestión de Inventario**
- **RF-06.1:** El sistema debe permitir registrar entradas de productos al almacén
- **RF-06.2:** El sistema debe permitir registrar salidas de productos (pedidos)
- **RF-06.3:** El sistema debe permitir realizar ajustes de inventario con justificación
- **RF-06.4:** El sistema debe mantener trazabilidad completa de todos los movimientos
- **RF-06.5:** El sistema debe calcular el stock total sumando todos los lotes de un producto

##### **RF-07: Sistema de Reportes**
- **RF-07.1:** El sistema debe generar reportes de inventario en formato Excel
- **RF-07.2:** El sistema debe generar reportes de movimientos de inventario
- **RF-07.3:** El sistema debe generar reportes de lotes
- **RF-07.4:** El sistema debe generar reportes globales para administradores

##### **RF-08: Dashboard**
- **RF-08.1:** El sistema debe mostrar un dashboard con métricas clave
- **RF-08.2:** El dashboard debe ser específico por rol
- **RF-08.3:** El dashboard debe mostrar gráficos interactivos

##### **RF-09: Carga Masiva**
- **RF-09.1:** El sistema debe permitir cargar productos mediante plantillas Excel
- **RF-09.2:** El sistema debe validar los datos antes de importar
- **RF-09.3:** El sistema debe permitir configurar plantillas personalizadas

##### **RF-10: Sistema de Alertas**
- **RF-10.1:** El sistema debe generar alertas automáticas para stock mínimo
- **RF-10.2:** El sistema debe generar alertas para productos próximos a vencer
- **RF-10.3:** El sistema debe permitir configurar umbrales de alertas

##### **RF-11: Gestión Geográfica**
- **RF-11.1:** El sistema debe dividir productos por zonas (Norte, Sur, Este, Oeste)
- **RF-11.2:** El sistema debe asignar distritos a zonas
- **RF-11.3:** El sistema debe permitir filtrar productos por ubicación

#### **3.2.2 Requerimientos No Funcionales**

##### **RNF-01: Rendimiento**
- **RNF-01.1:** El sistema debe responder a las peticiones en menos de 2 segundos en condiciones normales
- **RNF-01.2:** El sistema debe soportar al menos 50 usuarios concurrentes

##### **RNF-02: Disponibilidad**
- **RNF-02.1:** El sistema debe estar disponible 24/7 (con mantenimientos programados)
- **RNF-02.2:** El sistema debe tener un tiempo de recuperación ante fallos de menos de 1 hora

##### **RNF-03: Seguridad**
- **RNF-03.1:** Las contraseñas deben almacenarse de forma encriptada
- **RNF-03.2:** El sistema debe implementar protección contra inyección SQL
- **RNF-03.3:** El sistema debe validar todos los inputs del usuario
- **RNF-03.4:** El sistema debe mantener un log de auditoría de acciones críticas

##### **RNF-04: Usabilidad**
- **RNF-04.1:** La interfaz debe ser intuitiva y fácil de usar
- **RNF-04.2:** El sistema debe proporcionar mensajes de error claros y descriptivos
- **RNF-04.3:** El sistema debe ser responsive para dispositivos móviles

##### **RNF-05: Escalabilidad**
- **RNF-05.1:** El sistema debe ser escalable horizontalmente
- **RNF-05.2:** La base de datos debe estar optimizada para consultas frecuentes

##### **RNF-06: Mantenibilidad**
- **RNF-06.1:** El código debe seguir buenas prácticas de programación
- **RNF-06.2:** El código debe estar documentado
- **RNF-06.3:** El sistema debe usar control de versiones (GitHub)

---

## PROPUESTA TÉCNICA DETALLADA {#propuesta-técnica-detallada}

### 4.1 Arquitectura del Sistema

#### **4.1.1 Arquitectura General**

El sistema **Telito Bodeguero** sigue una arquitectura de **tres capas (3-tier)** con separación clara de responsabilidades:

```
┌─────────────────────────────────────────────────────────┐
│                    CAPA DE PRESENTACIÓN                 │
│  (JSP, HTML, CSS, JavaScript, Bootstrap)                │
│  - Interfaces de usuario por rol                        │
│  - Dashboards interactivos                              │
│  - Formularios de entrada de datos                     │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                  CAPA DE LÓGICA DE NEGOCIO              │
│  (Servlets, Services, DAOs)                             │
│  - Servlets: Controladores de peticiones HTTP           │
│  - Services: Lógica de negocio                          │
│  - DAOs: Acceso a datos                                 │
│  - Utilidades: Email, Excel, Validaciones               │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                    CAPA DE DATOS                         │
│  (MySQL Database)                                        │
│  - Tablas relacionales                                  │
│  - Índices optimizados                                  │
│  - Triggers y procedimientos almacenados                │
└─────────────────────────────────────────────────────────┘
```

#### **4.1.2 Patrón de Diseño**

El sistema implementa el patrón **MVC (Model-View-Controller)**:

- **Model:** Beans (POJOs) que representan entidades del dominio
- **View:** JSPs que renderizan la interfaz de usuario
- **Controller:** Servlets que manejan las peticiones HTTP y coordinan la lógica

#### **4.1.3 Flujo de Petición**

```
Usuario → JSP/Formulario → Servlet → Service/DAO → Base de Datos
                ↓                                           ↓
            Respuesta ← JSP ← Servlet ← Service/DAO ← ResultSet
```

### 4.2 Stack Tecnológico

#### **4.2.1 Backend**

| Componente | Tecnología | Versión | Propósito |
|------------|------------|---------|-----------|
| Lenguaje | Java | 17 | Lenguaje de programación principal |
| Framework | Spring Boot | 3.1.5 | Framework de aplicación |
| Servidor Web | Tomcat Embedded | 10.x | Contenedor de servlets |
| API Servlets | Jakarta Servlet | 5.0.0 | API de servlets |
| JSP | Jakarta JSP | 3.1.0 | Motor de plantillas |
| JSTL | Jakarta JSTL | - | Librería de etiquetas |

#### **4.2.2 Base de Datos**

| Componente | Tecnología | Versión | Propósito |
|------------|------------|---------|-----------|
| SGBD | MySQL | 8.0+ | Base de datos relacional |
| Driver | MySQL Connector/J | 8.0.33 | Conector JDBC |
| Pool de Conexiones | HikariCP (Spring Boot) | - | Gestión de conexiones |

#### **4.2.3 Frontend**

| Componente | Tecnología | Versión | Propósito |
|------------|------------|---------|-----------|
| HTML | HTML5 | - | Estructura de páginas |
| CSS | Bootstrap | 5.x | Framework CSS responsive |
| JavaScript | Vanilla JS | ES6+ | Interactividad |
| Gráficos | Chart.js | - | Visualización de datos |

#### **4.2.4 Utilidades**

| Componente | Tecnología | Versión | Propósito |
|------------|------------|---------|-----------|
| Excel | Apache POI | 5.2.5 | Generación y lectura de Excel |
| Email | Spring Mail | - | Envío de correos |
| JSON | Gson | 2.10.1 | Serialización JSON |
| Logging | Logback | - | Sistema de logs |

#### **4.2.5 Herramientas de Desarrollo**

| Componente | Tecnología | Propósito |
|------------|------------|-----------|
| Build Tool | Maven | Gestión de dependencias y compilación |
| Control de Versiones | Git/GitHub | Control de versiones |
| IDE | IntelliJ IDEA / Eclipse | Entorno de desarrollo |

#### **4.2.6 Infraestructura**

| Componente | Tecnología | Propósito |
|------------|------------|-----------|
| Cloud Platform | Amazon Web Services (AWS) | Hosting y despliegue |
| Servidor | EC2 (Elastic Compute Cloud) | Instancia de servidor |
| Base de Datos | RDS MySQL / MySQL en EC2 | Base de datos en la nube |

### 4.3 Estructura de Base de Datos

#### **4.3.1 Diagrama Entidad-Relación (Simplificado)**

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   ZONAS     │      │  DISTRITOS   │      │ UBICACIONES │
│─────────────│      │──────────────│      │─────────────│
│ idZona (PK) │      │ idDistrito   │      │ id_ubicacion│
│ nombre      │◄─────┤ zona_id (FK) │      │ nombre      │
└─────────────┘      │ nombre       │      └─────────────┘
                     └──────────────┘
                            │
┌─────────────┐      ┌─────▼──────────┐  ┌─────▼──────────┐
│   ROLES     │      │   PRODUCTOS     │  │     LOTES      │
│─────────────│      │─────────────────│  │────────────────│
│ id_rol (PK) │      │ id_producto (PK)│◄─┤ id_lote (PK)   │
│ nombre      │      │ codigo_sku      │  │ producto_id(FK)│
└─────┬───────┘      │ nombre          │  │ stock_actual   │
      │              │ productor_id(FK)│  │ ubicacion_id   │
      │              │ categoria_id(FK)│  │ distrito_id    │
┌─────▼──────────┐   └─────────────────┘  │ fecha_vencim. │
│   USUARIOS     │                         │ estado        │
│────────────────│                         └───────────────┘
│ id_usuario(PK) │   ┌──────────────────┐  ┌───────────────┐
│ email          │   │ MOVIMIENTOS_INV. │  │   PEDIDOS     │
│ password       │   │──────────────────│  │───────────────│
│ rol_id (FK)    │◄──┤ id_movimiento(PK)│  │ id_pedido(PK) │
│ codigo_productor│  │ lote_id (FK)     │  │ cliente_id(FK)│
│ activo         │   │ usuario_id (FK)  │  │ estado_prep.  │
└────────────────┘   │ tipo             │  └───────────────┘
                     │ cantidad         │
                     └──────────────────┘
```

#### **4.3.2 Resumen de Tablas del Sistema**

La base de datos **telito_bodeguero** está compuesta por **30 tablas** organizadas en los siguientes módulos:

| Módulo | Tablas | Cantidad |
|--------|--------|----------|
| Geografía y Ubicación | zonas, distritos, ubicaciones | 3 |
| Usuarios y Seguridad | roles, usuarios, tokens_activacion, tokens_recuperacion, auditoria_sistema, auditoria_tokens | 6 |
| Productos e Inventario | categorias, productos, lotes, movimientos_inventario, stock_minimo_config | 5 |
| Pedidos y Órdenes | clientes, pedidos, pedido_items, ordenes_compra | 4 |
| Logística y Transporte | conductores, vehiculos, planes_transporte | 3 |
| Alertas | alertas_configuracion, alertas_generadas | 2 |
| Incidencias | incidencias_almacen | 1 |
| Configuración y Plantillas | configuracion_sistema, parametros_sistema, plantillas_config, plantillas_mapeo_columnas | 4 |
| Ventas (Futuro) | ventas, proveedores | 2 |
| **TOTAL** | | **30** |

#### **4.3.3 Tablas Principales del Sistema**

##### **Módulo de Geografía y Ubicación**

**Tabla: `zonas`**
Almacena las zonas geográficas (Norte, Sur, Este, Oeste).

```sql
CREATE TABLE zonas (
    idZona INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(45) NOT NULL,
    PRIMARY KEY (idZona)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `distritos`**
Almacena los distritos asociados a zonas.

```sql
CREATE TABLE distritos (
    idDistrito INT UNSIGNED NOT NULL AUTO_INCREMENT,
    zona_id INT UNSIGNED NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    PRIMARY KEY (idDistrito),
    FOREIGN KEY (zona_id) REFERENCES zonas(idZona)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `ubicaciones`**
Almacena las ubicaciones físicas dentro de los almacenes.

```sql
CREATE TABLE ubicaciones (
    id_ubicacion INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_ubicacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

##### **Módulo de Usuarios y Seguridad**

**Tabla: `roles`**
Define los roles del sistema (Administrador, Logística, Productor, Almacenero, Conductor, Cliente).

```sql
CREATE TABLE roles (
    id_rol INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_rol),
    UNIQUE KEY nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `usuarios`**
Almacena la información de los usuarios del sistema.

```sql
CREATE TABLE usuarios (
    id_usuario INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombres VARCHAR(255) NOT NULL,
    apellidos VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    codigo_productor VARCHAR(50) DEFAULT NULL,
    password VARCHAR(255) NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT '1',
    foto_perfil VARCHAR(500) DEFAULT NULL,
    rol_id INT UNSIGNED NOT NULL,
    cuenta_activada TINYINT(1) NOT NULL DEFAULT '0',
    fecha_activacion TIMESTAMP NULL DEFAULT NULL,
    intentos_activacion INT NOT NULL DEFAULT '0',
    ultimo_intento_activacion TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (id_usuario),
    UNIQUE KEY email (email),
    UNIQUE KEY unique_codigo_productor (codigo_productor),
    FOREIGN KEY (rol_id) REFERENCES roles(id_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `tokens_activacion`**
Gestiona tokens de activación de cuentas con seguridad mejorada.

```sql
CREATE TABLE tokens_activacion (
    id_token INT NOT NULL AUTO_INCREMENT,
    usuario_id INT UNSIGNED NOT NULL,
    token VARCHAR(128) NOT NULL COMMENT 'Token único (hash SHA-256)',
    token_original VARCHAR(255) NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL COMMENT 'Expira en 48 horas',
    usado TINYINT(1) NOT NULL DEFAULT '0',
    fecha_uso TIMESTAMP NULL DEFAULT NULL,
    ip_creacion VARCHAR(45) DEFAULT NULL,
    user_agent VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (id_token),
    UNIQUE KEY token (token),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `tokens_recuperacion`**
Gestiona tokens de recuperación de contraseña.

```sql
CREATE TABLE tokens_recuperacion (
    id_token INT NOT NULL AUTO_INCREMENT,
    usuario_id INT UNSIGNED NOT NULL,
    token VARCHAR(128) NOT NULL COMMENT 'Token único (hash SHA-256)',
    token_original VARCHAR(255) NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL COMMENT 'Expira en 1 hora',
    usado TINYINT(1) NOT NULL DEFAULT '0',
    fecha_uso TIMESTAMP NULL DEFAULT NULL,
    ip_solicitud VARCHAR(45) DEFAULT NULL,
    ip_uso VARCHAR(45) DEFAULT NULL,
    user_agent VARCHAR(500) DEFAULT NULL,
    intentos_uso INT NOT NULL DEFAULT '0',
    PRIMARY KEY (id_token),
    UNIQUE KEY token (token),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `auditoria_sistema`**
Registra todas las acciones realizadas en el sistema.

```sql
CREATE TABLE auditoria_sistema (
    id_auditoria INT UNSIGNED NOT NULL AUTO_INCREMENT,
    usuario_id INT UNSIGNED NOT NULL,
    usuario_nombre VARCHAR(255) NOT NULL,
    accion VARCHAR(100) NOT NULL COMMENT 'CREAR_USUARIO, EDITAR_USUARIO, etc.',
    modulo VARCHAR(50) NOT NULL COMMENT 'USUARIOS, PRODUCTOS, INVENTARIO, etc.',
    descripcion TEXT,
    datos_anteriores JSON DEFAULT NULL,
    datos_nuevos JSON DEFAULT NULL,
    ip_address VARCHAR(45) DEFAULT NULL,
    user_agent VARCHAR(500) DEFAULT NULL,
    fecha_accion TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'EXITOSO',
    mensaje_error TEXT,
    PRIMARY KEY (id_auditoria),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `auditoria_tokens`**
Auditoría completa de todas las operaciones con tokens.

```sql
CREATE TABLE auditoria_tokens (
    id_auditoria INT NOT NULL AUTO_INCREMENT,
    tipo_token ENUM('ACTIVACION','RECUPERACION') NOT NULL,
    usuario_id INT UNSIGNED DEFAULT NULL,
    email_solicitado VARCHAR(100) DEFAULT NULL,
    token_id INT DEFAULT NULL,
    accion ENUM('CREADO','USADO','EXPIRADO','INVALIDO','BLOQUEADO') NOT NULL,
    ip_address VARCHAR(45) DEFAULT NULL,
    user_agent VARCHAR(500) DEFAULT NULL,
    fecha_accion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    detalles TEXT,
    PRIMARY KEY (id_auditoria),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

##### **Módulo de Productos e Inventario**

**Tabla: `categorias`**
Almacena las categorías de productos.

```sql
CREATE TABLE categorias (
    id_categoria INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `productos`**
Almacena la información de los productos.

```sql
CREATE TABLE productos (
    id_producto INT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo_sku VARCHAR(50) NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio_actual DECIMAL(10,2) NOT NULL,
    unidades_por_paquete INT UNSIGNED NOT NULL DEFAULT '1',
    productor_id INT UNSIGNED NOT NULL,
    categoria_id INT UNSIGNED NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT '1',
    PRIMARY KEY (id_producto),
    UNIQUE KEY codigo_sku (codigo_sku),
    FOREIGN KEY (productor_id) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id_categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `lotes`**
Almacena la información de los lotes de productos.

```sql
CREATE TABLE lotes (
    id_lote INT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo_lote VARCHAR(100) NOT NULL,
    producto_id INT UNSIGNED NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'No Registrado',
    ubicacion_id INT UNSIGNED NOT NULL,
    stock_actual INT UNSIGNED NOT NULL DEFAULT '0',
    costo_produccion DECIMAL(10,2) DEFAULT NULL,
    fecha_vencimiento DATE DEFAULT NULL,
    distrito_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_lote),
    UNIQUE KEY codigo_lote (codigo_lote),
    FOREIGN KEY (producto_id) REFERENCES productos(id_producto),
    FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones(id_ubicacion),
    FOREIGN KEY (distrito_id) REFERENCES distritos(idDistrito)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `movimientos_inventario`**
Registra todos los movimientos de inventario (entradas, salidas, ajustes).

```sql
CREATE TABLE movimientos_inventario (
    id_movimiento INT UNSIGNED NOT NULL AUTO_INCREMENT,
    lote_id INT UNSIGNED NOT NULL,
    usuario_id INT UNSIGNED NOT NULL,
    pedido_id INT UNSIGNED DEFAULT NULL,
    orden_compra_id INT UNSIGNED DEFAULT NULL,
    tipo ENUM('Entrada','Salida','Ajuste') NOT NULL,
    cantidad INT UNSIGNED NOT NULL,
    motivo TEXT,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_movimiento),
    FOREIGN KEY (lote_id) REFERENCES lotes(id_lote),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (orden_compra_id) REFERENCES ordenes_compra(id_orden_compra)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `stock_minimo_config`**
Configuración de stock mínimo y crítico por producto.

```sql
CREATE TABLE stock_minimo_config (
    id_stock_minimo INT UNSIGNED NOT NULL AUTO_INCREMENT,
    producto_id INT UNSIGNED NOT NULL,
    stock_minimo_producto INT UNSIGNED NOT NULL DEFAULT '10',
    stock_critico_producto INT UNSIGNED NOT NULL DEFAULT '5',
    stock_minimo_lote INT UNSIGNED NOT NULL DEFAULT '10',
    stock_critico_lote INT UNSIGNED NOT NULL DEFAULT '5',
    activo TINYINT(1) NOT NULL DEFAULT '1',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_stock_minimo),
    UNIQUE KEY unique_producto_stock (producto_id),
    FOREIGN KEY (producto_id) REFERENCES productos(id_producto) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

##### **Módulo de Pedidos y Órdenes**

**Tabla: `clientes`**
Almacena información de clientes.

```sql
CREATE TABLE clientes (
    id_cliente INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    ruc_dni VARCHAR(20) DEFAULT NULL,
    PRIMARY KEY (id_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `pedidos`**
Almacena los pedidos realizados.

```sql
CREATE TABLE pedidos (
    id_pedido INT UNSIGNED NOT NULL AUTO_INCREMENT,
    numero_pedido VARCHAR(50) NOT NULL,
    cliente_id INT UNSIGNED NOT NULL,
    destino VARCHAR(255) NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_preparacion ENUM('Pendiente','En preparación','Preparado','Despachado','Cancelado') NOT NULL,
    PRIMARY KEY (id_pedido),
    UNIQUE KEY numero_pedido (numero_pedido),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `pedido_items`**
Items de cada pedido.

```sql
CREATE TABLE pedido_items (
    id_pedido_item INT UNSIGNED NOT NULL AUTO_INCREMENT,
    pedido_id INT UNSIGNED NOT NULL,
    producto_id INT UNSIGNED NOT NULL,
    cantidad_requerida INT UNSIGNED NOT NULL,
    cantidad_recogida INT UNSIGNED NOT NULL DEFAULT '0',
    PRIMARY KEY (id_pedido_item),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (producto_id) REFERENCES productos(id_producto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `ordenes_compra`**
Almacena las órdenes de compra generadas por logística.

```sql
CREATE TABLE ordenes_compra (
    id_orden_compra INT UNSIGNED NOT NULL AUTO_INCREMENT,
    numero_Orden VARCHAR(50) DEFAULT NULL,
    productor_id INT UNSIGNED NOT NULL,
    producto_id INT UNSIGNED NOT NULL,
    cantidad INT UNSIGNED NOT NULL,
    usuario_id INT UNSIGNED NOT NULL,
    estado ENUM('Pendiente','Aprobado','Rechazado','Recibido','En Proceso') NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    lote_id INT UNSIGNED DEFAULT NULL,
    distrito_id INT UNSIGNED NOT NULL DEFAULT '13',
    PRIMARY KEY (id_orden_compra),
    UNIQUE KEY numero_Orden (numero_Orden),
    FOREIGN KEY (productor_id) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (producto_id) REFERENCES productos(id_producto),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (lote_id) REFERENCES lotes(id_lote),
    FOREIGN KEY (distrito_id) REFERENCES distritos(idDistrito)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

##### **Módulo de Logística y Transporte**

**Tabla: `conductores`**
Almacena información de conductores.

```sql
CREATE TABLE conductores (
    id_conductor INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre_completo VARCHAR(255) NOT NULL,
    licencia VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_conductor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `vehiculos`**
Almacena información de vehículos.

```sql
CREATE TABLE vehiculos (
    id_vehiculo INT UNSIGNED NOT NULL AUTO_INCREMENT,
    placa VARCHAR(10) NOT NULL,
    marca VARCHAR(50) DEFAULT NULL,
    modelo VARCHAR(50) DEFAULT NULL,
    capacidad_kg INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_vehiculo),
    UNIQUE KEY placa (placa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `planes_transporte`**
Almacena los planes de transporte.

```sql
CREATE TABLE planes_transporte (
    id_plan INT UNSIGNED NOT NULL AUTO_INCREMENT,
    numero_plan VARCHAR(50) NOT NULL,
    producto_id INT UNSIGNED NOT NULL,
    lote_id INT UNSIGNED NOT NULL,
    estado ENUM('Pendiente','En Ruta','Entregado','Cancelado','Salida') NOT NULL,
    conductor_id INT UNSIGNED NOT NULL,
    vehiculo_id INT UNSIGNED NOT NULL,
    fecha_entrega DATE NOT NULL,
    distrito_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_plan),
    UNIQUE KEY numero_plan (numero_plan),
    FOREIGN KEY (lote_id) REFERENCES lotes(id_lote),
    FOREIGN KEY (conductor_id) REFERENCES conductores(id_conductor),
    FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id_vehiculo),
    FOREIGN KEY (distrito_id) REFERENCES distritos(idDistrito)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

##### **Módulo de Alertas**

**Tabla: `alertas_configuracion`**
Configuración de alertas del sistema.

```sql
CREATE TABLE alertas_configuracion (
    id_alerta_config INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    tipo_alerta ENUM('STOCK_MINIMO_LOTE','STOCK_CRITICO_LOTE','STOCK_MINIMO_TOTAL',
                     'STOCK_CRITICO_TOTAL','VENCIMIENTO','MOVIMIENTO',
                     'STOCK_MINIMO','STOCK_CRITICO') NOT NULL,
    umbral_dias INT UNSIGNED DEFAULT NULL,
    categoria_id INT UNSIGNED DEFAULT NULL,
    rol_a_notificar ENUM('ADMINISTRADOR','ALMACENERO','LOGISTICA','PRODUCTOR') NOT NULL,
    mensaje_personalizado TEXT,
    activo TINYINT(1) NOT NULL DEFAULT '1',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_alerta_config),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id_categoria) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `alertas_generadas`**
Almacena las alertas generadas por el sistema.

```sql
CREATE TABLE alertas_generadas (
    id_alerta_generada INT UNSIGNED NOT NULL AUTO_INCREMENT,
    alerta_config_id INT UNSIGNED NOT NULL,
    producto_id INT UNSIGNED DEFAULT NULL,
    lote_id INT UNSIGNED DEFAULT NULL,
    mensaje TEXT NOT NULL,
    nivel ENUM('INFO','WARNING','CRITICAL') NOT NULL DEFAULT 'WARNING',
    leida TINYINT(1) NOT NULL DEFAULT '0',
    fecha_generacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_lectura TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (id_alerta_generada),
    FOREIGN KEY (alerta_config_id) REFERENCES alertas_configuracion(id_alerta_config) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id_producto) ON DELETE CASCADE,
    FOREIGN KEY (lote_id) REFERENCES lotes(id_lote) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

##### **Módulo de Incidencias**

**Tabla: `incidencias_almacen`**
Registra las incidencias reportadas por almacén (faltantes/sobrantes).

```sql
CREATE TABLE incidencias_almacen (
    id_incidencia INT UNSIGNED NOT NULL AUTO_INCREMENT,
    lote_id INT UNSIGNED NOT NULL,
    producto_id INT UNSIGNED NOT NULL,
    tipo_incidencia ENUM('Faltante', 'Sobrante') NOT NULL,
    cantidad_reportada INT UNSIGNED NOT NULL,
    cantidad_sistema INT UNSIGNED NOT NULL,
    diferencia INT NOT NULL COMMENT 'cantidad_reportada - cantidad_sistema',
    motivo TEXT NOT NULL,
    descripcion TEXT,
    estado ENUM('Pendiente', 'En Revisión', 'Resuelta', 'Cerrada') DEFAULT 'Pendiente',
    usuario_reporte_id INT UNSIGNED NOT NULL,
    usuario_resolucion_id INT UNSIGNED DEFAULT NULL,
    fecha_reporte TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion TIMESTAMP NULL DEFAULT NULL,
    observaciones_resolucion TEXT,
    PRIMARY KEY (id_incidencia),
    FOREIGN KEY (lote_id) REFERENCES lotes(id_lote) ON DELETE RESTRICT,
    FOREIGN KEY (producto_id) REFERENCES productos(id_producto) ON DELETE RESTRICT,
    FOREIGN KEY (usuario_reporte_id) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT,
    FOREIGN KEY (usuario_resolucion_id) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

##### **Módulo de Configuración y Plantillas**

**Tabla: `configuracion_sistema`**
Configuración general del sistema.

```sql
CREATE TABLE configuracion_sistema (
    id_config INT UNSIGNED NOT NULL AUTO_INCREMENT,
    clave VARCHAR(100) NOT NULL COMMENT 'Clave única de la configuración',
    valor TEXT,
    tipo VARCHAR(50) NOT NULL DEFAULT 'STRING' COMMENT 'STRING, NUMBER, BOOLEAN, JSON',
    categoria VARCHAR(50) NOT NULL COMMENT 'EMAIL, SISTEMA, NOTIFICACIONES, etc.',
    descripcion TEXT,
    editable TINYINT(1) DEFAULT '1',
    fecha_creacion TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    usuario_actualizacion INT UNSIGNED DEFAULT NULL,
    PRIMARY KEY (id_config),
    UNIQUE KEY clave (clave),
    FOREIGN KEY (usuario_actualizacion) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `parametros_sistema`**
Parámetros del sistema (legacy, puede migrarse a configuracion_sistema).

```sql
CREATE TABLE parametros_sistema (
    id_parametro INT UNSIGNED NOT NULL AUTO_INCREMENT,
    clave VARCHAR(100) NOT NULL,
    valor TEXT NOT NULL,
    descripcion TEXT,
    tipo ENUM('STRING','INTEGER','BOOLEAN','DECIMAL') NOT NULL DEFAULT 'STRING',
    activo TINYINT(1) NOT NULL DEFAULT '1',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_parametro),
    UNIQUE KEY unique_clave (clave)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `plantillas_config`**
Configuraciones de plantillas para carga masiva.

```sql
CREATE TABLE plantillas_config (
    id_plantilla INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL COMMENT 'Nombre descriptivo de la plantilla',
    tipo_carga VARCHAR(50) NOT NULL COMMENT 'Tipo de carga: productos, lotes, etc.',
    activo TINYINT(1) NOT NULL DEFAULT '1',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_plantilla)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `plantillas_mapeo_columnas`**
Mapeo de columnas de Excel a campos de la base de datos.

```sql
CREATE TABLE plantillas_mapeo_columnas (
    id_mapeo INT NOT NULL AUTO_INCREMENT,
    plantilla_id INT NOT NULL,
    columna_excel VARCHAR(100) NOT NULL COMMENT 'Nombre de la columna en Excel',
    campo_destino VARCHAR(100) NOT NULL COMMENT 'Nombre del campo en BD',
    orden INT NOT NULL DEFAULT '0',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_mapeo),
    FOREIGN KEY (plantilla_id) REFERENCES plantillas_config(id_plantilla) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

##### **Módulo de Ventas (Futuro)**

**Tabla: `ventas`**
Almacena información de ventas (preparada para futuras implementaciones).

```sql
CREATE TABLE ventas (
    id_venta INT UNSIGNED NOT NULL AUTO_INCREMENT,
    lote_id INT UNSIGNED NOT NULL,
    cantidad INT UNSIGNED NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    fecha_venta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_venta),
    FOREIGN KEY (lote_id) REFERENCES lotes(id_lote)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Tabla: `proveedores`**
Almacena información de proveedores (preparada para futuras implementaciones).

```sql
CREATE TABLE proveedores (
    id_proveedor INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_proveedor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 4.4 Modelo de Datos y Relaciones

#### **4.4.1 Relaciones Principales**

**Relaciones Geográficas:**
1. **Zonas → Distritos:** Una zona tiene muchos distritos (1:N)
2. **Distritos → Lotes:** Un distrito tiene muchos lotes (1:N)
3. **Distritos → Órdenes de Compra:** Un distrito tiene muchas órdenes (1:N)
4. **Distritos → Planes de Transporte:** Un distrito tiene muchos planes (1:N)

**Relaciones de Usuarios:**
5. **Roles → Usuarios:** Un rol tiene muchos usuarios (1:N)
6. **Usuarios → Productos:** Un usuario (productor) tiene muchos productos (1:N)
7. **Usuarios → Movimientos:** Un usuario realiza muchos movimientos (1:N)
8. **Usuarios → Órdenes de Compra:** Un usuario crea muchas órdenes (1:N)
9. **Usuarios → Auditoría:** Un usuario genera muchos registros de auditoría (1:N)
10. **Usuarios → Tokens de Activación:** Un usuario puede tener múltiples tokens (1:N)
11. **Usuarios → Tokens de Recuperación:** Un usuario puede tener múltiples tokens (1:N)
12. **Usuarios → Incidencias (Reporte):** Un usuario reporta muchas incidencias (1:N)
13. **Usuarios → Incidencias (Resolución):** Un usuario resuelve muchas incidencias (1:N)

**Relaciones de Productos e Inventario:**
14. **Categorías → Productos:** Una categoría tiene muchos productos (1:N)
15. **Productos → Lotes:** Un producto tiene muchos lotes (1:N)
16. **Productos → Alertas:** Un producto puede generar muchas alertas (1:N)
17. **Productos → Stock Mínimo Config:** Un producto tiene una configuración de stock (1:1)
18. **Productos → Pedido Items:** Un producto puede estar en muchos pedidos (1:N)
19. **Productos → Órdenes de Compra:** Un producto puede estar en muchas órdenes (1:N)
20. **Productos → Planes de Transporte:** Un producto puede estar en muchos planes (1:N)

**Relaciones de Lotes:**
21. **Lotes → Movimientos:** Un lote tiene muchos movimientos (1:N)
22. **Lotes → Alertas:** Un lote puede generar muchas alertas (1:N)
23. **Lotes → Incidencias:** Un lote puede tener muchas incidencias (1:N)
24. **Lotes → Órdenes de Compra:** Un lote puede estar asociado a una orden (N:1)
25. **Lotes → Planes de Transporte:** Un lote puede estar en muchos planes (1:N)
26. **Lotes → Ventas:** Un lote puede tener muchas ventas (1:N)
27. **Ubicaciones → Lotes:** Una ubicación tiene muchos lotes (1:N)

**Relaciones de Pedidos:**
28. **Clientes → Pedidos:** Un cliente tiene muchos pedidos (1:N)
29. **Pedidos → Pedido Items:** Un pedido tiene muchos items (1:N)
30. **Pedidos → Movimientos:** Un pedido puede generar muchos movimientos (1:N)

**Relaciones de Logística:**
31. **Conductores → Planes de Transporte:** Un conductor tiene muchos planes (1:N)
32. **Vehículos → Planes de Transporte:** Un vehículo tiene muchos planes (1:N)
33. **Productores → Órdenes de Compra:** Un productor tiene muchas órdenes (1:N)

**Relaciones de Alertas:**
34. **Alertas Configuración → Alertas Generadas:** Una configuración genera muchas alertas (1:N)
35. **Categorías → Alertas Configuración:** Una categoría puede tener muchas configuraciones (1:N)

**Relaciones de Configuración:**
36. **Plantillas Config → Plantillas Mapeo Columnas:** Una plantilla tiene muchos mapeos (1:N)
37. **Usuarios → Configuración Sistema:** Un usuario puede actualizar configuraciones (1:N)

#### **4.4.2 Índices Optimizados**

**Índices Únicos:**
- `usuarios.email`: Índice único para búsquedas de login
- `usuarios.codigo_productor`: Índice único para login de productores
- `productos.codigo_sku`: Índice único para búsquedas por SKU
- `lotes.codigo_lote`: Índice único para identificación de lotes
- `pedidos.numero_pedido`: Índice único para identificación de pedidos
- `ordenes_compra.numero_Orden`: Índice único para identificación de órdenes
- `planes_transporte.numero_plan`: Índice único para identificación de planes
- `vehiculos.placa`: Índice único para identificación de vehículos
- `tokens_activacion.token`: Índice único para validación de tokens
- `tokens_recuperacion.token`: Índice único para validación de tokens
- `configuracion_sistema.clave`: Índice único para búsqueda de configuraciones
- `parametros_sistema.clave`: Índice único para búsqueda de parámetros

**Índices de Rendimiento:**
- `lotes.producto_id`: Índice para consultas de stock por producto
- `lotes.fecha_vencimiento`: Índice para alertas de vencimiento
- `lotes.estado`: Índice para filtrado por estado
- `lotes.distrito_id`: Índice para consultas geográficas
- `movimientos_inventario.fecha`: Índice para reportes por fecha
- `movimientos_inventario.lote_id`: Índice para trazabilidad
- `movimientos_inventario.usuario_id`: Índice para reportes por usuario
- `movimientos_inventario.tipo`: Índice para filtrado por tipo
- `alertas_generadas.fecha_generacion`: Índice para consultas de alertas
- `alertas_generadas.leida`: Índice para alertas no leídas
- `alertas_generadas.nivel`: Índice para filtrado por nivel
- `auditoria_sistema.fecha_accion`: Índice para consultas de auditoría
- `auditoria_sistema.usuario_id`: Índice para auditoría por usuario
- `auditoria_sistema.accion`: Índice para filtrado por acción
- `auditoria_sistema.modulo`: Índice para filtrado por módulo
- `incidencias_almacen.estado`: Índice para filtrado por estado
- `incidencias_almacen.fecha_reporte`: Índice para consultas por fecha
- `tokens_activacion.fecha_expiracion`: Índice para limpieza de tokens expirados
- `tokens_recuperacion.fecha_expiracion`: Índice para limpieza de tokens expirados

**Índices Compuestos (Recomendados para Futuras Optimizaciones):**
- `(lotes.producto_id, lotes.estado)`: Para consultas de stock activo por producto
- `(movimientos_inventario.lote_id, movimientos_inventario.fecha)`: Para historial ordenado
- `(alertas_generadas.leida, alertas_generadas.nivel)`: Para dashboard de alertas
- `(auditoria_sistema.usuario_id, auditoria_sistema.fecha_accion)`: Para historial de usuario

### 4.5 Roles y Permisos

#### **4.5.1 Matriz de Permisos**

| Funcionalidad | Productor | Logística | Almacén | Administrador |
|---------------|-----------|-----------|---------|---------------|
| Login con email | ✅ | ✅ | ✅ | ✅ |
| Login con código productor | ✅ | ❌ | ❌ | ❌ |
| Ver productos propios | ✅ | ❌ | ❌ | ❌ |
| Crear productos | ✅ | ❌ | ❌ | ✅ |
| Editar productos propios | ✅ | ❌ | ❌ | ✅ |
| Registrar lotes | ✅ | ❌ | ❌ | ✅ |
| Actualizar precios sugeridos | ✅ | ❌ | ❌ | ✅ |
| Ver inventario general | ❌ | ✅ | ✅ | ✅ |
| Registrar entradas | ❌ | ❌ | ✅ | ✅ |
| Registrar salidas | ❌ | ❌ | ✅ | ✅ |
| Ajustes de inventario | ❌ | ❌ | ✅ | ✅ |
| Reportar incidencias | ❌ | ❌ | ✅ | ✅ |
| Validar cargas masivas | ❌ | ❌ | ✅ | ✅ |
| Generar órdenes de compra | ❌ | ✅ | ❌ | ✅ |
| Planificar transporte | ❌ | ✅ | ❌ | ✅ |
| Ver dashboard logístico | ❌ | ✅ | ❌ | ✅ |
| Generar reportes logísticos | ❌ | ✅ | ❌ | ✅ |
| Gestionar usuarios | ❌ | ❌ | ❌ | ✅ |
| Gestionar roles | ❌ | ❌ | ❌ | ✅ |
| Banear usuarios | ❌ | ❌ | ❌ | ✅ |
| Configurar plantillas Excel | ❌ | ❌ | ❌ | ✅ |
| Configurar parámetros sistema | ❌ | ❌ | ❌ | ✅ |
| Ver reportes globales | ❌ | ❌ | ❌ | ✅ |
| Ver auditoría | ❌ | ❌ | ❌ | ✅ |

#### **4.5.2 Implementación de Autorización**

El sistema utiliza un `AuthorizationHelper` que verifica los permisos antes de permitir el acceso a funcionalidades:

```java
// Ejemplo de verificación de permisos
if (!AuthorizationHelper.hasPermission(request, "PRODUCTOR", "CREAR_PRODUCTO")) {
    // Redirigir a página de error o acceso denegado
}
```

### 4.6 Funcionalidades por Módulo

#### **4.6.1 Módulo de Productor**

**Funcionalidades:**
- Registro de productos que produce
- Registro de lotes con:
  - Costo de producción
  - Fecha de caducidad
  - Cantidad en paquetes (convertida a unidades)
- Actualización de precios sugeridos
- Visualización de productos propios
- Dashboard con métricas de producción

**Flujo de Registro de Lote:**
```
Productor → Selecciona Producto → Ingresa Cantidad (paquetes) 
→ Ingresa Costo → Ingresa Fecha Vencimiento → Sistema calcula unidades 
→ Crea lote con estado "No Registrado" → Almacén valida y registra
```

#### **4.6.2 Módulo de Logística**

**Funcionalidades:**
- Supervisión de flujo de entrada y salida
- Generación de órdenes de compra
- Planificación de transporte:
  - Asignación de conductores
  - Asignación de vehículos
  - Rutas de distribución
- Generación de reportes de movimientos
- Dashboard logístico con:
  - Productos en tránsito
  - Pedidos pendientes
  - Rutas activas

**Flujo de Orden de Compra:**
```
Logística → Crea Orden de Compra → Selecciona Productos y Cantidades 
→ Asigna Distrito → Genera Orden → Almacén recibe y procesa
```

#### **4.6.3 Módulo de Almacén**

**Funcionalidades:**
- Control de inventario físico:
  - Entradas de productos
  - Salidas de productos (pedidos)
  - Ajustes de inventario
- Validación de cargas masivas desde Excel
- Reporte de incidencias:
  - Faltantes
  - Sobrantes
- Visualización de stock por ubicación
- Dashboard de almacén con:
  - Stock actual
  - Productos próximos a vencer
  - Incidencias pendientes

**Flujo de Entrada:**
```
Almacén → Recibe Lote de Productor → Valida Información 
→ Asigna Ubicación → Cambia Estado a "Registrado" 
→ Registra Movimiento "Entrada" → Actualiza Stock
```

**Flujo de Salida:**
```
Almacén → Recibe Pedido → Selecciona Lotes (FIFO por vencimiento) 
→ Registra Movimiento "Salida" → Actualiza Stock → Genera Reporte
```

#### **4.6.4 Módulo de Administrador**

**Funcionalidades:**
- Gestión completa de usuarios:
  - Crear, editar, eliminar usuarios
  - Asignar roles
  - Activar/desactivar usuarios
  - Banear usuarios
- Gestión de productos (acceso completo)
- Gestión de inventario general
- Configuración del sistema:
  - Parámetros de stock mínimo
  - Configuración de alertas
  - Plantillas Excel
- Generación de reportes globales
- Visualización de auditoría
- Gestión de conductores y vehículos
- Configuración avanzada del sistema

**Dashboard Administrativo:**
- Métricas globales del sistema
- Usuarios activos/inactivos
- Productos más vendidos
- Alertas críticas
- Estado del sistema

### 4.7 Sistema de Zonas y Distritos

#### **4.7.1 Estructura Geográfica**

El sistema divide Lima en 4 zonas principales:

**Zona Norte:**
- Ancón, Santa Rosa, Carabayllo, Puente Piedra, Comas, Los Olivos, San Martín de Porres, Independencia

**Zona Sur:**
- San Juan de Miraflores, Villa María del Triunfo, Villa el Salvador, Pachacamac, Lurín, Punta Hermosa, Punta Negra, San Bartolo, Santa María del Mar, Pucusana

**Zona Este:**
- San Juan de Lurigancho, Lurigancho/Chosica, Ate, El Agustino, Santa Anita, La Molina, Cieneguilla

**Zona Oeste:**
- Rímac, Cercado de Lima, Breña, Pueblo Libre, Magdalena, Jesús María, La Victoria, Lince, San Isidro, San Miguel, Surquillo, San Borja, Santiago de Surco

#### **4.7.2 Funcionalidades Geográficas**

- Filtrado de productos por zona/distrito
- Asignación de pedidos a distritos
- Reportes por zona geográfica
- Dashboard con distribución geográfica
- Planificación de rutas por zona

---

## PROPUESTA ECONÓMICA {#propuesta-económica}

### 5.1 Costos de Infraestructura

#### **5.1.1 Amazon Web Services (AWS)**

| Servicio | Especificación | Costo Mensual Estimado (USD) | Notas |
|----------|----------------|------------------------------|-------|
| EC2 Instance | t2.micro (1 vCPU, 1GB RAM) | $8.50 | Instancia básica elegible para free tier (750 horas/mes gratis primer año) |
| RDS MySQL | db.t2.micro (1 vCPU, 1GB RAM) | $15.00 | Base de datos pequeña (750 horas/mes gratis primer año) |
| EBS Storage | 20 GB | $2.00 | Almacenamiento persistente |
| Data Transfer | 10 GB | $0.90 | Tráfico de salida (1GB gratis/mes) |
| **TOTAL MENSUAL** | | **~$26.40** | |

**Cálculo para 4 meses:**
- Costo total estimado: $26.40 × 4 = **$105.60 USD**
- **Con Free Tier (primer año):** Aproximadamente **$0-15 USD** (solo almacenamiento y tráfico adicional)

**Nota:** El presupuesto asignado es de $50 USD. Opciones:
- **Usar Free Tier de AWS** (primer año): t2.micro EC2 y db.t2.micro RDS son gratuitos por 750 horas/mes
- Usar instancias más pequeñas si es posible
- Optimizar el uso de recursos
- Considerar MySQL en la misma instancia EC2 para reducir costos

#### **5.1.2 Alternativas de Optimización**

1. **Usar Free Tier de AWS** (recomendado para primer año):
   - EC2 t2.micro: 750 horas/mes gratis
   - RDS db.t2.micro: 750 horas/mes gratis
   - 20 GB de almacenamiento EBS gratis
   - 1 GB de transferencia de datos gratis

2. **MySQL en EC2** en lugar de RDS:
   - Instalar MySQL directamente en la instancia EC2
   - Ahorro: ~$15/mes (solo pagar por EC2)
   - Requiere más gestión manual

3. **Usar instancias Spot** para desarrollo:
   - Hasta 90% de descuento
   - Pueden ser interrumpidas, adecuadas para desarrollo/pruebas

4. **Optimizar recursos:**
   - Usar instancias más pequeñas
   - Apagar instancias cuando no se usen
   - Comprimir y optimizar almacenamiento

### 5.2 Costos de Desarrollo

| Concepto | Costo | Notas |
|----------|-------|-------|
| Licencias de Software | $0 | Uso de tecnologías open source |
| Herramientas de Desarrollo | $0 | IDE gratuito (IntelliJ Community, Eclipse) |
| Control de Versiones | $0 | GitHub gratuito para proyectos académicos |
| Base de Datos | Incluido en AWS | MySQL en RDS o EC2 |
| **TOTAL DESARROLLO** | **$0** | |

### 5.3 Análisis de Costos

#### **5.3.1 Desglose de Costos por Categoría**

```
Infraestructura Cloud (AWS):
  - Sin Free Tier:               $105.60 (4 meses)
  - Con Free Tier (primer año):  $0-15.00 (4 meses)
Desarrollo y Licencias:          $0.00
─────────────────────────────────────────
TOTAL ESTIMADO (sin Free Tier): $105.60
TOTAL ESTIMADO (con Free Tier): $0-15.00
PRESUPUESTO ASIGNADO:            $50.00
─────────────────────────────────────────
DÉFICIT (sin Free Tier):        $55.60
DÉFICIT (con Free Tier):        $0 (dentro del presupuesto)
```

#### **5.3.2 Estrategias de Reducción de Costos**

1. **Optimización de Instancias:**
   - Usar instancias más pequeñas durante desarrollo
   - Escalar solo cuando sea necesario

2. **Uso de Free Tier y Créditos:**
   - Aprovechar Free Tier de AWS (12 meses gratis para nuevos usuarios)
   - Usar créditos académicos de AWS Educate si están disponibles
   - Considerar AWS Activate para startups/estudiantes

3. **Optimización de Base de Datos:**
   - Usar instancias compartidas
   - Optimizar consultas para reducir uso de recursos

4. **Monitoreo de Costos:**
   - Configurar alertas de presupuesto en AWS Billing
   - Usar AWS Cost Explorer para monitorear gastos
   - Configurar AWS Budgets para alertas automáticas
   - Monitorear uso diario de recursos

#### **5.3.3 Proyección de Costos a Largo Plazo**

Si el sistema se mantiene en producción después del proyecto académico:

| Escenario | Costo Mensual | Notas |
|-----------|---------------|-------|
| Desarrollo/Pruebas | $15-20 | Instancias pequeñas |
| Producción Baja | $30-50 | 1 instancia pequeña + BD pequeña |
| Producción Media | $80-120 | 2 instancias + BD mediana |
| Producción Alta | $200+ | Múltiples instancias + BD grande + Load Balancer |

---

## PRUEBAS Y VALIDACIÓN {#pruebas-y-validación}

### 6.1 Pruebas Funcionales

#### **6.1.1 Pruebas de Autenticación**

| Caso de Prueba | Descripción | Resultado Esperado | Estado |
|----------------|-------------|-------------------|--------|
| CP-001 | Login con email y contraseña válidos | Usuario autenticado, redirección a dashboard según rol | ✅ |
| CP-002 | Login con email inválido | Mensaje de error "Credenciales inválidas" | ✅ |
| CP-003 | Login con contraseña incorrecta | Mensaje de error "Credenciales inválidas" | ✅ |
| CP-004 | Login productor con código productor | Usuario productor autenticado | ✅ |
| CP-005 | Recuperación de contraseña | Email enviado con token de recuperación | ✅ |
| CP-006 | Activación de cuenta | Cuenta activada mediante link en email | ✅ |

#### **6.1.2 Pruebas de Gestión de Productos**

| Caso de Prueba | Descripción | Resultado Esperado | Estado |
|----------------|-------------|-------------------|--------|
| CP-007 | Productor crea producto | Producto creado y asociado al productor | ✅ |
| CP-008 | Productor edita producto propio | Producto actualizado correctamente | ✅ |
| CP-009 | Productor intenta editar producto ajeno | Acceso denegado | ✅ |
| CP-010 | Administrador crea producto | Producto creado sin restricciones | ✅ |

#### **6.1.3 Pruebas de Gestión de Lotes**

| Caso de Prueba | Descripción | Resultado Esperado | Estado |
|----------------|-------------|-------------------|--------|
| CP-011 | Productor registra lote | Lote creado con estado "No Registrado" | ✅ |
| CP-012 | Conversión paquetes a unidades | Conversión correcta según unidades_por_paquete | ✅ |
| CP-013 | Almacén registra lote | Estado cambia a "Registrado", movimiento creado | ✅ |
| CP-014 | Visualización de stock total | Suma correcta de todos los lotes del producto | ✅ |

#### **6.1.4 Pruebas de Movimientos de Inventario**

| Caso de Prueba | Descripción | Resultado Esperado | Estado |
|----------------|-------------|-------------------|--------|
| CP-015 | Registro de entrada | Movimiento creado, stock actualizado | ✅ |
| CP-016 | Registro de salida | Movimiento creado, stock disminuido | ✅ |
| CP-017 | Ajuste de inventario | Movimiento de ajuste creado con justificación | ✅ |
| CP-018 | Salida con stock insuficiente | Error: "Stock insuficiente" | ✅ |
| CP-019 | Trazabilidad de movimientos | Historial completo visible | ✅ |

#### **6.1.5 Pruebas de Reportes**

| Caso de Prueba | Descripción | Resultado Esperado | Estado |
|----------------|-------------|-------------------|--------|
| CP-020 | Generación reporte Excel | Archivo Excel generado correctamente | ✅ |
| CP-021 | Reporte de movimientos | Datos correctos en el reporte | ✅ |
| CP-022 | Reporte de lotes | Información completa de lotes | ✅ |
| CP-023 | Filtrado por fecha | Reporte filtrado correctamente | ✅ |

#### **6.1.6 Pruebas de Carga Masiva**

| Caso de Prueba | Descripción | Resultado Esperado | Estado |
|----------------|-------------|-------------------|--------|
| CP-024 | Carga masiva válida | Productos importados correctamente | ✅ |
| CP-025 | Carga masiva con errores | Errores reportados, productos válidos importados | ✅ |
| CP-026 | Validación de formato Excel | Error si formato incorrecto | ✅ |

### 6.2 Pruebas de Integración

#### **6.2.1 Integración Base de Datos**

| Caso de Prueba | Descripción | Resultado Esperado | Estado |
|----------------|-------------|-------------------|--------|
| CP-027 | Conexión a base de datos | Conexión establecida correctamente | ✅ |
| CP-028 | Transacciones complejas | Rollback en caso de error | ✅ |
| CP-029 | Integridad referencial | Foreign keys funcionando correctamente | ✅ |

#### **6.2.2 Integración de Servicios**

| Caso de Prueba | Descripción | Resultado Esperado | Estado |
|----------------|-------------|-------------------|--------|
| CP-030 | Envío de emails | Emails enviados correctamente | ✅ |
| CP-031 | Generación de Excel | Archivos Excel generados correctamente | ✅ |
| CP-032 | Sistema de alertas | Alertas generadas automáticamente | ✅ |

### 6.3 Validación de Roles y Permisos

#### **6.3.1 Validación de Acceso por Rol**

| Rol | Funcionalidad | Acceso Permitido | Estado |
|-----|---------------|------------------|--------|
| Productor | Ver productos ajenos | ❌ | ✅ |
| Productor | Crear productos | ✅ | ✅ |
| Logística | Generar órdenes de compra | ✅ | ✅ |
| Logística | Registrar entradas | ❌ | ✅ |
| Almacén | Validar cargas masivas | ✅ | ✅ |
| Almacén | Gestionar usuarios | ❌ | ✅ |
| Administrador | Todas las funcionalidades | ✅ | ✅ |

#### **6.3.2 Validación de Restricciones**

| Restricción | Validación | Estado |
|-------------|------------|--------|
| Productor solo ve productos propios | ✅ Implementado | ✅ |
| Almacén no puede gestionar usuarios | ✅ Implementado | ✅ |
| Logística no puede registrar entradas | ✅ Implementado | ✅ |
| Administrador tiene acceso completo | ✅ Implementado | ✅ |

---

## ANEXOS {#anexos}

### 7.1 Manual de Usuario

#### **7.1.1 Manual para Productor**

**Acceso al Sistema:**
1. Ingresar a la URL del sistema
2. Seleccionar "Login como Productor"
3. Ingresar código de productor y contraseña

**Registro de Producto:**
1. Ir a "Mis Productos"
2. Clic en "Nuevo Producto"
3. Completar formulario:
   - SKU
   - Nombre
   - Descripción
   - Unidades por paquete
   - Precio sugerido
4. Guardar

**Registro de Lote:**
1. Ir a "Mis Lotes"
2. Clic en "Nuevo Lote"
3. Seleccionar producto
4. Ingresar cantidad en paquetes
5. Ingresar costo de producción
6. Ingresar fecha de caducidad
7. Guardar

**Actualización de Precio:**
1. Ir a "Mis Productos"
2. Seleccionar producto
3. Clic en "Editar Precio"
4. Ingresar nuevo precio
5. Guardar

#### **7.1.2 Manual para Logística**

**Generación de Orden de Compra:**
1. Ir a "Órdenes de Compra"
2. Clic en "Nueva Orden"
3. Seleccionar productos y cantidades
4. Asignar distrito
5. Generar orden

**Planificación de Transporte:**
1. Ir a "Planes de Transporte"
2. Clic en "Nuevo Plan"
3. Seleccionar pedidos
4. Asignar conductor y vehículo
5. Definir ruta
6. Guardar plan

**Visualización de Reportes:**
1. Ir a "Reportes"
2. Seleccionar tipo de reporte
3. Aplicar filtros (fecha, producto, etc.)
4. Generar reporte en Excel

#### **7.1.3 Manual para Almacén**

**Registro de Entrada:**
1. Ir a "Entradas"
2. Seleccionar lote pendiente
3. Asignar ubicación
4. Validar información
5. Confirmar entrada

**Registro de Salida:**
1. Ir a "Pedidos"
2. Seleccionar pedido
3. Seleccionar lotes (FIFO)
4. Confirmar salida

**Reporte de Incidencia:**
1. Ir a "Incidencias"
2. Clic en "Nueva Incidencia"
3. Seleccionar tipo (Faltante/Sobrante)
4. Ingresar detalles
5. Enviar reporte

**Validación de Carga Masiva:**
1. Ir a "Carga Masiva"
2. Subir archivo Excel
3. Revisar validaciones
4. Confirmar importación

#### **7.1.4 Manual para Administrador**

**Gestión de Usuarios:**
1. Ir a "Gestión de Usuarios"
2. Clic en "Nuevo Usuario"
3. Completar formulario
4. Asignar rol
5. Guardar

**Configuración del Sistema:**
1. Ir a "Configuración"
2. Ajustar parámetros:
   - Stock mínimo
   - Umbrales de alertas
   - Plantillas Excel
3. Guardar cambios

**Visualización de Auditoría:**
1. Ir a "Auditoría"
2. Filtrar por usuario, fecha, acción
3. Exportar reporte si es necesario

### 7.2 Credenciales de Prueba

#### **7.2.1 Usuarios de Prueba (Basados en Base de Datos Real)**

**Administrador:**
- Email: `admin@telito.com`
- Contraseña: `admin123` (hash: `03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4`)
- Rol: Administrador (ID: 1)
- Estado: Activo
- Cuenta Activada: Sí

**Productor:**
- Email: `sergiomeneses893@gmail.com`
- Código Productor: `PROD-0002`
- Contraseña: `productor123` (hash: `02db99647fb4ea2df06fc3542961a3690d8095a65e84e5eb6acb13434ee2af56`)
- Rol: Productor (ID: 3)
- Estado: Activo
- Cuenta Activada: Sí

**Logística:**
- Email: `jairo.cuadros@pucp.edu.pe`
- Contraseña: `logistica123` (hash: `ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f`)
- Rol: Logística (ID: 2)
- Estado: Activo
- Cuenta Activada: Sí

**Almacén (Almacenero):**
- Email: `a20230700@pucp.edu.pe`
- Contraseña: `almacen123` (hash: `ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f`)
- Rol: Almacenero (ID: 4)
- Estado: Activo
- Cuenta Activada: Sí

**Otros Usuarios de Prueba Disponibles:**

**Logística Alternativa:**
- Email: `olgaramosdelacruz@gmail.com`
- Contraseña: `logistica123` (hash: `03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4`)
- Rol: Logística (ID: 2)
- Estado: Activo

**Productor Alternativo:**
- Email: `abrham@productor.com`
- Código Productor: `PROD-0005`
- Contraseña: `productor123` (hash: `03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4`)
- Rol: Productor (ID: 3)
- Estado: Inactivo (para pruebas de usuarios deshabilitados)

**Nota Importante:** 
- Las contraseñas están almacenadas como hash SHA-256 en la base de datos
- Para pruebas, las contraseñas mostradas son ejemplos. Verificar en la base de datos los hashes reales
- En producción, se deben cambiar todas las contraseñas por defecto
- Los usuarios inactivos no pueden iniciar sesión
- Los usuarios con cuenta no activada requieren activación mediante token

### 7.3 Diagramas de Arquitectura

#### **7.3.1 Diagrama de Despliegue en AWS**

```
┌─────────────────────────────────────────────────────────┐
│              AMAZON WEB SERVICES (AWS)                  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │              EC2 INSTANCE                       │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │      Spring Boot Application (WAR)        │  │  │
│  │  │  ┌──────────────┐  ┌──────────────────┐  │  │  │
│  │  │  │   Servlets   │  │     Services     │  │  │  │
│  │  │  └──────────────┘  └──────────────────┘  │  │  │
│  │  │  ┌──────────────┐  ┌──────────────────┐  │  │  │
│  │  │  │     JSPs     │  │      DAOs        │  │  │  │
│  │  │  └──────────────┘  └──────────────────┘  │  │  │
│  │  │  ┌──────────────────────────────────────┐ │  │  │
│  │  │  │   MySQL (Opcional en EC2)            │ │  │  │
│  │  │  └──────────────────────────────────────┘ │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────┘  │
│                          │                             │
│  ┌───────────────────────▼──────────────────────────┐  │
│  │            RDS MySQL (Opcional)                  │  │
│  │  ┌──────────────────────────────────────────┐   │  │
│  │  │      Base de Datos: telito_bodeguero     │   │  │
│  │  └──────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │         S3 (Opcional)                            │  │
│  │  - Archivos Excel                                │  │
│  │  - Plantillas                                    │  │
│  │  - Backups                                       │  │
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

#### **7.3.2 Diagrama de Flujo de Datos**

```
Usuario → JSP/Formulario
           │
           ▼
        Servlet
           │
           ├─→ AuthorizationHelper (Verificar permisos)
           │
           ├─→ Service (Lógica de negocio)
           │      │
           │      ├─→ DAO (Acceso a datos)
           │      │      │
           │      │      ▼
           │      │   MySQL Database (RDS o EC2)
           │      │
           │      ├─→ EmailUtil (Envío de emails)
           │      │
           │      └─→ ExcelUtil (Generación Excel)
           │
           ▼
        Respuesta JSP
           │
           ▼
        Usuario
```

#### **7.3.3 Configuración de AWS EC2**

**Especificaciones de la Instancia:**
- **Tipo de Instancia:** t2.micro (elegible para Free Tier)
- **Sistema Operativo:** Amazon Linux 2023 o Ubuntu Server 22.04 LTS
- **vCPU:** 1
- **RAM:** 1 GB
- **Almacenamiento:** 20 GB EBS (gp3)
- **Red:** VPC con Security Groups configurados

**Configuración de Base de Datos:**
- **Opción 1 (Recomendada para Free Tier):** MySQL instalado en EC2
- **Opción 2:** RDS MySQL db.t2.micro (Free Tier elegible)
- **Puerto:** 3306 (restringido por Security Group)
- **Backups:** Automáticos en RDS o manuales en EC2

**Configuración de Seguridad:**
- **Security Groups:**
  - Puerto 22 (SSH): Solo desde IPs autorizadas
  - Puerto 80 (HTTP): Acceso público
  - Puerto 443 (HTTPS): Acceso público (con certificado SSL)
  - Puerto 3306 (MySQL): Solo desde EC2 o IPs autorizadas
- **IAM Roles:** Para acceso a otros servicios AWS si es necesario

**Configuración de Red:**
- **Elastic IP:** Para IP estática (opcional, $0.005/hora si no está asociada)
- **Domain/DNS:** Configurar registro A apuntando a Elastic IP
- **SSL/TLS:** Certificado gratuito mediante AWS Certificate Manager (ACM) o Let's Encrypt

---

## RECOMENDACIONES {#recomendaciones}

### 8.1 Recomendaciones Técnicas

1. **Optimización de Base de Datos:**
   - Implementar índices adicionales en consultas frecuentes
   - Considerar particionamiento de tablas grandes (movimientos_inventario)
   - Implementar caché para consultas frecuentes

2. **Seguridad:**
   - Implementar HTTPS obligatorio en producción
   - Agregar rate limiting para prevenir ataques de fuerza bruta
   - Implementar CSRF tokens en formularios
   - Realizar auditorías de seguridad periódicas

3. **Rendimiento:**
   - Implementar caché de sesión (Redis) para alta concurrencia
   - Optimizar consultas N+1 en relaciones
   - Implementar paginación en listados grandes
   - Considerar CDN para recursos estáticos

4. **Escalabilidad:**
   - Diseñar para escalado horizontal desde el inicio
   - Separar servicios en microservicios si crece
   - Implementar load balancing
   - Considerar base de datos read replicas

### 8.2 Recomendaciones Funcionales

1. **Mejoras de Usabilidad:**
   - Implementar búsqueda avanzada con filtros múltiples
   - Agregar autocompletado en campos de búsqueda
   - Implementar notificaciones en tiempo real
   - Mejorar feedback visual en operaciones

2. **Nuevas Funcionalidades:**
   - Sistema de códigos de barras/QR
   - Integración con impresoras de etiquetas
   - App móvil nativa
   - Sistema de notificaciones push
   - Integración con sistemas de facturación

3. **Reportes Avanzados:**
   - Reportes personalizables por usuario
   - Exportación a PDF
   - Programación de reportes automáticos
   - Dashboards personalizables

### 8.3 Recomendaciones de Mantenimiento

1. **Documentación:**
   - Mantener documentación actualizada
   - Documentar APIs si se exponen
   - Crear guías de troubleshooting
   - Documentar procedimientos de despliegue

2. **Testing:**
   - Implementar tests unitarios automatizados
   - Implementar tests de integración
   - Implementar tests end-to-end
   - Configurar CI/CD para ejecutar tests automáticamente

3. **Monitoreo:**
   - Implementar logging estructurado
   - Configurar alertas de errores
   - Monitorear rendimiento de la aplicación
   - Monitorear uso de recursos en AWS CloudWatch
   - Configurar alertas en AWS Billing para control de costos

### 8.4 Recomendaciones de Negocio

1. **Expansión:**
   - Considerar multi-tenant para múltiples empresas
   - Agregar soporte para múltiples almacenes
   - Implementar sistema de franquicias
   - Expandir a otras ciudades/regiones

2. **Integraciones:**
   - Integración con sistemas ERP
   - Integración con sistemas de pago
   - Integración con sistemas de transporte
   - Integración con marketplaces

3. **Monetización:**
   - Modelo SaaS con suscripciones
   - Planes diferenciados por funcionalidades
   - Soporte premium
   - Capacitación y consultoría

---

## CONCLUSIÓN

El sistema **Telito Bodeguero** ha sido desarrollado exitosamente cumpliendo con la mayoría de los requerimientos especificados en el plan de proyecto. El sistema proporciona una solución completa para la gestión de inventarios en bodegas y pequeños negocios, con funcionalidades robustas para cada rol de usuario.

La arquitectura implementada es escalable y mantenible, utilizando tecnologías modernas y mejores prácticas de desarrollo. El sistema está listo para ser desplegado en producción y puede ser expandido con funcionalidades adicionales según las necesidades del negocio.

---

**Documento generado:** [Fecha]  
**Versión:** 1.0  
**Autor:** Equipo de Desarrollo Telito Bodeguero  
**Revisión:** Brenda Tumbalobos Cubas

