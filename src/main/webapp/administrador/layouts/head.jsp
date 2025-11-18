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
    :root { --turquoise-dark:#006d77; --seafoam:#83c5be; --seafoam-light:#edf6f9; --white:#ffffff; --text-dark:#2b2d42; --text-muted:#6c757d; --border-color:#e9ecef; }
    body { font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif; margin:0; background-color:var(--seafoam-light); color:var(--text-dark); }
    .dashboard-main-wrapper { display:flex; min-height:100vh; }
    .dashboard-header { background:#fff; box-shadow:0 2px 10px rgba(0,0,0,.1); position:fixed; top:0; right:0; left:250px; z-index:999; height:70px; border-bottom:1px solid var(--border-color); }
    .dashboard-wrapper { margin-left:250px; width:calc(100% - 250px); min-height:100vh; }
    .dashboard-content { margin-top:70px; padding:30px; padding-bottom: 100px; }
    .page-header { margin-bottom:30px; }
    .page-header h2 { color:var(--turquoise-dark); font-weight:700; margin-bottom:10px; }
    .page-header p { color:var(--text-muted); font-size:1.05rem; }

    .nav-left-sidebar { width:250px; background:linear-gradient(160deg, var(--turquoise-dark) 0%, #055e68 100%); min-height:100vh; position:fixed; left:0; top:0; z-index:1000; box-shadow:2px 0 10px rgba(0,0,0,.1); }
    .navbar-brand { font-weight:700; color:var(--turquoise-dark); }
    .nav-link { color:rgba(255,255,255,.9) !important; padding:12px 20px; border-radius:8px; margin:5px 15px; transition:all .3s ease; display:flex; align-items:center; }
    .nav-link:hover, .nav-link.active { background-color:rgba(255,255,255,.18); color:#fff !important; transform:translateX(5px); }
    .nav-link i { margin-right:10px; width:20px; }
    .nav-divider { color:rgba(255,255,255,.8); font-weight:600; padding:15px 20px 5px; margin-top:20px; font-size:.85rem; text-transform:uppercase; letter-spacing:1px; }

    .card { background:var(--white); padding:30px; border-radius:12px; box-shadow:0 4px 12px rgba(0,0,0,.06); margin-bottom:40px; border:none; }
    .card-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:25px; background:linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); color:#fff; border-radius:12px 12px 0 0; padding:20px 30px; margin:-30px -30px 25px -30px; }
    .card-header h2, .card-header h5 { margin:0; color:#fff; }

    .form-control, .form-select { border-radius:8px; border:2px solid var(--border-color); padding:12px 15px; transition:all .3s ease; }
    .form-control:focus, .form-select:focus { border-color:var(--seafoam); box-shadow:0 0 0 .2rem rgba(131,197,190,.35); }
    .btn-primary { background:linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); border:none; }

    .pagination .page-link { color:var(--turquoise-dark); border-color:var(--border-color); padding:10px 15px; border-radius:8px; margin:0 2px; }
    .pagination .page-item.active .page-link { background:linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); border-color:var(--turquoise-dark); }

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
    .page-title { color: var(--turquoise-dark); font-weight: 700; margin-bottom: 30px; font-size: 2rem; }
    .page-title i { margin-right: 15px; color: var(--seafoam); }
    
    /* Table styles */
    .table-card { background: var(--white); border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,.06); border: none; }
    .table-card .card-header { background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); color: #fff; border-radius: 12px 12px 0 0; padding: 20px 30px; margin: 0; }
    .table-card .card-body { padding: 30px; }
    .table { margin-bottom: 0; }
    .table th { border-top: none; font-weight: 600; color: var(--turquoise-dark); padding: 15px; }
    .table td { padding: 15px; vertical-align: middle; }
    .badge { font-size: 0.8rem; padding: 6px 12px; }
    .bg-success-soft { background-color: rgba(40, 167, 69, 0.1) !important; color: #28a745 !important; }
    .bg-warning-soft { background-color: rgba(255, 193, 7, 0.1) !important; color: #ffc107 !important; }
    .bg-danger-soft { background-color: rgba(220, 53, 69, 0.1) !important; color: #dc3545 !important; }
    .bg-secondary-soft { background-color: rgba(108, 117, 125, 0.1) !important; color: #6c757d !important; }
    
    /* Mejoras visuales adicionales */
    .table tbody tr {
        transition: background-color 0.2s ease;
    }
    .table tbody tr:hover {
        background-color: rgba(131, 197, 190, 0.05);
    }
    
    .form-control:focus, .form-select:focus {
        border-color: var(--seafoam);
        box-shadow: 0 0 0 0.2rem rgba(131, 197, 190, 0.25);
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
        color: var(--seafoam);
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
        border-color: var(--seafoam);
        box-shadow: 0 0 0 0.2rem rgba(131, 197, 190, 0.25);
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button {
        border-radius: 8px;
        margin: 0 2px;
        padding: 0.5rem 0.75rem;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button.current {
        background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%) !important;
        border: none !important;
        color: white !important;
    }
    .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
        background: var(--seafoam) !important;
        border: none !important;
        color: var(--turquoise-dark) !important;
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
</style>

<!-- Incluir modales personalizados -->
<jsp:include page="/WEB-INF/includes/modal-alerts.jsp" />
