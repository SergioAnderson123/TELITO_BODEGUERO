<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.bodega.beans.Producto" %>
<%@ page import="com.example.telito.bodega.beans.Categoria" %>
<%@ page import="java.util.ArrayList" %>
<%--
    JSP: Mis Productos
    Propósito: Mostrar el inventario del productor, estadísticas y utilidades de filtrado/ordenado.
    Atributos esperados (request):
      - listaProductos (ArrayList<Producto>)
      - totalProductos (int), fueraDeStock (int), totalCategorias (int)
    Navegación: Sidebar con sección "Mis Productos" activa.
--%>
<jsp:useBean id="listaProductos" scope="request" type="java.util.ArrayList<com.example.telito.bodega.beans.Producto>" />

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
        }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .card-header h2 { margin: 0; color: var(--turquoise-dark); }
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

        /* =====================
           Modal
        ====================== */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); }
        .modal-content { background-color: var(--white); margin: 8% auto; padding: 30px; border: none; width: 60%; max-width: 700px; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.3); animation: slide-down 0.3s ease-out; }
        @keyframes slide-down { from { transform: translateY(-30px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        .modal-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); padding-bottom: 15px; margin-bottom: 25px; }
        .modal-header h2 { margin: 0; color: var(--turquoise-dark); }
        .modal-close { color: #aaa; font-size: 28px; font-weight: bold; cursor: pointer; }
        .modal-footer { display: flex; justify-content: flex-end; gap: 15px; padding-top: 15px; margin-top: 25px; border-top: 1px solid var(--border-color); }

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
                        <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                            <img src="https://ui-avatars.com/api/?name=Eduardo+Rodas&background=006d77&color=fff" alt="User" class="rounded-circle me-2" width="32" height="32">
                            <span style="color:#006d77;">Eduardo Rodas</span>
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
            <div class="page-header">
                <h2><i class="fas fa-shopping-cart me-2"></i>Mis Productos</h2>
                <p class="text-muted">Vista general de tu inventario y herramientas de gestión.</p>
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
                            <option value="Bebidas">Bebidas</option>
                            <option value="Abarrotes">Abarrotes</option>
                            <option value="Lácteos">Lácteos</option>
                            <option value="Carnes">Carnes</option>
                            <option value="Verduras">Verduras</option>
                            <option value="Snacks">Snacks</option>
                            <option value="Limpieza">Limpieza</option>
                            <option value="Higiene">Higiene</option>
                            <option value="Panadería">Panadería</option>
                            <option value="Congelados">Congelados</option>
                            <option value="Enlatados">Enlatados</option>
                            <option value="Granos y Cereales">Granos y Cereales</option>
                            <option value="Bebidas Energéticas">Bebidas Energéticas</option>
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
            <% int i = 1; %>
            <% for (Producto p : listaProductos) { %>
            <tr data-category="<%= p.getCategoria().getNombre() %>" data-price="<%= String.format(java.util.Locale.US, "%.2f", p.getPrecioActual()) %>" data-sku="<%= p.getCodigoSKU() %>" data-name="<%= p.getNombre() %>">
                <td><%= i++ %></td>
                <td><%= p.getCodigoSKU() %></td>
                <td><%= p.getNombre() %></td>
                <td><%= p.getCategoria().getNombre() %></td>
                <td>S/ <%= String.format("%.2f", p.getPrecioActual()) %></td>
                <td>
                    <% int lotes = p.getNumeroLotes(); %>
                    <span class="badge <%= (lotes > 0) ? "bg-success" : "bg-danger" %>"><%= lotes %></span>
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
        <form method="POST" action="ProductorServlet?action=crearProducto">
            <div style="display: flex; gap: 20px;">
                <div style="flex: 1;"><label for="productName">Nombre del producto</label><input type="text" name="productName" required></div>
                <div style="flex: 1;"><label for="productCategory">Categoría</label>
                    <select name="productCategory" required>
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
                <div style="flex: 1;"><label for="productSKU">SKU</label><input type="text" name="productSKU" required></div>
                <div style="flex: 1;"><label for="productPrice">Precio (S/)</label><input type="number" name="productPrice" step="0.01" required></div>
            </div>
            <div style="margin-top: 15px;"><label for="productDescription">Descripción</label><textarea name="productDescription" rows="3"></textarea></div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary modal-cancel">Cancelar</button>
                <button type="submit">Guardar Producto</button>
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

    openBtn.onclick = function() { modal.style.display = "block"; }
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
            // Crear un formulario oculto para enviar la petición POST
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
</script>

</body>
</html>