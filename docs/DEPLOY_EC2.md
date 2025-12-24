# Guía de Despliegue en EC2
## Comandos para desplegar Telito Bodeguero en AWS EC2

---

## 1. CONECTARSE A LA INSTANCIA EC2

Desde tu máquina local (Windows PowerShell o Git Bash):

```bash
# Conectarse a EC2 usando la clave .pem
ssh -i "ruta/a/tu-clave.pem" ec2-user@tu-ip-publica

# Ejemplo:
# ssh -i "C:\Users\Soporte\mi-clave.pem" ec2-user@54.123.45.67
```

---

## 2. INSTALAR DEPENDENCIAS EN EC2

Una vez conectado a EC2, ejecuta estos comandos:

### 2.1 Actualizar el sistema
```bash
sudo yum update -y
```

### 2.2 Instalar Java 17
```bash
# Instalar Java 17
sudo yum install -y java-17-amazon-corretto-devel

# Verificar instalación
java -version
```

### 2.3 Instalar Maven
```bash
# Instalar Maven
sudo yum install -y maven

# Verificar instalación
mvn -version
```

### 2.4 Instalar MySQL (si no está instalado)
```bash
# Instalar MySQL Server
sudo yum install -y mysql-server

# Iniciar MySQL
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Configurar MySQL (ejecutar y seguir las instrucciones)
sudo mysql_secure_installation
```

### 2.5 Instalar Git
```bash
# Instalar Git
sudo yum install -y git

# Verificar instalación
git --version
```

---

## 3. CONFIGURAR GIT EN EC2

```bash
# Configurar Git (ajustar con tus datos)
git config --global user.name "Tu Nombre"
git config --global user.email "tu-email@example.com"

# Si tu repositorio es privado, necesitarás configurar SSH o HTTPS
# Opción 1: Usar SSH (recomendado)
# Opción 2: Usar HTTPS con token de acceso personal
```

---

## 4. CLONAR O SUBIR EL PROYECTO

### Opción A: Clonar desde GitHub/GitLab
```bash
# Navegar al directorio home
cd ~

# Clonar el repositorio
git clone https://github.com/tu-usuario/TELITO_BODEGUERO.git
# O si usas SSH:
# git clone git@github.com:tu-usuario/TELITO_BODEGUERO.git

# Entrar al directorio del proyecto
cd TELITO_BODEGUERO
```

### Opción B: Subir proyecto desde tu máquina local
```bash
# En tu máquina local (PowerShell o Git Bash):
# 1. Asegúrate de tener Git inicializado
cd C:\Users\Soporte\TELITO_BODEGUERO
git init
git add .
git commit -m "Initial commit"

# 2. Crear repositorio en GitHub/GitLab y agregar remote
git remote add origin https://github.com/tu-usuario/TELITO_BODEGUERO.git
git push -u origin main

# 3. Luego en EC2, clonar como en Opción A
```

### Opción C: Transferir archivos directamente con SCP
```bash
# Desde tu máquina local (PowerShell o Git Bash):
scp -i "ruta/a/tu-clave.pem" -r C:\Users\Soporte\TELITO_BODEGUERO ec2-user@tu-ip-publica:~/
```

---

## 5. CONFIGURAR BASE DE DATOS EN EC2

```bash
# Conectarse a MySQL
sudo mysql -u root -p

# En el prompt de MySQL, ejecutar:
```

```sql
-- Crear base de datos
CREATE DATABASE telito_bodeguero CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Crear usuario (opcional, o usar root)
CREATE USER 'telito_user'@'localhost' IDENTIFIED BY 'tu_password_segura';
GRANT ALL PRIVILEGES ON telito_bodeguero.* TO 'telito_user'@'localhost';
FLUSH PRIVILEGES;

-- Salir de MySQL
EXIT;
```

```bash
# Importar el esquema de la base de datos
cd ~/TELITO_BODEGUERO
mysql -u root -p telito_bodeguero < telito_bodeguero.sql

# O si usas el usuario creado:
# mysql -u telito_user -p telito_bodeguero < telito_bodeguero.sql
```

---

## 6. CONFIGURAR APPLICATION.PROPERTIES PARA PRODUCCIÓN

```bash
# Crear archivo de propiedades de producción
cd ~/TELITO_BODEGUERO/src/main/resources
nano application-prod.properties
```

Contenido del archivo `application-prod.properties`:
```properties
# Configuración de Base de Datos Producción
spring.datasource.url=jdbc:mysql://localhost:3306/telito_bodeguero?useUnicode=true&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=tu_password_mysql
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# Configuración del servidor
server.port=8080
server.servlet.context-path=/

# Configuración de JSPs
spring.mvc.view.prefix=/
spring.mvc.view.suffix=.jsp

# Configuración de archivos estáticos
spring.web.resources.add-mappings=true
spring.web.resources.cache.period=3600

# Permitir sobrescritura de beans
spring.main.allow-bean-definition-overriding=true

# Configuración de correo
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=telitobodeguero@gmail.com
spring.mail.password=jjjk mscy txcq xhsr
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true

# Logging
logging.level.com.example.telito=INFO
logging.level.org.springframework.web=INFO
```

Guardar con `Ctrl+O`, `Enter`, `Ctrl+X`

---

## 7. COMPILAR EL PROYECTO

```bash
# Navegar al directorio del proyecto
cd ~/TELITO_BODEGUERO

# Limpiar y compilar el proyecto
mvn clean package -DskipTests

# El WAR se generará en: target/TELITO_BODEGUERO-1.0-SNAPSHOT.war
```

---

## 8. DESPLEGAR Y EJECUTAR LA APLICACIÓN

### Opción A: Ejecutar directamente con Java
```bash
cd ~/TELITO_BODEGUERO/target

# Ejecutar el WAR
java -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod
```

### Opción B: Usar el script start-app.sh
```bash
cd ~/TELITO_BODEGUERO

# Dar permisos de ejecución
chmod +x start-app.sh

# Copiar el WAR al directorio raíz (si el script lo requiere)
cp target/TELITO_BODEGUERO-1.0-SNAPSHOT.war .

# Ejecutar el script
./start-app.sh
```

### Opción C: Ejecutar en segundo plano con nohup
```bash
cd ~/TELITO_BODEGUERO/target

# Ejecutar en segundo plano y guardar logs
nohup java -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &

# Ver el proceso
ps aux | grep java

# Ver los logs
tail -f app.log
```

---

## 9. CONFIGURAR FIREWALL Y SEGURITY GROUPS

### En EC2 (Security Groups en AWS Console):
- Abrir puerto 8080 (o el que uses) para HTTP
- Abrir puerto 22 para SSH
- Opcional: puerto 443 para HTTPS

### En el servidor EC2 (si usas firewall local):
```bash
# Permitir puerto 8080
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

---

## 10. VERIFICAR QUE LA APLICACIÓN ESTÁ FUNCIONANDO

```bash
# Verificar que el proceso está corriendo
ps aux | grep java

# Verificar que el puerto está escuchando
sudo netstat -tlnp | grep 8080
# O con:
sudo ss -tlnp | grep 8080

# Probar desde el servidor
curl http://localhost:8080

# O desde tu navegador:
# http://tu-ip-publica:8080
```

---

## 11. CONFIGURAR COMO SERVICIO SYSTEMD (OPCIONAL)

Para que la aplicación se inicie automáticamente al reiniciar el servidor:

```bash
# Crear archivo de servicio
sudo nano /etc/systemd/system/telito-bodeguero.service
```

Contenido del archivo:
```ini
[Unit]
Description=Telito Bodeguero Application
After=network.target mysql.service

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/TELITO_BODEGUERO/target
ExecStart=/usr/bin/java -jar /home/ec2-user/TELITO_BODEGUERO/target/TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
# Recargar systemd
sudo systemctl daemon-reload

# Habilitar el servicio
sudo systemctl enable telito-bodeguero

# Iniciar el servicio
sudo systemctl start telito-bodeguero

# Ver estado
sudo systemctl status telito-bodeguero

# Ver logs
sudo journalctl -u telito-bodeguero -f
```

---

## 12. ACTUALIZAR EL PROYECTO (CUANDO HAY CAMBIOS)

```bash
# Conectarse a EC2
ssh -i "ruta/a/tu-clave.pem" ec2-user@tu-ip-publica

# Detener la aplicación actual
pkill -f TELITO_BODEGUERO
# O si usas systemd:
# sudo systemctl stop telito-bodeguero

# Navegar al proyecto
cd ~/TELITO_BODEGUERO

# Actualizar código desde Git
git pull origin main

# Recompilar
mvn clean package -DskipTests

# Reiniciar la aplicación
cd target
nohup java -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &
# O si usas systemd:
# sudo systemctl start telito-bodeguero
```

---

## COMANDOS ÚTILES ADICIONALES

```bash
# Ver logs de la aplicación
tail -f ~/TELITO_BODEGUERO/target/app.log

# Ver uso de recursos
top
htop  # Si está instalado

# Ver espacio en disco
df -h

# Ver memoria disponible
free -h

# Reiniciar MySQL
sudo systemctl restart mysqld

# Ver estado de MySQL
sudo systemctl status mysqld
```

---

## NOTAS IMPORTANTES

1. **Seguridad**: 
   - No expongas credenciales en el código
   - Usa variables de entorno para contraseñas sensibles
   - Considera usar AWS Secrets Manager

2. **Rendimiento**:
   - Ajusta las opciones de JVM según los recursos de tu instancia EC2
   - Para instancias pequeñas (t2.micro), usa las opciones del script `start-app.sh`

3. **Backups**:
   - Configura backups automáticos de la base de datos
   - Considera usar AWS RDS en lugar de MySQL local

4. **Dominio**:
   - Para usar un dominio personalizado, configura Route 53 o un proxy reverso (nginx)

---

## SOLUCIÓN DE PROBLEMAS

```bash
# Si la aplicación no inicia, verificar logs
tail -100 ~/TELITO_BODEGUERO/target/app.log

# Si hay problemas de conexión a BD
mysql -u root -p -e "SHOW DATABASES;"

# Si el puerto está ocupado
sudo lsof -i :8080

# Verificar permisos
ls -la ~/TELITO_BODEGUERO/target/TELITO_BODEGUERO-1.0-SNAPSHOT.war
```

---

**¡Listo!** Tu aplicación debería estar corriendo en `http://tu-ip-publica:8080`


