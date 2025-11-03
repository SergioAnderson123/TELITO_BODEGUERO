# Configuración del Sistema de Correos - TELITO BODEGUERO

Este documento explica cómo configurar y usar el sistema de envío de correos electrónicos integrado en TELITO BODEGUERO, basado en el concepto del proyecto VetClinic.

## 📋 Tabla de Contenidos

1. [Prerequisitos](#prerequisitos)
2. [Configuración](#configuración)
3. [Uso del Sistema](#uso-del-sistema)
4. [API de EmailUtil](#api-de-emailutil)
5. [Ejemplos de Uso](#ejemplos-de-uso)

## 🔧 Prerequisitos

- Java 17+
- Tomcat 10.x
- Cuenta de Gmail (o proveedor SMTP compatible)
- Contraseña de aplicación de Gmail (16 caracteres)

### Crear Contraseña de Aplicación en Gmail

1. Ve a tu cuenta de Google: https://myaccount.google.com/
2. Seguridad > Verificación en 2 pasos (debe estar activada)
3. Contraseñas de aplicaciones > Generar nueva
4. Copia la contraseña de 16 caracteres generada

## ⚙️ Configuración

### 1. Configurar Credenciales

Edita el archivo `src/main/resources/email.properties`:

```properties
# Email del remitente
email.from=tu_email@gmail.com

# Contraseña de aplicación de Gmail (16 caracteres)
email.password=TU_CONTRASEÑA_DE_APLICACION

# Configuración SMTP (Gmail por defecto)
smtp.host=smtp.gmail.com
smtp.port=587
```

### 2. Configuración Alternativa (Programática)

Si prefieres no usar el archivo de propiedades, puedes configurar las credenciales en tu código:

```java
EmailUtil.configureEmail(
    "tu_email@gmail.com",
    "tu_contraseña_de_aplicacion",
    "smtp.gmail.com",
    "587"
);
```

## 📧 Uso del Sistema

### Envío Simple de Correo

```java
import com.example.telito.util.EmailUtil;

// Enviar correo de texto plano
boolean enviado = EmailUtil.sendEmail(
    "destinatario@example.com",
    "Asunto del correo",
    "Mensaje del correo"
);

// Enviar correo HTML
boolean enviado = EmailUtil.sendEmail(
    "destinatario@example.com",
    "Asunto del correo",
    "<h1>Título</h1><p>Mensaje HTML</p>",
    true  // isHtml = true
);
```

### Envío de Alertas del Sistema

```java
import com.example.telito.util.EmailUtil;

// Enviar alerta en texto plano
EmailUtil.sendSystemAlert(
    "usuario@example.com",
    "Stock Mínimo",
    "El producto X tiene stock mínimo. Favor revisar."
);

// Enviar alerta en HTML (con formato mejorado)
EmailUtil.sendSystemAlertHTML(
    "usuario@example.com",
    "Stock Crítico",
    "El producto Y tiene stock crítico. Se requiere acción inmediata."
);
```

### Envío de Alertas por Rol

```java
import com.example.telito.administrador.daos.AlertaDAO;

AlertaDAO alertaDAO = new AlertaDAO();

// Obtener alertas para un rol
ArrayList<String> mensajes = alertaDAO.listarAlertasParaRol("LOGISTICA");

// Enviar correos a todos los usuarios del rol
if (!mensajes.isEmpty()) {
    int correosEnviados = alertaDAO.enviarAlertasPorCorreo(
        "LOGISTICA",
        "Alertas del Sistema",
        mensajes
    );
    System.out.println("Se enviaron " + correosEnviados + " correos");
}
```

## 🎯 API de EmailUtil

### Métodos Principales

#### `sendEmail(String to, String subject, String messageBody)`
Envía un correo de texto plano.

#### `sendEmail(String to, String subject, String messageBody, boolean isHtml)`
Envía un correo (texto plano o HTML según `isHtml`).

#### `sendSystemAlert(String toEmail, String alertTitle, String alertMessage)`
Envía una alerta del sistema en texto plano.

#### `sendSystemAlertHTML(String toEmail, String alertTitle, String alertMessage)`
Envía una alerta del sistema en HTML con formato mejorado.

#### `configureEmail(String emailFrom, String emailPassword, String smtpHost, String smtpPort)`
Configura las credenciales de email manualmente.

#### `isEmailConfigured()`
Verifica si la configuración de email está completa.

## 💡 Ejemplos de Uso

### Ejemplo 1: Enviar Correo al Registrar un Pedido

```java
// En tu servlet de pedidos
public class PedidoServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        // ... lógica de registro de pedido ...
        
        // Enviar confirmación por correo
        String emailCliente = request.getParameter("emailCliente");
        if (emailCliente != null && !emailCliente.isEmpty()) {
            EmailUtil.sendEmail(
                emailCliente,
                "TELITO BODEGUERO - Pedido Registrado",
                "Su pedido ha sido registrado exitosamente.\n\n" +
                "Número de pedido: " + numeroPedido + "\n" +
                "Gracias por su preferencia."
            );
        }
    }
}
```

### Ejemplo 2: Notificar Stock Mínimo

```java
// En tu servlet de inventario
public class InventarioServlet extends HttpServlet {
    
    public void verificarStock() {
        AlertaDAO alertaDAO = new AlertaDAO();
        ArrayList<String> alertas = alertaDAO.listarAlertasParaRol("ALMACEN");
        
        if (!alertas.isEmpty()) {
            // Enviar correos a todos los usuarios de almacén
            alertaDAO.enviarAlertasPorCorreo(
                "ALMACEN",
                "Alertas de Stock",
                alertas
            );
        }
    }
}
```

### Ejemplo 3: Usar el Servlet de Envío Manual

Accede a: `/EnviarCorreoServlet?action=test&email=destino@example.com`

O para enviar alertas por rol:
`/EnviarCorreoServlet?action=alertas&rol=LOGISTICA`

## 🔍 Verificación

### Verificar Configuración

```java
if (EmailUtil.isEmailConfigured()) {
    System.out.println("✓ Email configurado correctamente");
} else {
    System.out.println("✗ Email no configurado. Verifica email.properties");
}
```

### Enviar Correo de Prueba

Usa el servlet `EnviarCorreoServlet`:
- GET: `/EnviarCorreoServlet?action=test&email=tu_email@example.com`

## 🐛 Solución de Problemas

### Error: "Credenciales de email no configuradas"
- Verifica que el archivo `email.properties` existe en `src/main/resources/`
- Verifica que `email.from` y `email.password` tienen valores válidos

### Error: "Authentication failed"
- Verifica que estás usando una **contraseña de aplicación**, no tu contraseña normal de Gmail
- Asegúrate de que la verificación en 2 pasos está activada

### Error: "Connection timeout"
- Verifica tu conexión a internet
- Verifica que el puerto 587 no está bloqueado por un firewall
- Intenta cambiar `smtp.port` a `465` y agregar `props.put("mail.smtp.ssl.enable", "true")`

## 📚 Referencias

Este sistema está basado en:
- **Jakarta Mail API 2.0.1**
- Concepto del proyecto **VetClinic**
- Documentación oficial: https://eclipse-ee4j.github.io/angus-mail/

## 📝 Notas

- Las credenciales se cargan automáticamente desde `email.properties` al iniciar la aplicación
- El sistema usa Gmail SMTP por defecto, pero puede configurarse para otros proveedores
- Los correos HTML incluyen estilos inline para mejor compatibilidad
- El sistema registra logs de todas las operaciones de correo

