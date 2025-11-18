# Problemas Identificados en Zonas y Distritos

## Resumen de Problemas

Basado en el análisis de las imágenes de la base de datos, se han identificado los siguientes problemas:

---

## 🔴 PROBLEMAS EN ZONAS

### 1. Zonas Duplicadas
- **"Norte"** aparece en `idZona` **1** y **11** ❌
- **"Sur"** aparece en `idZona` **2** y **12** ❌
- **"Este"** aparece en `idZona` **3** y **13** ❌
- **"Oeste"** aparece en `idZona` **4** y **14** ❌

**Solución**: Mantener solo las zonas con `idZona` 1, 2, 3, 4 y eliminar los duplicados (11, 12, 13, 14).

### 2. Zonas Incorrectas (No Requeridas)
Las siguientes zonas **NO** están en los requerimientos y deben eliminarse:
- `idZona` 5: **Centro** ❌
- `idZona` 6: **Altiplano** ❌
- `idZona` 7: **Costa** ❌
- `idZona` 8: **Sierra** ❌
- `idZona` 9: **Selva** ❌
- `idZona` 10: **Metropolitana** ❌

**Solución**: Eliminar todas estas zonas. Solo deben existir: Norte, Sur, Este, Oeste.

---

## 🔴 PROBLEMAS EN DISTRITOS

### 1. Distritos Duplicados
- **"Cercado de Lima"** aparece en `idDistrito` **13** y **48** ❌
- **"Cercado"** (idDistrito 21) parece ser duplicado de "Cercado de Lima" ❌

**Solución**: Mantener solo "Cercado de Lima" con el `idDistrito` más bajo y eliminar duplicados.

### 2. Distritos Incorrectos (Fuera de Lima)
Los siguientes distritos **NO** son de Lima y deben eliminarse:
- **Ica** (idDistrito 14) ❌
- **Arequipa** (idDistrito 15) ❌
- **Cusco** (idDistrito 16) ❌
- **Puno** (idDistrito 17) ❌
- **Trujillo** (idDistrito 18) ❌
- **Chiclayo** (idDistrito 19) ❌
- **Tarapoto** (idDistrito 20) ❌
- **Callao** (idDistrito 5) ❌

**Solución**: Eliminar todos estos distritos. Solo deben existir los 41 distritos de Lima especificados en los requerimientos.

### 3. Distritos con `zona_id` Incorrecto
Algunos distritos están asignados a zonas incorrectas o a zonas que serán eliminadas:
- Distritos asignados a `zona_id` 5, 6, 7, 8, 9, 10 (zonas incorrectas)
- Distritos asignados a `zona_id` 11, 12, 13, 14 (zonas duplicadas)

**Solución**: Reasignar todos los distritos a las zonas correctas (1, 2, 3, 4) según su ubicación geográfica.

---

## ✅ DISTRIBUCIÓN CORRECTA ESPERADA

### NORTE (zona_id = 1) - 8 distritos:
1. Ancon
2. Santa Rosa
3. Carabayllo
4. Puente Piedra
5. Comas
6. Los Olivos
7. San Martín de Porres
8. Independencia

### SUR (zona_id = 2) - 10 distritos:
1. San Juan de Miraflores
2. Villa María del Triunfo
3. Villa el Salvador
4. Pachacamac
5. Lurin
6. Punta Hermosa
7. Punta Negra
8. San Bartolo
9. Santa María del Mar
10. Pucusana

### ESTE (zona_id = 3) - 7 distritos:
1. San Juan de Lurigancho
2. Lurigancho (Chosica)
3. Ate
4. El Agustino
5. Santa Anita
6. La Molina
7. Cieneguilla

### OESTE (zona_id = 4) - 16 distritos:
1. Rimac
2. Cercado de Lima
3. Breña
4. Pueblo Libre
5. Magdalena
6. Jesus María
7. La Victoria
8. Lince
9. San Isidro
10. San Miguel
11. Surquillo
12. San Borja
13. Santiago de Surco
14. Barranco
15. Chorrillos
16. San Luis
17. Miraflores

**Total**: 41 distritos

---

## 📋 PASOS PARA SOLUCIONAR

### Paso 1: Análisis Previo
```sql
-- Ejecutar primero para ver qué se va a eliminar
source database/analizar_zonas_distritos.sql
```

### Paso 2: Backup (Recomendado)
```sql
-- Crear backup antes de eliminar
CREATE TABLE distritos_backup AS SELECT * FROM distritos;
CREATE TABLE zonas_backup AS SELECT * FROM zonas;
```

### Paso 3: Limpieza
```sql
-- Ejecutar script de limpieza
source database/limpiar_zonas_distritos.sql
```

### Paso 4: Verificación
```sql
-- Verificar que solo queden 4 zonas
SELECT * FROM zonas ORDER BY idZona;

-- Verificar que haya 41 distritos
SELECT COUNT(*) FROM distritos;

-- Verificar distribución por zona
SELECT z.nombre, COUNT(d.idDistrito) as total
FROM zonas z
LEFT JOIN distritos d ON z.idZona = d.zona_id
GROUP BY z.idZona, z.nombre;
```

---

## ⚠️ ADVERTENCIAS

1. **Referencias en otras tablas**: Antes de eliminar distritos, verificar si hay referencias en:
   - Tabla `lotes` (campo `distrito_id`)
   - Otras tablas que puedan referenciar distritos

2. **Reasignación de distritos**: Los distritos que estaban en zonas incorrectas serán reasignados automáticamente según su nombre.

3. **IDs de zonas**: Después de la limpieza, solo deben existir `idZona` 1, 2, 3, 4.

4. **Integridad referencial**: El script maneja las claves foráneas, pero es recomendable verificar que no haya errores.

---

## 📁 Archivos Creados

1. **`database/analizar_zonas_distritos.sql`**: Script de análisis (NO elimina nada)
2. **`database/limpiar_zonas_distritos.sql`**: Script de limpieza (ELIMINA duplicados e incorrectos)
3. **`database/zonas_distritos_completos.sql`**: Script para insertar todos los distritos requeridos (si faltan)

---

## 🎯 Resultado Esperado

Después de ejecutar los scripts:
- ✅ Solo 4 zonas: Norte (1), Sur (2), Este (3), Oeste (4)
- ✅ Exactamente 41 distritos de Lima
- ✅ Sin duplicados
- ✅ Sin distritos fuera de Lima
- ✅ Todos los distritos correctamente asignados a sus zonas

