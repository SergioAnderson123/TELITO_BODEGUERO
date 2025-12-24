# Comandos Rápidos para EC2 - Telito Bodeguero

## 🚀 DESPLIEGUE RÁPIDO (Copiar y Pegar)

### 1. Conectarse a EC2
```bash
ssh -i "ruta/a/tu-clave.pem" ec2-user@tu-ip-publica
```

### 2. Instalar dependencias (solo la primera vez)
```bash
sudo yum update -y
sudo yum install -y java-17-amazon-corretto-devel maven mysql-server git
sudo systemctl start mysqld
sudo systemctl enable mysqld
```

### 3. Configurar base de datos (solo la primera vez)
```bash
sudo mysql -u root -p
# En MySQL:
CREATE DATABASE telito_bodeguero CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;

# Importar esquema
mysql -u root -p telito_bodeguero < telito_bodeguero.sql
```

### 4. Clonar o subir proyecto

**Opción A: Desde Git (recomendado)**
```bash
cd ~
git clone https://github.com/tu-usuario/TELITO_BODEGUERO.git
cd TELITO_BODEGUERO
```

**Opción B: Desde tu máquina local con SCP**
```bash
# Desde tu máquina local:
scp -i "ruta/a/tu-clave.pem" -r C:\Users\Soporte\TELITO_BODEGUERO ec2-user@tu-ip-publica:~/
```

### 5. Configurar aplicación de producción
```bash
cd ~/TELITO_BODEGUERO
nano src/main/resources/application-prod.properties
```

Pegar esta configuración (ajustar password de MySQL):
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/telito_bodeguero?useUnicode=true&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=TU_PASSWORD_MYSQL
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
server.port=8080
server.servlet.context-path=/
spring.mvc.view.prefix=/
spring.mvc.view.suffix=.jsp
spring.main.allow-bean-definition-overriding=true
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=telitobodeguero@gmail.com
spring.mail.password=jjjk mscy txcq xhsr
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
```

### 6. Desplegar con script automatizado
```bash
chmod +x deploy-ec2.sh
./deploy-ec2.sh
```

### 7. O desplegar manualmente
```bash
mvn clean package -DskipTests
cd target
nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &
```

### 8. Verificar que funciona
```bash
# Ver logs
tail -f target/app.log

# Ver proceso
ps aux | grep java

# Probar
curl http://localhost:8080
```

---

## 📝 COMANDOS ÚTILES

### Ver logs
```bash
tail -f ~/TELITO_BODEGUERO/target/app.log
```

### Detener aplicación
```bash
pkill -f TELITO_BODEGUERO
```

### Reiniciar aplicación
```bash
pkill -f TELITO_BODEGUERO
cd ~/TELITO_BODEGUERO/target
nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &
```

### Actualizar código desde Git
```bash
cd ~/TELITO_BODEGUERO
pkill -f TELITO_BODEGUERO
git pull origin main
./deploy-ec2.sh
```

### Ver estado de MySQL
```bash
sudo systemctl status mysqld
```

### Reiniciar MySQL
```bash
sudo systemctl restart mysqld
```

### Ver uso de recursos
```bash
top
htop  # Si está instalado
free -h
df -h
```

---

## 🔧 SOLUCIÓN DE PROBLEMAS

### La aplicación no inicia
```bash
# Ver logs de error
tail -100 ~/TELITO_BODEGUERO/target/app.log

# Verificar que el puerto no esté ocupado
sudo lsof -i :8080
```

### Error de conexión a base de datos
```bash
# Verificar que MySQL está corriendo
sudo systemctl status mysqld

# Probar conexión
mysql -u root -p -e "SHOW DATABASES;"
```

### Puerto 8080 no accesible
```bash
# Verificar Security Group en AWS Console
# Debe tener regla de entrada para puerto 8080 desde 0.0.0.0/0

# Verificar firewall local
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

---

## 🌐 ACCEDER A LA APLICACIÓN

Una vez desplegada, accede desde tu navegador:
```
http://tu-ip-publica-ec2:8080
```

Para obtener tu IP pública:
```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

---

**¡Listo!** Tu aplicación debería estar funcionando.


