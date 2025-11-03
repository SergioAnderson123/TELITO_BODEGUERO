<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.PlanTransporteBean" %>
<%@ page import="com.example.telito.logistica.beans.ConductorBean" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Distribucion y Transporte"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='Distribucion'/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="row">
                <div class="col-12">
                    <div class="page-header mb-4 d-flex justify-content-between align-items-center">
                        <div>
                            <h2><i class="fas fa-truck me-2"></i>Planes de Transporte</h2>
                            <p class="text-muted mb-0">Seguimiento de entregas y análisis de rutas.</p>
                        </div>
                        <div class="d-flex gap-2">
                            <%
                                String busquedaParam = request.getParameter("busqueda");
                                String conductorParam = request.getParameter("conductor");
                                String estadoParam = request.getParameter("estado");
                                String fechaDesdeParam = request.getParameter("fecha_desde");
                                String fechaHastaParam = request.getParameter("fecha_hasta");
                                StringBuilder urlParams = new StringBuilder();
                                if (busquedaParam != null && !busquedaParam.trim().isEmpty()) {
                                    urlParams.append("&busqueda=").append(java.net.URLEncoder.encode(busquedaParam, "UTF-8"));
                                }
                                if (conductorParam != null && !conductorParam.trim().isEmpty()) {
                                    urlParams.append("&conductor=").append(java.net.URLEncoder.encode(conductorParam, "UTF-8"));
                                }
                                if (estadoParam != null && !estadoParam.trim().isEmpty()) {
                                    urlParams.append("&estado=").append(java.net.URLEncoder.encode(estadoParam, "UTF-8"));
                                }
                                if (fechaDesdeParam != null && !fechaDesdeParam.trim().isEmpty()) {
                                    urlParams.append("&fecha_desde=").append(java.net.URLEncoder.encode(fechaDesdeParam, "UTF-8"));
                                }
                                if (fechaHastaParam != null && !fechaHastaParam.trim().isEmpty()) {
                                    urlParams.append("&fecha_hasta=").append(java.net.URLEncoder.encode(fechaHastaParam, "UTF-8"));
                                }
                                String urlBase = request.getContextPath() + "/logistica/DistribucionTransporteReporteServlet?action=exportar" + urlParams.toString();
                                String urlEnviar = request.getContextPath() + "/logistica/DistribucionTransporteReporteServlet?action=formEnviar" + urlParams.toString();
                            %>
                            <a href="<%= urlBase %>" class="btn btn-sm btn-success">
                                <i class="fas fa-file-excel me-2"></i>Exportar a Excel
                            </a>
                            <a href="<%= urlEnviar %>" class="btn btn-sm btn-info text-white">
                                <i class="fas fa-envelope me-2"></i>Enviar por Correo
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Mensajes de alerta -->
            <c:if test="${not empty sessionScope.mensaje}">
                <div class="alert alert-${sessionScope.tipoMensaje} alert-dismissible fade show" role="alert">
                    ${sessionScope.mensaje}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="mensaje" scope="session"/>
                <c:remove var="tipoMensaje" scope="session"/>
            </c:if>

            <div class="card mb-4">
                <div class="card-body">
                    <form class="row g-3" method="GET" action="${pageContext.request.contextPath}/planes-transporte">
                        <div class="col-md-3">
                            <label for="busquedaTexto" class="form-label">Búsqueda Rápida</label>
                            <input type="text" class="form-control" id="busquedaTexto" name="busqueda" placeholder="N° Viaje, Placa, Lote..." value="${param.busqueda}">
                        </div>
                        <div class="col-md-3">
                            <label for="filtroConductor" class="form-label">Conductor</label>
                            <select id="filtroConductor" name="conductor" class="form-select">
                                <option value="" selected>Todos</option>
                                <% ArrayList<ConductorBean> listaConductores = (ArrayList<ConductorBean>) request.getAttribute("listaConductores");
                                    if(listaConductores != null){
                                        for(ConductorBean conductor : listaConductores){ %>
                                <option value="<%= conductor.getId() %>" ${param.conductor == conductor.getId() ? 'selected' : ''} >
                                    <%= conductor.getNombreCompleto() %>
                                </option>
                                <%  }
                                } %>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label for="filtroEstado" class="form-label">Estado</label>
                            <select id="filtroEstado" name="estado" class="form-select">
                                <option value="" ${param.estado == '' ? 'selected' : ''}>Todos</option>
                                <option value="Pendiente" ${param.estado == 'Pendiente' ? 'selected' : ''}>Pendiente</option>
                                <option value="Salida" ${param.estado == 'Salida' ? 'selected' : ''}>Salida</option>
                                <option value="En Ruta" ${param.estado == 'En Ruta' ? 'selected' : ''}>En Ruta</option>
                                <option value="Entregado" ${param.estado == 'Entregado' ? 'selected' : ''}>Entregado</option>
                                <option value="Cancelado" ${param.estado == 'Cancelado' ? 'selected' : ''}>Cancelado</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Fecha de Entrega</label>
                            <div class="input-group">
                                <input type="date" class="form-control" name="fecha_desde" value="${param.fecha_desde}">
                                <input type="date" class="form-control" name="fecha_hasta" value="${param.fecha_hasta}">
                            </div>
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
                                <%-- La tabla no cambia --%>
                                <table id="distribucionTable" class="table table-hover text-center">
                                    <thead>
                                    <tr>
                                        <th onclick="sortTable(0, 'distribucionTable')" style="cursor:pointer;">N° de Viaje</th>
                                        <th onclick="sortTable(1, 'distribucionTable')" style="cursor:pointer;">Producto</th>
                                        <th onclick="sortTable(2, 'distribucionTable')" style="cursor:pointer;">Lote</th>
                                        <th onclick="sortTable(3, 'distribucionTable')" style="cursor:pointer;">Estado</th>
                                        <th onclick="sortTable(4, 'distribucionTable')" style="cursor:pointer;">Conductor</th>
                                        <th onclick="sortTable(5, 'distribucionTable')" style="cursor:pointer;">Placa</th>
                                        <th onclick="sortTable(6, 'distribucionTable')" style="cursor:pointer;">Fecha de Entrega</th>
                                        <th onclick="sortTable(7, 'distribucionTable')" style="cursor:pointer;">Destino</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        ArrayList<PlanTransporteBean> listaPlanes = (ArrayList<PlanTransporteBean>) request.getAttribute("listaPlanes");
                                        if (listaPlanes != null && !listaPlanes.isEmpty()) {
                                            for (PlanTransporteBean plan : listaPlanes) {
                                    %>
                                    <tr>
                                        <td><%= plan.getNumeroViaje() %></td>
                                        <td><%= plan.getNombreProducto() %></td>
                                        <td><%= plan.getCodigoLote() %></td>
                                        <td>
                                            <% if ("Entregado".equals(plan.getEstado())) { %>
                                            <span class="badge bg-success"><%= plan.getEstado() %></span>
                                            <% } else if ("En Ruta".equals(plan.getEstado())) { %>
                                            <span class="badge bg-primary"><%= plan.getEstado() %></span>
                                            <% } else if ("Pendiente".equals(plan.getEstado())) { %>
                                            <span class="badge bg-warning text-dark"><%= plan.getEstado() %></span>
                                            <% } else if ("Salida".equals(plan.getEstado())) { %>
                                            <span class="badge bg-info"><%= plan.getEstado() %></span>
                                            <% } else if ("Cancelado".equals(plan.getEstado())) { %>
                                            <span class="badge bg-danger"><%= plan.getEstado() %></span>
                                            <% } else { %>
                                            <span class="badge bg-secondary"><%= plan.getEstado() %></span>
                                            <% } %>
                                        </td>
                                        <td><%= plan.getNombreConductor() %></td>
                                        <td><%= plan.getPlacaVehiculo() %></td>
                                        <td><%= plan.getFechaEntrega() %></td>
                                        <td><%= plan.getNombreDestino() %></td>
                                    </tr>
                                    <%
                                        }
                                    } else {
                                    %>
                                    <tr>
                                        <td colspan="8" class="text-center text-muted">
                                            <i class="fas fa-road fa-2x mb-2"></i><br>
                                            No se encontraron resultados para los filtros seleccionados.
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                    </tbody>
                                </table>
                            </div>

                            <%-- Incluir componente de paginación --%>
                            <%
                                request.setAttribute("param1Name", "busqueda");
                                request.setAttribute("param1Value", request.getParameter("busqueda"));
                                request.setAttribute("param2Name", "conductor");
                                request.setAttribute("param2Value", request.getParameter("conductor"));
                                request.setAttribute("param3Name", "estado");
                                request.setAttribute("param3Value", request.getParameter("estado"));
                            %>
                            <jsp:include page="/WEB-INF/includes/pagination.jsp" />

                            <div class="mt-3">
                                <a href="${pageContext.request.contextPath}/planes-transporte?action=crear" class="btn btn-primary">
                                    <i class="fas fa-plus me-2"></i>Generar Plan Transporte
                                </a>
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
    let currentPage = 1, rowsPerPage = 9, allRows = [], filteredRows = [], sortDirections = Array(8).fill(true);
    document.addEventListener('DOMContentLoaded', function(){initializePagination();});
    function initializePagination(){const table=document.getElementById('distribucionTable');const tbody=table.getElementsByTagName('tbody')[0];allRows=Array.from(tbody.rows);filteredRows=allRows.filter(row=>{return !row.cells[0].hasAttribute('colspan');});totalRows=filteredRows.length;currentPage=1;displayPage(currentPage);updatePaginationControls();}
    function displayPage(page){const table=document.getElementById('distribucionTable');const tbody=table.getElementsByTagName('tbody')[0];tbody.innerHTML='';if(filteredRows.length===0){const noDataRow=document.createElement('tr');noDataRow.innerHTML=`<td colspan="8" class="text-center text-muted"><i class="fas fa-road fa-2x mb-2"></i><br>No se encontraron resultados.</td>`;tbody.appendChild(noDataRow);updatePaginationInfo(0,0,0);return;}const startIndex=(page-1)*rowsPerPage;const endIndex=Math.min(startIndex+rowsPerPage,filteredRows.length);for(let i=startIndex;i<endIndex;i++){tbody.appendChild(filteredRows[i].cloneNode(true));}updatePaginationInfo(startIndex+1,endIndex,filteredRows.length);}
    function updatePaginationInfo(start,end,total){const paginationInfo=document.getElementById('paginationInfo');if(total===0){paginationInfo.textContent='No hay registros para mostrar';}else{paginationInfo.textContent=`Mostrando ${start}-${end} de ${total} registros`;}}
    function updatePaginationControls(){const totalPages=Math.ceil(filteredRows.length/rowsPerPage);const paginationControls=document.getElementById('paginationControls');if(totalPages<=1){paginationControls.style.display='none';return;}paginationControls.style.display='flex';paginationControls.innerHTML='';const prevLi=document.createElement('li');prevLi.className=currentPage===1?'page-item disabled':'page-item';prevLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); changePage('prev')" tabindex="-1"><i class="fas fa-chevron-left"></i></a>`;paginationControls.appendChild(prevLi);const startPage=Math.max(1,currentPage-2);const endPage=Math.min(totalPages,currentPage+2);if(startPage>1){const firstLi=document.createElement('li');firstLi.className='page-item';firstLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); goToPage(1)">1</a>`;paginationControls.appendChild(firstLi);if(startPage>2){const dotsLi=document.createElement('li');dotsLi.className='page-item disabled';dotsLi.innerHTML=`<span class="page-link">...</span>`;paginationControls.appendChild(dotsLi);}}for(let i=startPage;i<=endPage;i++){const pageLi=document.createElement('li');pageLi.className=i===currentPage?'page-item active':'page-item';pageLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); goToPage(${i})">${i}</a>`;paginationControls.appendChild(pageLi);}if(endPage<totalPages){if(endPage<totalPages-1){const dotsLi=document.createElement('li');dotsLi.className='page-item disabled';dotsLi.innerHTML=`<span class="page-link">...</span>`;paginationControls.appendChild(dotsLi);}const lastLi=document.createElement('li');lastLi.className='page-item';lastLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); goToPage(${totalPages})">${totalPages}</a>`;paginationControls.appendChild(lastLi);}const nextLi=document.createElement('li');nextLi.className=currentPage===totalPages?'page-item disabled':'page-item';nextLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); changePage('next')"><i class="fas fa-chevron-right"></i></a>`;paginationControls.appendChild(nextLi);}
    function goToPage(page){const totalPages=Math.ceil(filteredRows.length/rowsPerPage);if(page<1||page>totalPages)return;currentPage=page;displayPage(currentPage);updatePaginationControls();}
    function changePage(direction){const totalPages=Math.ceil(filteredRows.length/rowsPerPage);if(direction==='prev'&&currentPage>1){goToPage(currentPage-1);}else if(direction==='next'&&currentPage<totalPages){goToPage(currentPage+1);}}
    function sortTable(n,tableId){if(filteredRows.length===0)return;const dir=sortDirections[n]?'asc':'desc';sortDirections[n]=!sortDirections[n];filteredRows.sort(function(a,b){let x=a.getElementsByTagName("TD")[n].textContent||a.getElementsByTagName("TD")[n].innerText;let y=b.getElementsByTagName("TD")[n].textContent||b.getElementsByTagName("TD")[n].innerText;if(n===6){let xParts=x.split('/');let yParts=y.split('/');if(xParts.length===3&&yParts.length===3){let xDate=new Date(xParts[2],xParts[1]-1,xParts[0]);let yDate=new Date(yParts[2],yParts[1]-1,yParts[0]);x=xDate.getTime();y=yDate.getTime();}}else{x=x.toLowerCase();y=y.toLowerCase();}if(dir==="asc"){if(x<y)return -1;if(x>y)return 1;return 0;}else{if(x>y)return -1;if(x<y)return 1;return 0;}});currentPage=1;displayPage(currentPage);updatePaginationControls();const table=document.getElementById(tableId);let ths=table.getElementsByTagName('th');for(let j=0;j<ths.length;j++){ths[j].classList.remove('active');}ths[n].classList.add('active');}
</script>
</body>
</html>