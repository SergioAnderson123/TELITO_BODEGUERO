# 🚨 Problemas Críticos al Desplegar en AWS EC2

## ⚠️ **SÍ, HABRÁ VARIOS ERRORES CRÍTICOS**

Este documento identifica todos los problemas que **definitivamente fallarán** al subir la aplicación a AWS EC2 y cómo solucionarlos.

---

## 🔴 **ERRORES CRÍTICOS (La aplicación NO funcionará)**

### 1. **Credenciales de Base de Datos Hardcodeadas**
**Ubicación**: `src/main/java/com/example/telito/util/DatabaseConnection.java` líneas 14-16

**Problema**:
```java
private static final String URL = "jdbc:mysql://localhost:3306/telito_bodeguero";
private static final String USER = "root";
private static final String PASSWORD = "root";
```

**Por qué falla en EC2**:
- ❌ `localhost` no funcionará si la BD está en RDS o en otra instancia
- ❌ Las credenciales están hardcodeadas (mala práctica de seguridad)
- ❌ No hay soporte para diferentes ambientes (dev/prod)

**Solución**:
```java
// Usar variables de entorno o archivo de propiedades
private static final String URL = System.getenv("DB_URL") != null ? 
    System.getenv("DB_URL") : 
    "jdbc:mysql://localhost:3306/telito_bodeguero";
    
private static final String USER = System.getenv("DB_USER") != null ? 
    System.getenv("DB_USER") : "root";
    
private static final String PASSWORD = System.getenv("DB_PASSWORD") != null ? 
    System.getenv("DB_PASSWORD") : "root";
```

**Mejor solución (usar archivo de propiedades)**:
```java
// Crear src/main/resources/database.properties
// db.url=jdbc:mysql://tu-rds-endpoint.region.rds.amazonaws.com:3306/telito_bodeguero
// db.user=admin
// db.password=tu_password_seguro

private static String URL;
private static String USER;
private static String PASSWORD;

static {
    Properties props = new Properties();
    try (InputStream input = DatabaseConnection.class.getClassLoader()
            .getResourceAsStream("database.properties")) {
        if (input != null) {
            props.load(input);
            URL = props.getProperty("db.url");
            USER = props.getProperty("db.user");
            PASSWORD = props.getProperty("db.password");
        }
    } catch (IOException e) {
        // Fallback a variables de entorno
        URL = System.getenv("DB_URL");
        USER = System.getenv("DB_USER");
        PASSWORD = System.getenv("DB_PASSWORD");
    }
}
```

---

### 2. **Contraseña de Email Expuesta en el Código**
**Ubicación**: `src/main/resources/email.properties` línea 13

**Problema**:
```properties
email.password=jjjk mscy txcq xhsr
```

**Por qué falla en EC2**:
- ❌ **CRÍTICO DE SEGURIDAD**: La contraseña está en el código fuente
- ❌ Si subes el código a Git, la contraseña queda expuesta
- ❌ No puedes usar diferentes credenciales por ambiente

**Solución**:
1. **NO subir `email.properties` a Git** (agregar a `.gitignore`)
2. Crear `email.properties.example` como plantilla:
```properties
# Email del remitente
email.from=tu_email@gmail.com

# Contraseña de aplicación (NO SUBIR ESTE ARCHIVO CON LA CONTRASEÑA)
email.password=TU_CONTRASEÑA_AQUI

# Configuración SMTP
smtp.host=smtp.gmail.com
smtp.port=587
```

3. **Usar variables de entorno en producción**:
```java
// En EmailUtil.java, modificar loadEmailConfig():
EMAIL_FROM = System.getenv("EMAIL_FROM") != null ? 
    System.getenv("EMAIL_FROM") : props.getProperty("email.from", "");
    
EMAIL_PASSWORD = System.getenv("EMAIL_PASSWORD") != null ? 
    System.getenv("EMAIL_PASSWORD") : props.getProperty("email.password", "");
```

---

### 3. **Uso de `getRealPath()` que Puede Retornar Null**
**Ubicación**: Múltiples archivos:
- `PerfilServlet.java` línea 109
- `ImageServlet.java` línea 34
- `FileUploadUtil.java` (usado con `getRealPath()`)

**Problema**:
```java
String uploadPath = getServletContext().getRealPath("/");
// En EC2/Tomcat empaquetado, esto puede retornar NULL
```

**Por qué falla en EC2**:
- ❌ En WAR desplegado, `getRealPath()` puede retornar `null`
- ❌ Los archivos no se guardarán en ningún lugar
- ❌ Las imágenes no se servirán correctamente

**Solución**:
```java
// Usar directorio absoluto configurado
private static final String UPLOAD_BASE_DIR = System.getenv("UPLOAD_DIR") != null ?
    System.getenv("UPLOAD_DIR") : "/var/www/telito/uploads";

String uploadPath = getServletContext().getRealPath("/");
if (uploadPath == null) {
    // Fallback a directorio absoluto
    uploadPath = UPLOAD_BASE_DIR;
} else {
    uploadPath = Paths.get(uploadPath, "uploads").toString();
}
```

**Mejor solución (usar directorio absoluto siempre)**:
```java
// En FileUploadUtil.java
private static final String UPLOAD_BASE_DIR = 
    System.getProperty("user.home") + "/telito_uploads";

// O mejor, usar variable de entorno
private static final String UPLOAD_BASE_DIR = 
    System.getenv("UPLOAD_DIR") != null ? 
    System.getenv("UPLOAD_DIR") : 
    System.getProperty("user.home") + "/telito_uploads";
```

---

### 4. **Rutas de Archivos Temporales en `/tmp`**
**Ubicación**: Todos los servlets de reportes (LoteReporteServlet, etc.)

**Problema**:
```java
String tempDir = System.getProperty("java.io.tmpdir");
// En EC2, esto puede ser /tmp que se limpia periódicamente
```

**Por qué falla en EC2**:
- ❌ `/tmp` en EC2 puede limpiarse automáticamente
- ❌ Puede no tener permisos de escritura
- ❌ Espacio limitado en `/tmp`

**Solución**:
```java
// Usar directorio dedicado con más espacio
String tempDir = System.getenv("TEMP_DIR") != null ?
    System.getenv("TEMP_DIR") : 
    "/var/tmp/telito_reports"; // Más persistente que /tmp

File tempDirFile = new File(tempDir);
if (!tempDirFile.exists()) {
    tempDirFile.mkdirs();
    // Asegurar permisos
    tempDirFile.setWritable(true, false);
}
```

---

### 5. **Separadores de Ruta Windows vs Linux**
**Ubicación**: Cualquier lugar donde se construyan rutas de archivos

**Problema**:
```java
// Código que puede tener problemas:
String path = uploadPath + "/" + fileName; // ❌ No es portable
```

**Por qué falla en EC2**:
- ❌ Windows usa `\`, Linux usa `/`
- ❌ Aunque Java maneja esto, es mejor usar `Paths` o `File.separator`

**Solución**:
```java
// Usar Paths de Java NIO (ya lo estás haciendo en algunos lugares)
Path filePath = Paths.get(uploadPath, UPLOAD_DIR, uniqueFileName);
// Esto es portable entre Windows y Linux
```

---

## 🟡 **ERRORES MEDIOS (Funcionará parcialmente o con problemas)**

### 6. **Permisos de Archivos en Linux**
**Problema**: Los archivos creados pueden no tener permisos correctos

**Solución**:
```java
// Después de crear un archivo:
Files.setPosixFilePermissions(filePath, 
    PosixFilePermissions.fromString("rw-r--r--"));
```

---

### 7. **Timezone y Fechas**
**Problema**: EC2 puede estar en UTC, causando problemas con fechas locales

**Solución**:
```java
// Configurar timezone en Tomcat o en la aplicación
TimeZone.setDefault(TimeZone.getTimeZone("America/Lima")); // O tu timezone
```

---

### 8. **Puertos y Security Groups**
**Problema**: EC2 Security Groups bloquean puertos por defecto

**Configuración necesaria en AWS**:
- ✅ Puerto 80 (HTTP) - Abrir a 0.0.0.0/0 o tu IP
- ✅ Puerto 443 (HTTPS) - Si usas SSL
- ✅ Puerto 8080 (Tomcat) - Solo si no usas reverse proxy
- ✅ Puerto 3306 (MySQL) - Solo desde tu IP o VPC si usas RDS

---

### 9. **Memoria y Recursos**
**Problema**: EC2 instancias pequeñas pueden quedarse sin memoria

**Solución**:
```bash
# En /etc/tomcat9/setenv.sh (o equivalente)
export CATALINA_OPTS="-Xms512m -Xmx1024m -XX:MaxPermSize=256m"
```

---

### 10. **Logging y Debugging**
**Problema**: Los logs pueden no estar accesibles fácilmente

**Solución**:
- Configurar CloudWatch Logs Agent
- O usar `journalctl` si usas systemd para Tomcat

---

## 🟢 **MEJORAS RECOMENDADAS**

### 11. **Usar RDS en lugar de MySQL Local**
- ✅ Mejor rendimiento
- ✅ Backups automáticos
- ✅ Alta disponibilidad
- ✅ Escalabilidad

### 12. **Usar S3 para Archivos Estáticos**
- ✅ En lugar de guardar en el servidor
- ✅ Mejor para escalabilidad
- ✅ CDN integrado

### 13. **Usar Application Load Balancer**
- ✅ Distribución de carga
- ✅ SSL/TLS terminación
- ✅ Health checks

---

## 📋 **CHECKLIST ANTES DE DESPLEGAR EN EC2**

### Configuración de Código:
- [ ] Cambiar `DatabaseConnection.java` para usar variables de entorno
- [ ] Crear `database.properties.example` (sin credenciales reales)
- [ ] Mover `email.properties` a variables de entorno
- [ ] Agregar `email.properties` a `.gitignore`
- [ ] Reemplazar todos los `getRealPath()` con rutas absolutas
- [ ] Usar `Paths.get()` en lugar de concatenación de strings
- [ ] Configurar directorio de uploads con variable de entorno

### Configuración de AWS EC2:
- [ ] Crear Security Group con puertos necesarios
- [ ] Configurar RDS (si usas base de datos separada)
- [ ] Configurar Elastic IP (opcional, para IP fija)
- [ ] Instalar Java 17 y Tomcat 10
- [ ] Configurar variables de entorno en `/etc/environment` o `setenv.sh`
- [ ] Crear directorios necesarios con permisos correctos:
  ```bash
  sudo mkdir -p /var/www/telito/uploads
  sudo mkdir -p /var/tmp/telito_reports
  sudo chown -R tomcat:tomcat /var/www/telito
  sudo chown -R tomcat:tomcat /var/tmp/telito_reports
  ```

### Variables de Entorno a Configurar:
```bash
# En /etc/tomcat9/setenv.sh o /etc/environment
export DB_URL="jdbc:mysql://tu-rds-endpoint.region.rds.amazonaws.com:3306/telito_bodeguero"
export DB_USER="admin"
export DB_PASSWORD="tu_password_seguro"
export EMAIL_FROM="tu_email@gmail.com"
export EMAIL_PASSWORD="tu_app_password"
export UPLOAD_DIR="/var/www/telito/uploads"
export TEMP_DIR="/var/tmp/telito_reports"
```

### Testing:
- [ ] Probar conexión a base de datos
- [ ] Probar envío de correos
- [ ] Probar subida de archivos
- [ ] Probar generación de reportes
- [ ] Verificar que las imágenes se sirven correctamente
- [ ] Probar con diferentes roles de usuario

---

## 🔧 **SCRIPT DE CONFIGURACIÓN INICIAL PARA EC2**

```bash
#!/bin/bash
# configurar_ec2.sh

# 1. Actualizar sistema
sudo yum update -y

# 2. Instalar Java 17
sudo yum install -y java-17-amazon-corretto-devel

# 3. Instalar Tomcat 10
sudo yum install -y tomcat10 tomcat10-webapps tomcat10-admin-webapps

# 4. Crear directorios
sudo mkdir -p /var/www/telito/uploads
sudo mkdir -p /var/tmp/telito_reports
sudo chown -R tomcat:tomcat /var/www/telito
sudo chown -R tomcat:tomcat /var/tmp/telito_reports

# 5. Configurar variables de entorno
sudo tee /etc/tomcat10/setenv.sh > /dev/null <<EOF
export DB_URL="jdbc:mysql://TU_RDS_ENDPOINT:3306/telito_bodeguero"
export DB_USER="admin"
export DB_PASSWORD="TU_PASSWORD"
export EMAIL_FROM="tu_email@gmail.com"
export EMAIL_PASSWORD="tu_app_password"
export UPLOAD_DIR="/var/www/telito/uploads"
export TEMP_DIR="/var/tmp/telito_reports"
EOF

# 6. Iniciar Tomcat
sudo systemctl enable tomcat10
sudo systemctl start tomcat10

# 7. Verificar estado
sudo systemctl status tomcat10
```

---

## 🚀 **PASOS PARA DESPLEGAR**

1. **Compilar el WAR**:
   ```bash
   mvn clean package
   ```

2. **Subir el WAR a EC2**:
   ```bash
   scp target/TELITO_BODEGUERO.war ec2-user@tu-ec2-ip:/tmp/
   ```

3. **Desplegar en Tomcat**:
   ```bash
   ssh ec2-user@tu-ec2-ip
   sudo cp /tmp/TELITO_BODEGUERO.war /var/lib/tomcat10/webapps/
   sudo systemctl restart tomcat10
   ```

4. **Verificar logs**:
   ```bash
   sudo tail -f /var/log/tomcat10/catalina.out
   ```

---

## ⚠️ **ERRORES COMUNES Y SOLUCIONES**

### Error: "Connection refused" al conectar a BD
- ✅ Verificar que RDS Security Group permite conexiones desde EC2
- ✅ Verificar que la URL de conexión es correcta
- ✅ Verificar credenciales

### Error: "Permission denied" al crear archivos
- ✅ Verificar permisos del directorio: `sudo chown -R tomcat:tomcat /ruta`
- ✅ Verificar que el directorio existe

### Error: "Email not sent"
- ✅ Verificar variables de entorno `EMAIL_FROM` y `EMAIL_PASSWORD`
- ✅ Verificar que Security Group permite tráfico saliente en puerto 587
- ✅ Verificar credenciales de Gmail (app password)

### Error: "404 Not Found" en imágenes
- ✅ Verificar que `ImageServlet` está mapeado correctamente
- ✅ Verificar que los archivos están en el directorio correcto
- ✅ Verificar permisos de lectura

---

**Fecha de creación**: $(date)
**Última actualización**: $(date)


