# 🔗 Conectar EC2 al Repositorio Git

## Tu repositorio: https://github.com/SergioAnderson123/TELITO_BODEGUERO.git

## Opción 1: Clonar el repositorio (Recomendado)

### Paso 1: Hacer backup de configuraciones importantes

```bash
# En EC2, guarda archivos que hayas modificado
cd ~/TELITO_BODEGUERO
mkdir ~/backup_config
cp src/main/resources/application-prod.properties ~/backup_config/ 2>/dev/null || true
cp src/main/resources/application.properties ~/backup_config/ 2>/dev/null || true
```

### Paso 2: Eliminar el directorio actual y clonar

```bash
cd ~
mv TELITO_BODEGUERO TELITO_BODEGUERO_backup  # Backup completo por si acaso
git clone https://github.com/SergioAnderson123/TELITO_BODEGUERO.git
cd TELITO_BODEGUERO
```

### Paso 3: Restaurar configuraciones si las tenías

```bash
# Si tenías application-prod.properties
cp ~/backup_config/application-prod.properties src/main/resources/ 2>/dev/null || true
```

### Paso 4: Verificar

```bash
git remote -v
# Debe mostrar:
# origin  https://github.com/SergioAnderson123/TELITO_BODEGUERO.git (fetch)
# origin  https://github.com/SergioAnderson123/TELITO_BODEGUERO.git (push)
```

---

## Opción 2: Convertir el directorio actual en repositorio Git

Si prefieres mantener el directorio actual:

```bash
cd ~/TELITO_BODEGUERO
git init
git remote add origin https://github.com/SergioAnderson123/TELITO_BODEGUERO.git
git fetch origin
git checkout -b main origin/main  # O master, depende de tu repo
```

**Nota:** Esta opción puede dar conflictos si hay diferencias entre lo que tienes y el repositorio.

---

## Después de cualquiera de las opciones:

```bash
# Verificar que está conectado
git remote -v

# Hacer pull para obtener los últimos cambios
git pull origin main
```








