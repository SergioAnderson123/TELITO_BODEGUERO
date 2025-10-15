<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.bodega.beans.Producto" %>
<%@ page import="java.util.ArrayList" %>
<%--
    JSP: Registrar Lotes
    Propósito: Permite registrar nuevos lotes asociados a un producto y ubicación.
    Atributos esperados (request):
      - alertType (String: success/danger) y alertMessage (String) para mensajes de resultado
      - form_* (opcionales) para repoblar campos cuando hay error: form_codigoLote, form_skuProducto,
        form_cantidadStock, form_fechaCaducidad, form_distrito
    Navegación: Sidebar con sección "Registrar Lotes" activa.
    Notas: La validación de fecha exige una fecha estrictamente futura. El submit se bloquea si no se cumple.
--%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Registrar Lotes - Telito Bodeguero</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <!-- Custom CSS -->
    <style>
        :root {
            --turquoise-dark: #006d77; /* oscuro */
            --seafoam: #83c5be;        /* verde agua */
            --seafoam-light: #edf6f9;  /* fondo claro */
            --text-dark: #2b2d42;
            --text-muted: #6c757d;
            --border: #e9ecef;
        }
        body {
            background-color: var(--seafoam-light);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .dashboard-main-wrapper { display: flex; min-height: 100vh; }
        .nav-left-sidebar {
            width: 250px;
            background: linear-gradient(160deg, var(--turquoise-dark) 0%, #055e68 100%);
            min-height: 100vh;
            position: fixed; left: 0; top: 0; z-index: 1000;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }
        .dashboard-wrapper { margin-left: 250px; width: calc(100% - 250px); min-height: 100vh; }
        .dashboard-header {
            background-color: #fff;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: fixed; top: 0; right: 0; left: 250px; z-index: 999;
            height: 70px; border-bottom: 1px solid var(--border);
        }
        .dashboard-content { margin-top: 70px; padding: 30px; }
        .nav-link {
            color: rgba(255,255,255,0.9) !important;
            padding: 12px 20px; border-radius: 8px; margin: 5px 15px;
            transition: all 0.3s ease; display: flex; align-items: center;
        }
        .nav-link:hover, .nav-link.active { background-color: rgba(255,255,255,0.18); color: #fff !important; transform: translateX(5px); }
        .nav-link i { margin-right: 10px; width: 20px; }
        .nav-divider { color: rgba(255,255,255,0.8); font-weight: 600; padding: 15px 20px 5px; margin-top: 20px; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; }
        .user-avatar-md { width: 40px; height: 40px; }
        .navbar-brand { font-weight: 700; color: var(--turquoise-dark); }
        .navbar-brand img { height: 35px; }
        .card { border: none; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.08); transition: transform 0.3s ease; }
        .card:hover { transform: translateY(-2px); }
        .card-header {
            background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
            color: white; border-radius: 15px 15px 0 0 !important; border: none; font-weight: 600;
        }
        .btn-primary {
            background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
            border: none; border-radius: 8px; padding: 12px 25px; font-weight: 500; transition: all 0.3s ease;
        }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0, 109, 119, 0.35); }
        .btn-secondary { background-color: #8d99ae; border: none; }
        .form-control, .form-select { border-radius: 8px; border: 2px solid var(--border); padding: 12px 15px; transition: all 0.3s ease; }
        .form-control:focus, .form-select:focus { border-color: var(--seafoam); box-shadow: 0 0 0 0.2rem rgba(131, 197, 190, 0.35); }
        .form-label { font-weight: 600; color: var(--text-dark); margin-bottom: 8px; }
        .form-text { color: var(--text-muted); font-size: 0.875rem; }
        .invalid-feedback { font-size: 0.875rem; }
        .page-header { margin-bottom: 30px; }
        .page-header h2 { color: var(--turquoise-dark); font-weight: 700; margin-bottom: 10px; }
        .page-header p { color: var(--text-muted); font-size: 1.05rem; }
        .section-title { color: var(--turquoise-dark); font-weight: 600; font-size: 1.1rem; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid var(--border); }
        .footer { background-color: #fff; border-top: 1px solid var(--border); margin-top: 50px; padding: 20px 0; }
        .footer-links a { color: var(--text-muted); text-decoration: none; margin: 0 10px; }
        .footer-links a:hover { color: var(--turquoise-dark); }

        /* Responsive sidebar */
        @media (max-width: 992px) {
            .nav-left-sidebar { position: fixed; transform: translateX(-100%); transition: transform 0.3s ease; }
            .nav-left-sidebar.open { transform: translateX(0); }
            .dashboard-header { left: 0; }
            .dashboard-wrapper { margin-left: 0; width: 100%; }
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
                            <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos">
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
                            <a class="nav-link active" href="<%= request.getContextPath() %>/ProductorServlet?action=formRegistrarLote">
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
                <!-- Page Header -->
                <div class="page-header">
                    <h2><i class="fas fa-boxes me-2"></i>Registrar Lotes</h2>
                    <p>Registra los nuevos lotes de productos distribuidos en diferentes ubicaciones.</p>
                </div>
                
                <!-- Mini pantalla de error para fecha inválida -->
                <div id="fechaErrorAlert" class="alert alert-danger d-none" role="alert" style="border-radius: 10px;">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    La fecha de caducidad no puede ser anterior a hoy.
                </div>

                <!-- Mensaje de resultado de registro de lote -->
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
        
                <!-- ===================== Card: Formulario de Registro de Lotes ===================== -->
                <div class="row">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0"><i class="fas fa-clipboard-list me-2"></i>Formulario de Registro de Lotes</h5>
                            </div>
                            <div class="card-body">
                                <form id="registrarLoteForm" class="needs-validation" novalidate method="POST" action="ProductorServlet">
                                    <input type="hidden" name="action" value="registrarLote">
                                    
                                    <div class="row">
                                        <div class="col-md-6">
                                            <h6 class="section-title">
                                                <i class="fas fa-info-circle me-2"></i>Información del Producto y Lote
                                            </h6>
                                            
                                            <!-- SKU del producto: al salir del campo se autocompleta el nombre vía fetch JSON -->
                                            <div class="mb-3">
                                                <label for="skuProducto" class="form-label">SKU del Producto</label>
                                                <input type="text" class="form-control" id="skuProducto" name="skuProducto" placeholder="Ej: BOD-0001" required value="<%= request.getAttribute("form_skuProducto") != null ? request.getAttribute("form_skuProducto") : "" %>">
                                                <div class="form-text">
                                                    <i class="fas fa-info-circle me-1"></i>Ingresa el SKU para cargar el nombre del producto.
                                                </div>
                                                <div class="invalid-feedback">Por favor, ingresa un SKU válido.</div>
                                            </div>
                                            
                                            <!-- Nombre de producto autocompletado (solo lectura) -->
                                            <div class="mb-3">
                                                <label for="nombreProducto" class="form-label">Nombre del Producto</label>
                                                <input type="text" class="form-control" id="nombreProducto" placeholder="Se completará automáticamente" readonly>
                                            </div>
                                            
                                            <!-- Código de lote (se autogenera al enfocar si está vacío) -->
                                            <div class="mb-3">
                                                <label for="codigoLote" class="form-label">Código de Lote</label>
                                                <input type="text" class="form-control" id="codigoLote" name="codigoLote" placeholder="Ej: L-2025-026" required value="<%= request.getAttribute("form_codigoLote") != null ? request.getAttribute("form_codigoLote") : "" %>">
                                                <div class="invalid-feedback">El código de lote es obligatorio.</div>
                                            </div>
                                        </div>
                                        
                                        <div class="col-md-6">
                                            <h6 class="section-title">
                                                <i class="fas fa-warehouse me-2"></i>Detalles de Stock y Ubicación
                                            </h6>
                                            
                                            <!-- Cantidad y fecha de caducidad (opcional). Fecha debe ser estrictamente futura -->
                                            <div class="mb-3">
                                                <label for="cantidadStock" class="form-label">Cantidad de Stock</label>
                                                <input type="number" class="form-control" id="cantidadStock" name="cantidadStock" min="1" placeholder="Ej: 100" required value="<%= request.getAttribute("form_cantidadStock") != null ? request.getAttribute("form_cantidadStock") : "" %>">
                                                <div class="invalid-feedback">Ingresa una cantidad válida.</div>
                                            </div>
                                            
                                            <!-- Selección de distrito/ubicación -->
                                            <div class="mb-3">
                                                <label for="fechaCaducidad" class="form-label">Fecha de Caducidad (Opcional)</label>
                                                <input type="date" class="form-control" id="fechaCaducidad" name="fechaCaducidad" value="<%= request.getAttribute("form_fechaCaducidad") != null ? request.getAttribute("form_fechaCaducidad") : "" %>">
                                                <div class="form-text">
                                                    <i class="fas fa-calendar me-1"></i>Deja vacío si el producto no tiene fecha de caducidad.
                                                </div>
                                            </div>
                                            
                                            <div class="mb-3">
                                                <label for="distrito" class="form-label">Distrito (Ubicación)</label>
                                                <select class="form-select" id="distrito" name="distrito" required>
                                                    <option value="" selected disabled>Seleccione un distrito...</option>
                                                    
                                                    <optgroup label="Norte">
                                                        <option value="Ancon" <%= "Ancon".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Ancon</option>
                                                        <option value="Santa Rosa" <%= "Santa Rosa".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Santa Rosa</option>
                                                        <option value="Carabayllo" <%= "Carabayllo".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Carabayllo</option>
                                                        <option value="Puente Piedra" <%= "Puente Piedra".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Puente Piedra</option>
                                                        <option value="Comas" <%= "Comas".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Comas</option>
                                                        <option value="Los Olivos" <%= "Los Olivos".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Los Olivos</option>
                                                        <option value="San Martín de Porres" <%= "San Martín de Porres".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>San Martín de Porres</option>
                                                        <option value="Independencia" <%= "Independencia".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Independencia</option>
                                                    </optgroup>
    
                                                    <optgroup label="Sur">
                                                        <option value="San Juan de Miraflores" <%= "San Juan de Miraflores".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>San Juan de Miraflores</option>
                                                        <option value="Villa María del Triunfo" <%= "Villa María del Triunfo".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Villa María del Triunfo</option>
                                                        <option value="Villa el Salvador" <%= "Villa el Salvador".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Villa el Salvador</option>
                                                        <option value="Pachacamac" <%= "Pachacamac".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Pachacamac</option>
                                                        <option value="Lurin" <%= "Lurin".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Lurin</option>
                                                        <option value="Punta Hermosa" <%= "Punta Hermosa".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Punta Hermosa</option>
                                                        <option value="Punta Negra" <%= "Punta Negra".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Punta Negra</option>
                                                        <option value="San Bartolo" <%= "San Bartolo".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>San Bartolo</option>
                                                        <option value="Santa María del Mar" <%= "Santa María del Mar".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Santa María del Mar</option>
                                                        <option value="Pucusana" <%= "Pucusana".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Pucusana</option>
                                                    </optgroup>
    
                                                    <optgroup label="Este">
                                                        <option value="San Juan de Lurigancho" <%= "San Juan de Lurigancho".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>San Juan de Lurigancho</option>
                                                        <option value="Lurigancho/Chosica" <%= "Lurigancho/Chosica".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Lurigancho/Chosica</option>
                                                        <option value="Ate" <%= "Ate".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Ate</option>
                                                        <option value="El Agustino" <%= "El Agustino".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>El Agustino</option>
                                                        <option value="Santa Anita" <%= "Santa Anita".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Santa Anita</option>
                                                        <option value="La Molina" <%= "La Molina".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>La Molina</option>
                                                        <option value="Cieneguilla" <%= "Cieneguilla".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Cieneguilla</option>
                                                    </optgroup>
    
                                                    <optgroup label="Oeste">
                                                        <option value="Rimac" <%= "Rimac".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Rimac</option>
                                                        <option value="Cercado de Lima" <%= "Cercado de Lima".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Cercado de Lima</option>
                                                        <option value="Breña" <%= "Breña".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Breña</option>
                                                        <option value="Pueblo Libre" <%= "Pueblo Libre".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Pueblo Libre</option>
                                                        <option value="Magdalena" <%= "Magdalena".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Magdalena</option>
                                                        <option value="Jesus María" <%= "Jesus María".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Jesus María</option>
                                                        <option value="La Victoria" <%= "La Victoria".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>La Victoria</option>
                                                        <option value="Lince" <%= "Lince".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Lince</option>
                                                        <option value="San Isidro" <%= "San Isidro".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>San Isidro</option>
                                                        <option value="San Miguel" <%= "San Miguel".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>San Miguel</option>
                                                        <option value="Surquillo" <%= "Surquillo".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Surquillo</option>
                                                        <option value="San Borja" <%= "San Borja".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>San Borja</option>
                                                        <option value="Santiago de Surco" <%= "Santiago de Surco".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Santiago de Surco</option>
                                                        <option value="Barranco" <%= "Barranco".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Barranco</option>
                                                        <option value="Chorrillos" <%= "Chorrillos".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Chorrillos</option>
                                                        <option value="San Luis" <%= "San Luis".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>San Luis</option>
                                                        <option value="Miraflores" <%= "Miraflores".equals(request.getAttribute("form_distrito")) ? "selected" : "" %>>Miraflores</option>
                                                    </optgroup>
                                                </select>
                                                <div class="invalid-feedback">Debes seleccionar una ubicación.</div>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="d-flex justify-content-end mt-4">
                                        <button type="button" class="btn btn-secondary me-3" onclick="limpiarFormulario()">
                                            <i class="fas fa-eraser me-1"></i>Limpiar
                                        </button>
                                        <span id="tooltipSubmitWrapper" data-bs-toggle="tooltip" data-bs-placement="top" title="">
                                            <button id="submitRegistrarLote" class="btn btn-primary" type="submit">
                                                <i class="fas fa-save me-1"></i>Registrar Lote
                                            </button>
                                        </span>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
    
    <!-- ===================== Bootstrap JS ===================== -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- ===================== Scripts de la vista ===================== -->
    <!-- Validación, autocompletado por SKU (fetch JSON), manejo de tooltip y bloqueo de submit -->
    <script>
        // Validación de Bootstrap (se mantiene igual)
        (function() {
            'use strict'
            var forms = document.querySelectorAll('.needs-validation')
            Array.prototype.slice.call(forms)
                .forEach(function(form) {
                    form.addEventListener('submit', function(event) {
                        if (!form.checkValidity()) {
                            event.preventDefault()
                            event.stopPropagation()
                        }
                        form.classList.add('was-validated')
                    }, false)
                })
        })();

        // Event listener para buscar el producto cuando se sale del campo SKU
        document.getElementById('skuProducto').addEventListener('blur', function() {
            const sku = this.value.trim();
            if (sku) {
                // Llamamos a la nueva función que se conecta al Servlet
                buscarProductoPorSKU_ajax(sku);
            }
        });

        // VVV --- FUNCIÓN ROBUSTA PARA BUSCAR POR SKU --- VVV
        function buscarProductoPorSKU_ajax(sku) {
            const campoNombre = document.getElementById('nombreProducto');
            const skuSanitizado = (sku || '').trim();
            if (!skuSanitizado) {
                campoNombre.value = '';
                return;
            }

            const url = '<%= request.getContextPath() %>' + '/ProductorServlet?action=buscarProductoPorSkuJson&sku=' + encodeURIComponent(skuSanitizado);

            fetch(url, { headers: { 'Accept': 'application/json' } })
                .then(resp => {
                    if (!resp.ok) throw new Error('HTTP ' + resp.status);
                    return resp.json();
                })
                .then(data => {
                    const nombre = (data && typeof data.nombre === 'string') ? data.nombre : '';
                    if (nombre) {
                        campoNombre.value = nombre;
                        campoNombre.style.backgroundColor = '#d4edda';
                        setTimeout(() => { campoNombre.style.backgroundColor = ''; }, 1500);
                    } else {
                        campoNombre.value = 'Producto no encontrado';
                        campoNombre.style.backgroundColor = '#f8d7da';
                        setTimeout(() => { campoNombre.value = ''; campoNombre.style.backgroundColor = ''; }, 1500);
                    }
                })
                .catch(error => {
                    console.error('Error en la búsqueda:', error);
                    campoNombre.value = 'Error al buscar';
                    campoNombre.style.backgroundColor = '#f8d7da';
                    setTimeout(() => { campoNombre.value = ''; campoNombre.style.backgroundColor = ''; }, 1500);
                });
        }

        // Función para limpiar el formulario (se mantiene igual)
        function limpiarFormulario() {
            document.getElementById('registrarLoteForm').reset();
            document.getElementById('registrarLoteForm').classList.remove('was-validated');
        }

        // Generar código de lote automático (se mantiene igual)
        document.getElementById('codigoLote').addEventListener('focus', function() {
            if (!this.value) {
                const fecha = new Date();
                const año = fecha.getFullYear();
                const mes = String(fecha.getMonth() + 1).padStart(2, '0');
                const dia = String(fecha.getDate()).padStart(2, '0');
                const numero = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
                this.value = `L-${año}-${mes}${dia}-${numero}`;
            }
        });

        // Validación de fecha de caducidad (se mantiene igual)
        const fechaCaducidadInput = document.getElementById('fechaCaducidad');
        const submitBtn = document.getElementById('submitRegistrarLote');
        const tooltipWrapper = document.getElementById('tooltipSubmitWrapper');

        function toDateOnly(d) {
            const copy = new Date(d.getTime());
            copy.setHours(0,0,0,0);
            return copy;
        }

        function validarFechaCaducidad() {
            // Campo opcional: vacío => válido
            if (!fechaCaducidadInput.value) {
                fechaCaducidadInput.setCustomValidity('');
                ocultarErrorFecha();
                submitBtn.disabled = false;
                if (tooltipWrapper) { tooltipWrapper.setAttribute('title', ''); }
                if (tooltipWrapper && bootstrap.Tooltip.getInstance(tooltipWrapper)) { bootstrap.Tooltip.getInstance(tooltipWrapper).setContent({'.tooltip-inner': ''}); }
                return true;
            }

            const fechaCad = toDateOnly(new Date(fechaCaducidadInput.value));
            const hoy = toDateOnly(new Date());

            // Debe ser estrictamente futura
            if (fechaCad <= hoy) {
                fechaCaducidadInput.setCustomValidity('La fecha de caducidad debe ser futura.');
                mostrarErrorFecha();
                submitBtn.disabled = true;
                if (tooltipWrapper) { tooltipWrapper.setAttribute('title', 'La fecha de caducidad debe ser futura'); }
                if (tooltipWrapper && bootstrap.Tooltip.getInstance(tooltipWrapper)) { bootstrap.Tooltip.getInstance(tooltipWrapper).setContent({'.tooltip-inner': 'La fecha de caducidad debe ser futura'}); }
                return false;
            } else {
                fechaCaducidadInput.setCustomValidity('');
                ocultarErrorFecha();
                submitBtn.disabled = false;
                if (tooltipWrapper) { tooltipWrapper.setAttribute('title', ''); }
                if (tooltipWrapper && bootstrap.Tooltip.getInstance(tooltipWrapper)) { bootstrap.Tooltip.getInstance(tooltipWrapper).setContent({'.tooltip-inner': ''}); }
                return true;
            }
        }

        fechaCaducidadInput.addEventListener('change', validarFechaCaducidad);

        // Mostrar/ocultar mini pantalla de error
        function mostrarErrorFecha() {
            const alerta = document.getElementById('fechaErrorAlert');
            alerta.classList.remove('d-none');
        }

        function ocultarErrorFecha() {
            const alerta = document.getElementById('fechaErrorAlert');
            alerta.classList.add('d-none');
        }

        // Bloquear envío si la fecha es inválida y mostrar alerta
        document.getElementById('registrarLoteForm').addEventListener('submit', function(event) {
            if (!validarFechaCaducidad()) {
                event.preventDefault();
                event.stopPropagation();
            }
        });

        // Estado inicial del botón al cargar
        validarFechaCaducidad();

        // Inicializar tooltips de la página (incluido el del botón)
        (function initTooltips(){
            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
            tooltipTriggerList.forEach(function (tooltipTriggerEl) {
                if (!bootstrap.Tooltip.getInstance(tooltipTriggerEl)) {
                    new bootstrap.Tooltip(tooltipTriggerEl);
                }
            })
        })();
    </script>
</body>
</html>