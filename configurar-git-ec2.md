# 🔧 Configurar Git en EC2 (Solo la primera vez)

## Paso 1: Instalar Git (si no está instalado)

```bash
sudo yum install -y git
git --version
```

## Paso 2: Configurar tu identidad

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu-email@example.com"
```

## Paso 3: Clonar tu repositorio (solo la primera vez)

```bash
cd ~
git clone https://github.com/tu-usuario/TELITO_BODEGUERO.git
# O si usas SSH:
# git clone git@github.com:tu-usuario/TELITO_BODEGUERO.git

cd TELITO_BODEGUERO
```

## Paso 4: Si tu repositorio es PRIVADO

Necesitas configurar autenticación. Dos opciones:

### Opción A: Usar HTTPS con Token (Más fácil)

1. En GitHub: Settings → Developer settings → Personal access tokens → Generate new token
2. Guarda el token que te den
3. En EC2, cuando hagas `git pull`, te pedirá usuario y contraseña:
   - Usuario: tu usuario de GitHub
   - Contraseña: el token que generaste

### Opción B: Usar SSH (Más seguro)

1. Generar clave SSH en EC2:
```bash
ssh-keygen -t ed25519 -C "tu-email@example.com"
# Presiona Enter para aceptar la ubicación por defecto
# Presiona Enter dos veces para no poner contraseña (o ponle una)
```

2. Ver la clave pública:
```bash
cat ~/.ssh/id_ed25519.pub
```

3. Copiar el contenido y agregarlo a GitHub:
   - GitHub → Settings → SSH and GPG keys → New SSH key
   - Pega la clave pública

4. Clonar usando SSH:
```bash
git clone git@github.com:tu-usuario/TELITO_BODEGUERO.git
```

---

## ✅ Después de esto, el flujo es:

**En tu PC:**
```bash
git add .
git commit -m "Cambios"
git push
```

**En EC2:**
```bash
cd ~/TELITO_BODEGUERO
git pull  # ← Ya tienes los cambios!
mvn clean package -DskipTests
pkill -f TELITO_BODEGUERO
cd target
nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &
```








