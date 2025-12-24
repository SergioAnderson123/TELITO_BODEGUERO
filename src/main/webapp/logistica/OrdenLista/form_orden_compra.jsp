<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.ProductoBean" %>
<%@ page import="com.example.telito.logistica.beans.ProveedorBean" %>
<%@ page import="com.example.telito.logistica.beans.ZonaBean" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Generar Orden de Compra"/>
    </jsp:include>
    <style>
        /* Estilos específicos del módulo: Sidebar con temática café y beige */
        .nav-left-sidebar {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%) !important;
        }
        .nav-link {
            color: #F5DEB3 !important;
        }
        .nav-link:hover, .nav-link.active {
            color: #FFF8DC !important;
            background-color: rgba(245, 222, 179, 0.2) !important;
        }
        .nav-divider {
            color: #F5DEB3 !important;
            border-top-color: rgba(245, 222, 179, 0.4) !important;
        }
        .nav-link::before {
            background: #F5DEB3 !important;
        }
        
        /* Fondo beige claro para todo el contenido principal (header, centro, footer) */
        .dashboard-header {
            background-color: #FFFEF9 !important;
        }
        .dashboard-header .navbar {
            background-color: #FFFEF9 !important;
        }
        .dashboard-wrapper {
            background-color: #FFFEF9 !important;
        }
        .dashboard-content {
            background-color: #FFFEF9 !important;
        }
        .dashboard-main-wrapper {
            background-color: #FFFEF9 !important;
        }
        footer,
        .footer {
            background-color: #FFFEF9 !important;
        }
        body {
            background-color: #FFFEF9 !important;
        }
        
        /* Textos en color marrón */
        .dashboard-header .navbar-brand span {
            color: #6F4E37 !important;
        }
        .dashboard-header .navbar-brand i {
            color: #6F4E37 !important;
        }
        .dashboard-header .navbar-nav .nav-link span {
            color: #6F4E37 !important;
        }
        .dashboard-header .nav-link.dropdown-toggle {
            color: #6F4E37 !important;
        }
        .dashboard-header .nav-link i.fa-bell,
        .dashboard-header .nav-link i[class*="fa-bell"] {
            color: #6F4E37 !important;
        }
        .dashboard-header .nav-link[style*="color: var(--turquoise-dark)"] i,
        .dashboard-header .nav-link i[style*="color: var(--turquoise-dark)"] {
            color: #6F4E37 !important;
        }
        .dashboard-header .navbar-brand i.fa-truck,
        .dashboard-header .navbar-brand i[class*="fa-truck"],
        .dashboard-header .navbar-brand i[style*="color: var(--seafoam)"] {
            color: #6F4E37 !important;
        }
        .pageheader-title {
            color: #6F4E37 !important;
        }
        .pageheader-text {
            color: #6F4E37 !important;
        }
        .page-header h2 {
            color: #6F4E37 !important;
        }
        .page-header p {
            color: #6F4E37 !important;
        }
        .page-header h2 i {
            color: #6F4E37 !important;
        }
        
        /* Estilos para el autocompletado */
        .autocomplete-container {
            position: relative;
        }
        
        .autocomplete-results {
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: white;
            border: 2px solid #e9ecef;
            border-top: none;
            border-radius: 0 0 8px 8px;
            max-height: 300px;
            overflow-y: auto;
            z-index: 1000;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            display: none;
        }
        
        .autocomplete-results.show {
            display: block;
        }
        
        .autocomplete-item {
            padding: 12px 15px;
            cursor: pointer;
            border-bottom: 1px solid #f0f0f0;
            transition: background-color 0.2s;
        }
        
        .autocomplete-item:hover,
        .autocomplete-item.selected {
            background-color: rgba(111, 78, 55, 0.1);
        }
        
        .autocomplete-item:last-child {
            border-bottom: none;
        }
        
        .autocomplete-item-name {
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 4px;
        }
        
        .autocomplete-item-details {
            font-size: 0.85rem;
            color: #6c757d;
        }
        
        .autocomplete-item-price {
            color: #6F4E37;
            font-weight: 600;
        }
        
        /* Secciones del formulario */
        .form-section {
            background: #FFFEF9;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            border: 2px solid #6F4E37;
        }
        
        .form-section-title {
            color: #6F4E37;
            font-weight: 700;
            font-size: 1.1rem;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid rgba(111, 78, 55, 0.2);
            display: flex;
            align-items: center;
        }
        
        .form-section-title i {
            margin-right: 10px;
            color: #6F4E37;
        }
        
        /* Resumen mejorado */
        .resumen-card {
            background: linear-gradient(165deg, rgba(111, 78, 55, 0.05) 0%, #FFFEF9 100%);
            border: 2px solid #6F4E37;
            border-radius: 12px;
            padding: 25px;
            position: sticky;
            top: 100px;
        }
        
        .resumen-item {
            padding: 12px 0;
            border-bottom: 1px solid #e9ecef;
        }
        
        .resumen-item:last-child {
            border-bottom: none;
        }
        
        .resumen-label {
            font-size: 0.85rem;
            color: #6c757d;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 5px;
        }
        
        .resumen-value {
            font-size: 1.1rem;
            color: #2b2d42;
            font-weight: 700;
        }
        
        .resumen-total {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            margin-top: 20px;
        }
        
        .resumen-total-label {
            font-size: 0.9rem;
            opacity: 0.9;
            margin-bottom: 8px;
        }
        
        .resumen-total-value {
            font-size: 2rem;
            font-weight: 800;
        }
        
        /* Input mejorado */
        .form-control-autocomplete {
            padding: 12px 45px 12px 15px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 1rem;
            transition: all 0.3s ease;
        }
        
        .form-control-autocomplete:focus {
            border-color: #6F4E37;
            box-shadow: 0 0 0 0.2rem rgba(111, 78, 55, 0.25);
        }
        
        .input-icon {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #6c757d;
            pointer-events: none;
        }
        
        .selected-display {
            background: rgba(111, 78, 55, 0.05);
            border: 2px solid #6F4E37;
            border-radius: 8px;
            padding: 15px;
            margin-top: 10px;
            display: none;
        }
        
        .selected-display.show {
            display: block;
        }
        
        .selected-name {
            font-weight: 700;
            color: #6F4E37;
            font-size: 1.1rem;
            margin-bottom: 5px;
        }
        
        .selected-details {
            font-size: 0.9rem;
            color: #6c757d;
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='OrdenCompra'/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />

    <div class="dashboard-wrapper">
        <div class="container-fluid dashboard-content">
            <div class="row">
                <div class="col-12">
                    <div class="page-header">
                        <h2><i class="fas fa-file-invoice-dollar me-2"></i>Generar Nueva Orden de Compra</h2>
                        <p class="text-muted">Complete el formulario para crear una nueva orden de compra</p>
                    </div>
                </div>
            </div>

            <%-- Mostrar errores de validación --%>
            <%
                ArrayList<String> errores = (ArrayList<String>) request.getAttribute("errores");
                if (errores != null && !errores.isEmpty()) {
            %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <h5 class="alert-heading">
                    <i class="fas fa-exclamation-triangle me-2"></i>Se encontraron los siguientes errores:
                </h5>
                <ul class="mb-0">
                    <% for (String error : errores) { %>
                        <li><%= error %></li>
                    <% } %>
                </ul>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>
            
            <%-- Recuperar valores previos del formulario --%>
            <%
                String productorIdPrevio = request.getAttribute("productor_id") != null ? request.getAttribute("productor_id").toString() : "";
                String productoIdPrevio = request.getAttribute("producto_id") != null ? request.getAttribute("producto_id").toString() : "";
                String cantidadPrevia = request.getAttribute("cantidad") != null ? request.getAttribute("cantidad").toString() : "";
                String distritoIdPrevio = request.getAttribute("distrito_id") != null ? request.getAttribute("distrito_id").toString() : "";
                String montoTotalPrevio = request.getAttribute("monto_total") != null ? request.getAttribute("monto_total").toString() : "";
            %>
            
            <form method="POST" action="${pageContext.request.contextPath}/orden-compra" id="formOrdenCompra">
                <input type="hidden" name="action" value="guardar">
                <input type="hidden" id="productor_id" name="productor_id" value="<%= productorIdPrevio %>">
                <input type="hidden" id="producto_id" name="producto_id" value="<%= productoIdPrevio %>">
                <input type="hidden" id="zona_id" name="zona_id" value="">
                <input type="hidden" id="distrito_id" name="distrito_id" value="<%= distritoIdPrevio %>">

                <div class="row">
                    <!-- Columna Izquierda - Formulario -->
                    <div class="col-lg-8">
                        <!-- Sección 1: Información del Productor y Producto -->
                        <div class="form-section">
                            <div class="form-section-title">
                                <i class="fas fa-user-tie"></i>
                                Información del Productor y Producto
                            </div>
                            
                            <div class="row">
                                <div class="col-md-12 mb-3">
                                    <label for="productorBusqueda" class="form-label">Buscar Productor <span class="text-danger">*</span></label>
                                    <div class="autocomplete-container">
                                        <input type="text" 
                                               class="form-control form-control-autocomplete" 
                                               id="productorBusqueda" 
                                               placeholder="Escribe el nombre del productor..." 
                                               autocomplete="off">
                                        <i class="fas fa-search input-icon"></i>
                                        <div class="autocomplete-results" id="autocompleteProductores"></div>
                                    </div>
                                    <small class="text-muted">
                                        <i class="fas fa-info-circle"></i> Escribe para buscar productores. Los resultados aparecerán mientras escribes.
                                    </small>
                                    
                                    <!-- Mostrar productor seleccionado -->
                                    <div class="selected-display" id="selectedProductorDisplay">
                                        <div class="selected-name" id="selectedProductorName"></div>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12 mb-3">
                                    <label for="productoBusqueda" class="form-label">Buscar Producto <span class="text-danger">*</span></label>
                                    <div class="autocomplete-container">
                                        <input type="text" 
                                               class="form-control form-control-autocomplete" 
                                               id="productoBusqueda" 
                                               placeholder="Escribe el nombre o SKU del producto..." 
                                               autocomplete="off"
                                               disabled>
                                        <i class="fas fa-search input-icon"></i>
                                        <div class="autocomplete-results" id="autocompleteProductos"></div>
                                    </div>
                                    <small class="text-muted">
                                        <i class="fas fa-info-circle"></i> Primero selecciona un productor, luego busca el producto.
                                    </small>
                                    
                                    <!-- Mostrar producto seleccionado -->
                                    <div class="selected-display" id="selectedProductDisplay">
                                        <div class="selected-name" id="selectedProductName"></div>
                                        <div class="selected-details" id="selectedProductDetails"></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Sección 2: Detalles de la Orden -->
                        <div class="form-section">
                            <div class="form-section-title">
                                <i class="fas fa-shopping-cart"></i>
                                Detalles de la Orden
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="cantidad" class="form-label">Cantidad de Paquetes <span class="text-danger">*</span></label>
                                    <input type="number" 
                                           class="form-control" 
                                           id="cantidad" 
                                           name="cantidad" 
                                           min="1" 
                                           value="<%= cantidadPrevia %>" 
                                           required
                                           placeholder="Ej: 10">
                                    <small class="text-muted">
                                        <i class="fas fa-info-circle"></i> Cantidad de paquetes a solicitar
                                    </small>
                                </div>
                            </div>
                        </div>

                        <!-- Sección 3: Destino de la Orden -->
                        <div class="form-section">
                            <div class="form-section-title">
                                <i class="fas fa-map-marker-alt"></i>
                                Destino de la Orden
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="zonaBusqueda" class="form-label">Buscar Zona <span class="text-danger">*</span></label>
                                    <div class="autocomplete-container">
                                        <input type="text" 
                                               class="form-control form-control-autocomplete" 
                                               id="zonaBusqueda" 
                                               placeholder="Escribe el nombre de la zona (Norte, Sur, Este, Oeste)..." 
                                               autocomplete="off">
                                        <i class="fas fa-search input-icon"></i>
                                        <div class="autocomplete-results" id="autocompleteZonas"></div>
                                    </div>
                                    <small class="text-muted">
                                        <i class="fas fa-info-circle"></i> Escribe para buscar zonas. Los resultados aparecerán mientras escribes.
                                    </small>
                                    
                                    <!-- Mostrar zona seleccionada -->
                                    <div class="selected-display" id="selectedZonaDisplay">
                                        <div class="selected-name" id="selectedZonaName"></div>
                                    </div>
                                </div>
                                
                                <div class="col-md-6 mb-3">
                                    <label for="distritoBusqueda" class="form-label">Buscar Distrito (Destino) <span class="text-danger">*</span></label>
                                    <div class="autocomplete-container">
                                        <input type="text" 
                                               class="form-control form-control-autocomplete" 
                                               id="distritoBusqueda" 
                                               placeholder="Escribe el nombre del distrito..." 
                                               autocomplete="off"
                                               disabled>
                                        <i class="fas fa-search input-icon"></i>
                                        <div class="autocomplete-results" id="autocompleteDistritos"></div>
                                    </div>
                                    <small class="text-muted">
                                        <i class="fas fa-info-circle"></i> Escribe para buscar distritos. Los resultados aparecerán mientras escribes.
                                    </small>
                                    
                                    <!-- Mostrar distrito seleccionado -->
                                    <div class="selected-display" id="selectedDistritoDisplay">
                                        <div class="selected-name" id="selectedDistritoName"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Columna Derecha - Resumen -->
                    <div class="col-lg-4">
                        <div class="resumen-card">
                            <h5 class="text-center mb-4" style="color: #6F4E37;">
                                <i class="fas fa-calculator me-2"></i>Resumen de Orden
                            </h5>
                            
                            <div class="resumen-item">
                                <div class="resumen-label">Producto Seleccionado</div>
                                <div class="resumen-value" id="resumenProducto">-</div>
                            </div>

                            <div class="resumen-item">
                                <div class="resumen-label">Precio Unitario</div>
                                <div class="resumen-value" id="resumenPrecio">S/. 0.00</div>
                            </div>

                            <div class="resumen-item">
                                <div class="resumen-label">Cantidad de Paquetes</div>
                                <div class="resumen-value" id="resumenCantidad">0</div>
                            </div>

                            <div class="resumen-item">
                                <div class="resumen-label">Unidades Totales</div>
                                <div class="resumen-value" id="resumenUnidadesTotales" style="color: #6F4E37;">0 unidades</div>
                                <small class="text-muted" style="font-size: 0.75rem;">
                                    <i class="fas fa-info-circle"></i> Paquetes × Unidades por paquete
                                </small>
                            </div>

                            <div class="resumen-item">
                                <div class="resumen-label">Destino</div>
                                <div class="resumen-value" id="resumenDestino">-</div>
                            </div>

                            <div class="resumen-total">
                                <div class="resumen-total-label">MONTO TOTAL</div>
                                <div class="resumen-total-value" id="montoTotalDisplay">S/. 0.00</div>
                                <input type="hidden" name="monto_total" id="montoTotal" required>
                            </div>
                        </div>
                    </div>
                </div>

                <hr class="my-4">

                <div class="d-flex justify-content-end gap-2">
                    <a href="${pageContext.request.contextPath}/orden-compra" class="btn btn-secondary" style="background-color: #6c757d; border-color: #6c757d;">
                        <i class="fas fa-times me-2"></i>Cancelar
                    </a>
                    <button type="submit" class="btn" id="btnGuardar" disabled style="background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); border: none; color: white; font-weight: 600;">
                        <i class="fas fa-save me-2"></i>Guardar Orden de Compra
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Contexto de la aplicación
    const contextPath = '${pageContext.request.contextPath}';
    
    // Variables globales
    let precioProducto = 0;
    let nombreProducto = '';
    let codigoProducto = '';
    let unidadesPorPaquete = 0;
    let nombreZona = '';
    let nombreDistrito = '';
    let selectedIndexProductor = -1;
    let selectedIndexProducto = -1;
    let selectedIndexZona = -1;
    let selectedIndexDistrito = -1;
    let timeoutIdProductor = null;
    let timeoutIdProducto = null;
    let timeoutIdZona = null;
    let timeoutIdDistrito = null;

    // Referencias a elementos
    const productorBusquedaInput = document.getElementById('productorBusqueda');
    const productorIdHidden = document.getElementById('productor_id');
    const autocompleteProductores = document.getElementById('autocompleteProductores');
    const selectedProductorDisplay = document.getElementById('selectedProductorDisplay');
    
    const productoBusquedaInput = document.getElementById('productoBusqueda');
    const productoIdHidden = document.getElementById('producto_id');
    const autocompleteProductos = document.getElementById('autocompleteProductos');
    const selectedProductDisplay = document.getElementById('selectedProductDisplay');
    
    const zonaBusquedaInput = document.getElementById('zonaBusqueda');
    const zonaIdHidden = document.getElementById('zona_id');
    const autocompleteZonas = document.getElementById('autocompleteZonas');
    const selectedZonaDisplay = document.getElementById('selectedZonaDisplay');
    
    const distritoBusquedaInput = document.getElementById('distritoBusqueda');
    const distritoIdHidden = document.getElementById('distrito_id');
    const autocompleteDistritos = document.getElementById('autocompleteDistritos');
    const selectedDistritoDisplay = document.getElementById('selectedDistritoDisplay');
    
    const cantidadInput = document.getElementById('cantidad');
    const btnGuardar = document.getElementById('btnGuardar');

    // ========== AUTocompletado de Productores ==========
    productorBusquedaInput.addEventListener('input', function() {
        const query = this.value.trim();
        
        if (query.length < 2) {
            autocompleteProductores.classList.remove('show');
            return;
        }
        
        clearTimeout(timeoutIdProductor);
        timeoutIdProductor = setTimeout(() => {
            buscarProductores(query);
        }, 300);
    });

    productorBusquedaInput.addEventListener('keydown', function(e) {
        const items = autocompleteProductores.querySelectorAll('.autocomplete-item');
        
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            selectedIndexProductor = Math.min(selectedIndexProductor + 1, items.length - 1);
            updateSelectedItem(items, selectedIndexProductor);
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            selectedIndexProductor = Math.max(selectedIndexProductor - 1, -1);
            updateSelectedItem(items, selectedIndexProductor);
        } else if (e.key === 'Enter') {
            e.preventDefault();
            if (selectedIndexProductor >= 0 && items[selectedIndexProductor]) {
                items[selectedIndexProductor].click();
            }
        } else if (e.key === 'Escape') {
            autocompleteProductores.classList.remove('show');
            selectedIndexProductor = -1;
        }
    });

    // ========== AUTocompletado de Productos ==========
    productoBusquedaInput.addEventListener('input', function() {
        const query = this.value.trim();
        const productorId = productorIdHidden.value;
        
        if (!productorId) {
            autocompleteProductos.classList.remove('show');
            return;
        }
        
        if (query.length < 2) {
            autocompleteProductos.classList.remove('show');
            return;
        }
        
        clearTimeout(timeoutIdProducto);
        timeoutIdProducto = setTimeout(() => {
            buscarProductos(productorId, query);
        }, 300);
    });

    productoBusquedaInput.addEventListener('keydown', function(e) {
        const items = autocompleteProductos.querySelectorAll('.autocomplete-item');
        
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            selectedIndexProducto = Math.min(selectedIndexProducto + 1, items.length - 1);
            updateSelectedItem(items, selectedIndexProducto);
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            selectedIndexProducto = Math.max(selectedIndexProducto - 1, -1);
            updateSelectedItem(items, selectedIndexProducto);
        } else if (e.key === 'Enter') {
            e.preventDefault();
            if (selectedIndexProducto >= 0 && items[selectedIndexProducto]) {
                items[selectedIndexProducto].click();
            }
        } else if (e.key === 'Escape') {
            autocompleteProductos.classList.remove('show');
            selectedIndexProducto = -1;
        }
    });

    // ========== AUTocompletado de Zonas ==========
    zonaBusquedaInput.addEventListener('input', function() {
        const query = this.value.trim();
        
        if (query.length < 1) {
            autocompleteZonas.classList.remove('show');
            return;
        }
        
        clearTimeout(timeoutIdZona);
        timeoutIdZona = setTimeout(() => {
            buscarZonas(query);
        }, 300);
    });

    zonaBusquedaInput.addEventListener('keydown', function(e) {
        const items = autocompleteZonas.querySelectorAll('.autocomplete-item');
        
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            selectedIndexZona = Math.min(selectedIndexZona + 1, items.length - 1);
            updateSelectedItem(items, selectedIndexZona);
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            selectedIndexZona = Math.max(selectedIndexZona - 1, -1);
            updateSelectedItem(items, selectedIndexZona);
        } else if (e.key === 'Enter') {
            e.preventDefault();
            if (selectedIndexZona >= 0 && items[selectedIndexZona]) {
                items[selectedIndexZona].click();
            }
        } else if (e.key === 'Escape') {
            autocompleteZonas.classList.remove('show');
            selectedIndexZona = -1;
        }
    });

    // ========== AUTocompletado de Distritos ==========
    distritoBusquedaInput.addEventListener('input', function() {
        const query = this.value.trim();
        
        if (query.length < 2) {
            autocompleteDistritos.classList.remove('show');
            return;
        }
        
        clearTimeout(timeoutIdDistrito);
        timeoutIdDistrito = setTimeout(() => {
            buscarDistritos(query);
        }, 300);
    });

    distritoBusquedaInput.addEventListener('keydown', function(e) {
        const items = autocompleteDistritos.querySelectorAll('.autocomplete-item');
        
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            selectedIndexDistrito = Math.min(selectedIndexDistrito + 1, items.length - 1);
            updateSelectedItem(items, selectedIndexDistrito);
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            selectedIndexDistrito = Math.max(selectedIndexDistrito - 1, -1);
            updateSelectedItem(items, selectedIndexDistrito);
        } else if (e.key === 'Enter') {
            e.preventDefault();
            if (selectedIndexDistrito >= 0 && items[selectedIndexDistrito]) {
                items[selectedIndexDistrito].click();
            }
        } else if (e.key === 'Escape') {
            autocompleteDistritos.classList.remove('show');
            selectedIndexDistrito = -1;
        }
    });

    // Cerrar autocompletado al hacer click fuera
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.autocomplete-container')) {
            autocompleteProductores.classList.remove('show');
            autocompleteProductos.classList.remove('show');
            autocompleteZonas.classList.remove('show');
            autocompleteDistritos.classList.remove('show');
        }
    });

    // ========== Funciones de búsqueda ==========
    async function buscarProductores(busqueda) {
        try {
            const url = contextPath + '/orden-compra?action=buscarProductores&busqueda=' + encodeURIComponent(busqueda);
            const response = await fetch(url);
            
            if (!response.ok) {
                throw new Error('Error en la respuesta del servidor');
            }
            
            const productores = await response.json();
            
            if (productores.error) {
                autocompleteProductores.innerHTML = '<div class="autocomplete-item text-danger">' + escapeHtml(productores.error) + '</div>';
                autocompleteProductores.classList.add('show');
                return;
            }
            
            selectedIndexProductor = -1;
            
            if (productores.length === 0) {
                autocompleteProductores.innerHTML = '<div class="autocomplete-item">No se encontraron productores</div>';
                autocompleteProductores.classList.add('show');
                return;
            }
            
            autocompleteProductores.innerHTML = '';
            productores.forEach((productor, index) => {
                const item = document.createElement('div');
                item.className = 'autocomplete-item';
                item.dataset.index = index;
                
                const nombreDiv = document.createElement('div');
                nombreDiv.className = 'autocomplete-item-name';
                nombreDiv.textContent = productor.nombre;
                
                item.appendChild(nombreDiv);
                
                item.addEventListener('click', function() {
                    seleccionarProductor(productor);
                });
                
                autocompleteProductores.appendChild(item);
            });
            
            autocompleteProductores.classList.add('show');
        } catch (error) {
            console.error('Error al buscar productores:', error);
            autocompleteProductores.innerHTML = '<div class="autocomplete-item text-danger">Error al buscar productores</div>';
            autocompleteProductores.classList.add('show');
        }
    }

    async function buscarProductos(productorId, busqueda) {
        try {
            const url = contextPath + '/orden-compra?action=buscarProductos&productorId=' + productorId + '&busqueda=' + encodeURIComponent(busqueda);
            const response = await fetch(url);
            
            if (!response.ok) {
                throw new Error('Error en la respuesta del servidor');
            }
            
            const productos = await response.json();
            
            if (productos.error) {
                autocompleteProductos.innerHTML = '<div class="autocomplete-item text-danger">' + escapeHtml(productos.error) + '</div>';
                autocompleteProductos.classList.add('show');
                return;
            }
            
            selectedIndexProducto = -1;
            
            if (productos.length === 0) {
                autocompleteProductos.innerHTML = '<div class="autocomplete-item">No se encontraron productos</div>';
                autocompleteProductos.classList.add('show');
                return;
            }
            
            autocompleteProductos.innerHTML = '';
            productos.forEach((producto, index) => {
                const item = document.createElement('div');
                item.className = 'autocomplete-item';
                item.dataset.index = index;
                
                const nombreDiv = document.createElement('div');
                nombreDiv.className = 'autocomplete-item-name';
                nombreDiv.textContent = producto.nombre;
                
                const detailsDiv = document.createElement('div');
                detailsDiv.className = 'autocomplete-item-details';
                const sku = producto.codigo || 'N/A';
                const precio = producto.precio ? producto.precio.toFixed(2) : '0.00';
                const unidades = producto.unidades_por_paquete || 0;
                detailsDiv.innerHTML = 'SKU: ' + escapeHtml(sku) + ' | ' +
                    '<span class="autocomplete-item-price">S/. ' + precio + '</span> | ' +
                    unidades + ' unidades/paquete';
                
                item.appendChild(nombreDiv);
                item.appendChild(detailsDiv);
                
                item.addEventListener('click', function() {
                    seleccionarProducto(producto);
                });
                
                autocompleteProductos.appendChild(item);
            });
            
            autocompleteProductos.classList.add('show');
        } catch (error) {
            console.error('Error al buscar productos:', error);
            autocompleteProductos.innerHTML = '<div class="autocomplete-item text-danger">Error al buscar productos</div>';
            autocompleteProductos.classList.add('show');
        }
    }

    async function buscarZonas(busqueda) {
        try {
            const url = contextPath + '/orden-compra?action=buscarZonas&busqueda=' + encodeURIComponent(busqueda);
            const response = await fetch(url);
            
            if (!response.ok) {
                throw new Error('Error en la respuesta del servidor');
            }
            
            const zonas = await response.json();
            
            if (zonas.error) {
                autocompleteZonas.innerHTML = '<div class="autocomplete-item text-danger">' + escapeHtml(zonas.error) + '</div>';
                autocompleteZonas.classList.add('show');
                return;
            }
            
            selectedIndexZona = -1;
            
            if (zonas.length === 0) {
                autocompleteZonas.innerHTML = '<div class="autocomplete-item">No se encontraron zonas</div>';
                autocompleteZonas.classList.add('show');
                return;
            }
            
            autocompleteZonas.innerHTML = '';
            zonas.forEach((zona, index) => {
                const item = document.createElement('div');
                item.className = 'autocomplete-item';
                item.dataset.index = index;
                
                const nombreDiv = document.createElement('div');
                nombreDiv.className = 'autocomplete-item-name';
                nombreDiv.textContent = zona.nombre;
                
                item.appendChild(nombreDiv);
                
                item.addEventListener('click', function() {
                    seleccionarZona(zona);
                });
                
                autocompleteZonas.appendChild(item);
            });
            
            autocompleteZonas.classList.add('show');
        } catch (error) {
            console.error('Error al buscar zonas:', error);
            autocompleteZonas.innerHTML = '<div class="autocomplete-item text-danger">Error al buscar zonas</div>';
            autocompleteZonas.classList.add('show');
        }
    }

    async function buscarDistritos(busqueda) {
        try {
            const url = contextPath + '/orden-compra?action=buscarDistritos&busqueda=' + encodeURIComponent(busqueda);
            const response = await fetch(url);
            
            if (!response.ok) {
                throw new Error('Error en la respuesta del servidor');
            }
            
            const distritos = await response.json();
            
            if (distritos.error) {
                autocompleteDistritos.innerHTML = '<div class="autocomplete-item text-danger">' + escapeHtml(distritos.error) + '</div>';
                autocompleteDistritos.classList.add('show');
                return;
            }
            
            selectedIndexDistrito = -1;
            
            if (distritos.length === 0) {
                autocompleteDistritos.innerHTML = '<div class="autocomplete-item">No se encontraron distritos</div>';
                autocompleteDistritos.classList.add('show');
                return;
            }
            
            autocompleteDistritos.innerHTML = '';
            distritos.forEach((distrito, index) => {
                const item = document.createElement('div');
                item.className = 'autocomplete-item';
                item.dataset.index = index;
                
                const nombreDiv = document.createElement('div');
                nombreDiv.className = 'autocomplete-item-name';
                nombreDiv.textContent = distrito.nombre;
                
                item.appendChild(nombreDiv);
                
                item.addEventListener('click', function() {
                    seleccionarDistrito(distrito);
                });
                
                autocompleteDistritos.appendChild(item);
            });
            
            autocompleteDistritos.classList.add('show');
        } catch (error) {
            console.error('Error al buscar distritos:', error);
            autocompleteDistritos.innerHTML = '<div class="autocomplete-item text-danger">Error al buscar distritos</div>';
            autocompleteDistritos.classList.add('show');
        }
    }

    // ========== Funciones de selección ==========
    function seleccionarProductor(productor) {
        productorIdHidden.value = productor.id;
        productorBusquedaInput.value = productor.nombre;
        document.getElementById('selectedProductorName').textContent = productor.nombre;
        selectedProductorDisplay.classList.add('show');
        autocompleteProductores.classList.remove('show');
        
        // Habilitar búsqueda de productos
        productoBusquedaInput.disabled = false;
        productoBusquedaInput.placeholder = "Escribe el nombre o SKU del producto...";
        limpiarProducto();
    }

    function seleccionarProducto(producto) {
        productoIdHidden.value = producto.id;
        precioProducto = parseFloat(producto.precio) || 0;
        nombreProducto = producto.nombre;
        codigoProducto = producto.codigo || '';
        unidadesPorPaquete = parseInt(producto.unidades_por_paquete) || 1;
        
        productoBusquedaInput.value = producto.nombre;
        document.getElementById('selectedProductName').textContent = producto.nombre;
        document.getElementById('selectedProductDetails').innerHTML = 
            '<strong>SKU:</strong> ' + (codigoProducto || 'N/A') + ' | ' +
            '<strong>Precio:</strong> S/. ' + precioProducto.toFixed(2) + ' | ' +
            '<strong>Unidades/Paquete:</strong> ' + unidadesPorPaquete;
        selectedProductDisplay.classList.add('show');
        autocompleteProductos.classList.remove('show');
        
        document.getElementById('resumenProducto').textContent = nombreProducto;
        document.getElementById('resumenPrecio').textContent = 'S/. ' + precioProducto.toFixed(2);
        calcularTotal();
    }

    function seleccionarZona(zona) {
        zonaIdHidden.value = zona.id;
        nombreZona = zona.nombre;
        zonaBusquedaInput.value = zona.nombre;
        document.getElementById('selectedZonaName').textContent = zona.nombre;
        selectedZonaDisplay.classList.add('show');
        autocompleteZonas.classList.remove('show');
        
        // Habilitar búsqueda de distritos
        distritoBusquedaInput.disabled = false;
        distritoBusquedaInput.placeholder = "Escribe el nombre del distrito...";
        limpiarDistrito();
        actualizarResumenDestino();
    }

    function seleccionarDistrito(distrito) {
        distritoIdHidden.value = distrito.id;
        nombreDistrito = distrito.nombre;
        distritoBusquedaInput.value = distrito.nombre;
        document.getElementById('selectedDistritoName').textContent = distrito.nombre;
        selectedDistritoDisplay.classList.add('show');
        autocompleteDistritos.classList.remove('show');
        
        actualizarResumenDestino();
        validarFormulario();
    }

    // ========== Funciones auxiliares ==========
    function updateSelectedItem(items, selectedIndex) {
        items.forEach((item, index) => {
            if (index === selectedIndex) {
                item.classList.add('selected');
                item.scrollIntoView({ block: 'nearest' });
            } else {
                item.classList.remove('selected');
            }
        });
    }

    function limpiarProducto() {
        productoIdHidden.value = '';
        productoBusquedaInput.value = '';
        selectedProductDisplay.classList.remove('show');
        autocompleteProductos.classList.remove('show');
        precioProducto = 0;
        nombreProducto = '';
        codigoProducto = '';
        unidadesPorPaquete = 0;
        document.getElementById('resumenProducto').textContent = '-';
        document.getElementById('resumenPrecio').textContent = 'S/. 0.00';
        calcularTotal();
    }

    function limpiarDistrito() {
        distritoIdHidden.value = '';
        distritoBusquedaInput.value = '';
        selectedDistritoDisplay.classList.remove('show');
        autocompleteDistritos.classList.remove('show');
        nombreDistrito = '';
        actualizarResumenDestino();
    }

    function actualizarResumenDestino() {
        if (nombreZona && nombreDistrito) {
            document.getElementById('resumenDestino').textContent = nombreZona + ' - ' + nombreDistrito;
        } else if (nombreZona) {
            document.getElementById('resumenDestino').textContent = nombreZona;
        } else {
            document.getElementById('resumenDestino').textContent = '-';
        }
    }

    // Cuando cambia la cantidad
    cantidadInput.addEventListener('input', function() {
        const cantidad = parseInt(this.value) || 0;
        document.getElementById('resumenCantidad').textContent = cantidad;
        calcularTotal();
    });

    // Calcular monto total y unidades totales
    function calcularTotal() {
        const cantidad = parseInt(cantidadInput.value) || 0;
        const total = precioProducto * cantidad;
        const unidadesTotales = cantidad * unidadesPorPaquete;
        
        document.getElementById('montoTotalDisplay').textContent = 'S/. ' + total.toFixed(2);
        document.getElementById('montoTotal').value = total.toFixed(2);
        document.getElementById('resumenUnidadesTotales').textContent = unidadesTotales + ' unidades';
        
        validarFormulario();
    }

    // Validar formulario completo
    function validarFormulario() {
        const valido = productorIdHidden.value && 
                      productoIdHidden.value && 
                      cantidadInput.value > 0 && 
                      zonaIdHidden.value && 
                      distritoIdHidden.value;
        
        btnGuardar.disabled = !valido;
    }

    // Función para escapar HTML
    function escapeHtml(text) {
        if (text == null) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Validar al enviar el formulario
    document.getElementById('formOrdenCompra').addEventListener('submit', function(e) {
        const montoTotal = parseFloat(document.getElementById('montoTotal').value);
        
        if (isNaN(montoTotal) || montoTotal <= 0) {
            e.preventDefault();
            alert('El monto total debe ser mayor a cero');
            return false;
        }
        
        if (!productoIdHidden.value) {
            e.preventDefault();
            alert('Por favor seleccione un producto');
            return false;
        }
        
        if (!productorIdHidden.value) {
            e.preventDefault();
            alert('Por favor seleccione un productor');
            return false;
        }
        
        if (!zonaIdHidden.value || !distritoIdHidden.value) {
            e.preventDefault();
            alert('Por favor seleccione una zona y un distrito');
            return false;
        }
    });
</script>
</body>
</html>
