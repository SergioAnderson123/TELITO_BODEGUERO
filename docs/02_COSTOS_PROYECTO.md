# ANÁLISIS DE COSTOS DEL PROYECTO
## Telito Bodeguero

---

## 1. RESUMEN EJECUTIVO DE COSTOS

**Presupuesto Asignado:** $50 USD  
**Costo Total Estimado (4 meses sin Free Tier):** $105.60 USD  
**Costo Total Estimado (4 meses con Free Tier):** $0-15 USD  
**Déficit (sin Free Tier):** $55.60 USD  
**Déficit (con Free Tier):** $0 USD (dentro del presupuesto)

---

## 2. COSTOS DE INFRAESTRUCTURA (AWS)

### 2.1 Desglose de Costos Mensuales

| Servicio | Especificación | Costo Mensual (USD) | Free Tier | Descripción |
|----------|----------------|---------------------|-----------|------------|
| **EC2 Instance** | t2.micro (1 vCPU, 1GB RAM) | $8.50 | ✅ 750 hrs/mes | Instancia básica elegible para free tier |
| **RDS MySQL** | db.t2.micro (1 vCPU, 1GB RAM) | $15.00 | ✅ 750 hrs/mes | Base de datos pequeña elegible para free tier |
| **EBS Storage** | 20 GB | $2.00 | ✅ 20 GB gratis | Almacenamiento persistente |
| **Data Transfer** | 10 GB | $0.90 | ✅ 1 GB gratis | Tráfico de salida de datos |
| **TOTAL MENSUAL (Sin Free Tier)** | | **$26.40** | | |
| **TOTAL MENSUAL (Con Free Tier)** | | **$0-3.00** | | Solo almacenamiento y tráfico adicional |

### 2.2 Cálculo para 4 Meses

**Sin Free Tier:**
```
Costo mensual:     $26.40
Duración:           4 meses
─────────────────────────────
Costo total:       $105.60 USD
```

**Con Free Tier (primer año):**
```
Costo mensual:     $0-3.00
Duración:           4 meses
─────────────────────────────
Costo total:       $0-15.00 USD
```

### 2.3 Comparación con Presupuesto

**Sin Free Tier:**
```
Presupuesto asignado:    $50.00 USD
Costo total estimado:    $105.60 USD
─────────────────────────────────────
Déficit:                 $55.60 USD
```

**Con Free Tier (Recomendado):**
```
Presupuesto asignado:    $50.00 USD
Costo total estimado:    $0-15.00 USD
─────────────────────────────────────
Déficit:                 $0 USD (dentro del presupuesto)
```

---

## 3. ESTRATEGIAS DE OPTIMIZACIÓN DE COSTOS

### 3.1 Reducción de Costos en EC2

**Opción 1: Usar Free Tier de AWS (RECOMENDADO)**
- EC2 t2.micro: 750 horas/mes gratis por 12 meses
- Ahorro: $8.50/mes × 12 = $102/año
- Ventaja: Ideal para proyectos académicos

**Opción 2: MySQL en EC2 en lugar de RDS**
- Instalar MySQL directamente en la instancia EC2
- Ahorro: ~$15/mes (solo pagar por EC2)
- Requiere más gestión manual pero reduce costos significativamente

**Opción 3: Usar instancias Spot**
- Hasta 90% de descuento sobre precio on-demand
- Adecuadas para desarrollo/pruebas
- Pueden ser interrumpidas, no recomendado para producción

**Opción 4: Apagar instancias cuando no se usen**
- Detener instancias EC2 cuando no estén en uso
- Solo pagar por almacenamiento EBS ($0.10/GB-mes)
- Ahorro significativo en desarrollo

### 3.2 Reducción de Costos en RDS

**Opción 1: Usar Free Tier de AWS**
- RDS db.t2.micro: 750 horas/mes gratis por 12 meses
- Ahorro: $15/mes × 12 = $180/año

**Opción 2: MySQL en EC2**
- Instalar MySQL en la misma instancia EC2
- Ahorro: $15/mes completo
- Requiere configuración y mantenimiento manual

**Opción 3: Optimizar consultas**
- Reducir uso de recursos mediante optimización
- Implementar índices adecuados
- Usar caché cuando sea posible

### 3.3 Uso de Free Tier y Créditos

**Free Tier de AWS (12 meses):**
- EC2 t2.micro: 750 horas/mes gratis
- RDS db.t2.micro: 750 horas/mes gratis
- EBS: 20 GB de almacenamiento gratis
- Data Transfer: 1 GB de salida gratis/mes
- **Total ahorrado: ~$300/año**

**AWS Educate:**
- Créditos adicionales para estudiantes
- Acceso a servicios educativos
- Requiere registro como estudiante

**AWS Activate:**
- Para startups y estudiantes
- Créditos adicionales disponibles

### 3.4 Optimización de Recursos

**Estrategias:**
1. **Apagar instancias cuando no se usen** (desarrollo)
   - Detener EC2: solo pagar almacenamiento
   - Ahorro: ~$8.50/mes por instancia detenida

2. **Usar instancias Spot** para desarrollo/pruebas
   - Hasta 90% de descuento
   - No recomendado para producción

3. **Optimizar tamaño de base de datos**
   - Limpiar datos antiguos
   - Comprimir tablas grandes
   - Usar particionamiento

4. **Comprimir archivos almacenados**
   - Reducir uso de EBS
   - Usar S3 para archivos grandes (más económico)

5. **Limitar tráfico de red**
   - Optimizar tamaño de respuestas
   - Usar CDN para recursos estáticos
   - Comprimir datos en tránsito

---

## 4. COSTOS DE DESARROLLO

### 4.1 Software y Herramientas

| Concepto | Costo | Notas |
|----------|-------|-------|
| **Licencias de Software** | $0 | Uso de tecnologías open source |
| **IDE** | $0 | IntelliJ IDEA Community (gratuito) |
| **Control de Versiones** | $0 | GitHub gratuito para proyectos académicos |
| **Base de Datos** | Incluido | MySQL en Cloud SQL (incluido en costos GCP) |
| **TOTAL DESARROLLO** | **$0** | |

### 4.2 Tiempo de Desarrollo

**Estimación de horas:**
- Desarrollo: ~320 horas (4 meses × 4 semanas × 20 horas/semana)
- Testing: ~80 horas
- Documentación: ~40 horas
- **Total:** ~440 horas

**Costo de desarrollo (si fuera comercial):**
- Tarifa promedio desarrollador junior: $20-30/hora
- Costo estimado: $8,800 - $13,200 USD
- **Nota:** Este es un proyecto académico, no hay costo real

---

## 5. PROYECCIÓN DE COSTOS A LARGO PLAZO

### 5.1 Escenarios de Uso

| Escenario | Costo Mensual | Descripción |
|-----------|---------------|-------------|
| **Desarrollo/Pruebas** | $15-20 | Instancias pequeñas, uso mínimo |
| **Producción Baja** | $30-50 | 1 instancia pequeña + BD pequeña, <100 usuarios |
| **Producción Media** | $80-120 | 2 instancias + BD mediana, 100-500 usuarios |
| **Producción Alta** | $200+ | Múltiples instancias + BD grande + Load Balancer, >500 usuarios |

### 5.2 Factores que Afectan el Costo

1. **Número de usuarios concurrentes**
2. **Volumen de datos almacenados**
3. **Tráfico de red**
4. **Uso de almacenamiento**
5. **Backups y redundancia**

---

## 6. ANÁLISIS DE ALTERNATIVAS

### 6.1 Comparación de Plataformas Cloud

| Plataforma | Costo Mensual Estimado | Free Tier | Ventajas | Desventajas |
|------------|------------------------|-----------|----------|-------------|
| **Amazon Web Services** | $26-30 (sin Free Tier) | ✅ 12 meses | Free Tier generoso, amplia gama de servicios | Curva de aprendizaje |
| **Google Cloud Platform** | $15-20 | ✅ $300 créditos | Créditos gratuitos, buena integración | Menos servicios que AWS |
| **Microsoft Azure** | $15-22 | ✅ $200 créditos | Integración con Office | Más caro para este caso |
| **Heroku** | $7-25 | ⚠️ Limitado | Fácil despliegue | Limitaciones en recursos gratuitos |

### 6.2 Opciones de Hosting Alternativas

**Opción 1: VPS Compartido**
- Costo: $5-10/mes
- Ventaja: Más económico
- Desventaja: Menos control, puede no cumplir requerimientos

**Opción 2: Hosting Compartido**
- Costo: $3-8/mes
- Ventaja: Muy económico
- Desventaja: Limitaciones técnicas, no recomendado para aplicaciones Java

---

## 7. RECOMENDACIONES

### 7.1 Para el Proyecto Académico

1. **Usar Free Tier de AWS** (12 meses gratis para nuevos usuarios) - RECOMENDADO
2. **Considerar MySQL en EC2** en lugar de RDS para ahorrar $15/mes
3. **Optimizar recursos** para mantener costos bajos
4. **Monitorear uso diario** mediante AWS Cost Explorer
5. **Configurar alertas de presupuesto** en AWS Billing
6. **Apagar instancias** cuando no se usen (solo pagar almacenamiento)

### 7.2 Para Producción Futura

1. **Implementar auto-scaling** para ajustar recursos según demanda
2. **Usar instancias preemptibles** para tareas no críticas
3. **Implementar caché** para reducir carga en BD
4. **Optimizar consultas** para reducir uso de recursos
5. **Considerar modelo SaaS** para monetizar y cubrir costos

---

## 8. RESUMEN FINAL

### 8.1 Costos Totales del Proyecto

**Sin Free Tier:**
```
Infraestructura Cloud (4 meses):    $105.60
Desarrollo y Licencias:              $0.00
───────────────────────────────────────────
TOTAL:                               $105.60
PRESUPUESTO:                         $50.00
───────────────────────────────────────────
DÉFICIT:                             $55.60
```

**Con Free Tier (Recomendado):**
```
Infraestructura Cloud (4 meses):    $0-15.00
Desarrollo y Licencias:              $0.00
───────────────────────────────────────────
TOTAL:                               $0-15.00
PRESUPUESTO:                         $50.00
───────────────────────────────────────────
DÉFICIT:                             $0 (dentro del presupuesto)
```

### 8.2 Soluciones Propuestas

1. **Usar Free Tier de AWS** (RECOMENDADO - 12 meses gratis)
2. **Instalar MySQL en EC2** en lugar de RDS (ahorro de $15/mes)
3. **Apagar instancias** cuando no se usen durante desarrollo
4. **Optimizar recursos** para reducir costos
5. **Monitorear costos** mediante AWS Cost Explorer y Billing
6. **Configurar alertas** de presupuesto en AWS Billing

---

**Fecha de Generación:** [Fecha]  
**Versión:** 1.0  
**Autor:** Equipo de Desarrollo Telito Bodeguero

