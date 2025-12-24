# Configurar HTTPS (SSL) para telitobodeguero.com

## 🔒 Usando Let's Encrypt (Gratis)

### Prerequisitos
1. ✅ El dominio `telitobodeguero.com` debe apuntar a tu IP de EC2: `3.213.47.70`
2. ✅ El Security Group debe permitir tráfico en:
   - Puerto **80** (HTTP) - para la validación
   - Puerto **443** (HTTPS) - para el tráfico SSL
3. ✅ Nginx debe estar corriendo y configurado correctamente

---

## 📋 Pasos en EC2

### Paso 1: Configurar Security Group (si no lo hiciste)

En AWS Console → EC2 → Security Groups:

**Agregar regla para HTTPS:**
- **Type:** HTTPS
- **Port:** 443
- **Source:** 0.0.0.0/0
- **Description:** HTTPS access

---

### Paso 2: Instalar Certbot

```bash
sudo yum install -y certbot python3-certbot-nginx
```

---

### Paso 3: Obtener certificado SSL

**Opción A: Automático (recomendado)**
```bash
sudo certbot --nginx -d telitobodeguero.com -d www.telitobodeguero.com \
  --non-interactive \
  --agree-tos \
  --email telitobodeguero@gmail.com \
  --redirect
```

Este comando:
- Obtiene el certificado SSL
- Configura nginx automáticamente
- Redirige HTTP a HTTPS automáticamente

**Opción B: Interactivo**
```bash
sudo certbot --nginx -d telitobodeguero.com -d www.telitobodeguero.com
```

Sigue las instrucciones en pantalla.

---

### Paso 4: Verificar que funciona

```bash
# Verificar estado de nginx
sudo systemctl status nginx

# Ver la nueva configuración
sudo cat /etc/nginx/conf.d/telitobodeguero.conf
```

Ahora deberías poder acceder a:
- ✅ `https://telitobodeguero.com`
- ✅ `https://www.telitobodeguero.com`
- ✅ `http://telitobodeguero.com` (redirige a HTTPS)

---

### Paso 5: Configurar renovación automática

Let's Encrypt renueva automáticamente el certificado cada 90 días. Verifica que funcione:

```bash
sudo certbot renew --dry-run
```

Si ves "Congratulations", la renovación automática está configurada correctamente.

---

## 🔧 Comandos útiles

```bash
# Ver certificados instalados
sudo certbot certificates

# Renovar certificado manualmente
sudo certbot renew

# Ver logs de certbot
sudo tail -f /var/log/letsencrypt/letsencrypt.log

# Revocar certificado (si es necesario)
sudo certbot revoke --cert-path /etc/letsencrypt/live/telitobodeguero.com/cert.pem

# Ver configuración de nginx después de certbot
sudo cat /etc/nginx/conf.d/telitobodeguero.conf
```

---

## 📝 Notas importantes

1. **Renovación automática:** Certbot configura un cron job automáticamente. Los certificados de Let's Encrypt duran 90 días y se renuevan automáticamente.

2. **Email de notificación:** Let's Encrypt enviará emails a `telitobodeguero@gmail.com` antes de que expire el certificado si hay problemas con la renovación.

3. **Validación:** Let's Encrypt necesita validar que eres el dueño del dominio. Lo hace accediendo a `http://telitobodeguero.com/.well-known/acme-challenge/`. Por eso necesitas que:
   - El dominio apunte a tu IP
   - El puerto 80 esté abierto
   - Nginx esté corriendo

4. **Renovación automática:** Los certificados se renuevan automáticamente, pero verifica periódicamente:
   ```bash
   sudo certbot renew --dry-run
   ```

---

## 🚨 Troubleshooting

### Error: "Failed to connect to host for DVSNI challenge"

**Causa:** El dominio no apunta a tu IP o el puerto 80 está bloqueado.

**Solución:**
1. Verifica que el DNS esté configurado: `dig telitobodeguero.com` o `nslookup telitobodeguero.com`
2. Verifica que el Security Group permita tráfico en el puerto 80

### Error: "The nginx plugin is not working"

**Causa:** Nginx no está corriendo o hay un error en la configuración.

**Solución:**
```bash
sudo systemctl start nginx
sudo nginx -t
```

### El certificado expiró

**Solución:**
```bash
sudo certbot renew
sudo systemctl reload nginx
```

---

## ✅ Verificación final

Después de configurar HTTPS:

1. ✅ Accede a `https://telitobodeguero.com` - debe mostrar el candado verde
2. ✅ Accede a `http://telitobodeguero.com` - debe redirigir a HTTPS
3. ✅ Verifica el certificado en el navegador - debe mostrar "Válido" y "Let's Encrypt"

---

## 🎯 Resultado esperado

Tu aplicación estará accesible en:
- 🔒 `https://telitobodeguero.com` (principal)
- 🔒 `https://www.telitobodeguero.com` (alternativo)
- 🔄 `http://telitobodeguero.com` → redirige a HTTPS
- 🔄 `http://www.telitobodeguero.com` → redirige a HTTPS

¡Listo! Tu sitio ahora tiene HTTPS configurado y seguro. 🎉








