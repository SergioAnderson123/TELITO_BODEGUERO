<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
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
    // Datos de ejemplo para la vista (en producción vendrían del servlet)
    List<Object> listaOrdenes = (List<Object>) request.getAttribute("listaOrdenes");
    if (listaOrdenes == null) {
        listaOrdenes = new ArrayList<>();
        // Datos de ejemplo para demostración
        listaOrdenes.add(new Object[]{"ORD-2025-001", "Coca Cola 500ml", 15, 2.50, "Miraflores", "Pendiente"});
        listaOrdenes.add(new Object[]{"ORD-2025-002", "Pan Bimbo Integral", 8, 4.20, "San Isidro", "Completada"});
        listaOrdenes.add(new Object[]{"ORD-2025-003", "Leche Gloria 1L", 12, 3.80, "La Molina", "Pendiente"});
        listaOrdenes.add(new Object[]{"ORD-2025-004", "Arroz Superior 5kg", 6, 8.50, "Surco", "Completada"});
        listaOrdenes.add(new Object[]{"ORD-2025-005", "Aceite Primor 900ml", 10, 6.20, "Barranco", "Pendiente"});
    }
    
    int totalOrdenes = (request.getAttribute("totalOrdenes") != null) ? (int) request.getAttribute("totalOrdenes") : listaOrdenes.size();
    int ordenesPendientes = (request.getAttribute("ordenesPendientes") != null) ? (int) request.getAttribute("ordenesPendientes") : 3;
    int ordenesCompletadas = (request.getAttribute("ordenesCompletadas") != null) ? (int) request.getAttribute("ordenesCompletadas") : 2;
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
        .dashboard-content { margin-top: 70px; padding: 30px; }
        .page-header { margin-bottom: 30px; }
        .page-header h2 { color: var(--turquoise-dark); font-weight: 700; margin-bottom: 10px; }
        .page-header p { color: var(--text-muted); font-size: 1.05rem; }

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

        /* Botones de acción */
        .btn-view {
            background: linear-gradient(160deg, #28a745 0%, #20c997 100%);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 0.875rem;
            font-weight: 500;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .btn-view:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
            color: white;
            text-decoration: none;
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
            <div class="page-header">
                <h2><i class="fas fa-chart-pie me-2"></i>Órdenes de Compra</h2>
                <p class="text-muted">Gestiona y monitorea las órdenes de compra de tus productos.</p>
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

            <!-- ===================== Card: Filtros y búsqueda ===================== -->
            <div class="card" style="padding: 20px; margin-top: -10px;">
                <div class="row g-3 align-items-center">
                    <div class="col-lg-4 col-md-12">
                        <div class="input-group">
                            <input id="searchInput" type="text" class="form-control" placeholder="Buscar por código de orden o producto...">
                            <button class="btn" type="button" style="background: var(--seafoam); color: #fff;">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-6">
                        <select id="statusFilter" class="form-select">
                            <option value="">Todos los estados</option>
                            <option value="Pendiente">Pendiente</option>
                            <option value="Completada">Completada</option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-6">
                        <select id="destinoFilter" class="form-select">
                            <option value="">Todos los destinos</option>
                            <option value="Miraflores">Miraflores</option>
                            <option value="San Isidro">San Isidro</option>
                            <option value="La Molina">La Molina</option>
                            <option value="Surco">Surco</option>
                            <option value="Barranco">Barranco</option>
                        </select>
                    </div>
                    <div class="col-lg-2 col-md-12">
                        <button class="btn w-100" onclick="limpiarFiltros()">
                            <i class="fas fa-eraser me-1"></i>Limpiar
                        </button>
                    </div>
                </div>
            </div>

            <!-- ===================== Card: Tabla de órdenes ===================== -->
            <div class="card">
                <div class="card-header">
                    <h2>Órdenes de Compra</h2>
                </div>
                <table id="ordenesTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Código de Orden</th>
                            <th>Nombre del Producto</th>
                            <th>Cantidad de Lotes</th>
                            <th>Precio</th>
                            <th>Destino</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% int i = 1; %>
                        <% for (Object orden : listaOrdenes) { %>
                            <% Object[] ordenData = (Object[]) orden; %>
                            <tr data-codigo="<%= ordenData[0] %>" 
                                data-producto="<%= ordenData[1] %>" 
                                data-estado="<%= ordenData[5] %>" 
                                data-destino="<%= ordenData[4] %>">
                                <td><%= i++ %></td>
                                <td><strong><%= ordenData[0] %></strong></td>
                                <td><%= ordenData[1] %></td>
                                <td>
                                    <span class="badge bg-primary">
                                        <%= ordenData[2] %> lotes
                                    </span>
                                </td>
                                <td><strong>S/ <%= String.format("%.2f", (Double) ordenData[3]) %></strong></td>
                                <td><%= ordenData[4] %></td>
                                <td>
                                    <% if ("Pendiente".equals(ordenData[5])) { %>
                                        <span class="badge-pendiente">
                                            <i class="fas fa-clock me-1"></i>Pendiente
                                        </span>
                                    <% } else { %>
                                        <span class="badge-completada">
                                            <i class="fas fa-check me-1"></i>Completada
                                        </span>
                                    <% } %>
                                </td>
                                <td>
                                    <a href="#" class="btn-view" onclick="verOrden('<%= ordenData[0] %>')">
                                        <i class="fas fa-eye"></i>Ver Orden
                                    </a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
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
    const destinoFilter = document.getElementById('destinoFilter');
    const table = document.getElementById('ordenesTable');
    const tbody = table.querySelector('tbody');

    function normalize(text) {
        return (text || '').toString().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }

    function applyFilters() {
        const searchTerm = normalize(searchInput.value);
        const status = statusFilter.value;
        const destino = destinoFilter.value;

        const rows = Array.from(tbody.querySelectorAll('tr'));

        rows.forEach(row => {
            const codigo = normalize(row.dataset.codigo);
            const producto = normalize(row.dataset.producto);
            const rowStatus = row.dataset.estado;
            const rowDestino = row.dataset.destino;

            const matchesSearch = !searchTerm || 
                codigo.includes(searchTerm) || 
                producto.includes(searchTerm);
            const matchesStatus = !status || rowStatus === status;
            const matchesDestino = !destino || rowDestino === destino;

            row.style.display = (matchesSearch && matchesStatus && matchesDestino) ? '' : 'none';
        });
    }

    function limpiarFiltros() {
        searchInput.value = '';
        statusFilter.value = '';
        destinoFilter.value = '';
        applyFilters();
    }

    // Event listeners
    searchInput.addEventListener('input', applyFilters);
    statusFilter.addEventListener('change', applyFilters);
    destinoFilter.addEventListener('change', applyFilters);

    // Función para ver orden (placeholder)
    function verOrden(codigoOrden) {
        alert('Ver detalles de la orden: ' + codigoOrden + '\n\nEsta funcionalidad se implementará próximamente.');
        // Aquí se podría abrir un modal o redirigir a una página de detalles
    }

    // Inicializar filtros
    applyFilters();
</script>

</body>
</html>
