<%--
  Created by IntelliJ IDEA.
  User: eduro
  Date: 27/09/2025
  Time: 12:05
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Ordenes de Compra</title>
    <meta name="description" content="Modern Bootstrap 5 Admin Dashboard Template">

    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="../assets/images/favicon.ico">

    <!-- CSS -->


    <script type="module" crossorigin src="../assets/js/OrdenesDeCompra-DWxWyNwf.js"></script>
    <link rel="modulepreload" crossorigin href="../assets/js/app-1KrE6bWM.js">
    <link rel="stylesheet" crossorigin href="../assets/css/style-3m-kRAaI.css">
    <script type="module">import.meta.url;import("_").catch(()=>1);(async function*(){})().next();window.__vite_is_modern_browser=true</script>
    <script type="module">!function(){if(window.__vite_is_modern_browser)return;console.warn("vite: loading legacy chunks, syntax error above and the same error below should be ignored");var e=document.getElementById("vite-legacy-polyfill"),n=document.createElement("script");n.src=e.src,n.onload=function(){System.import(document.getElementById('vite-legacy-entry').getAttribute('data-src'))},document.body.appendChild(n)}();</script>
</head>
<body>
<div class="dashboard-main-wrapper">

    <div class="dashboard-header">
        <nav class="navbar navbar-expand fixed-top">
            <div class="container-fluid">
                <!-- Mobile Sidebar Toggle -->
                <button class="navbar-toggler sidebar-toggler me-3 d-lg-none" type="button" aria-label="Toggle sidebar">
                    <span class="navbar-toggler-icon"></span>
                </button>

                <!-- Brand -->
                <a class="navbar-brand d-flex align-items-center ms-3" href="../index.html">
                    <!-- Icono (puedes cambiar el src por tu propio logo en /assets/images/) -->
                    <img src="../assets/images/telito-CfoOZLNj.jpeg" alt="Logo Telito" style="height:32px; width:auto;" class="me-2">
                    <span class="fw-bold">Telito Bodeguero</span>
                </a>




                <!-- Right Side Items - Always visible -->
                <ul class="navbar-nav ms-auto navbar-right-top">
                    <!-- Mobile Search Toggle -->
                    <li class="nav-item d-md-none">
                        <a class="nav-link nav-icons" href="#" data-bs-toggle="modal" data-bs-target="#searchModal">
                            <i class="fas fa-search"></i>
                        </a>
                    </li>


                    <!-- User Profile -->
                    <li class="nav-item dropdown nav-user ms-2">
                        <a class="nav-link p-0" href="#" id="navbarUser" data-bs-toggle="dropdown" aria-expanded="false">
                            <img src="https://ui-avatars.com/api/?name=John+Abraham&background=5969ff&color=fff" alt="User" class="user-avatar-md rounded-circle">
                        </a>
                        <div class="dropdown-menu dropdown-menu-end nav-user-dropdown" aria-labelledby="navbarUser">
                            <div class="nav-user-info">
                                <div class="d-flex align-items-center">
                                    <img src="https://ui-avatars.com/api/?name=John+Abraham&background=5969ff&color=fff" alt="User" class="rounded-circle me-3" width="50">
                                    <div>
                                        <h6 class="mb-0">Eduardo Rodas</h6>
                                        <small class="text-muted">eduardo@example.com</small>
                                    </div>
                                </div>
                            </div>
                            <a class="dropdown-item text-danger" href="#"><i class="fas fa-power-off me-2"></i>Logout</a>
                        </div>
                    </li>
                </ul>
            </div>
        </nav>
    </div>
    <div class="nav-left-sidebar sidebar-dark">
        <div class="menu-list">
            <nav class="navbar navbar-expand navbar-light">
                <ul class="navbar-nav flex-column w-100">
                    <li class="nav-divider">
                        Menu
                    </li>

                    <!-- Mis productos -->
                    <li class="nav-item">
                        <a class="nav-link " href="../pages/MisProductos.html">
                            <i class="fas fa-fw fa-shopping-cart"></i>Mis Productos
                        </a>
                    </li>

                    <!-- Ordenes de Compra -->
                    <li class="nav-item">
                        <a class="nav-link " href="../pages/OrdenesDeCompra.html">
                            <i class="fas fa-fw fa-chart-pie"></i>Ordenes de Compra
                        </a>
                    </li>

                    <!-- Registrar lotes -->
                    <li class="nav-item">
                        <a class="nav-link " href="../pages/RegistrarLotes.html">
                            <i class="fab fa-fw fa-wpforms"></i>Registrar lotes
                        </a>
                    </li>

                    <!-- Actualizar precios -->
                    <li class="nav-item">
                        <a class="nav-link " href="../pages/ActualizarPrecios.html" >
                            <i class="fas fa-fw fa-table"></i>Actualizar precios
                        </a>
                    </li>

                </ul>
            </nav>
        </div>
    </div>
    <div class="dashboard-wrapper">
        <div class="container-fluid dashboard-content">
            <div class="row">
                <div class="col-12">
                    <div class="page-header">
                        <h2 class="pageheader-title">Órdenes de Compra</h2>
                        <p class="pageheader-text">Revisa y gestiona las órdenes de compra asignadas a tus productos.</p>
                        <!-- Enlace al video de Homero bailando para alegrar el día 😄 -->
                        <div class="text-center mt-3">
                            <a href="https://www.youtube.com/watch?v=b34PMjZNIvY" 
                               target="_blank" 
                               class="btn btn-warning btn-lg"
                               style="border-radius: 25px; box-shadow: 0 4px 15px rgba(255, 193, 7, 0.3);">
                                <i class="fas fa-play me-2"></i>🎉 ¡Ver a Homero Bailar! 🕺
                            </a>
                            <p class="text-muted mt-2"><small>🎵 ¡Haz clic para ver el baile más épico! 🎵</small></p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12 col-12">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="text-muted">Órdenes Pendientes</h5>
                            <div class="metric-value d-inline-block">
                                <h1 class="mb-0">8</h1>
                            </div>
                            <div class="float-end">
                                <i class="fas fa-fw fa-hourglass-half fa-2x text-warning"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12 col-12">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="text-muted">Órdenes Aprobadas</h5>
                            <div class="metric-value d-inline-block">
                                <h1 class="mb-0">25</h1>
                            </div>
                            <div class="float-end">
                                <i class="fas fa-fw fa-check-circle fa-2x text-success"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12 col-12">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="text-muted">Total Unidades a Surtir</h5>
                            <div class="metric-value d-inline-block">
                                <h1 class="mb-0">1,250</h1>
                            </div>
                            <div class="float-end">
                                <i class="fas fa-fw fa-box-open fa-2x text-primary"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
                    <div class="card">
                        <h5 class="card-header">Listado de Órdenes de Compra</h5>
                        <div class="card-body">
                            <div class="row mb-3">
                                <div class="col-md-4">
                                    <input type="text" class="form-control" placeholder="Buscar por ID o producto...">
                                </div>
                                <div class="col-md-3">
                                    <select class="form-select">
                                        <option value="">Filtrar por estado...</option>
                                        <option value="Pendiente">Pendiente</option>
                                        <option value="Aprobado">Aprobado</option>
                                        <option value="Rechazado">Rechazado</option>
                                        <option value="Recibido">Recibido</option>
                                    </select>
                                </div>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead class="bg-light">
                                    <tr>
                                        <th scope="col">ID Orden</th>
                                        <th scope="col">Producto</th>
                                        <th scope="col">SKU</th>
                                        <th scope="col">Cantidad Solicitada</th>
                                        <th scope="col">Estado</th>
                                        <th scope="col">Acciones</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <tr>
                                        <td>OC-001</td>
                                        <td>Arroz Extra 5kg</td>
                                        <td>BOD-0001</td>
                                        <td>50</td>
                                        <td><span class="badge bg-success">Aprobado</span></td>
                                        <td><button class="btn btn-sm btn-outline-primary">Ver Detalle</button></td>
                                    </tr>
                                    <tr>
                                        <td>OC-002</td>
                                        <td>Aceite Vegetal 1L</td>
                                        <td>BOD-0004</td>
                                        <td>100</td>
                                        <td><span class="badge bg-warning">Pendiente</span></td>
                                        <td><button class="btn btn-sm btn-outline-primary">Ver Detalle</button></td>
                                    </tr>
                                    <tr>
                                        <td>OC-003</td>
                                        <td>Leche entera 1L</td>
                                        <td>BOD-0021</td>
                                        <td>120</td>
                                        <td><span class="badge bg-secondary">Recibido</span></td>
                                        <td><button class="btn btn-sm btn-outline-primary">Ver Detalle</button></td>
                                    </tr>
                                    <tr>
                                        <td>OC-004</td>
                                        <td>Atún en lata 170g</td>
                                        <td>BOD-0038</td>
                                        <td>80</td>
                                        <td><span class="badge bg-danger">Rechazado</span></td>
                                        <td><button class="btn btn-sm btn-outline-primary">Ver Detalle</button></td>
                                    </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="footer">
                <div class="container-fluid px-4">
                    <div class="row">
                        <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
                            Copyright © 2025 Concept. All rights reserved. Dashboard by <a href="https://colorlib.com/wp/">Colorlib</a>.
                        </div>
                        <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12">
                            <div class="text-md-end footer-links d-none d-sm-block">
                                <a href="javascript: void(0);">About</a>
                                <a href="javascript: void(0);">Support</a>
                                <a href="javascript: void(0);">Contact Us</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>        </div>
    </div>

    <!-- Core JavaScript -->


</div>


<!-- Core JavaScript -->



<script nomodule>!function(){var e=document,t=e.createElement("script");if(!("noModule"in t)&&"onbeforeload"in t){var n=!1;e.addEventListener("beforeload",(function(e){if(e.target===t)n=!0;else if(!e.target.hasAttribute("nomodule")||!n)return;e.preventDefault()}),!0),t.type="module",t.src=".",e.head.appendChild(t),t.remove()}}();</script>
<script nomodule crossorigin id="vite-legacy-polyfill" src="../assets/js/polyfills-legacy-CRev7DxZ.js"></script>
<script nomodule crossorigin id="vite-legacy-entry" data-src="../assets/js/OrdenesDeCompra-legacy-BhFBVaMk.js">System.import(document.getElementById('vite-legacy-entry').getAttribute('data-src'))</script>
</body>
</html>
