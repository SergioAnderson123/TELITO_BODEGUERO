# 🧠 Recordatorio: Comandos para EC2

## 📍 VERIFICAR ESTADO ACTUAL

```bash
# Ver si la aplicación está corriendo
ps aux | grep TELITO_BODEGUERO

# Ver si el puerto 8080 está activo
sudo netstat -tlnp | grep 8080
# O:
sudo ss -tlnp | grep 8080

# Ver logs recientes
tail -50 ~/TELITO_BODEGUERO/target/app.log
```

---

## 🚀 INICIAR LA APLICACIÓN

### Opción 1: Inicio rápido (si ya está compilado)
```bash
cd ~/TELITO_BODEGUERO/target
nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &
```

### Opción 2: Compilar y luego iniciar
```bash
cd ~/TELITO_BODEGUERO
mvn clean package -DskipTests
cd target
nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &
```

### Opción 3: Usar el script de despliegue
```bash
cd ~/TELITO_BODEGUERO
chmod +x deploy-ec2.sh
./deploy-ec2.sh
```

---

## 🛑 DETENER LA APLICACIÓN

```bash
# Detener por nombre del proceso
pkill -f TELITO_BODEGUERO

# O encontrar el PID y matarlo
ps aux | grep TELITO_BODEGUERO
kill [PID]
```

---

## 📥 SINCRONIZAR CAMBIOS (Local → EC2)

### Si usas Git (RECOMENDADO):

**En tu máquina local:**
```bash
cd C:\Users\Soporte\TELITO_BODEGUERO
git add .
git commit -m "Descripción de cambios"
git push origin main
```

**En EC2:**
```bash
cd ~/TELITO_BODEGUERO
git pull origin main
# Luego recompilar y reiniciar
mvn clean package -DskipTests
pkill -f TELITO_BODEGUERO
cd target
nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &
```

### Si NO usas Git (SCP):

**Desde tu máquina local (PowerShell o Git Bash):**
```bash
# Subir archivos específicos
scp -i "ruta/a/tu-clave.pem" -r src/main/java/com/example/telito/* ec2-user@tu-ip-publica:~/TELITO_BODEGUERO/src/main/java/com/example/telito/

# Subir todo el proyecto (cuidado, sobrescribe)
scp -i "ruta/a/tu-clave.pem" -r C:\Users\Soporte\TELITO_BODEGUERO/* ec2-user@tu-ip-publica:~/TELITO_BODEGUERO/
```

**Luego en EC2:**
```bash
cd ~/TELITO_BODEGUERO
mvn clean package -DskipTests
pkill -f TELITO_BODEGUERO
cd target
nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &
```

---

## 📤 SINCRONIZAR CAMBIOS (EC2 → Local)

### Si usas Git:

**En EC2:**
```bash
cd ~/TELITO_BODEGUERO
git add .
git commit -m "Cambios en EC2"
git push origin main
```

**En tu máquina local:**
```bash
cd C:\Users\Soporte\TELITO_BODEGUERO
git pull origin main
```

### Si NO usas Git (SCP):

**Desde tu máquina local:**
```bash
# Descargar archivos específicos
scp -i "ruta/a/tu-clave.pem" -r ec2-user@tu-ip-publica:~/TELITO_BODEGUERO/src/main/java/com/example/telito/* C:\Users\Soporte\TELITO_BODEGUERO\src\main\java\com\example\telito\
```

---

## 🔍 VER QUÉ CAMBIOS HICISTE EN EC2

```bash
# Ver archivos modificados recientemente
find ~/TELITO_BODEGUERO/src -type f -mtime -7 -ls

# Ver diferencias si usas Git
cd ~/TELITO_BODEGUERO
git status
git diff

# Ver historial de comandos que ejecutaste
history | grep -i "mvn\|java\|telito"
```

---

## 📋 VERIFICAR TODO EL ESTADO

```bash
# Usar el script de verificación
cd ~/TELITO_BODEGUERO
chmod +x check-ec2-status.sh
./check-ec2-status.sh
```

---

## 🔧 COMANDOS DE MANTENIMIENTO

### Ver logs en tiempo real
```bash
tail -f ~/TELITO_BODEGUERO/target/app.log
```

### Ver uso de recursos
```bash
top
# Presiona 'q' para salir
```

### Ver espacio en disco
```bash
df -h
```

### Reiniciar MySQL
```bash
sudo systemctl restart mysqld
```

### Ver estado de MySQL
```bash
sudo systemctl status mysqld
```

---

## 🌐 ACCEDER A LA APLICACIÓN

```bash
# Obtener tu IP pública
curl http://169.254.169.254/latest/meta-data/public-ipv4

# Luego acceder desde navegador:
# http://tu-ip-publica:8080
```

---

## ⚠️ SI ALGO NO FUNCIONA

### La aplicación no inicia:
```bash
# Ver logs de error
tail -100 ~/TELITO_BODEGUERO/target/app.log

# Verificar que el puerto no esté ocupado
sudo lsof -i :8080
```

### Error de compilación:
```bash
# Limpiar y recompilar
cd ~/TELITO_BODEGUERO
mvn clean
mvn package -DskipTests
```

### Error de base de datos:
```bash
# Verificar que MySQL está corriendo
sudo systemctl status mysqld

# Probar conexión
mysql -u root -p -e "SHOW DATABASES;"
```

---

## 💡 TIP: Crear alias para comandos frecuentes

Agregar al `~/.bashrc`:
```bash
alias telito-start='cd ~/TELITO_BODEGUERO/target && nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &'
alias telito-stop='pkill -f TELITO_BODEGUERO'
alias telito-logs='tail -f ~/TELITO_BODEGUERO/target/app.log'
alias telito-status='ps aux | grep TELITO_BODEGUERO'
```

Luego ejecutar:
```bash
source ~/.bashrc
```

Y usar:
```bash
telito-start   # Iniciar
telito-stop    # Detener
telito-logs    # Ver logs
telito-status  # Ver estado
```















