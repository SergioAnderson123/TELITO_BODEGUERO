<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<title>${param.pageTitle} - Telito Bodeguero</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<!-- DataTables CSS -->
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.bootstrap5.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.4.2/css/buttons.bootstrap5.min.css">

<style>
    :root { --turquoise-dark:#6F4E37; --turquoise-medium:#8B6F47; --seafoam:#8B6F47; --seafoam-light:#FFFEF9; --white:#FFFEF9; --text-dark:#2b2d42; --text-muted:#6c757d; --border-color:#e9ecef; }
    body { font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif; margin:0; background-color:var(--seafoam-light); color:var(--text-dark); }
    .dashboard-main-wrapper { display:flex; min-height:100vh; }
    .dashboard-header { background:#FFFEF9; box-shadow:0 2px 10px rgba(0,0,0,.1); position:fixed; top:0; right:0; left:250px; z-index:999; height:70px; border-bottom:1px solid var(--border-color); }
    .dashboard-wrapper { margin-left:250px; width:calc(100% - 250px); min-height:100vh; }
    .dashboard-content { margin-top:70px; padding:30px; padding-bottom: 100px; }
    .page-header { margin-bottom:30px; }
    .page-header h2 { color:#6F4E37; font-weight:700; margin-bottom:10px; }
    .page-header p { color:var(--text-muted); font-size:1.05rem; }

    .nav-left-sidebar { width:250px; background:linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); min-height:100vh; position:fixed; left:0; top:0; z-index:1000; box-shadow:3px 0 15px rgba(0,0,0,.12); }
    .navbar-brand { font-weight:700; color:#6F4E37; }
    .nav-link { color:#F5DEB3 !important; padding:13px 20px; border-radius:10px; margin:6px 15px; transition:all .3s cubic-bezier(0.4, 0, 0.2, 1); display:flex; align-items:center; font-weight:500; position:relative; overflow:hidden; }
    .nav-link::before { content:''; position:absolute; left:0; top:0; bottom:0; width:4px; background:#F5DEB3; transform:scaleY(0); transition:transform .3s ease; border-radius:0 4px 4px 0; }
    .nav-link:hover, .nav-link.active { background-color:rgba(245, 222, 179, 0.15); color:#FFF8DC !important; transform:translateX(8px); box-shadow:0 4px 12px rgba(0,0,0,.15); }
    .nav-link:hover::before, .nav-link.active::before { transform:scaleY(1); }
    .nav-link i { margin-right:12px; width:22px; font-size:1.1rem; }
    .nav-divider { color:#F5DEB3; font-weight:700; padding:18px 20px 8px; margin-top:25px; font-size:.8rem; text-transform:uppercase; letter-spacing:1.5px; border-top:1px solid rgba(245, 222, 179, 0.3); }

    .card { background:#FFFEF9; padding:30px; border-radius:12px; box-shadow:0 4px 12px rgba(0,0,0,.06); margin-bottom:40px; border:2px solid #6F4E37; transition:box-shadow .3s ease; }
    .card:hover { box-shadow:0 8px 24px rgba(0,0,0,.1); }
    .card-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:25px; background:linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%); color:#fff; border-radius:12px 12px 0 0; padding:20px 30px; margin:-30px -30px 25px -30px; box-shadow:0 4px 12px rgba(111, 78, 55, 0.25); }
    .card-header h2, .card-header h5 { margin:0; color:#fff; font-weight:700; }

    .form-control, .form-select { border-radius:8px; border:2px solid var(--border-color); padding:12px 15px; transition:all .3s ease; }
    .form-control:focus, .form-select:focus { border-color:#6F4E37; box-shadow:0 0 0 .2rem rgba(111, 78, 55, 0.25); transform:translateY(-1px); }
    .btn-primary { background:linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%); border:none; color:#fff; font-weight:600; box-shadow:0 4px 12px rgba(111, 78, 55, 0.35); }
    .btn-primary:hover { background:linear-gradient(135deg, #8B6F47 0%, #A0826D 100%); transform:translateY(-2px); box-shadow:0 6px 16px rgba(111, 78, 55, 0.45); }

    .pagination .page-link { color:#6F4E37; border-color:var(--border-color); padding:10px 15px; border-radius:8px; margin:0 2px; transition:all .3s ease; }
    .pagination .page-link:hover { background-color:#FFFEF9; border-color:#6F4E37; transform:translateY(-2px); }
    .pagination .page-item.active .page-link { background:linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%); border-color:#6F4E37; color:#fff; box-shadow:0 4px 8px rgba(111, 78, 55, 0.35); }

    /* =====================
       Botón Hamburguesa
    ====================== */
    .sidebar-toggle {
        display: none;
        background: none;
        border: none;
        color: #6F4E37;
        font-size: 1.5rem;
        padding: 8px 12px;
        cursor: pointer;
        margin-right: 15px;
        transition: color 0.3s ease;
    }
    .sidebar-toggle:hover {
        color: #8B6F47;
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

    /* Estilos para el header en móvil */
    .navbar-nav .nav-link span {
        white-space: nowrap;
    }
    
    @media (max-width: 992px) { 
        .sidebar-toggle {
            display: inline-block;
        }
        .nav-left-sidebar { 
            position: fixed;
            transform:translateX(-100%); 
            transition:transform .3s ease;
            z-index: 1000;
        } 
        .nav-left-sidebar.open { 
            transform:translateX(0); 
        }
        .sidebar-overlay {
            display: block;
        }
        .dashboard-header { 
            left:0; 
            padding: 0 10px;
        }
        .dashboard-header .navbar {
            padding: 0;
        }
        .dashboard-header .container-fluid {
            padding: 0 10px;
        }
        .navbar-brand span {
            font-size: 0.9rem;
        }
        /* Ocultar nombre del usuario en móvil, solo mostrar avatar */
        .navbar-nav .nav-link span {
            display: none;
        }
        .navbar-nav .nav-link {
            padding: 8px 12px;
        }
        .dashboard-wrapper { margin-left:0; width:100%; } 
        .dashboard-content { padding:20px; }
        
        /* Asegurar que los botones sean clickeables en móvil */
        .config-card a,
        .btn,
        button,
        a[href] {
            touch-action: manipulation;
            -webkit-tap-highlight-color: rgba(0, 0, 0, 0.1);
            cursor: pointer;
        }
        .config-card {
            pointer-events: auto;
        }
    }
    
    @media (max-width: 576px) {
        .navbar-brand span {
            display: none;
        }
        .navbar-brand i {
            margin-right: 0;
        }
    }

    /* Chart specific styles */
    .charts-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 30px; margin-top: 30px; }
    .chart-container { position: relative; height: 300px; width: 100%; }
    .page-title { color: #6F4E37; font-weight: 700; margin-bottom: 30px; font-size: 2rem; }
    .page-title i { margin-right: 15px; color: #6F4E37; }
    
    /* Table styles */
    .table-card { background: var(--white); border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,.06); border: none; overflow:hidden; }
    .table-card .card-header { background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%); color: #fff; border-radius: 12px 12px 0 0; padding: 20px 30px; margin: 0; box-shadow:0 4px 12px rgba(111, 78, 55, 0.25); }
    .table-card .card-body { padding: 30px; }
    .table { margin-bottom: 0; }
    .table th { border-top: none; font-weight: 600; color: #6F4E37; padding: 15px; background-color:rgba(111, 78, 55, 0.06); }
    .table td { padding: 15px; vertical-align: middle; }
    .badge { font-size: 0.8rem; padding: 6px 12px; }
    .bg-success-soft { background-color: rgba(40, 167, 69, 0.1) !important; color: #28a745 !important; }
    .bg-warning-soft { background-color: rgba(255, 193, 7, 0.1) !important; color: #ffc107 !important; }
    .bg-danger-soft { background-color: rgba(220, 53, 69, 0.1) !important; color: #dc3545 !important; }
    .bg-secondary-soft { background-color: rgba(108, 117, 125, 0.1) !important; color: #6c757d !important; }
    
    /* Mejoras visuales adicionales - Animación hover mejorada */
    .table tbody tr {
        transition: all 0.3s ease;
        cursor: pointer;
    }
    .table tbody tr:hover {
        background-color: rgba(111, 78, 55, 0.1) !important;
        transform: scale(1.01);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    }
    .table tbody tr:hover td {
        color: #6F4E37;
        font-weight: 500;
    }
    
    .form-control:focus, .form-select:focus {
        border-color: #6F4E37;
        box-shadow: 0 0 0 0.2rem rgba(111, 78, 55, 0.25);
        transform: translateY(-1px);
    }
    
    .btn {
        transition: all 0.3s ease;
        font-weight: 500;
    }
    .btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
    }
    .btn:active {
        transform: translateY(0);
    }
    
    .card {
        transition: box-shadow 0.3s ease;
    }
    .card:hover {
        box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
    }
    
    .badge {
        font-weight: 500;
        letter-spacing: 0.3px;
    }
    
    .pageheader-title {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .pageheader-title i {
        color: #6F4E37;
    }
    
    /* Mejoras en los avatares */
    .avatar-wrapper img {
        transition: transform 0.2s ease;
    }
    .avatar-wrapper:hover img {
        transform: scale(1.1);
    }
    
    /* Mejoras en los dropdowns */
    .dropdown-menu {
        border-radius: 8px;
        border: 1px solid rgba(0, 0, 0, 0.1);
        padding: 8px 0;
    }
    .dropdown-item {
        padding: 10px 20px;
        transition: all 0.2s ease;
    }
    .dropdown-item:hover {
        background-color: rgba(131, 197, 190, 0.1);
        padding-left: 25px;
    }
    
    /* Mejoras en los inputs */
    .form-control, .form-select {
        transition: all 0.3s ease;
    }
    
    /* Animación suave para las tarjetas de estadísticas */
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    .stat-card {
        animation: fadeInUp 0.5s ease-out;
    }
    .stat-card:nth-child(1) { animation-delay: 0.1s; }
    .stat-card:nth-child(2) { animation-delay: 0.2s; }
    .stat-card:nth-child(3) { animation-delay: 0.3s; }
    
    /* Mejoras en los enlaces de acceso rápido */
    .quick-link-card {
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    /* Mejoras en los alertas */
    .alert {
        border-left: 4px solid;
        border-radius: 8px;
    }
    .alert-success {
        border-left-color: #28a745;
    }
    .alert-danger {
        border-left-color: #dc3545;
    }
    .alert-warning {
        border-left-color: #ffc107;
    }
    .alert-info {
        border-left-color: #17a2b8;
    }
    
    /* Estilos para DataTables */
    .dataTables_wrapper {
        padding: 0;
    }
    .dataTables_wrapper .dataTables_length,
    .dataTables_wrapper .dataTables_filter {
        margin-bottom: 1rem;
    }
    .dataTables_wrapper .dataTables_length select {
        border-radius: 8px;
        border: 2px solid var(--border-color);
        padding: 0.35rem 0.5rem;
    }
    .dataTables_wrapper .dataTables_filter input {
        border-radius: 8px;
        border: 2px solid var(--border-color);
        padding: 0.5rem 0.75rem;
        margin-left: 0.5rem;
    }
    .dataTables_wrapper .dataTables_filter input:focus {
        border-color: #6F4E37;
        box-shadow: 0 0 0 0.2rem rgba(111, 78, 55, 0.25);
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button {
        border-radius: 8px;
        margin: 0 2px;
        padding: 0.5rem 0.75rem;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button.current {
        background: linear-gradient(160deg, #6F4E37 0%, #8B6F47 100%) !important;
        border: none !important;
        color: white !important;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
        background: #8B6F47 !important;
        border: none !important;
        color: #6F4E37 !important;
    }
    .dt-buttons {
        margin-bottom: 1rem;
    }
    .dt-buttons .btn {
        margin-right: 0.5rem;
        margin-bottom: 0.5rem;
    }
    
    /* Mejoras responsive para DataTables */
    @media (max-width: 768px) {
        .dataTables_wrapper .dataTables_length,
        .dataTables_wrapper .dataTables_filter {
            text-align: left;
            margin-bottom: 0.5rem;
        }
        .dataTables_wrapper .dataTables_filter input {
            width: 100% !important;
            margin-left: 0;
            margin-top: 0.5rem;
        }
        .dt-buttons {
            text-align: left;
        }
        .dt-buttons .btn {
            width: 100%;
            margin-right: 0;
        }
    }
    
    /* ===================== ESTILOS RESPONSIVE GLOBALES ===================== */
    
    /* Tablas responsive */
    @media (max-width: 768px) {
        .table-card .card-body {
            padding: 15px !important;
        }
        .table-card .card-header {
            padding: 15px 20px !important;
        }
        .table th, .table td {
            padding: 0.5rem 0.4rem !important;
            font-size: 0.8rem !important;
        }
        .table th {
            font-size: 0.75rem !important;
        }
        .badge {
            font-size: 0.7rem !important;
            padding: 0.25rem 0.5rem !important;
        }
    }
    
    /* Modales responsive */
    @media (max-width: 768px) {
        .modal-dialog {
            margin: 10px !important;
            max-width: calc(100% - 20px) !important;
        }
        .modal-content {
            border-radius: 12px !important;
        }
        .modal-header, .modal-body, .modal-footer {
            padding: 15px !important;
        }
        .modal-title {
            font-size: 1.1rem !important;
        }
    }
    
    /* Formularios responsive */
    @media (max-width: 768px) {
        .form-control, .form-select {
            font-size: 16px !important; /* Evita zoom en iOS */
        }
        .form-label {
            font-size: 0.9rem !important;
            margin-bottom: 0.5rem !important;
        }
        .input-group {
            flex-wrap: wrap;
        }
        .input-group-text {
            font-size: 0.85rem !important;
        }
    }
    
    /* Botones responsive */
    @media (max-width: 768px) {
        .btn {
            padding: 0.5rem 1rem !important;
            font-size: 0.9rem !important;
        }
        .btn-sm {
            padding: 0.35rem 0.75rem !important;
            font-size: 0.8rem !important;
        }
        .btn-group {
            flex-wrap: wrap;
        }
        .d-flex.gap-2, .d-flex.gap-3 {
            flex-wrap: wrap;
        }
    }
    
    /* Cards y tarjetas responsive */
    @media (max-width: 768px) {
        .card {
            margin-bottom: 1rem !important;
        }
        .card-body {
            padding: 1rem !important;
        }
        .card-header {
            padding: 1rem !important;
        }
        .page-header {
            margin-bottom: 1.5rem !important;
        }
        .pageheader-title {
            font-size: 1.3rem !important;
        }
        .pageheader-text {
            font-size: 0.9rem !important;
        }
    }
    
    /* Grids y columnas responsive */
    @media (max-width: 768px) {
        .row.g-2, .row.g-3, .row.g-4 {
            margin-left: -0.5rem !important;
            margin-right: -0.5rem !important;
        }
        .row.g-2 > *, .row.g-3 > *, .row.g-4 > * {
            padding-left: 0.5rem !important;
            padding-right: 0.5rem !important;
        }
        [class*="col-"] {
            margin-bottom: 1rem;
        }
    }
    
    /* Filtros y búsquedas responsive */
    @media (max-width: 768px) {
        .filtros-container {
            margin-bottom: 1rem !important;
        }
        .filtros-container .row {
            margin-left: -0.5rem !important;
            margin-right: -0.5rem !important;
        }
        .filtros-container [class*="col-"] {
            padding-left: 0.5rem !important;
            padding-right: 0.5rem !important;
            margin-bottom: 0.75rem;
        }
        .filtros-container .btn {
            width: 100%;
            margin-bottom: 0.5rem;
        }
    }
    
    /* Tabs responsive */
    @media (max-width: 768px) {
        .nav-tabs {
            flex-wrap: wrap;
            padding: 0.5rem !important;
        }
        .nav-tabs .nav-link {
            padding: 0.5rem 0.75rem !important;
            font-size: 0.85rem !important;
            margin-bottom: 0.25rem;
        }
        .nav-tabs-sm .nav-link {
            padding: 0.4rem 0.6rem !important;
            font-size: 0.8rem !important;
        }
    }
    
    /* Accordions responsive */
    @media (max-width: 768px) {
        .accordion-button {
            padding: 0.75rem 1rem !important;
            font-size: 0.9rem !important;
        }
        .accordion-body {
            padding: 0.75rem !important;
        }
        .accordion-item {
            margin-bottom: 0.75rem !important;
        }
    }
    
    /* Dropdowns responsive */
    @media (max-width: 768px) {
        .dropdown-menu {
            min-width: 160px !important;
            font-size: 0.85rem !important;
        }
        .dropdown-item {
            padding: 0.5rem 0.75rem !important;
        }
        .notificaciones-dropdown {
            width: calc(100vw - 40px) !important;
            max-width: 380px !important;
            left: auto !important;
            right: 10px !important;
        }
    }
    
    /* Paginación responsive */
    @media (max-width: 768px) {
        .pagination {
            flex-wrap: wrap;
            justify-content: center;
        }
        .pagination .page-link {
            padding: 0.4rem 0.6rem !important;
            font-size: 0.85rem !important;
        }
    }
    
    /* Alerts responsive */
    @media (max-width: 768px) {
        .alert {
            padding: 0.75rem 1rem !important;
            font-size: 0.9rem !important;
        }
    }
    
    /* Charts responsive */
    @media (max-width: 768px) {
        .charts-grid {
            grid-template-columns: 1fr !important;
            gap: 20px !important;
        }
        .chart-container {
            height: 250px !important;
        }
    }
    
    /* Report cards responsive */
    @media (max-width: 768px) {
        .report-card {
            margin-bottom: 1.5rem !important;
        }
        .report-card-header {
            padding: 20px !important;
        }
        .report-card-body {
            padding: 15px 20px !important;
        }
        .report-card-footer {
            padding: 12px 20px !important;
        }
        .report-icon {
            font-size: 2rem !important;
        }
        .report-title {
            font-size: 1.1rem !important;
        }
        .report-description {
            font-size: 0.85rem !important;
        }
        .stat-item {
            padding: 10px !important;
        }
        .stat-number {
            font-size: 1.3rem !important;
        }
        .stat-label {
            font-size: 0.7rem !important;
        }
    }
    
    @media (max-width: 768px) {
        .config-item {
            padding: 0.75rem !important;
            margin-bottom: 1rem !important;
        }
        .config-label {
            font-size: 0.9rem !important;
        }
        .config-description {
            font-size: 0.8rem !important;
        }
    }
    
    /* Inventario general responsive */
    @media (max-width: 768px) {
        .accordion-button {
            flex-direction: column;
            align-items: flex-start !important;
        }
        .accordion-button .d-flex {
            flex-direction: column;
            width: 100%;
        }
        .accordion-button .badge {
            margin-top: 0.5rem;
            margin-right: 0.5rem;
        }
    }
    
    /* Muy pequeños (menos de 576px) */
    @media (max-width: 576px) {
        .dashboard-content {
            padding: 15px !important;
        }
        .container-fluid {
            padding-left: 0.5rem !important;
            padding-right: 0.5rem !important;
        }
        .page-header {
            padding: 15px !important;
        }
        .pageheader-title {
            font-size: 1.2rem !important;
        }
        .table-responsive {
            font-size: 0.8rem;
        }
        .btn-group-vertical {
            width: 100%;
        }
        .btn-group-vertical .btn {
            width: 100%;
            margin-bottom: 0.25rem;
        }
    }
</style>

<!-- Incluir modales personalizados -->
<jsp:include page="/WEB-INF/includes/modal-alerts.jsp" />

