<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.MovimientoInventarioBean" %>

<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Movimiento de Producto - Sistema de Logística</title>
    <meta name="description" content="Sistema de gestión logística - Movimiento de Productos">

    <link rel="icon" type="image/x-icon" href="assets/images/favicon.ico">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
<div class="dashboard-main-wrapper">
    <div class="dashboard-header">
        <nav class="navbar navbar-expand-lg bg-white fixed-top dashboard-nav">
            <div class="container-fluid">
                <a class="navbar-brand concept-brand" href="#">
                    <strong>Concept</strong>
                </a>
            </div>
        </nav>
    </div>

    <div class="nav-left-sidebar sidebar-dark">
        <div class="menu-list">
            <nav class="navbar navbar-expand navbar-light">
                <ul class="navbar-nav flex-column w-100">
                    <li class="nav-divider">Menu</li>
                    <li class="my-2"></li>

                    <li class="nav-item">
                        <a class="nav-link ${currentPage == 'movimientos' ? 'active' : ''}" href="${pageContext.request.contextPath}/MovimientoProductoServlet">
                            <i class="fas fa-fw fa-exchange-alt"></i>Movimiento de Productos
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${currentPage == 'inventario' ? 'active' : ''}" href="${pageContext.request.contextPath}/InventarioServlet">
                            <i class="fas fa-fw fa-warehouse"></i>Gestión de Inventario
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${currentPage == 'orden-compra' ? 'active' : ''}" href="${pageContext.request.contextPath}/orden-compra">
                            <i class="fas fa-fw fa-file-invoice-dollar"></i>Orden de Compra
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#">
                            <i class="fas fa-fw fa-truck"></i>Distribución y Transporte
                        </a>
                    </li>
                    <li class="my-5"></li>
                </ul>
            </nav>
        </div>
    </div>

    <div class="dashboard-wrapper">
        <div class="container-fluid dashboard-content">
            <div class="row">
                <div class="col-12">
                    <div class="page-header">
                        <h1 class="pageheader-title">Movimiento de Producto</h1>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="table-responsive">
                                <table id="movementTable" class="table table-hover text-center">
                                    <thead>
                                    <tr>
                                        <th onclick="sortTable(0)" style="cursor:pointer">Fecha</th>
                                        <th onclick="sortTable(1)" style="cursor:pointer">Producto</th>
                                        <th onclick="sortTable(2)" style="cursor:pointer">Tipo</th>
                                        <th onclick="sortTable(3)" style="cursor:pointer">Destino</th>
                                        <th onclick="sortTable(4)" style="cursor:pointer">Lote</th>
                                        <th onclick="sortTable(5)" style="cursor:pointer">Personal Responsable</th>
                                        <th onclick="sortTable(6)" style="cursor:pointer">Observaciones</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        ArrayList<MovimientoInventarioBean> listaMovimientos =
                                                (ArrayList<MovimientoInventarioBean>) request.getAttribute("listaMovimientos");

                                        if (listaMovimientos != null && !listaMovimientos.isEmpty()) {
                                            for (MovimientoInventarioBean movimiento : listaMovimientos) {
                                    %>
                                    <tr>
                                        <td><%= movimiento.getFechaFormateada() %></td>
                                        <td><%= movimiento.getNombreProducto() %></td>
                                        <td>
                                            <% if ("Entrada".equalsIgnoreCase(movimiento.getTipo())) { %>
                                            <span class="badge bg-success"><%= movimiento.getTipo() %></span>
                                            <% } else if ("Salida".equalsIgnoreCase(movimiento.getTipo())) { %>
                                            <span class="badge bg-danger"><%= movimiento.getTipo() %></span>
                                            <% } else { %>
                                            <span class="badge bg-warning text-dark"><%= movimiento.getTipo() %></span>
                                            <% } %>
                                        </td>
                                        <td><%= movimiento.getDestino() %></td>
                                        <td><%= movimiento.getCodigoLote() %></td>
                                        <td><%= movimiento.getResponsable() %></td>
                                        <td><%= movimiento.getObservaciones() %></td>
                                    </tr>
                                    <%
                                        }
                                    } else {
                                    %>
                                    <tr>
                                        <td colspan="7" class="text-center text-muted">
                                            <i class="fas fa-inbox fa-2x mb-2"></i><br>
                                            No hay movimientos disponibles para mostrar.
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                    </tbody>
                                </table>
                            </div>

                            <div class="d-flex justify-content-between align-items-center mt-3">
                                <div class="pagination-info">
                                    <span id="paginationInfo" class="text-muted"></span>
                                </div>
                                <nav aria-label="Paginación de movimientos">
                                    <ul class="pagination pagination-sm mb-0" id="paginationControls">
                                    </ul>
                                </nav>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="footer">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
                        Copyright © 2025. Todos los derechos reservados.
                    </div>
                    <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
                        <div class="text-md-right footer-links d-none d-sm-block">
                            <a href="javascript: void(0);">Acerca</a>
                            <a href="javascript: void(0);">Soporte</a>
                            <a href="javascript: void(0);">Contacto</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Variables de paginación
    let currentPage = 1;
    const rowsPerPage = 9;
    let filteredRows = [];
    let sortDirections = Array(7).fill(true);

    document.addEventListener('DOMContentLoaded', function() {
        initializePagination();
    });

    function initializePagination() {
        const table = document.getElementById('movementTable');
        const tbody = table.tBodies[0];
        if (!tbody) return;
        const allRows = Array.from(tbody.rows);

        filteredRows = allRows.filter(row => !row.cells[0].hasAttribute('colspan'));

        currentPage = 1;
        displayPage(currentPage);
        updatePaginationControls();
    }

    function displayPage(page) {
        const table = document.getElementById('movementTable');
        const tbody = table.tBodies[0];
        tbody.innerHTML = '';

        if (filteredRows.length === 0) {
            const noDataRow = document.createElement('tr');
            noDataRow.innerHTML = `<td colspan="7" class="text-center text-muted"><i class="fas fa-inbox fa-2x mb-2"></i><br>No hay movimientos disponibles para mostrar.</td>`;
            tbody.appendChild(noDataRow);
            updatePaginationInfo(0, 0, 0);
            updatePaginationControls();
            return;
        }

        const startIndex = (page - 1) * rowsPerPage;
        const endIndex = Math.min(startIndex + rowsPerPage, filteredRows.length);

        for (let i = startIndex; i < endIndex; i++) {
            tbody.appendChild(filteredRows[i]);
        }
        updatePaginationInfo(startIndex + 1, endIndex, filteredRows.length);
    }

    function updatePaginationInfo(start, end, total) {
        const paginationInfo = document.getElementById('paginationInfo');
        paginationInfo.textContent = total > 0 ? `Mostrando ${start}-${end} de ${total} registros` : 'No hay registros';
    }

    function updatePaginationControls() {
        const totalPages = Math.ceil(filteredRows.length / rowsPerPage);
        const paginationControls = document.getElementById('paginationControls');
        paginationControls.innerHTML = '';

        if (totalPages <= 1) {
            paginationControls.style.display = 'none';
            return;
        }
        paginationControls.style.display = 'flex';

        // Prev Button - SINTAXIS CORREGIDA
        paginationControls.innerHTML += `<li class="page-item ${currentPage == 1 ? 'disabled' : ''}"><a class="page-link" href="#" onclick="changePage('prev')"><i class="fas fa-chevron-left"></i></a></li>`;

        // Page Numbers - SINTAXIS CORREGIDA
        for (let i = 1; i <= totalPages; i++) {
            paginationControls.innerHTML += `<li class="page-item ${i == currentPage ? 'active' : ''}"><a class="page-link" href="#" onclick="goToPage(${i})">${i}</a></li>`;
        }

        // Next Button - SINTAXIS CORREGIDA
        paginationControls.innerHTML += `<li class="page-item ${currentPage == totalPages ? 'disabled' : ''}"><a class="page-link" href="#" onclick="changePage('next')"><i class="fas fa-chevron-right"></i></a></li>`;
    }

    function goToPage(page) {
        currentPage = page;
        displayPage(currentPage);
        updatePaginationControls();
    }

    function changePage(direction) {
        const totalPages = Math.ceil(filteredRows.length / rowsPerPage);
        if (direction === 'prev' && currentPage > 1) {
            goToPage(currentPage - 1);
        } else if (direction === 'next' && currentPage < totalPages) {
            goToPage(currentPage + 1);
        }
    }

    function sortTable(n) {
        if (filteredRows.length === 0) return;

        const dir = sortDirections[n] ? 'asc' : 'desc';
        sortDirections.fill(true);
        sortDirections[n] = !dir;

        filteredRows.sort((a, b) => {
            let x = a.cells[n].innerText;
            let y = b.cells[n].innerText;

            if (n === 0) { // Lógica para ordenar por fecha en la columna 0
                let xParts = x.split('/');
                let yParts = y.split('/');
                let xDate = new Date(xParts[2], xParts[1] - 1, xParts[0]);
                let yDate = new Date(yParts[2], yParts[1] - 1, yParts[0]);
                return dir === 'asc' ? xDate - yDate : yDate - xDate;
            }

            return dir === 'asc' ? x.localeCompare(y) : y.localeCompare(x);
        });

        goToPage(1);
    }
</script>

<style>
    body { background-color: #efeff6; }
    .dashboard-main-wrapper { display: flex; min-height: 100vh; }
    .nav-left-sidebar { width: 260px; position: fixed; top: 60px; left: 0; z-index: 1000; background-color: #0e0c28 !important; height: calc(100vh - 60px); box-shadow: 0 0 28px 0 rgba(82, 63, 105, 0.08); }
    .dashboard-wrapper { margin-left: 260px; width: calc(100% - 260px); min-height: 100vh; }
    .dashboard-header { position: fixed; top: 0; left: 260px; right: 0; z-index: 999; height: 60px; }
    .dashboard-content { padding-top: 80px; min-height: calc(100vh - 60px); padding-left: 20px; padding-right: 20px; }
    .menu-list { height: 100%; overflow-y: auto; padding-top: 20px; }
    .nav-left-sidebar .navbar { padding: 0; }
    .nav-left-sidebar .navbar-nav { width: 100%; }
    .nav-left-sidebar .nav-link { padding: 12px 30px !important; color: #8287a0 !important; font-size: 0.875rem; display: flex; align-items: center; transition: all 0.2s ease; border-left: 3px solid transparent; text-decoration: none; }
    .nav-left-sidebar .nav-link i { width: 20px; margin-right: 10px; font-size: 1rem; text-align: left; }
    .nav-left-sidebar .nav-link:hover { background-color: rgba(255, 255, 255, 0.08) !important; color: #ffffff !important; }
    .nav-left-sidebar .nav-link.active { background-color: rgba(255, 255, 255, 0.08) !important; color: #ffffff !important; border-left-color: #007bff; font-weight: 500; }
    .nav-divider { padding: 20px 30px 10px; color: rgba(255, 255, 255, 0.5) !important; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; list-style: none; }
    .dashboard-nav { box-shadow: 0 1px 3px rgba(0,0,0,0.1); border-bottom: 1px solid #e5e5e5; background-color: #ffffff !important; height: 60px; padding: 0; }
    .navbar-brand { font-weight: 700; font-size: 1.2rem; color: #2c3e50 !important; text-decoration: none; }
    .concept-brand { position: absolute; left: 20px; top: 50%; transform: translateY(-50%); z-index: 1001; margin: 0 !important; }
    .page-header { margin-bottom: 30px; }
    .pageheader-title { font-size: 24px; font-weight: 700; color: #3d405c; }
    .card { border: none; box-shadow: 0 2px 10px rgba(0,0,0,0.1); border-radius: 10px; }
    .table thead th { border-bottom: 2px solid #dee2e6; font-weight: 600; color: #495057; background-color: #f8f9fa; }
    .table tbody tr:hover { background-color: #f8f9fa; }
    .table td, .table th { padding: 12px; vertical-align: middle; }
    .badge { padding: 6px 12px; font-size: 12px; font-weight: 500; }
    .footer { background-color: #f8f9fa; padding: 20px 0; margin-top: 40px; border-top: 1px solid #e5e5e6; }
    .text-muted { color: #6c757d !important; }

    /* Estilos de Paginación */
    .pagination-info { font-size: 0.875rem; color: #6c757d; }
    .pagination { margin-bottom: 0; }
    .pagination .page-link { color: #495057; background-color: #fff; border: 1px solid #dee2e6; transition: all 0.2s ease; }
    .pagination .page-link:hover { color: #0e0c28; background-color: #f8f9fa; }
    .pagination .page-item.active .page-link { z-index: 3; color: #fff; background-color: #0e0c28; border-color: #0e0c28; }
    .pagination .page-item.disabled .page-link { color: #adb5bd; }
</style>
</body>
</html>