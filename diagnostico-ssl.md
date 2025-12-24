# Diagnóstico del error "No such authorization" de Certbot

## 🔍 Verificar puntos comunes

### 1. Verificar que el dominio apunta a tu IP
```bash
# En EC2, verificar qué IP tiene
curl ifconfig.me

# Verificar resolución DNS
dig telitobodeguero.com
nslookup telitobodeguero.com
```

El dominio debe apuntar a: `3.213.47.70`

### 2. Verificar que nginx esté corriendo y accesible
```bash
# Verificar estado de nginx
sudo systemctl status nginx

# Verificar que escuche en el puerto 80
sudo netstat -tlnp | grep :80
# o
sudo ss -tlnp | grep :80

# Verificar configuración de nginx
sudo nginx -t
```

### 3. Verificar que el puerto 80 sea accesible desde internet
```bash
# Desde tu máquina local (no EC2), prueba:
curl -I http://telitobodeguero.com

# O desde otro servidor/PC, intenta acceder a:
# http://3.213.47.70
```

### 4. Ver logs detallados de certbot
```bash
sudo certbot --nginx -d telitobodeguero.com -d www.telitobodeguero.com --non-interactive --agree-tos --email telitobodeguero@gmail.com --redirect -v
```

### 5. Ver logs de Let's Encrypt
```bash
sudo tail -100 /var/log/letsencrypt/letsencrypt.log
```

### 6. Verificar configuración actual de nginx
```bash
sudo cat /etc/nginx/conf.d/telitobodeguero.conf
```








