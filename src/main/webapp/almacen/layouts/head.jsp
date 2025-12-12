<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<title>${param.pageTitle} - Telito Bodeguero</title>

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Font Awesome -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

<!-- Custom CSS (turquesa/verde agua) -->
<style>
    /* =====================
       Paleta y tokens (IDÉNTICA AL ADMINISTRADOR)
    ====================== */
    :root {
        --turquoise-dark: #00a896;
        --turquoise-medium: #028f80;
        --seafoam: #83c5be;
        --seafoam-light: #edf6f9;
        --white: #ffffff;
        --text-dark: #2b2d42;
        --text-muted: #6c757d;
        --border-color: #e9ecef;
    }

    /* =====================
       Layout base
    ====================== */
    body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        margin: 0;
        background-color: var(--seafoam-light);
        color: var(--text-dark);
    }
    
    /* =====================
       Contenedores
    ====================== */
    .dashboard-main-wrapper { display: flex; min-height: 100vh; }
    .dashboard-header {
        background-color: #fff;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        position: fixed; top: 0; right: 0; left: 250px; z-index: 999;
        height: 70px; border-bottom: 1px solid var(--border-color);
    }
    .dashboard-wrapper { margin-left: 250px; width: calc(100% - 250px); min-height: 100vh; }
    .dashboard-content { margin-top: 70px; padding: 30px; }
    .page-header { margin-bottom: 30px; }
    .page-header h2 { color: var(--turquoise-dark); font-weight: 700; margin-bottom: 10px; }
    .page-header p { color: var(--text-muted); font-size: 1.05rem; }

    /* =====================
       Sidebar (IDÉNTICO AL ADMINISTRADOR)
    ====================== */
    .nav-left-sidebar {
        width: 250px;
        background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%);
        min-height: 100vh;
        position: fixed;
        left: 0;
        top: 0;
        z-index: 1000;
        box-shadow: 3px 0 15px rgba(0,0,0,.12);
    }
    .navbar-brand { font-weight: 700; color: var(--turquoise-dark); }
    .nav-link {
        color: rgba(255,255,255,.95) !important;
        padding: 13px 20px;
        border-radius: 10px;
        margin: 6px 15px;
        transition: all .3s cubic-bezier(0.4, 0, 0.2, 1);
        display: flex;
        align-items: center;
        font-weight: 500;
        position: relative;
        overflow: hidden;
    }
    .nav-link::before {
        content: '';
        position: absolute;
        left: 0;
        top: 0;
        bottom: 0;
        width: 4px;
        background: #fff;
        transform: scaleY(0);
        transition: transform .3s ease;
        border-radius: 0 4px 4px 0;
    }
    .nav-link:hover, .nav-link.active {
        background-color: rgba(255,255,255,.25);
        color: #fff !important;
        transform: translateX(8px);
        box-shadow: 0 4px 12px rgba(0,0,0,.15);
    }
    .nav-link:hover::before, .nav-link.active::before {
        transform: scaleY(1);
    }
    .nav-link i { margin-right: 12px; width: 22px; font-size: 1.1rem; }
    .nav-divider {
        color: rgba(255,255,255,.95);
        font-weight: 700;
        padding: 18px 20px 8px;
        margin-top: 25px;
        font-size: .8rem;
        text-transform: uppercase;
        letter-spacing: 1.5px;
        border-top: 1px solid rgba(255,255,255,.15);
    }

    /* =====================
       Tarjetas/Tabla/Formularios
    ====================== */
    .stats-container { display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; margin-bottom: 40px; }
    .stat-card {
        background-color: var(--white);
        padding: 25px;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
    }
    .stat-card h3 { margin: 0 0 10px 0; font-size: 1rem; color: var(--text-muted); font-weight: 600; }
    .stat-card p { margin: 0; font-size: 2rem; font-weight: 800; color: var(--turquoise-dark); }

    /* Card principal */
    .card {
        background-color: var(--white);
        padding: 30px;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        margin-bottom: 40px;
        border: none;
    }
    .card-header { 
        display: flex; 
        justify-content: space-between; 
        align-items: center; 
        margin-bottom: 25px; 
        background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
        color: white;
        border-radius: 12px 12px 0 0;
        padding: 20px 30px;
        margin: -30px -30px 25px -30px;
    }
    .card-header h2, .card-header h5 { margin: 0; color: white; }
    .card-body { padding: 0; }

    /* Formularios y Botones */
    form label { display: block; margin-bottom: 8px; font-weight: 600; color: var(--text-dark); }
    form input, form select, form textarea {
        width: 100%; padding: 12px; border: 1.5px solid var(--border-color); border-radius: 8px; box-sizing: border-box; font-size: 1rem;
    }
    .form-control, .form-select { 
        border-radius: 8px; 
        border: 2px solid var(--border-color); 
        padding: 12px 15px; 
        transition: all 0.3s ease; 
    }
    .form-control:focus, .form-select:focus { 
        border-color: var(--seafoam); 
        box-shadow: 0 0 0 0.2rem rgba(131, 197, 190, 0.35); 
    }
    .form-label { font-weight: 600; color: var(--text-dark); margin-bottom: 8px; }
    
    button, .btn {
        background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
        color: var(--white);
        border: none; padding: 12px 24px; border-radius: 8px; cursor: pointer; font-size: 1rem; font-weight: 600; transition: transform 0.2s, box-shadow 0.2s;
    }
    .btn-secondary { background: #8d99ae; }
    .btn-primary { background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); }
    .btn-info { background: linear-gradient(160deg, #17a2b8 0%, #20c997 100%); }
    .btn-success { background: linear-gradient(160deg, #28a745 0%, #20c997 100%); }
    .btn-warning { background: linear-gradient(160deg, #ffc107 0%, #fd7e14 100%); color: #000; }
    .btn-danger { background: linear-gradient(160deg, #dc3545 0%, #e74c3c 100%); }
    button:hover, .btn:hover { transform: translateY(-2px); box-shadow: 0 6px 14px rgba(0, 109, 119, 0.25); }

    /* Tabla */
    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 15px; text-align: center; border-bottom: 1px solid var(--border-color); }
    thead th { background-color: var(--seafoam-light); font-weight: 700; color: var(--text-muted); text-transform: uppercase; font-size: 0.85rem; }
    tbody tr { transition: all 0.3s ease; cursor: pointer; }
    tbody tr:hover { 
        background-color: rgba(0, 168, 150, 0.1) !important; 
        transform: scale(1.01);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    }
    tbody tr:hover td {
        color: var(--turquoise-dark);
        font-weight: 500;
    }
    .table-responsive { border-radius: 8px; overflow: hidden; }
    
    /* Estilos de table-card (igual al administrador) */
    .table-card { background: var(--white); border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,.06); border: none; overflow:hidden; }
    .table-card .card-header { background: linear-gradient(135deg, #00a896 0%, #028f80 100%); color: #fff; border-radius: 12px 12px 0 0; padding: 20px 30px; margin: 0; box-shadow:0 4px 12px rgba(0,168,150,.25); }
    .table-card .card-body { padding: 30px; }
    .table { margin-bottom: 0; }
    .table th { border-top: none; font-weight: 600; color: #00a896; padding: 15px; background-color:rgba(0,168,150,.06); }
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
        background-color: rgba(0, 168, 150, 0.1) !important;
        transform: scale(1.01);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    }
    .table tbody tr:hover td {
        color: var(--turquoise-dark);
        font-weight: 500;
    }

    /* Badges */
    .badge { padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
    .bg-success { background: linear-gradient(160deg, #28a745 0%, #20c997 100%) !important; }
    .bg-warning { background: linear-gradient(160deg, #ffc107 0%, #fd7e14 100%) !important; color: #000 !important; }
    .bg-danger { background: linear-gradient(160deg, #dc3545 0%, #e74c3c 100%) !important; }
    .bg-info { background: linear-gradient(160deg, #17a2b8 0%, #20c997 100%) !important; }
    .bg-primary { background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%) !important; }

    /* Estilos de botones mejorados */
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
        box-shadow: 0 8px 24px rgba(0,0,0,.1);
    }

    /* Paginación */
    .pagination .page-link {
        color: var(--turquoise-dark);
        border-color: var(--border-color);
        padding: 10px 15px;
        border-radius: 8px;
        margin: 0 2px;
    }
    .pagination .page-link:hover {
        background-color: var(--seafoam-light);
        border-color: var(--seafoam);
    }
    .pagination .page-item.active .page-link {
        background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
        border-color: var(--turquoise-dark);
    }

    /* Búsqueda */
    .top-search-bar {
        position: relative;
        margin-bottom: 20px;
    }
    .search-icon {
        position: absolute;
        left: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--text-muted);
        z-index: 10;
    }
    .top-search-bar .form-control {
        padding-left: 45px;
        border-radius: 25px;
        border: 2px solid var(--border-color);
        background-color: var(--white);
    }
    .top-search-bar .form-control:focus {
        border-color: var(--seafoam);
        box-shadow: 0 0 0 0.2rem rgba(131, 197, 190, 0.35);
    }

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

    /* =====================
       Responsive
    ====================== */
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
        .dashboard-header { 
            left: 0; 
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
        .dashboard-wrapper { margin-left: 0; width: 100%; }
        .dashboard-content { padding: 20px; }
        .stats-container { grid-template-columns: 1fr; }
        
        /* Asegurar que los botones sean clickeables en móvil */
        .btn,
        button,
        a[href] {
            touch-action: manipulation;
            -webkit-tap-highlight-color: rgba(0, 0, 0, 0.1);
            cursor: pointer;
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
</style>
