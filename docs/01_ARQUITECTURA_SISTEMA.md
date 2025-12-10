# ARQUITECTURA DEL SISTEMA
## Telito Bodeguero

---

## 1. ARQUITECTURA GENERAL

### 1.1 Arquitectura de Tres Capas (3-Tier)

El sistema Telito Bodeguero sigue una arquitectura de tres capas con separación clara de responsabilidades:

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

### 1.2 Patrón de Diseño MVC

El sistema implementa el patrón **Model-View-Controller**:

- **Model:** Beans (POJOs) que representan entidades del dominio
- **View:** JSPs que renderizan la interfaz de usuario
- **Controller:** Servlets que manejan las peticiones HTTP y coordinan la lógica

---

## 2. STACK TECNOLÓGICO

### 2.1 Backend

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Lenguaje | Java | 17 |
| Framework | Spring Boot | 3.1.5 |
| Servidor Web | Tomcat Embedded | 10.x |
| API Servlets | Jakarta Servlet | 5.0.0 |
| JSP | Jakarta JSP | 3.1.0 |

### 2.2 Base de Datos

| Componente | Tecnología | Versión |
|------------|------------|---------|
| SGBD | MySQL | 8.0+ |
| Driver | MySQL Connector/J | 8.0.33 |

### 2.3 Frontend

| Componente | Tecnología |
|------------|------------|
| HTML | HTML5 |
| CSS | Bootstrap 5 |
| JavaScript | ES6+ |
| Gráficos | Chart.js |

### 2.4 Utilidades

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Excel | Apache POI | 5.2.5 |
| Email | Spring Mail | - |
| JSON | Gson | 2.10.1 |

---

## 3. ESTRUCTURA DEL PROYECTO

### 3.1 Estructura de Paquetes

```
com.example.telito
├── administrador/
│   ├── daos/          # Acceso a datos del módulo admin
│   ├── servlets/       # Controladores del módulo admin
│   └── beans/          # Modelos del módulo admin
├── almacen/
│   ├── daos/
│   ├── servlets/
│   └── beans/
├── logistica/
│   ├── daos/
│   ├── servlets/
│   └── beans/
├── productor/
│   ├── daos/
│   ├── servlets/
│   └── beans/
├── util/               # Utilidades compartidas
│   ├── EmailUtil.java
│   ├── ExcelUtil.java
│   └── AuthorizationHelper.java
└── Application.java    # Clase principal Spring Boot
```

### 3.2 Estructura de Webapp

```
src/main/webapp/
├── administrador/      # Vistas del módulo administrador
├── almacen/           # Vistas del módulo almacén
├── logistica/          # Vistas del módulo logística
├── productor/          # Vistas del módulo productor
├── acceso/             # Páginas de login, activación, recuperación
├── WEB-INF/            # Configuración web
│   ├── web.xml
│   └── lib/            # Librerías JAR
└── index.jsp           # Página principal
```

---

## 4. FLUJO DE DATOS

### 4.1 Flujo de una Petición HTTP

```
1. Usuario realiza petición HTTP
   ↓
2. Servlet recibe la petición
   ↓
3. AuthorizationHelper verifica permisos
   ↓
4. Service ejecuta lógica de negocio
   ↓
5. DAO accede a la base de datos
   ↓
6. ResultSet retorna datos
   ↓
7. Service procesa datos
   ↓
8. Servlet prepara respuesta
   ↓
9. JSP renderiza la vista
   ↓
10. Respuesta HTML enviada al usuario
```

### 4.2 Flujo de Autenticación

```
1. Usuario ingresa credenciales
   ↓
2. LoginServlet valida credenciales
   ↓
3. UsuarioDAO consulta base de datos
   ↓
4. Si válido: crea sesión, redirige a dashboard según rol
   ↓
5. Si inválido: muestra mensaje de error
```

---

## 5. BASE DE DATOS

### 5.1 Modelo de Datos Principal

**Entidades Principales:**
- `usuarios` - Usuarios del sistema
- `roles` - Roles disponibles
- `productos` - Productos del inventario
- `lotes` - Lotes de productos
- `movimientos_inventario` - Historial de movimientos
- `pedidos` - Pedidos realizados
- `ordenes_compra` - Órdenes de compra
- `zonas` - Zonas geográficas
- `distritos` - Distritos por zona
- `ubicaciones` - Ubicaciones físicas
- `alertas_generadas` - Alertas del sistema
- `incidencias_almacen` - Incidencias reportadas

### 5.2 Relaciones Principales

- Zonas (1) → Distritos (N)
- Distritos (1) → Ubicaciones (N)
- Roles (1) → Usuarios (N)
- Usuarios/Productores (1) → Productos (N)
- Productos (1) → Lotes (N)
- Lotes (1) → Movimientos (N)
- Usuarios (1) → Movimientos (N)
- Pedidos (1) → Movimientos (N)

---

## 6. SEGURIDAD

### 6.1 Autenticación
- Login con email y contraseña
- Login con código de productor (solo productores)
- Contraseñas encriptadas (hash)
- Activación de cuenta mediante email
- Recuperación de contraseña mediante email

### 6.2 Autorización
- Verificación de permisos por rol
- Restricción de acceso a funcionalidades
- Validación de sesión en cada petición
- Protección contra acceso no autorizado

### 6.3 Validación
- Validación de inputs del usuario
- Protección contra inyección SQL (PreparedStatements)
- Sanitización de datos de entrada

---

## 7. DESPLIEGUE

### 7.1 Arquitectura de Despliegue

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
│  │         S3 / EBS (Opcional)                      │  │
│  │  - Archivos Excel                                │  │
│  │  - Plantillas                                    │  │
│  │  - Backups                                       │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 7.2 Configuración de Producción

- **Servidor:** EC2 (t2.micro) - Free Tier elegible
- **Base de Datos:** RDS MySQL (db.t2.micro) o MySQL en EC2
- **Almacenamiento:** EBS (20GB incluido en Free Tier) o S3 (opcional)
- **Red:** HTTPS habilitado mediante certificado SSL
- **Seguridad:** Security Groups configurados para acceso restringido

---

## 8. ESCALABILIDAD

### 8.1 Consideraciones Actuales
- Arquitectura preparada para escalado horizontal
- Base de datos con índices optimizados
- Separación de capas permite escalado independiente

### 8.2 Mejoras Futuras
- Implementar caché (Redis)
- Load balancing para múltiples instancias
- Read replicas para base de datos
- CDN para recursos estáticos

---

**Fecha de Generación:** [Fecha]  
**Versión:** 1.0
