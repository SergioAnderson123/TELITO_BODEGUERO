<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.productor.beans.Producto" %>
<%@ page import="com.example.telito.productor.beans.Categoria" %>
<%@ page import="java.util.ArrayList" %>
<%--
    JSP: Mis Productos
    Propósito: Mostrar el inventario del productor, estadísticas y utilidades de filtrado/ordenado.
    Atributos esperados (request):
      - listaProductos (ArrayList<Producto>)
      - totalProductos (int), fueraDeStock (int), totalCategorias (int)
    Navegación: Sidebar con sección "Mis Productos" activa.
--%>
<jsp:useBean id="listaProductos" scope="request" type="java.util.ArrayList<com.example.telito.productor.beans.Producto>" />

<%
    int totalProductos = (request.getAttribute("totalProductos") != null) ? (int) request.getAttribute("totalProductos") : 0;
    int fueraDeStock = (request.getAttribute("fueraDeStock") != null) ? (int) request.getAttribute("fueraDeStock") : 0;
    int totalCategorias = (request.getAttribute("totalCategorias") != null) ? (int) request.getAttribute("totalCategorias") : 0;
    ArrayList<Categoria> todasLasCategorias = (ArrayList<Categoria>) request.getAttribute("todasLasCategorias");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Productos - Telito Bodeguero</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

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
           Contenedores (match registrarLotes)
        ====================== */
        .dashboard-main-wrapper { display: flex; min-height: 100vh; }
        .dashboard-header {
            background-color: #fff;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: fixed; top: 0; right: 0; left: 250px; z-index: 999;
            height: 70px; border-bottom: 1px solid var(--border-color);
        }
        .dashboard-wrapper { margin-left: 250px; width: calc(100% - 250px); min-height: 100vh; }
        .dashboard-content { margin-top: 70px; padding: 30px; }
        .page-header { margin-bottom: 30px; }
        .page-header h2 { color: var(--turquoise-dark); font-weight: 700; margin-bottom: 10px; }
        .page-header p { color: var(--text-muted); font-size: 1.05rem; }

        /* =====================
           Sidebar (idéntico a registrarLotes)
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
        .stats-container { display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; margin-bottom: 40px; }
        .stat-card {
            background-color: var(--white);
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        }
        .stat-card h3 { margin: 0 0 10px 0; font-size: 1rem; color: var(--text-muted); font-weight: 600; }
        .stat-card p { margin: 0; font-size: 2rem; font-weight: 800; color: var(--turquoise-dark); }

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
        #openModalBtn { background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); border: none; }

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

        /* Tabla */
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid var(--border-color); }
        thead th { background-color: var(--seafoam-light); font-weight: 700; color: var(--text-muted); text-transform: uppercase; font-size: 0.85rem; }
        tbody tr:hover { background-color: var(--seafoam-light); }

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
           Modal personalizado (solo para addProductModal)
        ====================== */
        #addProductModal.modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); }
        #addProductModal .modal-content { background-color: var(--white); margin: 8% auto; padding: 30px; border: none; width: 60%; max-width: 700px; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.3); animation: slide-down 0.3s ease-out; }
        @keyframes slide-down { from { transform: translateY(-30px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        #addProductModal .modal-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); padding-bottom: 15px; margin-bottom: 25px; }
        #addProductModal .modal-header h2 { margin: 0; color: var(--turquoise-dark); }
        #addProductModal .modal-close { color: #aaa; font-size: 28px; font-weight: bold; cursor: pointer; }
        #addProductModal .modal-footer { display: flex; justify-content: flex-end; gap: 15px; padding-top: 15px; margin-top: 25px; border-top: 1px solid var(--border-color); }
        
        /* Asegurar que los modales Bootstrap tengan z-index correcto */
        #resumenLotesProductoModal {
            z-index: 1055;
        }

        /* =====================
           Responsive
        ====================== */
        @media (max-width: 992px) {
            .nav-left-sidebar { position: fixed; transform: translateX(-100%); transition: transform 0.3s ease; }
            .nav-left-sidebar.open { transform: translateX(0); }
            .dashboard-header { left: 0; }
            .dashboard-wrapper { margin-left: 0; width: 100%; }
            .dashboard-content { padding: 20px; }
            .stats-container { grid-template-columns: 1fr; }
            .modal-content { width: 92%; margin: 15% auto; }
        }
    </style>
</head>
<body>

<div class="dashboard-main-wrapper">
    <!-- ===================== Header / Topbar ===================== -->
    <div class="dashboard-header">
        <nav class="navbar navbar-expand">
            <div class="container-fluid">
                <!-- Brand -->
                <a class="navbar-brand d-flex align-items-center" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos">
                    <i class="fas fa-store me-2" style="color: var(--seafoam);"></i>
                    <span>Telito Bodeguero</span>
                </a>

                <!-- Right actions -->
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item dropdown">
                        <%
                            com.example.telito.administrador.beans.Usuario usuarioHeaderMisProd = 
                                (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
                            String nombreCompletoMisProd = usuarioHeaderMisProd != null ? 
                                usuarioHeaderMisProd.getNombres() + " " + usuarioHeaderMisProd.getApellidos() : "Usuario";
                            String fotoUrlMisProd = "https://ui-avatars.com/api/?name=User&background=006d77&color=fff&size=200";
                            if (usuarioHeaderMisProd != null) {
                                String foto = usuarioHeaderMisProd.getFotoPerfil();
                                if (foto != null && !foto.trim().isEmpty()) {
                                    if (foto.startsWith("http://") || foto.startsWith("https://")) {
                                        fotoUrlMisProd = foto;
                                    } else {
                                        fotoUrlMisProd = request.getContextPath() + "/" + foto;
                                    }
                                } else {
                                    fotoUrlMisProd = usuarioHeaderMisProd.getFotoPerfilUrl();
                                }
                            }
                        %>
                        <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                            <img src="<%= fotoUrlMisProd %>" alt="User" class="rounded-circle me-2" width="32" height="32">
                            <span style="color:#006d77;"><%= nombreCompletoMisProd %></span>
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
                    <!-- Mis productos -->
                    <li class="nav-item">
                        <a class="nav-link active" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos">
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
            <div class="page-header d-flex justify-content-between align-items-center">
                <div>
                    <h2><i class="fas fa-shopping-cart me-2"></i>Mis Productos</h2>
                    <p class="text-muted mb-0">Vista general de tu inventario y herramientas de gestión.</p>
                </div>
                <div class="d-flex gap-2 flex-wrap">
                    <div class="btn-group">
                        <a href="<%= request.getContextPath() %>/productor/ProductoReporteServlet?action=exportar" class="btn btn-sm" style="background: linear-gradient(160deg, #28a745 0%, #20c997 100%); color: white; border: none; padding: 8px 16px; border-radius: 8px;">
                            <i class="fas fa-file-excel me-2"></i>Exportar Productos
                        </a>
                        <a href="<%= request.getContextPath() %>/productor/ProductoReporteServlet?action=formEnviar" class="btn btn-sm" style="background: linear-gradient(160deg, #17a2b8 0%, #138496 100%); color: white; border: none; padding: 8px 16px; border-radius: 8px;">
                            <i class="fas fa-envelope me-2"></i>Enviar Productos
                        </a>
                    </div>
                </div>
            </div>

            <!-- ===================== Mensaje de resultado (éxito/error) ===================== -->
            <%
                String alertType = (String) request.getAttribute("alertType");
                String alertMessage = (String) request.getAttribute("alertMessage");
                if (alertType != null && alertMessage != null) {
            %>
            <div class="alert alert-<%= alertType %>" role="alert" style="border-radius: 10px;">
                <i class="fas <%= "success".equals(alertType) ? "fa-check-circle" : "fa-exclamation-triangle" %> me-2"></i>
                <%= alertMessage %>
            </div>
            <%
                }
                // Mensajes de sesión para reportes
                String mensaje = (String) session.getAttribute("mensaje");
                String tipoMensaje = (String) session.getAttribute("tipoMensaje");
                if (mensaje != null) {
            %>
            <div class="alert alert-<%= tipoMensaje != null ? tipoMensaje : "info" %> alert-dismissible fade show" role="alert" style="border-radius: 10px;">
                <i class="fas <%= "success".equals(tipoMensaje) ? "fa-check-circle" : "info".equals(tipoMensaje) ? "fa-info-circle" : "fa-exclamation-triangle" %> me-2"></i>
                <%= mensaje %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <%
                    session.removeAttribute("mensaje");
                    session.removeAttribute("tipoMensaje");
                }
            %>

            <!-- ===================== Card: Búsqueda y filtros de productos ===================== -->
            <div class="card" style="padding: 20px; margin-top: -10px;">
                <div class="row g-3 align-items-center">
                    <div class="col-lg-5 col-md-12">
                        <div class="input-group">
                            <input id="searchInput" type="text" class="form-control" placeholder="Busca productos por nombre o SKU...">
                            <button class="btn" type="button" style="background: var(--seafoam); color: #fff;">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-6">
                        <select id="categoryFilter" class="form-select">
                            <option value="">Todas las categorías</option>
                            <% if (todasLasCategorias != null) { for (Categoria categoria : todasLasCategorias) { %>
                                <option value="<%= categoria.getNombre() %>"><%= categoria.getNombre() %></option>
                            <% } } %>
                        </select>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <select id="priceOrder" class="form-select">
                            <option value="">Todos los precios</option>
                            <option value="asc">Precio: Menor a Mayor</option>
                            <option value="desc">Precio: Mayor a Menor</option>
                        </select>
                    </div>
                </div>
            </div>

    <!-- ===================== Tarjetas de estadísticas ===================== -->
    <div class="stats-container">
        <div class="stat-card"><h3>Total de Productos</h3><p><%= totalProductos %></p></div>
        <div class="stat-card"><h3>Fuera de Stock</h3><p><%= fueraDeStock %></p></div>
        <div class="stat-card"><h3>Categorías Activas</h3><p><%= totalCategorias %></p></div>
    </div>

    <!-- ===================== Card: Inventario actual (tabla) ===================== -->
    <div class="card">
        <div class="card-header">
            <h2>Inventario Actual</h2>
            <button id="openModalBtn">Agregar Producto</button>
        </div>
        <table id="productsTable">
            <thead>
            <tr><th>#</th><th>SKU</th><th>Nombre</th><th>Categoría</th><th>Precio</th><th>Lotes</th><th>Acciones</th></tr>
            </thead>
            <tbody>
            <% 
                Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                Integer sizeObj = (Integer) request.getAttribute("size");
                int currentPage = (currentPageObj != null) ? currentPageObj : 1;
                int size = (sizeObj != null) ? sizeObj : 10;
                int i = (currentPage - 1) * size + 1;
            %>
            <% for (Producto p : listaProductos) { %>
            <tr data-category="<%= p.getCategoria().getNombre() %>" data-price="<%= String.format(java.util.Locale.US, "%.2f", p.getPrecioActual()) %>" data-sku="<%= p.getCodigoSKU() %>" data-name="<%= p.getNombre() %>">
                <td><%= i++ %></td>
                <td><%= p.getCodigoSKU() %></td>
                <td><%= p.getNombre() %></td>
                <td><%= p.getCategoria().getNombre() %></td>
                <td>S/ <%= String.format("%.2f", p.getPrecioActual()) %></td>
                <td>
                    <% int lotes = p.getNumeroLotes(); %>
                    <span class="badge <%= (lotes > 0) ? "bg-success" : "bg-danger" %> me-2"><%= lotes %></span>
                    <% if (lotes > 0) { %>
                        <button type="button" 
                                class="btn btn-sm btn-outline-primary" 
                                onclick="mostrarResumenLotesProducto(<%= p.getIdProducto() %>, '<%= p.getNombre() %>')"
                                title="Ver detalles de lotes">
                            <i class="fas fa-eye"></i> Ver
                        </button>
                    <% } %>
                </td>
                <td>
                    <button type="button" class="btn btn-sm"
                            style="background-color: #ff6b6b; color: white; border: none; padding: 6px 12px; border-radius: 6px;"
                            onclick="confirmarEliminacion(<%= p.getIdProducto() %>, '<%= p.getNombre() %>')"
                            title="Eliminar producto"
                            onmouseover="this.style.backgroundColor='#ff5252'"
                            onmouseout="this.style.backgroundColor='#ff6b6b'">
                        <i class="fas fa-trash me-1"></i>Borrar
                    </button>
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

    <!-- Cierre del contenedor principal -->
    </div>

<!-- ===================== Modal: Agregar Producto ===================== -->
<div id="addProductModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Agregar Nuevo Producto</h2>
            <span class="modal-close">&times;</span>
        </div>
        <form method="POST" action="<%= request.getContextPath() %>/ProductorServlet?action=crearProducto" id="formAgregarProducto">
            <div style="display: flex; gap: 20px;">
                <div style="flex: 1;"><label for="productName">Nombre del producto</label><input type="text" name="productName" id="productName" required></div>
                <div style="flex: 1;"><label for="productCategory">Categoría</label>
                    <select name="productCategory" id="productCategory" required>
                        <option value="">Seleccionar...</option>
                        <% if (todasLasCategorias != null) { %>
                            <% for (Categoria categoria : todasLasCategorias) { %>
                                <option value="<%= categoria.getIdCategoria() %>"><%= categoria.getNombre() %></option>
                            <% } %>
                        <% } %>
                    </select>
                </div>
            </div>
            <div style="display: flex; gap: 20px; margin-top: 15px;">
                <div style="flex: 1;">
                    <label for="productSKUDisplay">SKU (generado automáticamente)</label>
                    <input type="text" id="productSKUDisplay" readonly style="background-color: #f0f0f0; cursor: not-allowed;" placeholder="Cargando...">
                    <small style="color: var(--text-muted); display: block; margin-top: 5px;">
                        <i class="fas fa-info-circle"></i> El SKU se genera automáticamente
                    </small>
                </div>
                <div style="flex: 1;"><label for="productPrice">Precio por Paquete (S/)</label><input type="number" name="productPrice" id="productPrice" step="0.01" required></div>
            </div>
            <div style="display: flex; gap: 20px; margin-top: 15px;">
                <div style="flex: 1;">
                    <label for="productUnits">Unidades por Paquete</label>
                    <input type="number" name="productUnits" id="productUnits" min="1" value="1" required>
                    <small style="color: var(--text-muted); display: block; margin-top: 5px;">
                        <i class="fas fa-box"></i> Ej: Si vende cerveza en cajas de 12, ingrese 12
                    </small>
                </div>
                <div style="flex: 1;"></div>
            </div>
            <div style="margin-top: 15px;"><label for="productDescription">Descripción</label><textarea name="productDescription" id="productDescription" rows="3"></textarea></div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary modal-cancel">Cancelar</button>
                <button type="submit" id="btnGuardarProducto">Guardar Producto</button>
            </div>
        </form>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    const modal = document.getElementById('addProductModal');
    const openBtn = document.getElementById('openModalBtn');
    const closeBtn = document.querySelector('.modal-close');
    const cancelBtn = document.querySelector('.modal-cancel');
    const skuDisplay = document.getElementById('productSKUDisplay');

    // Función para cargar el siguiente SKU disponible
    function cargarNuevoSKU() {
        skuDisplay.value = 'Cargando...';
        skuDisplay.style.color = '#999';
        
        const contextPath = '<%= request.getContextPath() %>';
        fetch(contextPath + '/ProductorServlet?action=obtenerNuevoSKU')
            .then(response => response.json())
            .then(data => {
                if (data.sku) {
                    skuDisplay.value = data.sku;
                    skuDisplay.style.color = '#28a745'; // Color verde para indicar éxito
                    skuDisplay.style.fontWeight = 'bold';
                } else {
                    skuDisplay.value = 'Error al generar SKU';
                    skuDisplay.style.color = '#dc3545';
                }
            })
            .catch(error => {
                console.error('Error al obtener SKU:', error);
                skuDisplay.value = 'Error de conexión';
                skuDisplay.style.color = '#dc3545';
            });
    }

    // Al abrir el modal, cargar el nuevo SKU
    openBtn.onclick = function() { 
        modal.style.display = "block";
        cargarNuevoSKU(); // Cargar el SKU automáticamente
        // Limpiar solo los campos editables (no borrar las opciones del select)
        document.getElementById('productName').value = '';
        document.getElementById('productCategory').selectedIndex = 0; // Volver a "Seleccionar..."
        document.getElementById('productDescription').value = '';
        document.getElementById('productPrice').value = '';
        document.getElementById('productUnits').value = '1';
    }
    
    closeBtn.onclick = function() { modal.style.display = "none"; }
    cancelBtn.onclick = function() { modal.style.display = "none"; }
    window.onclick = function(event) { if (event.target == modal) { modal.style.display = "none"; } }

    // Búsqueda, filtro por categoría y orden de precio (en cliente)
    const searchInput = document.getElementById('searchInput');
    const categoryFilter = document.getElementById('categoryFilter');
    const priceOrder = document.getElementById('priceOrder');
    const table = document.getElementById('productsTable');
    const tbody = table.querySelector('tbody');

    function normalize(text){
        return (text || '').toString().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }

    function applyFilters() {
        const term = normalize(searchInput.value);
        const category = categoryFilter.value;

        const rows = Array.from(tbody.querySelectorAll('tr'));

        rows.forEach(row => {
            const name = normalize(row.dataset.name);
            const sku = normalize(row.dataset.sku);
            const rowCategory = row.dataset.category;

            const matchesSearch = !term || name.includes(term) || sku.includes(term);
            const matchesCategory = !category || rowCategory === category;

            row.style.display = (matchesSearch && matchesCategory) ? '' : 'none';
        });

        applySort();
    }

    function applySort() {
        const order = priceOrder.value;
        if (!order) return; // no ordenar

        const rows = Array.from(tbody.querySelectorAll('tr'))
            .filter(r => r.style.display !== 'none');

        rows.sort((a, b) => {
            const pa = parseFloat(a.dataset.price || '0');
            const pb = parseFloat(b.dataset.price || '0');
            return order === 'asc' ? pa - pb : pb - pa;
        });

        // Reinsertar en el nuevo orden, manteniendo ocultos sin moverlos
        rows.forEach(r => tbody.appendChild(r));
    }

    searchInput.addEventListener('input', applyFilters);
    categoryFilter.addEventListener('change', applyFilters);
    priceOrder.addEventListener('change', () => { applySort(); });

    // Inicializar
    applyFilters();

    // ===================== Función para confirmar eliminación de producto =====================
    function confirmarEliminacion(idProducto, nombreProducto) {
        if (confirm('¿Estás seguro de que quieres eliminar el producto "' + nombreProducto + '"?\n\nEsta acción no se puede deshacer.')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '<%= request.getContextPath() %>/ProductorServlet';
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'desactivarProducto';
            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'idProducto';
            idInput.value = idProducto;
            form.appendChild(actionInput);
            form.appendChild(idInput);
            document.body.appendChild(form);
            form.submit();
        }
    }

    // Recargar página si se vuelve desde el perfil
    if (sessionStorage.getItem('recargarDesdePerfil') === 'true') {
        sessionStorage.removeItem('recargarDesdePerfil');
        location.reload();
    }
    
    // Instancia global del modal para reutilizar
    let resumenLotesModalInstance = null;
    
    function getResumenLotesModal() {
        const modalElement = document.getElementById('resumenLotesProductoModal');
        
        // Siempre crear nueva instancia o obtener la existente
        resumenLotesModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
        
        // Limpiar backdrops cuando se cierre el modal (una sola vez)
        if (!modalElement.hasAttribute('data-backdrop-listener')) {
            modalElement.setAttribute('data-backdrop-listener', 'true');
            modalElement.addEventListener('hidden.bs.modal', function() {
                limpiarBackdropsResumen();
            });
        }
        
        return resumenLotesModalInstance;
    }
    
    function limpiarBackdropsResumen() {
        // Esperar un poco para que Bootstrap termine de procesar
        setTimeout(function() {
            const backdrops = document.querySelectorAll('.modal-backdrop');
            // Eliminar todos los backdrops excepto si hay un modal abierto
            if (backdrops.length > 0) {
                const modalsAbiertos = document.querySelectorAll('.modal.show');
                if (modalsAbiertos.length === 0) {
                    // No hay modales abiertos, eliminar todos los backdrops
                    backdrops.forEach(backdrop => backdrop.remove());
                    document.body.classList.remove('modal-open');
                    document.body.style.overflow = '';
                    document.body.style.paddingRight = '';
                } else if (backdrops.length > 1) {
                    // Hay múltiples backdrops pero solo un modal, eliminar extras
                    for (let i = 1; i < backdrops.length; i++) {
                        backdrops[i].remove();
                    }
                }
            }
        }, 150);
    }
    
    // Función para mostrar resumen de lotes de un producto
    function mostrarResumenLotesProducto(productoId, nombreProducto) {
        // Limpiar cualquier estado previo del modal
        const modalElement = document.getElementById('resumenLotesProductoModal');
        
        // Cerrar modal si está abierto
        const existingModal = bootstrap.Modal.getInstance(modalElement);
        if (existingModal) {
            existingModal.hide();
        }
        
        // Limpiar backdrops previos
        const backdrops = document.querySelectorAll('.modal-backdrop');
        backdrops.forEach(backdrop => backdrop.remove());
        document.body.classList.remove('modal-open');
        document.body.style.overflow = '';
        document.body.style.paddingRight = '';
        
        // Actualizar título del modal
        document.getElementById('modalProductoNombreResumen').textContent = 'Producto: ' + nombreProducto;
        
        // Mostrar loading y ocultar contenido
        document.getElementById('loadingResumenProducto').style.display = 'block';
        document.getElementById('contenidoResumenProducto').style.display = 'none';
        document.getElementById('sinLotesProducto').style.display = 'none';
        
        // Limpiar tabla
        document.getElementById('tablaResumenLotesProducto').innerHTML = '';
        
        // Abrir modal usando instancia reutilizable después de un pequeño delay
        setTimeout(function() {
            const modal = getResumenLotesModal();
            modal.show();
        }, 50);
        
        // Cargar datos via AJAX
        fetch('<%= request.getContextPath() %>/ProductorServlet?action=obtenerResumenLotesProducto&productoId=' + productoId)
            .then(response => response.json())
            .then(data => {
                document.getElementById('loadingResumenProducto').style.display = 'none';
                
                if (data.success && data.lotes && data.lotes.length > 0) {
                    document.getElementById('contenidoResumenProducto').style.display = 'block';
                    document.getElementById('sinLotesProducto').style.display = 'none';
                    
                    const tbody = document.getElementById('tablaResumenLotesProducto');
                    tbody.innerHTML = '';
                    
                    data.lotes.forEach(lote => {
                        const row = document.createElement('tr');
                        const fechaVencimiento = lote.fechaVencimiento || 'Sin fecha';
                        
                        // Convertir a números explícitamente
                        const paquetesInicial = parseInt(lote.paquetesInicial) || 0;
                        const paquetesRestante = parseInt(lote.paquetesRestante) || 0;
                        const stockInicial = parseInt(lote.stockInicial) || 0;
                        const stockRestante = parseInt(lote.stockRestante) || 0;
                        
                        // Calcular porcentaje usado basado en unidades (más preciso)
                        let porcentajeUsado = 0;
                        if (stockInicial > 0) {
                            const unidadesUsadas = stockInicial - stockRestante;
                            porcentajeUsado = (unidadesUsadas / stockInicial * 100).toFixed(1);
                        }
                        
                        // Determinar el color del badge según el porcentaje
                        let badgeClass = 'badge bg-secondary';
                        if (parseFloat(porcentajeUsado) === 0) {
                            badgeClass = 'badge bg-success';
                        } else if (parseFloat(porcentajeUsado) < 50) {
                            badgeClass = 'badge bg-info';
                        } else if (parseFloat(porcentajeUsado) < 90) {
                            badgeClass = 'badge bg-warning text-dark';
                        } else {
                            badgeClass = 'badge bg-danger';
                        }
                        
                        row.innerHTML = 
                            '<td><strong>' + lote.codigoLote + '</strong></td>' +
                            '<td>' + paquetesInicial + ' paquetes<br><small class="text-muted">(' + stockInicial.toLocaleString() + ' unidades)</small></td>' +
                            '<td>' + paquetesRestante + ' paquetes<br><small class="text-muted">(' + stockRestante.toLocaleString() + ' unidades)</small></td>' +
                            '<td><span class="' + badgeClass + '">' + porcentajeUsado + '% usado</span></td>' +
                            '<td>' + fechaVencimiento + '</td>';
                        tbody.appendChild(row);
                    });
                } else {
                    document.getElementById('contenidoResumenProducto').style.display = 'block';
                    document.getElementById('sinLotesProducto').style.display = 'block';
                }
            })
            .catch(error => {
                console.error('Error al cargar resumen de lotes:', error);
                document.getElementById('loadingResumenProducto').style.display = 'none';
                document.getElementById('contenidoResumenProducto').style.display = 'block';
                document.getElementById('sinLotesProducto').innerHTML = 
                    '<div class="alert alert-danger">Error al cargar el resumen de lotes. Por favor, intenta de nuevo.</div>';
            });
    }
</script>

<!-- Modal para mostrar resumen de lotes de un producto -->
<div class="modal fade" id="resumenLotesProductoModal" tabindex="-1" aria-labelledby="resumenLotesProductoModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="resumenLotesProductoModalLabel">
                    <i class="fas fa-boxes me-2"></i>Resumen de Lotes del Producto
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <h6 class="mb-3" id="modalProductoNombreResumen"></h6>
                <div id="loadingResumenProducto" class="text-center py-3">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Cargando...</span>
                    </div>
                </div>
                <div id="contenidoResumenProducto" style="display: none;">
                    <div class="table-responsive">
                        <table class="table table-hover table-sm">
                            <thead class="table-light">
                                <tr>
                                    <th>Código Lote</th>
                                    <th>Cantidad Inicial</th>
                                    <th>Cantidad Restante</th>
                                    <th>% Usado</th>
                                    <th>Fecha Vencimiento</th>
                                </tr>
                            </thead>
                            <tbody id="tablaResumenLotesProducto">
                            </tbody>
                        </table>
                    </div>
                    <div id="sinLotesProducto" class="alert alert-info" style="display: none;">
                        No hay lotes registrados para este producto.
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

</body>
</html>