<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.InventarioBean" %>

<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    boolean soloLectura = false;
    if (usuario != null && usuario.getRol().getNombre().equals("ADMINISTRADOR")) {
        soloLectura = true; // El administrador accede en modo solo lectura
    }
%>
<!doctype html>
<html lang="es">


<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestion de Inventario"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='Inventario'/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="row">
                <div class="col-12">
                    <div class="page-header"><h2><i class="fas fa-warehouse me-2"></i>Gestion de Inventario</h2></div>
                </div>
            </div>

            <div class="card mb-4">
                <div class="card-body">
                    <form class="row g-3" method="GET" action="${pageContext.request.contextPath}/InventarioServlet">

                        <div class="col-md-8">
                            <label for="busquedaTexto" class="form-label">Buscar por SKU / Producto</label>
                            <input type="text" class="form-control" id="busquedaTexto" name="busqueda" placeholder="Ej: SKU001, Coca Cola..." value="${param.busqueda}">
                        </div>

                        <div class="col-md-3">
                            <label for="filtroEstado" class="form-label">Estado de Stock</label>
                            <select id="filtroEstado" name="estado" class="form-select">
                                <option value="" ${param.estado == '' ? 'selected' : ''}>Todos</option>
                                <option value="En stock" ${param.estado == 'En stock' ? 'selected' : ''}>En stock</option>
                                <option value="Poco stock" ${param.estado == 'Poco stock' ? 'selected' : ''}>Poco stock</option>
                                <option value="Sin stock" ${param.estado == 'Sin stock' ? 'selected' : ''}>Sin stock</option>
                            </select>
                        </div>

                        <div class="col-md-1 d-flex align-items-end">
                            <button type="submit" class="btn btn-primary w-100">Buscar</button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="table-responsive">
                                <table id="inventoryTable" class="table table-hover text-center">
                                    <thead class="bg-light">
                                    <tr>
                                        <th scope="col">SKU</th>
                                        <th scope="col">Nombre Producto</th>
                                        <th scope="col">Cantidad Disponible</th>
                                        <th scope="col">Precio por Paquete</th>
                                        <th scope="col">Costo por Unidad</th>
                                        <th scope="col">Estado</th>
                                    </tr>
                                    </thead>
                                    <tbody id="productTableBody">
                                    <%
                                        ArrayList<InventarioBean> listaInventario = (ArrayList<InventarioBean>) request.getAttribute("listaInventario");
                                        if (listaInventario != null && !listaInventario.isEmpty()) {
                                            for (InventarioBean inventario : listaInventario) {
                                    %>
                                    <tr>
                                        <td><span class="badge bg-secondary"><%= inventario.getCodigoSKU() %></span></td>
                                        <td><%= inventario.getNombreProducto() %></td>
                                        <td><%= inventario.getPaquetesDisponibles() %> paquetes</td>
                                        <td>S/. <%= String.format("%.2f", inventario.getPrecioPorPaquete()) %></td>
                                        <td>S/. <%= String.format("%.2f", inventario.getCostoPorUnidad()) %></td>
                                        <td>
                                            <% 
                                                String estadoStock = inventario.getEstadoStock();
                                                if ("Sin Stock".equals(estadoStock)) { 
                                            %>
                                                <span class="badge bg-danger">Sin Stock</span>
                                            <% } else if ("Poco Stock".equals(estadoStock)) { %>
                                                <span class="badge bg-warning text-dark">Poco Stock</span>
                                            <% } else if ("En Stock".equals(estadoStock)) { %>
                                                <span class="badge bg-success">En Stock</span>
                                            <% } else { %>
                                                <span class="badge bg-secondary">No configurado</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    } else {
                                    %>
                                    <tr>
                                        <td colspan="6" class="text-center text-muted">
                                            <i class="fas fa-box-open fa-2x mb-2"></i><br>
                                            No hay inventario disponible para mostrar.
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
                                <nav aria-label="Paginación de inventario">
                                    <ul class="pagination pagination-sm mb-0" id="paginationControls"></ul>
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
        <jsp:include page="/logistica/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let currentPage = 1, rowsPerPage = 9, allRows = [], filteredRows = [], sortDirections = Array(6).fill(true);
    document.addEventListener('DOMContentLoaded', function(){initializePagination();});
    function initializePagination(){const table=document.getElementById('inventoryTable');const tbody=table.getElementsByTagName('tbody')[0];allRows=Array.from(tbody.rows);filteredRows=allRows.filter(row=>{return !row.cells[0].hasAttribute('colspan');});totalRows=filteredRows.length;currentPage=1;displayPage(currentPage);updatePaginationControls();}
    function displayPage(page){const table=document.getElementById('inventoryTable');const tbody=table.getElementsByTagName('tbody')[0];tbody.innerHTML='';if(filteredRows.length===0){const noDataRow=document.createElement('tr');noDataRow.innerHTML=`<td colspan="6" class="text-center text-muted"><i class="fas fa-box-open fa-2x mb-2"></i><br>No hay inventario disponible para mostrar.</td>`;tbody.appendChild(noDataRow);updatePaginationInfo(0,0,0);return;}const startIndex=(page-1)*rowsPerPage;const endIndex=Math.min(startIndex+rowsPerPage,filteredRows.length);for(let i=startIndex;i<endIndex;i++){tbody.appendChild(filteredRows[i].cloneNode(true));}updatePaginationInfo(startIndex+1,endIndex,filteredRows.length);}
    function updatePaginationInfo(start,end,total){const paginationInfo=document.getElementById('paginationInfo');if(total===0){paginationInfo.textContent='No hay registros para mostrar';}else{paginationInfo.textContent=`Mostrando ${start}-${end} de ${total} registros`;}}
    function updatePaginationControls(){const totalPages=Math.ceil(filteredRows.length/rowsPerPage);const paginationControls=document.getElementById('paginationControls');if(totalPages<=1){paginationControls.style.display='none';return;}paginationControls.style.display='flex';paginationControls.innerHTML='';const prevLi=document.createElement('li');prevLi.className=currentPage===1?'page-item disabled':'page-item';prevLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); changePage('prev')" tabindex="-1"><i class="fas fa-chevron-left"></i></a>`;paginationControls.appendChild(prevLi);const startPage=Math.max(1,currentPage-2);const endPage=Math.min(totalPages,currentPage+2);if(startPage>1){const firstLi=document.createElement('li');firstLi.className='page-item';firstLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); goToPage(1)">1</a>`;paginationControls.appendChild(firstLi);if(startPage>2){const dotsLi=document.createElement('li');dotsLi.className='page-item disabled';dotsLi.innerHTML=`<span class="page-link">...</span>`;paginationControls.appendChild(dotsLi);}}for(let i=startPage;i<=endPage;i++){const pageLi=document.createElement('li');pageLi.className=i===currentPage?'page-item active':'page-item';pageLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); goToPage(${i})">${i}</a>`;paginationControls.appendChild(pageLi);}if(endPage<totalPages){if(endPage<totalPages-1){const dotsLi=document.createElement('li');dotsLi.className='page-item disabled';dotsLi.innerHTML=`<span class="page-link">...</span>`;paginationControls.appendChild(dotsLi);}const lastLi=document.createElement('li');lastLi.className='page-item';lastLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); goToPage(${totalPages})">${totalPages}</a>`;paginationControls.appendChild(lastLi);}const nextLi=document.createElement('li');nextLi.className=currentPage===totalPages?'page-item disabled':'page-item';nextLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); changePage('next')"><i class="fas fa-chevron-right"></i></a>`;paginationControls.appendChild(nextLi);}
    function goToPage(page){const totalPages=Math.ceil(filteredRows.length/rowsPerPage);if(page<1||page>totalPages)return;currentPage=page;displayPage(currentPage);updatePaginationControls();}
    function changePage(direction){const totalPages=Math.ceil(filteredRows.length/rowsPerPage);if(direction==='prev'&&currentPage>1){goToPage(currentPage-1);}else if(direction==='next'&&currentPage<totalPages){goToPage(currentPage+1);}}
    function sortTable(n,tableId){if(filteredRows.length===0)return;const dir=sortDirections[n]?'asc':'desc';sortDirections[n]=!sortDirections[n];filteredRows.sort(function(a,b){let x=a.getElementsByTagName("TD")[n].textContent||a.getElementsByTagName("TD")[n].innerText;let y=b.getElementsByTagName("TD")[n].textContent||b.getElementsByTagName("TD")[n].innerText;const numberColumns=[2];const priceColumns=[3,4];if(priceColumns.includes(n)){x=parseFloat(x.trim().replace('S/.','').replace(/,/g,''))||0;y=parseFloat(y.trim().replace('S/.','').replace(/,/g,''))||0;}else if(numberColumns.includes(n)){x=parseInt(x.trim().replace(/,/g,'').replace(' paquetes',''))||0;y=parseInt(y.trim().replace(/,/g,'').replace(' paquetes',''))||0;}else{x=x.toLowerCase();y=y.toLowerCase();}if(dir==="asc"){if(x<y)return -1;if(x>y)return 1;return 0;}else{if(x>y)return -1;if(x<y)return 1;return 0;}});currentPage=1;displayPage(currentPage);updatePaginationControls();const table=document.getElementById(tableId);let ths=table.getElementsByTagName('th');for(let j=0;j<ths.length;j++){ths[j].classList.remove('active');}ths[n].classList.add('active');}
</script>
</body>
</html>