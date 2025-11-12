# Guía de Actualización de JIRA - Telito Bodeguero

## 📋 Resumen Ejecutivo

Esta guía te ayudará a actualizar el JIRA con todas las funcionalidades implementadas en las últimas 3 semanas. El documento está organizado por roles y tareas específicas del JIRA.

---

## 🎯 Tareas a Actualizar por ID



### ✅ TBD-218: Terminar CRUD de Ordenes de compra
**Estado:** TERMINADO ✅  
**Rol:** Logística  
**Fecha de Actualización:** [Fecha actual]

**Descripción de lo implementado:**
- CRUD completo de órdenes de compra
- Listado con paginación y filtros (búsqueda, proveedor, estado)
- Crear nueva orden de compra
- Editar orden de compra existente
- Estados: Pendiente, Aprobado, Rechazado, Recibido, En Proceso
- Integración con distritos (distrito_id)
- Relación corregida: productor_id (antes proveedor_id) apunta a usuarios

**Evidencias a subir:**
- Capturas de la lista de órdenes de compra con filtros
- Capturas del formulario de creación
- Capturas del formulario de edición
- Capturas de los diferentes estados
- Capturas de la paginación funcionando

**Comentarios para JIRA:**
```
✅ CRUD de Órdenes de Compra completado al 100%

Funcionalidades:
- ✅ Listar órdenes con paginación (10 por página)
- ✅ Filtros: búsqueda por producto/ID, filtro por proveedor, filtro por estado
- ✅ Crear nueva orden de compra
- ✅ Editar orden de compra existente
- ✅ Estados implementados: Pendiente, Aprobado, Rechazado, Recibido, En Proceso
- ✅ Integración con distritos (distrito_id)
- ✅ Relación corregida: productor_id apunta a usuarios (productores)

Archivos principales:
- src/main/java/com/example/telito/logistica/servlets/OrdenCompraServlet.java
- src/main/java/com/example/telito/logistica/daos/OrdenCompraDao.java
- src/main/webapp/logistica/OrdenLista/purchase-order.jsp
- actualizar_ordenes_compra.sql
- add_distrito_id_to_ordenes_compra.sql
- agregar_estado_en_proceso.sql

Cambios en BD:
- Columna proveedor_id → productor_id
- Nueva columna distrito_id
- Estado "En Proceso" agregado al ENUM
```

---

### ✅ TBD-210: Crear una nueva rama en Git para el Login
**Estado:** TERMINADO ✅  
**Rol:** Todos  
**Fecha de Actualización:** [Fecha actual]

**Comentarios para JIRA:**
```
✅ Rama de Git creada y mergeada para el Login

Branch: [nombre de la rama]
- Implementación completa del sistema de login
- Merge realizado a main/develop
- Código revisado y probado
```

---

### ✅ TBD-211: Verificar base de datos de Productor y almacen
**Estado:** TERMINADO ✅  
**Rol:** Todos  
**Fecha de Actualización:** [Fecha actual]

**Comentarios para JIRA:**
```
✅ Base de datos verificada para Productor y Almacén

Verificaciones realizadas:
- ✅ Relaciones de tablas correctas
- ✅ Foreign keys funcionando
- ✅ Datos de prueba insertados
- ✅ Consultas optimizadas
- ✅ Integridad referencial verificada

Scripts de actualización ejecutados:
- agregar_foto_perfil.sql
- agregar_stock_lote_columnas.sql
- agregar_estado_salida_planes_transporte.sql
- add_distrito_id_to_ordenes_compra.sql
- agregar_estado_en_proceso.sql
- actualizar_tipos_alerta.sql
- actualizar_ordenes_compra.sql
```

---

### ✅ TBD-215: Corregir estilo sidebar
**Estado:** TERMINADO ✅  
**Rol:** Todos  
**Fecha de Actualización:** [Fecha actual]

**Comentarios para JIRA:**
```
✅ Estilos del sidebar corregidos en todos los módulos

Correcciones realizadas:
- Sidebar responsive funcionando correctamente
- Menús activos destacados
- Iconos alineados correctamente
- Transiciones suaves
- Estilos consistentes entre módulos
```

---

### ✅ TBD-216: Crear Inicio (selector de botones)
**Estado:** TERMINADO ✅  
**Rol:** Administrador  
**Fecha de Actualización:** [Fecha actual]

**Descripción de lo implementado:**
- Página de inicio (index.jsp) que redirige al login
- Selector de roles en acceso-roles.jsp para Administrador
- Accesos rápidos desde el menú principal del Administrador
- Dashboard con estadísticas generales

**Evidencias a subir:**
- Capturas de la página de inicio
- Capturas del selector de roles
- Capturas del dashboard del administrador

**Comentarios para JIRA:**
```
✅ Página de inicio y selector de roles implementado

Funcionalidades:
- Página index.jsp que redirige al login
- Selector de roles en acceso-roles.jsp (Administrador puede acceder a otros roles)
- Dashboard con estadísticas:
  * Total de usuarios
  * Usuarios baneados
  * Alertas abiertas
- Accesos rápidos a funcionalidades principales

Archivos:
- src/main/webapp/index.jsp
- src/main/webapp/administrador/acceso-roles.jsp
- src/main/webapp/administrador/menu-principal.jsp
```

---

## 📊 Tareas por Rol - Funcionalidades al 100%

### 🔵 TBD-196 / TBD-212: Funcionalidad 100%: Logistica
**Estado:** EN DESARROLLO → TERMINADO ✅  
**Rol:** Logística  
**Fecha de Actualización:** [Fecha actual]

**Funcionalidades implementadas:**

1. **Gestión de Inventario**
   - Consulta de inventario
   - Filtros por producto, tipo, período
   - Paginación de resultados

2. **Movimiento de Productos**
   - Registro de movimientos de entrada/salida
   - Historial de movimientos
   - Filtros y búsqueda

3. **Orden de Compra** (CRUD completo)
   - Listar, crear, editar órdenes
   - Estados: Pendiente, Aprobado, Rechazado, Recibido, En Proceso
   - Filtros y paginación

4. **Distribución y Transporte**
   - Gestión de planes de transporte
   - Gestión de conductores
   - Gestión de vehículos
   - Estados de salida

5. **Alertas**
   - Visualización de alertas
   - Filtros por tipo de alerta

**Evidencias a subir:**
- Capturas de cada módulo funcionando
- Capturas de formularios completados
- Capturas de listas con datos

**Comentarios para JIRA:**
```
✅ Funcionalidad de Logística completada al 100%

Módulos implementados:
1. ✅ Gestión de Inventario (InventarioServlet)
2. ✅ Movimiento de Productos (MovimientoProductoServlet)
3. ✅ Orden de Compra (OrdenCompraServlet) - CRUD completo
4. ✅ Distribución y Transporte (PlanTransporteServlet)
5. ✅ Alertas (LogisticaAlertServlet)

Características:
- Paginación en todas las listas
- Filtros avanzados
- Búsqueda por múltiples criterios
- Reportes por módulo
- Integración completa con base de datos
```

---

### 🟢 TBD-198: Funcionalidad 100%: Productor
**Estado:** TERMINADO ✅  
**Rol:** Productor  
**Fecha de Actualización:** [Fecha actual]

**Funcionalidades implementadas:**

1. **Mis Productos**
   - Listado de productos del productor
   - Gestión de productos (CRUD)
   - Actualización de precios

2. **Registrar Lotes**
   - Registro de nuevos lotes
   - Asociación a productos
   - Gestión de stock

3. **Órdenes de Compra**
   - Visualización de órdenes recibidas
   - Estados de órdenes
   - Filtros y búsqueda

4. **Reportes**
   - Reporte de productos
   - Reporte de lotes
   - Reporte de órdenes

**Evidencias a subir:**
- Capturas de cada módulo
- Capturas de formularios
- Capturas de reportes

**Comentarios para JIRA:**
```
✅ Funcionalidad de Productor completada al 100%

Módulos implementados:
1. ✅ Mis Productos (ProductorServlet)
2. ✅ Registrar Lotes (LoteServlet)
3. ✅ Órdenes de Compra
4. ✅ Actualizar Precios
5. ✅ Reportes

Características:
- Interfaz intuitiva
- Validaciones completas
- Integración con base de datos
- Reportes por módulo
- Perfil de usuario con foto
```

---

### 🟡 TBD-199: Funcionalidad 100%: Almacen
**Estado:** TERMINADO ✅  
**Rol:** Almacén  
**Fecha de Actualización:** [Fecha actual]

**Funcionalidades implementadas:**

1. **Gestión de Inventario**
   - Listado de lotes
   - Gestión de stock por lote
   - Ajustes de inventario

2. **Registrar Entradas**
   - Registro de entradas de productos
   - Asociación a lotes
   - Actualización de stock

3. **Registrar Salidas**
   - Gestión de pedidos
   - Preparación de pedidos
   - Despacho de pedidos

4. **Historial de Movimientos**
   - Consulta de movimientos
   - Filtros por tipo y fecha
   - Detalles de movimientos

5. **Reportes**
   - Reporte de lotes
   - Reporte de movimientos

**Evidencias a subir:**
- Capturas de cada módulo
- Capturas de flujos completos
- Capturas de reportes

**Comentarios para JIRA:**
```
✅ Funcionalidad de Almacén completada al 100%

Módulos implementados:
1. ✅ Gestión de Inventario (LoteServlet)
2. ✅ Registrar Entradas (EntradaServlet)
3. ✅ Registrar Salidas (PedidoServlet)
4. ✅ Historial de Movimientos (MovimientoServlet)
5. ✅ Reportes (LoteReporteServlet, MovimientoReporteServlet)

Características:
- Gestión completa de lotes
- Control de stock por lote
- Estados de pedidos: Pendiente, Preparando, Despachado
- Alertas de stock mínimo por lote
- Reportes detallados
```

---

#

### 🔄 TBD-200: Actualizar base de datos
**Estado:** EN DESARROLLO → TERMINADO ✅  
**Rol:** Todos  
**Fecha de Actualización:** [Fecha actual]

**Comentarios para JIRA:**
```
✅ Base de datos actualizada con todos los cambios

Scripts ejecutados:
1. ✅ agregar_foto_perfil.sql - Columna foto_perfil en usuarios
2. ✅ agregar_stock_lote_columnas.sql - Columnas de stock en lotes
3. ✅ agregar_estado_salida_planes_transporte.sql - Estados en planes_transporte
4. ✅ add_distrito_id_to_ordenes_compra.sql - distrito_id en órdenes_compra
5. ✅ agregar_estado_en_proceso.sql - Estado "En Proceso" en órdenes_compra
6. ✅ actualizar_tipos_alerta.sql - Nuevos tipos de alerta
7. ✅ actualizar_ordenes_compra.sql - Corrección productor_id y distrito_id

Verificaciones:
- ✅ Foreign keys correctas
- ✅ Integridad referencial verificada
- ✅ Datos de prueba insertados
- ✅ Consultas optimizadas
```

---

### ✅ TBD-209: Verificar CRUD al 100%
**Estado:** EN DESARROLLO → TERMINADO ✅  
**Rol:** Todos  
**Fecha de Actualización:** [Fecha actual]

**Comentarios para JIRA:**
```
✅ CRUD verificado al 100% en todos los módulos

Verificaciones realizadas:

ADMINISTRADOR:
- ✅ CRUD Usuarios
- ✅ CRUD Alertas
- ✅ CRUD Stock Mínimo
- ✅ CRUD Conductores
- ✅ CRUD Vehículos
- ✅ CRUD Plantillas

LOGÍSTICA:
- ✅ CRUD Orden de Compra
- ✅ CRUD Movimientos
- ✅ CRUD Planes de Transporte

PRODUCTOR:
- ✅ CRUD Productos
- ✅ CRUD Lotes
- ✅ CRUD Órdenes (lectura)

ALMACÉN:
- ✅ CRUD Lotes
- ✅ CRUD Entradas
- ✅ CRUD Pedidos
- ✅ CRUD Movimientos

Todas las operaciones CRUD funcionando correctamente:
- ✅ Crear
- ✅ Leer/Listar
- ✅ Actualizar/Editar
- ✅ Eliminar (borrado lógico donde aplica)
- ✅ Validaciones
- ✅ Mensajes de error/éxito
```

---

## 📝 Tareas Pendientes / En Desarrollo

### ⏳ TBD-195: Decidir flujo para Parcial
**Estado:** EN DESARROLLO  
**Rol:** Todos

**Comentarios para JIRA:**
```
⚠️ EN DESARROLLO - Flujo para parcial en proceso de definición

Próximos pasos:
- [ ] Definir flujo completo
- [ ] Documentar proceso
- [ ] Implementar funcionalidades faltantes
```

---

## 📸 Guía para Subir Evidencias

### Cómo agregar imágenes en JIRA:

1. **Abrir la tarea en JIRA**
   - Haz clic en el ID de la tarea (ej: TBD-217)

2. **Buscar la sección de adjuntos**
   - En la parte inferior de la tarea, busca "Adjuntos" o "Attachments"
   - Haz clic en "Adjuntar archivos" o el icono de papel clip

3. **Subir las capturas**
   - Selecciona las imágenes desde tu computadora
   - Asegúrate de que los nombres sean descriptivos:
     - `login-formulario.png`
     - `login-validacion.png`
     - `logout-confirmacion.png`
     - etc.

4. **Agregar comentarios con contexto**
   - En cada comentario, menciona qué muestra la imagen
   - Usa el formato de comentarios proporcionado arriba

### Tipos de capturas recomendadas:

- **Pantallas completas** de funcionalidades principales
- **Formularios** antes y después de completar
- **Mensajes de éxito/error**
- **Listas con datos** mostrando filtros y paginación
- **Flujos completos** (paso a paso)
- **Reportes** generados

---

## 🎯 Checklist de Actualización

Usa este checklist para asegurarte de actualizar todo:

### Tareas Principales
- [ ] TBD-217: Crear el Login
- [ ] TBD-221: Configurar botones de cerrar sesion
- [ ] TBD-226: Configurar alertas Productor y Almacén
- [ ] TBD-218: Terminar CRUD de Ordenes de compra
- [ ] TBD-210: Crear una nueva rama en Git para el Login
- [ ] TBD-211: Verificar base de datos de Productor y almacen
- [ ] TBD-215: Corregir estilo sidebar
- [ ] TBD-216: Crear Inicio (selector de botones)

### Funcionalidades por Rol
- [ ] TBD-196 / TBD-212: Funcionalidad 100%: Logistica
- [ ] TBD-198: Funcionalidad 100%: Productor
- [ ] TBD-199: Funcionalidad 100%: Almacen
- [ ] TBD-197 / TBD-213: Funcionalidad 100%: Administrador

### Otras Tareas
- [ ] TBD-200: Actualizar base de datos
- [ ] TBD-209: Verificar CRUD al 100%

### Evidencias
- [ ] Capturas de Login y Logout
- [ ] Capturas de Alertas
- [ ] Capturas de CRUD de Órdenes
- [ ] Capturas de cada módulo por rol
- [ ] Capturas de reportes
- [ ] Capturas de base de datos

---

## 💡 Tips para Actualizar JIRA

1. **Actualiza el estado** de cada tarea a "TERMINADO" cuando corresponda
2. **Agrega fecha de actualización** en cada comentario
3. **Usa el formato de comentarios** proporcionado para consistencia
4. **Sube al menos 2-3 capturas** por tarea importante
5. **Menciona los archivos principales** modificados
6. **Documenta cambios en BD** cuando aplique
7. **Mantén los comentarios en español** y claros

---

## 📞 Soporte

Si necesitas ayuda adicional:
- Revisa los archivos fuente mencionados en cada tarea
- Consulta los scripts SQL para entender cambios en BD
- Verifica los servlets para entender la lógica implementada

---

**Última actualización:** [Fecha actual]  
**Versión:** 1.0  
**Proyecto:** Telito Bodeguero

