<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.*" %>
<%--
    JSP: Órdenes de Compra
    Propósito: Mostrar las órdenes de compra del productor con detalles de productos, lotes y destinos.
    Atributos esperados (request):
      - listaOrdenes (ArrayList<OrdenCompra>) - Lista de órdenes de compra
      - totalOrdenes (int) - Total de órdenes
      - ordenesPendientes (int) - Órdenes pendientes
      - ordenesCompletadas (int) - Órdenes completadas
    Navegación: Sidebar con sección "Órdenes de Compra" activa.
--%>

<%
    // Obtener datos del servlet
    List<Object[]> listaOrdenes = (List<Object[]>) request.getAttribute("listaOrdenes");
    if (listaOrdenes == null) {
        listaOrdenes = new ArrayList<>();
    }
    
    // Obtener total de órdenes del servlet (paginación)
    Integer totalOrdenesAttr = (Integer) request.getAttribute("totalRows");
    int totalOrdenes = (totalOrdenesAttr != null) ? totalOrdenesAttr : listaOrdenes.size();
    
    // Calcular estadísticas desde la lista paginada (solo para mostrar en la página actual)
    // Nota: Las estadísticas completas deberían calcularse en el servlet si se necesitan
    int ordenesPendientes = 0;
    int ordenesCompletadas = 0;
    
    for (Object[] orden : listaOrdenes) {
        String estado = (String) orden[6]; // índice 6 = estado
        if ("Pendiente".equals(estado) || "Aprobado".equals(estado)) {
            ordenesPendientes++;
        } else if ("Recibido".equals(estado)) {
            ordenesCompletadas++;
        }
        // Rechazado no se cuenta en ninguna categoría
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Órdenes de Compra - Telito Bodeguero</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <!-- Incluir modales personalizados -->
    <jsp:include page="/WEB-INF/includes/modal-alerts.jsp" />

    <!-- Custom CSS (turquesa/verde agua) -->
    <style>
        /* =====================
           Paleta y tokens
        ====================== */
        :root {
            --turquoise-dark: #006d77;
            --seafoam: #83c5be;
            --seafoam-light: #edf6f9;
            --white: #ffffff;
            --text-dark: #2b2d42;
            --text-muted: #6c757d;
            --border-color: #e9ecef;
        }

        /* =====================
           Layout base
        ====================== */
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            margin: 0;
            background-color: var(--seafoam-light);
            color: var(--text-dark);
        }
        
        /* =====================
           Contenedores
        ====================== */
        .dashboard-main-wrapper { display: flex; min-height: 100vh; }
        .dashboard-header {
            background-color: #fff;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: fixed; top: 0; right: 0; left: 250px; z-index: 999;
            height: 70px; border-bottom: 1px solid var(--border-color);
        }
        .dashboard-wrapper { margin-left: 250px; width: calc(100% - 250px); min-height: 100vh; }
        .dashboard-content { margin-top: 70px; padding: 20px; }
        .page-header { margin-bottom: 0.5rem; padding-top: 0.5rem; padding-bottom: 0.5rem; }
        .page-header h2 { color: var(--turquoise-dark); font-weight: 700; margin-bottom: 0; font-size: 1.4rem; line-height: 1.2; }
        .page-header p { color: var(--text-muted); font-size: 0.85rem; margin-top: 0.2rem; margin-bottom: 0; }

        /* =====================
           Sidebar
        ====================== */
        .nav-left-sidebar {
            width: 250px;
            background: linear-gradient(160deg, var(--turquoise-dark) 0%, #055e68 100%);
            min-height: 100vh; position: fixed; left: 0; top: 0; z-index: 1000;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }
        .navbar-brand { font-weight: 700; color: var(--turquoise-dark); }
        .nav-link { color: rgba(255,255,255,0.9) !important; padding: 12px 20px; border-radius: 8px; margin: 5px 15px; transition: all 0.3s ease; display: flex; align-items: center; }
        .nav-link:hover, .nav-link.active { background-color: rgba(255,255,255,0.18); color: #fff !important; transform: translateX(5px); }
        .nav-link i { margin-right: 10px; width: 20px; }
        .nav-divider { color: rgba(255,255,255,0.8); font-weight: 600; padding: 15px 20px 5px; margin-top: 20px; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; }

        /* =====================
           Tarjetas/Tabla/Formularios
        ====================== */
        .stats-container { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 15px; }
        .stat-card {
            background-color: var(--white);
            padding: 12px 15px;
            border-radius: 8px;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
        }
        .stat-card h3 { margin: 0 0 5px 0; font-size: 0.8rem; color: var(--text-muted); font-weight: 600; }
        .stat-card p { margin: 0; font-size: 1.5rem; font-weight: 700; color: var(--turquoise-dark); }

        /* Card principal */
        .card {
            background-color: var(--white);
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
            margin-bottom: 40px;
            border: none;
        }
        .card-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            margin-bottom: 25px; 
            background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
            color: white;
            border-radius: 12px 12px 0 0;
            padding: 20px 30px;
            margin: -30px -30px 25px -30px;
        }
        .card-header h2, .card-header h5 { margin: 0; color: white; }
        .card-body { padding: 0; }

        /* Formularios y Botones */
        form label { display: block; margin-bottom: 8px; font-weight: 600; color: var(--text-dark); }
        form input, form select, form textarea {
            width: 100%; padding: 12px; border: 1.5px solid var(--border-color); border-radius: 8px; box-sizing: border-box; font-size: 1rem;
        }
        button {
            background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
            color: var(--white);
            border: none; padding: 12px 24px; border-radius: 8px; cursor: pointer; font-size: 1rem; font-weight: 600; transition: transform 0.2s, box-shadow 0.2s;
        }
        button.btn-secondary { background: #8d99ae; }
        button:hover { transform: translateY(-2px); box-shadow: 0 6px 14px rgba(0, 109, 119, 0.25); }

        /* Table card - igual a gestión de usuarios y mis productos */
        .table-card {
            background: var(--white);
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,.06);
            border: none;
        }
        .table-card .card-header {
            background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
            color: #fff;
            border-radius: 12px 12px 0 0;
            padding: 0.5rem 0.75rem;
            margin: 0;
        }
        .table-card .card-body {
            padding: 0.75rem;
        }
        
        /* Tabla - Estilo igual a gestión de usuarios y mis productos */
        table { 
            width: 100%; 
            border-collapse: collapse; 
            font-size: 0.9rem; 
            margin-bottom: 0 !important; 
            table-layout: auto;
        }
        th, td { 
            padding: 0.4rem 0.5rem; 
            text-align: left; 
            border-bottom: 1px solid var(--border-color); 
            font-size: 0.85rem;
        }
        tbody td {
            padding: 0.35rem 0.5rem;
        }
        thead th { 
            background-color: #f8f9fa; 
            font-weight: 600; 
            color: var(--text-muted); 
            text-transform: uppercase; 
            font-size: 0.85rem; 
            vertical-align: middle;
        }
        tbody tr:hover { background-color: #f8f9fa; }
        tbody tr { vertical-align: middle; }

        /* Botón Ver Lotes/Editar - Estilo teal/verde agua igual a mis productos */
        .btn-ver-lotes {
            background: linear-gradient(135deg, #20c997 0%, #17a2b8 100%) !important;
            border: none !important;
            color: white !important;
            font-size: 0.8rem !important;
            padding: 0.35rem 0.6rem !important;
            font-weight: 500 !important;
            transition: all 0.2s ease !important;
            border-radius: 6px !important;
        }
        .btn-ver-lotes:hover {
            transform: translateY(-1px) !important;
            box-shadow: 0 4px 8px rgba(32, 201, 151, 0.3) !important;
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%) !important;
        }
        .btn-ver-lotes:focus {
            box-shadow: 0 0 0 0.2rem rgba(32, 201, 151, 0.25) !important;
        }

        /* Badges de estado */
        .badge-pendiente {
            background: linear-gradient(160deg, #ffc107 0%, #fd7e14 100%);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .badge-completada {
            background: linear-gradient(160deg, #28a745 0%, #20c997 100%);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        /* Paginación */
        .pagination .page-link {
            color: var(--turquoise-dark);
            border-color: var(--border-color);
            padding: 10px 15px;
            border-radius: 8px;
            margin: 0 2px;
        }
        .pagination .page-link:hover {
            background-color: var(--seafoam-light);
            border-color: var(--seafoam);
        }
        .pagination .page-item.active .page-link {
            background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
            border-color: var(--turquoise-dark);
            color: white;
        }

        /* =====================
           Botón Hamburguesa
        ====================== */
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
        
        /* Overlay para móvil */
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

        /* Estilos para el header en móvil */
        .navbar-nav .nav-link span {
            white-space: nowrap;
        }
        
        /* =====================
           Responsive
        ====================== */
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
            .dashboard-header .navbar {
                padding: 0;
            }
            .dashboard-header .container-fluid {
                padding: 0 10px;
            }
            .navbar-brand span {
                font-size: 0.9rem;
            }
            /* Ocultar nombre del usuario en móvil, solo mostrar avatar */
            .navbar-nav .nav-link span {
                display: none;
            }
            .navbar-nav .nav-link {
                padding: 8px 12px;
            }
            .dashboard-wrapper { margin-left: 0; width: 100%; }
            .dashboard-content { padding: 20px; }
            .stats-container { grid-template-columns: 1fr; }
            
            /* Asegurar que los botones sean clickeables en móvil */
            .btn,
            button,
            a[href] {
                touch-action: manipulation;
                -webkit-tap-highlight-color: rgba(0, 0, 0, 0.1);
                cursor: pointer;
            }
        }
        
        @media (max-width: 576px) {
            .navbar-brand span {
                display: none;
            }
            .navbar-brand i {
                margin-right: 0;
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
                            com.example.telito.administrador.beans.Usuario usuarioHeaderOrdenes = 
                                (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
                            String nombreCompletoOrdenes = usuarioHeaderOrdenes != null ? 
                                usuarioHeaderOrdenes.getNombres() + " " + usuarioHeaderOrdenes.getApellidos() : "Usuario";
                            String fotoUrlOrdenes = "https://ui-avatars.com/api/?name=User&background=006d77&color=fff&size=200";
                            if (usuarioHeaderOrdenes != null) {
                                String foto = usuarioHeaderOrdenes.getFotoPerfil();
                                if (foto != null && !foto.trim().isEmpty()) {
                                    if (foto.startsWith("http://") || foto.startsWith("https://")) {
                                        fotoUrlOrdenes = foto;
                                    } else {
                                        fotoUrlOrdenes = request.getContextPath() + "/" + foto;
                                    }
                                } else {
                                    fotoUrlOrdenes = usuarioHeaderOrdenes.getFotoPerfilUrl();
                                }
                            }
                        %>
                        <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                            <img src="<%= fotoUrlOrdenes %>" alt="User" class="rounded-circle me-2" width="32" height="32">
                            <span style="color:#006d77;"><%= nombreCompletoOrdenes %></span>
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

    <!-- ===================== Sidebar / Navegación ===================== -->
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
                        <a class="nav-link active" href="<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra">
                            <i class="fas fa-chart-pie"></i>Órdenes de Compra
                        </a>
                    </li>
                    <!-- Registrar lotes -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=formRegistrarLote">
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

    <!-- ===================== Contenido principal ===================== -->
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <div>
                        <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-chart-pie me-2"></i>Órdenes de Compra</h2>
                        <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Gestiona y monitorea las órdenes de compra de tus productos.</p>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <a href="<%= request.getContextPath() %>/productor/OrdenCompraReporteServlet?action=exportar" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                        </a>
                        <a href="<%= request.getContextPath() %>/productor/OrdenCompraReporteServlet?action=formEnviar" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-envelope me-1"></i>Enviar por Correo
                        </a>
                    </div>
                </div>
            </div>

            <!-- ===================== Tarjetas de estadísticas ===================== -->
            <div class="stats-container">
                <div class="stat-card">
                    <h3>Total de Órdenes</h3>
                    <p><%= totalOrdenes %></p>
                </div>
                <div class="stat-card">
                    <h3>Órdenes Pendientes</h3>
                    <p><%= ordenesPendientes %></p>
                </div>
                <div class="stat-card">
                    <h3>Órdenes Completadas</h3>
                    <p><%= ordenesCompletadas %></p>
                </div>
            </div>

            <!-- ===================== Card: Búsqueda y filtros ===================== -->
            <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                    <div class="col-md-4">
                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                        <div class="input-group">
                            <input id="searchInput" type="text" class="form-control form-control-sm shadow-sm" placeholder="Código de orden o producto..." style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-filter me-1"></i>Estado</label>
                        <select id="statusFilter" class="form-select form-select-sm shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            <option value="">Todos los estados</option>
                            <option value="Pendiente">Pendiente</option>
                            <option value="Aprobado">Aprobado</option>
                            <option value="Rechazado">Rechazado</option>
                            <option value="Recibido">Recibido</option>
                            <option value="En Proceso">En Proceso</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <a href="<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            <i class="fas fa-sync-alt me-1"></i>Limpiar
                        </a>
                    </div>
                </div>
            </div>

            <!-- ===================== Card: Tabla de órdenes ===================== -->
            <div class="row">
                <div class="col-12">
                    <div class="table-card shadow-sm">
                        <div class="card-header" style="padding: 0.5rem 0.75rem;">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-chart-pie me-2"></i>Órdenes de Compra</h5>
                                    <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todas tus órdenes de compra</small>
                                </div>
                            </div>
                        </div>
                        <div class="card-body" style="padding: 0.75rem;">
                            <table id="ordenesTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                    <thead class="table-light">
                        <tr>
                            <th class="fw-semibold" style="width: 5%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">#</th>
                            <th class="fw-semibold" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">CÓDIGO DE ORDEN</th>
                            <th class="fw-semibold" style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">NOMBRE DEL PRODUCTO</th>
                            <th class="fw-semibold" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">CANTIDAD DE PAQUETES</th>
                            <th class="fw-semibold" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">PRECIO</th>
                            <th class="fw-semibold" style="width: 18%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">SOLICITANTE DE COMPRA</th>
                            <th class="fw-semibold" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">ESTADO</th>
                            <th class="text-end fw-semibold" style="width: 9%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">ACCIONES</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                            Integer sizeObj = (Integer) request.getAttribute("size");
                            int currentPage = (currentPageObj != null) ? currentPageObj : 1;
                            int size = (sizeObj != null) ? sizeObj : 5;
                            int i = (currentPage - 1) * size + 1;
                        %>
                        <% for (Object orden : listaOrdenes) { %>
                            <% Object[] ordenData = (Object[]) orden; %>
                            <tr class="align-middle" data-codigo="<%= ordenData[1] %>" 
                                data-producto="<%= ordenData[2] %>" 
                                data-estado="<%= ordenData[6] %>" 
                                data-destino="<%= ordenData[5] %>"
                                style="padding: 0;">
                                <td class="text-muted" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= i++ %></td>
                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong><%= ordenData[1] %></strong></td>
                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= ordenData[2] %></td>
                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= ordenData[3] %> paquetes</td>
                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong>S/ <%= String.format("%.2f", (Double) ordenData[4]) %></strong></td>
                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= ordenData[5] %></td>
                                <td>
                                    <% 
                                        String estadoOrden = (String) ordenData[6];
                                        if ("Pendiente".equals(estadoOrden)) { 
                                    %>
                                        <span class="badge-pendiente">
                                            <i class="fas fa-clock me-1"></i>Pendiente
                                        </span>
                                    <% } else if ("Aprobado".equals(estadoOrden)) { %>
                                        <span class="badge" style="background: linear-gradient(160deg, #007bff 0%, #0056b3 100%); color: white; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;">
                                            <i class="fas fa-thumbs-up me-1"></i>Aprobado
                                        </span>
                                    <% } else if ("Recibido".equals(estadoOrden)) { %>
                                        <span class="badge-completada" style="cursor: pointer;" onclick="cambiarEstado(<%= ordenData[0] %>, 'En Proceso', this)" title="Click para cambiar a 'En Proceso'">
                                            <i class="fas fa-check me-1"></i>Recibido
                                        </span>
                                    <% } else if ("En Proceso".equals(estadoOrden)) { %>
                                        <span class="badge" style="background: linear-gradient(160deg, #ffc107 0%, #ff9800 100%); color: white; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;">
                                            <i class="fas fa-spinner me-1"></i>En Proceso
                                        </span>
                                    <% } else if ("Rechazado".equals(estadoOrden)) { %>
                                        <span class="badge" style="background: linear-gradient(160deg, #dc3545 0%, #c82333 100%); color: white; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;">
                                            <i class="fas fa-times me-1"></i>Rechazado
                                        </span>
                                    <% } else { %>
                                        <span class="badge-completada">
                                            <i class="fas fa-check me-1"></i><%= estadoOrden %>
                                        </span>
                                    <% } %>
                                </td>
                                <td class="text-end" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <% if ("En Proceso".equals(estadoOrden)) { %>
                                        <button type="button" class="btn btn-sm shadow-sm btn-ver-lotes" 
                                                onclick="editarOrden('<%= ordenData[0] %>')"
                                                title="Editar orden">
                                            <i class="fas fa-edit"></i> Editar
                                        </button>
                                    <% } %>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
                
                <%-- Incluir componente de paginación --%>
                <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Asignar Lote a Orden -->
<div class="modal fade" id="asignarLoteModal" tabindex="-1" aria-labelledby="asignarLoteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white;">
                <h5 class="modal-title" id="asignarLoteModalLabel">
                    <i class="fas fa-boxes me-2"></i>Asignar Lote a Orden
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div id="loadingLotes" class="text-center py-5">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Cargando...</span>
                    </div>
                    <p class="mt-3 text-muted">Cargando lotes disponibles...</p>
                </div>
                <div id="tableLotesContainer" style="display: none;">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i>
                        <strong>Orden:</strong> <span id="modalOrdenNumero"></span> | 
                        <strong>Producto:</strong> <span id="modalProductoNombre"></span>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover table-bordered">
                            <thead class="table-light">
                                <tr>
                                    <th style="width: 50px;">Seleccionar</th>
                                    <th>Código Lote</th>
                                    <th>SKU</th>
                                    <th>Producto</th>
                                    <th>Paquetes</th>
                                    <th>Fecha de Vencimiento</th>
                                </tr>
                            </thead>
                            <tbody id="tableLotesBody">
                                <!-- Los lotes se cargarán dinámicamente aquí -->
                            </tbody>
                        </table>
                    </div>
                    <div id="noLotesMessage" class="alert alert-warning" style="display: none;">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        No hay lotes disponibles para este producto.
                    </div>
                </div>
            </div>
            <div class="modal-footer" style="border-top: 2px solid #e9ecef;">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="fas fa-arrow-left me-2"></i>Volver
                </button>
                <button type="button" class="btn btn-primary" id="btnEnviarLote" onclick="asignarLoteAOrden()">
                    <i class="fas fa-paper-plane me-2"></i>Enviar
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Funcionalidad de búsqueda y filtros
    const searchInput = document.getElementById('searchInput');
    const statusFilter = document.getElementById('statusFilter');
    const table = document.getElementById('ordenesTable');
    const tbody = table.querySelector('tbody');

    function normalize(text) {
        return (text || '').toString().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }

    function applyFilters() {
        const searchTerm = normalize(searchInput.value);
        const status = statusFilter.value;

        const rows = Array.from(tbody.querySelectorAll('tr'));

        rows.forEach(row => {
            const codigo = normalize(row.dataset.codigo);
            const producto = normalize(row.dataset.producto);
            const rowStatus = row.dataset.estado;

            const matchesSearch = !searchTerm || 
                codigo.includes(searchTerm) || 
                producto.includes(searchTerm);
            const matchesStatus = !status || rowStatus === status;

            row.style.display = (matchesSearch && matchesStatus) ? '' : 'none';
        });
    }

    function limpiarFiltros() {
        searchInput.value = '';
        statusFilter.value = '';
        applyFilters();
        // Redirigir para limpiar filtros del servidor también
        window.location.href = '<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra';
    }

    // Event listeners
    searchInput.addEventListener('input', applyFilters);
    statusFilter.addEventListener('change', applyFilters);

    // Variables globales para el modal
    let ordenActualId = null;
    let ordenActualNumero = null;
    let productoActualNombre = null;
    let productoActualId = null;
    let loteSeleccionadoId = null;

    // Función para editar orden (asignar lote)
    function editarOrden(idOrden) {
        // Buscar los datos de la orden en la tabla
        const rows = Array.from(tbody.querySelectorAll('tr'));
        let ordenData = null;
        
        for (let row of rows) {
            const cells = row.querySelectorAll('td');
            if (cells.length > 0) {
                // Buscar por el ID de la orden (necesitamos agregarlo como data-attribute)
                // Por ahora usamos el índice de la fila
                ordenData = {
                    numero: cells[1].textContent.trim(),
                    producto: cells[2].textContent.trim()
                };
                break;
            }
        }
        
        // Guardar datos globales
        ordenActualId = idOrden;
        ordenActualNumero = ordenData ? ordenData.numero : idOrden;
        productoActualNombre = ordenData ? ordenData.producto : 'Producto';
        loteSeleccionadoId = null;
        
        // Actualizar información en el modal
        document.getElementById('modalOrdenNumero').textContent = ordenActualNumero;
        document.getElementById('modalProductoNombre').textContent = productoActualNombre;
        
        // Mostrar loading
        document.getElementById('loadingLotes').style.display = 'block';
        document.getElementById('tableLotesContainer').style.display = 'none';
        
        // Abrir el modal
        const modal = new bootstrap.Modal(document.getElementById('asignarLoteModal'));
        modal.show();
        
        // Cargar los lotes disponibles
        cargarLotesDisponibles(idOrden);
    }
    
    // Función para cargar lotes disponibles
    function cargarLotesDisponibles(idOrden) {
        console.log('=== CARGANDO LOTES ===');
        console.log('ID Orden:', idOrden);
        
        const url = '<%= request.getContextPath() %>/ProductorServlet?action=obtenerLotesParaOrden&idOrden=' + idOrden;
        console.log('URL:', url);
        
        fetch(url)
            .then(response => {
                console.log('Response status:', response.status);
                console.log('Response headers:', response.headers);
                return response.text();
            })
            .then(text => {
                console.log('Response text:', text);
                const data = JSON.parse(text);
                console.log('Data parsed:', data);
                console.log('data.success:', data.success);
                console.log('data.lotes:', data.lotes);
                console.log('data.lotes.length:', data.lotes ? data.lotes.length : 'undefined');
                
                document.getElementById('loadingLotes').style.display = 'none';
                document.getElementById('tableLotesContainer').style.display = 'block';
                
                if (data.success && data.lotes && data.lotes.length > 0) {
                    console.log('✓ Mostrando lotes en tabla...');
                    productoActualId = data.productoId;
                    mostrarLotesEnTabla(data.lotes);
                    document.getElementById('noLotesMessage').style.display = 'none';
                } else {
                    console.log('❌ No hay lotes disponibles o error');
                    document.getElementById('tableLotesBody').innerHTML = '';
                    document.getElementById('noLotesMessage').style.display = 'block';
                }
            })
            .catch(error => {
                console.error('❌ ERROR al cargar lotes:', error);
                document.getElementById('loadingLotes').style.display = 'none';
                showError('Error al cargar los lotes disponibles. Por favor, intenta de nuevo.');
            });
    }
    
    // Función para mostrar lotes en la tabla
    function mostrarLotesEnTabla(lotes) {
        const tbody = document.getElementById('tableLotesBody');
        tbody.innerHTML = '';
        
        console.log('=== MOSTRAR LOTES EN TABLA ===');
        console.log('Total lotes:', lotes.length);
        
        lotes.forEach((lote, index) => {
            console.log('Lote ' + index + ':', lote);
            console.log('  ID:', lote.id);
            console.log('  codigoLote:', lote.codigoLote);
            console.log('  sku:', lote.sku);
            console.log('  producto:', lote.producto);
            console.log('  paquetes:', lote.paquetes);
            console.log('  fechaVencimiento:', lote.fechaVencimiento);
            
            const row = document.createElement('tr');
            row.style.cursor = 'pointer';
            row.onclick = function() {
                seleccionarLote(lote.id, row);
            };
            
            const codigoLoteVal = lote.codigoLote || 'N/A';
            const skuVal = lote.sku || 'N/A';
            const productoVal = lote.producto || 'N/A';
            const paquetesVal = lote.paquetes || 0;
            const fechaVal = lote.fechaVencimiento || '<span class="text-muted">Sin fecha</span>';
            
            console.log('Valores antes de generar HTML:');
            console.log('  codigoLoteVal:', codigoLoteVal);
            console.log('  skuVal:', skuVal);
            console.log('  productoVal:', productoVal);
            console.log('  paquetesVal:', paquetesVal);
            console.log('  fechaVal:', fechaVal);
            
            // Usar concatenación en lugar de template literals
            row.innerHTML = 
                '<td class="text-center">' +
                    '<input type="radio" name="loteSeleccionado" value="' + lote.id + '" class="form-check-input" style="width: 20px; height: 20px;">' +
                '</td>' +
                '<td><strong>' + codigoLoteVal + '</strong></td>' +
                '<td><span class="badge bg-secondary">' + skuVal + '</span></td>' +
                '<td>' + productoVal + '</td>' +
                '<td><span class="badge bg-primary">' + paquetesVal + ' paquetes</span></td>' +
                '<td>' + fechaVal + '</td>';
            
            console.log('HTML generado:', row.innerHTML);
            
            tbody.appendChild(row);
        });
        
        console.log('✓ Tabla renderizada');
    }
    
    // Función para seleccionar un lote
    function seleccionarLote(idLote, row) {
        // Desmarcar todas las filas
        const rows = document.querySelectorAll('#tableLotesBody tr');
        rows.forEach(r => r.classList.remove('table-active'));
        
        // Marcar la fila seleccionada
        row.classList.add('table-active');
        
        // Seleccionar el radio button
        const radio = row.querySelector('input[type="radio"]');
        radio.checked = true;
        
        // Guardar el ID del lote seleccionado
        loteSeleccionadoId = idLote;
    }
    
    // Función para asignar el lote a la orden
    function asignarLoteAOrden() {
        if (!loteSeleccionadoId) {
            showAlert('Por favor, selecciona un lote antes de enviar.', 'Selecciona un lote', 'warning');
            return;
        }
        
        // Deshabilitar el botón
        const btnEnviar = document.getElementById('btnEnviarLote');
        btnEnviar.disabled = true;
        btnEnviar.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Procesando...';
        
        // Enviar la asignación al servidor
        fetch('<%= request.getContextPath() %>/ProductorServlet?action=asignarLoteAOrden', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'idOrden=' + ordenActualId + '&idLote=' + loteSeleccionadoId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showSuccess('Lote asignado correctamente a la orden');
                // Cerrar el modal
                bootstrap.Modal.getInstance(document.getElementById('asignarLoteModal')).hide();
                // Recargar la página después de 1 segundo
                setTimeout(() => location.reload(), 1500);
            } else {
                showError('Error: ' + (data.message || 'No se pudo asignar el lote'));
                btnEnviar.disabled = false;
                btnEnviar.innerHTML = '<i class="fas fa-paper-plane me-2"></i>Enviar';
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showError('Error de conexión al asignar el lote. Por favor, intenta de nuevo.');
            btnEnviar.disabled = false;
            btnEnviar.innerHTML = '<i class="fas fa-paper-plane me-2"></i>Enviar';
        });
    }

    // Función para cambiar estado de una orden
    function cambiarEstado(idOrden, nuevoEstado, elemento) {
        // Usar modal personalizado en lugar de confirm
        showConfirm(
            '¿Deseas cambiar el estado de esta orden a "' + nuevoEstado + '"?',
            function() {
                // Mostrar indicador de carga
                elemento.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Procesando...';
                elemento.style.pointerEvents = 'none';

                // Hacer petición AJAX
                fetch('<%= request.getContextPath() %>/ProductorServlet?action=cambiarEstadoOrden', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'idOrden=' + idOrden + '&nuevoEstado=' + encodeURIComponent(nuevoEstado)
                })
                .then(response => {
                    // Verificar si la respuesta es OK
                    if (!response.ok) {
                        throw new Error('Error HTTP: ' + response.status);
                    }
                    // Intentar parsear como JSON
                    return response.json().catch(() => {
                        // Si no es JSON válido, devolver un objeto de error
                        throw new Error('La respuesta del servidor no es válida');
                    });
                })
                .then(data => {
                    if (data.success) {
                        // Obtener la fila de la tabla
                        const row = elemento.closest('tr');
                        
                        // Actualizar el badge con el nuevo estado
                        const estadoCell = row.cells[6]; // Columna de estado
                        estadoCell.innerHTML = '<span class="badge" style="background: linear-gradient(160deg, #ffc107 0%, #ff9800 100%); color: white; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;"><i class="fas fa-spinner me-1"></i>En Proceso</span>';
                        
                        // IMPORTANTE: Mostrar el botón de editar en la columna de acciones
                        const accionesCell = row.cells[7]; // Columna de acciones
                        accionesCell.innerHTML = '<a href="#" class="btn-view" onclick="editarOrden(\'' + idOrden + '\'); return false;"><i class="fas fa-edit"></i> Editar</a>';
                        
                        // Mostrar mensaje de éxito
                        showSuccess('Estado cambiado a "' + nuevoEstado + '" correctamente');
                    } else {
                        showError('Error al cambiar el estado: ' + (data.message || 'Error desconocido'));
                        // Restaurar el badge original
                        elemento.innerHTML = '<i class="fas fa-check me-1"></i>Recibido';
                        elemento.style.pointerEvents = 'auto';
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showError('Error de conexión al cambiar el estado. Por favor, intenta de nuevo.');
                    // Restaurar el badge original
                    elemento.innerHTML = '<i class="fas fa-check me-1"></i>Recibido';
                    elemento.style.pointerEvents = 'auto';
                });
            },
            'Cambiar estado de orden'
        );
    }

    // Inicializar filtros
    applyFilters();

    // Recargar página si se vuelve desde el perfil
    if (sessionStorage.getItem('recargarDesdePerfil') === 'true') {
        sessionStorage.removeItem('recargarDesdePerfil');
        location.reload();
    }

    // ===================== Control del Sidebar en Móvil =====================
    const sidebarToggle = document.getElementById('sidebarToggle');
    const sidebar = document.querySelector('.nav-left-sidebar');
    const sidebarOverlay = document.getElementById('sidebarOverlay');

    function toggleSidebar() {
        if (sidebar && sidebarOverlay) {
            sidebar.classList.toggle('open');
            sidebarOverlay.classList.toggle('active');
            // Prevenir scroll del body cuando el sidebar está abierto
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

    // Event listeners
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function(e) {
            e.stopPropagation();
            toggleSidebar();
        });
    }

    if (sidebarOverlay) {
        sidebarOverlay.addEventListener('click', closeSidebar);
    }

    // Cerrar sidebar cuando se hace clic en un enlace (solo en móvil)
    if (window.innerWidth <= 992) {
        const sidebarLinks = document.querySelectorAll('.nav-left-sidebar .nav-link');
        sidebarLinks.forEach(link => {
            link.addEventListener('click', function() {
                setTimeout(closeSidebar, 100); // Pequeño delay para permitir la navegación
            });
        });
    }

    // Cerrar sidebar al redimensionar la ventana si pasa a desktop
    window.addEventListener('resize', function() {
        if (window.innerWidth > 992) {
            closeSidebar();
        }
    });
</script>

</body>
</html>
