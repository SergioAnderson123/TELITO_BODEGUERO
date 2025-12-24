<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Inicio"/>
    </jsp:include>
    <style>
        /* CRÍTICO: Eliminar TODAS las restricciones y forzar el mismo tamaño que Logística */
        .dashboard-wrapper {
            width: calc(100% - 250px) !important;
        }
        .dashboard-content {
            padding: 30px !important;
            width: 100% !important;
            max-width: 100% !important;
            box-sizing: border-box !important;
        }
        .dashboard-content .container-fluid {
            width: 100% !important;
            max-width: 100% !important;
            padding-left: 15px !important;
            padding-right: 15px !important;
            margin-left: 0 !important;
            margin-right: 0 !important;
            box-sizing: border-box !important;
        }
        /* Asegurar box-sizing consistente */
        .dashboard-content .row,
        .dashboard-content .row > [class*="col-"],
        .dashboard-content .stat-card {
            box-sizing: border-box !important;
        }
        /* CRÍTICO: Eliminar completamente el padding de 30px que tiene .card en el CSS global */
        .dashboard-content .stat-card,
        .dashboard-content .stat-card.card {
            padding: 0 !important;
            margin: 0 !important;
            margin-bottom: 0 !important;
            height: 100% !important;
            width: 100% !important;
            box-shadow: 0 2px 6px rgba(0,0,0,0.05) !important;
            background: var(--white) !important;
            border-radius: 15px !important;
        }
        .dashboard-content .stat-card .card-body {
            padding: 0.5rem !important;
            padding-top: 0.75rem !important;
            padding-bottom: 0.75rem !important;
            width: 100% !important;
        }
        /* Asegurar que las filas ocupen todo el ancho disponible */
        .dashboard-content .row.g-2 {
            --bs-gutter-x: 0.5rem;
            --bs-gutter-y: 0.5rem;
            margin-left: calc(var(--bs-gutter-x) * -0.5) !important;
            margin-right: calc(var(--bs-gutter-x) * -0.5) !important;
            width: 100% !important;
            max-width: 100% !important;
        }
        .dashboard-content .row.g-2 > [class*="col-"] {
            padding-left: calc(var(--bs-gutter-x) * 0.5) !important;
            padding-right: calc(var(--bs-gutter-x) * 0.5) !important;
        }
        /* CRÍTICO: Forzar que las columnas col-xl-3 ocupen exactamente 25% del ancho - igual que logística */
        @media (min-width: 1200px) {
            .dashboard-content .row.g-2 .col-xl-3 {
                flex: 0 0 25% !important;
                max-width: 25% !important;
                width: 25% !important;
                min-width: 0 !important;
            }
        }
        /* Asegurar que en todas las pantallas grandes el ancho sea consistente */
        @media (min-width: 1400px) {
            .dashboard-content .container-fluid {
                max-width: 100% !important;
                width: 100% !important;
            }
            .dashboard-content .row.g-2 .col-xl-3 {
                flex: 0 0 25% !important;
                max-width: 25% !important;
                width: 25% !important;
            }
        }
        /* Sobrescribir estilos globales para que los quick-link-card tengan el mismo tamaño que en Logística */
        .dashboard-content .quick-link-card,
        .dashboard-content .quick-link-card.card {
            padding: 0 !important;
            margin-bottom: 0 !important;
        }
        .dashboard-content .quick-link-card .card-body {
            padding: 0.5rem !important;
            padding-top: 0.75rem !important;
            padding-bottom: 0.75rem !important;
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Inicio'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">
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
            <div class="card stat-card shadow-sm border-start border-3" style="border-start-color: #D4A574 !important; transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto; background-color: #FFFEF9;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #6F4E37;">Usuarios activos</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #6F4E37;"><%= request.getAttribute("usuariosActivos") != null ? request.getAttribute("usuariosActivos") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;"><%= request.getAttribute("porcentajeActivos") != null ? request.getAttribute("porcentajeActivos") : "0" %>% del total</small>
                        </div>
                        <div class="stat-icon ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0; color: #6F4E37;">
                            <i class="fas fa-users"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-danger border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto; background-color: #FFFEF9;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #6F4E37;">Usuarios baneados</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #6F4E37;"><%= request.getAttribute("usuariosBaneados") != null ? request.getAttribute("usuariosBaneados") : "0" %></h2>
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
            <div class="card stat-card shadow-sm border-start border-3" style="border-start-color: #B8865B !important; transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto; background-color: #FFFEF9;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #6F4E37;">Alertas abiertas</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #6F4E37;"><%= request.getAttribute("alertasAbiertas") != null ? request.getAttribute("alertasAbiertas") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">Requieren atención</small>
                        </div>
                        <div class="stat-icon ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0; color: #6F4E37;">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-3" style="border-start-color: #E8B86D !important; transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto; background-color: #FFFEF9;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #6F4E37;">Acciones hoy</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #6F4E37;"><%= request.getAttribute("accionesHoy") != null ? request.getAttribute("accionesHoy") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">Registradas en auditoría</small>
                        </div>
                        <div class="stat-icon ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0; color: #6F4E37;">
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
            <div class="card stat-card shadow-sm border-start border-3" style="border-start-color: #D4A574 !important; transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto; background-color: #FFFEF9;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #6F4E37;">Productos</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #6F4E37;"><%= request.getAttribute("totalProductos") != null ? request.getAttribute("totalProductos") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">En el inventario</small>
                        </div>
                        <div class="stat-icon ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0; color: #6F4E37;">
                            <i class="fas fa-boxes-stacked"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-3" style="border-start-color: #C9A87A !important; transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto; background-color: #FFFEF9;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #6F4E37;">Lotes</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #6F4E37;"><%= request.getAttribute("totalLotes") != null ? request.getAttribute("totalLotes") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">Registrados</small>
                        </div>
                        <div class="stat-icon ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0; color: #6F4E37;">
                            <i class="fas fa-layer-group"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-3" style="border-start-color: #C9A87A !important; transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto; background-color: #FFFEF9;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #6F4E37;">Eficiencia logística</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #6F4E37;"><%= request.getAttribute("eficienciaLogistica") != null ? request.getAttribute("eficienciaLogistica") : "0" %>%</h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">Entregas completadas</small>
                        </div>
                        <div class="stat-icon ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0; color: #6F4E37;">
                            <i class="fas fa-truck-fast"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
            <div class="card stat-card shadow-sm border-start border-3" style="border-start-color: #B8865B !important; transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto; background-color: #FFFEF9;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #6F4E37;">Rutas activas</h6>
                            <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #6F4E37;"><%= request.getAttribute("rutasActivas") != null ? request.getAttribute("rutasActivas") : "0" %></h2>
                            <small style="font-size: 0.8rem; color: #4a4a4a;">En proceso</small>
                        </div>
                        <div class="stat-icon ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0; color: #6F4E37;">
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
                <i class="fas fa-bolt me-2" style="color: #6F4E37;"></i>Accesos rápidos
            </h5>
        </div>
        <div class="col-lg-3 col-md-6 mb-2">
            <a href="<%= request.getContextPath() %>/administrador/reportes?action=globales" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                    <div class="mb-1" style="color: #6F4E37;">
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
                    <div class="mb-1" style="color: #6F4E37;">
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
                    <div class="mb-1" style="color: #6F4E37;">
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
                    <div class="mb-1" style="color: #6F4E37;">
                        <i class="fas fa-users-cog" style="font-size: 1.9rem;"></i>
                    </div>
                    <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Gestión de usuarios</h6>
                    <span style="font-size: 0.8rem; color: #4a4a4a;">Administrar usuarios</span>
                </div>
            </a>
        </div>
    </div>
            </div>
            <jsp:include page="/administrador/layouts/footer.jsp" />
        </div>
    </div>
</div>

<!-- Bootstrap JS ya está incluido en footer.jsp -->
</body>
</html>