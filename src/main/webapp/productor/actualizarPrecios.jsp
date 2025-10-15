<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.bodega.beans.Producto" %>
<%--
    JSP: Actualizar Precios
    Propósito: Buscar un producto por SKU y actualizar su precio sugerido.
    Atributos esperados (request):
      - producto (Producto) después de buscar por SKU; null si no se encontró o aún no se buscó
    Navegación: Sidebar con sección "Actualizar Precios" activa.
--%>
<%
    // Objeto "producto" enviado por el servlet tras la búsqueda por SKU
    Producto producto = (Producto) request.getAttribute("producto");
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
        .dashboard-content { margin-top: 70px; padding: 30px; }

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
           Tarjetas, Formularios y Botones
        ====================== */
        .card { border: none; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.08); }
        .card-header { background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); color: white; border-radius: 15px 15px 0 0 !important; border: none; font-weight: 600; }
        .btn-primary { background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); border: none; border-radius: 8px; padding: 12px 25px; font-weight: 500; transition: all 0.3s ease; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0, 109, 119, 0.35); }
        .form-control, .form-select { border-radius: 8px; border: 2px solid var(--border-color); padding: 12px 15px; transition: all 0.3s ease; }
        .form-control:focus, .form-select:focus { border-color: var(--seafoam); box-shadow: 0 0 0 0.2rem rgba(131, 197, 190, 0.35); }
        .form-label { font-weight: 600; color: var(--text-dark); margin-bottom: 8px; }
        .page-header h2 { color: var(--turquoise-dark); font-weight: 700; }
        .page-header p { color: var(--text-muted); font-size: 1.05rem; }

        /* =====================
           Responsive
        ====================== */
        @media (max-width: 992px) {
            .nav-left-sidebar { transform: translateX(-100%); }
            .dashboard-header { left: 0; }
            .dashboard-wrapper { margin-left: 0; width: 100%; }
        }
    </style>
</head>
<body>

<!-- ===================== Header / Topbar ===================== -->
<div class="dashboard-header">
    <nav class="navbar navbar-expand">
        <div class="container-fluid">
            <a class="navbar-brand d-flex align-items-center" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos">
                <i class="fas fa-store me-2" style="color: var(--seafoam);"></i>
                <span>Telito Bodeguero</span>
            </a>

            <ul class="navbar-nav ms-auto">
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                        <img src="https://ui-avatars.com/api/?name=Eduardo+Rodas&background=006d77&color=fff" alt="User" class="rounded-circle me-2" width="32" height="32">
                        <span>Eduardo Rodas</span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="#"><i class="fas fa-user me-2"></i>Perfil</a></li>
                        <li><a class="dropdown-item" href="#"><i class="fas fa-cog me-2"></i>Configuración</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="#"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a></li>
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
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos"><i class="fas fa-shopping-cart"></i>Mis Productos</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra"><i class="fas fa-chart-pie"></i>Órdenes de Compra</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=formRegistrarLote"><i class="fas fa-boxes"></i>Registrar Lotes</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="<%= request.getContextPath() %>/ProductorServlet?action=formActualizarPrecios"><i class="fas fa-tags"></i>Actualizar Precios</a>
                    </li>
                    <!-- Ir a Roles -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/">
                            <i class="fas fa-th-large"></i>Ir a Roles
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>

    <!-- ===================== Contenido principal ===================== -->
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="page-header mb-4">
                <h2 class="mb-1"><i class="fas fa-tags me-2"></i>Actualizar Precios</h2>
                <p class="text-muted">Modifica el precio sugerido de un producto. Busca por SKU y define el nuevo precio.</p>
            </div>

            <!-- ===================== Card: Búsqueda por SKU ===================== -->
            <div class="card mb-4">
                <div class="card-header"><h5 class="mb-0"><strong>1. Buscar Producto</strong></h5></div>
                <div class="card-body">
                    <form method="GET" action="<%= request.getContextPath() %>/ProductorServlet" class="row g-3 align-items-end">
                        <input type="hidden" name="action" value="formActualizarPrecios">
                        <div class="col-md-9">
                            <label for="sku" class="form-label">SKU del Producto</label>
                            <input id="sku" type="text" class="form-control" name="sku" placeholder="Ingrese el SKU para buscar..." required value="<%= (request.getParameter("sku") != null ? request.getParameter("sku") : "") %>">
                        </div>
                        <div class="col-md-3">
                            <button type="submit" class="btn btn-primary w-100"><i class="fas fa-search me-2"></i>Buscar</button>
                        </div>
                    </form>
                </div>
            </div>

            <%-- El card de actualización solo se muestra si se encontró un producto --%>
            <!-- ===================== Card: Actualización de Precio ===================== -->
            <% if (producto != null && producto.getIdProducto() != 0) { %>
            <div class="card">
                <div class="card-header"><h5 class="mb-0"><strong>2. Actualizar Precio</strong></h5></div>
                <div class="card-body">
                    <form method="POST" action="<%= request.getContextPath() %>/ProductorServlet?action=actualizarPrecio" class="row g-3">
                        <input type="hidden" name="idProducto" value="<%= producto.getIdProducto() %>">

                        <div class="col-md-6">
                            <label class="form-label">Nombre del Producto</label>
                            <input type="text" class="form-control" value="<%= producto.getNombre() %>" readonly style="background-color: #f8f9fa;">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Precio Actual</label>
                            <div class="input-group">
                                <span class="input-group-text">S/</span>
                                <input type="text" class="form-control" value="<%= String.format("%.2f", producto.getPrecioActual()) %>" readonly style="background-color: #f8f9fa;">
                            </div>
                        </div>
                        <div class="col-12">
                            <label for="nuevoPrecio" class="form-label"><strong>Precio Sugerido (Nuevo)</strong></label>
                            <div class="input-group">
                                <span class="input-group-text">S/</span>
                                <input id="nuevoPrecio" type="number" class="form-control" name="nuevoPrecio" step="0.01" min="0" value="0.00" required>
                            </div>
                        </div>
                        <div class="col-12 text-end mt-4">
                            <button type="submit" class="btn btn-primary"><i class="fas fa-sync-alt me-2"></i>Actualizar Precio</button>
                        </div>
                    </form>
                </div>
            </div>
            <% } %>
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
</script>
</body>
</html>