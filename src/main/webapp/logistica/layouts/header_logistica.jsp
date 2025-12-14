<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%
    Usuario usuarioHeader = (Usuario) session.getAttribute("usuario");
    String nombreCompleto = usuarioHeader != null ? usuarioHeader.getNombres() + " " + usuarioHeader.getApellidos() : "Usuario";
    String fotoUrl = "https://ui-avatars.com/api/?name=User&background=006d77&color=fff&size=200";
    if (usuarioHeader != null) {
        String foto = usuarioHeader.getFotoPerfil();
        if (foto != null && !foto.trim().isEmpty()) {
            if (foto.startsWith("http://") || foto.startsWith("https://")) {
                fotoUrl = foto;
            } else {
                fotoUrl = request.getContextPath() + "/" + foto;
            }
        } else {
            fotoUrl = usuarioHeader.getFotoPerfilUrl();
        }
    }
%>
<!-- Overlay para móvil -->
<div class="sidebar-overlay" id="sidebarOverlay"></div>

<div class="dashboard-header">
    <nav class="navbar navbar-expand">
        <div class="container-fluid">
            <!-- Botón Hamburguesa -->
            <button class="sidebar-toggle" id="sidebarToggle" type="button" aria-label="Toggle sidebar">
                <i class="fas fa-bars"></i>
            </button>
            <a class="navbar-brand d-flex align-items-center" href="${pageContext.request.contextPath}/logistica/InventarioServlet">
                <i class="fas fa-truck me-2" style="color: var(--seafoam);"></i>
                <span>Telito Bodeguero</span>
            </a>

            <ul class="navbar-nav ms-auto">
                <!-- Notificaciones -->
                <li class="nav-item dropdown me-3">
                    <a class="nav-link position-relative" href="#" role="button" id="notificacionesDropdown" data-bs-toggle="dropdown" aria-expanded="false" style="padding: 8px 12px;">
                        <i class="fas fa-bell" style="font-size: 1.3rem; color: var(--turquoise-dark);"></i>
                        <span class="badge-notificacion" id="badgeNotificaciones" style="display: none;">0</span>
                    </a>
                    <div class="dropdown-menu dropdown-menu-end notificaciones-dropdown" aria-labelledby="notificacionesDropdown" style="width: 380px;">
                        <div class="dropdown-header d-flex justify-content-between align-items-center" style="background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%); color: white; padding: 12px 20px;">
                            <h6 class="mb-0"><i class="fas fa-bell me-2"></i>Notificaciones</h6>
                            <button class="btn btn-sm btn-light" onclick="marcarTodasLeidas()" style="font-size: 0.75rem; padding: 2px 8px;">
                                <i class="fas fa-check-double me-1"></i>Marcar todas
                            </button>
                        </div>
                        <div id="listaNotificaciones" style="max-height: 400px; overflow-y: auto; overflow-x: hidden;">
                            <div class="text-center py-4 text-muted">
                                <i class="fas fa-spinner fa-spin fa-2x mb-2"></i>
                                <p class="mb-0">Cargando notificaciones...</p>
                            </div>
                        </div>
                        <div class="dropdown-divider m-0"></div>
                        <a class="dropdown-item text-center fw-bold py-2" href="javascript:void(0);" onclick="event.preventDefault(); mostrarModalTodasNotificaciones();" style="color: #00a896 !important;">
                            <i class="fas fa-list me-2"></i>Ver todas las notificaciones
                        </a>
                    </div>
                </li>
                
                <!-- Usuario -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                        <img src="<%= fotoUrl %>" alt="User" class="rounded-circle me-2" width="32" height="32">
                        <span style="color:#006d77;"><%= nombreCompleto %></span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/perfil"><i class="fas fa-user me-2"></i>Perfil</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesion</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </nav>
</div>

<!-- Estilos para Notificaciones -->
<style>
    .badge-notificacion {
        position: absolute;
        top: -2px;
        right: -2px;
        background: #dc3545;
        color: white;
        font-size: 10px;
        font-weight: 700;
        padding: 2px 5px;
        border-radius: 10px;
        min-width: 18px;
        height: 18px;
        display: flex;
        align-items: center;
        justify-content: center;
        text-align: center;
        line-height: 1;
        animation: pulse-badge 2s infinite;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        border: 2px solid white;
    }
    
    @keyframes pulse-badge {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.1); }
    }
    
    .notificaciones-dropdown {
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        border: none;
        border-radius: 12px;
        overflow: visible;
    }
    
    /* Ocultar scrollbar pero mantener funcionalidad */
    #listaNotificaciones {
        scrollbar-width: thin;
        scrollbar-color: rgba(0, 168, 150, 0.3) transparent;
    }
    
    #listaNotificaciones::-webkit-scrollbar {
        width: 6px;
    }
    
    #listaNotificaciones::-webkit-scrollbar-track {
        background: transparent;
    }
    
    #listaNotificaciones::-webkit-scrollbar-thumb {
        background-color: rgba(0, 168, 150, 0.3);
        border-radius: 10px;
    }
    
    #listaNotificaciones::-webkit-scrollbar-thumb:hover {
        background-color: rgba(0, 168, 150, 0.5);
    }
    
    .notificacion-item {
        padding: 12px 20px;
        border-bottom: 1px solid #eee;
        transition: all 0.3s ease;
        cursor: pointer;
        background: white;
    }
    
    .notificacion-item:hover {
        background: #f8f9fa;
    }
    
    .notificacion-item.no-leida {
        background: #e8f4f8;
        border-left: 4px solid var(--turquoise-dark);
    }
    
    .notificacion-item.no-leida:hover {
        background: #d4ecf5;
    }
    
    .notificacion-icon {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.2rem;
        flex-shrink: 0;
    }
    
    .notificacion-icon.CRITICAL { background: #fee; color: #dc3545; }
    .notificacion-icon.WARNING { background: #fff3cd; color: #ffc107; }
    .notificacion-icon.INFO { background: #d1ecf1; color: #0dcaf0; }
    
    .notificacion-contenido {
        flex: 1;
        min-width: 0;
    }
    
    .notificacion-titulo {
        font-weight: 600;
        font-size: 0.9rem;
        color: #212529 !important;
        margin-bottom: 4px;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        line-height: 1.3;
    }
    
    .notificacion-mensaje {
        font-size: 0.8rem;
        color: #495057 !important;
        margin-bottom: 4px;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        line-height: 1.4;
    }
    
    .notificacion-tiempo {
        font-size: 0.7rem;
        color: #6c757d !important;
    }
</style>

<script>
// ===================== Sistema de Notificaciones =====================
let ultimaActualizacion = Date.now();

// Cargar notificaciones al inicio
document.addEventListener('DOMContentLoaded', function() {
    cargarContadorNotificaciones();
    cargarNotificacionesRecientes();
    
    // Auto-refresh cada 5 segundos (5000ms)
    setInterval(function() {
        cargarContadorNotificaciones();
        cargarNotificacionesRecientes();
    }, 5000);
});

// Cargar contador de notificaciones no leídas
function cargarContadorNotificaciones() {
    fetch('${pageContext.request.contextPath}/NotificacionServlet?action=contador', {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            const contador = data.datos.contador || 0;
            const badge = document.getElementById('badgeNotificaciones');
            if (contador > 0) {
                badge.textContent = contador > 99 ? '99+' : contador;
                badge.style.display = 'block';
            } else {
                badge.style.display = 'none';
            }
        }
    })
    .catch(error => console.error('Error al cargar contador:', error));
}

// Cargar notificaciones recientes
function cargarNotificacionesRecientes() {
    fetch('${pageContext.request.contextPath}/NotificacionServlet?action=recientes', {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            const notifs = data.datos.notificaciones || [];
            mostrarNotificaciones(notifs);
            
            // Mostrar modal automáticamente si hay notificaciones nuevas
            if (notifs.length > 0) {
                mostrarModalNotificaciones(notifs);
            }
        }
    })
    .catch(error => {
        console.error('Error al cargar notificaciones:', error);
        document.getElementById('listaNotificaciones').innerHTML = 
            '<div class="text-center py-4 text-danger">' +
                '<i class="fas fa-exclamation-triangle fa-2x mb-2"></i>' +
                '<p class="mb-0">Error al cargar notificaciones</p>' +
            '</div>';
    });
}

// Mostrar notificaciones en el dropdown
function mostrarNotificaciones(notificaciones) {
    const lista = document.getElementById('listaNotificaciones');
    
    if (notificaciones.length === 0) {
        lista.innerHTML = '<div class="text-center py-4 text-muted">' +
            '<i class="fas fa-bell-slash fa-2x mb-2"></i>' +
            '<p class="mb-0">No tienes notificaciones nuevas</p>' +
        '</div>';
        return;
    }
    
    const htmlArray = notificaciones.map(notif => {
        const iconoTipo = obtenerIconoTipo(notif.tipo || notif.tipoNotificacion);
        const tiempoRelativo = obtenerTiempoRelativo(notif.fechaCreacion);
        const idNotif = notif.id || notif.idNotificacion;
        const nivelPrioridad = notif.nivel || notif.nivelPrioridad;
        const tipoNotif = notif.tipo || notif.tipoNotificacion || '';
        
        return '<div class="notificacion-item no-leida" onclick="verNotificacion(' + idNotif + ', \'' + (notif.urlAccion || '') + '\', \'' + tipoNotif + '\')">' +
                '<div class="d-flex gap-3">' +
                    '<div class="notificacion-icon ' + nivelPrioridad + '">' +
                        '<i class="' + iconoTipo + '"></i>' +
                    '</div>' +
                    '<div class="notificacion-contenido">' +
                        '<div class="notificacion-titulo">' + notif.titulo + '</div>' +
                        '<div class="notificacion-mensaje">' + notif.mensaje + '</div>' +
                        '<div class="notificacion-tiempo">' +
                            '<i class="far fa-clock me-1"></i>' + tiempoRelativo +
                        '</div>' +
                    '</div>' +
                    '<div class="text-primary"><i class="fas fa-circle" style="font-size: 8px;"></i></div>' +
                '</div>' +
            '</div>';
    });
    
    lista.innerHTML = htmlArray.join('');
}

// Obtener icono según tipo de notificación
function obtenerIconoTipo(tipo) {
    const iconos = {
        'STOCK_CRITICO': 'fas fa-exclamation-triangle',
        'STOCK_MINIMO': 'fas fa-box-open',
        'VENCIMIENTO_7_DIAS': 'fas fa-calendar-times',
        'VENCIMIENTO_3_DIAS': 'fas fa-bell',
        'LOTE_VENCIDO': 'fas fa-times-circle',
        'INCIDENCIA_REPORTADA': 'fas fa-exclamation-circle',
        'AJUSTE_INVENTARIO': 'fas fa-exchange-alt',
        'ENTRADA_REGISTRADA': 'fas fa-arrow-down',
        'ORDEN_COMPRA_CREADA': 'fas fa-shopping-cart',
        'ORDEN_LISTA': 'fas fa-check-circle',
        'PLAN_TRANSPORTE_CREADO': 'fas fa-truck',
        'PEDIDO_RECHAZADO': 'fas fa-times',
        'PEDIDO_COMPLETADO': 'fas fa-check',
        'ORDEN_CONFIRMADA': 'fas fa-check-circle',
        'ORDEN_RECHAZADA': 'fas fa-times-circle',
        'ORDEN_LISTA_PRODUCTOR': 'fas fa-check',
        'PRODUCTO_NUEVO': 'fas fa-plus-circle',
        'USUARIO_CREADO': 'fas fa-user-plus',
        'ALERTA_CONFIGURADA': 'fas fa-cog',
        'SISTEMA_ACTUALIZADO': 'fas fa-info-circle',
        'VENCIMIENTO_PROXIMO': 'fas fa-calendar-times',
        'VENCIMIENTO_URGENTE': 'fas fa-bell',
        'PRODUCTO_VENCIDO': 'fas fa-times-circle',
        'PEDIDO_PENDIENTE': 'fas fa-shopping-cart',
        'ORDEN_COMPRA_APROBADA': 'fas fa-check-circle',
        'ALERTA_SISTEMA': 'fas fa-info-circle',
        'MOVIMIENTO_CRITICO': 'fas fa-exchange-alt'
    };
    return iconos[tipo] || 'fas fa-bell';
}

// Obtener tiempo relativo
function obtenerTiempoRelativo(fechaStr) {
    let fecha;
    if (typeof fechaStr === 'number') {
        fecha = new Date(fechaStr);
    } else if (typeof fechaStr === 'string') {
        fecha = new Date(fechaStr);
    } else {
        return 'Reciente';
    }
    
    if (isNaN(fecha.getTime())) {
        return 'Reciente';
    }
    
    const ahora = new Date();
    const diffMs = ahora - fecha;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);
    
    if (diffMins < 1) return 'Ahora mismo';
    if (diffMins < 60) return 'Hace ' + diffMins + ' min';
    if (diffHours < 24) return 'Hace ' + diffHours + ' h';
    if (diffDays < 7) return 'Hace ' + diffDays + ' días';
    return fecha.toLocaleDateString('es-ES', { day: '2-digit', month: 'short' });
}

// Ver notificación (marcar como leída y redirigir)
function verNotificacion(id, url, tipoNotificacion) {
    fetch('${pageContext.request.contextPath}/NotificacionServlet?action=marcarLeida&id=' + id, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            cargarContadorNotificaciones();
            // Si es una notificación relacionada con órdenes de compra, redirigir a /orden-compra
            if (tipoNotificacion && (tipoNotificacion.includes('ORDEN_COMPRA') || tipoNotificacion.includes('ORDEN_CONFIRMADA') || tipoNotificacion.includes('ORDEN_RECHAZADA') || tipoNotificacion.includes('ORDEN_LISTA') || tipoNotificacion.includes('ORDEN_LISTA_PRODUCTOR'))) {
                window.location.href = '${pageContext.request.contextPath}/orden-compra';
            } else if (tipoNotificacion && tipoNotificacion.includes('ENTRADA_REGISTRADA')) {
                // Si es una notificación de entrada registrada, redirigir a planes de transporte
                window.location.href = '${pageContext.request.contextPath}/planes-transporte';
            } else if (tipoNotificacion && tipoNotificacion.includes('PEDIDO_COMPLETADO')) {
                // Si es una notificación de pedido completado o plan de transporte despachado, redirigir según la URL
                if (url && url.trim() !== '') {
                    const contextPath = '${pageContext.request.contextPath}';
                    // Si la URL es MovimientoProductoServlet, redirigir directamente
                    if (url.includes('MovimientoProductoServlet')) {
                        window.location.href = contextPath + '/MovimientoProductoServlet';
                    } else {
                        const finalUrl = url.startsWith('/') ? contextPath + url : url;
                        window.location.href = finalUrl;
                    }
                } else {
                    // Si no hay URL, redirigir a pedidos por defecto
                    window.location.href = '${pageContext.request.contextPath}/logistica/pedidos';
                }
            } else if (url && url.trim() !== '') {
                const contextPath = '${pageContext.request.contextPath}';
                const finalUrl = url.startsWith('/') ? contextPath + url : url;
                window.location.href = finalUrl;
            } else {
                cargarNotificacionesRecientes();
            }
        }
    })
    .catch(error => console.error('Error al marcar como leída:', error));
}

// Marcar todas como leídas
function marcarTodasLeidas() {
    const dropdown = document.getElementById('notificacionesDropdown');
    if (dropdown) {
        const bsDropdown = bootstrap.Dropdown.getInstance(dropdown);
        if (bsDropdown) bsDropdown.hide();
    }
    
    fetch('${pageContext.request.contextPath}/NotificacionServlet?action=marcarTodasLeidas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            cargarContadorNotificaciones();
            cargarNotificacionesRecientes();
            mostrarToast('success', 'Todas las notificaciones marcadas como leídas', 'fas fa-check-circle');
        } else {
            mostrarToast('danger', 'Error al marcar notificaciones', 'fas fa-exclamation-triangle');
        }
    })
    .catch(error => {
        console.error('Error al marcar todas como leídas:', error);
        mostrarToast('danger', 'Error de conexión con el servidor', 'fas fa-exclamation-triangle');
    });
}

// Mostrar toast mejorado
function mostrarToast(tipo, mensaje, icono) {
    const toastDiv = document.createElement('div');
    toastDiv.className = 'position-fixed top-0 end-0 p-3';
    toastDiv.style.zIndex = '9999';
    toastDiv.style.marginTop = '70px';
    
    const colorMap = {
        'success': '#28a745',
        'danger': '#dc3545',
        'warning': '#ffc107',
        'info': '#17a2b8'
    };
    
    toastDiv.innerHTML = 
        '<div class="toast show" role="alert" style="min-width: 300px; border-left: 4px solid ' + (colorMap[tipo] || '#333') + ';">' +
            '<div class="toast-header" style="background: ' + (colorMap[tipo] || '#333') + '; color: white;">' +
                '<i class="' + (icono || 'fas fa-info-circle') + ' me-2"></i>' +
                '<strong class="me-auto">Notificación</strong>' +
                '<button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast"></button>' +
            '</div>' +
            '<div class="toast-body" style="font-size: 0.95rem;">' +
                mensaje +
            '</div>' +
        '</div>';
    
    document.body.appendChild(toastDiv);
    
    setTimeout(function() {
        toastDiv.querySelector('.toast').classList.remove('show');
        setTimeout(function() { toastDiv.remove(); }, 300);
    }, 3000);
}

// ===================== Control del Sidebar en Móvil =====================
if (sessionStorage.getItem('recargarDesdePerfil') === 'true') {
    sessionStorage.removeItem('recargarDesdePerfil');
    location.reload();
}

const sidebarToggle = document.getElementById('sidebarToggle');
const sidebar = document.querySelector('.nav-left-sidebar');
const sidebarOverlay = document.getElementById('sidebarOverlay');

function toggleSidebar() {
    if (sidebar && sidebarOverlay) {
        sidebar.classList.toggle('open');
        sidebarOverlay.classList.toggle('active');
        if (sidebar.classList.contains('open')) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = '';
        }
    }
}

function closeSidebar() {
    if (sidebar && sidebarOverlay) {
        sidebar.classList.remove('open');
        sidebarOverlay.classList.remove('active');
        document.body.style.overflow = '';
    }
}

if (sidebarToggle) {
    sidebarToggle.addEventListener('click', function(e) {
        e.stopPropagation();
        toggleSidebar();
    });
}

if (sidebarOverlay) {
    sidebarOverlay.addEventListener('click', closeSidebar);
}

    if (window.innerWidth <= 992) {
        const sidebarLinks = document.querySelectorAll('.nav-left-sidebar .nav-link');
        sidebarLinks.forEach(function(link) {
            link.addEventListener('click', function() {
                setTimeout(closeSidebar, 100);
            });
        });
    }

    window.addEventListener('resize', function() {
        if (window.innerWidth > 992) {
            closeSidebar();
        }
    });

// Variable para rastrear el ID de la última notificación mostrada en el modal
let ultimaNotificacionMostradaId = null;

// Mostrar modal de notificaciones automáticamente
function mostrarModalNotificaciones(notificaciones) {
    if (notificaciones.length === 0) {
        return;
    }
    
    // Filtrar solo notificaciones no leídas
    const notificacionesNoLeidas = notificaciones.filter(notif => !notif.leida);
    
    if (notificacionesNoLeidas.length === 0) {
        return;
    }
    
    // Obtener la primera notificación no leída
    const primeraNotificacion = notificacionesNoLeidas[0];
    const notifId = primeraNotificacion.id || primeraNotificacion.idNotificacion;
    
    // Si ya se mostró esta notificación, no mostrar el modal de nuevo
    if (ultimaNotificacionMostradaId === notifId) {
        return;
    }
    
    const iconoTipo = obtenerIconoTipo(primeraNotificacion.tipo || primeraNotificacion.tipoNotificacion);
    const tiempoRelativo = obtenerTiempoRelativo(primeraNotificacion.fechaCreacion);
    const nivelPrioridad = primeraNotificacion.nivel || primeraNotificacion.nivelPrioridad;
    
    // Configurar el contenido del modal
    document.getElementById('modalNotificacionIcono').className = 'notificacion-icon-modal ' + nivelPrioridad;
    document.getElementById('modalNotificacionIcono').innerHTML = '<i class="' + iconoTipo + '"></i>';
    document.getElementById('modalNotificacionTitulo').textContent = primeraNotificacion.titulo;
    document.getElementById('modalNotificacionMensaje').textContent = primeraNotificacion.mensaje;
    document.getElementById('modalNotificacionTiempo').innerHTML = '<i class="far fa-clock me-1"></i>' + tiempoRelativo;
    
    // Guardar el ID de la notificación para marcarla como leída
    document.getElementById('modalNotificacion').setAttribute('data-notificacion-id', notifId);
    document.getElementById('modalNotificacion').setAttribute('data-notificacion-url', primeraNotificacion.urlAccion || '');
    document.getElementById('modalNotificacion').setAttribute('data-tipo-notificacion', primeraNotificacion.tipo || primeraNotificacion.tipoNotificacion || '');
    
    // Mostrar el modal
    const modal = new bootstrap.Modal(document.getElementById('modalNotificacion'));
    modal.show();
    
    // Marcar que ya se mostró esta notificación
    ultimaNotificacionMostradaId = notifId;
    
    // Marcar la notificación como leída automáticamente
    if (notifId) {
        fetch('${pageContext.request.contextPath}/NotificacionServlet?action=marcarLeida&id=' + notifId, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        })
        .then(response => response.json())
        .then(data => {
            if (data.exito) {
                cargarContadorNotificaciones();
            }
        })
        .catch(error => console.error('Error al marcar como leída:', error));
    }
}

// Función para ir a la acción de la notificación
function irANotificacion() {
    const modal = document.getElementById('modalNotificacion');
    const url = modal.getAttribute('data-notificacion-url');
    const tipoNotificacion = modal.getAttribute('data-tipo-notificacion');
    const modalInstance = bootstrap.Modal.getInstance(modal);
    modalInstance.hide();
    
    // Si es una notificación relacionada con órdenes de compra, redirigir a /orden-compra
    if (tipoNotificacion && (tipoNotificacion.includes('ORDEN_COMPRA') || tipoNotificacion.includes('ORDEN_CONFIRMADA') || tipoNotificacion.includes('ORDEN_RECHAZADA') || tipoNotificacion.includes('ORDEN_LISTA') || tipoNotificacion.includes('ORDEN_LISTA_PRODUCTOR'))) {
        window.location.href = '${pageContext.request.contextPath}/orden-compra';
    } else if (tipoNotificacion && tipoNotificacion.includes('ENTRADA_REGISTRADA')) {
        // Si es una notificación de entrada registrada, redirigir a planes de transporte
        window.location.href = '${pageContext.request.contextPath}/planes-transporte';
    } else if (tipoNotificacion && tipoNotificacion.includes('PEDIDO_COMPLETADO')) {
        // Si es una notificación de pedido completado o plan de transporte despachado, redirigir según la URL
        if (url && url.trim() !== '') {
            const contextPath = '${pageContext.request.contextPath}';
            // Si la URL es MovimientoProductoServlet, redirigir directamente
            if (url.includes('MovimientoProductoServlet')) {
                window.location.href = contextPath + '/MovimientoProductoServlet';
            } else {
                const finalUrl = url.startsWith('/') ? contextPath + url : url;
                window.location.href = finalUrl;
            }
        } else {
            // Si no hay URL, redirigir a pedidos por defecto
            window.location.href = '${pageContext.request.contextPath}/logistica/pedidos';
        }
    } else if (url && url.trim() !== '') {
        const contextPath = '${pageContext.request.contextPath}';
        const finalUrl = url.startsWith('/') ? contextPath + url : url;
        window.location.href = finalUrl;
    }
}

// Cargar y mostrar todas las notificaciones en el modal grande
function mostrarModalTodasNotificaciones() {
    // Cerrar el dropdown si está abierto
    const dropdown = document.getElementById('notificacionesDropdown');
    if (dropdown) {
        const bsDropdown = bootstrap.Dropdown.getInstance(dropdown);
        if (bsDropdown) bsDropdown.hide();
    }
    
    // Mostrar loading en el modal
    document.getElementById('listaTodasNotificaciones').innerHTML = 
        '<div class="text-center py-5">' +
            '<i class="fas fa-spinner fa-spin fa-2x mb-3 text-muted"></i>' +
            '<p class="text-muted">Cargando notificaciones...</p>' +
        '</div>';
    
    // Mostrar el modal
    const modal = new bootstrap.Modal(document.getElementById('modalTodasNotificaciones'));
    modal.show();
    
    // Cargar todas las notificaciones
    fetch('${pageContext.request.contextPath}/NotificacionServlet?action=todas', {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            const notifs = data.datos.notificaciones || [];
            mostrarTodasNotificaciones(notifs);
        } else {
            document.getElementById('listaTodasNotificaciones').innerHTML = 
                '<div class="text-center py-5 text-danger">' +
                    '<i class="fas fa-exclamation-triangle fa-2x mb-3"></i>' +
                    '<p>' + (data.mensaje || 'Error al cargar notificaciones') + '</p>' +
                '</div>';
        }
    })
    .catch(error => {
        console.error('Error al cargar todas las notificaciones:', error);
        document.getElementById('listaTodasNotificaciones').innerHTML = 
            '<div class="text-center py-5 text-danger">' +
                '<i class="fas fa-exclamation-triangle fa-2x mb-3"></i>' +
                '<p>Error al cargar notificaciones</p>' +
            '</div>';
    });
}

// Mostrar todas las notificaciones en el modal grande
function mostrarTodasNotificaciones(notificaciones) {
    const lista = document.getElementById('listaTodasNotificaciones');
    
    if (notificaciones.length === 0) {
        lista.innerHTML = '<div class="text-center py-5 text-muted">' +
            '<i class="fas fa-bell-slash fa-3x mb-3"></i>' +
            '<h5 class="mb-2">No tienes notificaciones</h5>' +
            '<p class="mb-0">No hay notificaciones para mostrar</p>' +
        '</div>';
        return;
    }
    
    const htmlArray = notificaciones.map(notif => {
        const iconoTipo = obtenerIconoTipo(notif.tipo || notif.tipoNotificacion);
        const tiempoRelativo = obtenerTiempoRelativo(notif.fechaCreacion);
        const idNotif = notif.id || notif.idNotificacion;
        const nivelPrioridad = notif.nivel || notif.nivelPrioridad;
        const esLeida = notif.leida || false;
        const claseLeida = esLeida ? '' : 'no-leida';
        const tipoNotif = notif.tipo || notif.tipoNotificacion || '';
        
        return '<div class="notificacion-item-grande ' + claseLeida + '">' +
                '<div class="d-flex gap-3 align-items-start">' +
                    '<div class="notificacion-icon-grande ' + nivelPrioridad + '">' +
                        '<i class="' + iconoTipo + '"></i>' +
                    '</div>' +
                    '<div class="notificacion-contenido-grande flex-grow-1">' +
                        '<div class="d-flex justify-content-between align-items-start mb-2">' +
                            '<div class="notificacion-titulo-grande">' + notif.titulo + '</div>' +
                            (!esLeida ? '<span class="badge bg-primary rounded-pill" style="font-size: 0.7rem;">Nueva</span>' : '') +
                        '</div>' +
                        '<div class="notificacion-mensaje-grande">' + notif.mensaje + '</div>' +
                        '<div class="notificacion-tiempo-grande mt-2">' +
                            '<i class="far fa-clock me-1"></i>' + tiempoRelativo +
                        '</div>' +
                    '</div>' +
                '</div>' +
            '</div>';
    });
    
    lista.innerHTML = htmlArray.join('');
    
    // Actualizar contador en el modal
    const contador = notificaciones.filter(n => !(n.leida || false)).length;
    const contadorEl = document.getElementById('contadorModalNotificaciones');
    if (contadorEl) {
        contadorEl.textContent = contador > 0 ? contador + ' no leída' + (contador > 1 ? 's' : '') : 'Todas leídas';
    }
}

// Marcar todas como leídas desde el modal
function marcarTodasLeidasDesdeModal() {
    fetch('${pageContext.request.contextPath}/NotificacionServlet?action=marcarTodasLeidas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            cargarContadorNotificaciones();
            mostrarModalTodasNotificaciones(); // Recargar notificaciones
            mostrarToast('success', 'Todas las notificaciones marcadas como leídas', 'fas fa-check-circle');
        } else {
            mostrarToast('danger', 'Error al marcar notificaciones', 'fas fa-exclamation-triangle');
        }
    })
    .catch(error => {
        console.error('Error al marcar todas como leídas:', error);
        mostrarToast('danger', 'Error de conexión con el servidor', 'fas fa-exclamation-triangle');
    });
}
</script>

<!-- Modal de Notificaciones -->
<div class="modal fade" id="modalNotificacion" tabindex="-1" aria-labelledby="modalNotificacionLabel" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 15px; border: none; box-shadow: 0 10px 40px rgba(0,0,0,0.2);">
            <div class="modal-header" style="background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%); color: white; border-radius: 15px 15px 0 0; border: none; padding: 20px;">
                <h5 class="modal-title" id="modalNotificacionLabel" style="font-weight: 600;">
                    <i class="fas fa-bell me-2"></i>Nueva Notificación
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding: 30px;">
                <div class="d-flex align-items-start gap-4">
                    <div id="modalNotificacionIcono" class="notificacion-icon-modal" style="flex-shrink: 0;">
                        <i class="fas fa-bell"></i>
                    </div>
                    <div style="flex: 1;">
                        <h6 id="modalNotificacionTitulo" style="font-weight: 600; color: #212529; margin-bottom: 10px; font-size: 1.1rem;"></h6>
                        <p id="modalNotificacionMensaje" style="color: #495057; margin-bottom: 15px; line-height: 1.6; font-size: 0.95rem;"></p>
                        <div id="modalNotificacionTiempo" style="color: #6c757d; font-size: 0.85rem;">
                            <i class="far fa-clock me-1"></i>Reciente
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer" style="border-top: 1px solid #e9ecef; padding: 20px; border-radius: 0 0 15px 15px;">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="border-radius: 8px; padding: 8px 20px;">
                    <i class="fas fa-times me-2"></i>Cerrar
                </button>
                <button type="button" class="btn btn-primary" onclick="irANotificacion()" style="background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%); border: none; border-radius: 8px; padding: 8px 20px;">
                    <i class="fas fa-arrow-right me-2"></i>Ver Detalles
                </button>
            </div>
        </div>
    </div>
</div>

<style>
    .notificacion-icon-modal {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        flex-shrink: 0;
    }
    
    .notificacion-icon-modal.CRITICAL {
        background: #fee;
        color: #dc3545;
    }
    
    .notificacion-icon-modal.WARNING {
        background: #fff3cd;
        color: #ffc107;
    }
    
    .notificacion-icon-modal.INFO {
        background: #d1ecf1;
        color: #0dcaf0;
    }
    
    #modalNotificacion .modal-content {
        animation: slideDown 0.3s ease-out;
    }
    
    @keyframes slideDown {
        from {
            transform: translateY(-50px);
            opacity: 0;
        }
        to {
            transform: translateY(0);
            opacity: 1;
        }
    }
    
    .notificacion-item-grande {
        padding: 20px;
        border-bottom: 1px solid #e9ecef;
        transition: all 0.3s ease;
        cursor: default;
        background: white;
        border-left: 4px solid transparent;
    }
    
    .notificacion-item-grande:hover {
        background: #f8f9fa;
    }
    
    .notificacion-item-grande.no-leida {
        background: #e8f4f8;
        border-left-color: #00a896;
    }
    
    .notificacion-icon-grande {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.3rem;
        flex-shrink: 0;
    }
    
    .notificacion-icon-grande.CRITICAL {
        background: #fee;
        color: #dc3545;
    }
    
    .notificacion-icon-grande.WARNING {
        background: #fff3cd;
        color: #ffc107;
    }
    
    .notificacion-icon-grande.INFO {
        background: #d1ecf1;
        color: #0dcaf0;
    }
    
    .notificacion-titulo-grande {
        font-weight: 600;
        font-size: 1rem;
        color: #212529;
        margin-bottom: 8px;
    }
    
    .notificacion-mensaje-grande {
        font-size: 0.9rem;
        color: #495057;
        line-height: 1.5;
        margin-bottom: 8px;
    }
    
    .notificacion-tiempo-grande {
        font-size: 0.8rem;
        color: #6c757d;
    }
</style>

<!-- Modal Grande para Todas las Notificaciones -->
<div class="modal fade" id="modalTodasNotificaciones" tabindex="-1" aria-labelledby="modalTodasNotificacionesLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content" style="border-radius: 15px; border: none; box-shadow: 0 10px 40px rgba(0,0,0,0.2);">
            <div class="modal-header" style="background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%); color: white; border-radius: 15px 15px 0 0; border: none; padding: 20px;">
                <h5 class="modal-title" id="modalTodasNotificacionesLabel" style="font-weight: 600;">
                    <i class="fas fa-bell me-2"></i>Todas las Notificaciones
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding: 0;">
                <div class="d-flex justify-content-between align-items-center p-3 border-bottom" style="background: #f8f9fa;">
                    <button class="btn btn-sm" onclick="marcarTodasLeidasDesdeModal()" style="background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%); color: white; border: none; border-radius: 8px; padding: 6px 15px;">
                        <i class="fas fa-check-double me-1"></i>Marcar todas como leídas
                    </button>
                    <span class="text-muted" id="contadorModalNotificaciones"></span>
                </div>
                <div id="listaTodasNotificaciones" style="max-height: 500px; overflow-y: auto; overflow-x: hidden;">
                    <div class="text-center py-5">
                        <i class="fas fa-spinner fa-spin fa-2x mb-3 text-muted"></i>
                        <p class="text-muted">Cargando notificaciones...</p>
                    </div>
                </div>
            </div>
            <div class="modal-footer" style="border-top: 1px solid #e9ecef; padding: 15px 20px; border-radius: 0 0 15px 15px;">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="border-radius: 8px; padding: 8px 20px;">
                    <i class="fas fa-times me-2"></i>Cerrar
                </button>
            </div>
        </div>
    </div>
</div>