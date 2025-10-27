<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.OrdenCompraBean" %>
<%@ page import="com.example.telito.logistica.beans.ProveedorBean" %>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Orden de Compra"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='OrdenCompra'/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="row">
                <div class="col-12">
                    <div class="page-header"><h2><i class="fas fa-file-invoice-dollar me-2"></i>Orden de Compra</h2></div>
                </div>
            </div>

            <div class="card mb-4">
                <div class="card-body">
                    <%-- Título Eliminado --%>
                    <form class="row g-3" method="GET" action="${pageContext.request.contextPath}/orden-compra">

                        <div class="col-md-5">
                            <label for="busquedaTexto" class="form-label">Buscar por N° Orden / Producto</label>
                            <input type="text" class="form-control" id="busquedaTexto" name="busqueda" placeholder="Ej: OC001, Aceite..." value="${param.busqueda}">
                        </div>

                        <div class="col-md-4">
                            <label for="filtroProveedor" class="form-label">Proveedor</label>
                            <select id="filtroProveedor" name="proveedor" class="form-select">
                                <option value="" selected>Todos</option>
                                <% ArrayList<ProveedorBean> listaProveedores = (ArrayList<ProveedorBean>) request.getAttribute("listaProveedores");
                                    if(listaProveedores != null){
                                        for(ProveedorBean proveedor : listaProveedores){ %>
                                <option value="<%= proveedor.getId() %>" ${param.proveedor == proveedor.getId() ? 'selected' : ''} >
                                    <%= proveedor.getNombre() %>
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
                                <option value="Aprobado" ${param.estado == 'Aprobado' ? 'selected' : ''}>Aprobado</option>
                                <option value="Rechazado" ${param.estado == 'Rechazado' ? 'selected' : ''}>Rechazado</option>
                                <option value="Recibido" ${param.estado == 'Recibido' ? 'selected' : ''}>Recibido</option>
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
                                <table id="purchaseTable" class="table table-hover text-center">
                                    <thead>
                                    <tr>
                                        <th onclick="sortTable(0, 'purchaseTable')" style="cursor:pointer">N° de Orden</th>
                                        <th onclick="sortTable(1, 'purchaseTable')" style="cursor:pointer">Proveedor</th>
                                        <th onclick="sortTable(2, 'purchaseTable')" style="cursor:pointer">Producto</th>
                                        <th onclick="sortTable(3, 'purchaseTable')" style="cursor:pointer">Cantidad</th>
                                        <th onclick="sortTable(4, 'purchaseTable')" style="cursor:pointer">Personal Responsable</th>
                                        <th onclick="sortTable(5, 'purchaseTable')" style="cursor:pointer">Estado</th>
                                        <th onclick="sortTable(6, 'purchaseTable')" style="cursor:pointer">Monto</th>
                                        <th>Acciones</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        ArrayList<OrdenCompraBean> listaOrdenes = (ArrayList<OrdenCompraBean>) request.getAttribute("listaOrdenes");
                                        if (listaOrdenes != null && !listaOrdenes.isEmpty()) {
                                            for (OrdenCompraBean orden : listaOrdenes) {
                                    %>
                                    <tr>
                                        <td><%= orden.getNumeroOrden() %></td>
                                        <td><%= orden.getNombreProveedor() %></td>
                                        <td><%= orden.getNombreProducto() %></td>
                                        <td><%= orden.getCantidadPaquetes() %> paquetes</td>
                                        <td><%= orden.getPersonalResponsable() %></td>
                                        <td>
                                            <% if ("Pendiente".equals(orden.getEstado())) { %>
                                            <span class="badge bg-warning text-dark"><%= orden.getEstado() %></span>
                                            <% } else if ("Aprobado".equals(orden.getEstado())) { %>
                                            <span class="badge bg-success"><%= orden.getEstado() %></span>
                                            <% } else if ("Rechazado".equals(orden.getEstado())) { %>
                                            <span class="badge bg-danger"><%= orden.getEstado() %></span>
                                            <% } else if ("Recibido".equals(orden.getEstado())) { %>
                                            <span class="badge bg-info text-white"><%= orden.getEstado() %></span>
                                            <% } else { %>
                                            <span class="badge bg-secondary"><%= orden.getEstado() %></span>
                                            <% } %>
                                        </td>
                                        <td><%= orden.getMontoTotal() %></td>
                                        <td>
                                            <% if ("Recibido".equals(orden.getEstado())) { %>
                                            <button class="btn btn-sm btn-primary" onclick="editarOrden('<%= orden.getNumeroOrden() %>')">
                                                <i class="fas fa-edit"></i> Editar
                                            </button>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    } else {
                                    %>
                                    <tr>
                                        <td colspan="8" class="text-center text-muted">
                                            <i class="fas fa-file-invoice fa-2x mb-2"></i><br>
                                            No hay órdenes de compra para mostrar.
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
                                <nav aria-label="Paginación de órdenes">
                                    <ul class="pagination pagination-sm mb-0" id="paginationControls"></ul>
                                </nav>
                            </div>

                            <div class="mt-3">
                                <a href="${pageContext.request.contextPath}/orden-compra?action=crear" class="btn btn-dark">
                                    <i class="fas fa-plus me-2"></i>Generar Orden
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

<!-- Modal: Ver Detalles de Orden Recibida -->
<div class="modal fade" id="detalleOrdenModal" tabindex="-1" aria-labelledby="detalleOrdenModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white;">
                <h5 class="modal-title" id="detalleOrdenModalLabel">
                    <i class="fas fa-box-open me-2"></i>Detalles de Orden Recibida
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div id="loadingDetalle" class="text-center py-5">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Cargando...</span>
                    </div>
                    <p class="mt-3 text-muted">Cargando detalles de la orden...</p>
                </div>
                <div id="detalleOrdenContainer" style="display: none;">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i>
                        <strong>Orden:</strong> <span id="detalleNumeroOrden"></span>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Productor:</label>
                            <p id="detalleProductor" class="form-control-plaintext">-</p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Personal Responsable:</label>
                            <p id="detallePersonalResponsable" class="form-control-plaintext">-</p>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Producto:</label>
                            <p id="detalleProducto" class="form-control-plaintext">-</p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">SKU:</label>
                            <p id="detalleSKU" class="form-control-plaintext"><span class="badge bg-secondary">-</span></p>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Cantidad Solicitada:</label>
                            <p id="detalleCantidad" class="form-control-plaintext">-</p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Monto Total:</label>
                            <p id="detalleMontoTotal" class="form-control-plaintext">-</p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Estado:</label>
                            <p id="detalleEstado" class="form-control-plaintext"><span class="badge">-</span></p>
                        </div>
                    </div>
                    
                    <hr>
                    
                    <h6 class="mb-3"><i class="fas fa-boxes me-2"></i>Lote Asignado por el Productor</h6>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Código de Lote:</label>
                            <p id="detalleCodigoLote" class="form-control-plaintext"><strong>-</strong></p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Fecha de Vencimiento:</label>
                            <p id="detalleFechaVencimiento" class="form-control-plaintext">-</p>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Stock Disponible:</label>
                            <p id="detalleStockDisponible" class="form-control-plaintext">-</p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Ubicación:</label>
                            <p id="detalleUbicacion" class="form-control-plaintext">-</p>
                        </div>
                    </div>
                </div>
                <div id="errorDetalle" class="alert alert-warning" style="display: none;">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    No se pudieron cargar los detalles de la orden.
                </div>
            </div>
            <div class="modal-footer d-flex justify-content-between">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="fas fa-arrow-left me-2"></i>Volver
                </button>
                <div>
                    <button type="button" class="btn btn-danger me-2" id="btnRechazar" onclick="cambiarEstadoOrden('Rechazado')">
                        <i class="fas fa-times-circle me-2"></i>Rechazar
                    </button>
                    <button type="button" class="btn btn-success" id="btnAprobar" onclick="cambiarEstadoOrden('Aprobado')">
                        <i class="fas fa-check-circle me-2"></i>Aprobar
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let currentPage = 1, rowsPerPage = 9, allRows = [], filteredRows = [], sortDirections = Array(7).fill(true);
    document.addEventListener('DOMContentLoaded', function(){initializePagination();});
    function initializePagination(){const table=document.getElementById('purchaseTable');const tbody=table.getElementsByTagName('tbody')[0];allRows=Array.from(tbody.rows);filteredRows=allRows.filter(row=>{return !row.cells[0].hasAttribute('colspan');});totalRows=filteredRows.length;currentPage=1;displayPage(currentPage);updatePaginationControls();}
    function displayPage(page){const table=document.getElementById('purchaseTable');const tbody=table.getElementsByTagName('tbody')[0];tbody.innerHTML='';if(filteredRows.length===0){const noDataRow=document.createElement('tr');noDataRow.innerHTML=`<td colspan="8" class="text-center text-muted"><i class="fas fa-file-invoice fa-2x mb-2"></i><br>No hay órdenes de compra para mostrar.</td>`;tbody.appendChild(noDataRow);updatePaginationInfo(0,0,0);return;}const startIndex=(page-1)*rowsPerPage;const endIndex=Math.min(startIndex+rowsPerPage,filteredRows.length);for(let i=startIndex;i<endIndex;i++){tbody.appendChild(filteredRows[i].cloneNode(true));}updatePaginationInfo(startIndex+1,endIndex,filteredRows.length);}
    function updatePaginationInfo(start,end,total){const paginationInfo=document.getElementById('paginationInfo');if(total===0){paginationInfo.textContent='No hay registros para mostrar';}else{paginationInfo.textContent=`Mostrando ${start}-${end} de ${total} registros`;}}
    function updatePaginationControls(){const totalPages=Math.ceil(filteredRows.length/rowsPerPage);const paginationControls=document.getElementById('paginationControls');if(totalPages<=1){paginationControls.style.display='none';return;}paginationControls.style.display='flex';paginationControls.innerHTML='';const prevLi=document.createElement('li');prevLi.className=currentPage===1?'page-item disabled':'page-item';prevLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); changePage('prev')" tabindex="-1"><i class="fas fa-chevron-left"></i></a>`;paginationControls.appendChild(prevLi);const startPage=Math.max(1,currentPage-2);const endPage=Math.min(totalPages,currentPage+2);if(startPage>1){const firstLi=document.createElement('li');firstLi.className='page-item';firstLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); goToPage(1)">1</a>`;paginationControls.appendChild(firstLi);if(startPage>2){const dotsLi=document.createElement('li');dotsLi.className='page-item disabled';dotsLi.innerHTML=`<span class="page-link">...</span>`;paginationControls.appendChild(dotsLi);}}for(let i=startPage;i<=endPage;i++){const pageLi=document.createElement('li');pageLi.className=i===currentPage?'page-item active':'page-item';pageLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); goToPage(${i})">${i}</a>`;paginationControls.appendChild(pageLi);}if(endPage<totalPages){if(endPage<totalPages-1){const dotsLi=document.createElement('li');dotsLi.className='page-item disabled';dotsLi.innerHTML=`<span class="page-link">...</span>`;paginationControls.appendChild(dotsLi);}const lastLi=document.createElement('li');lastLi.className='page-item';lastLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); goToPage(${totalPages})">${totalPages}</a>`;paginationControls.appendChild(lastLi);}const nextLi=document.createElement('li');nextLi.className=currentPage===totalPages?'page-item disabled':'page-item';nextLi.innerHTML=`<a class="page-link" href="#" onclick="event.preventDefault(); changePage('next')"><i class="fas fa-chevron-right"></i></a>`;paginationControls.appendChild(nextLi);}
    function goToPage(page){const totalPages=Math.ceil(filteredRows.length/rowsPerPage);if(page<1||page>totalPages)return;currentPage=page;displayPage(currentPage);updatePaginationControls();}
    function changePage(direction){const totalPages=Math.ceil(filteredRows.length/rowsPerPage);if(direction==='prev'&&currentPage>1){goToPage(currentPage-1);}else if(direction==='next'&&currentPage<totalPages){goToPage(currentPage+1);}}
    function sortTable(n,tableId){if(filteredRows.length===0)return;const dir=sortDirections[n]?'asc':'desc';sortDirections[n]=!sortDirections[n];filteredRows.sort(function(a,b){let x=a.getElementsByTagName("TD")[n].textContent||a.getElementsByTagName("TD")[n].innerText;let y=b.getElementsByTagName("TD")[n].textContent||b.getElementsByTagName("TD")[n].innerText;if(n===6){x=x.replace(/S\/\.\s?|,/g,"");y=y.replace(/S\/\.\s?|,/g,"");x=parseFloat(x)||0;y=parseFloat(y)||0;}else{x=x.toLowerCase();y=y.toLowerCase();}if(dir==="asc"){if(x<y)return -1;if(x>y)return 1;return 0;}else{if(x>y)return -1;if(x<y)return 1;return 0;}});currentPage=1;displayPage(currentPage);updatePaginationControls();const table=document.getElementById(tableId);let ths=table.getElementsByTagName('th');for(let j=0;j<ths.length;j++){ths[j].classList.remove('active');}ths[n].classList.add('active');}
    
    // Función para ver detalles de orden recibida
    function editarOrden(numeroOrden) {
        console.log('Abriendo detalles de orden:', numeroOrden);
        
        // Mostrar loading y ocultar contenido
        document.getElementById('loadingDetalle').style.display = 'block';
        document.getElementById('detalleOrdenContainer').style.display = 'none';
        document.getElementById('errorDetalle').style.display = 'none';
        
        // Abrir el modal
        const modal = new bootstrap.Modal(document.getElementById('detalleOrdenModal'));
        modal.show();
        
        // Extraer el número de orden (ej: "OC005" -> 5)
        const idOrden = numeroOrden.replace(/\D/g, '');
        ordenActualId = idOrden; // Guardar en variable global
        console.log('ID Orden extraído:', idOrden);
        
        // Habilitar botones al abrir el modal
        document.getElementById('btnAprobar').disabled = false;
        document.getElementById('btnRechazar').disabled = false;
        
        // Cargar los detalles de la orden vía AJAX
        fetch('${pageContext.request.contextPath}/orden-compra?action=obtenerDetalle&idOrden=' + idOrden)
            .then(response => response.json())
            .then(data => {
                console.log('Datos recibidos:', data);
                
                document.getElementById('loadingDetalle').style.display = 'none';
                
                if (data.success) {
                    // Llenar los campos del modal con los datos
                    document.getElementById('detalleNumeroOrden').textContent = numeroOrden;
                    document.getElementById('detalleProductor').textContent = data.productor || '-';
                    document.getElementById('detallePersonalResponsable').textContent = data.personalResponsable || '-';
                    document.getElementById('detalleProducto').textContent = data.producto || '-';
                    document.getElementById('detalleSKU').innerHTML = '<span class="badge bg-secondary">' + (data.sku || '-') + '</span>';
                    document.getElementById('detalleCantidad').textContent = (data.cantidad || '-') + ' paquetes';
                    document.getElementById('detalleMontoTotal').textContent = data.montoTotal || '-';
                    
                    // Badge de estado
                    let estadoBadge = '<span class="badge bg-info">' + (data.estado || '-') + '</span>';
                    document.getElementById('detalleEstado').innerHTML = estadoBadge;
                    
                    // Datos del lote
                    document.getElementById('detalleCodigoLote').innerHTML = '<strong>' + (data.codigoLote || '-') + '</strong>';
                    document.getElementById('detalleFechaVencimiento').textContent = data.fechaVencimiento || 'Sin fecha';
                    document.getElementById('detalleStockDisponible').textContent = (data.stockDisponible || '0') + ' unidades';
                    document.getElementById('detalleUbicacion').textContent = data.ubicacion || '-';
                    
                    document.getElementById('detalleOrdenContainer').style.display = 'block';
                } else {
                    document.getElementById('errorDetalle').style.display = 'block';
                }
            })
            .catch(error => {
                console.error('Error al cargar detalles:', error);
                document.getElementById('loadingDetalle').style.display = 'none';
                document.getElementById('errorDetalle').style.display = 'block';
            });
    }
    
    // Variable global para guardar el ID de la orden actual
    let ordenActualId = null;
    
    // Función para cambiar el estado de la orden (Aprobar o Rechazar)
    function cambiarEstadoOrden(nuevoEstado) {
        if (!ordenActualId) {
            alert('Error: No se ha seleccionado ninguna orden');
            return;
        }
        
        const mensajeConfirm = nuevoEstado === 'Aprobado' 
            ? '¿Está seguro de APROBAR esta orden?' 
            : '¿Está seguro de RECHAZAR esta orden?';
        
        if (!confirm(mensajeConfirm)) {
            return;
        }
        
        console.log('Cambiando estado a:', nuevoEstado, 'para orden:', ordenActualId);
        
        // Deshabilitar botones
        document.getElementById('btnAprobar').disabled = true;
        document.getElementById('btnRechazar').disabled = true;
        
        // Hacer petición para cambiar el estado
        fetch('${pageContext.request.contextPath}/orden-compra', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'action=cambiarEstado&idOrden=' + ordenActualId + '&nuevoEstado=' + encodeURIComponent(nuevoEstado)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('✓ Orden ' + (nuevoEstado === 'Aprobado' ? 'aprobada' : 'rechazada') + ' exitosamente');
                // Cerrar el modal
                bootstrap.Modal.getInstance(document.getElementById('detalleOrdenModal')).hide();
                // Recargar la página para ver los cambios
                location.reload();
            } else {
                alert('Error: ' + (data.message || 'No se pudo cambiar el estado'));
                document.getElementById('btnAprobar').disabled = false;
                document.getElementById('btnRechazar').disabled = false;
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error de conexión al cambiar el estado');
            document.getElementById('btnAprobar').disabled = false;
            document.getElementById('btnRechazar').disabled = false;
        });
    }
</script>
</body>
</html>