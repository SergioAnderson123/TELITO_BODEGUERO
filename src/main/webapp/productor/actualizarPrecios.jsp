<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.productor.beans.Producto" %>
<%@ page import="java.util.ArrayList" %>
<%--
    JSP: Actualizar Precios (VERSIÓN MEJORADA)
    Propósito: Buscar productos por SKU o nombre y actualizar su precio sugerido.
    Atributos esperados (request):
      - listaProductos (ArrayList<Producto>) lista de productos del productor
      - producto (Producto) producto seleccionado para actualizar; null si aún no se seleccionó
    Navegación: Sidebar con sección "Actualizar Precios" activa.
--%>
<%
    // Objeto "producto" enviado por el servlet tras la búsqueda
    Producto producto = (Producto) request.getAttribute("producto");
    ArrayList<Producto> listaProductos = (ArrayList<Producto>) request.getAttribute("listaProductos");
    String busqueda = request.getParameter("busqueda");
    if (busqueda == null) busqueda = "";
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Actualizar Precios - Telito Bodeguero</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

    <style>
        /* =====================
           Paleta y tokens
        ====================== */
        :root {
            --turquoise-dark: #6F4E37;
            --seafoam: #8B6F47;
            --seafoam-light: #FFFEF9;
            --white: #FFFEF9;
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
           Contenedores principales
        ====================== */
        .dashboard-main-wrapper { display: flex; min-height: 100vh; }
        .dashboard-header {
            background-color: #FFFEF9;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: fixed; top: 0; right: 0; left: 250px; z-index: 999;
            height: 70px;
            border-bottom: 1px solid var(--border-color);
        }
        .dashboard-wrapper { margin-left: 250px; width: calc(100% - 250px); min-height: 100vh; }
        .dashboard-content { margin-top: 70px; padding: 20px; }

        /* =====================
           Sidebar (igual a logística y almacenero)
        ====================== */
        .nav-left-sidebar {
            width: 250px;
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%);
            min-height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 1000;
            box-shadow: 3px 0 15px rgba(0,0,0,.12);
        }
        .navbar-brand { font-weight: 700; color: var(--turquoise-dark); }
        .nav-link {
            color: #F5DEB3 !important;
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
            background: #F5DEB3;
            transform: scaleY(0);
            transition: transform .3s ease;
            border-radius: 0 4px 4px 0;
        }
        .nav-link:hover, .nav-link.active {
            background-color: rgba(245, 222, 179, 0.15);
            color: #FFF8DC !important;
            transform: translateX(8px);
            box-shadow: 0 4px 12px rgba(0,0,0,.15);
        }
        .nav-link:hover::before, .nav-link.active::before {
            transform: scaleY(1);
        }
        .nav-link i { margin-right: 12px; width: 22px; font-size: 1.1rem; }
        .nav-divider {
            color: #F5DEB3;
            font-weight: 700;
            padding: 18px 20px 8px;
            margin-top: 25px;
            font-size: .8rem;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            border-top: 1px solid rgba(245, 222, 179, 0.3);
        }

        /* =====================
           Tarjetas, Formularios y Botones (igual a logística y almacenero)
        ====================== */
        .card {
            background-color: var(--white);
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
            margin-bottom: 40px;
            border: none;
            transition: box-shadow .3s ease;
        }
        .card:hover { box-shadow: 0 8px 24px rgba(0,0,0,.1); }
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%);
            color: white;
            border-radius: 12px 12px 0 0;
            padding: 20px 30px;
            margin: -30px -30px 25px -30px;
            box-shadow: 0 4px 12px rgba(0,168,150,.25);
        }
        .card-header h2, .card-header h5 { margin: 0; color: white; font-weight: 700; }
        .card-body { padding: 0; }
        button, .btn {
            background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%);
            color: var(--white);
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            transition: transform .2s, box-shadow .2s;
        }
        .btn-secondary { background: #8d99ae; border: none; }
        .btn-primary {
            background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%);
            border: none;
            color: #fff;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(0,168,150,.35);
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #00b8a3 0%, #02a190 100%);
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0,168,150,.45);
        }
        .btn-info {
            background: linear-gradient(160deg, #17a2b8 0%, #20c997 100%);
        }
        .btn-success {
            background: linear-gradient(160deg, #28a745 0%, #20c997 100%);
        }
        .btn-warning {
            background: linear-gradient(160deg, #ffc107 0%, #fd7e14 100%);
            color: #000;
        }
        .btn-danger {
            background: linear-gradient(160deg, #dc3545 0%, #e74c3c 100%);
        }
        button:hover, .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 14px rgba(0, 109, 119, 0.25);
        }
        .form-control, .form-select { border-radius: 8px; border: 2px solid var(--border-color); padding: 12px 15px; transition: all 0.3s ease; }
        .form-control:focus, .form-select:focus { border-color: var(--seafoam); box-shadow: 0 0 0 0.2rem rgba(131, 197, 190, 0.35); }
        .form-label { font-weight: 600; color: var(--text-dark); margin-bottom: 8px; }
        .page-header h2 { color: var(--turquoise-dark); font-weight: 700; margin-bottom: 0; font-size: 1.4rem; line-height: 1.2; }
        .page-header p { color: var(--text-muted); font-size: 0.85rem; margin-top: 0.2rem; margin-bottom: 0; }
        .pageheader-title {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #6F4E37 !important;
        }
        .pageheader-title i {
            color: var(--seafoam);
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
            .dashboard-header { left: 0; }
            .dashboard-wrapper { margin-left: 0; width: 100%; }
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
                <a class="navbar-brand d-flex align-items-center" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos">
                    <i class="fas fa-store me-2" style="color: var(--seafoam);"></i>
                    <span>Telito Bodeguero</span>
                </a>

            <ul class="navbar-nav ms-auto">
                <!-- Notificaciones -->
                <li class="nav-item dropdown me-3">
                    <a class="nav-link position-relative" href="javascript:void(0);" role="button" id="notificacionesDropdown" data-bs-toggle="dropdown" aria-expanded="false" style="padding: 8px 12px;" onclick="event.preventDefault();">
                        <i class="fas fa-bell" style="font-size: 1.3rem; color: var(--turquoise-dark);"></i>
                        <span class="badge-notificacion" id="badgeNotificaciones" style="display: none;">0</span>
                    </a>
                    <div class="dropdown-menu dropdown-menu-end notificaciones-dropdown" aria-labelledby="notificacionesDropdown" style="width: 380px;">
                        <div class="dropdown-header d-flex justify-content-between align-items-center" style="background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); color: white; padding: 12px 20px;">
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
                        <a class="dropdown-item text-center fw-bold py-2" href="javascript:void(0);" onclick="event.preventDefault(); mostrarModalTodasNotificaciones();" style="color: #6F4E37 !important;">
                            <i class="fas fa-list me-2"></i>Ver todas las notificaciones
                        </a>
                    </div>
                </li>
                
                <li class="nav-item dropdown">
                    <%
                        com.example.telito.administrador.beans.Usuario usuarioHeaderPrecios = 
                            (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
                        String nombreCompletoPrecios = usuarioHeaderPrecios != null ? 
                            usuarioHeaderPrecios.getNombres() + " " + usuarioHeaderPrecios.getApellidos() : "Usuario";
                        String fotoUrlPrecios = "https://ui-avatars.com/api/?name=User&background=006d77&color=fff&size=200";
                        if (usuarioHeaderPrecios != null) {
                            String foto = usuarioHeaderPrecios.getFotoPerfil();
                            if (foto != null && !foto.trim().isEmpty()) {
                                if (foto.startsWith("http://") || foto.startsWith("https://")) {
                                    fotoUrlPrecios = foto;
                                } else {
                                    fotoUrlPrecios = request.getContextPath() + "/" + foto;
                                }
                            } else {
                                fotoUrlPrecios = usuarioHeaderPrecios.getFotoPerfilUrl();
                            }
                        }
                    %>
                    <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                        <img src="<%= fotoUrlPrecios %>" alt="User" class="rounded-circle me-2" width="32" height="32">
                        <span style="color:#006d77;"><%= nombreCompletoPrecios %></span>
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
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos"><i class="fas fa-shopping-cart"></i>Mis Productos</a>
                    </li>
                    <!-- Órdenes de Compra -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra"><i class="fas fa-chart-pie"></i>Órdenes de Compra</a>
                    </li>
                    <!-- Registrar lotes -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=formRegistrarLote"><i class="fas fa-boxes"></i>Registrar Lotes</a>
                    </li>
                    <!-- Actualizar precios -->
                    <li class="nav-item">
                        <a class="nav-link active" href="<%= request.getContextPath() %>/ProductorServlet?action=formActualizarPrecios"><i class="fas fa-tags"></i>Actualizar Precios</a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>

    <!-- ===================== Contenido principal ===================== -->
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="page-header mb-3">
                <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-tags me-2"></i>Actualizar Precios</h2>
                <p class="text-muted mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Busca y actualiza el precio de tus productos de forma rápida y eficiente.</p>
            </div>

            <!-- Mensajes de éxito/error -->
            <%
                String alertType = (String) request.getAttribute("alertType");
                String alertMessage = (String) request.getAttribute("alertMessage");
                if (alertType != null && alertMessage != null) {
            %>
            <div class="alert alert-<%= alertType %> alert-dismissible fade show" role="alert" style="padding: 10px 15px; margin-bottom: 15px; font-size: 0.9rem;">
                <i class="fas <%= "success".equals(alertType) ? "fa-check-circle" : "fa-exclamation-triangle" %> me-2"></i>
                <%= alertMessage %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <!-- ===================== Card: Búsqueda Mejorada ===================== -->
            <div class="card mb-3" style="padding: 20px;">
                <div class="card-header" style="padding: 15px 20px; margin: -20px -20px 20px -20px;">
                    <h5 class="mb-0"><i class="fas fa-search me-2"></i><strong>Buscar Producto</strong></h5>
                </div>
                <div class="card-body">
                    <form method="GET" action="<%= request.getContextPath() %>/ProductorServlet" class="row g-3 align-items-end">
                        <input type="hidden" name="action" value="formActualizarPrecios">
                        <div class="col-md-10">
                            <label for="busqueda" class="form-label" style="font-weight: 600; font-size: 0.9rem;">
                                <i class="fas fa-barcode me-2" style="color: #6F4E37;"></i>Buscar por SKU o Nombre de Producto
                            </label>
                            <input id="busqueda" type="text" class="form-control" name="busqueda" 
                                   placeholder="Ej: SKU019 o cerveza..." 
                                   value="<%= busqueda %>" 
                                   style="padding: 10px 12px; font-size: 0.95rem;">
                            <small class="text-muted" style="font-size: 0.8rem;">
                                <i class="fas fa-info-circle me-1"></i>
                                Puedes buscar por código SKU o por el nombre del producto
                            </small>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary w-100" style="padding: 10px;">
                                <i class="fas fa-search me-2"></i>Buscar
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- ===================== Tabla de Productos ===================== -->
            <% if (listaProductos != null && !listaProductos.isEmpty()) { %>
            <div class="card" style="padding: 0;">
                <div class="card-header" style="padding: 15px 20px; margin: 0; border-radius: 12px 12px 0 0;">
                    <h5 class="mb-0">
                        <i class="fas fa-list me-2"></i><strong>Productos Encontrados</strong>
                        <span class="badge bg-white text-dark ms-2" style="font-size: 0.85rem;"><%= listaProductos.size() %></span>
                    </h5>
                </div>
                <div class="card-body" style="padding: 15px;">
                    <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                        <table class="table table-hover align-middle mb-0" style="font-size: 0.9rem;">
                            <thead style="background: #f8f9fa; position: sticky; top: 0; z-index: 10;">
                                <tr>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase;">
                                        <i class="fas fa-barcode me-1" style="color: #6F4E37;"></i>SKU
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase;">
                                        <i class="fas fa-box me-1" style="color: #6F4E37;"></i>Producto
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase;">
                                        <i class="fas fa-folder me-1" style="color: #6F4E37;"></i>Categoría
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase; text-align: center;">
                                        <i class="fas fa-dollar-sign me-1" style="color: #6F4E37;"></i>Precio Actual
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase; text-align: center;">
                                        <i class="fas fa-boxes me-1" style="color: #6F4E37;"></i>Lotes
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase; text-align: center;">
                                        <i class="fas fa-cog me-1" style="color: #6F4E37;"></i>Acción
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Producto p : listaProductos) { %>
                                <tr style="transition: all 0.3s ease; cursor: pointer;" 
                                    onmouseover="this.style.backgroundColor='rgba(0,168,150,0.05)'; this.style.transform='scale(1.01)';"
                                    onmouseout="this.style.backgroundColor=''; this.style.transform='scale(1)';">
                                    <td style="padding: 10px;"><strong style="color: #495057;"><%= p.getCodigoSKU() %></strong></td>
                                    <td style="padding: 10px;"><%= p.getNombre() %></td>
                                    <td style="padding: 10px;"><%= p.getCategoria() != null ? p.getCategoria().getNombre() : "N/A" %></td>
                                    <td style="padding: 10px; text-align: center;">
                                        <span style="color: #6F4E37; font-weight: 600; font-size: 1rem;">
                                            S/ <%= String.format("%.2f", p.getPrecioActual()) %>
                                        </span>
                                    </td>
                                    <td style="padding: 10px; text-align: center;">
                                        <span class="badge <%= p.getNumeroLotes() > 0 ? "bg-success" : "bg-secondary" %>" style="font-size: 0.85rem;">
                                            <%= p.getNumeroLotes() %>
                                        </span>
                                    </td>
                                    <td style="padding: 10px; text-align: center;">
                                        <button type="button" class="btn btn-sm btn-primary" 
                                                onclick="seleccionarProducto(<%= p.getIdProducto() %>, '<%= p.getCodigoSKU() %>', '<%= p.getNombre() %>', <%= p.getPrecioActual() %>)"
                                                style="font-size: 0.8rem; padding: 6px 12px;">
                                            <i class="fas fa-edit me-1"></i>Actualizar
                                        </button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <% } else if (busqueda != null && !busqueda.trim().isEmpty()) { %>
            <div class="alert alert-warning" style="display: flex; align-items: center; gap: 10px; padding: 15px;">
                <i class="fas fa-exclamation-triangle" style="font-size: 1.5rem;"></i>
                <div>
                    <strong>No se encontraron productos</strong>
                    <p class="mb-0" style="font-size: 0.9rem;">Intenta con otro SKU o nombre de producto.</p>
                </div>
            </div>
            <% } %>

            <!-- ===================== Modal: Actualizar Precio ===================== -->
            <div class="modal fade" id="modalActualizarPrecio" tabindex="-1" aria-labelledby="modalActualizarPrecioLabel" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content" style="border-radius: 16px; border: none; box-shadow: 0 20px 60px rgba(0,0,0,0.3);">
                        <div class="modal-header text-white" style="background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%); border-radius: 16px 16px 0 0; padding: 20px 25px; border-bottom: none;">
                            <h5 class="modal-title d-flex align-items-center" id="modalActualizarPrecioLabel" style="font-weight: 600; font-size: 1.2rem;">
                                <span class="d-flex align-items-center justify-content-center me-3" style="background: rgba(255,255,255,0.2); padding: 10px; border-radius: 10px; width: 45px; height: 45px;">
                                    <i class="fas fa-tags" style="font-size: 1.2rem;"></i>
                                </span>
                                Actualizar Precio
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="opacity: 1; width: 36px; height: 36px; border-radius: 50%; background: rgba(255,255,255,0.15); display: flex; align-items: center; justify-content: center; border: none; color: white;" onmouseover="this.style.background='rgba(255,255,255,0.25)';" onmouseout="this.style.background='rgba(255,255,255,0.15)';">
                                <i class="fas fa-times" style="color: white; font-size: 18px;"></i>
                            </button>
                        </div>
                        <form method="POST" action="<%= request.getContextPath() %>/ProductorServlet?action=actualizarPrecio" id="formActualizarPrecio">
                            <div class="modal-body" style="padding: 25px; background: #f8f9fa;">
                                <input type="hidden" name="idProducto" id="modalIdProducto">
                                
                                <!-- Info del Producto -->
                                <div class="mb-4" style="background: white; padding: 15px 20px; border-radius: 12px; border-left: 4px solid #6F4E37;">
                                    <div class="row">
                                        <div class="col-6">
                                            <small class="text-muted d-block" style="font-size: 0.75rem; text-transform: uppercase; font-weight: 600;">SKU</small>
                                            <strong id="modalSKU" style="color: #495057; font-size: 1rem;"></strong>
                                        </div>
                                        <div class="col-6">
                                            <small class="text-muted d-block" style="font-size: 0.75rem; text-transform: uppercase; font-weight: 600;">Producto</small>
                                            <strong id="modalNombre" style="color: #6F4E37; font-size: 1rem;"></strong>
                                        </div>
                                    </div>
                                </div>

                                <!-- Precio Actual -->
                                <div class="mb-3" style="background: white; padding: 15px; border-radius: 10px;">
                                    <label class="form-label" style="font-weight: 600; font-size: 0.9rem; color: #495057;">
                                        <i class="fas fa-info-circle me-2" style="color: #17a2b8;"></i>Precio Actual
                                    </label>
                                    <div class="input-group">
                                        <span class="input-group-text" style="background: #e9ecef; border: 2px solid #dee2e6;">S/</span>
                                        <input type="text" class="form-control" id="modalPrecioActual" readonly 
                                               style="background-color: #f8f9fa; border: 2px solid #dee2e6; font-weight: 600; font-size: 1.1rem; color: #495057;">
                                    </div>
                                </div>

                                <!-- Nuevo Precio -->
                                <div class="mb-3" style="background: white; padding: 15px; border-radius: 10px;">
                                    <label for="nuevoPrecio" class="form-label" style="font-weight: 600; font-size: 0.9rem; color: #495057;">
                                        <i class="fas fa-tag me-2" style="color: #6F4E37;"></i>Nuevo Precio <span class="text-danger">*</span>
                                    </label>
                                    <div class="input-group">
                                        <span class="input-group-text" style="background: rgba(0,168,150,0.1); border: 2px solid #6F4E37; color: #6F4E37; font-weight: 600;">S/</span>
                                        <input type="number" class="form-control" id="nuevoPrecio" name="nuevoPrecio" 
                                               step="0.01" min="0.01" required
                                               style="border: 2px solid #6F4E37; font-weight: 600; font-size: 1.1rem;"
                                               placeholder="0.00">
                                    </div>
                                    <small class="text-muted d-block mt-2" style="font-size: 0.8rem;">
                                        <i class="fas fa-lightbulb me-1" style="color: #ffc107;"></i>
                                        Ingresa el nuevo precio sugerido para este producto
                                    </small>
                                </div>
                            </div>
                            <div class="modal-footer" style="background: white; border-top: 2px solid #e9ecef; padding: 20px 25px; border-radius: 0 0 16px 16px;">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="padding: 10px 20px; border-radius: 8px;">
                                    <i class="fas fa-times me-2"></i>Cancelar
                                </button>
                                <button type="submit" class="btn btn-primary" style="padding: 10px 20px; border-radius: 8px;">
                                    <i class="fas fa-check me-2"></i>Actualizar Precio
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Validación simple del input de precio: no permitir negativos y formatear a 2 decimales
    const nuevoPrecioInput = document.getElementById('nuevoPrecio');
    if (nuevoPrecioInput) {
        nuevoPrecioInput.addEventListener('input', function(e) {
            if (parseFloat(e.target.value) < 0) {
                e.target.value = '0.00';
            }
        });
        nuevoPrecioInput.addEventListener('blur', function(e) {
            const v = parseFloat(e.target.value || '0');
            e.target.value = v.toFixed(2);
        });
    }

    // No modal de confirmación: envío directo del formulario

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
        
        // ============ Función: Seleccionar Producto desde la Tabla ============
        function seleccionarProducto(id, sku, nombre, precioActual) {
            document.getElementById('modalIdProducto').value = id;
            document.getElementById('modalSKU').textContent = sku;
            document.getElementById('modalNombre').textContent = nombre;
            document.getElementById('modalPrecioActual').value = precioActual.toFixed(2);
            document.getElementById('nuevoPrecio').value = '';
            
            // Abrir el modal
            var modal = new bootstrap.Modal(document.getElementById('modalActualizarPrecio'));
            modal.show();
        }
    </script>

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
        border-left: 4px solid #6F4E37;
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
        cursor: pointer;
        background: white;
        border-left: 4px solid transparent;
    }
    
    .notificacion-item-grande:hover {
        background: #f8f9fa;
        border-left-color: #6F4E37;
    }
    
    .notificacion-item-grande.no-leida {
        background: #e8f4f8;
        border-left-color: #6F4E37;
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

<script>
// ===================== Sistema de Notificaciones =====================
let ultimaActualizacion = Date.now();
let modalNotificacionesMostrado = false;

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
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=contador', {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            const contador = data.datos.contador || 0;
            const badge = document.getElementById('badgeNotificaciones');
            if (badge) {
                if (contador > 0) {
                    badge.textContent = contador > 99 ? '99+' : contador;
                    badge.style.display = 'block';
                } else {
                    badge.style.display = 'none';
                }
            }
        }
    })
    .catch(error => console.error('Error al cargar contador:', error));
}

// Cargar notificaciones recientes
function cargarNotificacionesRecientes() {
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=recientes', {
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
        } else {
            document.getElementById('listaNotificaciones').innerHTML = 
                '<div class="text-center py-4 text-warning">' +
                    '<i class="fas fa-exclamation-triangle fa-2x mb-2"></i>' +
                    '<p class="mb-0">' + (data.mensaje || 'Error al cargar notificaciones') + '</p>' +
                '</div>';
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
        const ordenCompraId = notif.ordenCompraId || '';
        const tipoNotif = notif.tipo || notif.tipoNotificacion || '';
        
        return '<div class="notificacion-item no-leida" onclick="verNotificacion(' + idNotif + ', \'' + (notif.urlAccion || '') + '\', ' + (ordenCompraId || 'null') + ', \'' + tipoNotif + '\')">' +
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
        'SISTEMA_ACTUALIZADO': 'fas fa-info-circle'
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
function verNotificacion(id, url, ordenCompraId, tipoNotificacion) {
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=marcarLeida&id=' + id, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            cargarContadorNotificaciones();
            // Si es una notificación de orden de compra, redirigir a la página de órdenes
            // Si es una notificación relacionada con órdenes de compra, redirigir a la página de órdenes
            if (tipoNotificacion && (tipoNotificacion.includes('ORDEN_COMPRA') || tipoNotificacion.includes('ORDEN_RECHAZADA') || tipoNotificacion.includes('ORDEN_CONFIRMADA') || tipoNotificacion.includes('ORDEN_LISTA'))) {
                window.location.href = '<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra';
            } else if (url && url.trim() !== '') {
                const contextPath = '<%= request.getContextPath() %>';
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
    
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=marcarTodasLeidas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            cargarContadorNotificaciones();
            cargarNotificacionesRecientes();
        }
    })
    .catch(error => {
        console.error('Error al marcar todas como leídas:', error);
    });
}

// Mostrar modal de notificaciones automáticamente
function mostrarModalNotificaciones(notificaciones) {
    if (notificaciones.length === 0 || modalNotificacionesMostrado) {
        return;
    }
    
    const primeraNotificacion = notificaciones[0];
    const iconoTipo = obtenerIconoTipo(primeraNotificacion.tipo || primeraNotificacion.tipoNotificacion);
    const tiempoRelativo = obtenerTiempoRelativo(primeraNotificacion.fechaCreacion);
    const nivelPrioridad = primeraNotificacion.nivel || primeraNotificacion.nivelPrioridad;
    
    document.getElementById('modalNotificacionIcono').className = 'notificacion-icon-modal ' + nivelPrioridad;
    document.getElementById('modalNotificacionIcono').innerHTML = '<i class="' + iconoTipo + '"></i>';
    document.getElementById('modalNotificacionTitulo').textContent = primeraNotificacion.titulo;
    document.getElementById('modalNotificacionMensaje').textContent = primeraNotificacion.mensaje;
    document.getElementById('modalNotificacionTiempo').innerHTML = '<i class="far fa-clock me-1"></i>' + tiempoRelativo;
    
    document.getElementById('modalNotificacion').setAttribute('data-notificacion-id', primeraNotificacion.id || primeraNotificacion.idNotificacion);
    document.getElementById('modalNotificacion').setAttribute('data-notificacion-url', primeraNotificacion.urlAccion || '');
    document.getElementById('modalNotificacion').setAttribute('data-orden-compra-id', primeraNotificacion.ordenCompraId || '');
    document.getElementById('modalNotificacion').setAttribute('data-tipo-notificacion', primeraNotificacion.tipo || primeraNotificacion.tipoNotificacion || '');
    
    const modal = new bootstrap.Modal(document.getElementById('modalNotificacion'));
    modal.show();
    
    modalNotificacionesMostrado = true;
    
    const notifId = primeraNotificacion.id || primeraNotificacion.idNotificacion;
    if (notifId) {
        fetch('<%= request.getContextPath() %>/NotificacionServlet?action=marcarLeida&id=' + notifId, {
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
    
    // Si es una notificación relacionada con órdenes de compra, redirigir a la página de órdenes
    if (tipoNotificacion && (tipoNotificacion.includes('ORDEN_COMPRA') || tipoNotificacion.includes('ORDEN_RECHAZADA') || tipoNotificacion.includes('ORDEN_CONFIRMADA') || tipoNotificacion.includes('ORDEN_LISTA'))) {
        window.location.href = '<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra';
    } else if (url && url.trim() !== '') {
        const contextPath = '<%= request.getContextPath() %>';
        const finalUrl = url.startsWith('/') ? contextPath + url : url;
        window.location.href = finalUrl;
    }
}

// Cargar y mostrar todas las notificaciones en el modal grande
function mostrarModalTodasNotificaciones() {
    const dropdown = document.getElementById('notificacionesDropdown');
    if (dropdown) {
        const bsDropdown = bootstrap.Dropdown.getInstance(dropdown);
        if (bsDropdown) bsDropdown.hide();
    }
    
    document.getElementById('listaTodasNotificaciones').innerHTML = 
        '<div class="text-center py-5">' +
            '<i class="fas fa-spinner fa-spin fa-2x mb-3 text-muted"></i>' +
            '<p class="text-muted">Cargando notificaciones...</p>' +
        '</div>';
    
    const modal = new bootstrap.Modal(document.getElementById('modalTodasNotificaciones'));
    modal.show();
    
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=todas', {
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
        const ordenCompraId = notif.ordenCompraId || '';
        const tipoNotif = notif.tipo || notif.tipoNotificacion || '';
        
        return '<div class="notificacion-item-grande ' + claseLeida + '" onclick="verNotificacion(' + idNotif + ', \'' + (notif.urlAccion || '') + '\', ' + (ordenCompraId || 'null') + ', \'' + tipoNotif + '\')">' +
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
    
    const contador = notificaciones.filter(n => !(n.leida || false)).length;
    const contadorEl = document.getElementById('contadorModalNotificaciones');
    if (contadorEl) {
        contadorEl.textContent = contador > 0 ? contador + ' no leída' + (contador > 1 ? 's' : '') : 'Todas leídas';
    }
}

// Marcar todas como leídas desde el modal
function marcarTodasLeidasDesdeModal() {
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=marcarTodasLeidas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            cargarContadorNotificaciones();
            mostrarModalTodasNotificaciones();
        }
    })
    .catch(error => {
        console.error('Error al marcar todas como leídas:', error);
    });
}
</script>

<!-- Modal de Notificaciones -->
<div class="modal fade" id="modalNotificacion" tabindex="-1" aria-labelledby="modalNotificacionLabel" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 15px; border: none; box-shadow: 0 10px 40px rgba(0,0,0,0.2);">
            <div class="modal-header" style="background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); color: white; border-radius: 15px 15px 0 0; border: none; padding: 20px;">
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
                <button type="button" class="btn btn-primary" onclick="irANotificacion()" style="background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); border: none; border-radius: 8px; padding: 8px 20px;">
                    <i class="fas fa-arrow-right me-2"></i>Ver Detalles
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Grande para Todas las Notificaciones -->
<div class="modal fade" id="modalTodasNotificaciones" tabindex="-1" aria-labelledby="modalTodasNotificacionesLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content" style="border-radius: 15px; border: none; box-shadow: 0 10px 40px rgba(0,0,0,0.2);">
            <div class="modal-header" style="background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); color: white; border-radius: 15px 15px 0 0; border: none; padding: 20px;">
                <h5 class="modal-title" id="modalTodasNotificacionesLabel" style="font-weight: 600;">
                    <i class="fas fa-bell me-2"></i>Todas las Notificaciones
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding: 0;">
                <div class="d-flex justify-content-between align-items-center p-3 border-bottom" style="background: #f8f9fa;">
                    <button class="btn btn-sm" onclick="marcarTodasLeidasDesdeModal()" style="background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); color: white; border: none; border-radius: 8px; padding: 6px 15px;">
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

</body>
</html>