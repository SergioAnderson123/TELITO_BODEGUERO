<%@ page import="com.example.telito.administrador.beans.PlantillaConfig" %>
<%@ page import="com.example.telito.administrador.beans.PlantillaMapeo" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    PlantillaConfig plantilla = (PlantillaConfig) request.getAttribute("plantilla");
    boolean modoEditar = (plantilla != null);
    String pageTitle = modoEditar ? "Editar Plantilla" : "Crear Plantilla";
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="<%= pageTitle %>"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Configuracion'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="page-header mb-4">
                <h2 class="pageheader-title"><i class="fas fa-file-excel me-2"></i><%= modoEditar ? "Editar" : "Crear" %> Plantilla</h2>
                <p class="pageheader-text">Define la estructura para la carga masiva de datos desde Excel.</p>
            </div>

            <div class="row">
                <div class="col-xl-8 col-lg-10 col-md-12 col-sm-12 col-12 mx-auto">
                    <div class="card shadow-sm">
                        <div class="card-header bg-gradient-primary text-white mb-4" style="background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); border-radius: 12px 12px 0 0; margin: -30px -30px 30px -30px; padding: 25px 30px;">
                            <h5 class="mb-0"><i class="fas fa-file-excel me-2"></i>Datos de la Plantilla</h5>
                            <small class="text-white-50">Complete todos los campos obligatorios</small>
                        </div>
                        <div class="card-body">
                            <form action="<%= request.getContextPath() %>/PlantillaServlet?action=<%= modoEditar ? "actualizar" : "guardar" %>" method="POST">
                                <% if (modoEditar) { %>
                                <input type="hidden" name="id_plantilla" value="<%= plantilla.getIdPlantilla() %>">
                                <% } %>

                                <div class="mb-4">
                                    <label for="nombre" class="form-label fw-semibold">
                                        <i class="fas fa-tag text-primary me-2"></i>Nombre de la Plantilla <span class="text-danger">*</span>
                                    </label>
                                    <input type="text" class="form-control shadow-sm" id="nombre" name="nombre" value="<%= modoEditar ? plantilla.getNombre() : "" %>" placeholder="Ej: Carga de Stock Semanal" required>
                                </div>

                                <div class="mb-4">
                                    <label for="tipo_carga" class="form-label fw-semibold">
                                        <i class="fas fa-filter text-primary me-2"></i>Tipo de Carga <span class="text-danger">*</span>
                                    </label>
                                    <select id="tipo_carga" name="tipo_carga" class="form-select shadow-sm" required>
                                        <option value="STOCK" <%= (modoEditar && "STOCK".equals(plantilla.getTipoCarga())) ? "selected" : "" %>>Carga de Stock</option>
                                        <option value="PRODUCTOS" <%= (modoEditar && "PRODUCTOS".equals(plantilla.getTipoCarga())) ? "selected" : "" %>>Creación de Productos</option>
                                    </select>
                                </div>

                                <div class="mapeo-section border-top pt-4">
                                    <h5 class="fw-semibold mb-3">Mapeo de Columnas</h5>
                                    <div id="mapeo-container">
                                        <% if (modoEditar && plantilla.getMapeos() != null && !plantilla.getMapeos().isEmpty()) {
                                            for (PlantillaMapeo mapeo : plantilla.getMapeos()) { %>
                                        <div class="row align-items-center mapeo-row mb-2">
                                            <div class="col-5">
                                                <label class="form-label visually-hidden">Columna Excel</label>
                                                <input type="text" class="form-control" name="columna_excel" placeholder="Columna Excel (ej. A)" value="<%= mapeo.getColumnaExcel() %>" required>
                                            </div>
                                            <div class="col-5">
                                                <label class="form-label visually-hidden">Campo de Destino</label>
                                                <select class="form-select" name="campo_destino" required>
                                                    <option value="">Seleccionar Campo</option>
                                                    <option value="CODIGO_SKU" <%= "CODIGO_SKU".equals(mapeo.getCampoDestino()) ? "selected" : "" %>>Código SKU</option>
                                                    <option value="STOCK_ACTUAL" <%= "STOCK_ACTUAL".equals(mapeo.getCampoDestino()) ? "selected" : "" %>>Stock</option>
                                                    <option value="CODIGO_LOTE" <%= "CODIGO_LOTE".equals(mapeo.getCampoDestino()) ? "selected" : "" %>>Código de Lote</option>
                                                    <option value="FECHA_VENCIMIENTO" <%= "FECHA_VENCIMIENTO".equals(mapeo.getCampoDestino()) ? "selected" : "" %>>Fecha de Vencimiento</option>
                                                    <option value="PRECIO" <%= "PRECIO".equals(mapeo.getCampoDestino()) ? "selected" : "" %>>Precio</option>
                                                </select>
                                            </div>
                                            <div class="col-2 text-end">
                                                <button type="button" class="btn btn-sm btn-outline-danger btn-remove-mapeo"><i class="fas fa-trash"></i></button>
                                            </div>
                                        </div>
                                        <%    }
                                        } %>
                                    </div>
                                    <button type="button" id="btn-add-mapeo" class="btn btn-sm btn-secondary mt-2"><i class="fas fa-plus"></i> Añadir Mapeo</button>
                                </div>

                                <div class="form-check mt-4">
                                    <input class="form-check-input" type="checkbox" id="activo" name="activo" value="true" <%= (modoEditar && !plantilla.isActivo()) ? "" : "checked" %>>
                                    <label class="form-check-label" for="activo">Plantilla Activa</label>
                                </div>

                                <div class="mt-5 pt-4 border-top d-flex justify-content-between align-items-center">
                                    <a href="<%= request.getContextPath() %>/PlantillaServlet" class="btn btn-outline-secondary shadow-sm">
                                        <i class="fas fa-times me-2"></i>Cancelar
                                    </a>
                                    <button type="submit" class="btn btn-primary shadow-sm px-4">
                                        <i class="fas fa-save me-2"></i>Guardar Plantilla
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Plantilla para clonar nuevas filas de mapeo -->
            <template id="mapeo-template">
                <div class="row align-items-center mapeo-row mb-2">
                    <div class="col-5">
                        <label class="form-label visually-hidden">Columna Excel</label>
                        <input type="text" class="form-control" name="columna_excel" placeholder="Columna Excel (ej. A)" required>
                    </div>
                    <div class="col-5">
                        <label class="form-label visually-hidden">Campo de Destino</label>
                        <select class="form-select" name="campo_destino" required>
                            <option value="" selected>Seleccionar Campo</option>
                            <option value="CODIGO_SKU">Código SKU</option>
                            <option value="STOCK_ACTUAL">Stock</option>
                            <option value="CODIGO_LOTE">Código de Lote</option>
                            <option value="FECHA_VENCIMIENTO">Fecha de Vencimiento</option>
                            <option value="PRECIO">Precio</option>
                        </select>
                    </div>
                    <div class="col-2 text-end">
                        <button type="button" class="btn btn-sm btn-outline-danger btn-remove-mapeo"><i class="fas fa-trash"></i></button>
                    </div>
                </div>
            </template>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
            <script>
                document.addEventListener('DOMContentLoaded', () => {
                    // Script para el menú lateral
                    const sidebar = document.getElementById('sidebar');
                    const content = document.getElementById('content');
                    const header = document.getElementById('header');
                    const sidebarToggle = document.getElementById('sidebar-toggle');
                    if (sidebarToggle) {
                        sidebarToggle.addEventListener('click', () => {
                            sidebar.classList.toggle('hidden');
                            content.classList.toggle('full-width');
                            header.classList.toggle('full-width');
                        });
                    }

                    // Script para el formulario dinámico de mapeo
                    const mapeoContainer = document.getElementById('mapeo-container');
                    const template = document.getElementById('mapeo-template');
                    const addBtn = document.getElementById('btn-add-mapeo');

                    addBtn.addEventListener('click', () => {
                        const clone = template.content.cloneNode(true);
                        mapeoContainer.appendChild(clone);
                    });

                    mapeoContainer.addEventListener('click', (e) => {
                        if (e.target.closest('.btn-remove-mapeo')) {
                            e.target.closest('.mapeo-row').remove();
                        }
                    });
                });
            </script>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>
</body>
</html>