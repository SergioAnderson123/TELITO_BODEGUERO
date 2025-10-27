<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.ProductoBean" %>
<%@ page import="com.example.telito.logistica.beans.ProveedorBean" %>
<%@ page import="com.example.telito.logistica.beans.ZonaBean" %>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Generar Orden de Compra"/>
    </jsp:include>
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
                    <div class="page-header"><h2><i class="fas fa-file-invoice-dollar me-2"></i>Generar Nueva Orden de Compra</h2></div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-10 col-md-12 mx-auto">
                    <div class="card">
                        <div class="card-body">
                            <form method="POST" action="${pageContext.request.contextPath}/orden-compra" id="formOrdenCompra">
                                <input type="hidden" name="action" value="guardar">

                                <div class="row">
                                    <!-- Columna Izquierda -->
                                    <div class="col-md-7">
                                        <!-- Productor/Proveedor -->
                                        <div class="mb-3">
                                            <label for="productor" class="form-label">Productor <span class="text-danger">*</span></label>
                                            <select class="form-select" id="productor" name="productor_id" required>
                                                <option value="" selected disabled>Seleccione un productor...</option>
                                                <% ArrayList<ProveedorBean> listaProductores = (ArrayList<ProveedorBean>) request.getAttribute("listaProductores");
                                                    if (listaProductores != null) {
                                                        for (ProveedorBean productor : listaProductores) { %>
                                                <option value="<%= productor.getId() %>"><%= productor.getNombre() %></option>
                                                <%     }
                                                } %>
                                            </select>
                                        </div>

                                        <!-- Producto -->
                                        <div class="mb-3">
                                            <label for="producto" class="form-label">Producto <span class="text-danger">*</span></label>
                                            <select class="form-select" id="producto" name="producto_id" required disabled>
                                                <option value="" selected disabled>Primero seleccione un productor...</option>
                                            </select>
                                        </div>

                                        <!-- Cantidad de Paquetes -->
                                        <div class="mb-3">
                                            <label for="cantidad" class="form-label">Cantidad de Paquetes <span class="text-danger">*</span></label>
                                            <input type="number" class="form-control" id="cantidad" name="cantidad" min="1" required>
                                        </div>

                                        <!-- Zona -->
                                        <div class="mb-3">
                                            <label for="zona" class="form-label">Zona <span class="text-danger">*</span></label>
                                            <select class="form-select" id="zona" required>
                                                <option value="" selected disabled>Seleccione una zona...</option>
                                                <% ArrayList<ZonaBean> listaZonas = (ArrayList<ZonaBean>) request.getAttribute("listaZonas");
                                                    if (listaZonas != null) {
                                                        for (ZonaBean zona : listaZonas) { %>
                                                <option value="<%= zona.getId() %>"><%= zona.getNombre() %></option>
                                                <%     }
                                                } %>
                                            </select>
                                        </div>

                                        <!-- Distrito -->
                                        <div class="mb-3">
                                            <label for="distrito" class="form-label">Distrito (Destino) <span class="text-danger">*</span></label>
                                            <select class="form-select" id="distrito" name="distrito_id" required disabled>
                                                <option value="" selected disabled>Primero seleccione una zona...</option>
                                            </select>
                                        </div>
                                    </div>

                                    <!-- Columna Derecha - Resumen -->
                                    <div class="col-md-5">
                                        <div class="card bg-light">
                                            <div class="card-body">
                                                <h5 class="card-title text-center mb-4"><i class="fas fa-calculator me-2"></i>Resumen de Orden</h5>
                                                
                                                <div class="mb-3">
                                                    <label class="form-label text-muted">Producto Seleccionado:</label>
                                                    <p class="fw-bold" id="resumenProducto">-</p>
                                                </div>

                                                <div class="mb-3">
                                                    <label class="form-label text-muted">Precio Unitario:</label>
                                                    <p class="fw-bold" id="resumenPrecio">S/. 0.00</p>
                                                </div>

                                                <div class="mb-3">
                                                    <label class="form-label text-muted">Cantidad de Paquetes:</label>
                                                    <p class="fw-bold" id="resumenCantidad">0</p>
                                                </div>

                                                <div class="mb-3">
                                                    <label class="form-label text-muted">Unidades Totales:</label>
                                                    <p class="fw-bold text-success" id="resumenUnidadesTotales">0 unidades</p>
                                                    <small class="text-muted" style="font-size: 0.85em;">
                                                        <i class="fas fa-info-circle"></i> Paquetes × Unidades por paquete
                                                    </small>
                                                </div>

                                                <div class="mb-3">
                                                    <label class="form-label text-muted">Destino:</label>
                                                    <p class="fw-bold" id="resumenDestino">-</p>
                                                </div>

                                                <hr>

                                                <div class="text-center">
                                                    <label class="form-label text-muted">MONTO TOTAL:</label>
                                                    <h3 class="text-primary" id="montoTotalDisplay">S/. 0.00</h3>
                                                    <input type="hidden" name="monto_total" id="montoTotal" required>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <hr class="my-4">

                                <div class="d-flex justify-content-end">
                                    <a href="${pageContext.request.contextPath}/orden-compra" class="btn btn-secondary me-2">
                                        <i class="fas fa-times me-2"></i>Cancelar
                                    </a>
                                    <button type="submit" class="btn btn-primary" id="btnGuardar" disabled>
                                        <i class="fas fa-save me-2"></i>Guardar Orden de Compra
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Variables globales
    let precioProducto = 0;
    let nombreProducto = '';
    let unidadesPorPaquete = 0;
    let nombreZona = '';
    let nombreDistrito = '';

    // Referencias a elementos
    const productorSelect = document.getElementById('productor');
    const productoSelect = document.getElementById('producto');
    const cantidadInput = document.getElementById('cantidad');
    const zonaSelect = document.getElementById('zona');
    const distritoSelect = document.getElementById('distrito');
    const btnGuardar = document.getElementById('btnGuardar');

    // Cuando se selecciona un productor, cargar sus productos
    productorSelect.addEventListener('change', async function() {
        const productorId = this.value;
        
        if (!productorId) return;

        // Limpiar y deshabilitar producto
        productoSelect.innerHTML = '<option value="" selected disabled>Cargando productos...</option>';
        productoSelect.disabled = true;
        resetearResumen();

        try {
            const response = await fetch('${pageContext.request.contextPath}/orden-compra?action=obtenerProductosPorProductor&productorId=' + productorId);
            const productos = await response.json();

            productoSelect.innerHTML = '<option value="" selected disabled>Seleccione un producto...</option>';
            
            if (productos.length === 0) {
                productoSelect.innerHTML = '<option value="" selected disabled>Este productor no tiene productos</option>';
            } else {
                productos.forEach(producto => {
                    const option = document.createElement('option');
                    option.value = producto.id;
                    option.textContent = producto.nombre;
                    option.dataset.precio = producto.precio;
                    option.dataset.nombre = producto.nombre;
                    option.dataset.unidades = producto.unidades_por_paquete || 1;
                    productoSelect.appendChild(option);
                });
                productoSelect.disabled = false;
            }
        } catch (error) {
            console.error('Error al cargar productos:', error);
            productoSelect.innerHTML = '<option value="" selected disabled>Error al cargar productos</option>';
        }
    });

    // Cuando se selecciona un producto
    productoSelect.addEventListener('change', function() {
        const selectedOption = this.options[this.selectedIndex];
        precioProducto = parseFloat(selectedOption.dataset.precio) || 0;
        nombreProducto = selectedOption.dataset.nombre || '-';
        unidadesPorPaquete = parseInt(selectedOption.dataset.unidades) || 1;
        
        document.getElementById('resumenProducto').textContent = nombreProducto;
        document.getElementById('resumenPrecio').textContent = 'S/. ' + precioProducto.toFixed(2);
        
        calcularTotal();
    });

    // Cuando cambia la cantidad
    cantidadInput.addEventListener('input', function() {
        const cantidad = parseInt(this.value) || 0;
        document.getElementById('resumenCantidad').textContent = cantidad;
        calcularTotal();
    });

    // Cuando se selecciona una zona, cargar sus distritos
    zonaSelect.addEventListener('change', async function() {
        const zonaId = this.value;
        nombreZona = this.options[this.selectedIndex].text;
        
        if (!zonaId) return;

        // Limpiar y deshabilitar distrito
        distritoSelect.innerHTML = '<option value="" selected disabled>Cargando distritos...</option>';
        distritoSelect.disabled = true;
        document.getElementById('resumenDestino').textContent = '-';

        try {
            const response = await fetch('${pageContext.request.contextPath}/orden-compra?action=obtenerDistritosPorZona&zonaId=' + zonaId);
            const distritos = await response.json();

            distritoSelect.innerHTML = '<option value="" selected disabled>Seleccione un distrito...</option>';
            
            if (distritos.length === 0) {
                distritoSelect.innerHTML = '<option value="" selected disabled>Esta zona no tiene distritos</option>';
            } else {
                distritos.forEach(distrito => {
                    const option = document.createElement('option');
                    option.value = distrito.id;
                    option.textContent = distrito.nombre;
                    option.dataset.nombre = distrito.nombre;
                    distritoSelect.appendChild(option);
                });
                distritoSelect.disabled = false;
            }
        } catch (error) {
            console.error('Error al cargar distritos:', error);
            distritoSelect.innerHTML = '<option value="" selected disabled>Error al cargar distritos</option>';
        }
    });

    // Cuando se selecciona un distrito
    distritoSelect.addEventListener('change', function() {
        nombreDistrito = this.options[this.selectedIndex].dataset.nombre || '-';
        document.getElementById('resumenDestino').textContent = nombreZona + ' - ' + nombreDistrito;
        validarFormulario();
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

    // Resetear resumen
    function resetearResumen() {
        precioProducto = 0;
        nombreProducto = '';
        unidadesPorPaquete = 0;
        document.getElementById('resumenProducto').textContent = '-';
        document.getElementById('resumenPrecio').textContent = 'S/. 0.00';
        document.getElementById('resumenCantidad').textContent = '0';
        document.getElementById('resumenUnidadesTotales').textContent = '0 unidades';
        document.getElementById('montoTotalDisplay').textContent = 'S/. 0.00';
        document.getElementById('montoTotal').value = '';
        btnGuardar.disabled = true;
    }

    // Validar formulario completo
    function validarFormulario() {
        const valido = productorSelect.value && 
                      productoSelect.value && 
                      cantidadInput.value > 0 && 
                      zonaSelect.value && 
                      distritoSelect.value;
        
        btnGuardar.disabled = !valido;
    }

    // Validar al enviar el formulario
    document.getElementById('formOrdenCompra').addEventListener('submit', function(e) {
        const montoTotal = parseFloat(document.getElementById('montoTotal').value);
        
        if (isNaN(montoTotal) || montoTotal <= 0) {
            e.preventDefault();
            alert('El monto total debe ser mayor a cero');
            return false;
        }
    });
</script>
</body>
</html>
