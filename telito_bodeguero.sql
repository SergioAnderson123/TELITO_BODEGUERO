-- MySQL dump 10.13  Distrib 8.0.28, for Win64 (x86_64)
--
-- Host: localhost    Database: telito_bodeguero
-- ------------------------------------------------------
-- Server version	8.0.28

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `alertas_configuracion`
--

DROP TABLE IF EXISTS `alertas_configuracion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alertas_configuracion` (
  `id_alerta_config` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `tipo_alerta` enum('STOCK_MINIMO_LOTE','STOCK_CRITICO_LOTE','STOCK_MINIMO_TOTAL','STOCK_CRITICO_TOTAL','VENCIMIENTO','MOVIMIENTO','STOCK_MINIMO','STOCK_CRITICO') NOT NULL,
  `umbral_dias` int unsigned DEFAULT NULL,
  `categoria_id` int unsigned DEFAULT NULL,
  `rol_a_notificar` enum('ADMINISTRADOR','ALMACENERO','LOGISTICA','PRODUCTOR') NOT NULL,
  `mensaje_personalizado` text,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_alerta_config`),
  KEY `fk_alerta_categoria` (`categoria_id`),
  CONSTRAINT `fk_alerta_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id_categoria`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alertas_configuracion`
--

LOCK TABLES `alertas_configuracion` WRITE;
/*!40000 ALTER TABLE `alertas_configuracion` DISABLE KEYS */;
INSERT INTO `alertas_configuracion` VALUES (1,'Alerta Stock Mínimo Snacks','STOCK_MINIMO_TOTAL',NULL,2,'ALMACENERO','El stock de Snacks está cerca del mínimo.',1,'2025-10-29 01:18:26','2025-10-29 01:18:27'),(2,'Alerta Vencimiento 15 días','VENCIMIENTO',15,NULL,'LOGISTICA','Productos vencen en 15 días o menos.',1,'2025-10-29 01:18:26','2025-10-29 01:18:26'),(3,'Alerta Crítica Lácteos','STOCK_CRITICO_TOTAL',NULL,3,'ADMINISTRADOR','¡CRÍTICO! Stock de lácteos por debajo del límite.',1,'2025-10-29 01:18:26','2025-10-29 01:18:27'),(4,'Alerta Vencimiento 7 días Carnes','VENCIMIENTO',7,8,'PRODUCTOR','Lotes de carne próximos a vencer en una semana.',1,'2025-10-29 01:18:26','2025-10-29 01:18:26'),(5,'Alerta Movimientos de Ajuste','MOVIMIENTO',NULL,NULL,'ALMACENERO','Se ha registrado un ajuste de inventario manual.',0,'2025-10-29 01:18:26','2025-11-17 13:58:10');
/*!40000 ALTER TABLE `alertas_configuracion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alertas_generadas`
--

DROP TABLE IF EXISTS `alertas_generadas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alertas_generadas` (
  `id_alerta_generada` int unsigned NOT NULL AUTO_INCREMENT,
  `alerta_config_id` int unsigned NOT NULL,
  `producto_id` int unsigned DEFAULT NULL,
  `lote_id` int unsigned DEFAULT NULL,
  `mensaje` text NOT NULL,
  `nivel` enum('INFO','WARNING','CRITICAL') NOT NULL DEFAULT 'WARNING',
  `leida` tinyint(1) NOT NULL DEFAULT '0',
  `fecha_generacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_lectura` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_alerta_generada`),
  KEY `fk_alert_gen_config` (`alerta_config_id`),
  KEY `fk_alert_gen_producto` (`producto_id`),
  KEY `fk_alert_gen_lote` (`lote_id`),
  CONSTRAINT `fk_alert_gen_config` FOREIGN KEY (`alerta_config_id`) REFERENCES `alertas_configuracion` (`id_alerta_config`) ON DELETE CASCADE,
  CONSTRAINT `fk_alert_gen_lote` FOREIGN KEY (`lote_id`) REFERENCES `lotes` (`id_lote`) ON DELETE CASCADE,
  CONSTRAINT `fk_alert_gen_producto` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alertas_generadas`
--

LOCK TABLES `alertas_generadas` WRITE;
/*!40000 ALTER TABLE `alertas_generadas` DISABLE KEYS */;
/*!40000 ALTER TABLE `alertas_generadas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_sistema`
--

DROP TABLE IF EXISTS `auditoria_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoria_sistema` (
  `id_auditoria` int unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned NOT NULL,
  `usuario_nombre` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `accion` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tipo de acción: CREAR_USUARIO, EDITAR_USUARIO, ELIMINAR_USUARIO, BANEAR_USUARIO, CREAR_PRODUCTO, etc.',
  `modulo` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Módulo donde se realizó la acción: USUARIOS, PRODUCTOS, INVENTARIO, etc.',
  `descripcion` text COLLATE utf8mb4_unicode_ci COMMENT 'Descripción detallada de la acción',
  `datos_anteriores` json DEFAULT NULL COMMENT 'Datos antes del cambio (para ediciones)',
  `datos_nuevos` json DEFAULT NULL COMMENT 'Datos después del cambio (para ediciones)',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Dirección IP del usuario',
  `user_agent` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User agent del navegador',
  `fecha_accion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'EXITOSO' COMMENT 'EXITOSO, FALLIDO, ERROR',
  `mensaje_error` text COLLATE utf8mb4_unicode_ci COMMENT 'Mensaje de error si la acción falló',
  PRIMARY KEY (`id_auditoria`),
  KEY `idx_usuario` (`usuario_id`),
  KEY `idx_accion` (`accion`),
  KEY `idx_modulo` (`modulo`),
  KEY `idx_fecha` (`fecha_accion`),
  KEY `idx_estado` (`estado`),
  CONSTRAINT `auditoria_sistema_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=142 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_sistema`
--

LOCK TABLES `auditoria_sistema` WRITE;
/*!40000 ALTER TABLE `auditoria_sistema` DISABLE KEYS */;
INSERT INTO `auditoria_sistema` VALUES (1,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:16:45','EXITOSO',NULL),(2,14,'Alejo aldrolin','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:25:50','EXITOSO',NULL),(3,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:27:33','EXITOSO',NULL),(5,13,'Luis Lingan','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:28:41','EXITOSO',NULL),(6,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:30:04','EXITOSO',NULL),(7,13,'Luis Lingan','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:32:13','EXITOSO',NULL),(9,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:33:30','EXITOSO',NULL),(10,2,'Eduardo Rodas','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:46:26','EXITOSO',NULL),(11,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:46:44','EXITOSO',NULL),(12,16,'sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:46:58','EXITOSO',NULL),(13,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:47:17','EXITOSO',NULL),(16,2,'Eduardo Rodas','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:48:53','EXITOSO',NULL),(17,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 13:53:53','EXITOSO',NULL),(18,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:48:11','EXITOSO',NULL),(19,1,'Admin Principal','BANEAR_USUARIO','USUARIOS','Usuario deshabilitado: a20223291@pucp.edu.pe (ID: 3)',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:49:35','EXITOSO',NULL),(20,1,'Admin Principal','BANEAR_USUARIO','USUARIOS','Usuario deshabilitado: sergiomeneses893@gmail.com (ID: 2)',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:50:34','EXITOSO',NULL),(21,1,'Admin Principal','CREAR_USUARIO','USUARIOS','Usuario creado: sergiomeneses893@gmail.com (ID: 2), Rol: Logística',NULL,'{\"rol\": {\"idRol\": 2, \"nombre\": \"Logística\"}, \"email\": \"sergiomeneses893@gmail.com\", \"activo\": true, \"nombres\": \"juan\", \"apellidos\": \"perez\", \"idUsuario\": 2, \"cuentaActivada\": true, \"codigoProductor\": \"PROD-0002\", \"fechaActivacion\": \"Nov 17, 2025, 11:45:19 AM\"}','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:51:06','EXITOSO',NULL),(22,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:57:02','EXITOSO',NULL),(23,1,'Admin Principal','BANEAR_USUARIO','USUARIOS','Usuario deshabilitado: sergiomeneses893@gmail.com (ID: 2)',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:57:15','EXITOSO',NULL),(24,1,'Admin Principal','CREAR_USUARIO','USUARIOS','Usuario creado: sergiomeneses893@gmail.com (ID: 2), Rol: Administrador',NULL,'{\"rol\": {\"idRol\": 1, \"nombre\": \"Administrador\"}, \"email\": \"sergiomeneses893@gmail.com\", \"activo\": true, \"nombres\": \"Sergio\", \"apellidos\": \"Meneses\", \"idUsuario\": 2, \"cuentaActivada\": true, \"codigoProductor\": \"PROD-0002\", \"fechaActivacion\": \"Nov 17, 2025, 11:45:19 AM\"}','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:57:50','EXITOSO',NULL),(25,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:59:07','EXITOSO',NULL),(26,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 17:04:44','EXITOSO',NULL),(27,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 17:11:21','EXITOSO',NULL),(28,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 17:42:25','EXITOSO',NULL),(29,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 05:33:30','EXITOSO',NULL),(30,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 05:40:21','EXITOSO',NULL),(31,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 16:30:22','EXITOSO',NULL),(33,16,'sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0','2025-11-18 16:31:36','EXITOSO',NULL),(35,13,'Luis Lingan','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 16:32:57','EXITOSO',NULL),(38,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 16:33:50','EXITOSO',NULL),(39,1,'Admin Principal','EDITAR_USUARIO','USUARIOS','Usuario actualizado: sergiomeneses893@gmail.com (ID: 2)','{\"rol\": {\"idRol\": 1, \"nombre\": \"Administrador\"}, \"email\": \"sergiomeneses893@gmail.com\", \"activo\": true, \"nombres\": \"Sergio\", \"apellidos\": \"Meneses\", \"idUsuario\": 2, \"cuentaActivada\": false, \"codigoProductor\": \"PROD-0002\"}','{\"rol\": {\"idRol\": 3, \"nombre\": \"Productor\"}, \"email\": \"sergiomeneses893@gmail.com\", \"activo\": true, \"nombres\": \"Sergio\", \"apellidos\": \"Meneses\", \"idUsuario\": 2, \"cuentaActivada\": false, \"codigoProductor\": \"PROD-0002\"}','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 16:34:18','EXITOSO',NULL),(43,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 16:36:06','EXITOSO',NULL),(44,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 127.0.0.1',NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 16:44:32','EXITOSO',NULL),(45,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 127.0.0.1',NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 16:44:55','EXITOSO',NULL),(46,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 16:45:28','EXITOSO',NULL),(48,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0','2025-11-18 16:46:02','EXITOSO',NULL),(49,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0','2025-11-18 17:13:57','EXITOSO',NULL),(50,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 19:11:06','EXITOSO',NULL),(54,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 19:12:43','EXITOSO',NULL),(55,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 19:22:26','EXITOSO',NULL),(56,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 19:23:23','EXITOSO',NULL),(57,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 19:29:31','EXITOSO',NULL),(58,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 19:30:28','EXITOSO',NULL),(59,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 19:36:35','EXITOSO',NULL),(60,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 03:38:39','EXITOSO',NULL),(62,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 03:41:01','EXITOSO',NULL),(63,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 04:22:20','EXITOSO',NULL),(64,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 04:38:45','EXITOSO',NULL),(65,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 04:39:47','EXITOSO',NULL),(66,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 04:40:36','EXITOSO',NULL),(67,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 05:11:10','EXITOSO',NULL),(68,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 19:50:39','EXITOSO',NULL),(69,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 22:52:36','EXITOSO',NULL),(70,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 22:55:33','EXITOSO',NULL),(71,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 23:01:03','EXITOSO',NULL),(73,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 127.0.0.1',NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 23:09:08','EXITOSO',NULL),(74,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-19 23:09:42','EXITOSO',NULL),(75,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 01:58:00','EXITOSO',NULL),(78,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 01:59:14','EXITOSO',NULL),(80,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 02:05:52','EXITOSO',NULL),(82,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 02:08:26','EXITOSO',NULL),(83,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 02:09:30','EXITOSO',NULL),(84,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 02:10:37','EXITOSO',NULL),(86,14,'Alejo aldrolin','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 02:11:22','EXITOSO',NULL),(88,13,'Luis Lingan','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 02:12:15','EXITOSO',NULL),(89,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 02:13:55','EXITOSO',NULL),(90,13,'Luis Lingan','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 02:14:24','EXITOSO',NULL),(91,13,'Luis Lingan','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 02:23:46','EXITOSO',NULL),(92,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 02:24:32','EXITOSO',NULL),(93,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 02:37:24','EXITOSO',NULL),(94,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 02:52:41','EXITOSO',NULL),(95,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 03:01:29','EXITOSO',NULL),(96,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:00:55','EXITOSO',NULL),(97,1,'Admin Principal','CREAR_USUARIO','USUARIOS','Usuario creado: olgaramosdelacruz@pucp.edu.pe (ID: 17), Rol: Productor',NULL,'{\"rol\": {\"idRol\": 3, \"nombre\": \"Productor\"}, \"email\": \"olgaramosdelacruz@pucp.edu.pe\", \"activo\": true, \"nombres\": \"Olguita\", \"apellidos\": \"Ramos\", \"idUsuario\": 17, \"cuentaActivada\": false, \"codigoProductor\": \"PROD-0016\"}','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:02:56','EXITOSO',NULL),(98,1,'Admin Principal','BANEAR_USUARIO','USUARIOS','Usuario deshabilitado: olgaramosdelacruz@pucp.edu.pe (ID: 17)',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:04:19','EXITOSO',NULL),(99,1,'Admin Principal','CREAR_USUARIO','USUARIOS','Usuario creado: olgaramosdelacruz@gmail.com (ID: 4), Rol: Productor',NULL,'{\"rol\": {\"idRol\": 3, \"nombre\": \"Productor\"}, \"email\": \"olgaramosdelacruz@gmail.com\", \"activo\": true, \"nombres\": \"Olguita\", \"apellidos\": \"Ramos\", \"idUsuario\": 4, \"cuentaActivada\": true, \"fechaActivacion\": \"Nov 17, 2025, 11:45:19 AM\"}','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:04:56','EXITOSO',NULL),(100,1,'Admin Principal','EDITAR_USUARIO','USUARIOS','Usuario actualizado: olgaramosdelacruz@gmail.com (ID: 4)','{\"rol\": {\"idRol\": 3, \"nombre\": \"Productor\"}, \"email\": \"olgaramosdelacruz@gmail.com\", \"activo\": true, \"nombres\": \"Olguita\", \"apellidos\": \"Ramos\", \"idUsuario\": 4, \"cuentaActivada\": false}','{\"rol\": {\"idRol\": 2, \"nombre\": \"Logística\"}, \"email\": \"olgaramosdelacruz@gmail.com\", \"activo\": true, \"nombres\": \"Olguita\", \"apellidos\": \"Ramos\", \"idUsuario\": 4, \"cuentaActivada\": false}','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:07:17','EXITOSO',NULL),(101,4,'Olguita Ramos','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:11:05','EXITOSO',NULL),(102,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:11:19','EXITOSO',NULL),(103,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:25:21','EXITOSO',NULL),(104,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:27:32','EXITOSO',NULL),(105,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:28:58','EXITOSO',NULL),(106,2,'Sergio Meneses','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:30:38','EXITOSO',NULL),(107,13,'Luis Lingan','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:34:39','EXITOSO',NULL),(108,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:38:17','EXITOSO',NULL),(109,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:41:34','EXITOSO',NULL),(111,13,'Luis Lingan','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:43:53','EXITOSO',NULL),(112,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:45:21','EXITOSO',NULL),(113,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 19:08:00','EXITOSO',NULL),(114,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 19:11:39','EXITOSO',NULL),(115,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 19:13:22','EXITOSO',NULL),(116,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 19:28:54','EXITOSO',NULL),(117,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 19:32:32','EXITOSO',NULL),(119,13,'Luis Lingan','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 19:34:16','EXITOSO',NULL),(120,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 19:38:50','EXITOSO',NULL),(121,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 20:27:32','EXITOSO',NULL),(122,13,'Luis Lingan','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:13:04','EXITOSO',NULL),(123,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:15:15','EXITOSO',NULL),(124,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:15:38','EXITOSO',NULL),(125,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:25:09','EXITOSO',NULL),(126,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:26:05','EXITOSO',NULL),(127,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:27:47','EXITOSO',NULL),(128,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:28:40','EXITOSO',NULL),(129,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:33:27','EXITOSO',NULL),(130,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:34:23','EXITOSO',NULL),(131,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:36:17','EXITOSO',NULL),(132,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:40:15','EXITOSO',NULL),(133,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 127.0.0.1',NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:41:27','EXITOSO',NULL),(134,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 127.0.0.1',NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:41:28','EXITOSO',NULL),(135,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:45:43','EXITOSO',NULL),(136,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:52:07','EXITOSO',NULL),(137,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:54:20','EXITOSO',NULL),(138,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:55:00','EXITOSO',NULL),(139,9,'Jairo Cuadros','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 21:59:50','EXITOSO',NULL),(140,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 22:01:28','EXITOSO',NULL),(141,1,'Admin Principal','LOGIN','SEGURIDAD','Login exitoso desde IP: 0:0:0:0:0:0:0:1',NULL,NULL,'0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-12-08 22:02:56','EXITOSO',NULL);
/*!40000 ALTER TABLE `auditoria_sistema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_tokens`
--

DROP TABLE IF EXISTS `auditoria_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoria_tokens` (
  `id_auditoria` int NOT NULL AUTO_INCREMENT,
  `tipo_token` enum('ACTIVACION','RECUPERACION') COLLATE utf8mb4_unicode_ci NOT NULL,
  `usuario_id` int unsigned DEFAULT NULL COMMENT 'NULL si el usuario no existe',
  `email_solicitado` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Email usado en la solicitud',
  `token_id` int DEFAULT NULL COMMENT 'ID del token relacionado',
  `accion` enum('CREADO','USADO','EXPIRADO','INVALIDO','BLOQUEADO') COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_accion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `detalles` text COLLATE utf8mb4_unicode_ci COMMENT 'Detalles adicionales de la acción',
  PRIMARY KEY (`id_auditoria`),
  KEY `idx_tipo_token` (`tipo_token`),
  KEY `idx_usuario_id` (`usuario_id`),
  KEY `idx_fecha_accion` (`fecha_accion`),
  KEY `idx_accion` (`accion`),
  CONSTRAINT `auditoria_tokens_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Auditoría completa de todas las operaciones con tokens';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_tokens`
--

LOCK TABLES `auditoria_tokens` WRITE;
/*!40000 ALTER TABLE `auditoria_tokens` DISABLE KEYS */;
INSERT INTO `auditoria_tokens` VALUES (1,'RECUPERACION',1,'admin@telito.com',NULL,'CREADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:38:32','Token de recuperación creado'),(2,'ACTIVACION',2,NULL,NULL,'CREADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:51:03','Token de activación creado'),(3,'ACTIVACION',2,NULL,NULL,'CREADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:57:47','Token de activación creado'),(4,'ACTIVACION',2,NULL,NULL,'USADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:57:59','Token usado exitosamente para activar cuenta'),(5,'RECUPERACION',2,'sergiomeneses893@gmail.com',NULL,'CREADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 16:59:58','Token de recuperación creado'),(6,'RECUPERACION',2,'sergiomeneses893@gmail.com',NULL,'CREADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 17:03:01','Token de recuperación creado'),(7,'RECUPERACION',2,'sergiomeneses893@gmail.com',NULL,'CREADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 17:03:56','Token de recuperación creado'),(8,'RECUPERACION',2,NULL,NULL,'USADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 17:04:05','Token validado para cambio de contraseña'),(9,'RECUPERACION',2,NULL,NULL,'USADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-17 17:04:22','Token validado para cambio de contraseña'),(10,'RECUPERACION',NULL,NULL,1,'EXPIRADO',NULL,NULL,'2025-11-17 18:25:15','Token expirado automáticamente'),(11,'RECUPERACION',NULL,NULL,2,'EXPIRADO',NULL,NULL,'2025-11-17 18:25:15','Token expirado automáticamente'),(12,'RECUPERACION',NULL,NULL,3,'EXPIRADO',NULL,NULL,'2025-11-17 18:25:15','Token expirado automáticamente'),(13,'RECUPERACION',2,'sergiomeneses893@gmail.com',NULL,'CREADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 16:35:10','Token de recuperación creado'),(14,'RECUPERACION',2,NULL,NULL,'USADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 16:35:25','Token validado para cambio de contraseña'),(15,'RECUPERACION',2,NULL,NULL,'USADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-18 16:35:53','Token validado para cambio de contraseña'),(16,'ACTIVACION',NULL,NULL,1,'EXPIRADO',NULL,NULL,'2025-11-19 17:25:15','Token expirado automáticamente'),(17,'ACTIVACION',17,NULL,NULL,'CREADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:02:52','Token de activación creado'),(18,'ACTIVACION',4,NULL,NULL,'CREADO','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','2025-11-23 16:04:52','Token de activación creado'),(19,'ACTIVACION',NULL,NULL,3,'EXPIRADO',NULL,NULL,'2025-11-25 16:25:15','Token expirado automáticamente'),(20,'ACTIVACION',NULL,NULL,4,'EXPIRADO',NULL,NULL,'2025-11-25 16:25:15','Token expirado automáticamente');
/*!40000 ALTER TABLE `auditoria_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `id_categoria` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'Bebidas'),(2,'Snacks'),(3,'Lácteos'),(4,'Enlatados'),(5,'Limpieza'),(6,'Higiene'),(7,'Cereales'),(8,'Carnes'),(9,'Verduras'),(10,'Frutas');
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id_cliente` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `ruc_dni` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id_cliente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conductores`
--

DROP TABLE IF EXISTS `conductores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conductores` (
  `id_conductor` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre_completo` varchar(255) NOT NULL,
  `licencia` varchar(50) NOT NULL,
  PRIMARY KEY (`id_conductor`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conductores`
--

LOCK TABLES `conductores` WRITE;
/*!40000 ALTER TABLE `conductores` DISABLE KEYS */;
INSERT INTO `conductores` VALUES (1,'her','A001'),(2,'locazo','DYF377');
/*!40000 ALTER TABLE `conductores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `configuracion_sistema`
--

DROP TABLE IF EXISTS `configuracion_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `configuracion_sistema` (
  `id_config` int unsigned NOT NULL AUTO_INCREMENT,
  `clave` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Clave única de la configuración',
  `valor` text COLLATE utf8mb4_unicode_ci COMMENT 'Valor de la configuración',
  `tipo` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'STRING' COMMENT 'STRING, NUMBER, BOOLEAN, JSON',
  `categoria` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'EMAIL, SISTEMA, NOTIFICACIONES, SEGURIDAD, etc.',
  `descripcion` text COLLATE utf8mb4_unicode_ci COMMENT 'Descripción de qué hace esta configuración',
  `editable` tinyint(1) DEFAULT '1' COMMENT 'Si el administrador puede editar este valor',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `usuario_actualizacion` int unsigned DEFAULT NULL COMMENT 'Usuario que actualizó por última vez',
  PRIMARY KEY (`id_config`),
  UNIQUE KEY `clave` (`clave`),
  KEY `idx_clave` (`clave`),
  KEY `idx_categoria` (`categoria`),
  KEY `usuario_actualizacion` (`usuario_actualizacion`),
  CONSTRAINT `configuracion_sistema_ibfk_1` FOREIGN KEY (`usuario_actualizacion`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuracion_sistema`
--

LOCK TABLES `configuracion_sistema` WRITE;
/*!40000 ALTER TABLE `configuracion_sistema` DISABLE KEYS */;
INSERT INTO `configuracion_sistema` VALUES (1,'email.smtp.host','smtp.gmail.com','STRING','EMAIL','Servidor SMTP para envío de correos',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(2,'email.smtp.port','587','NUMBER','EMAIL','Puerto SMTP',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(3,'email.from','','STRING','EMAIL','Email remitente por defecto',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(4,'email.from.name','TELITO BODEGUERO','STRING','EMAIL','Nombre del remitente',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(5,'email.enabled','true','BOOLEAN','EMAIL','Habilitar/deshabilitar envío de correos',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(6,'notificaciones.bienvenida.enabled','true','BOOLEAN','NOTIFICACIONES','Enviar correo de bienvenida a nuevos usuarios',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(7,'notificaciones.actualizacion.enabled','true','BOOLEAN','NOTIFICACIONES','Enviar correo cuando se actualiza un usuario',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(8,'notificaciones.alertas.enabled','true','BOOLEAN','NOTIFICACIONES','Enviar correos de alertas automáticas',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(9,'notificaciones.reportes.enabled','true','BOOLEAN','NOTIFICACIONES','Permitir envío de reportes por correo',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(10,'sistema.nombre','TELITO BODEGUERO','STRING','SISTEMA','Nombre del sistema',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(11,'sistema.timezone','America/Lima','STRING','SISTEMA','Zona horaria del sistema',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(12,'sistema.idioma','es','STRING','SISTEMA','Idioma por defecto',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(13,'sistema.paginacion.size','10','NUMBER','SISTEMA','Tamaño de página por defecto',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(14,'sistema.auditoria.enabled','true','BOOLEAN','SISTEMA','Habilitar registro de auditoría',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(15,'sistema.auditoria.retention.days','365','NUMBER','SISTEMA','Días de retención de registros de auditoría',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(16,'seguridad.password.min.length','8','NUMBER','SEGURIDAD','Longitud mínima de contraseña',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(17,'seguridad.password.require.uppercase','false','BOOLEAN','SEGURIDAD','Requerir mayúsculas en contraseña',1,'2025-11-17 04:16:33','2025-11-17 04:16:33',NULL),(18,'seguridad.password.require.numbers','false','BOOLEAN','SEGURIDAD','Requerir números en contraseña',1,'2025-11-17 04:16:33','2025-11-17 04:16:33',NULL),(19,'seguridad.session.timeout','30','NUMBER','SEGURIDAD','Timeout de sesión en minutos',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(20,'seguridad.max.login.attempts','5','NUMBER','SEGURIDAD','Intentos máximos de login antes de bloquear',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(21,'reportes.excel.max.rows','10000','NUMBER','REPORTES','Máximo de filas en reportes Excel',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1),(22,'reportes.email.max.size.mb','10','NUMBER','REPORTES','Tamaño máximo de adjuntos en MB',1,'2025-11-17 04:16:33','2025-12-08 22:03:07',1);
/*!40000 ALTER TABLE `configuracion_sistema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `distritos`
--

DROP TABLE IF EXISTS `distritos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `distritos` (
  `idDistrito` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) NOT NULL,
  `zona_id` int unsigned NOT NULL,
  PRIMARY KEY (`idDistrito`),
  KEY `fk_Distritos_Zonas_idx` (`zona_id`),
  CONSTRAINT `fk_Distritos_Zonas` FOREIGN KEY (`zona_id`) REFERENCES `zonas` (`idZona`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `distritos`
--

LOCK TABLES `distritos` WRITE;
/*!40000 ALTER TABLE `distritos` DISABLE KEYS */;
INSERT INTO `distritos` VALUES (1,'San Isidro',4),(2,'Miraflores',4),(3,'Surco',4),(4,'San Miguel',4),(6,'Comas',1),(7,'Carabayllo',1),(8,'Villa El Salvador',2),(9,'Chorrillos',4),(10,'Ate',3),(11,'La Molina',3),(12,'Lince',4),(13,'Cercado de Lima',4),(22,'Ancon',1),(23,'Santa Rosa',1),(25,'Puente Piedra',1),(27,'Los Olivos',1),(28,'San Martín de Porres',1),(29,'Independencia',1),(30,'San Juan de Miraflores',2),(31,'Villa María del Triunfo',2),(33,'Pachacamac',2),(34,'Lurin',2),(35,'Punta Hermosa',2),(36,'Punta Negra',2),(37,'San Bartolo',2),(38,'Santa María del Mar',2),(39,'Pucusana',2),(40,'San Juan de Lurigancho',3),(41,'Lurigancho',3),(43,'El Agustino',3),(44,'Santa Anita',3),(46,'Cieneguilla',3),(47,'Rimac',4),(49,'Breña',4),(50,'Pueblo Libre',4),(51,'Magdalena',4),(52,'Jesus María',4),(53,'La Victoria',4),(57,'Surquillo',4),(58,'San Borja',4),(59,'Santiago de Surco',4),(60,'Barranco',4),(62,'San Luis',4);
/*!40000 ALTER TABLE `distritos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `incidencias_almacen`
--

DROP TABLE IF EXISTS `incidencias_almacen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `incidencias_almacen` (
  `id_incidencia` int unsigned NOT NULL AUTO_INCREMENT,
  `lote_id` int unsigned NOT NULL,
  `producto_id` int unsigned NOT NULL,
  `tipo_incidencia` enum('Faltante','Sobrante') COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad_reportada` int unsigned NOT NULL,
  `cantidad_sistema` int unsigned NOT NULL,
  `diferencia` int NOT NULL COMMENT 'cantidad_reportada - cantidad_sistema (puede ser negativo)',
  `motivo` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `estado` enum('Pendiente','En Revisión','Resuelta','Cerrada') COLLATE utf8mb4_unicode_ci DEFAULT 'Pendiente',
  `usuario_reporte_id` int unsigned NOT NULL COMMENT 'Usuario de almacén que reportó',
  `usuario_resolucion_id` int unsigned DEFAULT NULL COMMENT 'Administrador que resolvió',
  `fecha_reporte` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_resolucion` timestamp NULL DEFAULT NULL,
  `observaciones_resolucion` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id_incidencia`),
  KEY `idx_lote` (`lote_id`),
  KEY `idx_producto` (`producto_id`),
  KEY `idx_usuario_reporte` (`usuario_reporte_id`),
  KEY `idx_estado` (`estado`),
  KEY `idx_fecha_reporte` (`fecha_reporte`),
  KEY `idx_tipo` (`tipo_incidencia`),
  KEY `usuario_resolucion_id` (`usuario_resolucion_id`),
  CONSTRAINT `incidencias_almacen_ibfk_1` FOREIGN KEY (`lote_id`) REFERENCES `lotes` (`id_lote`) ON DELETE RESTRICT,
  CONSTRAINT `incidencias_almacen_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id_producto`) ON DELETE RESTRICT,
  CONSTRAINT `incidencias_almacen_ibfk_3` FOREIGN KEY (`usuario_reporte_id`) REFERENCES `usuarios` (`id_usuario`) ON DELETE RESTRICT,
  CONSTRAINT `incidencias_almacen_ibfk_4` FOREIGN KEY (`usuario_resolucion_id`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `incidencias_almacen`
--

LOCK TABLES `incidencias_almacen` WRITE;
/*!40000 ALTER TABLE `incidencias_almacen` DISABLE KEYS */;
/*!40000 ALTER TABLE `incidencias_almacen` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lotes`
--

DROP TABLE IF EXISTS `lotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lotes` (
  `id_lote` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo_lote` varchar(100) NOT NULL,
  `producto_id` int unsigned NOT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'No Registrado',
  `ubicacion_id` int unsigned NOT NULL,
  `stock_actual` int unsigned NOT NULL DEFAULT '0',
  `costo_produccion` decimal(10,2) DEFAULT NULL COMMENT 'Costo de producción por unidad del lote',
  `fecha_vencimiento` date DEFAULT NULL,
  `distrito_id` int unsigned NOT NULL,
  PRIMARY KEY (`id_lote`),
  UNIQUE KEY `codigo_lote` (`codigo_lote`),
  KEY `fk_lote_producto` (`producto_id`),
  KEY `fk_lote_ubicacion` (`ubicacion_id`),
  KEY `fk_lote_distrito` (`distrito_id`),
  CONSTRAINT `fk_lote_distrito` FOREIGN KEY (`distrito_id`) REFERENCES `distritos` (`idDistrito`),
  CONSTRAINT `fk_lote_producto` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id_producto`),
  CONSTRAINT `fk_lote_ubicacion` FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicaciones` (`id_ubicacion`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lotes`
--

LOCK TABLES `lotes` WRITE;
/*!40000 ALTER TABLE `lotes` DISABLE KEYS */;
INSERT INTO `lotes` VALUES (1,'L--0001',1,'Registrado',10,60,NULL,'2025-10-31',13),(2,'L--0002',2,'Registrado',10,0,NULL,'2025-11-05',13),(3,'L--0003',3,'No Registrado',11,108,NULL,'2025-11-25',13),(4,'L--0004',4,'No Registrado',11,10,NULL,'2026-01-29',13),(5,'L--0005',5,'Registrado',9,1,NULL,'2026-02-19',13),(6,'L--0006',6,'No Registrado',11,0,NULL,'2025-11-05',13),(7,'L--0007',7,'Registrado',11,0,NULL,'2025-11-09',13),(8,'L--0008',8,'No Registrado',11,246,NULL,'2025-11-29',13),(9,'L--0009',9,'No Registrado',11,0,NULL,'2025-11-20',13),(10,'L--0010',10,'No Registrado',11,560,NULL,'2025-11-15',13),(11,'L--0011',11,'No Registrado',11,0,NULL,'2025-11-08',13),(12,'L--0012',11,'No Registrado',11,80,NULL,'2025-11-08',13),(13,'L--0013',12,'Registrado',9,0,NULL,'2025-11-22',13),(14,'L--0014',13,'No Registrado',11,48,NULL,'2025-11-29',13),(15,'L--0015',14,'Registrado',9,0,NULL,'2025-11-15',13),(16,'L--0016',15,'Registrado',5,0,NULL,'2025-11-15',13),(17,'L--0017',16,'Registrado',9,0,NULL,'2025-11-22',13),(18,'L--0018',17,'Registrado',9,0,NULL,'2025-11-15',13),(19,'L--0019',18,'No Registrado',11,160,NULL,'2025-11-15',13),(20,'L--0020',19,'No Registrado',12,16,1.50,'2025-11-28',13),(21,'L--0021',20,'No Registrado',12,800,NULL,'2025-11-24',13),(26,'L--0022',20,'Registrado',12,600,NULL,'2025-11-24',13),(27,'L--0023',21,'No Registrado',12,0,20.00,'2025-11-25',13),(28,'L--0024',21,'Registrado',9,0,NULL,'2025-11-25',13);
/*!40000 ALTER TABLE `lotes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movimientos_inventario`
--

DROP TABLE IF EXISTS `movimientos_inventario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movimientos_inventario` (
  `id_movimiento` int unsigned NOT NULL AUTO_INCREMENT,
  `lote_id` int unsigned NOT NULL,
  `usuario_id` int unsigned NOT NULL,
  `pedido_id` int unsigned DEFAULT NULL,
  `orden_compra_id` int unsigned DEFAULT NULL,
  `tipo` enum('Entrada','Salida','Ajuste') NOT NULL,
  `cantidad` int unsigned NOT NULL,
  `motivo` text,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_movimiento`),
  KEY `fk_mov_lote` (`lote_id`),
  KEY `fk_mov_usuario` (`usuario_id`),
  KEY `fk_mov_pedido` (`pedido_id`),
  KEY `fk_mov_oc` (`orden_compra_id`),
  CONSTRAINT `fk_mov_lote` FOREIGN KEY (`lote_id`) REFERENCES `lotes` (`id_lote`),
  CONSTRAINT `fk_mov_oc` FOREIGN KEY (`orden_compra_id`) REFERENCES `ordenes_compra` (`id_orden_compra`),
  CONSTRAINT `fk_mov_pedido` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id_pedido`),
  CONSTRAINT `fk_mov_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimientos_inventario`
--

LOCK TABLES `movimientos_inventario` WRITE;
/*!40000 ALTER TABLE `movimientos_inventario` DISABLE KEYS */;
INSERT INTO `movimientos_inventario` VALUES (1,1,4,NULL,1,'Entrada',10,'Recepción de OC: OC001','2025-10-29 03:09:54'),(2,2,4,NULL,3,'Entrada',25,'Recepción de OC: OC003','2025-10-29 03:35:45'),(3,2,4,NULL,NULL,'Salida',250,'Plan de transporte: PT001','2025-10-29 03:45:30'),(4,4,3,NULL,5,'Salida',60,'Asignación a orden de compra: null','2025-11-02 22:10:06'),(5,5,3,NULL,6,'Salida',2,'Asignación a orden de compra: null','2025-11-02 22:15:42'),(6,5,4,NULL,6,'Entrada',2,'Recepción de OC: OC006','2025-11-02 22:17:47'),(7,6,3,NULL,7,'Salida',24,'Asignación a orden de compra: null','2025-11-02 22:34:11'),(8,7,3,NULL,8,'Salida',16,'Asignación a orden de compra: null','2025-11-02 22:40:20'),(9,7,4,NULL,8,'Entrada',4,'Recepción de OC: OC008','2025-11-02 22:42:08'),(10,7,4,NULL,NULL,'Salida',8,'Plan de transporte: PT006','2025-11-02 22:53:29'),(11,8,2,NULL,10,'Salida',24,'Asignación a orden de compra: null','2025-11-04 03:59:19'),(12,9,2,NULL,11,'Salida',24,'Asignación a orden de compra: null','2025-11-04 04:04:32'),(13,10,2,NULL,12,'Salida',1120,'Asignación a orden de compra: null','2025-11-04 04:08:17'),(14,11,2,NULL,14,'Salida',120,'Asignación a orden de compra: null','2025-11-04 04:16:07'),(15,12,2,NULL,16,'Salida',20,'Asignación a orden de compra: null','2025-11-04 04:21:38'),(16,13,2,NULL,17,'Salida',5,'Asignación a orden de compra: null','2025-11-04 04:27:08'),(17,13,13,NULL,17,'Entrada',1,'Recepción de OC: OC017','2025-11-04 04:37:56'),(18,13,13,NULL,NULL,'Salida',60,'Plan de transporte: PT007','2025-11-04 04:45:18'),(19,14,2,NULL,18,'Salida',72,'Asignación a orden de compra: null','2025-11-06 13:46:54'),(20,15,2,NULL,19,'Salida',24,'Asignación a orden de compra: null','2025-11-12 22:05:45'),(21,15,3,NULL,19,'Entrada',3,'Recepción de OC: OC019','2025-11-12 22:06:58'),(22,15,3,NULL,NULL,'Salida',56,'Plan de transporte: PT008','2025-11-12 22:07:57'),(23,16,2,NULL,20,'Salida',240,'Asignación a orden de compra: null','2025-11-12 23:37:23'),(24,16,13,NULL,20,'Entrada',2,'Recepción de OC: OC020','2025-11-12 23:38:22'),(25,16,13,NULL,NULL,'Salida',120,'Plan de transporte: PT009','2025-11-12 23:39:29'),(26,17,2,NULL,21,'Salida',8,'Asignación a orden de compra: null','2025-11-13 01:46:56'),(27,17,3,NULL,21,'Entrada',2,'Recepción de OC: OC021','2025-11-13 01:49:08'),(28,18,2,NULL,24,'Salida',100,'Asignación a orden de compra: null','2025-11-13 04:29:11'),(29,18,13,NULL,24,'Entrada',2,'Recepción de OC: OC024','2025-11-13 04:47:01'),(30,18,13,NULL,NULL,'Salida',100,'Plan de transporte: PT010','2025-11-13 04:52:11'),(31,21,2,NULL,26,'Salida',600,'Asignación a orden de compra: null','2025-11-23 02:09:18'),(32,26,13,NULL,26,'Entrada',600,'Recepción de OC: OC026 (3 paquetes = 600 unidades)','2025-11-23 02:24:02'),(33,27,2,NULL,27,'Salida',36,'Asignación a orden de compra: null','2025-11-23 16:28:20'),(34,28,13,NULL,27,'Entrada',36,'Recepción de OC: OC027 (6 paquetes = 36 unidades)','2025-11-23 16:41:01'),(35,28,13,NULL,NULL,'Salida',36,'Plan de transporte: PT011','2025-11-23 16:44:40');
/*!40000 ALTER TABLE `movimientos_inventario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ordenes_compra`
--

DROP TABLE IF EXISTS `ordenes_compra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ordenes_compra` (
  `id_orden_compra` int unsigned NOT NULL AUTO_INCREMENT,
  `numero_Orden` varchar(50) DEFAULT NULL,
  `productor_id` int unsigned NOT NULL,
  `producto_id` int unsigned NOT NULL,
  `cantidad` int unsigned NOT NULL,
  `usuario_id` int unsigned NOT NULL,
  `estado` enum('Pendiente','Aprobado','Rechazado','Recibido','En Proceso') NOT NULL,
  `monto_total` decimal(10,2) NOT NULL,
  `lote_id` int unsigned DEFAULT NULL,
  `distrito_id` int unsigned NOT NULL DEFAULT '13',
  PRIMARY KEY (`id_orden_compra`),
  UNIQUE KEY `numero_Orden` (`numero_Orden`),
  KEY `fk_oc_proveedor` (`productor_id`),
  KEY `fk_oc_producto` (`producto_id`),
  KEY `fk_oc_usuario` (`usuario_id`),
  KEY `lote_id` (`lote_id`),
  KEY `fk_oc_distrito` (`distrito_id`),
  CONSTRAINT `fk_oc_distrito` FOREIGN KEY (`distrito_id`) REFERENCES `distritos` (`idDistrito`),
  CONSTRAINT `fk_oc_producto` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id_producto`),
  CONSTRAINT `fk_oc_productor` FOREIGN KEY (`productor_id`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `fk_oc_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `ordenes_compra_ibfk_1` FOREIGN KEY (`lote_id`) REFERENCES `lotes` (`id_lote`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ordenes_compra`
--

LOCK TABLES `ordenes_compra` WRITE;
/*!40000 ALTER TABLE `ordenes_compra` DISABLE KEYS */;
INSERT INTO `ordenes_compra` VALUES (1,NULL,3,1,10,2,'Aprobado',180.00,1,1),(2,NULL,3,2,10,2,'En Proceso',40.00,NULL,13),(3,NULL,3,2,25,2,'Aprobado',100.00,2,4),(4,NULL,3,1,10,2,'En Proceso',180.00,NULL,13),(5,NULL,3,4,6,2,'Aprobado',42.00,4,7),(6,NULL,3,5,2,2,'Aprobado',30.00,5,13),(7,NULL,3,6,4,2,'Rechazado',55.96,6,13),(8,NULL,3,7,4,2,'Aprobado',80.00,7,13),(9,NULL,3,7,4,2,'Pendiente',80.00,NULL,9),(10,NULL,2,8,4,9,'Pendiente',140.00,8,13),(11,NULL,2,9,2,9,'Pendiente',68.00,9,13),(12,NULL,2,10,20,14,'Pendiente',240.00,10,13),(13,NULL,2,9,3,14,'En Proceso',102.00,NULL,9),(14,NULL,2,11,12,9,'Pendiente',1344.00,11,10),(15,NULL,2,11,3,3,'En Proceso',336.00,NULL,9),(16,NULL,2,11,2,3,'Pendiente',224.00,12,2),(17,NULL,2,12,1,3,'Aprobado',12.00,13,13),(18,NULL,2,13,12,3,'Aprobado',96.00,14,7),(19,NULL,2,14,3,9,'Aprobado',63.00,15,7),(20,NULL,2,15,2,9,'Aprobado',42.00,16,13),(21,NULL,2,16,2,9,'Aprobado',24.00,17,4),(22,NULL,2,16,3,9,'Recibido',36.00,NULL,13),(23,NULL,2,16,3,9,'Recibido',36.00,NULL,13),(24,NULL,2,17,2,9,'Aprobado',24.00,18,13),(25,NULL,2,18,1,3,'Recibido',20.00,NULL,1),(26,NULL,2,20,3,9,'Aprobado',24.00,21,7),(27,NULL,2,21,6,9,'Aprobado',180.00,27,7);
/*!40000 ALTER TABLE `ordenes_compra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parametros_sistema`
--

DROP TABLE IF EXISTS `parametros_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parametros_sistema` (
  `id_parametro` int unsigned NOT NULL AUTO_INCREMENT,
  `clave` varchar(100) NOT NULL,
  `valor` text NOT NULL,
  `descripcion` text,
  `tipo` enum('STRING','INTEGER','BOOLEAN','DECIMAL') NOT NULL DEFAULT 'STRING',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_parametro`),
  UNIQUE KEY `unique_clave` (`clave`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parametros_sistema`
--

LOCK TABLES `parametros_sistema` WRITE;
/*!40000 ALTER TABLE `parametros_sistema` DISABLE KEYS */;
INSERT INTO `parametros_sistema` VALUES (1,'STOCK_MINIMO_GLOBAL','20','Stock mínimo global por defecto.','INTEGER',1,'2025-10-29 01:18:26','2025-10-29 01:18:26'),(2,'DIAS_ALERTA_VENCIMIENTO','10','Días de anticipación para alertas de vencimiento por defecto.','INTEGER',1,'2025-10-29 01:18:26','2025-10-29 01:18:26'),(3,'HABILITAR_ALERTAS_EMAIL','true','Habilitar envío de alertas por email.','BOOLEAN',1,'2025-10-29 01:18:26','2025-10-29 01:18:26'),(4,'EMAIL_SOPORTE','soporte@telito.com','Email para reportes de errores y soporte.','STRING',1,'2025-10-29 01:18:26','2025-10-29 01:18:26');
/*!40000 ALTER TABLE `parametros_sistema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido_items`
--

DROP TABLE IF EXISTS `pedido_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido_items` (
  `id_pedido_item` int unsigned NOT NULL AUTO_INCREMENT,
  `pedido_id` int unsigned NOT NULL,
  `producto_id` int unsigned NOT NULL,
  `cantidad_requerida` int unsigned NOT NULL,
  `cantidad_recogida` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_pedido_item`),
  KEY `fk_pi_pedido` (`pedido_id`),
  KEY `fk_pi_producto` (`producto_id`),
  CONSTRAINT `fk_pi_pedido` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id_pedido`),
  CONSTRAINT `fk_pi_producto` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id_producto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido_items`
--

LOCK TABLES `pedido_items` WRITE;
/*!40000 ALTER TABLE `pedido_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedido_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedidos` (
  `id_pedido` int unsigned NOT NULL AUTO_INCREMENT,
  `numero_pedido` varchar(50) NOT NULL,
  `cliente_id` int unsigned NOT NULL,
  `destino` varchar(255) NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado_preparacion` enum('Pendiente','En preparación','Preparado','Despachado','Cancelado') NOT NULL,
  PRIMARY KEY (`id_pedido`),
  UNIQUE KEY `numero_pedido` (`numero_pedido`),
  KEY `fk_pedido_cliente` (`cliente_id`),
  CONSTRAINT `fk_pedido_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id_cliente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `planes_transporte`
--

DROP TABLE IF EXISTS `planes_transporte`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `planes_transporte` (
  `id_plan` int unsigned NOT NULL AUTO_INCREMENT,
  `numero_plan` varchar(50) NOT NULL,
  `producto_id` int unsigned NOT NULL,
  `lote_id` int unsigned NOT NULL,
  `estado` enum('Pendiente','En Ruta','Entregado','Cancelado','Salida') NOT NULL,
  `conductor_id` int unsigned NOT NULL,
  `vehiculo_id` int unsigned NOT NULL,
  `fecha_entrega` date NOT NULL,
  `distrito_id` int unsigned NOT NULL,
  PRIMARY KEY (`id_plan`),
  UNIQUE KEY `numero_plan` (`numero_plan`),
  KEY `fk_pt_lote` (`lote_id`),
  KEY `fk_pt_conductor` (`conductor_id`),
  KEY `fk_pt_vehiculo` (`vehiculo_id`),
  KEY `fk_pt_distrito` (`distrito_id`),
  CONSTRAINT `fk_pt_conductor` FOREIGN KEY (`conductor_id`) REFERENCES `conductores` (`id_conductor`),
  CONSTRAINT `fk_pt_distrito` FOREIGN KEY (`distrito_id`) REFERENCES `distritos` (`idDistrito`),
  CONSTRAINT `fk_pt_lote` FOREIGN KEY (`lote_id`) REFERENCES `lotes` (`id_lote`),
  CONSTRAINT `fk_pt_vehiculo` FOREIGN KEY (`vehiculo_id`) REFERENCES `vehiculos` (`id_vehiculo`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `planes_transporte`
--

LOCK TABLES `planes_transporte` WRITE;
/*!40000 ALTER TABLE `planes_transporte` DISABLE KEYS */;
INSERT INTO `planes_transporte` VALUES (1,'PT001',2,2,'Salida',1,1,'2025-11-01',4),(2,'PT002',5,5,'Pendiente',1,1,'2025-11-26',4),(3,'PT003',5,5,'Pendiente',1,1,'2025-12-04',59),(4,'PT004',7,7,'Pendiente',1,1,'2025-11-19',4),(5,'PT005',7,7,'Pendiente',1,1,'2025-12-04',4),(6,'PT006',7,7,'Salida',1,1,'2025-11-13',1),(7,'PT007',12,13,'Salida',2,1,'2025-11-28',4),(8,'PT008',14,15,'Salida',1,1,'2025-11-14',11),(9,'PT009',15,16,'Salida',1,1,'2025-11-25',2),(10,'PT010',17,18,'Salida',2,1,'2025-11-19',4),(11,'PT011',21,28,'Salida',1,1,'2025-12-01',7);
/*!40000 ALTER TABLE `planes_transporte` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plantillas_config`
--

DROP TABLE IF EXISTS `plantillas_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plantillas_config` (
  `id_plantilla` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombre descriptivo de la plantilla',
  `tipo_carga` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tipo de carga: productos, lotes, etc.',
  `activo` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Indica si la plantilla está activa',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación de la plantilla',
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de última actualización',
  PRIMARY KEY (`id_plantilla`),
  KEY `idx_tipo_carga` (`tipo_carga`),
  KEY `idx_activo` (`activo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabla para almacenar las configuraciones de plantillas de carga de datos';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plantillas_config`
--

LOCK TABLES `plantillas_config` WRITE;
/*!40000 ALTER TABLE `plantillas_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `plantillas_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plantillas_mapeo_columnas`
--

DROP TABLE IF EXISTS `plantillas_mapeo_columnas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plantillas_mapeo_columnas` (
  `id_mapeo` int NOT NULL AUTO_INCREMENT,
  `plantilla_id` int NOT NULL COMMENT 'ID de la plantilla a la que pertenece este mapeo',
  `columna_excel` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombre de la columna en el archivo Excel',
  `campo_destino` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombre del campo en la base de datos destino',
  `orden` int NOT NULL DEFAULT '0' COMMENT 'Orden de la columna en el mapeo',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del mapeo',
  PRIMARY KEY (`id_mapeo`),
  KEY `idx_plantilla_id` (`plantilla_id`),
  KEY `idx_orden` (`orden`),
  CONSTRAINT `plantillas_mapeo_columnas_ibfk_1` FOREIGN KEY (`plantilla_id`) REFERENCES `plantillas_config` (`id_plantilla`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabla para almacenar el mapeo de columnas de Excel a campos de la base de datos';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plantillas_mapeo_columnas`
--

LOCK TABLES `plantillas_mapeo_columnas` WRITE;
/*!40000 ALTER TABLE `plantillas_mapeo_columnas` DISABLE KEYS */;
/*!40000 ALTER TABLE `plantillas_mapeo_columnas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productos` (
  `id_producto` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo_sku` varchar(50) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text,
  `precio_actual` decimal(10,2) NOT NULL,
  `unidades_por_paquete` int unsigned NOT NULL DEFAULT '1',
  `productor_id` int unsigned NOT NULL,
  `categoria_id` int unsigned NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_producto`),
  UNIQUE KEY `codigo_sku` (`codigo_sku`),
  KEY `fk_prod_usuario` (`productor_id`),
  KEY `fk_prod_categoria` (`categoria_id`),
  CONSTRAINT `fk_prod_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id_categoria`),
  CONSTRAINT `fk_prod_usuario` FOREIGN KEY (`productor_id`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (1,'SKU001','leche','',18.00,6,3,3,1),(2,'SKU002','fideos','',4.00,50,3,7,1),(3,'SKU003','azucar','',8.00,9,5,1,1),(4,'SKU004','vainilla','',7.00,10,3,5,1),(5,'SKU005','queso','',15.00,1,3,4,1),(6,'SKU006','pepsi','',13.99,6,3,1,1),(7,'SKU007','guarana','',20.00,4,3,1,1),(8,'SKU008','leche','',35.00,6,2,3,0),(9,'SKU009','leche','',34.00,12,2,8,1),(10,'SKU010','vainilla','',12.00,56,2,6,1),(11,'SKU011','oreo','',112.00,10,2,5,1),(12,'SKU012','picaras','',12.00,5,2,3,1),(13,'SKU013','casino','',8.00,6,2,2,1),(14,'SKU014','donofrio','Se pondran los helados aca',21.00,8,2,3,1),(15,'SKU015','frejol','',21.00,120,2,9,1),(16,'SKU016','coliflor','',12.00,4,2,9,1),(17,'SKU017','chocochip','',12.00,50,2,7,1),(18,'SKU018','choclito','',20.00,8,2,9,1),(19,'SKU019','cacahuete','prueba de cacahuete',20.00,8,2,1,1),(20,'SKU020','arroz','',8.00,200,2,2,1),(21,'SKU021','yogurt','',30.00,6,2,3,1);
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedores`
--

DROP TABLE IF EXISTS `proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proveedores` (
  `id_proveedor` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  PRIMARY KEY (`id_proveedor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedores`
--

LOCK TABLES `proveedores` WRITE;
/*!40000 ALTER TABLE `proveedores` DISABLE KEYS */;
/*!40000 ALTER TABLE `proveedores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id_rol` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Administrador'),(4,'Almacenero'),(6,'Cliente'),(5,'Conductor'),(2,'Logística'),(3,'Productor');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_minimo_config`
--

DROP TABLE IF EXISTS `stock_minimo_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_minimo_config` (
  `id_stock_minimo` int unsigned NOT NULL AUTO_INCREMENT,
  `producto_id` int unsigned NOT NULL,
  `stock_minimo_producto` int unsigned NOT NULL DEFAULT '10',
  `stock_critico_producto` int unsigned NOT NULL DEFAULT '5',
  `stock_minimo_lote` int unsigned NOT NULL DEFAULT '10',
  `stock_critico_lote` int unsigned NOT NULL DEFAULT '5',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_stock_minimo`),
  UNIQUE KEY `unique_producto_stock` (`producto_id`),
  KEY `fk_stock_producto` (`producto_id`),
  CONSTRAINT `fk_stock_producto` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_minimo_config`
--

LOCK TABLES `stock_minimo_config` WRITE;
/*!40000 ALTER TABLE `stock_minimo_config` DISABLE KEYS */;
INSERT INTO `stock_minimo_config` VALUES (1,2,10,7,5,2,1,'2025-10-29 03:42:16','2025-10-29 03:42:16');
/*!40000 ALTER TABLE `stock_minimo_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tokens_activacion`
--

DROP TABLE IF EXISTS `tokens_activacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tokens_activacion` (
  `id_token` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned NOT NULL,
  `token` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Token único de activación (hash SHA-256)',
  `token_original` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Token original antes del hash (para comparación)',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_expiracion` timestamp NOT NULL COMMENT 'Token expira en 48 horas',
  `usado` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Indica si el token ya fue usado',
  `fecha_uso` timestamp NULL DEFAULT NULL COMMENT 'Fecha en que se usó el token',
  `ip_creacion` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IP desde donde se creó el token',
  `user_agent` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User agent del navegador',
  PRIMARY KEY (`id_token`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_token` (`token`),
  KEY `idx_usuario_id` (`usuario_id`),
  KEY `idx_fecha_expiracion` (`fecha_expiracion`),
  KEY `idx_usado` (`usado`),
  CONSTRAINT `tokens_activacion_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE,
  CONSTRAINT `chk_fecha_expiracion` CHECK ((`fecha_expiracion` > `fecha_creacion`))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabla para gestionar tokens de activación de cuentas con seguridad mejorada';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tokens_activacion`
--

LOCK TABLES `tokens_activacion` WRITE;
/*!40000 ALTER TABLE `tokens_activacion` DISABLE KEYS */;
INSERT INTO `tokens_activacion` VALUES (1,2,'9a57d0140955dd05d42df6f4c8f29198eb2ac0fc2322c525d99b58a3fbb124f1','65b05e1974b44649b511ff4da0577ed954dab761bd5b4c7d96c1731fa46cc96117633982634627242903b5422a6510442c8d2ba4baac1643a5c92dcfd0c98b40','2025-11-17 16:51:03','2025-11-19 16:51:03',1,'2025-11-19 17:25:15','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36'),(2,2,'9cd6e8d1443e51913b503568255872c8d08f3035662170c379cfdf0196b6f702','4207f7556c8644babe8b451a58c32b679ecf917836c84fd7b647c9077a9bd64817633986673226486198bd507e2517f4dbdb3e0ae3005ab7a71456d9c4b4f584','2025-11-17 16:57:47','2025-11-19 16:57:47',1,'2025-11-17 16:57:59','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36'),(3,17,'b917baccb925f33ba814b9c401a6c391bc38c506a597f9afdb5715521693ece2','6ad593a80b724beabfccfedc8f23f376c8f18b77c35f42e4a54007b41cf0ea911763913772618986027b4cc40e3f89a4a4380a8538f132137bd21d27f84f0154','2025-11-23 16:02:52','2025-11-25 16:02:53',1,'2025-11-25 16:25:15','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36'),(4,4,'8917fbfb54a14a70e045ed534f42b05956cfd3967a54e344cbdf57712c1391b1','0b2d0bcf4b284f1c9fb49d185189475ce44de6574336421098f160a6bff31f4c176391389288274708070c735414db04af7b0b1766739eb16cecd2dbdc6049e4','2025-11-23 16:04:52','2025-11-25 16:04:53',1,'2025-11-25 16:25:15','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36');
/*!40000 ALTER TABLE `tokens_activacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tokens_recuperacion`
--

DROP TABLE IF EXISTS `tokens_recuperacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tokens_recuperacion` (
  `id_token` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int unsigned NOT NULL,
  `token` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Token único de recuperación (hash SHA-256)',
  `token_original` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Token original antes del hash',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_expiracion` timestamp NOT NULL COMMENT 'Token expira en 1 hora',
  `usado` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Indica si el token ya fue usado',
  `fecha_uso` timestamp NULL DEFAULT NULL COMMENT 'Fecha en que se usó el token',
  `ip_solicitud` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IP desde donde se solicitó la recuperación',
  `ip_uso` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IP desde donde se usó el token',
  `user_agent` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User agent del navegador',
  `intentos_uso` int NOT NULL DEFAULT '0' COMMENT 'Número de intentos de uso del token',
  PRIMARY KEY (`id_token`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_token` (`token`),
  KEY `idx_usuario_id` (`usuario_id`),
  KEY `idx_fecha_expiracion` (`fecha_expiracion`),
  KEY `idx_usado` (`usado`),
  CONSTRAINT `tokens_recuperacion_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE,
  CONSTRAINT `chk_fecha_expiracion_recuperacion` CHECK ((`fecha_expiracion` > `fecha_creacion`)),
  CONSTRAINT `chk_intentos_uso` CHECK ((`intentos_uso` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabla para gestionar tokens de recuperación de contraseña con seguridad mejorada';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tokens_recuperacion`
--

LOCK TABLES `tokens_recuperacion` WRITE;
/*!40000 ALTER TABLE `tokens_recuperacion` DISABLE KEYS */;
INSERT INTO `tokens_recuperacion` VALUES (1,1,'e382bd300bba544760c1f1a80a1089bcea1c03bb30bb581c37d780371b27ed88','cd8a5043c65c44aebd78bdb883480de8f34b4fe675df44bc9cb1f06796043a671763397512525718307561ed3a8620c493d80dbb67b61740b00a346c90c37994','2025-11-17 16:38:32','2025-11-17 17:38:33',1,'2025-11-17 18:25:15','0:0:0:0:0:0:0:1',NULL,'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',0),(2,2,'a44014098fcda08c61da4b54b76ace7b5ba21a0c65a9e7c85c91b43e0f7c3d8c','a9064b9a372a42e5abbb7b4506917c552abe9c677e254d6a9f1fae8f14afe4b11763398798140395286aae60a773b6e44a68b374c9300de08c2912ba1204e1f4','2025-11-17 16:59:58','2025-11-17 17:59:58',1,'2025-11-17 18:25:15','0:0:0:0:0:0:0:1',NULL,'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',0),(3,2,'55651751591cb0dbcf0b4db649f6fef595e25c98e5263ace89d72ae2ed491ce6','d4808c883aaa4eedb78fb75bf71c7da1d8340d8e6b934c87aa3fede47f3a6f9a17633989814965072993322b7e85ab84fe88958ed5037ea08f876d07e0d40de4','2025-11-17 17:03:01','2025-11-17 18:03:01',1,'2025-11-17 18:25:15','0:0:0:0:0:0:0:1',NULL,'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',0),(4,2,'38f070416e3913ded8d5248c5217200ee6aeb2a90fb5651601ec74b586fd2343','e5dc2049b0234b08b2801770ec62f0c4942613aea584471294114a24d031b39a1763399036686281623e40e1b50ffd4495090ecb93ec415b4a803948dce888b4','2025-11-17 17:03:56','2025-11-17 18:03:57',1,'2025-11-17 17:04:22','0:0:0:0:0:0:0:1','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',2),(5,2,'18ee0a91aea50e131f19275f338809a97613aaa613c5b93cbd8d6e660c3dad95','16b7f43b3cfe467aa28a5d686fbbb7e3056405da07f34b0fa7b0dfe993d14f3017634837109235729071182644af2d74369941413b0d0c8e27dc5a6e9d790854','2025-11-18 16:35:10','2025-11-18 17:35:11',1,'2025-11-18 16:35:53','0:0:0:0:0:0:0:1','0:0:0:0:0:0:0:1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',2);
/*!40000 ALTER TABLE `tokens_recuperacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ubicaciones`
--

DROP TABLE IF EXISTS `ubicaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ubicaciones` (
  `id_ubicacion` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  PRIMARY KEY (`id_ubicacion`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ubicaciones`
--

LOCK TABLES `ubicaciones` WRITE;
/*!40000 ALTER TABLE `ubicaciones` DISABLE KEYS */;
INSERT INTO `ubicaciones` VALUES (1,'Estante A01'),(2,'Estante A02'),(3,'Estante B01'),(4,'Estante B02'),(5,'Cámara Fria 1'),(6,'Cámara Fria 2'),(7,'Rack C01'),(8,'Rack C02'),(9,'Zona Despacho'),(10,'Almacen Seco'),(11,'Cercado'),(12,'Cercado de Lima');
/*!40000 ALTER TABLE `ubicaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id_usuario` int unsigned NOT NULL AUTO_INCREMENT,
  `nombres` varchar(255) NOT NULL,
  `apellidos` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `codigo_productor` varchar(50) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `foto_perfil` varchar(500) DEFAULT NULL,
  `rol_id` int unsigned NOT NULL,
  `cuenta_activada` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Indica si la cuenta ha sido activada por email',
  `fecha_activacion` timestamp NULL DEFAULT NULL COMMENT 'Fecha y hora en que se activó la cuenta',
  `intentos_activacion` int NOT NULL DEFAULT '0' COMMENT 'Número de intentos de activación fallidos',
  `ultimo_intento_activacion` timestamp NULL DEFAULT NULL COMMENT 'Último intento de activación',
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `unique_codigo_productor` (`codigo_productor`),
  KEY `fk_usuario_rol` (`rol_id`),
  CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id_rol`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Admin','Principal','admin@telito.com',NULL,'03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',1,'uploads/perfiles/39b93b5f-da6f-4078-b384-5443e6f54062.jpeg',1,1,'2025-11-17 16:45:19',0,NULL),(2,'Sergio','Meneses','sergiomeneses893@gmail.com','PROD-0002','02db99647fb4ea2df06fc3542961a3690d8095a65e84e5eb6acb13434ee2af56',1,NULL,3,1,'2025-11-17 16:57:59',1,'2025-11-17 16:57:59'),(3,'alejo','gaaa','a20223291@pucp.edu.pe',NULL,'03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',0,NULL,2,1,'2025-11-17 16:45:19',0,NULL),(4,'Olguita','Ramos','olgaramosdelacruz@gmail.com',NULL,'03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',1,NULL,2,1,'2025-11-17 16:45:19',0,NULL),(5,'abraham','gaaa','abrham@productor.com','PROD-0005','03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',0,NULL,3,1,'2025-11-17 16:45:19',0,NULL),(6,'Kent','Jianbin','a20202132@pucp.edu.pe',NULL,'bb30f1397a636757baeff97cb769fb87d752cdd3244da8a4195c882922e20ab7',0,NULL,1,1,'2025-11-17 16:45:19',0,NULL),(8,'Abraham','Ramirez','a20206364@pucp.edu.pe','PROD-0008','6f78f682768bae7911ca6072c322183a390c88bfb3354a7d6616b75ce464b7ee',1,NULL,3,1,'2025-11-17 16:45:19',0,NULL),(9,'Jairo','Cuadros','jairo.cuadros@pucp.edu.pe',NULL,'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f',1,NULL,2,1,'2025-11-17 16:45:19',0,NULL),(10,'Jairo','Cuadros','jairo.cuadros@pucpe.edu.pe',NULL,'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f',0,NULL,2,1,'2025-11-17 16:45:19',0,NULL),(11,'jairo','xd','jairodavidatt@gmail.com','PROD-0011','ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f',0,NULL,3,1,'2025-11-17 16:45:19',0,NULL),(13,'Luis','Lingan','a20230700@pucp.edu.pe',NULL,'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f',1,NULL,4,1,'2025-11-17 16:45:19',0,NULL),(14,'Alejo','aldrolin','aldrolin05@gmail.com',NULL,'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f',1,NULL,2,1,'2025-11-17 16:45:19',0,NULL),(15,'hello','a','hello@gmail.com','PROD-0015','03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',1,NULL,3,1,'2025-11-17 16:45:19',0,NULL),(16,'sergio','Meneses','sergiomeneses89@gmail.com',NULL,'03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',1,NULL,2,1,'2025-11-17 16:45:19',0,NULL),(17,'Olguita','Ramos','olgaramosdelacruz@pucp.edu.pe','PROD-0016','03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',0,NULL,3,0,NULL,0,NULL);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehiculos`
--

DROP TABLE IF EXISTS `vehiculos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehiculos` (
  `id_vehiculo` int unsigned NOT NULL AUTO_INCREMENT,
  `placa` varchar(10) NOT NULL,
  `marca` varchar(50) DEFAULT NULL,
  `modelo` varchar(50) DEFAULT NULL,
  `capacidad_kg` int unsigned NOT NULL,
  PRIMARY KEY (`id_vehiculo`),
  UNIQUE KEY `placa` (`placa`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehiculos`
--

LOCK TABLES `vehiculos` WRITE;
/*!40000 ALTER TABLE `vehiculos` DISABLE KEYS */;
INSERT INTO `vehiculos` VALUES (1,'FGB789','Nissan','toyota',1000);
/*!40000 ALTER TABLE `vehiculos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ventas`
--

DROP TABLE IF EXISTS `ventas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ventas` (
  `id_venta` int unsigned NOT NULL AUTO_INCREMENT,
  `lote_id` int unsigned NOT NULL,
  `cantidad` int unsigned NOT NULL,
  `monto_total` decimal(10,2) NOT NULL,
  `fecha_venta` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_venta`),
  KEY `fk_venta_lote` (`lote_id`),
  CONSTRAINT `fk_venta_lote` FOREIGN KEY (`lote_id`) REFERENCES `lotes` (`id_lote`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ventas`
--

LOCK TABLES `ventas` WRITE;
/*!40000 ALTER TABLE `ventas` DISABLE KEYS */;
/*!40000 ALTER TABLE `ventas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vista_estadisticas_activaciones`
--

DROP TABLE IF EXISTS `vista_estadisticas_activaciones`;
/*!50001 DROP VIEW IF EXISTS `vista_estadisticas_activaciones`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_estadisticas_activaciones` AS SELECT 
 1 AS `total_tokens_creados`,
 1 AS `tokens_usados`,
 1 AS `tokens_pendientes`,
 1 AS `tokens_expirados`,
 1 AS `usuarios_con_tokens`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vista_estadisticas_recuperaciones`
--

DROP TABLE IF EXISTS `vista_estadisticas_recuperaciones`;
/*!50001 DROP VIEW IF EXISTS `vista_estadisticas_recuperaciones`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_estadisticas_recuperaciones` AS SELECT 
 1 AS `total_tokens_creados`,
 1 AS `tokens_usados`,
 1 AS `tokens_pendientes`,
 1 AS `tokens_expirados`,
 1 AS `usuarios_con_tokens`,
 1 AS `promedio_intentos_uso`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `zonas`
--

DROP TABLE IF EXISTS `zonas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `zonas` (
  `idZona` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) NOT NULL,
  PRIMARY KEY (`idZona`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `zonas`
--

LOCK TABLES `zonas` WRITE;
/*!40000 ALTER TABLE `zonas` DISABLE KEYS */;
INSERT INTO `zonas` VALUES (1,'Norte'),(2,'Sur'),(3,'Este'),(4,'Oeste');
/*!40000 ALTER TABLE `zonas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `vista_estadisticas_activaciones`
--

/*!50001 DROP VIEW IF EXISTS `vista_estadisticas_activaciones`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_estadisticas_activaciones` AS select count(0) AS `total_tokens_creados`,sum((case when (`tokens_activacion`.`usado` = true) then 1 else 0 end)) AS `tokens_usados`,sum((case when ((`tokens_activacion`.`usado` = false) and (`tokens_activacion`.`fecha_expiracion` > now())) then 1 else 0 end)) AS `tokens_pendientes`,sum((case when ((`tokens_activacion`.`usado` = false) and (`tokens_activacion`.`fecha_expiracion` < now())) then 1 else 0 end)) AS `tokens_expirados`,count(distinct `tokens_activacion`.`usuario_id`) AS `usuarios_con_tokens` from `tokens_activacion` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vista_estadisticas_recuperaciones`
--

/*!50001 DROP VIEW IF EXISTS `vista_estadisticas_recuperaciones`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_estadisticas_recuperaciones` AS select count(0) AS `total_tokens_creados`,sum((case when (`tokens_recuperacion`.`usado` = true) then 1 else 0 end)) AS `tokens_usados`,sum((case when ((`tokens_recuperacion`.`usado` = false) and (`tokens_recuperacion`.`fecha_expiracion` > now())) then 1 else 0 end)) AS `tokens_pendientes`,sum((case when ((`tokens_recuperacion`.`usado` = false) and (`tokens_recuperacion`.`fecha_expiracion` < now())) then 1 else 0 end)) AS `tokens_expirados`,count(distinct `tokens_recuperacion`.`usuario_id`) AS `usuarios_con_tokens`,avg(`tokens_recuperacion`.`intentos_uso`) AS `promedio_intentos_uso` from `tokens_recuperacion` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-08 17:56:22
