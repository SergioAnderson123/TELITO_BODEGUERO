# Guion Completo de Presentación – Telito Bodeguero

> **Documento para exposición oral**  
> Duración estimada: 15-20 minutos  
> Formato: Presentación empresarial con demostración en vivo

---

## 🎯 ESTRUCTURA GENERAL DE LA PRESENTACIÓN

1. **Apertura – ¿Quiénes somos?** (2 min)
2. **Usuario objetivo y requisitos** (2 min)
3. **Roles del sistema** (3 min)
4. **Flujo del proyecto** (3 min)
5. **Cualidades del proyecto** (2 min)
6. **Demostración en vivo: Administrador** (4-5 min)
7. **Demostración en vivo: Productor** (2-3 min)
8. **Cierre y preguntas** (1-2 min)

---

## 1. APERTURA – ¿QUIÉNES SOMOS? (2 minutos)

### 1.1 Saludo inicial

> **Buenos días/tardes. Somos Telito Bodeguero**, una empresa de soluciones tecnológicas especializada en la **gestión integral de inventarios para bodegas y pequeños negocios**.

> Nuestro objetivo es **digitalizar y optimizar** los procesos de control de stock, desde la producción hasta la distribución final, eliminando errores manuales y proporcionando visibilidad en tiempo real a todos los actores de la cadena de suministro.

### 1.2 Propuesta de valor

> **Telito Bodeguero** no es solo un software de inventario. Es una **plataforma completa** que conecta a productores, almaceneros, logística y gerentes de tienda en un solo ecosistema, permitiendo:

- **Trazabilidad completa** de cada producto desde su origen hasta su destino
- **Automatización de alertas** para stock mínimo y vencimientos
- **Reportes inteligentes** que facilitan la toma de decisiones
- **Control de acceso por roles** que garantiza la seguridad de la información

### 1.3 Tecnología y arquitectura

> Desarrollamos nuestra plataforma utilizando **Java 17 y Spring Boot**, con una arquitectura multicapa que garantiza escalabilidad y mantenibilidad. La base de datos **MySQL** almacena más de 25 tablas normalizadas, y el sistema está diseñado para desplegarse en **Amazon Web Services**, con un costo operativo mensual de aproximadamente **USD 31**.

---

## 2. USUARIO OBJETIVO Y REQUISITOS (2 minutos)

### 2.1 ¿Para quién es nuestra plataforma?

> **Telito Bodeguero** está diseñado para **bodegas y pequeños negocios** que necesitan:

- Controlar su inventario de forma eficiente sin depender de hojas de cálculo
- Gestionar múltiples proveedores y productores
- Distribuir productos a diferentes tiendas o puntos de venta
- Cumplir con trazabilidad y auditoría para temas fiscales o de calidad
- Reducir pérdidas por vencimientos o stock obsoleto

### 2.2 Requisitos que cumple nuestra plataforma

> Nuestra solución cumple con los **requisitos críticos** que estas empresas necesitan:

**Funcionales:**
- ✅ Gestión completa de productos, lotes y movimientos de inventario
- ✅ Control de acceso por roles (Productor, Logística, Almacén, Administrador, Gerente de tienda)
- ✅ Sistema de alertas automáticas para stock mínimo y vencimientos
- ✅ Carga masiva de datos mediante plantillas Excel configurables
- ✅ Generación de reportes en Excel y por correo electrónico
- ✅ Gestión de distribución geográfica por zonas y distritos (4 zonas, 41 distritos de Lima)

**No funcionales:**
- ✅ Interfaz responsive que funciona en computadoras, tablets y móviles
- ✅ Seguridad robusta con autenticación, autorización y auditoría completa
- ✅ Escalabilidad para crecer con el negocio
- ✅ Disponibilidad 24/7 con infraestructura en la nube

---

## 3. ROLES DEL SISTEMA (3 minutos)

> **Telito Bodeguero** opera con **5 roles principales**, cada uno con funcionalidades específicas diseñadas para su responsabilidad en la cadena de suministro:

### 3.1 Administrador

> El **Administrador** es el dueño del sistema o el responsable de TI. Tiene **visibilidad completa** y control total:

- **Gestión de usuarios**: Crear, editar, activar/desactivar usuarios y asignar roles
- **Configuración del sistema**: Definir stock mínimo, configurar alertas, gestionar plantillas Excel
- **Reportes globales**: Ver inventario consolidado, movimientos por área, planes de transporte
- **Auditoría**: Consultar quién hizo qué y cuándo, para trazabilidad y control interno

> *[Nota: Se mostrará en detalle durante la demostración]*

### 3.2 Productor

> El **Productor** es quien abastece la bodega. Su función es registrar sus productos y lotes:

- **Gestión de productos**: Registrar productos que produce, con SKU, categoría y precio sugerido
- **Registro de lotes**: Ingresar lotes con cantidad, costo de producción y fecha de vencimiento
- **Actualización de precios**: Ajustar precios sugeridos para negociación con logística

> El productor **solo ve sus propios productos**, no el inventario completo. Esto mantiene la confidencialidad comercial.

> *[Nota: Se mostrará en detalle durante la demostración]*

### 3.3 Almacén

> El **Almacenero** controla el inventario físico en la bodega:

- **Entradas**: Registrar productos que llegan al almacén
- **Salidas**: Despachar productos según pedidos
- **Ajustes**: Corregir discrepancias entre el sistema y el inventario físico
- **Carga masiva**: Validar y cargar datos desde archivos Excel
- **Incidencias**: Reportar faltantes o sobrantes para que el administrador los resuelva

### 3.4 Logística

> El usuario de **Logística** supervisa el flujo y planifica la distribución:

- **Supervisión de movimientos**: Ver todas las entradas, salidas y ajustes en tiempo real
- **Órdenes de compra**: Generar órdenes para adquirir productos a productores
- **Planes de transporte**: Asignar conductores y vehículos, definir rutas de distribución por distritos
- **Reportes logísticos**: Exportar reportes de movimientos y distribución

### 3.5 Gerente de Tienda

> El **Gerente de Tienda** confirma la recepción de productos en su punto de venta:

- **Recepciones pendientes**: Ver pedidos que están en camino a su tienda
- **Confirmar recepción**: Validar que los productos recibidos coincidan con lo enviado
- **Historial**: Consultar todas las recepciones confirmadas

> Este rol completa el ciclo: desde que el productor registra un lote hasta que el gerente confirma que llegó a la tienda.

---

## 4. FLUJO DEL PROYECTO (3 minutos)

> Ahora les voy a explicar **cómo funciona el flujo completo** de principio a fin:

### 4.1 Flujo principal: De la producción a la tienda

```
┌─────────────┐
│  PRODUCTOR  │
│             │
│ 1. Registra │
│   producto  │
│             │
│ 2. Crea     │
│   lote con  │
│   costo y   │
│   vencim.   │
└──────┬──────┘
       │
       │ Notificación automática
       ▼
┌─────────────┐
│  ALMACÉN    │
│             │
│ 3. Valida   │
│   y registra│
│   entrada   │
│             │
│ 4. Actualiza│
│   stock     │
└──────┬──────┘
       │
       │ Alerta de stock mínimo
       ▼
┌─────────────┐
│ LOGÍSTICA   │
│             │
│ 5. Crea     │
│   orden de  │
│   compra    │
│             │
│ 6. Planifica│
│   transporte│
│   a distrito│
└──────┬──────┘
       │
       │ Notificación al gerente
       ▼
┌─────────────┐
│ GERENTE     │
│ TIENDA      │
│             │
│ 7. Confirma │
│   recepción │
└─────────────┘
```

### 4.2 Ejemplo práctico del flujo

> **Ejemplo real:**

1. **Productor** registra un nuevo lote de "Arroz Premium" con 1000 unidades, costo S/ 2.50 por unidad, vencimiento 31/12/2025.

2. El sistema **notifica automáticamente** al almacén que hay un nuevo lote pendiente de validación.

3. **Almacén** valida la información y registra la entrada. El stock se actualiza automáticamente.

4. Si el stock baja del mínimo configurado, el sistema **genera una alerta** que llega a Logística y Administrador.

5. **Logística** crea una orden de compra y luego un plan de transporte asignando un conductor y vehículo para llevar el producto al distrito "San Isidro".

6. El sistema **notifica al Gerente de Tienda** de San Isidro que hay un pedido en camino.

7. Cuando el producto llega, el **Gerente de Tienda** confirma la recepción, cerrando el ciclo.

### 4.3 Características del flujo

> Este flujo tiene características importantes:

- **Trazabilidad completa**: Cada movimiento queda registrado con usuario, fecha y hora
- **Notificaciones en tiempo real**: Todos los actores reciben alertas relevantes
- **Control de acceso**: Cada rol solo ve y puede hacer lo que le corresponde
- **Auditoría**: El administrador puede rastrear cualquier acción en el sistema

---

## 5. CUALIDADES DEL PROYECTO (2 minutos)

> Ahora quiero destacar las **cualidades que hacen de Telito Bodeguero una solución profesional y confiable**:

### 5.1 Arquitectura robusta

> Nuestra plataforma utiliza una **arquitectura multicapa** con separación clara de responsabilidades:

- **Capa de Presentación**: JSP con Bootstrap 5 para una interfaz moderna y responsive
- **Capa de Control**: Más de 50 servlets que manejan la lógica de negocio
- **Capa de Acceso a Datos**: 30+ DAOs que gestionan las consultas a la base de datos
- **Base de Datos**: MySQL con 25+ tablas normalizadas

> Esta arquitectura garantiza **mantenibilidad, escalabilidad y seguridad**.

### 5.2 Seguridad empresarial

> Implementamos **múltiples capas de seguridad**:

- Autenticación con hash SHA-256 para contraseñas
- Autorización por roles con filtros que validan permisos en cada request
- Auditoría completa de acciones críticas (logins, cambios de inventario, gestión de usuarios)
- Sistema de tokens para recuperación de contraseña y activación de cuentas

### 5.3 Automatización inteligente

> El sistema **automatiza procesos** que tradicionalmente se hacen manualmente:

- **Alertas automáticas**: Stock mínimo, vencimientos próximos, incidencias
- **Notificaciones por email**: Con templates HTML profesionales y unificados
- **Cálculos automáticos**: Conversión de paquetes a unidades, FIFO para salidas
- **Reportes programados**: Envío automático de reportes por correo

### 5.4 Experiencia de usuario

> Hemos diseñado la interfaz pensando en la **usabilidad**:

- **Dashboards interactivos**: Con gráficos en tiempo real usando Chart.js
- **Tablas avanzadas**: Con filtros, búsqueda y ordenamiento usando DataTables
- **Carga masiva**: Plantillas Excel configurables que facilitan la importación de datos
- **Responsive design**: Funciona perfectamente en móviles y tablets

### 5.5 Costo-beneficio

> **Telito Bodeguero** ofrece un excelente **retorno de inversión**:

- **Costo operativo mensual**: USD 30.95 (infraestructura AWS)
- **Inversión inicial**: S/ 3,500 (desarrollo del MVP)
- **Ahorro estimado**: Reducción de pérdidas por vencimientos, optimización de stock, eliminación de errores manuales

> Para una bodega pequeña, esto se recupera en **menos de 3 meses**.

---

## 6. DEMOSTRACIÓN EN VIVO: ADMINISTRADOR (4-5 minutos)

> Ahora voy a mostrarles la plataforma en funcionamiento, empezando por el rol de **Administrador**, que tiene la vista completa del sistema.

### 6.1 Login y Dashboard

**[Acción: Abrir navegador, ir a login.jsp, ingresar como admin]**

> Ingresamos como **Administrador**. El administrador suele ser el dueño o responsable de TI de la empresa.

**[Acción: Mostrar dashboard/menú principal del administrador]**

> Desde aquí el administrador tiene una **vista 360° del inventario y de los usuarios**. En el dashboard puede ver los indicadores clave: inventario general, productos con más stock, motivos de ajuste, actividad reciente. Esto le permite tomar decisiones rápidas sin entrar a cada módulo.

### 6.2 Gestión de Usuarios

**[Acción: Navegar a "Gestión de Usuarios"]**

> Una de las funciones críticas del administrador es la **gestión de usuarios y roles**.

**[Acción: Mostrar la tabla de usuarios]**

> Aquí puede ver todos los usuarios del sistema, filtrarlos por rol, por estado, y saber cuántos están activos o inactivos.

**[Acción: Hacer clic en "Agregar Usuario" o mostrar el formulario]**

> Desde este formulario puede crear nuevos usuarios, asignarles un rol (Productor, Logística, Almacén, Gerente de tienda, etc.) y definir a qué tienda o distrito pertenecen en el caso del gerente.

> Cada vez que se crea, edita o desactiva un usuario, el sistema registra la acción en la **auditoría**, y puede enviar correos de bienvenida o actualización con un **template corporativo**, para mantener la comunicación formal con el equipo.

**[Acción: Mostrar que el nuevo usuario aparece primero en la tabla]**

> Como pueden ver, cuando creamos un usuario nuevo, aparece automáticamente como el primero en la tabla, facilitando la verificación inmediata.

### 6.3 Configuración de Stock Mínimo y Alertas

**[Acción: Navegar a "Configuración → Stock mínimo"]**

> El administrador también define la **política de stock mínimo y alertas**.

**[Acción: Mostrar la pantalla de stock mínimo]**

> Por ejemplo, aquí podemos configurar cuántas unidades consideramos 'stock crítico' por producto.

**[Acción: Navegar a "Configuración → Alertas"]**

> En el módulo de **Alertas**, definimos qué eventos disparan notificaciones: vencimientos, incidencias, pedidos pendientes, etc., y a qué roles se les notifica. Esto asegura que **Almacén, Logística y Gerente de tienda** reciban avisos en el momento correcto.

### 6.4 Reportes Globales y Auditoría

**[Acción: Navegar a "Reportes Globales"]**

> Finalmente, el administrador tiene acceso a **reportes globales**: inventario consolidado, movimientos por área, planes de transporte, etc., todo exportable a Excel.

**[Acción: Navegar a "Auditoría"]**

> Y en la sección de **Auditoría** puede ver quién inició sesión, quién cambió el stock, quién creó un usuario o una alerta. Esto nos da **trazabilidad completa** y ayuda en temas de control interno.

### 6.5 Cierre del módulo Administrador

> En resumen, el administrador controla **quién entra al sistema, qué puede hacer cada uno, y tiene visibilidad completa de todo lo que pasa en Telito Bodeguero**.

---

## 7. DEMOSTRACIÓN EN VIVO: PRODUCTOR (2-3 minutos)

> Pasando ahora al rol de **Productor**, nuestra plataforma le da una vista clara de **sus productos y lotes**, no del inventario completo.

### 7.1 Inicio Productor y Mis Productos

**[Acción: Cerrar sesión de admin, iniciar sesión como productor]**

> Esto es importante porque cada productor solo ve lo que está bajo su responsabilidad.

**[Acción: Navegar a "Mis Productos"]**

> En **Mis Productos** puede ver su catálogo, actualizar datos y, sobre todo, **registrar nuevos lotes** con costos y fechas de vencimiento.

### 7.2 Registrar Lotes y Precios

**[Acción: Navegar a "Registrar Lotes"]**

> Desde aquí el productor registra un nuevo lote indicando la cantidad, el costo de producción y la fecha de vencimiento.

**[Acción: Mostrar el formulario de registro de lotes]**

> Esto alimenta directamente el inventario de la bodega, manteniendo la **trazabilidad por lote**.

**[Acción: Navegar a "Actualizar Precios"]**

> Además, el productor puede **ajustar sus precios sugeridos**, lo que facilita la negociación con logística y mantiene actualizada la información comercial.

### 7.3 Cierre del módulo Productor

> De esta forma, el productor usa Telito Bodeguero como su **panel de control comercial**, mientras que el administrador y el resto de roles garantizan que ese stock llegue correctamente hasta la tienda.

---

## 8. CIERRE Y PREGUNTAS (1-2 minutos)

### 8.1 Resumen ejecutivo

> Para cerrar, quiero resumir lo que hemos visto:

> **Telito Bodeguero** es una plataforma completa de gestión de inventarios que:

- ✅ Conecta a todos los actores de la cadena de suministro en un solo sistema
- ✅ Automatiza procesos manuales y reduce errores
- ✅ Proporciona trazabilidad completa y auditoría
- ✅ Ofrece una excelente relación costo-beneficio
- ✅ Está diseñada con arquitectura profesional y escalable

### 8.2 Próximos pasos

> Estamos listos para implementar **Telito Bodeguero** en su empresa. Ofrecemos:

- Instalación y configuración inicial
- Capacitación para todos los roles
- Soporte técnico durante los primeros 3 meses
- Actualizaciones y mejoras continuas

### 8.3 Invitación a preguntas

> **¿Tienen alguna pregunta sobre la plataforma, el flujo, los costos o cualquier funcionalidad específica?**

> Estamos aquí para resolver todas sus dudas y mostrarles cómo **Telito Bodeguero** puede transformar la gestión de inventarios de su empresa.

---

## 📝 NOTAS PARA EL PRESENTADOR

### Tiempos sugeridos

- **Apertura**: 2 min (no más de 2.5 min)
- **Usuario objetivo**: 2 min (máximo 2.5 min)
- **Roles**: 3 min (puede extenderse a 4 min si hay preguntas)
- **Flujo**: 3 min (máximo 3.5 min)
- **Cualidades**: 2 min (máximo 2.5 min)
- **Demo Admin**: 4-5 min (esta es tu parte principal)
- **Demo Productor**: 2-3 min (tu parte secundaria)
- **Cierre**: 1-2 min

**Total: 19-24 minutos** (ajustar según tiempo disponible)

### Tips de presentación

1. **Mantén contacto visual** con la audiencia mientras navegas
2. **Explica lo que vas a hacer** antes de hacer clic ("Ahora voy a mostrar...")
3. **Si algo falla**, mantén la calma y explica que es un entorno de demostración
4. **Destaca los beneficios** más que las características técnicas
5. **Usa ejemplos concretos** cuando sea posible
6. **Practica la navegación** antes de la presentación para que sea fluida

### Puntos clave a enfatizar

- ✅ **Trazabilidad completa**: Cada acción queda registrada
- ✅ **Automatización**: El sistema trabaja por sí solo en muchas tareas
- ✅ **Seguridad**: Múltiples capas de protección
- ✅ **Costo-beneficio**: Inversión recuperable en menos de 3 meses
- ✅ **Escalabilidad**: Crece con el negocio

### Preparación técnica

- ✅ Tener la aplicación corriendo y probada antes de la presentación
- ✅ Tener credenciales de prueba listas (admin y productor)
- ✅ Tener datos de ejemplo cargados (productos, lotes, usuarios)
- ✅ Verificar que las notificaciones funcionen
- ✅ Probar la exportación a Excel
- ✅ Tener un navegador limpio sin pestañas innecesarias

---

## 🎯 MENSAJES CLAVE A COMUNICAR

1. **Somos una empresa seria** con una solución profesional
2. **Entendemos el negocio** de bodegas y pequeños negocios
3. **Nuestra plataforma resuelve problemas reales** (vencimientos, stock mínimo, trazabilidad)
4. **Es accesible** en términos de costo
5. **Es fácil de usar** con interfaces intuitivas
6. **Es segura y confiable** con auditoría completa

---

**¡Éxito en tu presentación! 🚀**

