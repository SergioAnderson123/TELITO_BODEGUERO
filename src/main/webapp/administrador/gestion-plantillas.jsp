<%--
  Created by IntelliJ IDEA.
  User: Sergio
  Date: 1/10/2025
  Time: 16:22
  To change this template use File | Settings | File Templates.
--%>
<%@ page import="com.example.telito.administrador.beans.PlantillaConfig" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    ArrayList<PlantillaConfig> listaPlantillas = (ArrayList<PlantillaConfig>) request.getAttribute("listaPlantillas");
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Plantillas"/>
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
            <div class="page-header mb-4 d-flex justify-content-between align-items-center">
                <div>
                    <h2 class="pageheader-title" style="font-weight: 700;">Gestión de Plantillas</h2>
                    <p class="pageheader-text">Administra las plantillas para la carga masiva de datos.</p>
                </div>
                <div>
                    <a href="<%= request.getContextPath() %>/PlantillaServlet?action=formCrear" class="btn btn-primary"><i class="fas fa-plus"></i> Crear Nueva Plantilla</a>
                </div>
            </div>

            <%-- Mensajes de éxito o error --%>
            <% if (session.getAttribute("successMsg") != null) { %>
            <div class="alert alert-success" role="alert">
                <%= session.getAttribute("successMsg") %>
                <% session.removeAttribute("successMsg"); %>
            </div>
            <% } %>
            <% if (session.getAttribute("errorMsg") != null) { %>
            <div class="alert alert-danger" role="alert">
                <%= session.getAttribute("errorMsg") %>
                <% session.removeAttribute("errorMsg"); %>
            </div>
            <% } %>

            <div class="row">
                <div class="col-12">
                    <div class="table-card">
                        <div class="card-header">
                            <h5 class="mb-0 fw-semibold">Plantillas Creadas</h5>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle">
                                    <thead>
                                    <tr>
                                        <th>Nombre de la Plantilla</th>
                                        <th>Tipo de Carga</th>
                                        <th>Estado</th>
                                        <th class="text-end">Acciones</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <% if (listaPlantillas != null && !listaPlantillas.isEmpty()) { %>
                                    <% for (PlantillaConfig plantilla : listaPlantillas) { %>
                                    <tr>
                                        <td class="fw-medium"><%= plantilla.getNombre() %></td>
                                        <td>
                                            <% if ("STOCK".equals(plantilla.getTipoCarga())) { %>
                                            <span class="badge bg-info-soft text-info">Carga de Stock</span>
                                            <% } else { %>
                                            <span class="badge bg-primary-soft text-primary">Creación de Productos</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <% if (plantilla.isActivo()) { %>
                                            <span class="badge bg-success-soft text-success">Activa</span>
                                            <% } else { %>
                                            <span class="badge bg-secondary-soft text-secondary">Inactiva</span>
                                            <% } %>
                                        </td>
                                        <td class="text-end">
                                            <a href="<%= request.getContextPath() %>/PlantillaServlet?action=editar&id=<%= plantilla.getIdPlantilla() %>" class="btn btn-sm btn-outline-primary">Editar</a>
                                            <% if (plantilla.isActivo()) { %>
                                            <a href="<%= request.getContextPath() %>/PlantillaServlet?action=deshabilitar&id=<%= plantilla.getIdPlantilla() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('¿Estás seguro de que quieres deshabilitar esta plantilla?')">Deshabilitar</a>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <% } %>
                                    <% } else { %>
                                    <tr><td colspan="4" class="text-center py-4">No hay plantillas configuradas. ¡Crea la primera!</td></tr>
                                    <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            </main>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
            <script>
                document.addEventListener('DOMContentLoaded', () => {
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
                });
            </script>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>
</body>
</html>