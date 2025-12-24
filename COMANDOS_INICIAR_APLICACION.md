# 🚀 Comandos para Iniciar la Aplicación en EC2

## 📋 Comandos Rápidos

### 1. Conectarse a EC2
```bash
ssh -i "ruta/a/tu-clave.pem" ec2-user@3.213.47.70
```

---

### 2. Verificar si la Aplicación está Corriendo
```bash
ps aux | grep TELITO_BODEGUERO
```

Si está corriendo, verás un proceso Java. Si no está corriendo, no verás nada.

---

### 3. Iniciar la Aplicación

```bash
# Ir al directorio del proyecto
cd ~/TELITO_BODEGUERO

# Si necesitas recompilar (después de cambios)
export MAVEN_OPTS="-Xmx512m -Xms256m"
mvn clean package -DskipTests

# Ir al directorio target
cd target

# Iniciar la aplicación en segundo plano
nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO.war --spring.profiles.active=prod > app.log 2>&1 &
```

---

### 4. Verificar que se Inició Correctamente

```bash
# Esperar 5 segundos
sleep 5

# Verificar proceso
ps aux | grep TELITO_BODEGUERO

# Ver logs (últimas 30 líneas)
tail -30 app.log
```

---

### 5. Ver Logs en Tiempo Real

```bash
# Desde el directorio target
cd ~/TELITO_BODEGUERO/target
tail -f app.log
```

Presiona `Ctrl+C` para salir.

---

### 6. Detener la Aplicación

```bash
# Detener proceso
pkill -f TELITO_BODEGUERO

# Verificar que se detuvo
ps aux | grep TELITO_BODEGUERO
```

---

## 🔄 Proceso Completo: Reiniciar Aplicación

```bash
# 1. Detener aplicación actual
pkill -f TELITO_BODEGUERO

# 2. Ir al directorio del proyecto
cd ~/TELITO_BODEGUERO

# 3. Si hay cambios, hacer pull y recompilar
git pull origin rama_modificaciones
export MAVEN_OPTS="-Xmx512m -Xms256m"
mvn clean package -DskipTests

# 4. Ir a target e iniciar
cd target
nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO.war --spring.profiles.active=prod > app.log 2>&1 &

# 5. Verificar que inició
sleep 5
ps aux | grep TELITO_BODEGUERO
tail -30 app.log
```

---

## 📊 Verificar Estado de Servicios

```bash
# Estado de la aplicación
ps aux | grep TELITO_BODEGUERO

# Estado de nginx
sudo systemctl status nginx

# Ver puertos abiertos
sudo netstat -tlnp | grep -E ':(80|443|8080)'

# Ver logs de nginx (si hay problemas)
sudo tail -f /var/log/nginx/telitobodeguero-error.log
```

---

## ⚡ Comandos Rápidos (Copy-Paste)

### Iniciar solo (si ya está compilado)
```bash
cd ~/TELITO_BODEGUERO/target && nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO.war --spring.profiles.active=prod > app.log 2>&1 & sleep 5 && ps aux | grep TELITO_BODEGUERO && tail -20 app.log
```

### Detener
```bash
pkill -f TELITO_BODEGUERO
```

### Ver logs
```bash
tail -f ~/TELITO_BODEGUERO/target/app.log
```

---

## 🔍 Troubleshooting

### Si la aplicación no inicia:

1. **Verificar logs de error:**
   ```bash
   tail -50 ~/TELITO_BODEGUERO/target/app.log
   ```

2. **Verificar que el puerto 8080 no esté ocupado:**
   ```bash
   sudo netstat -tlnp | grep 8080
   ```

3. **Verificar que Java esté instalado:**
   ```bash
   java -version
   ```

4. **Verificar que el WAR existe:**
   ```bash
   ls -lh ~/TELITO_BODEGUERO/target/*.war
   ```

5. **Verificar configuración de base de datos:**
   ```bash
   cat ~/TELITO_BODEGUERO/src/main/resources/application-prod.properties | grep spring.datasource
   ```

---

## 📝 Notas Importantes

- **Memoria:** La aplicación usa `-Xms32m -Xmx128m` (32MB inicial, 128MB máximo)
- **Perfil:** Siempre usar `--spring.profiles.active=prod`
- **Logs:** Se guardan en `~/TELITO_BODEGUERO/target/app.log`
- **Nginx:** Debe estar corriendo para que funcione HTTPS
- **Base de datos:** La aplicación se conecta a RDS automáticamente usando `application-prod.properties`

---

## ✅ Checklist de Inicio

- [ ] Conectado a EC2 vía SSH
- [ ] Nginx está corriendo (`sudo systemctl status nginx`)
- [ ] Aplicación compilada (si hubo cambios)
- [ ] Aplicación iniciada (`ps aux | grep TELITO_BODEGUERO`)
- [ ] Logs sin errores (`tail app.log`)
- [ ] Sitio accesible: `https://telitobodeguero.com`







