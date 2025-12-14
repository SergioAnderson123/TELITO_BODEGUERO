package com.example.telito.util;

import com.example.telito.administrador.daos.AlertaDAO;
import com.example.telito.almacen.daos.PedidoDao;
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.almacen.beans.Pedido;
import com.example.telito.almacen.beans.Lote;
import com.example.telito.administrador.daos.StockMinimoDAO;
import com.example.telito.util.EmailUtil;
import com.example.telito.util.NotificacionService;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.ArrayList;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

// Scheduler que ejecuta alertas automáticas diariamente a las 8:00 AM
@WebListener
public class AlertaScheduler implements ServletContextListener {

    private static final Logger logger = LoggerFactory.getLogger(AlertaScheduler.class);
    private ScheduledExecutorService scheduler;
    private static final int HORA_EJECUCION = 8; // 8:00 AM
    private static final int INTERVALO_HORAS = 24; // Diariamente

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        logger.info("=== INICIANDO SCHEDULER DE ALERTAS AUTOMÁTICAS ===");
        
        scheduler = Executors.newScheduledThreadPool(1);
        
        // Calcular delay inicial hasta las 8:00 AM
        long delayInicial = calcularDelayInicial();
        
        // Ejecutar primera vez después del delay inicial
        scheduler.schedule(new TareaAlertas(), delayInicial, TimeUnit.MILLISECONDS);
        
        // Luego ejecutar cada 24 horas
        scheduler.scheduleAtFixedRate(
            new TareaAlertas(), 
            delayInicial, 
            INTERVALO_HORAS * 60 * 60 * 1000, // 24 horas en milisegundos
            TimeUnit.MILLISECONDS
        );
        
        logger.info("Scheduler de alertas iniciado correctamente. Ejecutara alertas diariamente a las {}:00 AM", HORA_EJECUCION);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        logger.info("=== DETENIENDO SCHEDULER DE ALERTAS ===");
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
            logger.info("Scheduler de alertas detenido correctamente");
        }
    }

    // Calcula delay inicial hasta la próxima ejecución programada (8:00 AM)
    private long calcularDelayInicial() {
        java.util.Calendar ahora = java.util.Calendar.getInstance();
        java.util.Calendar proximaEjecucion = java.util.Calendar.getInstance();
        
        proximaEjecucion.set(java.util.Calendar.HOUR_OF_DAY, HORA_EJECUCION);
        proximaEjecucion.set(java.util.Calendar.MINUTE, 0);
        proximaEjecucion.set(java.util.Calendar.SECOND, 0);
        proximaEjecucion.set(java.util.Calendar.MILLISECOND, 0);
        
        // Si ya pasó la hora de hoy, programar para mañana
        if (proximaEjecucion.before(ahora)) {
            proximaEjecucion.add(java.util.Calendar.DAY_OF_MONTH, 1);
        }
        
        return proximaEjecucion.getTimeInMillis() - ahora.getTimeInMillis();
    }

    /**
     * Tarea que ejecuta las alertas automáticas y envía correos
     */
    private static class TareaAlertas implements Runnable {
        @Override
        public void run() {
            try {
                System.out.println("=== EJECUTANDO ALERTAS AUTOMÁTICAS ===");
                System.out.println("Fecha/Hora: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new java.util.Date()));
                
                AlertaDAO alertaDAO = new AlertaDAO();
                
                // Obtener todos los roles únicos que tienen alertas configuradas
                ArrayList<String> rolesConAlertas = alertaDAO.obtenerRolesConAlertasActivas();
                
                if (rolesConAlertas.isEmpty()) {
                    System.out.println("⚠ No hay alertas configuradas para ningún rol");
                    return;
                }
                
                int totalCorreosEnviados = 0;
                
                // Procesar alertas para cada rol
                for (String rolNombre : rolesConAlertas) {
                    ArrayList<String> mensajes = alertaDAO.listarAlertasParaRol(rolNombre);
                    
                    if (!mensajes.isEmpty()) {
                        // Generar correo HTML detallado
                        String htmlContent = generarCorreoHTMLAlertas(rolNombre, mensajes);
                        
                        // Obtener emails del rol
                        ArrayList<String> emails = alertaDAO.obtenerEmailsPorRol(rolNombre);
                        
                        if (!emails.isEmpty()) {
                            // Enviar correo HTML a cada usuario del rol
                            int correosEnviados = 0;
                            for (String email : emails) {
                                boolean enviado = EmailUtil.sendSystemAlertHTML(
                                    email,
                                    "Alertas Automáticas del Sistema - " + rolNombre,
                                    htmlContent
                                );
                                if (enviado) {
                                    correosEnviados++;
                                }
                            }
                            
                            totalCorreosEnviados += correosEnviados;
                            System.out.println("✓ Se enviaron " + correosEnviados + " correo(s) de alertas al rol: " + rolNombre);
                            System.out.println("  - Total de alertas: " + mensajes.size());
                        } else {
                            System.out.println("⚠ No se encontraron emails para el rol: " + rolNombre);
                        }
                    } else {
                        System.out.println("ℹ No hay alertas activas para el rol: " + rolNombre);
                    }
                }
                
                // ========== RECORDATORIO DE PEDIDOS PENDIENTES A ALMACÉN ==========
                try {
                    PedidoDao pedidoDao = new PedidoDao();
                    ArrayList<Pedido> pedidosPendientes = pedidoDao.listarPedidosPendientes();
                    
                    if (!pedidosPendientes.isEmpty()) {
                        System.out.println("📦 Encontrados " + pedidosPendientes.size() + " pedido(s) pendiente(s) - Enviando recordatorio a almacén");
                        
                        // Obtener emails de almacén
                        AlertaDAO alertaDAO2 = new AlertaDAO();
                        ArrayList<String> emailsAlmacen = alertaDAO2.obtenerEmailsPorRol("Almacenero");
                        
                        if (!emailsAlmacen.isEmpty()) {
                            // Generar correo HTML con lista de pedidos pendientes
                            String htmlPedidos = generarCorreoHTMLPedidosPendientes(pedidosPendientes);
                            
                            int correosEnviados = 0;
                            for (String email : emailsAlmacen) {
                                boolean enviado = EmailUtil.sendSystemAlertHTML(
                                    email,
                                    "Recordatorio: " + pedidosPendientes.size() + " Pedido(s) Pendiente(s) - TELITO BODEGUERO",
                                    htmlPedidos
                                );
                                if (enviado) {
                                    correosEnviados++;
                                }
                            }
                            
                            totalCorreosEnviados += correosEnviados;
                            System.out.println("✓ Se enviaron " + correosEnviados + " correo(s) de recordatorio de pedidos pendientes a almacén");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("⚠ Error al enviar recordatorio de pedidos pendientes: " + e.getMessage());
                    e.printStackTrace();
                }
                // ========== FIN RECORDATORIO DE PEDIDOS ==========
                
                // ========== NOTIFICACIONES WEB PERIÓDICAS ==========
                // Evaluar stock crítico, vencimientos y crear notificaciones web
                try {
                    evaluarYNotificarStockYVencimientos();
                } catch (Exception e) {
                    System.err.println("⚠ Error al evaluar y notificar stock/vencimientos: " + e.getMessage());
                    e.printStackTrace();
                }
                // ========== FIN NOTIFICACIONES WEB PERIÓDICAS ==========
                
                System.out.println("=== FIN EJECUCIÓN DE ALERTAS ===");
                System.out.println("Total de correos enviados: " + totalCorreosEnviados);
                
            } catch (Exception e) {
                System.err.println("❌ Error al ejecutar alertas automáticas: " + e.getMessage());
                e.printStackTrace();
            }
        }

        /**
         * Genera un correo HTML detallado con las alertas
         */
        private String generarCorreoHTMLAlertas(String rolNombre, ArrayList<String> mensajes) {
            StringBuilder html = new StringBuilder();
            html.append("""
                <html>
                <head>
                    <meta charset="UTF-8">
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                        .container { max-width: 800px; margin: 0 auto; padding: 20px; }
                        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                                 color: white; padding: 20px; border-radius: 8px 8px 0 0; }
                        .content { background: #f8f9fa; padding: 20px; border-radius: 0 0 8px 8px; }
                        .alert-list { background: white; padding: 15px; border-radius: 5px; margin-top: 15px; }
                        .alert-item { padding: 10px; margin: 5px 0; background: #fff3cd; 
                                     border-left: 4px solid #ffc107; border-radius: 3px; }
                        .alert-item.critical { background: #f8d7da; border-left-color: #dc3545; }
                        .alert-item.warning { background: #fff3cd; border-left-color: #ffc107; }
                        .alert-item.info { background: #d1ecf1; border-left-color: #0dcaf0; }
                        .footer { margin-top: 20px; padding-top: 15px; border-top: 1px solid #ddd; 
                                 font-size: 12px; color: #666; text-align: center; }
                        .badge { display: inline-block; padding: 3px 8px; border-radius: 3px; 
                               font-size: 11px; font-weight: bold; margin-right: 5px; }
                        .badge-danger { background: #dc3545; color: white; }
                        .badge-warning { background: #ffc107; color: #000; }
                        .badge-info { background: #0dcaf0; color: #000; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h2>🚨 Alertas Automáticas del Sistema</h2>
                            <p>Rol: <strong>%s</strong></p>
                            <p>Fecha: %s</p>
                        </div>
                        <div class="content">
                            <h3>Se han detectado <strong>%d</strong> alerta(s) que requieren tu atención:</h3>
                """.formatted(
                    rolNombre,
                    new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()),
                    mensajes.size()
                ));
            
            html.append("<div class=\"alert-list\">");
            
            int contador = 1;
            for (String mensaje : mensajes) {
                // Determinar tipo de alerta por el contenido
                String tipo = "warning";
                String badge = "";
                
                if (mensaje.toLowerCase().contains("crítico") || mensaje.toLowerCase().contains("vencido")) {
                    tipo = "critical";
                    badge = "<span class=\"badge badge-danger\">CRÍTICO</span>";
                } else if (mensaje.toLowerCase().contains("vencimiento") || mensaje.toLowerCase().contains("vence")) {
                    tipo = "warning";
                    badge = "<span class=\"badge badge-warning\">VENCIMIENTO</span>";
                } else if (mensaje.toLowerCase().contains("stock")) {
                    tipo = "info";
                    badge = "<span class=\"badge badge-info\">STOCK</span>";
                }
                
                html.append(String.format(
                    "<div class=\"alert-item %s\">%s <strong>%d.</strong> %s</div>%n",
                    tipo,
                    badge,
                    contador++,
                    mensaje
                ));
            }
            
            html.append("""
                        </div>
                        <div class="footer">
                            <p>Este es un correo automático generado por el sistema TELITO BODEGUERO.</p>
                            <p>Por favor, revisa estas alertas en tu panel de control.</p>
                        </div>
                    </div>
                </div>
                </body>
                </html>
                """);
            
            return html.toString();
        }
        
        /**
         * Genera un correo HTML con la lista de pedidos pendientes
         */
        private String generarCorreoHTMLPedidosPendientes(ArrayList<Pedido> pedidos) {
            StringBuilder html = new StringBuilder();
            html.append("""
                <html>
                <head>
                    <meta charset="UTF-8">
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                        .container { max-width: 800px; margin: 0 auto; padding: 20px; }
                        .header { background: linear-gradient(135deg, #ff9800 0%, #f57c00 100%); 
                                 color: white; padding: 20px; border-radius: 8px 8px 0 0; text-align: center; }
                        .content { background: #f8f9fa; padding: 20px; border-radius: 0 0 8px 8px; }
                        .pedidos-list { background: white; padding: 20px; border-radius: 5px; margin-top: 15px; }
                        .pedido-item { padding: 15px; margin: 10px 0; background: #fff3cd; 
                                     border-left: 4px solid #ff9800; border-radius: 5px; }
                        .pedido-header { font-weight: bold; color: #ff9800; margin-bottom: 8px; }
                        .pedido-details { margin-left: 15px; color: #666; }
                        .footer { margin-top: 20px; padding-top: 15px; border-top: 1px solid #ddd; 
                                 font-size: 12px; color: #666; text-align: center; }
                        .badge { display: inline-block; padding: 5px 10px; border-radius: 3px; 
                               font-size: 12px; font-weight: bold; margin-right: 10px; }
                        .badge-warning { background: #ff9800; color: white; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h2>📦 Recordatorio: Pedidos Pendientes</h2>
                        </div>
                        <div class="content">
                            <p>Hola,</p>
                            <p>Tienes <strong>%d pedido(s) pendiente(s)</strong> que requieren preparación y despacho.</p>
                            
                            <div class="pedidos-list">
                                <h3 style="margin-top: 0; color: #ff9800;">📋 Lista de Pedidos Pendientes</h3>
                """.formatted(pedidos.size()));
            
            int contador = 1;
            for (Pedido pedido : pedidos) {
                html.append(String.format("""
                                    <div class="pedido-item">
                                        <div class="pedido-header">
                                            <span class="badge badge-warning">%d</span>
                                            Pedido #%s
                                        </div>
                                        <div class="pedido-details">
                                            <p><strong>Cliente:</strong> %s</p>
                                            <p><strong>Destino:</strong> %s</p>
                                            <p><strong>Estado:</strong> %s</p>
                                        </div>
                                    </div>
                    """,
                    contador++,
                    pedido.getNumeroPedido(),
                    pedido.getCliente() != null ? pedido.getCliente().getNombre() : "N/A",
                    pedido.getDestino() != null ? pedido.getDestino() : "N/A",
                    pedido.getEstadoPreparacion() != null ? pedido.getEstadoPreparacion() : "Pendiente"
                ));
            }
            
            html.append("""
                            </div>
                            
                            <p style="margin-top: 20px;"><strong>Acción requerida:</strong></p>
                            <ul>
                                <li>Revisa cada pedido pendiente en tu panel de almacén</li>
                                <li>Prepara la mercancía según los requisitos de cada pedido</li>
                                <li>Marca los pedidos como "Despachado" una vez completados</li>
                            </ul>
                            
                            <p>Puedes acceder a la gestión de pedidos desde: <strong>Almacén → Registrar Salidas</strong></p>
                            
                            <div class="footer">
                                <p>Este es un correo automático generado por el sistema TELITO BODEGUERO.</p>
                                <p>Fecha: %s</p>
                            </div>
                        </div>
                    </div>
                </body>
                </html>
                """.formatted(
                    new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date())
                ));
            
            return html.toString();
        }
        
        // Evalúa stock crítico y vencimientos, creando notificaciones web
        private void evaluarYNotificarStockYVencimientos() {
            try {
                System.out.println("=== EVALUANDO STOCK Y VENCIMIENTOS PARA NOTIFICACIONES WEB ===");
                
                LoteDao loteDao = new LoteDao();
                StockMinimoDAO stockMinimoDAO = new StockMinimoDAO();
                
                // Obtener todos los lotes registrados
                ArrayList<Lote> lotes = loteDao.listarLotesRegistrados(1);
                
                java.util.Calendar hoy = java.util.Calendar.getInstance();
                hoy.set(java.util.Calendar.HOUR_OF_DAY, 0);
                hoy.set(java.util.Calendar.MINUTE, 0);
                hoy.set(java.util.Calendar.SECOND, 0);
                hoy.set(java.util.Calendar.MILLISECOND, 0);
                
                int notificacionesStockCritico = 0;
                int notificacionesStockMinimo = 0;
                int notificacionesVencimiento7Dias = 0;
                int notificacionesVencimiento3Dias = 0;
                int notificacionesLoteVencido = 0;
                
                for (Lote lote : lotes) {
                    try {
                        // Verificar stock crítico y mínimo
                        if (lote.getProductoId() > 0) {
                            com.example.telito.administrador.beans.StockMinimoConfig config = 
                                stockMinimoDAO.obtenerPorProducto(lote.getProductoId());
                            
                            if (config != null && config.isActivo()) {
                                int paquetesDisponibles = lote.getPaquetesDisponibles();
                                
                                // Stock crítico
                                if (config.getStockCriticoLote() > 0 && 
                                    paquetesDisponibles <= config.getStockCriticoLote() && 
                                    paquetesDisponibles > 0) {
                                    NotificacionService.notificarStockCritico(
                                        lote.getNombreProducto() != null ? lote.getNombreProducto() : "Producto",
                                        lote.getProductoId(),
                                        lote.getIdLote(),
                                        lote.getStockActual(),
                                        config.getStockCriticoLote()
                                    );
                                    notificacionesStockCritico++;
                                }
                                
                                // Stock mínimo (solo si no es crítico)
                                if (config.getStockMinimoLote() > 0 && 
                                    paquetesDisponibles <= config.getStockMinimoLote() && 
                                    paquetesDisponibles > config.getStockCriticoLote()) {
                                    NotificacionService.notificarStockMinimo(
                                        lote.getNombreProducto() != null ? lote.getNombreProducto() : "Producto",
                                        lote.getProductoId(),
                                        lote.getIdLote(),
                                        lote.getStockActual(),
                                        config.getStockMinimoLote()
                                    );
                                    notificacionesStockMinimo++;
                                }
                            }
                        }
                        
                        // Verificar vencimientos
                        if (lote.getFechaVencimiento() != null) {
                            java.util.Calendar fechaVencimiento = java.util.Calendar.getInstance();
                            fechaVencimiento.setTime(lote.getFechaVencimiento());
                            fechaVencimiento.set(java.util.Calendar.HOUR_OF_DAY, 0);
                            fechaVencimiento.set(java.util.Calendar.MINUTE, 0);
                            fechaVencimiento.set(java.util.Calendar.SECOND, 0);
                            fechaVencimiento.set(java.util.Calendar.MILLISECOND, 0);
                            
                            long diferenciaMillis = fechaVencimiento.getTimeInMillis() - hoy.getTimeInMillis();
                            int diasRestantes = (int) (diferenciaMillis / (1000 * 60 * 60 * 24));
                            
                            // Lote vencido
                            if (diasRestantes < 0) {
                                NotificacionService.notificarLoteVencido(
                                    lote.getNombreProducto() != null ? lote.getNombreProducto() : "Producto",
                                    lote.getCodigoLote(),
                                    lote.getProductoId(),
                                    lote.getIdLote(),
                                    lote.getFechaVencimiento()
                                );
                                notificacionesLoteVencido++;
                            }
                            // Vencimiento en 3 días
                            else if (diasRestantes <= 3 && diasRestantes >= 0) {
                                NotificacionService.notificarVencimiento3Dias(
                                    lote.getNombreProducto() != null ? lote.getNombreProducto() : "Producto",
                                    lote.getCodigoLote(),
                                    lote.getProductoId(),
                                    lote.getIdLote(),
                                    lote.getFechaVencimiento()
                                );
                                notificacionesVencimiento3Dias++;
                            }
                            // Vencimiento en 7 días
                            else if (diasRestantes <= 7 && diasRestantes > 3) {
                                NotificacionService.notificarVencimiento7Dias(
                                    lote.getNombreProducto() != null ? lote.getNombreProducto() : "Producto",
                                    lote.getCodigoLote(),
                                    lote.getProductoId(),
                                    lote.getIdLote(),
                                    lote.getFechaVencimiento()
                                );
                                notificacionesVencimiento7Dias++;
                            }
                        }
                    } catch (Exception e) {
                        System.err.println("⚠ Error al evaluar lote ID " + lote.getIdLote() + ": " + e.getMessage());
                    }
                }
                
                System.out.println("✓ Notificaciones web creadas:");
                System.out.println("  - Stock crítico: " + notificacionesStockCritico);
                System.out.println("  - Stock mínimo: " + notificacionesStockMinimo);
                System.out.println("  - Vencimiento 7 días: " + notificacionesVencimiento7Dias);
                System.out.println("  - Vencimiento 3 días: " + notificacionesVencimiento3Dias);
                System.out.println("  - Lotes vencidos: " + notificacionesLoteVencido);
                System.out.println("  - Total: " + (notificacionesStockCritico + notificacionesStockMinimo + 
                                                   notificacionesVencimiento7Dias + notificacionesVencimiento3Dias + 
                                                   notificacionesLoteVencido));
                
            } catch (Exception e) {
                System.err.println("❌ Error al evaluar stock y vencimientos: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }
}

