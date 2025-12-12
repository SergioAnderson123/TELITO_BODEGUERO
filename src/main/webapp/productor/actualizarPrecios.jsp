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
           Contenedores principales
        ====================== */
        .dashboard-main-wrapper { display: flex; min-height: 100vh; }
        .dashboard-header {
            background-color: #fff;
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
            background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%);
            min-height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 1000;
            box-shadow: 3px 0 15px rgba(0,0,0,.12);
        }
        .navbar-brand { font-weight: 700; color: var(--turquoise-dark); }
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
            background: linear-gradient(135deg, #00a896 0%, #83c5be 100%);
            color: white;
            border-radius: 12px 12px 0 0;
            padding: 20px 30px;
            margin: -30px -30px 25px -30px;
            box-shadow: 0 4px 12px rgba(0,168,150,.25);
        }
        .card-header h2, .card-header h5 { margin: 0; color: white; font-weight: 700; }
        .card-body { padding: 0; }
        button, .btn {
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%);
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
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%);
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
        .page-header h2 { color: var(--turquoise-dark); font-weight: 700; }
        .page-header p { color: var(--text-muted); font-size: 1.05rem; }
        .pageheader-title {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #00a896 !important;
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
                <h2 class="pageheader-title mb-1"><i class="fas fa-tags me-2"></i>Actualizar Precios</h2>
                <p class="text-muted" style="font-size: 0.85rem;">Busca y actualiza el precio de tus productos de forma rápida y eficiente.</p>
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
                                <i class="fas fa-barcode me-2" style="color: #00a896;"></i>Buscar por SKU o Nombre de Producto
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
                                        <i class="fas fa-barcode me-1" style="color: #00a896;"></i>SKU
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase;">
                                        <i class="fas fa-box me-1" style="color: #00a896;"></i>Producto
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase;">
                                        <i class="fas fa-folder me-1" style="color: #00a896;"></i>Categoría
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase; text-align: center;">
                                        <i class="fas fa-dollar-sign me-1" style="color: #00a896;"></i>Precio Actual
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase; text-align: center;">
                                        <i class="fas fa-boxes me-1" style="color: #00a896;"></i>Lotes
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase; text-align: center;">
                                        <i class="fas fa-cog me-1" style="color: #00a896;"></i>Acción
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
                                        <span style="color: #00a896; font-weight: 600; font-size: 1rem;">
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
                        <div class="modal-header text-white" style="background: linear-gradient(135deg, #00a896 0%, #028f80 100%); border-radius: 16px 16px 0 0; padding: 20px 25px; border-bottom: none;">
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
                                <div class="mb-4" style="background: white; padding: 15px 20px; border-radius: 12px; border-left: 4px solid #00a896;">
                                    <div class="row">
                                        <div class="col-6">
                                            <small class="text-muted d-block" style="font-size: 0.75rem; text-transform: uppercase; font-weight: 600;">SKU</small>
                                            <strong id="modalSKU" style="color: #495057; font-size: 1rem;"></strong>
                                        </div>
                                        <div class="col-6">
                                            <small class="text-muted d-block" style="font-size: 0.75rem; text-transform: uppercase; font-weight: 600;">Producto</small>
                                            <strong id="modalNombre" style="color: #00a896; font-size: 1rem;"></strong>
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
                                        <i class="fas fa-tag me-2" style="color: #00a896;"></i>Nuevo Precio <span class="text-danger">*</span>
                                    </label>
                                    <div class="input-group">
                                        <span class="input-group-text" style="background: rgba(0,168,150,0.1); border: 2px solid #00a896; color: #00a896; font-weight: 600;">S/</span>
                                        <input type="number" class="form-control" id="nuevoPrecio" name="nuevoPrecio" 
                                               step="0.01" min="0.01" required
                                               style="border: 2px solid #00a896; font-weight: 600; font-size: 1.1rem;"
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
</body>
</html>