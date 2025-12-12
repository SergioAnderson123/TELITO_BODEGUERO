<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) {
        session.removeAttribute("errorMsg");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enviar Reporte por Correo - Telito Bodeguero</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --turquoise-dark: #006d77;
            --seafoam: #83c5be;
            --seafoam-light: #edf6f9;
            --white: #ffffff;
            --text-dark: #2b2d42;
            --text-muted: #6c757d;
            --border-color: #e9ecef;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            margin: 0;
            background-color: var(--seafoam-light);
            color: var(--text-dark);
        }
        .dashboard-main-wrapper { display: flex; min-height: 100vh; }
        .dashboard-header {
            background-color: #fff;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: fixed; top: 0; right: 0; left: 250px; z-index: 999;
            height: 70px; border-bottom: 1px solid var(--border-color);
        }
        .dashboard-wrapper { margin-left: 250px; width: calc(100% - 250px); min-height: 100vh; }
        .dashboard-content { margin-top: 70px; padding: 20px; }
        
        /* ===================== Sidebar - Igual a misProductos.jsp ===================== */
        .nav-left-sidebar {
            width: 250px;
            background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%);
            min-height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 1000;
            box-shadow: 3px 0 15px rgba(0,0,0,.12);
        }
        .nav-link {
            color: rgba(255,255,255,.95) !important;
            padding: 13px 20px;
            border-radius: 10px;
            margin: 6px 15px;
            transition: all .3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            font-weight: 500;
            position: relative;
            overflow: hidden;
        }
        .nav-link::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            background: #fff;
            transform: scaleY(0);
            transition: transform .3s ease;
            border-radius: 0 4px 4px 0;
        }
        .nav-link:hover, .nav-link.active {
            background-color: rgba(255,255,255,.25);
            color: #fff !important;
            transform: translateX(8px);
            box-shadow: 0 4px 12px rgba(0,0,0,.15);
        }
        .nav-link:hover::before, .nav-link.active::before {
            transform: scaleY(1);
        }
        .nav-link i { margin-right: 12px; width: 22px; font-size: 1.1rem; }
        .nav-divider {
            color: rgba(255,255,255,.95);
            font-weight: 700;
            padding: 18px 20px 8px;
            margin-top: 25px;
            font-size: .8rem;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            border-top: 1px solid rgba(255,255,255,.15);
        }
        .navbar-brand { font-weight: 700; color: var(--turquoise-dark); }
        .page-header { 
            margin-bottom: 15px; 
            padding-top: 0.5rem; 
            padding-bottom: 0.5rem; 
        }
        .page-header h2 { 
            color: var(--turquoise-dark); 
            font-weight: 700; 
            margin-bottom: 5px; 
            font-size: 1.4rem; 
        }
        .page-header p { 
            color: var(--text-muted); 
            font-size: 0.85rem; 
            margin-bottom: 0;
        }
        .pageheader-title {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #00a896 !important;
        }
        .pageheader-title i {
            color: var(--seafoam);
        }
        .sidebar-toggle {
            display: none;
            background: none;
            border: none;
            color: var(--turquoise-dark);
            font-size: 1.5rem;
            padding: 8px 12px;
            cursor: pointer;
            margin-right: 15px;
            transition: color 0.3s ease;
        }
        .sidebar-toggle:hover {
            color: var(--seafoam);
        }
        .sidebar-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 999;
            opacity: 0;
            transition: opacity 0.3s ease;
        }
        .sidebar-overlay.active {
            opacity: 1;
        }
        .card {
            background-color: var(--white);
            padding: 0;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            margin-bottom: 20px;
            border: none;
        }
        .card-header { 
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%);
            color: white;
            border-radius: 12px 12px 0 0;
            padding: 15px 20px;
            margin: 0;
            border-bottom: none;
        }
        .card-header h5 { 
            margin: 0; 
            color: white; 
            font-weight: 600;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .card-body { 
            padding: 20px; 
        }
        
        /* ===================== Alert mejorada ===================== */
        .alert-info {
            background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
            border: none;
            border-left: 4px solid #2196f3;
            border-radius: 8px;
            padding: 12px 15px;
            margin-bottom: 20px;
            font-size: 0.9rem;
        }
        .alert-info ul {
            margin-bottom: 8px;
            margin-top: 8px;
            padding-left: 20px;
        }
        .alert-info li {
            font-size: 0.85rem;
            margin-bottom: 3px;
        }
        .alert-info strong {
            color: #1976d2;
        }
        
        /* ===================== Formulario mejorado ===================== */
        form label { 
            display: block; 
            margin-bottom: 6px; 
            font-weight: 600; 
            color: var(--text-dark); 
            font-size: 0.9rem;
        }
        form label i {
            color: #00a896;
            margin-right: 6px;
        }
        form input, form select, form textarea {
            width: 100%; 
            padding: 10px 12px; 
            border: 2px solid var(--border-color); 
            border-radius: 8px; 
            box-sizing: border-box; 
            font-size: 0.95rem;
            transition: all 0.3s ease;
        }
        form input:focus, form select:focus, form textarea:focus {
            border-color: #00a896;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        .form-control {
            border: 2px solid var(--border-color);
            transition: all 0.3s ease;
        }
        .form-control:focus {
            border-color: #00a896;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        
        /* ===================== Botones mejorados ===================== */
        .btn-primary {
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%);
            border: none;
            color: white;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(0,168,150,0.3);
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0,168,150,0.4);
            background: linear-gradient(135deg, #00b8a3 0%, #02a190 100%);
        }
        .btn-secondary {
            background: linear-gradient(135deg, #6c757d 0%, #5a6268 100%);
            border: none;
            color: white;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(108,117,125,0.3);
        }
        /* ===================== Responsive ===================== */
        @media (max-width: 992px) {
            .sidebar-toggle {
                display: inline-block;
            }
            .nav-left-sidebar { 
                position: fixed; 
                transform: translateX(-100%); 
                transition: transform 0.3s ease;
                z-index: 1000;
            }
            .nav-left-sidebar.open { 
                transform: translateX(0); 
            }
            .sidebar-overlay {
                display: block;
            }
            .dashboard-header { 
                left: 0; 
                padding: 0 10px;
            }
            .navbar-brand span {
                font-size: 0.9rem;
            }
            .navbar-nav .nav-link span {
                display: none;
            }
            .dashboard-wrapper { margin-left: 0; width: 100%; }
            .dashboard-content { padding: 15px; }
        }
        
        @media (max-width: 576px) {
            .navbar-brand span {
                display: none;
            }
            .page-header h2 {
                font-size: 1.2rem;
            }
            .card-body {
                padding: 15px;
            }
            .alert-info {
                font-size: 0.85rem;
            }
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <!-- ===================== Overlay para móvil ===================== -->
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <!-- ===================== Header / Topbar ===================== -->
    <div class="dashboard-header">
        <nav class="navbar navbar-expand">
            <div class="container-fluid">
                <!-- Botón Hamburguesa -->
                <button class="sidebar-toggle" id="sidebarToggle" type="button" aria-label="Toggle sidebar">
                    <i class="fas fa-bars"></i>
                </button>
                <!-- Brand -->
                <a class="navbar-brand d-flex align-items-center" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos">
                    <i class="fas fa-store me-2" style="color: var(--seafoam);"></i>
                    <span>Telito Bodeguero</span>
                </a>

                <!-- Right actions -->
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item dropdown">
                        <%
                            com.example.telito.administrador.beans.Usuario usuarioHeader = 
                                (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
                            String nombreCompleto = usuarioHeader != null ? 
                                usuarioHeader.getNombres() + " " + usuarioHeader.getApellidos() : "Usuario";
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
                        <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                            <img src="<%= fotoUrl %>" alt="User" class="rounded-circle me-2" width="32" height="32">
                            <span style="color:#006d77;"><%= nombreCompleto %></span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="<%= request.getContextPath() %>/perfil"><i class="fas fa-user me-2"></i>Perfil</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="<%= request.getContextPath() %>/logout"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesion</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </nav>
    </div>

    <!-- Sidebar -->
    <div class="nav-left-sidebar">
        <div class="menu-list">
            <nav class="navbar navbar-expand">
                <ul class="navbar-nav flex-column w-100">
                    <li class="nav-divider"><i class="fas fa-bars me-2"></i>Menú</li>
                    <!-- Inicio -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=inicio">
                            <i class="fas fa-home"></i>Inicio
                        </a>
                    </li>
                    <!-- Mis productos -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos">
                            <i class="fas fa-shopping-cart"></i>Mis Productos
                        </a>
                    </li>
                    <!-- Órdenes de Compra -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra">
                            <i class="fas fa-chart-pie"></i>Órdenes de Compra
                        </a>
                    </li>
                    <!-- Registrar lotes -->
                    <li class="nav-item">
                        <a class="nav-link active" href="<%= request.getContextPath() %>/ProductorServlet?action=formRegistrarLote">
                            <i class="fas fa-boxes"></i>Registrar Lotes
                        </a>
                    </li>
                    <!-- Actualizar precios -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=formActualizarPrecios">
                            <i class="fas fa-tags"></i>Actualizar Precios
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>

    <!-- Content -->
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <% if (errorMsg != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert" style="padding: 10px 15px; margin-bottom: 15px; font-size: 0.9rem;">
                <i class="fas fa-exclamation-triangle me-2"></i><%= errorMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <div class="page-header mb-3">
                <h2 class="pageheader-title"><i class="fas fa-envelope me-2"></i>Enviar Reporte de Lotes por Correo</h2>
                <p class="text-muted">Genera y envía un reporte Excel de tus lotes por correo electrónico.</p>
            </div>

            <div class="row">
                <div class="col-xl-10 col-lg-11 col-md-12 mx-auto">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-file-excel me-2"></i>Formulario de Envío</h5>
                        </div>
                        <div class="card-body">
                            <!-- Info Box Compacto -->
                            <div class="alert alert-info">
                                <div class="d-flex align-items-start">
                                    <i class="fas fa-info-circle me-2" style="font-size: 1.2rem; margin-top: 2px;"></i>
                                    <div style="flex: 1;">
                                        <strong>Información del reporte:</strong> Se generará un reporte Excel que incluye:
                                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 8px; margin-top: 10px;">
                                            <div style="display: flex; align-items: center; font-size: 0.85rem;">
                                                <i class="fas fa-check-circle me-2" style="color: #00a896; font-size: 0.75rem;"></i>Código Lote y Producto
                                            </div>
                                            <div style="display: flex; align-items: center; font-size: 0.85rem;">
                                                <i class="fas fa-check-circle me-2" style="color: #00a896; font-size: 0.75rem;"></i>SKU y Stock Actual
                                            </div>
                                            <div style="display: flex; align-items: center; font-size: 0.85rem;">
                                                <i class="fas fa-check-circle me-2" style="color: #00a896; font-size: 0.75rem;"></i>Fecha Vencimiento
                                            </div>
                                            <div style="display: flex; align-items: center; font-size: 0.85rem;">
                                                <i class="fas fa-check-circle me-2" style="color: #00a896; font-size: 0.75rem;"></i>Ubicación y Distrito
                                            </div>
                                            <div style="display: flex; align-items: center; font-size: 0.85rem;">
                                                <i class="fas fa-check-circle me-2" style="color: #00a896; font-size: 0.75rem;"></i>Estado y <strong>Stock Total</strong>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <form action="<%= request.getContextPath() %>/productor/LoteReporteServlet" method="POST">
                                <input type="hidden" name="action" value="enviar">

                                <div class="row">
                                    <div class="col-md-12 mb-3">
                                        <label for="email_destino" class="form-label">
                                            <i class="fas fa-envelope"></i>Email de Destino <span class="text-danger">*</span>
                                        </label>
                                        <input type="email" class="form-control" id="email_destino" name="email_destino" placeholder="ejemplo@correo.com" required>
                                    </div>

                                    <div class="col-md-12 mb-3">
                                        <label for="asunto" class="form-label">
                                            <i class="fas fa-tag"></i>Asunto del Correo
                                        </label>
                                        <input type="text" class="form-control" id="asunto" name="asunto" 
                                               value="Reporte de Lotes - Productor - TELITO BODEGUERO">
                                    </div>

                                    <div class="col-md-12 mb-3">
                                        <label for="mensaje" class="form-label">
                                            <i class="fas fa-comment"></i>Mensaje Adicional (Opcional)
                                        </label>
                                        <textarea class="form-control" id="mensaje" name="mensaje" rows="3" placeholder="Escribe un mensaje adicional para el destinatario..."></textarea>
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between mt-3 pt-3 border-top" style="gap: 10px;">
                                    <a href="<%= request.getContextPath() %>/ProductorServlet?action=formRegistrarLote" class="btn btn-secondary">
                                        <i class="fas fa-arrow-left me-2"></i>Cancelar
                                    </a>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-paper-plane me-2"></i>Enviar Reporte
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ===================== Control del Sidebar en Móvil =====================
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
        sidebarLinks.forEach(link => {
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
</script>
</body>
</html>

