# Guía para Configurar soporte@telitobodeguero.com en Gmail/Outlook

## 📧 Pasos para que las personas usen soporte@telitobodeguero.com

### 1. Crear la cuenta en cPanel

1. Entra a cPanel
2. Ve a **Email Accounts**
3. Haz clic en **Create** o **Crear**
4. Crea la cuenta: `soporte@telitobodeguero.com`
5. Establece una **contraseña segura**
6. Guarda la contraseña (la necesitarás para compartir)

---

### 2. Obtener los datos de configuración

En cPanel, busca una de estas secciones:
- **Email Client Configuration**
- **Connect Devices**
- **Mail Client Manual Settings**
- **Email Accounts** → Click en la cuenta → **Connect Devices**

Anota estos datos (pueden variar según tu hosting):

**Datos que necesitas:**
- Servidor IMAP entrante: `mail.telitobodeguero.com` o `imap.telitobodeguero.com`
- Puerto IMAP: `993` (con SSL) o `143` (sin SSL)
- Servidor SMTP saliente: `mail.telitobodeguero.com` o `smtp.telitobodeguero.com`
- Puerto SMTP: `465` (con SSL) o `587` (con TLS)
- Usuario: `soporte@telitobodeguero.com` (dirección completa)
- Contraseña: La que configuraste en cPanel

**Seguridad:** Usa SSL/TLS siempre que sea posible.

---

### 3. Configurar en Gmail (Android/iPhone/Web)

#### En Gmail Web:
1. Abre Gmail → ⚙️ (Configuración)
2. Ve a **Ver todas las configuraciones**
3. Pestaña **Cuentas e importación**
4. En "Consultar el correo de otras cuentas", haz clic en **Agregar otra cuenta de correo**
5. Selecciona **Agregar una cuenta de correo**
6. Ingresa: `soporte@telitobodeguero.com`
7. Selecciona **Importar correos de mi otra cuenta (POP3)**
8. Ingresa los datos:
   - Nombre de usuario: `soporte@telitobodeguero.com`
   - Contraseña: [La contraseña de la cuenta]
   - Servidor POP: [Servidor que te dio cPanel]
   - Puerto: 995 (POP3 con SSL) o 110
   - Marca "Usar siempre una conexión segura (SSL)"
9. Listo

#### En Gmail App (Android/iPhone):
1. Abre la app Gmail
2. Toca tu foto de perfil (arriba a la derecha)
3. Agrega otra cuenta → Correo electrónico
4. Ingresa: `soporte@telitobodeguero.com`
5. Selecciona **Otro (Personal (IMAP/POP))**
6. Ingresa:
   - Correo: `soporte@telitobodeguero.com`
   - Contraseña: [La contraseña]
7. En configuración avanzada:
   - Servidor IMAP: [El servidor que te dio cPanel]
   - Puerto: 993
   - Tipo de seguridad: SSL/TLS
   - Servidor SMTP: [El servidor SMTP]
   - Puerto SMTP: 465
   - Tipo de seguridad: SSL/TLS
8. Listo

---

### 4. Configurar en Outlook (Windows/Mac/Web/Mobile)

#### Outlook Web/Desktop:
1. Ve a **Archivo** → **Agregar cuenta**
2. Ingresa: `soporte@telitobodeguero.com`
3. Selecciona **Configuración avanzada**
4. Marca **Configurar manualmente**
5. Selecciona **IMAP**
6. Completa:
   - **Servidor de correo entrante (IMAP):** [Servidor IMAP]
   - **Puerto:** 993
   - **Cifrado:** SSL/TLS
   - **Servidor de correo saliente (SMTP):** [Servidor SMTP]
   - **Puerto:** 465 o 587
   - **Cifrado:** SSL/TLS
   - **Usuario:** `soporte@telitobodeguero.com`
   - **Contraseña:** [La contraseña]
7. Siguiente → Finalizar

#### Outlook Mobile (Android/iPhone):
1. Abre Outlook
2. Toca el menú (☰)
3. Agrega cuenta → Agregar correo
4. Ingresa: `soporte@telitobodeguero.com`
5. Selecciona **Configuración avanzada**
6. Selecciona **IMAP**
7. Ingresa los datos de servidor
8. Listo

---

### 5. Compartir las credenciales de forma segura

**⚠️ IMPORTANTE:** Comparte las credenciales de forma segura:
- Usa un gestor de contraseñas compartido
- Envía por WhatsApp/Telegram (no por email)
- O comparte en persona

**Datos a compartir:**
```
Cuenta: soporte@telitobodeguero.com
Contraseña: [Contraseña segura]

Configuración IMAP:
- Servidor: mail.telitobodeguero.com
- Puerto: 993
- Seguridad: SSL/TLS
- Usuario: soporte@telitobodeguero.com

Configuración SMTP:
- Servidor: mail.telitobodeguero.com
- Puerto: 465 o 587
- Seguridad: SSL/TLS
- Usuario: soporte@telitobodeguero.com
```

---

## ✅ Verificación

Después de configurar, prueba:
1. Enviar un correo de prueba desde `soporte@telitobodeguero.com`
2. Recibir un correo enviado a `soporte@telitobodeguero.com`
3. Verificar que aparezca correctamente en Gmail/Outlook

---

## 🔧 Troubleshooting

**Error: "No se puede conectar al servidor"**
- Verifica que los datos del servidor sean correctos
- Asegúrate de usar SSL/TLS
- Verifica que el puerto sea correcto

**Error: "Usuario o contraseña incorrectos"**
- Verifica que uses `soporte@telitobodeguero.com` completo como usuario
- Confirma la contraseña en cPanel

**Los correos no se reciben**
- Verifica que la cuenta esté activa en cPanel
- Revisa la carpeta de spam
- Verifica la configuración IMAP/POP3

---

## 📝 Nota

Si no encuentras los datos del servidor en cPanel, contacta a tu proveedor de hosting. Normalmente te los dan en:
- El email de bienvenida
- En la sección de "Email Client Configuration"
- O preguntando al soporte técnico








