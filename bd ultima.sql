	-- =============================================
	-- SCRIPT COMPLETO Y CONSOLIDADO TELITO BODEGUERO
	-- Base de datos + Tablas (Estructura) + Registros (Datos)
	-- =============================================

	-- Crear la base de datos
	CREATE DATABASE IF NOT EXISTS telito_bodeguero CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

	-- Usar la base de datos
	USE telito_bodeguero;

	-- Deshabilitar verificaciones de claves foráneas temporalmente
	SET FOREIGN_KEY_CHECKS = 0;

	-- =============================================
	-- ELIMINAR Y TRUNCAR TABLAS EXISTENTES
	-- =============================================
	DROP TABLE IF EXISTS alertas_generadas;
	DROP TABLE IF EXISTS stock_minimo_config;
	DROP TABLE IF EXISTS alertas_configuracion;
	DROP TABLE IF EXISTS parametros_sistema;
	DROP TABLE IF EXISTS movimientos_inventario;
	DROP TABLE IF EXISTS ventas;
	DROP TABLE IF EXISTS planes_transporte;
	DROP TABLE IF EXISTS pedido_items;
	DROP TABLE IF EXISTS pedidos;
	DROP TABLE IF EXISTS ordenes_compra;
	DROP TABLE IF EXISTS lotes;
	DROP TABLE IF EXISTS productos;
	DROP TABLE IF EXISTS proveedores;
	DROP TABLE IF EXISTS conductores;
	DROP TABLE IF EXISTS vehiculos;
	DROP TABLE IF EXISTS usuarios;
	DROP TABLE IF EXISTS roles;
	DROP TABLE IF EXISTS ubicaciones;
	DROP TABLE IF EXISTS distritos;
	DROP TABLE IF EXISTS zonas;
	DROP TABLE IF EXISTS clientes;
	DROP TABLE IF EXISTS categorias;

	-- =============================================
	-- CREAR TABLAS (ESTRUCTURA)
	-- =============================================

	-- TABLA: zonas
	CREATE TABLE zonas (
		idZona INT UNSIGNED NOT NULL AUTO_INCREMENT,
		nombre VARCHAR(45) NOT NULL,
		PRIMARY KEY (idZona)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: distritos
	CREATE TABLE distritos (
		idDistrito INT UNSIGNED NOT NULL AUTO_INCREMENT,
		nombre VARCHAR(45) NOT NULL,
		zona_id INT UNSIGNED NOT NULL,
		PRIMARY KEY (idDistrito),
		KEY fk_Distritos_Zonas_idx (zona_id),
		CONSTRAINT fk_Distritos_Zonas FOREIGN KEY (zona_id) REFERENCES zonas (idZona)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: categorias
	CREATE TABLE categorias (
		id_categoria INT UNSIGNED NOT NULL AUTO_INCREMENT,
		nombre VARCHAR(100) NOT NULL,
		PRIMARY KEY (id_categoria)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: roles
	CREATE TABLE roles (
		id_rol INT UNSIGNED NOT NULL AUTO_INCREMENT,
		nombre VARCHAR(100) NOT NULL,
		PRIMARY KEY (id_rol),
		UNIQUE KEY nombre (nombre)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA: usuarios
CREATE TABLE usuarios (
	id_usuario INT UNSIGNED NOT NULL AUTO_INCREMENT,
	nombres VARCHAR(255) NOT NULL,
	apellidos VARCHAR(255) NOT NULL,
	email VARCHAR(255) NOT NULL,
	password VARCHAR(255) NOT NULL,
	activo TINYINT(1) NOT NULL DEFAULT '1',
	foto_perfil VARCHAR(500) NULL,
	rol_id INT UNSIGNED NOT NULL,
	PRIMARY KEY (id_usuario),
	UNIQUE KEY email (email),
	KEY fk_usuario_rol (rol_id),
	CONSTRAINT fk_usuario_rol FOREIGN KEY (rol_id) REFERENCES roles (id_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: productos
	CREATE TABLE productos (
		id_producto INT UNSIGNED NOT NULL AUTO_INCREMENT,
		codigo_sku VARCHAR(50) NOT NULL,
		nombre VARCHAR(255) NOT NULL,
		descripcion TEXT,
		precio_actual DECIMAL(10,2) NOT NULL,
		unidades_por_paquete INT UNSIGNED NOT NULL DEFAULT '1',
		productor_id INT UNSIGNED NOT NULL,
		categoria_id INT UNSIGNED NOT NULL,
		activo TINYINT(1) NOT NULL DEFAULT '1',
		PRIMARY KEY (id_producto),
		UNIQUE KEY codigo_sku (codigo_sku),
		KEY fk_prod_usuario (productor_id),
		KEY fk_prod_categoria (categoria_id),
		CONSTRAINT fk_prod_categoria FOREIGN KEY (categoria_id) REFERENCES categorias (id_categoria),
		CONSTRAINT fk_prod_usuario FOREIGN KEY (productor_id) REFERENCES usuarios (id_usuario)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: ubicaciones
	CREATE TABLE ubicaciones (
		id_ubicacion INT UNSIGNED NOT NULL AUTO_INCREMENT,
		nombre VARCHAR(100) NOT NULL,
		PRIMARY KEY (id_ubicacion)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: lotes
	CREATE TABLE lotes (
		id_lote INT UNSIGNED NOT NULL AUTO_INCREMENT,
		codigo_lote VARCHAR(100) NOT NULL,
		producto_id INT UNSIGNED NOT NULL,
		estado VARCHAR(20) NOT NULL DEFAULT 'No Registrado',
		ubicacion_id INT UNSIGNED NOT NULL,
		stock_actual INT UNSIGNED NOT NULL DEFAULT 0,
		fecha_vencimiento DATE DEFAULT NULL,
		distrito_id INT UNSIGNED NOT NULL,
		PRIMARY KEY (id_lote),
		UNIQUE KEY codigo_lote (codigo_lote),
		KEY fk_lote_producto (producto_id),
		KEY fk_lote_ubicacion (ubicacion_id),
		KEY fk_lote_distrito (distrito_id),
		CONSTRAINT fk_lote_distrito FOREIGN KEY (distrito_id) REFERENCES distritos(idDistrito),
		CONSTRAINT fk_lote_producto FOREIGN KEY (producto_id) REFERENCES productos(id_producto),
		CONSTRAINT fk_lote_ubicacion FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones(id_ubicacion)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: clientes
	CREATE TABLE clientes (
		id_cliente INT UNSIGNED NOT NULL AUTO_INCREMENT,
		nombre VARCHAR(255) NOT NULL,
		ruc_dni VARCHAR(20) DEFAULT NULL,
		PRIMARY KEY (id_cliente)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: pedidos
	CREATE TABLE pedidos (
		id_pedido INT UNSIGNED NOT NULL AUTO_INCREMENT,
		numero_pedido VARCHAR(50) NOT NULL,
		cliente_id INT UNSIGNED NOT NULL,
		destino VARCHAR(255) NOT NULL,
		fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		estado_preparacion ENUM('Pendiente','En preparación','Preparado','Despachado','Cancelado') NOT NULL,
		PRIMARY KEY (id_pedido),
		UNIQUE KEY numero_pedido (numero_pedido),
		KEY fk_pedido_cliente (cliente_id),
		CONSTRAINT fk_pedido_cliente FOREIGN KEY (cliente_id) REFERENCES clientes (id_cliente)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: pedido_items
	CREATE TABLE pedido_items (
		id_pedido_item INT UNSIGNED NOT NULL AUTO_INCREMENT,
		pedido_id INT UNSIGNED NOT NULL,
		producto_id INT UNSIGNED NOT NULL,
		cantidad_requerida INT UNSIGNED NOT NULL,
		cantidad_recogida INT UNSIGNED NOT NULL DEFAULT '0',
		PRIMARY KEY (id_pedido_item),
		KEY fk_pi_pedido (pedido_id),
		KEY fk_pi_producto (producto_id),
		CONSTRAINT fk_pi_pedido FOREIGN KEY (pedido_id) REFERENCES pedidos (id_pedido),
		CONSTRAINT fk_pi_producto FOREIGN KEY (producto_id) REFERENCES productos (id_producto)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: proveedores
	CREATE TABLE proveedores (
		id_proveedor INT UNSIGNED NOT NULL AUTO_INCREMENT,
		nombre VARCHAR(255) NOT NULL,
		PRIMARY KEY (id_proveedor)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: ordenes_compra
	CREATE TABLE ordenes_compra (
		id_orden_compra INT UNSIGNED NOT NULL AUTO_INCREMENT,
		numero_Orden VARCHAR(50) NOT NULL,
		productor_id INT UNSIGNED NOT NULL,
		producto_id INT UNSIGNED NOT NULL,
		cantidad INT UNSIGNED NOT NULL,
		usuario_id INT UNSIGNED NOT NULL,
		estado ENUM('Pendiente','Aprobado','Rechazado','Recibido','En Proceso') NOT NULL,
		monto_total DECIMAL(10,2) NOT NULL,
		lote_id INT UNSIGNED DEFAULT NULL,
		distrito_id INT UNSIGNED NOT NULL,
		PRIMARY KEY (id_orden_compra),
		UNIQUE KEY numero_Orden (numero_Orden),
		KEY fk_oc_productor (productor_id),
		KEY fk_oc_producto (producto_id),
		KEY fk_oc_usuario (usuario_id),
		KEY fk_oc_distrito (distrito_id),
		KEY lote_id (lote_id),
		CONSTRAINT fk_oc_producto FOREIGN KEY (producto_id) REFERENCES productos (id_producto),
		CONSTRAINT fk_oc_productor FOREIGN KEY (productor_id) REFERENCES usuarios (id_usuario),
		CONSTRAINT fk_oc_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id_usuario),
		CONSTRAINT fk_oc_distrito FOREIGN KEY (distrito_id) REFERENCES distritos (idDistrito),
		CONSTRAINT ordenes_compra_ibfk_1 FOREIGN KEY (lote_id) REFERENCES lotes (id_lote)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: movimientos_inventario
	CREATE TABLE movimientos_inventario (
		id_movimiento INT UNSIGNED NOT NULL AUTO_INCREMENT,
		lote_id INT UNSIGNED NOT NULL,
		usuario_id INT UNSIGNED NOT NULL,
		pedido_id INT UNSIGNED DEFAULT NULL,
		orden_compra_id INT UNSIGNED DEFAULT NULL,
		tipo ENUM('Entrada','Salida','Ajuste') NOT NULL,
		cantidad INT UNSIGNED NOT NULL,
		motivo TEXT,
		fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		PRIMARY KEY (id_movimiento),
		KEY fk_mov_lote (lote_id),
		KEY fk_mov_usuario (usuario_id),
		KEY fk_mov_pedido (pedido_id),
		KEY fk_mov_oc (orden_compra_id),
		CONSTRAINT fk_mov_lote FOREIGN KEY (lote_id) REFERENCES lotes (id_lote),
		CONSTRAINT fk_mov_oc FOREIGN KEY (orden_compra_id) REFERENCES ordenes_compra (id_orden_compra),
		CONSTRAINT fk_mov_pedido FOREIGN KEY (pedido_id) REFERENCES pedidos (id_pedido),
		CONSTRAINT fk_mov_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id_usuario)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: conductores
	CREATE TABLE conductores (
		id_conductor INT UNSIGNED NOT NULL AUTO_INCREMENT,
		nombre_completo VARCHAR(255) NOT NULL,
		licencia VARCHAR(50) NOT NULL,
		PRIMARY KEY (id_conductor)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: vehiculos
	CREATE TABLE vehiculos (
		id_vehiculo INT UNSIGNED NOT NULL AUTO_INCREMENT,
		placa VARCHAR(10) NOT NULL,
		marca VARCHAR(50) DEFAULT NULL,
		modelo VARCHAR(50) DEFAULT NULL,
		capacidad_kg INT UNSIGNED NOT NULL,
		PRIMARY KEY (id_vehiculo),
		UNIQUE KEY placa (placa)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: planes_transporte
	CREATE TABLE planes_transporte (
		id_plan INT UNSIGNED NOT NULL AUTO_INCREMENT,
		numero_plan VARCHAR(50) NOT NULL,
		producto_id INT UNSIGNED NOT NULL,
		lote_id INT UNSIGNED NOT NULL,
		estado ENUM('Pendiente','En Ruta','Entregado','Cancelado') NOT NULL,
		conductor_id INT UNSIGNED NOT NULL,
		vehiculo_id INT UNSIGNED NOT NULL,
		fecha_entrega DATE NOT NULL,
		distrito_id INT UNSIGNED NOT NULL,
		PRIMARY KEY (id_plan),
		UNIQUE KEY numero_plan (numero_plan),
		KEY fk_pt_lote (lote_id),
		KEY fk_pt_conductor (conductor_id),
		KEY fk_pt_vehiculo (vehiculo_id),
		KEY fk_pt_distrito (distrito_id),
		CONSTRAINT fk_pt_conductor FOREIGN KEY (conductor_id) REFERENCES conductores (id_conductor),
		CONSTRAINT fk_pt_distrito FOREIGN KEY (distrito_id) REFERENCES distritos (idDistrito),
		CONSTRAINT fk_pt_lote FOREIGN KEY (lote_id) REFERENCES lotes (id_lote),
		CONSTRAINT fk_pt_vehiculo FOREIGN KEY (vehiculo_id) REFERENCES vehiculos (id_vehiculo)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: ventas
	CREATE TABLE ventas (
		id_venta INT UNSIGNED NOT NULL AUTO_INCREMENT,
		lote_id INT UNSIGNED NOT NULL,
		cantidad INT UNSIGNED NOT NULL,
		monto_total DECIMAL(10,2) NOT NULL,
		fecha_venta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		PRIMARY KEY (id_venta),
		KEY fk_venta_lote (lote_id),
		CONSTRAINT fk_venta_lote FOREIGN KEY (lote_id) REFERENCES lotes (id_lote)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: stock_minimo_config
	CREATE TABLE stock_minimo_config (
		id_stock_minimo INT UNSIGNED NOT NULL AUTO_INCREMENT,
		producto_id INT UNSIGNED NOT NULL,
		stock_minimo INT UNSIGNED NOT NULL DEFAULT 10,
		stock_critico INT UNSIGNED NOT NULL DEFAULT 5,
		activo TINYINT(1) NOT NULL DEFAULT 1,
		fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		PRIMARY KEY (id_stock_minimo),
		UNIQUE KEY unique_producto_stock (producto_id),
		KEY fk_stock_producto (producto_id),
		CONSTRAINT fk_stock_producto FOREIGN KEY (producto_id) REFERENCES productos (id_producto) ON DELETE CASCADE
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: alertas_configuracion
	CREATE TABLE alertas_configuracion (
		id_alerta_config INT UNSIGNED NOT NULL AUTO_INCREMENT,
		nombre VARCHAR(255) NOT NULL,
		tipo_alerta ENUM('STOCK_MINIMO','STOCK_CRITICO','VENCIMIENTO','MOVIMIENTO') NOT NULL,
		umbral_dias INT UNSIGNED DEFAULT NULL,
		categoria_id INT UNSIGNED DEFAULT NULL,
		rol_a_notificar ENUM('ADMINISTRADOR','ALMACENERO','LOGISTICA','PRODUCTOR') NOT NULL,
		mensaje_personalizado TEXT,
		activo TINYINT(1) NOT NULL DEFAULT 1,
		fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		PRIMARY KEY (id_alerta_config),
		KEY fk_alerta_categoria (categoria_id),
		CONSTRAINT fk_alerta_categoria FOREIGN KEY (categoria_id) REFERENCES categorias (id_categoria) ON DELETE SET NULL
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: alertas_generadas
	CREATE TABLE alertas_generadas (
		id_alerta_generada INT UNSIGNED NOT NULL AUTO_INCREMENT,
		alerta_config_id INT UNSIGNED NOT NULL,
		producto_id INT UNSIGNED DEFAULT NULL,
		lote_id INT UNSIGNED DEFAULT NULL,
		mensaje TEXT NOT NULL,
		nivel ENUM('INFO','WARNING','CRITICAL') NOT NULL DEFAULT 'WARNING',
		leida TINYINT(1) NOT NULL DEFAULT 0,
		fecha_generacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		fecha_lectura TIMESTAMP NULL DEFAULT NULL,
		PRIMARY KEY (id_alerta_generada),
		KEY fk_alert_gen_config (alerta_config_id),
		KEY fk_alert_gen_producto (producto_id),
		KEY fk_alert_gen_lote (lote_id),
		CONSTRAINT fk_alert_gen_config FOREIGN KEY (alerta_config_id) REFERENCES alertas_configuracion (id_alerta_config) ON DELETE CASCADE,
		CONSTRAINT fk_alert_gen_producto FOREIGN KEY (producto_id) REFERENCES productos (id_producto) ON DELETE CASCADE,
		CONSTRAINT fk_alert_gen_lote FOREIGN KEY (lote_id) REFERENCES lotes (id_lote) ON DELETE CASCADE
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- TABLA: parametros_sistema
	CREATE TABLE parametros_sistema (
		id_parametro INT UNSIGNED NOT NULL AUTO_INCREMENT,
		clave VARCHAR(100) NOT NULL,
		valor TEXT NOT NULL,
		descripcion TEXT,
		tipo ENUM('STRING','INTEGER','BOOLEAN','DECIMAL') NOT NULL DEFAULT 'STRING',
		activo TINYINT(1) NOT NULL DEFAULT 1,
		fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		PRIMARY KEY (id_parametro),
		UNIQUE KEY unique_clave (clave)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- =============================================
	-- INSERTAR DATOS
	-- =============================================

	-- HASH DE '1234' para el login: 03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4
	SET @PASSWORD_HASH = SHA2('1234', 256);

	-- Datos de zonas (10 registros)
	INSERT INTO zonas (nombre) VALUES
	('Norte'), ('Sur'), ('Este'), ('Oeste'), ('Centro'),
	('Altiplano'), ('Costa'), ('Sierra'), ('Selva'), ('Metropolitana');

	-- Datos de distritos (20 registros)
	INSERT INTO distritos (nombre, zona_id) VALUES
	('San Isidro', 10), ('Miraflores', 10), ('Surco', 10), ('San Miguel', 10), ('Callao', 4),
	('Comas', 1), ('Carabayllo', 1), ('Villa El Salvador', 2), ('Chorrillos', 2), ('Ate', 3),
	('La Molina', 3), ('Lince', 5), ('Cercado de Lima', 5), ('Ica', 7), ('Arequipa', 7),
	('Cusco', 8), ('Puno', 6), ('Trujillo', 7), ('Chiclayo', 7), ('Tarapoto', 9);

	-- Datos de categorias (10 registros)
	INSERT INTO categorias (nombre) VALUES
	('Bebidas'), ('Snacks'), ('Lácteos'), ('Enlatados'), ('Limpieza'),
	('Higiene'), ('Cereales'), ('Carnes'), ('Verduras'), ('Frutas');

	-- Datos de roles (6 registros clave)
	INSERT INTO roles (id_rol, nombre) VALUES
	(1,'Administrador'), (2,'Logística'), (3,'Productor'),
	(4,'Almacenero'), (5,'Conductor'), (6,'Cliente');

	-- Datos de usuarios (10 registros, con roles definidos)
	INSERT INTO usuarios (id_usuario, nombres, apellidos, email, password, activo, rol_id) VALUES
	(1,'Admin','Principal','admin@telito.com', @PASSWORD_HASH, 1, 1),
	(2,'Maria','Logistica','maria@telito.com', @PASSWORD_HASH, 1, 2),
	(3,'Carlos','Productor','carlos@productor.com', @PASSWORD_HASH, 1, 3),
	(4,'Ana','Almacenero','ana@telito.com', @PASSWORD_HASH, 1, 4),
	(5,'Luis','Conductor','luis@conductor.com', @PASSWORD_HASH, 1, 5),
	(6,'Sofia','Ventas','sofia@telito.com', @PASSWORD_HASH, 1, 2),
	(7,'Ricardo','Productor Dos','ricardo@productor.com', @PASSWORD_HASH, 1, 3),
	(8,'Elena','Almacenero Dos','elena@telito.com', @PASSWORD_HASH, 1, 4),
	(9,'Pedro','Supervisor','pedro@telito.com', @PASSWORD_HASH, 1, 1),
	(10,'Jorge','Conductor Dos','jorge@conductor.com', @PASSWORD_HASH, 1, 5);

	-- Datos de proveedores (10 registros)
	INSERT INTO proveedores (nombre) VALUES
	('Distribuidora Andina'), ('Proveedor Mayorista P & H'), ('Logística Express SAC'),
	('Ferretería Global'), ('Insumos del Campo'), ('Bebidas del Sur'),
	('Lacteos Frescos EIRL'), ('Snacks y Frituras'), ('Carnicos Premium'),
	('Frutas y Verduras Orgánicas');

	-- Datos de productos (15 registros, asociados a Productores 3 y 7)
	INSERT INTO productos (codigo_sku, nombre, descripcion, precio_actual, productor_id, categoria_id, activo) VALUES
	('SKU001','Gaseosa Cola 1.5L','Bebida burbujeante', 5.50, 3, 1, 1),
	('SKU002','Jugo Naranja 1L','Jugo fresco envasado', 7.20, 3, 1, 1),
	('SKU003','Papas Onduladas','Snack salado', 3.00, 3, 2, 1),
	('SKU004','Yogurt Vainilla 1KG','Lácteo bebible', 8.50, 7, 3, 1),
	('SKU005','Leche Fresca 1L','Leche entera UHT', 4.10, 7, 3, 1),
	('SKU006','Atún en Aceite','Lata de atún, 180g', 6.00, 7, 4, 1),
	('SKU007','Detergente Líquido','Para ropa delicada', 15.00, 3, 5, 1),
	('SKU008','Jabón Barra','Jabón de tocador', 2.50, 3, 6, 1),
	('SKU009','Cereal Trigo','Cereal integral, 500g', 12.00, 7, 7, 1),
	('SKU010','Carne Molida 500g','Carne de res congelada', 18.50, 7, 8, 1),
	('SKU011','Tomate Italiano 1kg','Vegetal fresco', 3.50, 3, 9, 1),
	('SKU012','Plátano Isla 1kg','Fruta energética', 2.80, 7, 10, 1),
	('SKU013','Agua Mineral 600ml','Botella de agua sin gas', 1.50, 3, 1, 1),
	('SKU014','Barra de Chocolate','Snack dulce', 4.50, 7, 2, 1),
	('SKU015','Queso Fresco 250g','Lácteo refrigerado', 9.90, 3, 3, 1);

	-- Datos de ubicaciones (10 registros)
	INSERT INTO ubicaciones (nombre) VALUES
	('Estante A01'), ('Estante A02'), ('Estante B01'), ('Estante B02'),
	('Cámara Fria 1'), ('Cámara Fria 2'), ('Rack C01'), ('Rack C02'),
	('Zona Despacho'), ('Almacen Seco');

	-- Datos de lotes (30 registros)
	INSERT INTO lotes (codigo_lote, producto_id, estado, ubicacion_id, stock_actual, fecha_vencimiento, distrito_id) VALUES
	('LTC001', 1, 'Registrado', 1, 300, '2026-10-30', 1), -- Gaseosa (Bebidas) - Stock Alto
	('LTC002', 2, 'Registrado', 1, 250, '2026-05-15', 2), -- Jugo (Bebidas)
	('LTC003', 3, 'Registrado', 2, 400, '2025-11-20', 3), -- Papas (Snacks) - Vence pronto
	('LTC004', 4, 'Registrado', 5, 150, '2026-01-01', 4), -- Yogurt (Lácteos) - Refrigerado
	('LTC005', 5, 'Registrado', 5, 200, '2025-12-05', 5), -- Leche (Lácteos) - Refrigerado
	('LTC006', 6, 'Registrado', 10, 500, '2027-03-01', 6), -- Atún (Enlatados)
	('LTC007', 7, 'Registrado', 7, 100, '2028-01-01', 7), -- Detergente (Limpieza)
	('LTC008', 8, 'Registrado', 8, 80, '2026-04-20', 8), -- Jabón (Higiene)
	('LTC009', 9, 'Registrado', 9, 60, '2025-10-25', 9), -- Cereal (Cereales) - Vence muy pronto
	('LTC010', 10, 'Registrado', 5, 120, '2025-11-01', 10), -- Carne (Carnes) - Refrigerado, Vence pronto
	('LTC011', 11, 'Registrado', 5, 90, '2025-10-30', 1), -- Tomate (Verduras) - Refrigerado, Vence pronto
	('LTC012', 12, 'Registrado', 5, 110, '2025-11-05', 2), -- Plátano (Frutas) - Refrigerado
	('LTC013', 13, 'Registrado', 1, 350, '2027-06-01', 3), -- Agua (Bebidas)
	('LTC014', 14, 'Registrado', 2, 280, '2026-02-10', 4), -- Chocolate (Snacks)
	('LTC015', 15, 'Registrado', 5, 180, '2025-12-25', 5), -- Queso (Lácteos) - Refrigerado
	('LTC016', 1, 'No Registrado', 1, 150, '2026-09-01', 6),
	('LTC017', 2, 'Registrado', 2, 70, '2025-11-10', 7),
	('LTC018', 3, 'No Registrado', 3, 210, '2026-03-01', 8),
	('LTC019', 4, 'Registrado', 5, 95, '2026-04-01', 9),
	('LTC020', 5, 'No Registrado', 5, 140, '2027-01-15', 10),
	('LTC021', 6, 'Registrado', 10, 320, '2028-05-01', 1),
	('LTC022', 7, 'Registrado', 7, 75, '2027-11-01', 2),
	('LTC023', 8, 'No Registrado', 8, 160, '2026-08-01', 3),
	('LTC024', 9, 'Registrado', 9, 40, '2025-10-22', 4), -- Stock bajo, Vence inmediatamente
	('LTC025', 10, 'No Registrado', 5, 10, '2025-11-15', 5), -- Stock muy bajo
	('LTC026', 11, 'Registrado', 5, 20, '2025-11-01', 6), -- Stock bajo
	('LTC027', 12, 'Registrado', 5, 30, '2026-03-01', 7),
	('LTC028', 13, 'No Registrado', 1, 400, '2027-12-01', 8),
	('LTC029', 14, 'Registrado', 2, 190, '2026-06-01', 9),
	('LTC030', 15, 'Registrado', 5, 130, '2026-01-01', 10);

	-- Datos de clientes (15 registros)
	INSERT INTO clientes (nombre, ruc_dni) VALUES
	('Supermercado Llama', '20123456781'), ('Tienda Don Pepe', '10987654321'),
	('Restaurante El Chef', '20998877665'), ('Minimarket Sarita', '10555444332'),
	('Cliente Final 1', '47123456'), ('Distribuidora Rápida', '20112233445'),
	('Catering Gourmet', '20556677889'), ('Panadería Central', '10667788990'),
	('Cliente Final 2', '47654321'), ('Mercado Mayorista Lima', '20332211445'),
	('Puesto 12', '10112233445'), ('Hotel Cinco Estrellas', '20990011223'),
	('Universidad UTP', '20334455667'), ('Librería San Martín', '10778899001'),
	('Cliente VIP', '4700011122');

	-- Datos de pedidos (20 pedidos)
	INSERT INTO pedidos (numero_pedido, cliente_id, destino, estado_preparacion, fecha_creacion) VALUES
	('P001', 1, 'Av. Central 100, Miraflores', 'Despachado', '2025-09-01 10:00:00'),
	('P002', 2, 'Calle Lima 201, Lince', 'Preparado', '2025-09-02 11:30:00'),
	('P003', 3, 'Jr. Sucre 303, Surco', 'En preparación', '2025-09-03 12:45:00'),
	('P004', 4, 'Av. Puno 404, Callao', 'Pendiente', '2025-09-04 14:00:00'),
	('P005', 5, 'Residencia 505, SJM', 'Cancelado', '2025-09-05 09:00:00'),
	('P006', 6, 'Av. Marina 606, San Miguel', 'Despachado', '2025-09-05 15:30:00'),
	('P007', 7, 'Calle Berlín 707, Miraflores', 'Preparado', '2025-09-06 16:45:00'),
	('P008', 8, 'Jr. Ayacucho 808, Camaná', 'En preparación', '2025-09-07 10:00:00'),
	('P009', 9, 'Av. Angamos 909, Surco', 'Pendiente', '2025-09-08 11:30:00'),
	('P010', 10, 'Plaza Mayor 10, Cercado', 'Despachado', '2025-09-09 12:45:00'),
	('P011', 1, 'Av. Los Ficus 111, Miraflores', 'Despachado', '2025-09-10 14:00:00'),
	('P012', 2, 'Calle Las Palmas 222, Lince', 'Preparado', '2025-09-11 09:00:00'),
	('P013', 3, 'Jr. Las Moras 333, Surco', 'En preparación', '2025-09-12 15:30:00'),
	('P014', 4, 'Av. Faucett 444, Callao', 'Pendiente', '2025-09-13 16:45:00'),
	('P015', 5, 'Residencia El Sol 555, SJM', 'Cancelado', '2025-09-14 10:00:00'),
	('P016', 6, 'Av. El Ejército 666, San Miguel', 'Despachado', '2025-09-15 11:30:00'),
	('P017', 7, 'Calle San Martín 777, Miraflores', 'Preparado', '2025-09-16 12:45:00'),
	('P018', 8, 'Jr. Unión 888, Camaná', 'En preparación', '2025-09-17 14:00:00'),
	('P019', 9, 'Av. Primavera 999, Surco', 'Pendiente', '2025-09-18 09:00:00'),
	('P020', 10, 'Plaza San Martín 20, Cercado', 'Despachado', '2025-09-19 15:30:00');

	-- Datos de pedido_items (40 items para los 20 pedidos)
	INSERT INTO pedido_items (pedido_id, producto_id, cantidad_requerida, cantidad_recogida) VALUES
	-- P001 (Despachado)
	(1, 1, 50, 50), (1, 3, 20, 20),
	-- P002 (Preparado)
	(2, 4, 30, 30), (2, 5, 15, 15),
	-- P003 (En preparación)
	(3, 7, 10, 5), (3, 8, 5, 0),
	-- P004 (Pendiente)
	(4, 10, 25, 0), (4, 11, 15, 0),
	-- P005 (Cancelado)
	(5, 1, 100, 0), (5, 6, 50, 0),
	-- P006 (Despachado)
	(6, 13, 80, 80), (6, 14, 40, 40),
	-- P007 (Preparado)
	(7, 15, 20, 20), (7, 1, 10, 10),
	-- P008 (En preparación)
	(8, 2, 5, 5), (8, 3, 10, 0),
	-- P009 (Pendiente)
	(9, 4, 15, 0), (9, 5, 5, 0),
	-- P010 (Despachado)
	(10, 6, 120, 120), (10, 7, 50, 50),
	-- Más Pedidos (P011-P020)
	(11, 8, 30, 30), (11, 9, 10, 10),
	(12, 10, 5, 5), (12, 11, 8, 0),
	(13, 12, 15, 10), (13, 13, 20, 0),
	(14, 14, 25, 0), (14, 15, 10, 0),
	(16, 1, 35, 35), (16, 2, 25, 25),
	(17, 3, 15, 15), (17, 4, 10, 10),
	(18, 5, 10, 5), (18, 6, 20, 0),
	(19, 7, 8, 0), (19, 8, 12, 0),
	(20, 9, 10, 10), (20, 10, 15, 15);

	-- Datos de ordenes_compra (15 registros)
	INSERT INTO ordenes_compra (numero_Orden, proveedor_id, producto_id, cantidad, usuario_id, estado, monto_total, lote_id) VALUES
	('OC001', 1, 1, 500, 2, 'Recibido', 2750.00, 1),
	('OC002', 2, 3, 300, 2, 'Recibido', 900.00, 3),
	('OC003', 3, 4, 200, 4, 'Recibido', 1700.00, 4),
	('OC004', 4, 7, 100, 4, 'Pendiente', 1500.00, NULL),
	('OC005', 5, 10, 50, 2, 'Recibido', 925.00, 10),
	('OC006', 6, 1, 400, 2, 'Aprobado', 2200.00, NULL),
	('OC007', 7, 5, 150, 4, 'Recibido', 615.00, 5),
	('OC008', 8, 8, 100, 4, 'Aprobado', 250.00, NULL),
	('OC009', 9, 11, 200, 2, 'Recibido', 700.00, 11),
	('OC010', 10, 13, 600, 4, 'Pendiente', 900.00, NULL),
	('OC011', 1, 15, 100, 2, 'Recibido', 990.00, 15),
	('OC012', 2, 2, 250, 4, 'Aprobado', 1800.00, NULL),
	('OC013', 3, 6, 300, 2, 'Recibido', 1800.00, 6),
	('OC014', 4, 9, 80, 4, 'Recibido', 960.00, 9),
	('OC015', 5, 12, 100, 2, 'Aprobado', 280.00, NULL);

	-- Datos de movimientos_inventario (25 registros)
	INSERT INTO movimientos_inventario (lote_id, usuario_id, pedido_id, orden_compra_id, tipo, cantidad, motivo, fecha) VALUES
	-- Entradas (Recibido de OC)
	(1, 4, NULL, 1, 'Entrada', 500, 'Recepción OC001', '2025-09-01 09:00:00'),
	(3, 4, NULL, 2, 'Entrada', 300, 'Recepción OC002', '2025-09-02 09:00:00'),
	(4, 4, NULL, 3, 'Entrada', 200, 'Recepción OC003', '2025-09-03 09:00:00'),
	(10, 4, NULL, 5, 'Entrada', 50, 'Recepción OC005', '2025-09-05 09:00:00'),
	(11, 4, NULL, 9, 'Entrada', 200, 'Recepción OC009', '2025-09-09 09:00:00'),
	(15, 4, NULL, 11, 'Entrada', 100, 'Recepción OC011', '2025-09-11 09:00:00'),
	(6, 4, NULL, 13, 'Entrada', 300, 'Recepción OC013', '2025-09-13 09:00:00'),
	(9, 4, NULL, 14, 'Entrada', 80, 'Recepción OC014', '2025-09-14 09:00:00'),

	-- Salidas (Despacho de Pedidos)
	(1, 4, 1, NULL, 'Salida', 50, 'Despacho P001', '2025-09-01 11:00:00'),
	(3, 4, 1, NULL, 'Salida', 20, 'Despacho P001', '2025-09-01 11:05:00'),
	(6, 4, 6, NULL, 'Salida', 80, 'Despacho P006', '2025-09-05 16:00:00'),
	(14, 4, 6, NULL, 'Salida', 40, 'Despacho P006', '2025-09-05 16:05:00'),
	(9, 4, 10, NULL, 'Salida', 120, 'Despacho P010', '2025-09-09 13:00:00'),
	(7, 4, 10, NULL, 'Salida', 50, 'Despacho P010', '2025-09-09 13:05:00'),
	(8, 4, 11, NULL, 'Salida', 30, 'Despacho P011', '2025-09-10 14:30:00'),
	(9, 4, 11, NULL, 'Salida', 10, 'Despacho P011', '2025-09-10 14:35:00'),
	(1, 4, 16, NULL, 'Salida', 35, 'Despacho P016', '2025-09-15 11:45:00'),
	(2, 4, 16, NULL, 'Salida', 25, 'Despacho P016', '2025-09-15 11:50:00'),
	(3, 4, 17, NULL, 'Salida', 15, 'Despacho P017', '2025-09-16 13:00:00'),
	(4, 4, 17, NULL, 'Salida', 10, 'Despacho P017', '2025-09-16 13:05:00'),
	(9, 4, 20, NULL, 'Salida', 10, 'Despacho P020', '2025-09-19 16:00:00'),
	(10, 4, 20, NULL, 'Salida', 15, 'Despacho P020', '2025-09-19 16:05:00'),

	-- Ajustes (Ajustes de stock)
	(5, 8, NULL, NULL, 'Ajuste', 5, 'Ajuste por merma', '2025-09-20 10:00:00'),
	(11, 8, NULL, NULL, 'Ajuste', 10, 'Ajuste por error de conteo', '2025-09-21 11:00:00'),
	(24, 8, NULL, NULL, 'Ajuste', 5, 'Ajuste por expiración', '2025-09-22 12:00:00');

	-- Datos de conductores (5 registros)
	INSERT INTO conductores (nombre_completo, licencia) VALUES
	('Juan Torres', 'B001'), ('Ana Castro', 'B002'), ('Pedro Gómez', 'C003'),
	('Laura Flores', 'A004'), ('Miguel Ríos', 'C005');

	-- Datos de vehiculos (5 registros)
	INSERT INTO vehiculos (placa, marca, modelo, capacidad_kg) VALUES
	('XYZ100', 'Toyota', 'Hiace', 2500), ('ABC200', 'Nissan', 'NV350', 3000),
	('DEF300', 'Hyundai', 'H100', 1500), ('GHI400', 'Mercedes', 'Sprinter', 4000),
	('JKL500', 'Kia', 'K2700', 2000);

	-- Datos de planes_transporte (10 planes)
	INSERT INTO planes_transporte (numero_plan, producto_id, lote_id, estado, conductor_id, vehiculo_id, fecha_entrega, distrito_id) VALUES
	('PT001', 1, 1, 'Entregado', 1, 1, '2025-09-02', 1),
	('PT002', 3, 3, 'Entregado', 2, 2, '2025-09-03', 3),
	('PT003', 13, 13, 'En Ruta', 3, 3, '2025-10-25', 5),
	('PT004', 6, 6, 'Pendiente', 4, 4, '2025-10-26', 6),
	('PT005', 10, 10, 'Cancelado', 5, 5, '2025-09-10', 10),
	('PT006', 8, 8, 'Entregado', 1, 1, '2025-09-11', 8),
	('PT007', 9, 9, 'En Ruta', 2, 2, '2025-10-25', 9),
	('PT008', 4, 4, 'Pendiente', 3, 3, '2025-10-27', 4),
	('PT009', 15, 15, 'Entregado', 4, 4, '2025-09-17', 5),
	('PT010', 1, 1, 'Pendiente', 5, 5, '2025-10-28', 1);

	-- Datos de ventas (10 registros - simulados a partir de los despachos)
	INSERT INTO ventas (lote_id, cantidad, monto_total, fecha_venta) VALUES
	(1, 50, 275.00, '2025-09-01 11:30:00'),
	(3, 20, 60.00, '2025-09-01 11:30:00'),
	(6, 80, 480.00, '2025-09-05 17:00:00'),
	(14, 40, 180.00, '2025-09-05 17:00:00'),
	(9, 120, 1440.00, '2025-09-09 14:00:00'),
	(7, 50, 750.00, '2025-09-09 14:00:00'),
	(8, 30, 75.00, '2025-09-10 15:00:00'),
	(9, 10, 120.00, '2025-09-10 15:00:00'),
	(1, 35, 192.50, '2025-09-15 12:30:00'),
	(2, 25, 180.00, '2025-09-15 12:30:00');

	-- Configuraciones de stock mínimo para productos principales (10 registros)
	INSERT INTO stock_minimo_config (producto_id, stock_minimo, stock_critico, activo) VALUES
	(1, 100, 50, 1), (3, 50, 25, 1), (4, 75, 40, 1), (6, 150, 75, 1), (10, 30, 15, 1),
	(11, 40, 20, 1), (13, 200, 100, 1), (14, 100, 50, 1), (15, 80, 40, 1), (9, 20, 10, 1);

	-- Configuraciones de alertas (5 registros)
	INSERT INTO alertas_configuracion (nombre, tipo_alerta, umbral_dias, categoria_id, rol_a_notificar, mensaje_personalizado, activo) VALUES
	('Alerta Stock Mínimo Snacks', 'STOCK_MINIMO', NULL, 2, 'ALMACENERO', 'El stock de Snacks está cerca del mínimo.', 1),
	('Alerta Vencimiento 15 días', 'VENCIMIENTO', 15, NULL, 'LOGISTICA', 'Productos vencen en 15 días o menos.', 1),
	('Alerta Crítica Lácteos', 'STOCK_CRITICO', NULL, 3, 'ADMINISTRADOR', '¡CRÍTICO! Stock de lácteos por debajo del límite.', 1),
	('Alerta Vencimiento 7 días Carnes', 'VENCIMIENTO', 7, 8, 'PRODUCTOR', 'Lotes de carne próximos a vencer en una semana.', 1),
	('Alerta Movimientos de Ajuste', 'MOVIMIENTO', NULL, NULL, 'ALMACENERO', 'Se ha registrado un ajuste de inventario manual.', 1);

	-- Parámetros del sistema (4 registros)
	INSERT INTO parametros_sistema (clave, valor, descripcion, tipo, activo) VALUES
	('STOCK_MINIMO_GLOBAL', '20', 'Stock mínimo global por defecto.', 'INTEGER', 1),
	('DIAS_ALERTA_VENCIMIENTO', '10', 'Días de anticipación para alertas de vencimiento por defecto.', 'INTEGER', 1),
	('HABILITAR_ALERTAS_EMAIL', 'true', 'Habilitar envío de alertas por email.', 'BOOLEAN', 1),
	('EMAIL_SOPORTE', 'soporte@telito.com', 'Email para reportes de errores y soporte.', 'STRING', 1);

	-- Habilitar verificaciones de claves foráneas
	SET FOREIGN_KEY_CHECKS = 1;

	SELECT '🎉 BASE DE DATOS TELITO_BODEGUERO LISTA. ¡SCRIPT EJECUTADO CORRECTAMENTE! 🎉' AS mensaje;