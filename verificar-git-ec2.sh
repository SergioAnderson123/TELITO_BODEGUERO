#!/bin/bash

# Script para verificar si EC2 está conectado al repositorio Git

echo "=========================================="
echo "  Verificando conexión Git en EC2"
echo "=========================================="
echo ""

# Verificar si existe el directorio del proyecto
if [ ! -d ~/TELITO_BODEGUERO ]; then
    echo "❌ No existe el directorio ~/TELITO_BODEGUERO"
    echo ""
    echo "Necesitas clonar el repositorio primero:"
    echo "  cd ~"
    echo "  git clone https://github.com/tu-usuario/TELITO_BODEGUERO.git"
    exit 1
fi

cd ~/TELITO_BODEGUERO

# Verificar si es un repositorio Git
if [ ! -d .git ]; then
    echo "❌ No es un repositorio Git"
    echo ""
    echo "Este directorio no tiene Git inicializado."
    echo "Necesitas clonarlo desde GitHub/GitLab:"
    echo "  cd ~"
    echo "  rm -rf TELITO_BODEGUERO"
    echo "  git clone https://github.com/tu-usuario/TELITO_BODEGUERO.git"
    exit 1
fi

echo "✓ Es un repositorio Git"
echo ""

# Verificar remotes
echo "📍 Repositorios remotos configurados:"
git remote -v

if [ -z "$(git remote -v)" ]; then
    echo ""
    echo "❌ No hay repositorios remotos configurados"
    echo ""
    echo "Necesitas agregar el remote:"
    echo "  git remote add origin https://github.com/tu-usuario/TELITO_BODEGUERO.git"
    exit 1
fi

echo ""
echo "✓ Repositorio remoto configurado"
echo ""

# Probar conexión (opcional, solo si tienes credenciales)
echo "🔍 Verificando estado del repositorio..."
git status

echo ""
echo "=========================================="
echo "✅ Git está configurado correctamente"
echo "=========================================="
echo ""
echo "Puedes hacer:"
echo "  git pull origin main    # Descargar cambios"
echo "  git status              # Ver estado"
echo "  git log --oneline -5    # Ver últimos commits"








