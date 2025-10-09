<%@ page import="com.example.telito.administrador.beans.PlantillaConfig" %>
<%@ page import="com.example.telito.administrador.beans.PlantillaMapeo" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    PlantillaConfig plantilla = (PlantillaConfig) request.getAttribute("plantilla");
    boolean modoEditar = (plantilla != null);
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><%= modoEditar ? "Editar" : "Crear" %> Plantilla – Telito Bodeguero</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>
<body>
<div class="topbar">
    <div class="topbar-brand"><i class="fas fa-warehouse"></i> Telito Bodeguero</div>
    <div class="topbar-actions">
        <a href="<%= request.getContextPath() %>/AlertaServlet?action=listar" class="notification-bell">
            <i class="fas fa-bell"></i>
            <%
                Integer alertasAbiertas = (Integer) session.getAttribute("alertasAbiertas");
                if (alertasAbiertas != null && alertasAbiertas > 0) {
            %>
            <span class="notification-badge"><%= alertasAbiertas %></span>
            <%
                }
            %>
        </a>
        <div class="user-avatar">TB</div>
    </div>
</div>

<aside class="sidebar" id="sidebar">
    <div class="sidebar-menu-title">Menu</div>
    <nav>
        <a href="<%= request.getContextPath() %>/inicio"><i class="fas fa-home fa-fw"></i> Pestaña principal</a>
        <a href="<%= request.getContextPath() %>/UsuarioServlet"><i class="fas fa-users fa-fw"></i> Gestión de Usuarios</a>
        <a href="<%= request.getContextPath() %>/ProductoServlet?action=listarInventario"><i class="fas fa-boxes-stacked fa-fw"></i> Inventario General</a>
        <a href="<%= request.getContextPath() %>/administrador/acceso-roles.jsp"><i class="fas fa-user-shield fa-fw"></i> Acceso a Roles</a>
        <a href="<%= request.getContextPath() %>/reportes-globales.jsp"><i class="fas fa-chart-pie fa-fw"></i> Reportes Globales</a>
        <a href="<%= request.getContextPath() %>/configuracion.jsp" class="active"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
    </nav>
    <div class="sidebar-footer"><a href="#"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
</aside>

<header class="header" id="header">
    <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
</header>

<main class="content" id="content">
    <div class="page-header mb-4">
        <h2 class="pageheader-title" style="font-weight: 700;"><%= modoEditar ? "Editar" : "Crear" %> Plantilla</h2>
        <p class="pageheader-text">Define la estructura para la carga masiva de datos desde Excel.</p>
    </div>

    <div class="row">
        <div class="col-xl-8 col-lg-10 col-md-12 col-sm-12 col-12 mx-auto">
            <div class="form-card">
                <div class="card-body">
                    <form action="<%= request.getContextPath() %>/PlantillaServlet?action=<%= modoEditar ? "actualizar" : "guardar" %>" method="POST">
                        <% if (modoEditar) { %>
                        <input type="hidden" name="id_plantilla" value="<%= plantilla.getIdPlantilla() %>">
                        <% } %>

                        <div class="mb-3">
                            <label for="nombre" class="form-label">Nombre de la Plantilla</label>
                            <input type="text" class="form-control" id="nombre" name="nombre" value="<%= modoEditar ? plantilla.getNombre() : "" %>" placeholder="Ej: Carga de Stock Semanal" required>
                        </div>

                        <div class="mb-4">
                            <label for="tipo_carga" class="form-label">Tipo de Carga</label>
                            <select id="tipo_carga" name="tipo_carga" class="form-select" required>
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

                        <div class="mt-4 pt-3 border-top d-flex justify-content-end">
                            <a href="<%= request.getContextPath() %>/PlantillaServlet" class="btn btn-light me-2">Cancelar</a>
                            <button type="submit" class="btn btn-primary">Guardar Plantilla</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</main>

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
</body>
</html>
