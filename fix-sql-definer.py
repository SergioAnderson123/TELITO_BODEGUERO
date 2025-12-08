#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para limpiar DEFINER de vistas en archivo SQL
Elimina las referencias a DEFINER='root'@'localhost' que causan problemas en cPanel
"""

import sys
import re

def fix_sql_file(input_file, output_file):
    """
    Lee el archivo SQL y elimina las referencias a DEFINER='root'@'localhost'
    """
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Patrón 1: Eliminar DEFINER='root'@'localhost' completo
        # Busca: /*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
        pattern1 = r'/\*!50013\s+DEFINER=`root`@`localhost`\s+SQL SECURITY DEFINER\s+\*/'
        content = re.sub(pattern1, '/*!50013 SQL SECURITY DEFINER */', content)
        
        # Patrón 2: Eliminar DEFINER='root'@'localhost' en líneas CREATE
        # Busca: DEFINER=`root`@`localhost`
        pattern2 = r'DEFINER=`root`@`localhost`'
        content = re.sub(pattern2, '', content)
        
        # Limpiar espacios múltiples que puedan quedar
        content = re.sub(r'\s+', ' ', content)
        content = re.sub(r'\s+\*/', '*/', content)
        
        # Guardar el archivo corregido
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✓ Archivo corregido guardado en: {output_file}")
        print("✓ Todas las referencias a DEFINER='root'@'localhost' han sido eliminadas")
        return True
        
    except FileNotFoundError:
        print(f"✗ Error: No se encontró el archivo {input_file}")
        return False
    except Exception as e:
        print(f"✗ Error al procesar el archivo: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python fix-sql-definer.py <archivo_entrada.sql> [archivo_salida.sql]")
        print("Ejemplo: python fix-sql-definer.py base_datos.sql base_datos_fixed.sql")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else input_file.replace('.sql', '_fixed.sql')
    
    fix_sql_file(input_file, output_file)


