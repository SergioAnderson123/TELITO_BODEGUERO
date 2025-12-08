# 📦 Documentación: Manejo de Stock en Telito Bodeguero

## 📋 Índice
1. [Arquitectura del Sistema de Stock](#arquitectura)
2. [Estructura de Datos](#estructura)
3. [Conceptos Clave](#conceptos)
4. [Flujos de Stock](#flujos)
5. [Cálculos y Conversiones](#calculos)
6. [Estados del Stock](#estados)
7. [Movimientos de Inventario](#movimientos)

---

## 🏗️ Arquitectura del Sistema de Stock {#arquitectura}

El sistema de stock está diseñado con una arquitectura de **dos niveles**:

### Nivel 1: Productos
- **Tabla**: `productos`
- **Propósito**: Define las características del producto
- **Stock a nivel producto**: Se calcula dinámicamente sumando el stock de todos sus lotes

### Nivel 2: Lotes
- **Tabla**: `lotes`
- **Propósito**: Almacena el stock físico real
- **Stock a nivel lote**: Se almacena en `stock_actual` (en unidades)

```
┌─────────────┐
│  PRODUCTO   │  (Define: SKU, nombre, unidades_por_paquete)
│             │
│  Stock:     │  = SUM(lotes.stock_actual)  [CALCULADO]
└──────┬──────┘
       │
       │ 1:N
       │
┌──────▼──────┐
│    LOTE     │  (Almacena: stock_actual, ubicación, fecha_vencimiento)
│             │
│  Stock:     │  = stock_actual  [ALMACENADO]
└─────────────┘
```

---

## 📊 Estructura de Datos {#estructura}

### Tabla: `productos`

```sql
CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    codigo_sku VARCHAR(50),
    nombre VARCHAR(255),
    unidades_por_paquete INT,  -- ⭐ CLAVE: Define conversión unidades ↔ paquetes
    stock_minimo INT,           -- Stock mínimo configurado
    precio_actual DECIMAL(10,2),
    productor_id INT,
    categoria_id INT,
    activo BOOLEAN
);
```

**Campos importantes para stock:**
- `unidades_por_paquete`: Define cuántas unidades hay en un paquete
- `stock_minimo`: Nivel mínimo de stock para alertas

### Tabla: `lotes`

```sql
CREATE TABLE lotes (
    id_lote INT PRIMARY KEY,
    codigo_lote VARCHAR(50),
    producto_id INT,
    stock_actual INT,           -- ⭐ ALMACENA EL STOCK REAL (en unidades)
    paquetes_disponibles INT,  -- Calculado: FLOOR(stock_actual / unidades_por_paquete)
    fecha_vencimiento DATE,
    ubicacion_id INT,
    distrito_id INT,
    estado VARCHAR(50),        -- 'No Registrado', 'Registrado'
    costo_produccion DECIMAL(10,2)
);
```

**Campos importantes:**
- `stock_actual`: **Stock real almacenado en UNIDADES**
- `paquetes_disponibles`: Calculado dinámicamente
- `estado`: Controla si el lote está en almacén o en producción

### Tabla: `movimientos_inventario`

```sql
CREATE TABLE movimientos_inventario (
    id_movimiento INT PRIMARY KEY,
    lote_id INT,
    tipo ENUM('Entrada', 'Salida', 'Ajuste'),
    cantidad INT,               -- En unidades
    motivo VARCHAR(255),
    fecha TIMESTAMP,
    usuario_id INT,
    pedido_id INT,
    orden_compra_id INT
);
```

---

## 🔑 Conceptos Clave {#conceptos}

### 1. Unidades vs Paquetes

El sistema maneja **dos unidades de medida**:

#### **Unidades** (Base de Datos)
- El stock se almacena **SIEMPRE en unidades** en `lotes.stock_actual`
- Todas las operaciones internas trabajan con unidades
- Ejemplo: Si un producto tiene 100 unidades, se almacena como `stock_actual = 100`

#### **Paquetes** (Visualización)
- Los paquetes se calculan dinámicamente: `paquetes = stock_actual / unidades_por_paquete`
- Se usa para visualización y operaciones comerciales
- Ejemplo: Si `unidades_por_paquete = 10` y `stock_actual = 100`, entonces `paquetes = 10`

**Fórmula de Conversión:**
```java
// De unidades a paquetes
paquetes = FLOOR(stock_actual / unidades_por_paquete)

// De paquetes a unidades
unidades = paquetes * unidades_por_paquete
```

### 2. Stock Total de un Producto

El stock total de un producto se calcula **sumando todos los lotes activos**:

```sql
SELECT COALESCE(SUM(l.stock_actual), 0) as stock_total
FROM lotes l
INNER JOIN productos p ON l.producto_id = p.id_producto
WHERE p.id_producto = ? 
  AND l.stock_actual > 0
  AND l.estado = 'Registrado'
```

**Implementación en código:**
```java
// ProductoDAO.java - Línea 14
"COALESCE(SUM(l.stock_actual), 0) as stock_total "
```

### 3. Estados de Lote

- **`No Registrado`**: Lote creado por productor, aún no está en almacén
- **`Registrado`**: Lote recibido y validado en almacén (tiene `ubicacion_id`)

---

## 🔄 Flujos de Stock {#flujos}

### 1. Entrada de Stock (Productor → Almacén)

#### Paso 1: Productor crea lote
```java
// ProductorServlet.java
// El productor ingresa cantidad en PAQUETES
int cantidadPaquetes = Integer.parseInt(request.getParameter("cantidadStock"));

// Se convierte a unidades
int unidadesPorPaquete = obtenerUnidadesPorPaquete(productoId);
int stockReal = cantidadPaquetes * unidadesPorPaquete;

// Se crea el lote con stock_actual en unidades
INSERT INTO lotes (stock_actual, ...) VALUES (stockReal, ...)
```

**Estado inicial**: `estado = 'No Registrado'`, `ubicacion_id = NULL`

#### Paso 2: Almacén recibe y registra
```java
// EntradaServlet.java
// Al recibir una orden de compra:
1. Se crea/actualiza el lote
2. Se asigna ubicacion_id
3. Se cambia estado a 'Registrado'
4. Se registra movimiento tipo 'Entrada'
```

**Estado final**: `estado = 'Registrado'`, `ubicacion_id = [ID]`

### 2. Salida de Stock (Almacén → Distribución)

#### Preparación de Pedido
```java
// PedidoServlet.java
// Se verifica stock disponible
int stockActual = lote.getStockActual();
int cantidadRequerida = cantidadPaquetes * unidadesPorPaquete;

if (stockActual >= cantidadRequerida) {
    // Se descuenta el stock
    int nuevoStock = stockActual - cantidadRequerida;
    loteDao.actualizarStock(idLote, nuevoStock);
    
    // Se registra movimiento tipo 'Salida'
    movimientoDao.registrarMovimiento(tipo='Salida', cantidad=cantidadRequerida);
}
```

### 3. Ajuste de Inventario

#### Conteo Físico
```java
// LoteServlet.java - guardarAjuste
int stockOriginal = lote.getStockActual();  // Stock en sistema
int cantidadContada = Integer.parseInt(request.getParameter("cantidadContada"));  // Stock físico

int diferencia = cantidadContada - stockOriginal;

if (diferencia != 0) {
    String tipoMovimiento = (diferencia > 0) ? "Entrada" : "Salida";
    
    // Se registra el movimiento
    movimientoDao.registrarMovimiento(
        tipo=tipoMovimiento,
        cantidad=Math.abs(diferencia),
        motivo="Ajuste de inventario: " + motivoAjuste
    );
    
    // Se actualiza el stock
    loteDao.actualizarStock(idLote, cantidadContada);
}
```

---

## 🧮 Cálculos y Conversiones {#calculos}

### Cálculo de Paquetes Disponibles

```java
// LoteDao.java - Línea 25
"FLOOR(l.stock_actual / p.unidades_por_paquete) AS paquetes_disponibles"
```

**Ejemplo:**
- `stock_actual = 127 unidades`
- `unidades_por_paquete = 10`
- `paquetes_disponibles = FLOOR(127 / 10) = 12 paquetes`
- **Nota**: Se pierden 7 unidades (no completan un paquete)

### Cálculo de Stock Total por Producto

```java
// ProductoDAO.java - Línea 14
"COALESCE(SUM(l.stock_actual), 0) as stock_total "
```

**Ejemplo:**
- Producto tiene 3 lotes:
  - Lote 1: `stock_actual = 100`
  - Lote 2: `stock_actual = 50`
  - Lote 3: `stock_actual = 25`
- **Stock total = 175 unidades**

### Validación de Stock Mínimo

```java
// AlertaDAO.java
// Verifica si el stock está por debajo del mínimo
"FLOOR(l.stock_actual / p.unidades_por_paquete) <= smc.stock_minimo_lote"
```

---

## 📈 Estados del Stock {#estados}

### Estados Calculados Dinámicamente

El sistema calcula el estado del stock basándose en:
1. Stock actual (en paquetes)
2. Stock mínimo configurado
3. Stock crítico configurado

```sql
CASE 
    WHEN smc.id_stock_minimo IS NULL THEN 'No configurado'
    WHEN FLOOR(l.stock_actual / p.unidades_por_paquete) = 0 THEN 'Sin Stock'
    WHEN FLOOR(l.stock_actual / p.unidades_por_paquete) <= smc.stock_critico_lote THEN 'Sin Stock'
    WHEN FLOOR(l.stock_actual / p.unidades_por_paquete) <= smc.stock_minimo_lote THEN 'Poco Stock'
    ELSE 'En Stock'
END AS estado_stock
```

**Estados posibles:**
- **`No configurado`**: No hay configuración de stock mínimo
- **`Sin Stock`**: Stock = 0 o por debajo del crítico
- **`Poco Stock`**: Stock por debajo del mínimo pero arriba del crítico
- **`En Stock`**: Stock normal

---

## 📝 Movimientos de Inventario {#movimientos}

### Tipos de Movimientos

1. **Entrada**
   - Cuando se recibe mercancía en almacén
   - Aumenta `stock_actual`
   - Relacionado con `orden_compra_id`

2. **Salida**
   - Cuando se despacha mercancía
   - Disminuye `stock_actual`
   - Relacionado con `pedido_id`

3. **Ajuste**
   - Corrección por conteo físico
   - Puede aumentar o disminuir `stock_actual`
   - Motivo: "Ajuste de inventario: [razón]"

### Registro de Movimientos

```java
// MovimientoDao.java
public void registrarMovimiento(Movimiento movimiento) {
    String sql = "INSERT INTO movimientos_inventario " +
                 "(lote_id, tipo, cantidad, motivo, usuario_id, pedido_id, orden_compra_id) " +
                 "VALUES (?, ?, ?, ?, ?, ?, ?)";
    
    // IMPORTANTE: La cantidad siempre se guarda en UNIDADES
    pstmt.setInt(3, movimiento.getCantidad());  // En unidades
}
```

**Flujo completo:**
1. Se actualiza `lotes.stock_actual`
2. Se registra en `movimientos_inventario`
3. Se puede consultar el historial completo

---

## 🔍 Consultas Importantes

### 1. Obtener Stock de un Producto

```sql
SELECT 
    p.id_producto,
    p.nombre,
    p.unidades_por_paquete,
    COALESCE(SUM(l.stock_actual), 0) as stock_total_unidades,
    COALESCE(SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)), 0) as stock_total_paquetes
FROM productos p
LEFT JOIN lotes l ON p.id_producto = l.producto_id 
    AND l.estado = 'Registrado' 
    AND l.stock_actual > 0
WHERE p.id_producto = ?
GROUP BY p.id_producto
```

### 2. Obtener Lotes Disponibles para un Producto

```sql
SELECT 
    l.id_lote,
    l.codigo_lote,
    l.stock_actual,
    FLOOR(l.stock_actual / p.unidades_por_paquete) as paquetes_disponibles,
    l.fecha_vencimiento,
    u.nombre as ubicacion
FROM lotes l
INNER JOIN productos p ON l.producto_id = p.id_producto
INNER JOIN ubicaciones u ON l.ubicacion_id = u.id_ubicacion
WHERE l.producto_id = ?
  AND l.stock_actual > 0
  AND l.estado = 'Registrado'
ORDER BY l.fecha_vencimiento ASC  -- FIFO: Primero los que vencen antes
```

### 3. Historial de Movimientos de un Lote

```sql
SELECT 
    m.tipo,
    m.cantidad,
    m.motivo,
    m.fecha,
    CONCAT(u.nombres, ' ', u.apellidos) as usuario
FROM movimientos_inventario m
INNER JOIN usuarios u ON m.usuario_id = u.id_usuario
WHERE m.lote_id = ?
ORDER BY m.fecha DESC
```

---

## ⚠️ Puntos Importantes

### 1. **Stock siempre en unidades**
- El campo `stock_actual` en la tabla `lotes` **SIEMPRE almacena unidades**
- Las conversiones a paquetes se hacen en tiempo de consulta

### 2. **Validación de stock antes de salidas**
- Siempre se verifica que haya stock suficiente antes de descontar
- Se valida tanto en unidades como en paquetes

### 3. **FIFO (First In, First Out)**
- Los lotes se ordenan por `fecha_vencimiento ASC` para usar primero los que vencen antes

### 4. **Separación Productor/Almacén**
- Lotes del productor: `ubicacion_id = NULL`, `estado = 'No Registrado'`
- Lotes del almacén: `ubicacion_id != NULL`, `estado = 'Registrado'`

### 5. **Trazabilidad completa**
- Todos los cambios de stock se registran en `movimientos_inventario`
- Se guarda: usuario, fecha, motivo, tipo de movimiento

---

## 📊 Ejemplo Completo

### Escenario: Productor registra lote

1. **Productor ingresa:**
   - Producto: "Arroz Premium"
   - Cantidad: **50 paquetes**
   - `unidades_por_paquete = 20`

2. **Sistema calcula:**
   ```java
   stock_actual = 50 * 20 = 1000 unidades
   ```

3. **Se crea lote:**
   ```sql
   INSERT INTO lotes (stock_actual, estado, ...) 
   VALUES (1000, 'No Registrado', ...)
   ```

4. **Almacén recibe:**
   - Asigna `ubicacion_id = 5`
   - Cambia `estado = 'Registrado'`
   - Registra movimiento tipo 'Entrada'

5. **Consulta de stock:**
   ```sql
   -- Stock total del producto
   SELECT SUM(stock_actual) FROM lotes WHERE producto_id = X
   -- Resultado: 1000 unidades = 50 paquetes
   ```

---

## 🔧 Archivos Clave del Sistema

### DAOs (Acceso a Datos)
- `LoteDao.java`: Operaciones con lotes
- `ProductoDAO.java`: Operaciones con productos
- `MovimientoDao.java`: Registro de movimientos

### Servlets (Lógica de Negocio)
- `ProductorServlet.java`: Registro de lotes por productor
- `EntradaServlet.java`: Recepción en almacén
- `PedidoServlet.java`: Preparación y salida de pedidos
- `LoteServlet.java`: Ajustes de inventario

### Beans (Modelos)
- `Lote.java`: Modelo de lote
- `Producto.java`: Modelo de producto
- `Movimiento.java`: Modelo de movimiento

---

## ✅ Resumen

1. **Stock se almacena en UNIDADES** en `lotes.stock_actual`
2. **Paquetes se calculan dinámicamente** dividiendo unidades entre `unidades_por_paquete`
3. **Stock total de producto** = Suma de todos los lotes activos
4. **Todos los cambios** se registran en `movimientos_inventario`
5. **Estados del stock** se calculan comparando con stock mínimo/crítico
6. **FIFO** se aplica ordenando por fecha de vencimiento

---

**Última actualización**: $(date)  
**Versión del Sistema**: 1.0

