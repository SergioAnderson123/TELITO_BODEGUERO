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
            <div class="page-header mb-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h2 class="pageheader-title"><i class="fas fa-file-excel me-2"></i>Gestión de Plantillas</h2>
                    <p class="pageheader-text">Administra las plantillas para la carga masiva de datos.</p>
                </div>
                <div>
                    <a href="<%= request.getContextPath() %>/PlantillaServlet?action=formCrear" class="btn btn-primary shadow-sm">
                        <i class="fas fa-plus me-2"></i>Crear Nueva Plantilla
                    </a>
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
                    <div class="table-card shadow-sm">
                        <div class="card-header" style="padding: 0.5rem 0.75rem;">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-file-excel me-2"></i>Plantillas Creadas</h5>
                                    <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todas las plantillas del sistema</small>
                                </div>
                            </div>
                        </div>
                        <div class="card-body" style="padding: 0.75rem;">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important;">
                                    <thead class="table-light">
                                    <tr>
                                        <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-tag me-1"></i>Nombre de la Plantilla</th>
                                        <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-filter me-1"></i>Tipo de Carga</th>
                                        <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-toggle-on me-1"></i>Estado</th>
                                        <th class="text-end" style="width: 150px; font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-cog me-1"></i>Acciones</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <% if (listaPlantillas != null && !listaPlantillas.isEmpty()) { %>
                                    <% for (PlantillaConfig plantilla : listaPlantillas) { %>
                                    <tr class="align-middle" style="padding: 0;">
                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;" class="fw-semibold"><%= plantilla.getNombre() %></td>
                                        <td style="padding: 0.35rem 0.5rem;">
                                            <% if ("STOCK".equals(plantilla.getTipoCarga())) { %>
                                            <span class="badge bg-info shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">Carga de Stock</span>
                                            <% } else { %>
                                            <span class="badge bg-primary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">Creación de Productos</span>
                                            <% } %>
                                        </td>
                                        <td style="padding: 0.35rem 0.5rem;">
                                            <% if (plantilla.isActivo()) { %>
                                            <span class="badge bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">Activa</span>
                                            <% } else { %>
                                            <span class="badge bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">Inactiva</span>
                                            <% } %>
                                        </td>
                                        <td class="text-end" style="padding: 0.35rem 0.5rem;">
                                            <div class="dropdown">
                                                <button class="btn btn-sm btn-outline-secondary shadow-sm" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="font-size: 0.8rem; padding: 0.25rem 0.5rem;">
                                                    <i class="fas fa-ellipsis-v"></i>
                                                </button>
                                                <ul class="dropdown-menu dropdown-menu-end">
                                                    <li><a class="dropdown-item" href="<%= request.getContextPath() %>/PlantillaServlet?action=editar&id=<%= plantilla.getIdPlantilla() %>"><i class="fas fa-edit me-2"></i>Editar</a></li>
                                                    <% if (plantilla.isActivo()) { %>
                                                    <li><hr class="dropdown-divider"></li>
                                                    <li><a class="dropdown-item text-danger" href="#" onclick="showConfirm('¿Estás seguro de que quieres deshabilitar esta plantilla?', function() { window.location.href='<%= request.getContextPath() %>/PlantillaServlet?action=deshabilitar&id=<%= plantilla.getIdPlantilla() %>'; }, 'Confirmar acción'); return false;"><i class="fas fa-ban me-2"></i>Deshabilitar</a></li>
                                                    <% } %>
                                                </ul>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                    <% } else { %>
                                    <tr>
                                        <td colspan="4" class="text-center py-4 text-muted" style="font-size: 0.85rem;">
                                            <i class="fas fa-inbox fa-2x mb-2 d-block" style="opacity: 0.3;"></i>
                                            No hay plantillas configuradas. ¡Crea la primera!
                                        </td>
                                    </tr>
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