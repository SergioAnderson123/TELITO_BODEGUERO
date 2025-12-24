# Configurar Nginx para eliminar el puerto 8080

## 📋 Pasos en EC2

### Opción 1: Ejecutar el script automático

```bash
# Desde tu máquina local, subir el script
scp -i "ruta/a/tu-clave.pem" configurar-nginx-ec2.sh ec2-user@3.213.47.70:~/

# Conectarse a EC2
ssh -i "ruta/a/tu-clave.pem" ec2-user@3.213.47.70

# En EC2, ejecutar el script
chmod +x configurar-nginx-ec2.sh
./configurar-nginx-ec2.sh
```

### Opción 2: Ejecutar comandos manualmente

```bash
# 1. Instalar nginx
sudo yum update -y
sudo yum install -y nginx

# 2. Crear archivo de configuración
sudo nano /etc/nginx/conf.d/telitobodeguero.conf
```

Pegar esta configuración:
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
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    access_log /var/log/nginx/telitobodeguero-access.log;
    error_log /var/log/nginx/telitobodeguero-error.log;
}
```

Guardar con `Ctrl+O`, `Enter`, `Ctrl+X`

```bash
# 3. Verificar que la configuración es correcta
sudo nginx -t

# 4. Iniciar nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# 5. Verificar estado
sudo systemctl status nginx
```

---

## ⚠️ IMPORTANTE: Configurar Security Group

Asegúrate de que el Security Group de tu EC2 permita tráfico HTTP (puerto 80):

1. Ve a AWS Console → EC2 → Security Groups
2. Selecciona el Security Group de tu instancia
3. Inbound Rules → Edit inbound rules
4. Agregar regla:
   - **Type:** HTTP
   - **Port:** 80
   - **Source:** 0.0.0.0/0 (o tu IP específica)
   - **Description:** HTTP access

---

## ✅ Verificación

Después de configurar:

1. **Verificar nginx está corriendo:**
   ```bash
   sudo systemctl status nginx
   ```

2. **Verificar que tu app sigue corriendo en 8080:**
   ```bash
   ps aux | grep TELITO_BODEGUERO
   ```

3. **Ver logs de nginx si hay problemas:**
   ```bash
   sudo tail -f /var/log/nginx/telitobodeguero-error.log
   ```

4. **Acceder a tu sitio:**
   - `http://telitobodeguero.com` (sin puerto)
   - Debería funcionar igual que `http://telitobodeguero.com:8080`

---

## 🔧 Comandos útiles

```bash
# Reiniciar nginx
sudo systemctl restart nginx

# Ver logs en tiempo real
sudo tail -f /var/log/nginx/telitobodeguero-access.log
sudo tail -f /var/log/nginx/telitobodeguero-error.log

# Recargar configuración sin reiniciar
sudo nginx -s reload

# Detener nginx
sudo systemctl stop nginx
```

---

## 📝 Notas

- Tu aplicación Spring Boot seguirá corriendo en el puerto **8080**
- Nginx escuchará en el puerto **80** y redirigirá las peticiones a **8080**
- No necesitas cambiar nada en `application-prod.properties`
- Si más adelante quieres HTTPS, puedes configurar SSL en nginx fácilmente








