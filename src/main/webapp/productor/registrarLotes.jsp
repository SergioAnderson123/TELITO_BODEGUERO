<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.productor.beans.Producto" %>
<%@ page import="java.util.ArrayList" %>
<%--
    JSP: Registrar Lotes
    Propósito: Permite registrar nuevos lotes asociados a un producto.
    Atributos esperados (request):
      - alertType (String: success/danger) y alertMessage (String) para mensajes de resultado
      - form_* (opcionales) para repoblar campos cuando hay error: form_skuProducto, form_cantidadStock, form_fechaCaducidad
    Navegación: Sidebar con sección "Registrar Lotes" activa.
    Notas: El código de lote se genera automáticamente en formato L--0001, L--0002, etc. El distrito se asigna por defecto.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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

        /* =====================
           Botón Hamburguesa
        ====================== */
        .sidebar-toggle {
            display: none;
            background: none;
            border: none;
            color: var(--turquoise-dark);
            font-size: 1.5rem;
            padding: 8px 12px;
            cursor: pointer;
            margin-right: 15px;
            transition: color 0.3s ease;
        }
        .sidebar-toggle:hover {
            color: var(--seafoam);
        }
        
        /* Overlay para móvil */
        .sidebar-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 999;
            opacity: 0;
            transition: opacity 0.3s ease;
        }
        .sidebar-overlay.active {
            opacity: 1;
        }

        /* Responsive sidebar */
        @media (max-width: 992px) {
            .sidebar-toggle {
                display: inline-block;
            }
            .nav-left-sidebar { 
                position: fixed; 
                transform: translateX(-100%); 
                transition: transform 0.3s ease;
                z-index: 1000;
            }
            .nav-left-sidebar.open { 
                transform: translateX(0); 
            }
            .sidebar-overlay {
                display: block;
            }
            .dashboard-header { left: 0; }
            .dashboard-wrapper { margin-left: 0; width: 100%; }
        }
    </style>
</head>
<body>
    <div class="dashboard-main-wrapper">
        <!-- ===================== Overlay para móvil ===================== -->
        <div class="sidebar-overlay" id="sidebarOverlay"></div>

        <!-- ===================== Header / Topbar ===================== -->
        <div class="dashboard-header">
            <nav class="navbar navbar-expand">
                <div class="container-fluid">
                    <!-- Botón Hamburguesa -->
                    <button class="sidebar-toggle" id="sidebarToggle" type="button" aria-label="Toggle sidebar">
                        <i class="fas fa-bars"></i>
                    </button>
                    <!-- Brand -->
                    <a class="navbar-brand d-flex align-items-center" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos">
                        <i class="fas fa-store me-2" style="color: var(--seafoam);"></i>
                        <span>Telito Bodeguero</span>
                    </a>

                    <!-- Right actions -->
                    <ul class="navbar-nav ms-auto">
                        <li class="nav-item dropdown">
                            <%
                                com.example.telito.administrador.beans.Usuario usuarioHeader = 
                                    (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
                                String nombreCompleto = usuarioHeader != null ? 
                                    usuarioHeader.getNombres() + " " + usuarioHeader.getApellidos() : "Usuario";
                                String fotoUrl = "https://ui-avatars.com/api/?name=User&background=006d77&color=fff&size=200";
                                if (usuarioHeader != null) {
                                    String foto = usuarioHeader.getFotoPerfil();
                                    if (foto != null && !foto.trim().isEmpty()) {
                                        if (foto.startsWith("http://") || foto.startsWith("https://")) {
                                            fotoUrl = foto;
                                        } else {
                                            fotoUrl = request.getContextPath() + "/" + foto;
                                        }
                                    } else {
                                        fotoUrl = usuarioHeader.getFotoPerfilUrl();
                                    }
                                }
                            %>
                            <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                                <img src="<%= fotoUrl %>" alt="User" class="rounded-circle me-2" width="32" height="32">
                                <span style="color:#006d77;"><%= nombreCompleto %></span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="<%= request.getContextPath() %>/perfil"><i class="fas fa-user me-2"></i>Perfil</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="<%= request.getContextPath() %>/logout"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesion</a></li>
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
                    </ul>
                </nav>
            </div>
        </div>
        
        <!-- ===================== Contenido principal ===================== -->
        <div class="dashboard-wrapper">
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header d-flex justify-content-between align-items-center">
                    <div>
                        <h2><i class="fas fa-boxes me-2"></i>Registrar Lotes</h2>
                        <p class="text-muted mb-0">Registra los nuevos lotes de productos distribuidos en diferentes ubicaciones.</p>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <div class="btn-group">
                            <a href="<%= request.getContextPath() %>/productor/LoteReporteServlet?action=exportar" class="btn btn-sm" style="background: linear-gradient(160deg, #28a745 0%, #20c997 100%); color: white; border: none; padding: 8px 16px; border-radius: 8px;">
                                <i class="fas fa-boxes me-2"></i>Exportar Lotes
                            </a>
                            <a href="<%= request.getContextPath() %>/productor/LoteReporteServlet?action=formEnviar" class="btn btn-sm" style="background: linear-gradient(160deg, #17a2b8 0%, #138496 100%); color: white; border: none; padding: 8px 16px; border-radius: 8px;">
                                <i class="fas fa-envelope me-2"></i>Enviar Lotes
                            </a>
                        </div>
                    </div>
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
                                <form id="registrarLoteForm" class="needs-validation" novalidate method="POST" action="<%= request.getContextPath() %>/ProductorServlet">
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
                                            
                                            <!-- Código de lote (generado automáticamente) -->
                                            <div class="mb-3">
                                                <label for="codigoLote" class="form-label">Código de Lote (generado automáticamente)</label>
                                                <input type="text" class="form-control" id="codigoLote" name="codigoLote" readonly style="background-color: #f0f0f0; cursor: not-allowed; font-weight: bold; color: #28a745;" placeholder="Cargando...">
                                                <small class="text-muted">
                                                    <i class="fas fa-info-circle"></i> El código de lote se genera automáticamente (ej: L--0031)
                                                </small>
                                            </div>
                                        </div>
                                        
                                        <div class="col-md-6">
                                            <h6 class="section-title">
                                                <i class="fas fa-warehouse me-2"></i>Detalles de Stock y Ubicación
                                            </h6>
                                            
                                            <!-- Cantidad de paquetes. El stock real se calcula automáticamente multiplicando por unidades_por_paquete -->
                                            <div class="mb-3">
                                                <label for="cantidadStock" class="form-label">Cantidad de Paquetes/Cajas</label>
                                                <input type="number" class="form-control" id="cantidadStock" name="cantidadStock" min="1" placeholder="Ej: 10 (cajas)" required value="<%= request.getAttribute("form_cantidadStock") != null ? request.getAttribute("form_cantidadStock") : "" %>">
                                                <small class="form-text text-muted">
                                                    <i class="fas fa-info-circle"></i> El stock total se calculará automáticamente multiplicando por las unidades por paquete del producto
                                                </small>
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
                                            
                                            <!-- Costo de producción -->
                                            <div class="mb-3">
                                                <label for="costoProduccion" class="form-label">Costo de Producción por Unidad (Opcional)</label>
                                                <div class="input-group">
                                                    <span class="input-group-text">S/</span>
                                                    <input type="number" class="form-control" id="costoProduccion" name="costoProduccion" 
                                                           step="0.01" min="0" placeholder="Ej: 2.50" 
                                                           value="<%= request.getAttribute("form_costoProduccion") != null ? request.getAttribute("form_costoProduccion") : "" %>">
                                                </div>
                                                <small class="form-text text-muted">
                                                    <i class="fas fa-info-circle"></i> Costo de producción por unidad del lote.
                                                </small>
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

        // Función para limpiar el formulario
        function limpiarFormulario() {
            document.getElementById('registrarLoteForm').reset();
            document.getElementById('registrarLoteForm').classList.remove('was-validated');
            cargarCodigoLote(); // Cargar un nuevo código de lote
        }

        // Cargar código de lote automático al cargar la página
        function cargarCodigoLote() {
            const codigoLoteInput = document.getElementById('codigoLote');
            codigoLoteInput.value = 'Cargando...';
            codigoLoteInput.style.color = '#999';
            
            const contextPath = '<%= request.getContextPath() %>';
            fetch(contextPath + '/ProductorServlet?action=obtenerNuevoCodigoLote')
                .then(response => response.json())
                .then(data => {
                    if (data.codigo) {
                        codigoLoteInput.value = data.codigo;
                        codigoLoteInput.style.color = '#28a745';
                    } else {
                        codigoLoteInput.value = 'Error al generar código';
                        codigoLoteInput.style.color = '#dc3545';
                    }
                })
                .catch(error => {
                    console.error('Error al obtener código de lote:', error);
                    codigoLoteInput.value = 'Error de conexión';
                    codigoLoteInput.style.color = '#dc3545';
                });
        }
        
        // Cargar código al iniciar la página
        cargarCodigoLote();

        // Si hay mensaje de éxito, recargar nuevo código de lote
        <% if ("success".equals(alertType)) { %>
        setTimeout(function() {
            cargarCodigoLote();
        }, 500);
        <% } %>

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

        // Recargar página si se vuelve desde el perfil
        if (sessionStorage.getItem('recargarDesdePerfil') === 'true') {
            sessionStorage.removeItem('recargarDesdePerfil');
            location.reload();
        }
    </script>

    <script>
        // ===================== Control del Sidebar en Móvil =====================
        const sidebarToggle = document.getElementById('sidebarToggle');
        const sidebar = document.querySelector('.nav-left-sidebar');
        const sidebarOverlay = document.getElementById('sidebarOverlay');

        function toggleSidebar() {
            if (sidebar && sidebarOverlay) {
                sidebar.classList.toggle('open');
                sidebarOverlay.classList.toggle('active');
                if (sidebar.classList.contains('open')) {
                    document.body.style.overflow = 'hidden';
                } else {
                    document.body.style.overflow = '';
                }
            }
        }

        function closeSidebar() {
            if (sidebar && sidebarOverlay) {
                sidebar.classList.remove('open');
                sidebarOverlay.classList.remove('active');
                document.body.style.overflow = '';
            }
        }

        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', function(e) {
                e.stopPropagation();
                toggleSidebar();
            });
        }

        if (sidebarOverlay) {
            sidebarOverlay.addEventListener('click', closeSidebar);
        }

        if (window.innerWidth <= 992) {
            const sidebarLinks = document.querySelectorAll('.nav-left-sidebar .nav-link');
            sidebarLinks.forEach(link => {
                link.addEventListener('click', function() {
                    setTimeout(closeSidebar, 100);
                });
            });
        }

        window.addEventListener('resize', function() {
            if (window.innerWidth > 992) {
                closeSidebar();
            }
        });
    </script>
</body>
</html>