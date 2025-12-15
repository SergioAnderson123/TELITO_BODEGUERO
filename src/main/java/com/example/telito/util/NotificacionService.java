package com.example.telito.util;

import com.example.telito.administrador.daos.NotificacionDAO;
import com.example.telito.administrador.daos.UsuarioDAO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

// Servicio centralizado para gestión de notificaciones unificado
// Maneja creación de notificaciones, determinación de destinatarios y envío de emails
public class NotificacionService {
    
    private static final Logger logger = LoggerFactory.getLogger(NotificacionService.class);
    private static NotificacionDAO notificacionDAO = new NotificacionDAO();
    private static UsuarioDAO usuarioDAO = new UsuarioDAO();
    
    // Constantes para tipos de notificación
    public static class TipoNotificacion {
        // Módulo Almacén
        public static final String STOCK_CRITICO = "STOCK_CRITICO";
        public static final String STOCK_MINIMO = "STOCK_MINIMO";
        public static final String VENCIMIENTO_7_DIAS = "VENCIMIENTO_7_DIAS";
        public static final String VENCIMIENTO_3_DIAS = "VENCIMIENTO_3_DIAS";
        public static final String LOTE_VENCIDO = "LOTE_VENCIDO";
        public static final String INCIDENCIA_REPORTADA = "INCIDENCIA_REPORTADA";
        public static final String AJUSTE_INVENTARIO = "AJUSTE_INVENTARIO";
        public static final String ENTRADA_REGISTRADA = "ENTRADA_REGISTRADA";
        
        // Módulo Logística
        public static final String ORDEN_COMPRA_CREADA = "ORDEN_COMPRA_CREADA";
        public static final String ORDEN_LISTA = "ORDEN_LISTA";
        public static final String PLAN_TRANSPORTE_CREADO = "PLAN_TRANSPORTE_CREADO";
        public static final String PLAN_TRANSPORTE_DESTINADO = "PLAN_TRANSPORTE_DESTINADO";
        public static final String PEDIDO_RECHAZADO = "PEDIDO_RECHAZADO";
        public static final String PEDIDO_COMPLETADO = "PEDIDO_COMPLETADO";
        
        // Módulo Productor
        public static final String ORDEN_CONFIRMADA = "ORDEN_CONFIRMADA";
        public static final String ORDEN_RECHAZADA = "ORDEN_RECHAZADA";
        public static final String ORDEN_LISTA_PRODUCTOR = "ORDEN_LISTA_PRODUCTOR";
        public static final String PRODUCTO_NUEVO = "PRODUCTO_NUEVO";
        
        // Módulo Administrador
        public static final String USUARIO_CREADO = "USUARIO_CREADO";
        public static final String ALERTA_CONFIGURADA = "ALERTA_CONFIGURADA";
        public static final String SISTEMA_ACTUALIZADO = "SISTEMA_ACTUALIZADO";
    }
    
    // Constantes para niveles de prioridad
    public static class Prioridad {
        public static final String CRITICAL = "CRITICAL";
        public static final String WARNING = "WARNING";
        public static final String INFO = "INFO";
    }
    
    // Constantes para nombres de roles (deben coincidir exactamente con los nombres en la BD)
    public static class Rol {
        public static final String ADMINISTRADOR = "Administrador";
        public static final String LOGISTICA = "Logística";
        public static final String PRODUCTOR = "Productor";
        public static final String ALMACEN = "Almacenero";
        public static final String GERENTE_TIENDA = "Gerente de Tienda";
    }
    
    // Crea notificación para un usuario específico
    public static boolean crearNotificacionUsuario(int usuarioId, String tipoNotificacion, 
                                                   String titulo, String mensaje, String prioridad,
                                                   Integer productoId, Integer loteId, 
                                                   Integer pedidoId, Integer ordenCompraId,
                                                   String urlAccion) {
        try {
            boolean exito = notificacionDAO.crearNotificacion(
                usuarioId, tipoNotificacion, titulo, mensaje, prioridad,
                productoId, loteId, pedidoId, ordenCompraId, urlAccion
            );
            
            if (exito) {
                logger.debug("Notificación creada para usuario ID: {} - Tipo: {}", usuarioId, tipoNotificacion);
            } else {
                logger.warn("No se pudo crear notificación para usuario ID: {}", usuarioId);
            }
            
            return exito;
        } catch (Exception e) {
            logger.error("Error al crear notificación para usuario ID: " + usuarioId, e);
            return false;
        }
    }
    
    // Crea notificaciones para todos los usuarios de un rol específico
    public static int crearNotificacionPorRol(String nombreRol, String tipoNotificacion,
                                             String titulo, String mensaje, String prioridad,
                                             Integer productoId, Integer loteId,
                                             Integer pedidoId, Integer ordenCompraId,
                                             String urlAccion, boolean enviarEmail) {
        try {
            List<Integer> usuariosIds = notificacionDAO.obtenerUsuariosPorRol(nombreRol);
            
            if (usuariosIds.isEmpty()) {
                logger.warn("No se encontraron usuarios activos con rol: {}", nombreRol);
                return 0;
            }
            
            int notificacionesCreadas = notificacionDAO.crearNotificacionesMasivas(
                usuariosIds, tipoNotificacion, titulo, mensaje, prioridad,
                productoId, loteId, pedidoId, ordenCompraId, urlAccion
            );
            
            logger.info("Se crearon {} notificaciones para rol: {} - Tipo: {}", 
                       notificacionesCreadas, nombreRol, tipoNotificacion);
            
            // Enviar emails si está configurado
            if (enviarEmail && notificacionesCreadas > 0) {
                enviarNotificacionesPorEmail(usuariosIds, titulo, mensaje, prioridad);
            }
            
            return notificacionesCreadas;
        } catch (Exception e) {
            logger.error("Error al crear notificaciones por rol: " + nombreRol, e);
            return 0;
        }
    }
    
    // Crea notificaciones para múltiples roles
    public static int crearNotificacionPorRoles(List<String> nombresRoles, String tipoNotificacion,
                                                String titulo, String mensaje, String prioridad,
                                                Integer productoId, Integer loteId,
                                                Integer pedidoId, Integer ordenCompraId,
                                                String urlAccion, boolean enviarEmail) {
        int totalCreadas = 0;
        
        for (String rol : nombresRoles) {
            totalCreadas += crearNotificacionPorRol(rol, tipoNotificacion, titulo, mensaje, 
                                                   prioridad, productoId, loteId, pedidoId, 
                                                   ordenCompraId, urlAccion, false);
        }
        
        // Enviar emails una sola vez si está configurado
        if (enviarEmail && totalCreadas > 0) {
            List<Integer> todosUsuarios = new ArrayList<>();
            for (String rol : nombresRoles) {
                todosUsuarios.addAll(notificacionDAO.obtenerUsuariosPorRol(rol));
            }
            enviarNotificacionesPorEmail(todosUsuarios, titulo, mensaje, prioridad);
        }
        
        return totalCreadas;
    }
    
    // Envía notificaciones por email a una lista de usuarios
    private static void enviarNotificacionesPorEmail(List<Integer> usuariosIds, 
                                                     String titulo, String mensaje, 
                                                     String prioridad) {
        try {
            for (Integer usuarioId : usuariosIds) {
                try {
                    com.example.telito.administrador.beans.Usuario usuario = 
                        usuarioDAO.obtenerUsuarioPorId(usuarioId);
                    
                    if (usuario != null && usuario.getEmail() != null && 
                        !usuario.getEmail().trim().isEmpty()) {
                        
                        String asunto = "[" + prioridad + "] " + titulo;
                        String cuerpoEmail = construirCuerpoEmail(mensaje, prioridad);
                        
                        boolean emailEnviado = EmailUtil.sendEmail(
                            usuario.getEmail(), asunto, cuerpoEmail, true
                        );
                        
                        if (emailEnviado) {
                            logger.debug("Email de notificación enviado a: {}", usuario.getEmail());
                        } else {
                            logger.warn("No se pudo enviar email a: {}", usuario.getEmail());
                        }
                    }
                } catch (Exception e) {
                    logger.error("Error al enviar email a usuario ID: " + usuarioId, e);
                }
            }
        } catch (Exception e) {
            logger.error("Error al enviar notificaciones por email", e);
        }
    }
    
    // Construye el cuerpo del email con formato HTML
    private static String construirCuerpoEmail(String mensaje, String prioridad) {
        String colorFondo = "#f8f9fa";
        String colorBorde = "#0dcaf0";
        
        if (Prioridad.CRITICAL.equals(prioridad)) {
            colorFondo = "#fee";
            colorBorde = "#dc3545";
        } else if (Prioridad.WARNING.equals(prioridad)) {
            colorFondo = "#fff3cd";
            colorBorde = "#ffc107";
        }
        
        return "<html><body style='font-family: Arial, sans-serif;'>" +
               "<div style='background: " + colorFondo + "; border-left: 4px solid " + colorBorde + 
               "; padding: 15px; margin: 10px 0; border-radius: 4px;'>" +
               "<p style='margin: 0; color: #212529;'>" + mensaje + "</p>" +
               "</div>" +
               "<p style='color: #6c757d; font-size: 12px;'>Este es un mensaje automático del sistema TELITO BODEGUERO.</p>" +
               "</body></html>";
    }
    
    // ========== MÉTODOS ESPECÍFICOS POR MÓDULO ==========
    
    // MÓDULO ALMACÉN
    
    // Notifica stock crítico (ADMINISTRADOR + LOGISTICA)
    public static int notificarStockCritico(String nombreProducto, Integer productoId, 
                                            Integer loteId, int stockActual, int stockCritico) {
        String titulo = "Stock Crítico Detectado";
        String mensaje = String.format("El producto '%s' tiene stock crítico: %d unidades (umbral: %d). " +
                                       "Se requiere atención inmediata.", nombreProducto, stockActual, stockCritico);
        String urlAccion = "/TELITO_BODEGUERO/administrador/inventario-general";
        
        List<String> roles = new ArrayList<>();
        roles.add(Rol.ADMINISTRADOR);
        roles.add(Rol.LOGISTICA);
        
        return crearNotificacionPorRoles(roles, TipoNotificacion.STOCK_CRITICO, titulo, mensaje,
                                        Prioridad.CRITICAL, productoId, loteId, null, null, 
                                        urlAccion, true);
    }
    
    // Notifica stock mínimo (LOGISTICA)
    public static int notificarStockMinimo(String nombreProducto, Integer productoId, 
                                          Integer loteId, int stockActual, int stockMinimo) {
        String titulo = "Stock en Nivel Mínimo";
        String mensaje = String.format("El producto '%s' ha alcanzado su stock mínimo: %d unidades (umbral: %d). " +
                                       "Considera realizar pedidos de reabastecimiento.", 
                                       nombreProducto, stockActual, stockMinimo);
        String urlAccion = "/TELITO_BODEGUERO/logistica/inventario";
        
        return crearNotificacionPorRol(Rol.LOGISTICA, TipoNotificacion.STOCK_MINIMO, titulo, mensaje,
                                       Prioridad.WARNING, productoId, loteId, null, null, 
                                       urlAccion, false);
    }
    
    // Notifica vencimiento en 7 días (ALMACENERO + LOGISTICA)
    public static int notificarVencimiento7Dias(String nombreProducto, String codigoLote,
                                                Integer productoId, Integer loteId, 
                                                java.sql.Date fechaVencimiento) {
        String titulo = "Vencimiento Próximo (7 días)";
        String mensaje = String.format("El lote '%s' del producto '%s' vence en 7 días (Fecha: %s). " +
                                       "Revisar inventario.", codigoLote, nombreProducto, 
                                       new java.text.SimpleDateFormat("dd/MM/yyyy").format(fechaVencimiento));
        String urlAccion = "/TELITO_BODEGUERO/almacen/lotes";
        
        List<String> roles = new ArrayList<>();
        roles.add(Rol.ALMACEN);
        roles.add(Rol.LOGISTICA);
        
        return crearNotificacionPorRoles(roles, TipoNotificacion.VENCIMIENTO_7_DIAS, titulo, mensaje,
                                        Prioridad.WARNING, productoId, loteId, null, null, 
                                        urlAccion, false);
    }
    
    // Notifica vencimiento en 3 días (ALMACENERO + ADMINISTRADOR)
    public static int notificarVencimiento3Dias(String nombreProducto, String codigoLote,
                                                Integer productoId, Integer loteId,
                                                java.sql.Date fechaVencimiento) {
        String titulo = "Vencimiento Inminente (3 días)";
        String mensaje = String.format("⚠️ URGENTE: El lote '%s' del producto '%s' vence en 3 días (Fecha: %s). " +
                                       "Acción inmediata requerida.", codigoLote, nombreProducto,
                                       new java.text.SimpleDateFormat("dd/MM/yyyy").format(fechaVencimiento));
        String urlAccion = "/TELITO_BODEGUERO/almacen/lotes";
        
        List<String> roles = new ArrayList<>();
        roles.add(Rol.ALMACEN);
        roles.add(Rol.ADMINISTRADOR);
        
        return crearNotificacionPorRoles(roles, TipoNotificacion.VENCIMIENTO_3_DIAS, titulo, mensaje,
                                        Prioridad.CRITICAL, productoId, loteId, null, null, 
                                        urlAccion, true);
    }
    
    // Notifica lote vencido (ADMINISTRADOR)
    public static int notificarLoteVencido(String nombreProducto, String codigoLote,
                                          Integer productoId, Integer loteId,
                                          java.sql.Date fechaVencimiento) {
        String titulo = "Lote Vencido Detectado";
        String mensaje = String.format("🔴 CRÍTICO: El lote '%s' del producto '%s' ha vencido (Fecha: %s). " +
                                       "Revisar y retirar del inventario inmediatamente.", 
                                       codigoLote, nombreProducto,
                                       new java.text.SimpleDateFormat("dd/MM/yyyy").format(fechaVencimiento));
        String urlAccion = "/TELITO_BODEGUERO/administrador/inventario-general";
        
        return crearNotificacionPorRol(Rol.ADMINISTRADOR, TipoNotificacion.LOTE_VENCIDO, titulo, mensaje,
                                      Prioridad.CRITICAL, productoId, loteId, null, null, 
                                      urlAccion, true);
    }
    
    // Notifica incidencia reportada (ADMINISTRADOR)
    public static int notificarIncidenciaReportada(String tipoIncidencia, String descripcion,
                                                   Integer loteId, int usuarioReporteId) {
        String titulo = "Nueva Incidencia Reportada";
        String mensaje = String.format("Se ha reportado una incidencia de tipo '%s': %s", 
                                       tipoIncidencia, descripcion);
        String urlAccion = "/TELITO_BODEGUERO/almacen/incidencias";
        
        return crearNotificacionPorRol(Rol.ADMINISTRADOR, TipoNotificacion.INCIDENCIA_REPORTADA, 
                                      titulo, mensaje, Prioridad.WARNING, null, loteId, null, null, 
                                      urlAccion, false);
    }
    
    // Notifica ajuste de inventario significativo (ADMINISTRADOR)
    public static int notificarAjusteInventario(String nombreProducto, String codigoLote,
                                                Integer productoId, Integer loteId,
                                                int stockAnterior, int stockNuevo, double porcentajeAjuste) {
        if (porcentajeAjuste < 10.0) {
            return 0; // Solo notificar si el ajuste es >= 10%
        }
        
        String titulo = "Ajuste Significativo de Inventario";
        String mensaje = String.format("Se realizó un ajuste de inventario del %.1f%% para el lote '%s' " +
                                       "del producto '%s'. Stock anterior: %d, Stock nuevo: %d.",
                                       porcentajeAjuste, codigoLote, nombreProducto, stockAnterior, stockNuevo);
        String urlAccion = "/TELITO_BODEGUERO/almacen/movimientos";
        
        return crearNotificacionPorRol(Rol.ADMINISTRADOR, TipoNotificacion.AJUSTE_INVENTARIO, 
                                      titulo, mensaje, Prioridad.INFO, productoId, loteId, null, null, 
                                      urlAccion, false);
    }
    
    // Notifica entrada registrada (LOGISTICA)
    public static int notificarEntradaRegistrada(String numeroOrden, Integer ordenCompraId,
                                                String nombreProducto, int cantidad) {
        String titulo = "Entrada de Productos Registrada";
        String mensaje = String.format("Se ha registrado la entrada de %d unidades del producto '%s' " +
                                       "según la orden de compra %s.", cantidad, nombreProducto, numeroOrden);
        String urlAccion = "/TELITO_BODEGUERO/logistica/ordenes";
        
        return crearNotificacionPorRol(Rol.LOGISTICA, TipoNotificacion.ENTRADA_REGISTRADA, 
                                      titulo, mensaje, Prioridad.INFO, null, null, null, ordenCompraId, 
                                      urlAccion, false);
    }
    
    // MÓDULO LOGÍSTICA
    
    // Notifica orden de compra creada (PRODUCTOR)
    public static int notificarOrdenCompraCreada(String numeroOrden, Integer ordenCompraId,
                                                 String nombreProducto, int cantidad,
                                                 int productorId) {
        try {
            String titulo = "Nueva Orden de Compra";
            String mensaje = String.format("Se ha creado una nueva orden de compra %s para %d paquetes " +
                                           "del producto '%s'. Por favor, revisa y confirma.", 
                                           numeroOrden, cantidad, nombreProducto);
            String urlAccion = "/productor/ordenes";
            
            logger.info("Creando notificación ORDEN_COMPRA_CREADA para productor ID: {} - Orden: {} - Producto: {}", 
                       productorId, numeroOrden, nombreProducto);
            
            boolean exito = crearNotificacionUsuario(productorId, TipoNotificacion.ORDEN_COMPRA_CREADA, 
                                                   titulo, mensaje, Prioridad.INFO, null, null, null, ordenCompraId, 
                                                   urlAccion);
            
            if (exito) {
                logger.info("✓ Notificación creada exitosamente para productor ID: {}", productorId);
                return 1;
            } else {
                logger.warn("⚠ No se pudo crear notificación para productor ID: {}", productorId);
                return 0;
            }
        } catch (Exception e) {
            logger.error("Error al crear notificación ORDEN_COMPRA_CREADA para productor ID: " + productorId, e);
            return 0;
        }
    }
    
    // Notifica orden lista (ALMACENERO)
    public static int notificarOrdenLista(String numeroOrden, Integer ordenCompraId,
                                          String nombreProducto) {
        String titulo = "Orden de Compra Lista para Recepción";
        String mensaje = String.format("La orden de compra %s del producto '%s' está lista y " +
                                       "pendiente de recepción en el almacén.", numeroOrden, nombreProducto);
        String urlAccion = "/TELITO_BODEGUERO/almacen/entradas";
        
        return crearNotificacionPorRol(Rol.ALMACEN, TipoNotificacion.ORDEN_LISTA, titulo, mensaje,
                                      Prioridad.INFO, null, null, null, ordenCompraId, 
                                      urlAccion, false);
    }
    
    // Notifica plan de transporte creado (ALMACENERO)
    public static int notificarPlanTransporteCreado(String numeroPlan, String nombreProducto,
                                                    String destino, int paquetes) {
        String titulo = "Nuevo Plan de Transporte";
        String mensaje = String.format("Se ha creado un nuevo plan de transporte %s para %d paquetes " +
                                       "del producto '%s' con destino a %s. Preparar para despacho.", 
                                       numeroPlan, paquetes, nombreProducto, destino);
        String urlAccion = "/TELITO_BODEGUERO/almacen/PedidoServlet?action=lista";
        
        return crearNotificacionPorRol(Rol.ALMACEN, TipoNotificacion.PLAN_TRANSPORTE_CREADO, 
                                      titulo, mensaje, Prioridad.INFO, null, null, null, null, 
                                      urlAccion, false);
    }
    
    // Notifica plan de transporte destinado a un distrito (GERENTE DE TIENDA del distrito)
    public static boolean notificarPlanTransporteDestinado(String numeroPlan, String nombreProducto,
                                                          String nombreDistrito, String fechaEntrega,
                                                          int distritoId) {
        try {
            // Obtener el ID del gerente de tienda asignado a este distrito
            Integer gerenteId = notificacionDAO.obtenerGerenteTiendaPorDistrito(distritoId);
            
            if (gerenteId == null) {
                logger.warn("No se encontró gerente de tienda activo para el distrito ID: {}", distritoId);
                return false;
            }
            
            String titulo = "Plan de Transporte Destinado a tu Tienda";
            String mensaje = String.format("Se ha creado un plan de transporte %s con destino a %s. " +
                                           "Producto: '%s'. Fecha de entrega estimada: %s. " +
                                           "Estar preparado para recibir la mercancía.",
                                           numeroPlan, nombreDistrito, nombreProducto, fechaEntrega);
            String urlAccion = "/TELITO_BODEGUERO/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes";
            
            boolean exito = crearNotificacionUsuario(gerenteId, TipoNotificacion.PLAN_TRANSPORTE_DESTINADO,
                                                    titulo, mensaje, Prioridad.INFO,
                                                    null, null, null, null, urlAccion);
            
            if (exito) {
                logger.info("✓ Notificación enviada al gerente de tienda ID: {} para plan de transporte: {}", 
                           gerenteId, numeroPlan);
            } else {
                logger.warn("⚠ No se pudo crear notificación para gerente de tienda ID: {}", gerenteId);
            }
            
            return exito;
        } catch (Exception e) {
            logger.error("Error al notificar plan de transporte destinado al distrito ID: " + distritoId, e);
            return false;
        }
    }
    
    // Notifica pedido rechazado por stock insuficiente (LOGISTICA)
    public static int notificarPedidoRechazado(String numeroPedido, Integer pedidoId,
                                               String motivo) {
        String titulo = "Pedido Rechazado - Stock Insuficiente";
        String mensaje = String.format("El pedido %s fue rechazado: %s", numeroPedido, motivo);
        String urlAccion = "/TELITO_BODEGUERO/logistica/pedidos";
        
        return crearNotificacionPorRol(Rol.LOGISTICA, TipoNotificacion.PEDIDO_RECHAZADO, 
                                      titulo, mensaje, Prioridad.WARNING, null, null, pedidoId, null, 
                                      urlAccion, false);
    }
    
    // Notifica pedido completado (LOGISTICA)
    public static int notificarPedidoCompletado(String numeroPedido, Integer pedidoId) {
        try {
            String titulo = "Pedido Completado";
            String mensaje = String.format("El pedido %s ha sido despachado exitosamente.", numeroPedido);
            String urlAccion = "/TELITO_BODEGUERO/logistica/pedidos";
            
            logger.info("Creando notificación PEDIDO_COMPLETADO para pedido: {} - ID: {}", numeroPedido, pedidoId);
            
            int resultado = crearNotificacionPorRol(Rol.LOGISTICA, TipoNotificacion.PEDIDO_COMPLETADO, 
                                          titulo, mensaje, Prioridad.INFO, null, null, pedidoId, null, 
                                          urlAccion, false);
            
            if (resultado > 0) {
                logger.info("✓ Notificación creada exitosamente para pedido: {}", numeroPedido);
            } else {
                logger.warn("⚠ No se pudo crear notificación para pedido: {}", numeroPedido);
            }
            
            return resultado;
        } catch (Exception e) {
            logger.error("Error al crear notificación PEDIDO_COMPLETADO para pedido: " + numeroPedido, e);
            return 0;
        }
    }
    
    // Notifica plan de transporte despachado (LOGISTICA)
    public static int notificarPlanTransporteDespachado(String numeroPlan, String codigoLote, int cantidadPaquetes) {
        try {
            String titulo = "Plan de Transporte Despachado";
            String mensaje = String.format("El plan de transporte %s ha sido despachado exitosamente. " +
                                           "Lote: %s - Cantidad: %d paquetes. La mercancía está lista para ser transportada.",
                                           numeroPlan, codigoLote, cantidadPaquetes);
            String urlAccion = "/MovimientoProductoServlet";
            
            logger.info("Creando notificación PLAN_TRANSPORTE_DESPACHADO para plan: {} - Lote: {} - Paquetes: {}", 
                       numeroPlan, codigoLote, cantidadPaquetes);
            
            int resultado = crearNotificacionPorRol(Rol.LOGISTICA, TipoNotificacion.PEDIDO_COMPLETADO, 
                                          titulo, mensaje, Prioridad.INFO, null, null, null, null, 
                                          urlAccion, false);
            
            if (resultado > 0) {
                logger.info("✓ Notificación creada exitosamente para plan de transporte: {}", numeroPlan);
            } else {
                logger.warn("⚠ No se pudo crear notificación para plan de transporte: {}", numeroPlan);
            }
            
            return resultado;
        } catch (Exception e) {
            logger.error("Error al crear notificación PLAN_TRANSPORTE_DESPACHADO para plan: " + numeroPlan, e);
            return 0;
        }
    }
    
    // MÓDULO PRODUCTOR
    
    // Notifica orden confirmada (LOGISTICA)
    public static int notificarOrdenConfirmada(String numeroOrden, Integer ordenCompraId,
                                               String nombreProducto, int productorId) {
        String titulo = "Orden de Compra Confirmada";
        String mensaje = String.format("El productor ha confirmado la orden de compra %s del producto '%s'. " +
                                       "Proceder con la preparación.", numeroOrden, nombreProducto);
        String urlAccion = "/TELITO_BODEGUERO/logistica/ordenes";
        
        return crearNotificacionPorRol(Rol.LOGISTICA, TipoNotificacion.ORDEN_CONFIRMADA, 
                                      titulo, mensaje, Prioridad.INFO, null, null, null, ordenCompraId, 
                                      urlAccion, false);
    }
    
    // Notifica orden rechazada (LOGISTICA + ADMINISTRADOR)
    public static int notificarOrdenRechazada(String numeroOrden, Integer ordenCompraId,
                                             String nombreProducto, String motivo) {
        String titulo = "Orden de Compra Rechazada";
        String mensaje = String.format("El productor ha rechazado la orden de compra %s del producto '%s'. " +
                                       "Motivo: %s", numeroOrden, nombreProducto, motivo);
        String urlAccion = "/TELITO_BODEGUERO/logistica/ordenes";
        
        List<String> roles = new ArrayList<>();
        roles.add(Rol.LOGISTICA);
        roles.add(Rol.ADMINISTRADOR);
        
        return crearNotificacionPorRoles(roles, TipoNotificacion.ORDEN_RECHAZADA, titulo, mensaje,
                                        Prioridad.WARNING, null, null, null, ordenCompraId, 
                                        urlAccion, false);
    }
    
    // Notifica orden rechazada por logística (PRODUCTOR)
    public static int notificarOrdenRechazadaPorLogistica(String numeroOrden, Integer ordenCompraId,
                                                          String nombreProducto, int productorId) {
        try {
            String titulo = "Orden de Compra Rechazada por Logística";
            String mensaje = String.format("La orden de compra %s del producto '%s' ha sido rechazada por el personal de logística. " +
                                           "Por favor, revisa los detalles y contacta con logística si tienes preguntas.",
                                           numeroOrden, nombreProducto);
            String urlAccion = "/ProductorServlet?action=ordenesCompra";
            
            logger.info("Creando notificación ORDEN_RECHAZADA_POR_LOGISTICA para productor ID: {} - Orden: {} - Producto: {}", 
                       productorId, numeroOrden, nombreProducto);
            
            boolean exito = crearNotificacionUsuario(productorId, TipoNotificacion.ORDEN_RECHAZADA, titulo, mensaje,
                                                  Prioridad.WARNING, null, null, null, ordenCompraId, urlAccion);
            
            if (exito) {
                logger.info("✓ Notificación creada exitosamente para productor ID: {}", productorId);
                return 1;
            } else {
                logger.warn("⚠ No se pudo crear notificación para productor ID: {}", productorId);
                return 0;
            }
        } catch (Exception e) {
            logger.error("Error al crear notificación ORDEN_RECHAZADA_POR_LOGISTICA para productor ID: " + productorId, e);
            return 0;
        }
    }
    
    // Notifica orden lista por productor (LOGISTICA)
    public static int notificarOrdenListaProductor(String numeroOrden, Integer ordenCompraId,
                                                   String nombreProducto) {
        String titulo = "Orden de Compra Lista para Envío";
        String mensaje = String.format("El productor ha marcado la orden de compra %s del producto '%s' " +
                                       "como lista. Preparar recepción en almacén.", numeroOrden, nombreProducto);
        String urlAccion = "/TELITO_BODEGUERO/logistica/ordenes";
        
        return crearNotificacionPorRol(Rol.LOGISTICA, TipoNotificacion.ORDEN_LISTA_PRODUCTOR, 
                                      titulo, mensaje, Prioridad.INFO, null, null, null, ordenCompraId, 
                                      urlAccion, false);
    }
    
    // Notifica producto nuevo (ADMINISTRADOR)
    public static int notificarProductoNuevo(String nombreProducto, Integer productoId,
                                            String sku, int productorId) {
        String titulo = "Nuevo Producto Registrado";
        String mensaje = String.format("Se ha registrado un nuevo producto '%s' (SKU: %s) en el sistema.", 
                                       nombreProducto, sku);
        String urlAccion = "/TELITO_BODEGUERO/administrador/inventario-general";
        
        return crearNotificacionPorRol(Rol.ADMINISTRADOR, TipoNotificacion.PRODUCTO_NUEVO, 
                                      titulo, mensaje, Prioridad.INFO, productoId, null, null, null, 
                                      urlAccion, false);
    }
    
    // MÓDULO ADMINISTRADOR
    
    // Notifica usuario creado (USUARIO NUEVO por email)
    public static boolean notificarUsuarioCreado(int usuarioId, String email, String nombres,
                                                String apellidos, String nombreRol, String passwordTemporal) {
        String titulo = "Bienvenido a TELITO BODEGUERO";
        String mensaje = String.format("Tu cuenta ha sido creada exitosamente. Rol asignado: %s. " +
                                       "Por favor, cambia tu contraseña al iniciar sesión por primera vez.",
                                       nombreRol);
        String urlAccion = "/TELITO_BODEGUERO/acceso/login";
        
        boolean notificacionCreada = crearNotificacionUsuario(usuarioId, TipoNotificacion.USUARIO_CREADO, 
                                                              titulo, mensaje, Prioridad.INFO, 
                                                              null, null, null, null, urlAccion);
        
        // El email se envía desde UsuarioService, no desde aquí
        return notificacionCreada;
    }
    
    // Notifica alerta configurada (ROL_ESPECIFICADO)
    public static int notificarAlertaConfigurada(String nombreAlerta, String tipoAlerta,
                                                 String rolANotificar) {
        String titulo = "Nueva Alerta Configurada";
        String mensaje = String.format("Se ha configurado una nueva alerta '%s' de tipo '%s' " +
                                       "que te notificará automáticamente.", nombreAlerta, tipoAlerta);
        String urlAccion = "/TELITO_BODEGUERO/administrador/alertas";
        
        return crearNotificacionPorRol(rolANotificar, TipoNotificacion.ALERTA_CONFIGURADA, 
                                      titulo, mensaje, Prioridad.INFO, null, null, null, null, 
                                      urlAccion, false);
    }
    
    // Notifica actualización del sistema (TODOS)
    public static int notificarSistemaActualizado(String descripcionActualizacion) {
        String titulo = "Actualización del Sistema";
        String mensaje = descripcionActualizacion;
        String urlAccion = "/TELITO_BODEGUERO/administrador/dashboard";
        
        List<String> todosLosRoles = new ArrayList<>();
        todosLosRoles.add(Rol.ADMINISTRADOR);
        todosLosRoles.add(Rol.LOGISTICA);
        todosLosRoles.add(Rol.PRODUCTOR);
        todosLosRoles.add(Rol.ALMACEN);
        
        return crearNotificacionPorRoles(todosLosRoles, TipoNotificacion.SISTEMA_ACTUALIZADO, 
                                        titulo, mensaje, Prioridad.INFO, null, null, null, null, 
                                        urlAccion, false);
    }
}

