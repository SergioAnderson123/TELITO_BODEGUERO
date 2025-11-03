# 📧 Plan de Integración de Correos Electrónicos en TELITO BODEGUERO

## 🎯 Objetivo

Integrar el sistema de envío de correos electrónicos en todos los módulos del proyecto para:
- **Notificar eventos importantes** automáticamente
- **Mejorar la comunicación** entre roles del sistema
- **Alertar sobre situaciones críticas** (stock bajo, vencimientos, etc.)
- **Confirmar operaciones** realizadas por usuarios

---

## 📋 Módulos del Sistema

El proyecto **TELITO BODEGUERO** tiene 4 módulos principales:

1. **🔧 Módulo Administrador** - Gestión general del sistema
2. **📦 Módulo Almacén** - Gestión de pedidos, entradas y lotes
3. **🚚 Módulo Logística** - Órdenes de compra, planes de transporte
4. **🌾 Módulo Productor** - Registro de productos y lotes

---

## 🔧 MÓDULO ADMINISTRADOR

### 1. **Gestión de Usuarios**

#### **Crear Nuevo Usuario**
**Ubicación:** `UsuarioServlet.doPost()` - acción "guardar"

**Correo a enviar:**
- **Destinatario:** Email del nuevo usuario
- **Asunto:** "TELITO BODEGUERO - Bienvenido al Sistema"
- **Mensaje:** Credenciales de acceso y bienvenida

```java
// Después de guardar el usuario exitosamente
if (usuarioGuardado) {
    String emailUsuario = request.getParameter("email");
    String passwordTemporal = request.getParameter("password"); // O generar uno
    
    EmailUtil.sendSystemAlertHTML(
        emailUsuario,
        "Bienvenido a TELITO BODEGUERO",
        """
        <h2>Bienvenido al Sistema TELITO BODEGUERO</h2>
        <p>Se ha creado tu cuenta exitosamente.</p>
        <p><strong>Credenciales de acceso:</strong></p>
        <ul>
            <li>Email: %s</li>
            <li>Contraseña temporal: %s</li>
        </ul>
        <p>Por favor, cambia tu contraseña al iniciar sesión por primera vez.</p>
        """.formatted(emailUsuario, passwordTemporal)
    );
}
```

#### **Editar Usuario / Cambio de Rol**
**Ubicación:** `UsuarioServlet.doPost()` - acción "actualizar"

**Correo a enviar:**
- Notificación de cambio de rol o permisos
- Información actualizada del perfil

#### **Desactivar Usuario**
**Ubicación:** `UsuarioServlet.doPost()` - acción "desactivar"

**Correo a enviar:**
- Notificación de desactivación de cuenta
- Razón de la desactivación (si aplica)

---

### 2. **Sistema de Alertas**

#### **Alertas de Stock Mínimo**
**Ubicación:** `AlertaDAO.contarAlertasAbiertas()` o job programado

**Correo a enviar:**
- **Destinatario:** Usuarios del rol configurado (ALMACEN, LOGISTICA)
- **Asunto:** "TELITO BODEGUERO - Alerta de Stock Mínimo"
- **Mensaje:** Lista de productos con stock bajo

```java
// En un job o método de verificación periódica
AlertaDAO alertaDAO = new AlertaDAO();
ArrayList<String> alertas = alertaDAO.listarAlertasParaRol("ALMACEN");

if (!alertas.isEmpty()) {
    alertaDAO.enviarAlertasPorCorreo(
        "ALMACEN",
        "Alertas de Stock Mínimo",
        alertas
    );
}
```

#### **Alertas de Vencimiento**
**Ubicación:** Job programado o verificación automática

**Correo a enviar:**
- **Destinatario:** Usuarios del rol configurado
- **Asunto:** "TELITO BODEGUERO - Alertas de Vencimiento"
- **Mensaje:** Lista de lotes próximos a vencer

---

### 3. **Configuración del Sistema**

#### **Cambios en Configuración**
**Ubicación:** Cuando se actualiza configuración crítica

**Correo a enviar:**
- Notificación a administradores sobre cambios importantes

---

## 📦 MÓDULO ALMACÉN

### 1. **Gestión de Pedidos**

#### **Pedido Preparado / Despachado**
**Ubicación:** `PedidoServlet.doPost()` - después de actualizar estado a "Despachado"

**Correos a enviar:**

**a) Al Cliente:**
```java
// Después de actualizar el estado a "Despachado"
Pedido pedido = pedidoDao.buscarPedidoPorId(idPedido);
if (pedido != null && pedido.getCliente() != null) {
    String emailCliente = pedido.getCliente().getEmail();
    
    if (emailCliente != null && !emailCliente.isEmpty()) {
        String mensaje = """
            <h2>Tu Pedido ha sido Despachado</h2>
            <p><strong>Número de Pedido:</strong> %s</p>
            <p><strong>Fecha de Despacho:</strong> %s</p>
            <p><strong>Destino:</strong> %s</p>
            <p>Tu pedido está en camino. Te notificaremos cuando sea entregado.</p>
            """.formatted(
                pedido.getNumeroPedido(),
                new java.util.Date(),
                pedido.getDestino()
            );
        
        EmailUtil.sendSystemAlertHTML(emailCliente, "Pedido Despachado - TELITO BODEGUERO", mensaje);
    }
}
```

**b) A Logística (si aplica):**
- Notificación cuando se necesita plan de transporte

#### **Pedido Nuevo Creado**
**Ubicación:** Cuando se crea un nuevo pedido

**Correo a enviar:**
- Notificación a personal de almacén sobre nuevo pedido pendiente

---

### 2. **Registro de Entradas**

#### **Entrada de Mercancía Registrada**
**Ubicación:** `EntradaServlet.doPost()` - después de registrar lote

**Correo a enviar:**

**a) Al Productor:**
```java
// Después de registrar el lote exitosamente
OrdenCompra orden = ordenCompraDao.buscarOrdenPorId(idOrden);
if (orden != null && orden.getProductor() != null) {
    String emailProductor = orden.getProductor().getEmail();
    
    if (emailProductor != null && !emailProductor.isEmpty()) {
        EmailUtil.sendSystemAlertHTML(
            emailProductor,
            "Entrada Registrada - TELITO BODEGUERO",
            """
            <h2>Tu Orden de Compra ha sido Registrada</h2>
            <p><strong>Orden:</strong> %s</p>
            <p><strong>Lote:</strong> %s</p>
            <p><strong>Fecha de Registro:</strong> %s</p>
            <p>La mercancía ha ingresado al almacén exitosamente.</p>
            """.formatted(
                orden.getNumeroOrden(),
                codigoLote,
                new java.util.Date()
            )
        );
    }
}
```

**b) A Administración:**
- Confirmación de entrada de mercancía para control

---

### 3. **Gestión de Lotes**

#### **Stock Crítico Detectado**
**Ubicación:** `LoteServlet` o verificación automática

**Correo a enviar:**
- Alertas cuando un lote específico tiene stock crítico
- Notificar a almacén y logística

---

### 4. **Movimientos de Inventario**

#### **Movimiento Importante**
**Ubicación:** `MovimientoServlet` - movimientos significativos

**Correo a enviar:**
- Notificaciones de movimientos grandes de stock
- Ajustes de inventario importantes

---

## 🚚 MÓDULO LOGÍSTICA

### 1. **Órdenes de Compra**

#### **Orden de Compra Aprobada**
**Ubicación:** `OrdenCompraServlet.doPost()` - acción "aprobar"

**Correo a enviar:**

**a) Al Productor:**
```java
// Después de aprobar la orden
OrdenCompra orden = ordenCompraDao.buscarOrdenPorId(idOrden);
if (orden != null && orden.getProductor() != null) {
    String emailProductor = orden.getProductor().getEmail();
    
    EmailUtil.sendSystemAlertHTML(
        emailProductor,
        "Orden de Compra Aprobada - TELITO BODEGUERO",
        """
        <h2>¡Tu Orden de Compra ha sido Aprobada!</h2>
        <p><strong>Número de Orden:</strong> %s</p>
        <p><strong>Producto:</strong> %s</p>
        <p><strong>Cantidad:</strong> %s</p>
        <p><strong>Fecha de Aprobación:</strong> %s</p>
        <p>Por favor, prepara la mercancía para entrega según lo acordado.</p>
        """.formatted(
            orden.getNumeroOrden(),
            orden.getNombreProducto(),
            orden.getCantidad(),
            new java.util.Date()
        )
    );
}
```

#### **Orden de Compra Rechazada**
**Ubicación:** `OrdenCompraServlet.doPost()` - acción "rechazar"

**Correo a enviar:**
- Notificación al productor con motivo del rechazo

#### **Orden de Compra Creada**
**Ubicación:** `OrdenCompraServlet.doPost()` - acción "guardar"

**Correo a enviar:**
- Notificación a administradores sobre nueva orden pendiente de aprobación

---

### 2. **Planes de Transporte**

#### **Plan de Transporte Creado**
**Ubicación:** `PlanTransporteServlet.doPost()` - acción "guardar"

**Correos a enviar:**

**a) Al Conductor:**
```java
// Después de crear el plan de transporte
PlanTransporte plan = planTransporteDao.buscarPlanPorId(idPlan);
if (plan != null && plan.getConductor() != null) {
    String emailConductor = plan.getConductor().getEmail(); // Necesitarías agregar email a conductor
    
    EmailUtil.sendSystemAlertHTML(
        emailConductor,
        "Nuevo Plan de Transporte Asignado - TELITO BODEGUERO",
        """
        <h2>Se te ha asignado un nuevo Plan de Transporte</h2>
        <p><strong>Número de Plan:</strong> %s</p>
        <p><strong>Destino:</strong> %s</p>
        <p><strong>Fecha de Entrega:</strong> %s</p>
        <p><strong>Vehículo:</strong> %s</p>
        <p>Por favor, revisa los detalles en el sistema.</p>
        """.formatted(
            plan.getNumeroPlan(),
            plan.getDestino(),
            plan.getFechaEntrega(),
            plan.getPlacaVehiculo()
        )
    );
}
```

#### **Plan de Transporte Completado**
**Ubicación:** `PlanTransporteServlet.doPost()` - actualizar estado a "Completado"

**Correo a enviar:**
- Notificación a logística sobre entrega completada
- Confirmación al cliente (si aplica)

---

### 3. **Alertas del Sistema**

#### **Alertas para Logística**
**Ubicación:** `LogisticaAlertServlet` - ya implementado parcialmente

**Mejoras:**
- Enviar correos automáticamente cuando hay alertas nuevas
- Consolidar múltiples alertas en un solo correo diario

```java
// En LogisticaAlertServlet
AlertaDAO alertaDAO = new AlertaDAO();
ArrayList<String> mensajes = alertaDAO.listarAlertasParaRol("LOGISTICA");

if (!mensajes.isEmpty()) {
    // Enviar correo automáticamente
    int correosEnviados = alertaDAO.enviarAlertasPorCorreo(
        "LOGISTICA",
        "Alertas del Sistema - Logística",
        mensajes
    );
}
```

---

## 🌾 MÓDULO PRODUCTOR

### 1. **Registro de Lotes**

#### **Lote Registrado Exitosamente**
**Ubicación:** `ProductorServlet.doPost()` - acción "registrarLote"

**Correo a enviar:**

**a) Confirmación al Productor:**
```java
// Después de registrar el lote
String emailProductor = obtenerEmailDelUsuarioEnSesion();

EmailUtil.sendSystemAlertHTML(
    emailProductor,
    "Lote Registrado - TELITO BODEGUERO",
    """
    <h2>Tu Lote ha sido Registrado Exitosamente</h2>
    <p><strong>Código de Lote:</strong> %s</p>
    <p><strong>Producto:</strong> %s</p>
    <p><strong>Stock:</strong> %s</p>
    <p><strong>Fecha de Vencimiento:</strong> %s</p>
    <p>El lote está ahora en estado "No Registrado" y esperando recepción en almacén.</p>
    """.formatted(
        codigoLote,
        nombreProducto,
        cantidadStock,
        fechaVencimiento
    )
);
```

**b) Notificación a Administración:**
- Notificar a almacén sobre nuevo lote pendiente de recepción

---

### 2. **Órdenes de Compra**

#### **Nueva Orden de Compra Recibida**
**Ubicación:** Cuando logística crea orden para el productor

**Correo a enviar:**
- Notificación al productor sobre nueva orden de compra pendiente

---

### 3. **Productos**

#### **Precio Actualizado**
**Ubicación:** `ProductorServlet.doPost()` - actualizar precios

**Correo a enviar:**
- Confirmación de actualización de precios
- Notificación a logística sobre cambios de precios

---

## 🎯 CASOS DE USO ESPECIALES

### 1. **Alertas Automáticas por Rol**

**Implementación:** Sistema de alertas ya existente + correos automáticos

```java
// En un ScheduledTask o job programado
public void enviarAlertasDiarias() {
    String[] roles = {"ADMINISTRADOR", "ALMACEN", "LOGISTICA", "PRODUCTOR"};
    
    for (String rol : roles) {
        AlertaDAO alertaDAO = new AlertaDAO();
        ArrayList<String> alertas = alertaDAO.listarAlertasParaRol(rol);
        
        if (!alertas.isEmpty()) {
            alertaDAO.enviarAlertasPorCorreo(
                rol,
                "Alertas Diarias - TELITO BODEGUERO",
                alertas
            );
        }
    }
}
```

### 2. **Resúmenes Semanales**

**Correo a enviar:**
- Resumen de operaciones semanales
- Métricas y estadísticas
- Pendientes importantes

### 3. **Notificaciones de Sistema**

**Correo a enviar:**
- Mantenimientos programados
- Actualizaciones del sistema
- Cambios importantes en configuración

---

## 📊 PRIORIDADES DE IMPLEMENTACIÓN

### **Fase 1 - Prioridad Alta (Implementar Primero):**
1. ✅ Alertas automáticas de stock y vencimiento (ya existe parcialmente)
2. ✅ Notificaciones de pedidos despachados
3. ✅ Confirmación de entrada de mercancía a productores
4. ✅ Aprobación/rechazo de órdenes de compra

### **Fase 2 - Prioridad Media:**
1. Notificaciones de planes de transporte a conductores
2. Alertas de stock crítico
3. Confirmación de registro de lotes
4. Notificaciones de nuevos usuarios

### **Fase 3 - Prioridad Baja:**
1. Resúmenes semanales
2. Confirmaciones de actualización de precios
3. Notificaciones de movimientos menores

---

## 🔧 MÉTODOS AUXILIARES NECESARIOS

### **1. Obtener Email de Usuario**
```java
// En UsuarioDAO o crear método nuevo
public String obtenerEmailPorId(int usuarioId) {
    String sql = "SELECT email FROM usuarios WHERE id_usuario = ? AND activo = 1";
    // ... implementación
}
```

### **2. Obtener Email de Cliente**
```java
// En ClienteDAO
public String obtenerEmailPorId(int clienteId) {
    String sql = "SELECT email FROM clientes WHERE id_cliente = ?";
    // ... implementación
}
```

### **3. Obtener Email de Conductor**
```java
// Agregar campo email a tabla conductores o crear método
public String obtenerEmailConductor(int conductorId) {
    // ... implementación
}
```

---

## 🎨 PLANTILLAS DE CORREO HTML

### **Plantilla Base para Notificaciones**
```java
public static String generarPlantillaHTML(String titulo, String contenido) {
    return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #006d77; color: white; padding: 20px; text-align: center; }
                .content { padding: 20px; background-color: #f9f9f9; }
                .footer { padding: 20px; text-align: center; color: #666; font-size: 12px; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h2>TELITO BODEGUERO</h2>
                </div>
                <div class="content">
                    <h3>%s</h3>
                    %s
                </div>
                <div class="footer">
                    <p>Sistema TELITO BODEGUERO - Gestión Logística</p>
                    <p>Este es un correo automático. Por favor, no responda.</p>
                </div>
            </div>
        </body>
        </html>
        """.formatted(titulo, contenido);
}
```

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

- [ ] Agregar método para obtener emails de usuarios por rol
- [ ] Agregar método para obtener email de clientes
- [ ] Agregar método para obtener email de conductores (si no existe)
- [ ] Implementar envío de correos en PedidoServlet (despacho)
- [ ] Implementar envío de correos en EntradaServlet (registro entrada)
- [ ] Implementar envío de correos en OrdenCompraServlet (aprobación/rechazo)
- [ ] Implementar envío de correos en PlanTransporteServlet (asignación)
- [ ] Implementar envío de correos en ProductorServlet (registro lotes)
- [ ] Implementar envío de correos en UsuarioServlet (nuevo usuario)
- [ ] Configurar job programado para alertas automáticas
- [ ] Crear plantillas HTML para diferentes tipos de correos
- [ ] Probar envío de correos en entorno de desarrollo
- [ ] Documentar configuración de SMTP para producción

---

## 📝 NOTAS IMPORTANTES

1. **Siempre verificar que el email no esté vacío** antes de enviar
2. **Manejar errores silenciosamente** - no bloquear operaciones si falla el correo
3. **Registrar logs** de todos los envíos de correos
4. **Usar correos HTML** para mejor presentación
5. **Incluir información relevante** en cada correo (números de orden, fechas, etc.)
6. **Personalizar mensajes** según el destinatario y contexto
7. **Considerar frecuencia** - no saturar a usuarios con demasiados correos

---

## 🚀 PRÓXIMOS PASOS

1. Revisar este plan con el equipo
2. Priorizar qué funcionalidades implementar primero
3. Crear métodos auxiliares necesarios
4. Implementar integraciones módulo por módulo
5. Probar exhaustivamente cada integración
6. Documentar en código y documentación del proyecto

---

**Creado el:** 2025
**Versión:** 1.0
**Proyecto:** TELITO BODEGUERO

