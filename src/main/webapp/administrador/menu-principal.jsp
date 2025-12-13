<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Inicio"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Inicio'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content" style="padding-bottom: 100px !important;">
    <div class="row">
        <div class="col-12">
            <div class="page-header pt-1 pb-1 d-flex justify-content-between align-items-center flex-wrap">
                <div>
                    <h2 class="pageheader-title mb-0" style="font-size: 1.4rem;"><i class="fas fa-chart-pie me-2"></i>¡Bienvenido, Administrador!</h2>
                    <p class="pageheader-text mb-0" style="font-size: 0.85rem;">Resumen general del sistema y accesos rápidos.</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Primera fila de métricas principales -->
    <div class="row g-2 mb-3">
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-success border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Usuarios activos</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= request.getAttribute("usuariosActivos") != null ? request.getAttribute("usuariosActivos") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;"><%= request.getAttribute("porcentajeActivos") != null ? request.getAttribute("porcentajeActivos") : "0" %>% del total</small>
                        </div>
                        <div class="stat-icon text-success ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                            <i class="fas fa-users"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-danger border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Usuarios baneados</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= request.getAttribute("usuariosBaneados") != null ? request.getAttribute("usuariosBaneados") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">Acceso deshabilitado</small>
                        </div>
                        <div class="stat-icon text-danger ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                            <i class="fas fa-user-slash"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-warning border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Alertas abiertas</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= request.getAttribute("alertasAbiertas") != null ? request.getAttribute("alertasAbiertas") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">Requieren atención</small>
                        </div>
                        <div class="stat-icon text-warning ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-info border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Acciones hoy</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= request.getAttribute("accionesHoy") != null ? request.getAttribute("accionesHoy") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">Registradas en auditoría</small>
                        </div>
                        <div class="stat-icon text-info ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                            <i class="fas fa-history"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Segunda fila de métricas del sistema -->
    <div class="row g-2 mb-3">
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-primary border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Productos</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= request.getAttribute("totalProductos") != null ? request.getAttribute("totalProductos") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">En el inventario</small>
                        </div>
                        <div class="stat-icon text-primary ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                            <i class="fas fa-boxes-stacked"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-secondary border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Lotes</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= request.getAttribute("totalLotes") != null ? request.getAttribute("totalLotes") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">Registrados</small>
                        </div>
                        <div class="stat-icon text-secondary ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                            <i class="fas fa-layer-group"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-success border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Eficiencia logística</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= request.getAttribute("eficienciaLogistica") != null ? request.getAttribute("eficienciaLogistica") : "0" %>%</h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">Entregas completadas</small>
                        </div>
                        <div class="stat-icon text-success ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                            <i class="fas fa-truck-fast"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-warning border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Rutas activas</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= request.getAttribute("rutasActivas") != null ? request.getAttribute("rutasActivas") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">En proceso</small>
                        </div>
                        <div class="stat-icon text-warning ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                            <i class="fas fa-route"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row mt-2 mb-4">
        <div class="col-12">
            <h5 class="mb-3 pageheader-title" style="font-size: 1.15rem;">
                <i class="fas fa-bolt text-primary me-2"></i>Accesos rápidos
            </h5>
        </div>
        <div class="col-lg-3 col-md-6 mb-2">
            <a href="<%= request.getContextPath() %>/administrador/reportes?action=globales" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="mb-1" style="color: #006d77;">
                        <i class="fas fa-chart-pie" style="font-size: 1.9rem;"></i>
                    </div>
                    <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Reportes globales</h6>
                    <span style="font-size: 0.8rem; color: #4a4a4a;">KPIs y tableros</span>
                </div>
            </a>
        </div>
        <div class="col-lg-3 col-md-6 mb-2">
            <a href="<%= request.getContextPath() %>/administrador/acceso-roles.jsp" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="mb-1" style="color: #006d77;">
                        <i class="fas fa-user-shield" style="font-size: 1.9rem;"></i>
                    </div>
                    <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Roles y permisos</h6>
                    <span style="font-size: 0.8rem; color: #4a4a4a;">Asignación y políticas</span>
                </div>
            </a>
        </div>
        <div class="col-lg-3 col-md-6 mb-2">
            <a href="<%= request.getContextPath() %>/administrador/configuracion.jsp" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="mb-1" style="color: #006d77;">
                        <i class="fas fa-cogs" style="font-size: 1.9rem;"></i>
                    </div>
                    <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Configuración</h6>
                    <span style="font-size: 0.8rem; color: #4a4a4a;">Sistema y plantillas</span>
                </div>
            </a>
        </div>
        <div class="col-lg-3 col-md-6 mb-2">
            <a href="<%= request.getContextPath() %>/UsuarioServlet" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="mb-1" style="color: #006d77;">
                        <i class="fas fa-users-cog" style="font-size: 1.9rem;"></i>
                    </div>
                    <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Gestión de usuarios</h6>
                    <span style="font-size: 0.8rem; color: #4a4a4a;">Administrar usuarios</span>
                </div>
            </a>
        </div>
        <div class="col-lg-3 col-md-6 mb-2 offset-lg-3">
            <a href="<%= request.getContextPath() %>/AuditoriaServlet" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="mb-1" style="color: #006d77;">
                        <i class="fas fa-clipboard-list" style="font-size: 1.9rem;"></i>
                    </div>
                    <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Auditoría</h6>
                    <span style="font-size: 0.8rem; color: #4a4a4a;">Registro de acciones</span>
                </div>
            </a>
        </div>
        <div class="col-lg-3 col-md-6 mb-2">
            <a href="<%= request.getContextPath() %>/ConfiguracionAvanzadaServlet" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="mb-1" style="color: #006d77;">
                        <i class="fas fa-sliders-h" style="font-size: 1.9rem;"></i>
                    </div>
                    <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Configuración avanzada</h6>
                    <span style="font-size: 0.8rem; color: #4a4a4a;">Sistema y emails</span>
                </div>
            </a>
        </div>
    </div>
    
    <!-- Espacio adicional al final para evitar que se corten los accesos rápidos -->
    <div class="row" style="margin-bottom: 80px; padding-bottom: 40px;">
        <div class="col-12"></div>
    </div>

        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<!-- Bootstrap JS ya está incluido en footer.jsp -->
</body>
</html>