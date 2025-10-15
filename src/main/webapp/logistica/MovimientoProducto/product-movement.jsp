<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.MovimientoInventarioBean" %>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Movimiento de Producto"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='Movimiento'/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="row">
                <div class="col-12">
                    <div class="page-header"><h2><i class="fas fa-exchange-alt me-2"></i>Movimiento de Producto</h2></div>
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
        <jsp:include page="/logistica/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
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
</body>
</html>