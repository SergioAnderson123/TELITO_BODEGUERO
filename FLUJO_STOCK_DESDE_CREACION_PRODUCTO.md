
## 🎯 PASO 1: Crear el Producto

### Lo que haces:
1. Vas a "Mis Productos" → "+ Agregar Producto"
2. Ingresas:
   - **Nombre**: "arroz"
   - **SKU**: "SKU020"
   - **Categoría**: "Snacks"
   - **Precio**: S/ 8.00
   - **Unidades por paquete**: 200 unidades/paquete ⭐ (IMPORTANTE)

### Lo que pasa en la base de datos:
```sql
INSERT INTO productos (codigo_sku, nombre, unidades_por_paquete, precio_actual, ...)
VALUES ('SKU020', 'arroz', 200, 8.00, ...)
```

**Estado del stock en este momento:**
- ❌ **Stock = 0** (porque aún no hay lotes)
- ❌ **Lotes = 0**

---

## 🎯 PASO 2: Registrar un Lote

### Lo que haces:
1. Haces clic en "Ver" en la columna LOTES del producto "arroz"
2. O vas a "Registrar Lotes"
3. Ingresas:
   - **SKU del Producto**: "SKU020" (o seleccionas "arroz")
   - **Cantidad de Paquetes**: **10 paquetes** ⭐
   - **Fecha de caducidad**: 2025-11-24
   - **Distrito**: (seleccionas uno)

### Lo que pasa internamente:

```java
// 1. El sistema obtiene las unidades por paquete del producto
int unidadesPorPaquete = 200;  // Del producto "arroz"

// 2. Convierte paquetes a unidades
int cantidadPaquetes = 10;
int stockReal = cantidadPaquetes * unidadesPorPaquete;
// stockReal = 10 × 200 = 2,000 unidades

// 3. Genera código de lote automáticamente
String codigoLote = "L--0021";  // Generado automáticamente

// 4. Crea el lote en la base de datos
INSERT INTO lotes (
    codigo_lote, 
    producto_id, 
    stock_actual,      -- ⭐ 2,000 unidades (NO paquetes)
    fecha_vencimiento,
    estado,            -- 'No Registrado' (aún no está en almacén)
    ubicacion_id       -- NULL (aún no tiene ubicación en almacén)
) VALUES (
    'L--0021',
    [id_producto_arroz],
    2000,              -- ⭐ Stock almacenado en UNIDADES
    '2025-11-24',
    'No Registrado',
    NULL
)
```

**Estado del stock ahora:**
- ✅ **Stock del producto = 2,000 unidades** (suma de todos los lotes)
- ✅ **Paquetes disponibles = 10 paquetes** (2,000 ÷ 200)
- ✅ **Lotes = 1** (L--0021)

---

## 🎯 PASO 3: Ver el Resumen de Lotes (Modal que viste)

### Lo que haces:
1. En "Mis Productos", haces clic en el botón "Ver" en la columna LOTES
2. Se abre el modal "Resumen de Lotes del Producto"

### Lo que muestra el modal:

```
Producto: arroz

┌─────────────┬──────────────────────┬──────────────────────┬─────────┬──────────────────┐
│ CÓDIGO LOTE │ CANTIDAD INICIAL     │ CANTIDAD RESTANTE    │ % USADO │ FECHA VENCIMIENTO│
├─────────────┼──────────────────────┼──────────────────────┼─────────┼──────────────────┤
│ L--0021     │ 10 paquetes          │ 10 paquetes          │ 0.0%    │ 2025-11-24       │
│             │ (2,000 unidades)     │ (2,000 unidades)     │ usado   │                  │
└─────────────┴──────────────────────┴──────────────────────┴─────────┴──────────────────┘
```

### Cómo se calculan estos valores:

```java
// LoteDao.java - obtenerResumenCompletoLotesPorProducto()

// 1. Obtiene el stock actual del lote
int stockActual = 2000;  // En unidades (de la BD)

// 2. Calcula las salidas registradas (movimientos tipo 'Salida')
int salidasRegistradas = obtenerSalidasLote(idLote);
// Como es un lote nuevo, salidasRegistradas = 0

// 3. Calcula el stock inicial
int stockInicial = stockActual + salidasRegistradas;
// stockInicial = 2000 + 0 = 2000 unidades

// 4. Convierte a paquetes
int unidadesPorPaquete = 200;
int paquetesInicial = stockInicial / unidadesPorPaquete;
// paquetesInicial = 2000 / 200 = 10 paquetes

int paquetesRestante = stockActual / unidadesPorPaquete;
// paquetesRestante = 2000 / 200 = 10 paquetes

// 5. Calcula el porcentaje usado
double porcentajeUsado = ((stockInicial - stockActual) / stockInicial) * 100;
// porcentajeUsado = ((2000 - 2000) / 2000) * 100 = 0.0%
```

**Explicación:**
- **Cantidad Inicial**: Stock que tenía el lote cuando se creó (2,000 unidades = 10 paquetes)
- **Cantidad Restante**: Stock actual disponible (2,000 unidades = 10 paquetes)
- **% Usado**: Porcentaje que se ha consumido (0% porque no se ha usado nada)

---

## 🎯 PASO 4: ¿Qué pasa cuando se usa el stock?

### Escenario: Se despacha 3 paquetes

#### Lo que pasa:
1. Se crea un pedido que requiere **3 paquetes de arroz**
2. El sistema verifica stock disponible
3. Se descuenta del lote L--0021

#### Cálculo interno:

```java
// 1. Verifica stock disponible
int stockActual = 2000;  // unidades
int unidadesPorPaquete = 200;
int paquetesDisponibles = stockActual / unidadesPorPaquete;  // 10 paquetes

// 2. Valida que haya suficiente
int paquetesRequeridos = 3;
if (paquetesDisponibles >= paquetesRequeridos) {
    // ✅ Hay suficiente stock
    
    // 3. Calcula unidades a descontar
    int unidadesADescontar = paquetesRequeridos * unidadesPorPaquete;
    // unidadesADescontar = 3 × 200 = 600 unidades
    
    // 4. Actualiza el stock
    int nuevoStock = stockActual - unidadesADescontar;
    // nuevoStock = 2000 - 600 = 1400 unidades
    
    // 5. Actualiza en la base de datos
    UPDATE lotes 
    SET stock_actual = 1400 
    WHERE id_lote = [L--0021];
    
    // 6. Registra el movimiento
    INSERT INTO movimientos_inventario (
        lote_id, 
        tipo, 
        cantidad,      -- ⭐ 600 unidades (NO paquetes)
        motivo,
        pedido_id
    ) VALUES (
        [L--0021],
        'Salida',
        600,           -- ⭐ Siempre en unidades
        'Despacho de pedido',
        [id_pedido]
    );
}
```

#### Estado después del despacho:

```
┌─────────────┬──────────────────────┬──────────────────────┬─────────┬──────────────────┐
│ CÓDIGO LOTE │ CANTIDAD INICIAL     │ CANTIDAD RESTANTE    │ % USADO │ FECHA VENCIMIENTO│
├─────────────┼──────────────────────┼──────────────────────┼─────────┼──────────────────┤
│ L--0021     │ 10 paquetes          │ 7 paquetes           │ 30.0%   │ 2025-11-24       │
│             │ (2,000 unidades)     │ (1,400 unidades)     │ usado   │                  │
└─────────────┴──────────────────────┴──────────────────────┴─────────┴──────────────────┘
```

**Cálculo del % usado:**
```java
stockInicial = 2000 unidades
stockActual = 1400 unidades
unidadesUsadas = 2000 - 1400 = 600 unidades
porcentajeUsado = (600 / 2000) × 100 = 30.0%
```

---

## 📊 Resumen Visual del Flujo

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUJO COMPLETO DEL STOCK                     │
└─────────────────────────────────────────────────────────────────┘

1. CREAR PRODUCTO
   ┌─────────────┐
   │  Producto   │  unidades_por_paquete = 200
   │  "arroz"    │  stock = 0 (sin lotes aún)
   └─────────────┘
         │
         ▼
2. REGISTRAR LOTE
   ┌─────────────┐
   │   Lote      │  stock_actual = 2,000 unidades
   │  L--0021    │  = 10 paquetes × 200 unidades/paquete
   │             │  estado = 'No Registrado'
   └─────────────┘
         │
         ▼
3. ALMACÉN RECIBE
   ┌─────────────┐
   │   Lote      │  stock_actual = 2,000 unidades
   │  L--0021    │  estado = 'Registrado'
   │             │  ubicacion_id = [ID]
   └─────────────┘
         │
         ▼
4. VER RESUMEN (Modal)
   ┌─────────────────────────────────────┐
   │ Cantidad Inicial: 10 paq (2,000 un) │
   │ Cantidad Restante: 10 paq (2,000 un)│
   │ % Usado: 0.0%                       │
   └─────────────────────────────────────┘
         │
         ▼
5. DESPACHAR 3 PAQUETES
   ┌─────────────┐
   │   Lote      │  stock_actual = 1,400 unidades
   │  L--0021    │  = 7 paquetes × 200 unidades/paquete
   │             │  Movimiento: Salida 600 unidades
   └─────────────┘
         │
         ▼
6. VER RESUMEN ACTUALIZADO
   ┌─────────────────────────────────────┐
   │ Cantidad Inicial: 10 paq (2,000 un) │
   │ Cantidad Restante: 7 paq (1,400 un) │
   │ % Usado: 30.0%                      │
   └─────────────────────────────────────┘
```

---

## 🔑 Puntos Clave para Entender

### 1. **Stock siempre en unidades**
- En la base de datos: `stock_actual = 2000` (unidades)
- Nunca se almacena: `stock_actual = 10` (paquetes)

### 2. **Conversión dinámica**
- Paquetes = `stock_actual / unidades_por_paquete`
- Ejemplo: `2000 / 200 = 10 paquetes`

### 3. **Cantidad Inicial vs Restante**
- **Inicial**: Stock cuando se creó el lote (o stock actual + salidas)
- **Restante**: Stock disponible ahora
- **% Usado**: `(Inicial - Restante) / Inicial × 100`

### 4. **Cuando el lote es nuevo**
- Cantidad Inicial = Cantidad Restante (porque no hay salidas)
- % Usado = 0%

### 5. **Cuando se usa stock**
- Se descuenta en **unidades** de `stock_actual`
- Se registra movimiento tipo "Salida"
- El % usado aumenta

---

## 💡 Ejemplo Práctico Completo

### Estado Inicial (Lote Nuevo):
```
Producto: arroz
Lote: L--0021
├─ Stock Actual: 2,000 unidades
├─ Unidades por paquete: 200
├─ Paquetes: 10
├─ Cantidad Inicial: 2,000 unidades (10 paquetes)
├─ Cantidad Restante: 2,000 unidades (10 paquetes)
└─ % Usado: 0.0%
```

### Después de Despachar 3 Paquetes:
```
Producto: arroz
Lote: L--0021
├─ Stock Actual: 1,400 unidades  ⬇️ (2000 - 600)
├─ Unidades por paquete: 200
├─ Paquetes: 7  ⬇️ (10 - 3)
├─ Cantidad Inicial: 2,000 unidades (10 paquetes)  ← No cambia
├─ Cantidad Restante: 1,400 unidades (7 paquetes)  ⬇️
└─ % Usado: 30.0%  ⬆️ ((2000-1400)/2000 × 100)
```

### Después de Despachar Otros 4 Paquetes:
```
Producto: arroz
Lote: L--0021
├─ Stock Actual: 600 unidades  ⬇️ (1400 - 800)
├─ Unidades por paquete: 200
├─ Paquetes: 3  ⬇️ (7 - 4)
├─ Cantidad Inicial: 2,000 unidades (10 paquetes)  ← No cambia
├─ Cantidad Restante: 600 unidades (3 paquetes)  ⬇️
└─ % Usado: 70.0%  ⬆️ ((2000-600)/2000 × 100)
```

---

## 🎯 Conclusión

1. **Al crear producto**: Stock = 0 (no hay lotes)
2. **Al registrar lote**: Stock aumenta según cantidad de paquetes × unidades_por_paquete
3. **Cantidad Inicial**: Stock cuando se creó (o actual + salidas)
4. **Cantidad Restante**: Stock disponible ahora
5. **% Usado**: Muestra qué porcentaje del lote se ha consumido

**En tu caso específico (arroz, L--0021):**
- Tienes 10 paquetes iniciales (2,000 unidades)
- Aún tienes 10 paquetes restantes (2,000 unidades)
- 0% usado porque no se ha despachado nada aún

¿Te queda claro? ¿Quieres que explique algún otro aspecto del flujo?

