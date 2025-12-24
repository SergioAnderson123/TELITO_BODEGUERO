# 📋 Resumen Completo: Deployment de Telito Bodeguero a AWS EC2

## 🎯 Objetivo Principal
Desplegar la aplicación Spring Boot `TELITO_BODEGUERO` en una instancia AWS EC2 y conectarla a una base de datos AWS RDS.

---

## 📝 Consultas y Proceso

### 1. Identificación del Tipo de Empaquetado
**Consulta:** ¿La aplicación está empaquetada como WAR o JAR?

**Respuesta:** 
- Revisamos `pom.xml` y confirmamos que está configurada como **WAR**
- Packaging: `<packaging>war</packaging>`
- La aplicación usa Spring Boot con Tomcat embebido

---

### 2. Conexión a EC2 y Transferencia de Código
**Consulta:** ¿Cómo enviar cambios de IntelliJ a EC2?

**Solución Implementada:**
1. **Opción 1 (Recomendada): Usar Git**
   - Push desde local → GitHub
   - Pull en EC2 desde GitHub

2. **Opción 2: Usar SCP**
   - Transferencia directa de archivos vía SCP

**Proceso:**

**Paso 1: Instalar Git en EC2 (si no está instalado)**
```bash
# Verificar si Git está instalado
git --version

# Si no está instalado, instalar (Amazon Linux 2/2023)
sudo yum install -y git

# Verificar instalación
git --version
```

**Paso 2: Clonar el repositorio en EC2**
```bash
cd ~
git clone https://github.com/SergioAnderson123/TELITO_BODEGUERO.git
cd TELITO_BODEGUERO
git checkout rama_modificaciones  # Si usas una rama específica
```

**Paso 3: Sincronizar cambios futuros**
```bash
cd ~/TELITO_BODEGUERO
git pull origin rama_modificaciones
```

**Resumen:**
- Git instalado y configurado en EC2
- Proyecto clonado desde: `https://github.com/SergioAnderson123/TELITO_BODEGUERO.git`
- Branch usado: `rama_modificaciones`

---

### 3. Compilación y Empaquetado en EC2
**Problema 1: Error de Dependencia Jakarta Mail**
```
[ERROR] com.sun.mail:jakarta.mail:jar:2.1.2 was not found
```

**Solución:**
- Corregimos `pom.xml` con las dependencias correctas:
  ```xml
  <!-- Jakarta Mail API -->
  <dependency>
      <groupId>jakarta.mail</groupId>
      <artifactId>jakarta.mail-api</artifactId>
      <version>${jakarta.mail.version}</version>
  </dependency>
  <!-- Jakarta Mail Implementation -->
  <dependency>
      <groupId>org.eclipse.angus</groupId>
      <artifactId>jakarta.mail</artifactId>
      <version>2.0.2</version>
  </dependency>
  ```
- Limpiamos caché de Maven: `rm -rf ~/.m2/repository/com/sun/mail/jakarta.mail`
- Recompilamos: `mvn clean package -DskipTests -U`

---

**Problema 2: Java Heap Space Error**
```
[ERROR] Failed to execute goal ... Error assembling WAR: Java heap space
```

**Solución:**
- Aumentamos memoria de Maven:
  ```bash
  export MAVEN_OPTS="-Xmx512m -Xms256m"
  mvn clean package -DskipTests
  ```

---

### 4. Configuración de Base de Datos RDS
**Consulta:** ¿Cómo conectar la aplicación a AWS RDS en lugar de MySQL local?

**Solución:**
1. **Creación de `application-prod.properties`**
   - Archivo creado en: `src/main/resources/application-prod.properties`
   - Configuración de RDS:
     ```properties
     spring.datasource.url=jdbc:mysql://database-telito.cj5gi85waivv.us-east-1.rds.amazonaws.com:3306/BaseTelito?...
     spring.datasource.username=admin
     spring.datasource.password=umXGwkVRTohgRLelhwH5
     ```
   - Base de datos: `BaseTelito`

2. **Importación de Schema SQL**
   - Archivo importado: `telito_bodeguero_nuevo.sql`
   - Importado a RDS usando MySQL Workbench
   - Base de datos creada: `BaseTelito`

---

**Problema 3: Connection Refused - Base de Datos**
```
java.net.ConnectException: Connection refused
java.sql.SQLException: No se pudo establecer conexión con la base de datos
```

**Causa Raíz:**
- La clase `DatabaseConnection.java` tenía valores hardcodeados:
  ```java
  private static String URL = "jdbc:mysql://localhost:3306/telito_bodeguero...";
  private static String USER = "root";
  private static String PASSWORD = "root";
  ```
- Estos valores sobrescribían la configuración de Spring Boot

**Solución:**
- Modificamos `DatabaseConnection.java` para leer propiedades dinámicamente:
  - Método `loadDatabaseConfig()` agregado
  - Lee primero `application-prod.properties`
  - Si no existe, lee `application.properties`
  - Los valores hardcodeados ahora son solo valores por defecto
  - Código modificado:
    ```java
    private static void loadDatabaseConfig() {
        Properties props = new Properties();
        // Intenta cargar application-prod.properties primero
        try (InputStream input = DatabaseConnection.class.getClassLoader()
                .getResourceAsStream("application-prod.properties")) {
            if (input != null) {
                props.load(input);
            }
        } catch (Exception e) {
            // Si falla, intenta application.properties
        }
        // ... actualiza URL, USER, PASSWORD desde props
    }
    ```

---

### 5. Ejecución de la Aplicación
**Problema 4: Error al Iniciar - JAR No Encontrado**
```
Error: Unable to access jarfile TELITO_BODEGUERO-1.0-SNAPSHOT.war
```

**Causa:**
- Comando ejecutado desde directorio incorrecto
- Nombre de archivo incorrecto

**Solución:**
- El WAR se genera como: `TELITO_BODEGUERO.war` (no `TELITO_BODEGUERO-1.0-SNAPSHOT.war`)
- Ejecutar desde el directorio correcto:
  ```bash
  cd ~/TELITO_BODEGUERO/target
  nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO.war --spring.profiles.active=prod > app.log 2>&1 &
  ```

---

### 6. Configuración de Dominio y Acceso
**Consulta:** ¿Cómo acceder a la aplicación sin el puerto `:8080`?

**Solución: Configuración de Nginx como Reverse Proxy**

1. **Instalación de Nginx**
   ```bash
   sudo yum install -y nginx
   ```

2. **Configuración de Reverse Proxy**
   - Archivo: `/etc/nginx/conf.d/telitobodeguero.conf`
   - Configuración:
     ```nginx
     server {
         listen 80;
         server_name telitobodeguero.com www.telitobodeguero.com;
         
         location / {
             proxy_pass http://localhost:8080;
             proxy_set_header Host $host;
             proxy_set_header X-Real-IP $remote_addr;
             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
             proxy_set_header X-Forwarded-Proto $scheme;
         }
     }
     ```

3. **Security Group AWS**
   - Puerto 80 (HTTP) abierto: `0.0.0.0/0`

4. **Iniciar Nginx**
   ```bash
   sudo systemctl start nginx
   sudo systemctl enable nginx
   ```

**Resultado:** Acceso disponible en `http://telitobodeguero.com` (sin puerto)

---

### 7. Configuración de HTTPS (SSL)
**Consulta:** ¿Cómo obtener HTTPS?

**Solución: Implementación de Let's Encrypt**

1. **Instalación de Certbot**
   ```bash
   sudo yum install -y certbot python3-certbot-nginx
   ```

2. **Problema Inicial: Error de Autorización**
   ```
   An unexpected error occurred: No such authorization
   ```

   **Causa:** Estado previo corrupto de certbot

   **Solución:**
   - Limpiamos estado previo:
     ```bash
     sudo rm -rf /etc/letsencrypt/live/telitobodeguero.com
     sudo rm -rf /etc/letsencrypt/archive/telitobodeguero.com
     sudo rm -rf /etc/letsencrypt/renewal/telitobodeguero.com.conf
     ```
   - Usamos método standalone:
     ```bash
     sudo systemctl stop nginx
     sudo certbot certonly --standalone \
       -d telitobodeguero.com \
       -d www.telitobodeguero.com \
       --non-interactive \
       --agree-tos \
       --email telitobodeguero@gmail.com
     ```

3. **Configuración de Nginx con SSL**
   ```bash
   sudo systemctl start nginx
   sudo certbot --nginx -d telitobodeguero.com -d www.telitobodeguero.com --non-interactive --redirect
   ```

4. **Security Group AWS**
   - Puerto 443 (HTTPS) abierto: `0.0.0.0/0`

**Resultado:**
- ✅ `https://telitobodeguero.com` funcionando
- ✅ `https://www.telitobodeguero.com` funcionando
- ✅ Redirección automática HTTP → HTTPS
- ✅ Certificado válido hasta: **2026-03-17** (90 días)
- ✅ Renovación automática configurada

---

### 8. Consulta sobre Emails Personalizados
**Consulta:** ¿Cómo crear y usar cuentas de correo `@telitobodeguero.com`?

**Información Proporcionada:**
- **cPanel:** Panel de control para gestionar dominios y emails
- **Creación de cuentas:** cPanel → Email Accounts
- **Configuración en clientes:** Requiere datos IMAP/SMTP del hosting
- **Opciones:**
  1. Webmail (acceso directo desde cPanel)
  2. Reenvío automático a Gmail
  3. Configuración manual en Gmail/Outlook con IMAP/POP3

**Aclaración:**
- El dominio `@telitobodeguero.com` no es exclusivo de cPanel
- Es una cuenta de correo real que se puede usar en cualquier cliente
- La aplicación actualmente solo **envía** correos (no los recibe)

---

## ✅ Estado Final

### Infraestructura
- **EC2:** Instancia funcionando
- **RDS:** Base de datos `BaseTelito` conectada
- **Nginx:** Reverse proxy configurado
- **SSL/HTTPS:** Certificado Let's Encrypt activo
- **Dominio:** `telitobodeguero.com` funcionando

### Aplicación
- **URL:** `https://telitobodeguero.com`
- **Puerto interno:** 8080 (Spring Boot)
- **Puerto externo:** 443 (HTTPS) / 80 (HTTP → redirige a HTTPS)
- **Base de datos:** RDS MySQL `BaseTelito`
- **Perfil:** `prod` (production)

### Archivos Clave Modificados
1. `pom.xml` - Dependencias Jakarta Mail corregidas
2. `src/main/resources/application-prod.properties` - Configuración de producción (RDS)
3. `src/main/java/com/example/telito/util/DatabaseConnection.java` - Lectura dinámica de propiedades

### Comandos Útiles para Mantenimiento

```bash
# Ver logs de la aplicación
tail -f ~/TELITO_BODEGUERO/target/app.log

# Reiniciar aplicación
pkill -f TELITO_BODEGUERO
cd ~/TELITO_BODEGUERO/target
nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO.war --spring.profiles.active=prod > app.log 2>&1 &

# Verificar estado de servicios
sudo systemctl status nginx
ps aux | grep TELITO_BODEGUERO

# Sincronizar código desde Git
cd ~/TELITO_BODEGUERO
git pull origin rama_modificaciones
export MAVEN_OPTS="-Xmx512m -Xms256m"
mvn clean package -DskipTests
# Luego reiniciar aplicación

# Renovar certificado SSL (si es necesario)
sudo certbot renew
sudo systemctl reload nginx
```

---

## 📊 Problemas Resueltos - Resumen

| # | Problema | Causa | Solución |
|---|----------|-------|----------|
| 1 | Error dependencia Jakarta Mail | `groupId` incorrecto en `pom.xml` | Cambiar a `jakarta.mail:jakarta.mail-api` y `org.eclipse.angus:jakarta.mail` |
| 2 | Java Heap Space | Memoria insuficiente para Maven | Aumentar `MAVEN_OPTS="-Xmx512m -Xms256m"` |
| 3 | Connection Refused (BD) | Valores hardcodeados en `DatabaseConnection.java` | Leer propiedades dinámicamente desde `application-prod.properties` |
| 4 | JAR no encontrado | Directorio/nombre de archivo incorrecto | Ejecutar desde `target/` con nombre correcto `TELITO_BODEGUERO.war` |
| 5 | Error autorización SSL | Estado previo corrupto de certbot | Limpiar estado y usar método standalone |

---

## 🎓 Lecciones Aprendidas

1. **Siempre revisar valores hardcodeados** - Pueden sobrescribir configuraciones externas
2. **Usar perfiles de Spring Boot** - Separar configuración local vs producción
3. **Verificar directorio y nombres de archivos** - Errores comunes al ejecutar aplicaciones
4. **Limpiar estado previo** - Importante cuando hay errores con herramientas como certbot
5. **Maven requiere memoria suficiente** - Especialmente para proyectos grandes
6. **Git es mejor que SCP** - Para sincronización continua de código

---

## 📚 Archivos de Documentación Creados

1. `COMANDOS_EC2_RAPIDO.md` - Comandos rápidos para EC2
2. `COMANDOS_EC2_RECORDATORIO.md` - Comandos útiles de mantenimiento
3. `configurar-nginx-ec2.sh` - Script para configurar nginx
4. `configurar-https-ec2.sh` - Script para configurar HTTPS
5. `CONFIGURAR_NGINX.md` - Guía detallada de nginx
6. `CONFIGURAR_HTTPS.md` - Guía detallada de HTTPS
7. `GUIA_CONFIGURAR_EMAIL_SOPORTE.md` - Guía para configurar emails personalizados
8. `RESUMEN_DEPLOYMENT.md` - Este documento

---

## 🔒 Seguridad

### Credenciales Configuradas
- **RDS Database:** `BaseTelito`
- **RDS Username:** `admin`
- **Email Gmail:** `telitobodeguero@gmail.com`
- **Dominio:** `telitobodeguero.com`
- **IP EC2:** `3.213.47.70`
- **RDS Endpoint:** `database-telito.cj5gi85waivv.us-east-1.rds.amazonaws.com`

**⚠️ IMPORTANTE:** Este documento contiene información sensible. Mantenerlo seguro y no compartirlo públicamente.

---

## 🚀 Próximos Pasos Recomendados

1. **Monitoreo:** Configurar alertas de CloudWatch para la instancia EC2
2. **Backups:** Configurar backups automáticos de RDS
3. **Logs:** Configurar CloudWatch Logs para la aplicación
4. **SSL Renewal:** Verificar periódicamente que la renovación automática funcione
5. **Emails:** Si se necesita, configurar cuentas personalizadas `@telitobodeguero.com`
6. **CDN:** Considerar CloudFront para mejor rendimiento
7. **Load Balancer:** Si el tráfico crece, considerar Application Load Balancer

---

**Fecha del Deployment:** Diciembre 2025  
**Estado:** ✅ Producción - Funcionando Correctamente


