<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect(request.getContextPath() + "/acceso/login");
        return;
    }
    // Verificar si es Productor (rol_id = 3)
    if (usuario.getRol() == null || usuario.getRol().getIdRol() != 3) {
        response.sendRedirect(request.getContextPath() + "/acceso/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notificaciones - Telito Bodeguero</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <style>
        :root {
            --turquoise-dark: #006d77;
            --seafoam: #83c5be;
            --seafoam-light: #edf6f9;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: var(--seafoam-light);
        }
        
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
    <div class="container-fluid py-4">
        <div class="row">
            <div class="col-12">
                <div class="page-header mb-4">
                    <h2 class="text-primary">
                        <i class="fas fa-bell me-2"></i>Mis Notificaciones
                    </h2>
                    <p class="text-muted">Administra tus notificaciones del sistema.</p>
                </div>
                
                <div class="card shadow-sm">
                    <div class="card-header" style="background: var(--turquoise-dark); color: white;">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <h5 class="mb-0" style="color: white;">
                                <i class="fas fa-bell me-2"></i>Notificaciones
                            </h5>
                            <div class="d-flex gap-2">
                                <button class="btn btn-light btn-sm" onclick="marcarTodasLeidas()">
                                    <i class="fas fa-check-double me-1"></i>Marcar todas leídas
                                </button>
                                <button class="btn btn-outline-light btn-sm" onclick="eliminarLeidas()">
                                    <i class="fas fa-trash me-1"></i>Eliminar leídas
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="card-body p-0">
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
                        
                        <div id="contenedorNotificaciones">
                            <div class="text-center py-5">
                                <i class="fas fa-spinner fa-spin fa-3x mb-3" style="color: var(--turquoise-dark);"></i>
                                <p class="text-muted mb-0">Cargando notificaciones...</p>
                            </div>
                        </div>
                        
                        <div id="paginacion" class="d-flex justify-content-center py-3 border-top bg-light"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let filtroActual = 'todas';
        let paginaActual = 0;
        const notificacionesPorPagina = 20;
        
        document.addEventListener('DOMContentLoaded', function() {
            cargarNotificaciones();
        });
        
        function aplicarFiltro(filtro, btn) {
            filtroActual = filtro;
            paginaActual = 0;
            document.querySelectorAll('.filtro-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            cargarNotificaciones();
        }
        
        function cargarNotificaciones() {
            const params = new URLSearchParams({
                action: 'obtener',
                limit: notificacionesPorPagina,
                offset: paginaActual * notificacionesPorPagina,
                soloNoLeidas: filtroActual === 'noLeidas' ? 'true' : 'false'
            });
            
            fetch('<%= request.getContextPath() %>/NotificacionServlet?' + params)
                .then(response => response.json())
                .then(data => {
                    if (data.exito) {
                        let notifs = data.datos.notificaciones || [];
                        if (filtroActual !== 'todas' && filtroActual !== 'noLeidas') {
                            notifs = notifs.filter(n => n.nivelPrioridad === filtroActual);
                        }
                        mostrarNotificaciones(notifs);
                        const total = data.datos.totalGeneral || data.datos.total || 0;
                        generarPaginacion(total);
                    } else {
                        document.getElementById('contenedorNotificaciones').innerHTML =
                            '<div class="alert alert-warning"><i class="fas fa-exclamation-triangle me-2"></i>' + data.mensaje + '</div>';
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    document.getElementById('contenedorNotificaciones').innerHTML =
                        '<div class="alert alert-danger"><i class="fas fa-exclamation-triangle me-2"></i>Error al cargar notificaciones</div>';
                });
        }
        
        function mostrarNotificaciones(notificaciones) {
            const contenedor = document.getElementById('contenedorNotificaciones');
            
            if (notificaciones.length === 0) {
                contenedor.innerHTML =
                    '<div class="text-center py-5">' +
                        '<i class="fas fa-bell-slash fa-3x text-muted mb-3"></i>' +
                        '<h6 class="text-muted">No hay notificaciones</h6>' +
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
                
                html += '<div class="list-group-item list-group-item-action py-3" style="border-left: 4px solid ' + borderColor + '; background-color: ' + bgColor + '; cursor: pointer;" onclick="marcarLeida(' + notif.idNotificacion + ', \'' + (notif.urlAccion || '') + '\')">';
                html += '    <div class="d-flex w-100 justify-content-between align-items-start">';
                html += '        <div class="flex-grow-1">';
                html += '            <div class="d-flex align-items-center mb-1">';
                html += '                <i class="fas ' + iconClass + ' me-2 text-' + badgeClass + '"></i>';
                html += '                <h6 class="mb-0 fw-bold">' + notif.titulo + '</h6>';
                if (!notif.leida) {
                    html += '                <span class="badge bg-primary ms-2">Nueva</span>';
                }
                html += '            </div>';
                html += '            <p class="mb-1 text-muted">' + notif.mensaje + '</p>';
                html += '            <small class="text-muted">';
                html += '                <i class="far fa-clock me-1"></i>' + obtenerTiempoRelativo(notif.fechaCreacion);
                html += '            </small>';
                html += '        </div>';
                html += '        <button class="btn btn-sm btn-outline-danger ms-3" onclick="event.stopPropagation(); eliminarNotificacion(' + notif.idNotificacion + ')" title="Eliminar">';
                html += '            <i class="fas fa-trash"></i>';
                html += '        </button>';
                html += '    </div>';
                html += '</div>';
            });
            
            html += '</div>';
            contenedor.innerHTML = html;
        }
        
        function generarPaginacion(total) {
            const totalPaginas = Math.ceil(total / notificacionesPorPagina);
            const contenedor = document.getElementById('paginacion');
            
            if (totalPaginas <= 1) {
                contenedor.innerHTML = '';
                return;
            }
            
            let html = '<nav><ul class="pagination pagination-sm mb-0">';
            html += '<li class="page-item ' + (paginaActual === 0 ? 'disabled' : '') + '">';
            html += '    <a class="page-link" href="#" onclick="cambiarPagina(' + (paginaActual - 1) + '); return false;">Anterior</a>';
            html += '</li>';
            
            for (let i = 0; i < totalPaginas; i++) {
                if (i === 0 || i === totalPaginas - 1 || (i >= paginaActual - 1 && i <= paginaActual + 1)) {
                    html += '<li class="page-item ' + (i === paginaActual ? 'active' : '') + '">';
                    html += '    <a class="page-link" href="#" onclick="cambiarPagina(' + i + '); return false;">' + (i + 1) + '</a>';
                    html += '</li>';
                } else if (i === paginaActual - 2 || i === paginaActual + 2) {
                    html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
                }
            }
            
            html += '<li class="page-item ' + (paginaActual >= totalPaginas - 1 ? 'disabled' : '') + '">';
            html += '    <a class="page-link" href="#" onclick="cambiarPagina(' + (paginaActual + 1) + '); return false;">Siguiente</a>';
            html += '</li>';
            html += '</ul></nav>';
            contenedor.innerHTML = html;
        }
        
        function cambiarPagina(pagina) {
            paginaActual = pagina;
            cargarNotificaciones();
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
        
        function marcarLeida(id, url) {
            fetch('<%= request.getContextPath() %>/NotificacionServlet?action=marcarLeida&id=' + id, {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.exito) {
                    if (url && url.trim() !== '') {
                        window.location.href = url;
                    } else {
                        cargarNotificaciones();
                    }
                }
            });
        }
        
        function marcarTodasLeidas() {
            fetch('<%= request.getContextPath() %>/NotificacionServlet?action=marcarTodasLeidas', {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.exito) {
                    cargarNotificaciones();
                }
            });
        }
        
        function eliminarLeidas() {
            fetch('<%= request.getContextPath() %>/NotificacionServlet?action=eliminarLeidas', {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.exito) {
                    cargarNotificaciones();
                }
            });
        }
        
        function eliminarNotificacion(id) {
            fetch('<%= request.getContextPath() %>/NotificacionServlet?action=eliminar&id=' + id, {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.exito) {
                    cargarNotificaciones();
                }
            });
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
            return fecha.toLocaleDateString('es-ES', { day: '2-digit', month: 'short' });
        }
    </script>
</body>
</html>

