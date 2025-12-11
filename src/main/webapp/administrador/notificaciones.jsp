<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    // Verificar si es Administrador (rol_id = 1)
    if (usuario.getRol() == null || usuario.getRol().getIdRol() != 1) {
        response.sendRedirect(request.getContextPath() + "/acceso");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Notificaciones"/>
    </jsp:include>
    <style>
        /* Estilos para botones de filtro */
        .filtro-btn {
            padding: 8px 16px;
            border: 2px solid #dee2e6;
            background: white;
            color: #212529;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 0.9rem;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        
        .filtro-btn:hover {
            border-color: var(--turquoise-dark);
            color: var(--turquoise-dark);
            background: var(--seafoam-light);
        }
        
        .filtro-btn.active {
            background: var(--turquoise-dark);
            color: white;
            border-color: var(--turquoise-dark);
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Notificaciones'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content" style="padding-bottom: 100px !important;">
            <div class="row">
                <div class="col-12">
                    <!-- Header de página -->
                    <div class="page-header mb-4">
                        <h2 class="pageheader-title">
                            <i class="fas fa-bell me-2"></i>Gestión de Notificaciones
                        </h2>
                        <p class="pageheader-text">Administra tus notificaciones del sistema.</p>
                    </div>
                    
                    <!-- Card principal estilo tabla -->
                    <div class="card shadow-sm">
                        <div class="card-header" style="background: var(--turquoise-dark); color: white; border-bottom: none; padding: 1rem 1.25rem;">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="mb-0" style="color: white; font-size: 1.1rem;">
                                        <i class="fas fa-bell me-2"></i>Mis Notificaciones
                                    </h5>
                                </div>
                                <div class="d-flex gap-2">
                                    <button class="btn btn-light btn-sm" onclick="marcarTodasLeidas()" style="font-size: 0.85rem;">
                                        <i class="fas fa-check-double me-1"></i>Marcar todas leídas
                                    </button>
                                    <button class="btn btn-outline-light btn-sm" onclick="eliminarLeidas()" style="font-size: 0.85rem;">
                                        <i class="fas fa-trash me-1"></i>Eliminar leídas
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <div class="card-body p-0">
                            <!-- Filtros dentro del card -->
                            <div class="px-3 py-2 border-bottom bg-light">
                                <div class="d-flex gap-2 flex-wrap">
                                    <button class="filtro-btn active" data-filtro="todas" onclick="aplicarFiltro('todas', this)">
                                        <i class="fas fa-list me-1"></i>Todas
                                    </button>
                                    <button class="filtro-btn" data-filtro="noLeidas" onclick="aplicarFiltro('noLeidas', this)">
                                        <i class="fas fa-circle me-1" style="font-size: 8px;"></i>No leídas
                                    </button>
                                    <button class="filtro-btn" data-filtro="CRITICAL" onclick="aplicarFiltro('CRITICAL', this)">
                                        <i class="fas fa-exclamation-triangle me-1"></i>Críticas
                                    </button>
                                    <button class="filtro-btn" data-filtro="WARNING" onclick="aplicarFiltro('WARNING', this)">
                                        <i class="fas fa-exclamation-circle me-1"></i>Advertencias
                                    </button>
                                    <button class="filtro-btn" data-filtro="INFO" onclick="aplicarFiltro('INFO', this)">
                                        <i class="fas fa-info-circle me-1"></i>Información
                                    </button>
                                </div>
                            </div>
                            
                            <!-- Lista de notificaciones -->
                            <div id="contenedorNotificaciones">
                                <div class="text-center py-5">
                                    <i class="fas fa-spinner fa-spin fa-3x mb-3" style="color: var(--turquoise-dark);"></i>
                                    <p class="text-muted mb-0">Cargando notificaciones...</p>
                                </div>
                            </div>
                            
                            <!-- Paginación -->
                            <div id="paginacion" class="d-flex justify-content-center py-3 border-top bg-light"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    let filtroActual = 'todas';
    let paginaActual = 0;
    const notificacionesPorPagina = 4;
    
    // Cargar notificaciones al inicio
    document.addEventListener('DOMContentLoaded', function() {
        cargarNotificaciones();
    });
    
    // Aplicar filtro
    function aplicarFiltro(filtro, btn) {
        filtroActual = filtro;
        paginaActual = 0;
        
        // Actualizar botones activos
        document.querySelectorAll('.filtro-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        
        cargarNotificaciones();
    }
    
    // Cargar notificaciones
    function cargarNotificaciones() {
        const params = new URLSearchParams({
            action: 'obtener',
            limit: notificacionesPorPagina,
            offset: paginaActual * notificacionesPorPagina,
            soloNoLeidas: filtroActual === 'noLeidas' ? 'true' : 'false'
        });
        
        fetch('${pageContext.request.contextPath}/NotificacionServlet?' + params)
            .then(response => response.json())
            .then(data => {
                console.log('Respuesta del servidor:', data);
                if (data.exito) {
                    mostrarNotificaciones(data.datos.notificaciones);
                    const total = data.datos.totalGeneral || data.datos.total || 0;
                    console.log('Total para paginación:', total);
                    generarPaginacion(total);
                } else {
                    console.error('Error del servidor:', data.mensaje);
                    document.getElementById('contenedorNotificaciones').innerHTML =
                        '<div class="alert alert-warning">' +
                            '<i class="fas fa-exclamation-triangle me-2"></i>' + data.mensaje +
                        '</div>';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                document.getElementById('contenedorNotificaciones').innerHTML =
                    '<div class="alert alert-danger">' +
                        '<i class="fas fa-exclamation-triangle me-2"></i>Error al cargar notificaciones' +
                    '</div>';
            });
    }
    
    // Mostrar notificaciones
    function mostrarNotificaciones(notificaciones) {
        const contenedor = document.getElementById('contenedorNotificaciones');
        
        if (notificaciones.length === 0) {
            contenedor.innerHTML =
                '<div class="text-center py-5">' +
                    '<i class="fas fa-bell-slash fa-3x text-muted mb-3"></i>' +
                    '<h6 class="text-muted">No hay notificaciones</h6>' +
                    '<p class="text-muted mb-0 small">No se encontraron notificaciones con los filtros seleccionados.</p>' +
                '</div>';
            return;
        }
        
        let html = '<div class="list-group list-group-flush">';
        
        notificaciones.forEach(notif => {
            const badgeClass = notif.nivelPrioridad === 'CRITICAL' ? 'danger' : 
                              notif.nivelPrioridad === 'WARNING' ? 'warning' : 'info';
            const borderColor = notif.nivelPrioridad === 'CRITICAL' ? '#dc3545' : 
                               notif.nivelPrioridad === 'WARNING' ? '#ffc107' : '#0dcaf0';
            const bgColor = notif.leida ? '#ffffff' : '#f8f9fa';
            const iconClass = notif.nivelPrioridad === 'CRITICAL' ? 'fa-exclamation-triangle' :
                             notif.nivelPrioridad === 'WARNING' ? 'fa-exclamation-circle' : 'fa-info-circle';
            
            html += '<div class="list-group-item list-group-item-action py-3" style="border-left: 4px solid ' + borderColor + '; background-color: ' + bgColor + '; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.backgroundColor=\'#f8f9fa\'" onmouseout="this.style.backgroundColor=\'' + bgColor + '\'" onclick="marcarLeida(' + notif.idNotificacion + ')">';
            html += '    <div class="d-flex w-100 justify-content-between align-items-start">';
            html += '        <div class="flex-grow-1">';
            html += '            <div class="d-flex align-items-center mb-1">';
            html += '                <i class="fas ' + iconClass + ' me-2 text-' + badgeClass + '" style="font-size: 1rem;"></i>';
            html += '                <h6 class="mb-0 fw-bold" style="font-size: 0.95rem;">' + notif.titulo + '</h6>';
            if (!notif.leida) {
                html += '                <span class="badge bg-primary ms-2 px-2 py-1" style="font-size: 0.65rem;">Nueva</span>';
            }
            html += '            </div>';
            html += '            <p class="mb-1 text-muted" style="font-size: 0.9rem;">' + notif.mensaje + '</p>';
            html += '            <small class="text-muted" style="font-size: 0.8rem;">';
            html += '                <i class="far fa-clock me-1"></i>' + obtenerTiempoRelativo(notif.fechaCreacion);
            if (notif.productoNombre) {
                html += ' • <i class="fas fa-box me-1"></i>' + notif.productoNombre;
            }
            if (notif.loteCodigo) {
                html += ' • <i class="fas fa-barcode me-1"></i>' + notif.loteCodigo;
            }
            html += '            </small>';
            html += '        </div>';
            html += '        <button class="btn btn-sm btn-outline-danger ms-3" style="font-size: 0.8rem; padding: 0.25rem 0.5rem;" onclick="event.stopPropagation(); eliminarNotificacion(' + notif.idNotificacion + ')" title="Eliminar">';
            html += '            <i class="fas fa-trash"></i>';
            html += '        </button>';
            html += '    </div>';
            html += '</div>';
        });
        
        html += '</div>';
        contenedor.innerHTML = html;
    }
    
    // Generar paginación
    function generarPaginacion(total) {
        const totalPaginas = Math.ceil(total / notificacionesPorPagina);
        const contenedor = document.getElementById('paginacion');
        
        if (totalPaginas <= 1) {
            contenedor.innerHTML = '';
            return;
        }
        
        let html = '<nav aria-label="Paginación de notificaciones"><ul class="pagination pagination-sm mb-0">';
        
        // Botón anterior
        html += '<li class="page-item ' + (paginaActual === 0 ? 'disabled' : '') + '">';
        html += '    <a class="page-link" href="#" onclick="cambiarPagina(' + (paginaActual - 1) + '); return false;" style="color: var(--turquoise-dark);"><i class="fas fa-chevron-left me-1"></i>Anterior</a>';
        html += '</li>';
        
        // Números de página
        for (let i = 0; i < totalPaginas; i++) {
            if (i === 0 || i === totalPaginas - 1 || (i >= paginaActual - 1 && i <= paginaActual + 1)) {
                html += '<li class="page-item ' + (i === paginaActual ? 'active' : '') + '">';
                if (i === paginaActual) {
                    html += '    <a class="page-link" href="#" onclick="cambiarPagina(' + i + '); return false;" style="background-color: var(--turquoise-dark); border-color: var(--turquoise-dark);">' + (i + 1) + '</a>';
                } else {
                    html += '    <a class="page-link" href="#" onclick="cambiarPagina(' + i + '); return false;" style="color: var(--turquoise-dark);">' + (i + 1) + '</a>';
                }
                html += '</li>';
            } else if (i === paginaActual - 2 || i === paginaActual + 2) {
                html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
            }
        }
        
        // Botón siguiente
        html += '<li class="page-item ' + (paginaActual >= totalPaginas - 1 ? 'disabled' : '') + '">';
        html += '    <a class="page-link" href="#" onclick="cambiarPagina(' + (paginaActual + 1) + '); return false;" style="color: var(--turquoise-dark);">Siguiente<i class="fas fa-chevron-right ms-1"></i></a>';
        html += '</li>';
        
        html += '</ul></nav>';
        contenedor.innerHTML = html;
    }
    
    // Cambiar página
    function cambiarPagina(pagina) {
        paginaActual = pagina;
        cargarNotificaciones();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
    
    // Ver notificación (marcar como leída)
    function marcarLeida(id) {
        fetch('${pageContext.request.contextPath}/NotificacionServlet?action=marcarLeida&id=' + id, {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            if (data.exito) {
                cargarNotificaciones();
            }
        });
    }
    
    // Marcar todas como leídas
    function marcarTodasLeidas() {
        mostrarToast('Marcando todas como leídas...', 'info');
        
        fetch('${pageContext.request.contextPath}/NotificacionServlet?action=marcarTodasLeidas', {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            if (data.exito) {
                mostrarToast('Todas las notificaciones marcadas como leídas', 'success');
                cargarNotificaciones();
            }
        })
        .catch(error => {
            mostrarToast('Error al marcar notificaciones', 'error');
        });
    }
    
    // Eliminar notificaciones leídas
    function eliminarLeidas() {
        mostrarToast('Eliminando notificaciones leídas...', 'info');
        
        fetch('${pageContext.request.contextPath}/NotificacionServlet?action=eliminarLeidas', {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            if (data.exito) {
                mostrarToast('Notificaciones leídas eliminadas', 'success');
                cargarNotificaciones();
            }
        })
        .catch(error => {
            mostrarToast('Error al eliminar notificaciones', 'error');
        });
    }
    
    // Eliminar notificación individual
    function eliminarNotificacion(id) {
        fetch('${pageContext.request.contextPath}/NotificacionServlet?action=eliminar&id=' + id, {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            if (data.exito) {
                mostrarToast('Notificación eliminada', 'success');
                cargarNotificaciones();
            }
        })
        .catch(error => {
            mostrarToast('Error al eliminar notificación', 'error');
        });
    }
    
    // Funciones auxiliares
    function obtenerIconoTipo(tipo) {
        const iconos = {
            'STOCK_MINIMO': 'fas fa-box-open',
            'STOCK_CRITICO': 'fas fa-exclamation-triangle',
            'VENCIMIENTO_PROXIMO': 'fas fa-calendar-times',
            'VENCIMIENTO_URGENTE': 'fas fa-bell',
            'PRODUCTO_VENCIDO': 'fas fa-times-circle',
            'PEDIDO_PENDIENTE': 'fas fa-shopping-cart',
            'INCIDENCIA_REPORTADA': 'fas fa-exclamation-circle',
            'ORDEN_COMPRA_APROBADA': 'fas fa-check-circle',
            'ALERTA_SISTEMA': 'fas fa-info-circle',
            'MOVIMIENTO_CRITICO': 'fas fa-exchange-alt'
        };
        return iconos[tipo] || 'fas fa-bell';
    }
    
    function obtenerTiempoRelativo(fechaStr) {
        const fecha = new Date(fechaStr);
        const ahora = new Date();
        const diffMs = ahora - fecha;
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMs / 3600000);
        const diffDays = Math.floor(diffMs / 86400000);
        
        if (diffMins < 1) return 'Ahora mismo';
        if (diffMins < 60) return 'Hace ' + diffMins + ' min';
        if (diffHours < 24) return 'Hace ' + diffHours + ' h';
        if (diffDays < 7) return 'Hace ' + diffDays + ' días';
        return fecha.toLocaleDateString('es-ES', { day: '2-digit', month: 'short', year: 'numeric' });
    }
    
    function mostrarToast(mensaje, tipo) {
        const toastDiv = document.createElement('div');
        toastDiv.className = 'position-fixed top-0 end-0 p-3';
        toastDiv.style.zIndex = '9999';
        toastDiv.style.marginTop = '70px';
        
        const colorMap = {
            'success': '#28a745',
            'error': '#dc3545',
            'warning': '#ffc107',
            'info': '#17a2b8'
        };
        
        const iconMap = {
            'success': 'fas fa-check-circle',
            'error': 'fas fa-exclamation-triangle',
            'warning': 'fas fa-exclamation-circle',
            'info': 'fas fa-info-circle'
        };
        
        toastDiv.innerHTML =
            '<div class="toast show" role="alert" style="min-width: 300px; border-left: 4px solid ' + (colorMap[tipo] || '#333') + ';">' +
                '<div class="toast-header" style="background: ' + (colorMap[tipo] || '#333') + '; color: white;">' +
                    '<i class="' + (iconMap[tipo] || 'fas fa-info-circle') + ' me-2"></i>' +
                    '<strong class="me-auto">Notificación</strong>' +
                    '<button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast"></button>' +
                '</div>' +
                '<div class="toast-body" style="font-size: 0.95rem;">' +
                    mensaje +
                '</div>' +
            '</div>';
        
        document.body.appendChild(toastDiv);
        
        setTimeout(() => {
            toastDiv.querySelector('.toast').classList.remove('show');
            setTimeout(() => toastDiv.remove(), 300);
        }, 3000);
    }
</script>
</body>
</html>
