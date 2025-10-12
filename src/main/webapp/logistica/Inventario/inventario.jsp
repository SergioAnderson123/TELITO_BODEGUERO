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
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Gestión de Inventario - Sistema de Logística</title>
    <meta name="description" content="Sistema de gestión logística - Gestión de Inventario">
    <link rel="icon" type="image/x-icon" href="assets/images/favicon.ico">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/logistica/assets/style.css">
</head>
<body>
<div class="dashboard-main-wrapper">
    <div class="dashboard-header">
        <nav class="navbar navbar-expand-lg bg-white fixed-top dashboard-nav">
            <div class="container-fluid">
                <a class="navbar-brand concept-brand" href="#"><strong>Concept</strong></a>
                <div class="navbar-nav ms-auto" style="margin-right: 20px;"></div>
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
                        <a class="nav-link" href="${pageContext.request.contextPath}/MovimientoProductoServlet">
                            <i class="fas fa-fw fa-exchange-alt"></i>Movimiento de Productos
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/InventarioServlet">
                            <i class="fas fa-fw fa-warehouse"></i>Gestión de Inventario
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#">
                            <i class="fas fa-fw fa-file-invoice-dollar"></i>Orden de Compra
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/planes-transporte">
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
                        <h1 class="pageheader-title">Gestión de Inventario</h1>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="table-responsive">
                                <table id="inventoryTable" class="table table-hover text-center">
                                    <%-- ======================================================= --%>
                                    <%-- SECCIÓN DE LA TABLA CORREGIDA --%>
                                    <%-- ======================================================= --%>
                                    <thead>
                                    <tr>
                                        <%-- CABECERAS CORREGIDAS PARA COINCIDIR CON LA CONSULTA --%>
                                        <th onclick="sortTable(0, 'inventoryTable')" style="cursor:pointer">SKU</th>
                                        <th onclick="sortTable(1, 'inventoryTable')" style="cursor:pointer">Producto</th>
                                        <th onclick="sortTable(2, 'inventoryTable')" style="cursor:pointer">Cant. Lotes</th>
                                        <th onclick="sortTable(3, 'inventoryTable')" style="cursor:pointer">Códigos de Lote</th>
                                        <th onclick="sortTable(4, 'inventoryTable')" style="cursor:pointer">Próximo Vencimiento</th>
                                        <th onclick="sortTable(5, 'inventoryTable')" style="cursor:pointer">Estado</th>
                                        <th onclick="sortTable(6, 'inventoryTable')" style="cursor:pointer">Stock Total</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        ArrayList<InventarioBean> listaInventario = (ArrayList<InventarioBean>) request.getAttribute("listaInventario");
                                        if (listaInventario != null && !listaInventario.isEmpty()) {
                                            for (InventarioBean inventario : listaInventario) {
                                    %>
                                    <tr>
                                        <%-- DATOS CORREGIDOS PARA USAR LOS MÉTODOS CORRECTOS DEL BEAN --%>
                                        <td><%= inventario.getSku() %></td>
                                        <td><%= inventario.getNombreProducto() %></td>
                                        <td><%= inventario.getCantidadLotes() %></td>
                                        <td><%= inventario.getCodigosDeLote() %></td>
                                        <td><%= inventario.getProximoVencimiento() != null ? inventario.getProximoVencimiento() : "N/A" %></td>
                                        <td>
                                            <% if ("En stock".equals(inventario.getEstadoStock())) { %>
                                            <span class="badge bg-success"><%= inventario.getEstadoStock() %></span>
                                            <% } else { %>
                                            <span class="badge bg-danger"><%= inventario.getEstadoStock() %></span>
                                            <% } %>
                                        </td>
                                        <td><%= inventario.getStockTotal() %></td>
                                    </tr>
                                    <%
                                        }
                                    } else {
                                    %>
                                    <tr>
                                        <td colspan="7" class="text-center text-muted">
                                            <i class="fas fa-box-open fa-2x mb-2"></i><br>
                                            No hay inventario disponible para mostrar.
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                    </tbody>
                                    <%-- ======================================================= --%>
                                    <%-- FIN DE LA SECCIÓN CORREGIDA --%>
                                    <%-- ======================================================= --%>
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
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let currentPage = 1, rowsPerPage = 9, allRows = [], filteredRows = [], sortDirections = Array(7).fill(true);
    document.addEventListener('DOMContentLoaded', function(){initializePagination();});
    function initializePagination(){const table=document.getElementById('inventoryTable');const tbody=table.getElementsByTagName('tbody')[0];allRows=Array.from(tbody.rows);filteredRows=allRows.filter(row=>{return !row.cells[0].hasAttribute('colspan');});totalRows=filteredRows.length;currentPage=1;displayPage(currentPage);updatePaginationControls();}
    function displayPage(page){const table=document.getElementById('inventoryTable');const tbody=table.getElementsByTagName('tbody')[0];tbody.innerHTML='';if(filteredRows.length===0){const noDataRow=document.createElement('tr');noDataRow.innerHTML=`<td colspan="7" class="text-center text-muted"><i class="fas fa-box-open fa-2x mb-2"></i><br>No hay inventario disponible para mostrar.</td>`;tbody.appendChild(noDataRow);updatePaginationInfo(0,0,0);return;}const startIndex=(page-1)*rowsPerPage;const endIndex=Math.min(startIndex+rowsPerPage,filteredRows.length);for(let i=startIndex;i<endIndex;i++){tbody.appendChild(filteredRows[i].cloneNode(true));}updatePaginationInfo(startIndex+1,endIndex,filteredRows.length);}
    function updatePaginationInfo(start,end,total){const paginationInfo=document.getElementById('paginationInfo');if(total===0){paginationInfo.textContent='No hay registros para mostrar';}else{paginationInfo.textContent=`Mostrando ${start}-${end} de ${total} registros`;}}
    function updatePaginationControls(){const totalPages=Math.ceil(filteredRows.length/rowsPerPage);const paginationControls=document.getElementById('paginationControls');if(totalPages<=1){paginationControls.style.display='none';return;}paginationControls.style.display='flex';paginationControls.innerHTML='';const prevLi=document.createElement('li');prevLi.className=currentPage===1?'page-item disabled':'page-item';prevLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); changePage('prev')" tabindex="-1"><i class="fas fa-chevron-left"></i></a>`;paginationControls.appendChild(prevLi);const startPage=Math.max(1,currentPage-2);const endPage=Math.min(totalPages,currentPage+2);if(startPage>1){const firstLi=document.createElement('li');firstLi.className='page-item';firstLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); goToPage(1)">1</a>`;paginationControls.appendChild(firstLi);if(startPage>2){const dotsLi=document.createElement('li');dotsLi.className='page-item disabled';dotsLi.innerHTML=`<span class="page-link">...</span>`;paginationControls.appendChild(dotsLi);}}for(let i=startPage;i<=endPage;i++){const pageLi=document.createElement('li');pageLi.className=i===currentPage?'page-item active':'page-item';pageLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); goToPage(${i})">${i}</a>`;paginationControls.appendChild(pageLi);}if(endPage<totalPages){if(endPage<totalPages-1){const dotsLi=document.createElement('li');dotsLi.className='page-item disabled';dotsLi.innerHTML=`<span class="page-link">...</span>`;paginationControls.appendChild(dotsLi);}const lastLi=document.createElement('li');lastLi.className='page-item';lastLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); goToPage(${totalPages})">${totalPages}</a>`;paginationControls.appendChild(lastLi);}const nextLi=document.createElement('li');nextLi.className=currentPage===totalPages?'page-item disabled':'page-item';nextLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); changePage('next')"><i class="fas fa-chevron-right"></i></a>`;paginationControls.appendChild(nextLi);}
    function goToPage(page){const totalPages=Math.ceil(filteredRows.length/rowsPerPage);if(page<1||page>totalPages)return;currentPage=page;displayPage(currentPage);updatePaginationControls();}
    function changePage(direction){const totalPages=Math.ceil(filteredRows.length/rowsPerPage);if(direction==='prev'&&currentPage>1){goToPage(currentPage-1);}else if(direction==='next'&&currentPage<totalPages){goToPage(currentPage+1);}}
    function sortTable(n,tableId){if(filteredRows.length===0)return;const dir=sortDirections[n]?'asc':'desc';sortDirections[n]=!sortDirections[n];filteredRows.sort(function(a,b){let x=a.getElementsByTagName("TD")[n].textContent||a.getElementsByTagName("TD")[n].innerText;let y=b.getElementsByTagName("TD")[n].textContent||b.getElementsByTagName("TD")[n].innerText;const numberColumns=[2,6];const dateColumns=[4];if(dateColumns.includes(n)){let xParts=x.trim().split('/');let yParts=y.trim().split('/');if(xParts.length===3&&yParts.length===3){x=new Date(xParts[2],xParts[1]-1,xParts[0]);}else{x=new Date(0);}if(yParts.length===3&&yParts.length===3){y=new Date(yParts[2],yParts[1]-1,yParts[0]);}else{y=new Date(0);}}else if(numberColumns.includes(n)){x=parseInt(x.trim().replace(/,/g,''))||0;y=parseInt(y.trim().replace(/,/g,''))||0;}else{x=x.toLowerCase();y=y.toLowerCase();}if(dir==="asc"){if(x<y)return -1;if(x>y)return 1;return 0;}else{if(x>y)return -1;if(x<y)return 1;return 0;}});currentPage=1;displayPage(currentPage);updatePaginationControls();const table=document.getElementById(tableId);let ths=table.getElementsByTagName('th');for(let j=0;j<ths.length;j++){ths[j].classList.remove('active');}ths[n].classList.add('active');}
</script>
<style>
    body{background-color:#efeff6;}.dashboard-main-wrapper{display:flex;min-height:100vh;background-color:#efeff6;}.nav-left-sidebar{width:260px;position:fixed;top:60px;left:0;z-index:1000;background-color:#0e0c28 !important;margin-top:0;padding-top:0;height:calc(100vh - 60px);box-shadow:0 0 28px 0 rgba(82,63,105,0.08);}.dashboard-wrapper{margin-left:260px;width:calc(100% - 260px);background-color:#efeff6;min-height:100vh;}.dashboard-header{position:fixed;top:0;left:260px;right:0;z-index:999;height:60px;}.dashboard-content{padding-top:80px;min-height:calc(100vh - 60px);padding-left:20px;padding-right:20px;background-color:#efeff6;}.menu-list{height:100%;overflow-y:auto;padding-top:20px;scrollbar-width:thin;scrollbar-color:rgba(255,255,255,0.1) transparent;}.menu-list::-webkit-scrollbar{width:5px;}.menu-list::-webkit-scrollbar-thumb{background-color:rgba(255,255,255,0.1);border-radius:10px;}.nav-left-sidebar .navbar{padding:0;}.nav-left-sidebar .navbar-nav{width:100%;}.nav-left-sidebar .nav-link{padding:12px 30px !important;font-size:0.875rem;font-weight:400;display:flex;align-items:center;transition:all 0.2s ease;border-left:3px solid transparent;text-decoration:none;border-radius:0;margin:0;font-family:'Circular Std',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;}.nav-left-sidebar .nav-link i{width:20px;margin-right:10px;font-size:1rem;text-align:left;}.nav-left-sidebar .nav-link:hover{background-color:rgba(255,255,255,0.08) !important;color:#ffffff !important;text-decoration:none;}.nav-left-sidebar .nav-link.active{background-color:rgba(255,255,255,0.08) !important;color:#ffffff !important;border-left-color:#007bff;font-weight:500;}.nav-divider{padding:20px 30px 10px;color:rgba(255,255,255,0.5) !important;font-size:0.75rem;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;list-style:none;font-family:'Circular Std',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif;}.dashboard-nav{box-shadow:0 1px 3px rgba(0,0,0,0.1);border-bottom:1px solid #e5e5e5;background-color:#ffffff !important;height:60px;padding:0;}.navbar-brand{font-weight:700;font-size:1.2rem;color:#2c3e50 !important;text-decoration:none;font-family:'Circular Std',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;}.navbar-brand:hover{color:#2c3e50 !important;text-decoration:none;}.concept-brand{position:absolute;left:20px;top:50%;transform:translateY(-50%);z-index:1001;margin:0 !important;}.page-header{margin-bottom:30px;}.pageheader-title{font-size:24px;font-weight:700;color:#3d405c;margin-bottom:10px;font-family:'Circular Std',-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;}.card{border:none;box-shadow:0 2px 10px rgba(0,0,0,0.1);border-radius:10px;}.card-header{background-color:#f8f9fa;border-bottom:1px solid #dee2e6;font-weight:600;border-radius:10px 10px 0 0 !important;}.table{margin-bottom:0;}.table thead th{border-bottom:2px solid #dee2e6;font-weight:600;color:#495057;background-color:#f8f9fa;padding:15px 12px;}.table tbody tr:hover{background-color:#f8f9fa;}.table td{padding:12px;vertical-align:middle;}.badge{padding:6px 12px;font-size:12px;font-weight:500;}.footer{background-color:#f8f9fa;padding:20px 0;margin-top:40px;border-top:1px solid #dee2e6;}.footer-links a{color:#6c757d;text-decoration:none;margin-left:15px;}.footer-links a:hover{color:#007bff;}.sort-icon{display:inline-block;margin-left:4px;vertical-align:middle;}.triangle-up,.triangle-down{display:block;width:0;height:0;border-left:5px solid transparent;border-right:5px solid transparent;margin:0 auto;}.triangle-up{border-bottom:7px solid #888;margin-bottom:4px;}.triangle-down{border-top:7px solid #888;margin-top:4px;}th.active .triangle-up{border-bottom:7px solid #0E0C28;}th.active .triangle-down{border-top:7px solid #0E0C28;}th:hover .sort-icon{transform:scale(1.2);transition:transform 0.2s;}@media (max-width:768px){.nav-left-sidebar{transform:translateX(-100%);transition:transform 0.3s ease;}.dashboard-wrapper{margin-left:0;width:100%;}.dashboard-header{left:0;}}.loading{display:flex;justify-content:center;align-items:center;height:200px;}.fade-in{animation:fadeIn 0.5s ease-in;}@keyframes fadeIn{from{opacity:0;}to{opacity:1;}}.text-muted{color:#6c757d !important;}.text-muted i{color:#adb5bd !important;}.pagination-info{font-size:0.875rem;color:#6c757d;}.pagination{margin-bottom:0;}.pagination .page-link{color:#495057;background-color:#fff;border:1px solid #dee2e6;padding:0.375rem 0.75rem;font-size:0.875rem;border-radius:0.25rem;transition:all 0.2s ease;}.pagination .page-link:hover{color:#0e0c28;background-color:#f8f9fa;border-color:#dee2e6;text-decoration:none;}.pagination .page-item.active .page-link{color:#fff;background-color:#0e0c28;border-color:#0e0c28;font-weight:500;}.pagination .page-item.disabled .page-link{color:#adb5bd;background-color:#fff;border-color:#dee2e6;cursor:not-allowed;}.pagination .page-item:first-child .page-link{border-top-left-radius:0.375rem;border-bottom-left-radius:0.375rem;}.pagination .page-item:last-child .page-link{border-top-right-radius:0.375rem;border-bottom-right-radius:0.375rem;}@media (max-width:576px){.pagination-info{font-size:0.75rem;margin-bottom:0.5rem;}.d-flex.justify-content-between{flex-direction:column;align-items:flex-start !important;}.pagination{align-self:center;margin-top:0.5rem;}}
</style>
</body>
</html>