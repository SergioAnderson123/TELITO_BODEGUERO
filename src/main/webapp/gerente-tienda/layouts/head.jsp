<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<title>${param.pageTitle} - Telito Bodeguero</title>

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Font Awesome -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

<!-- Custom CSS (turquesa/verde agua) - Mismo estilo que Productor -->
<style>
    /* =====================
       Paleta y tokens
    ====================== */
    :root {
        --turquoise-dark: #6F4E37;
        --seafoam: #8B6F47;
        --seafoam-light: #FFFEF9;
        --white: #FFFEF9;
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
        background-color: #FFFEF9;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        position: fixed; top: 0; right: 0; left: 250px; z-index: 999;
        height: 70px; border-bottom: 1px solid var(--border-color);
    }
    .dashboard-wrapper { margin-left: 250px; width: calc(100% - 250px); min-height: 100vh; }
    .dashboard-content { margin-top: 70px; padding: 20px; }
    .page-header { margin-bottom: 0.5rem; padding-top: 0.5rem; padding-bottom: 0.5rem; }
    .page-header h2 { color: #6F4E37; font-weight: 700; margin-bottom: 0; font-size: 1.4rem; line-height: 1.2; }
    .page-header p { color: var(--text-muted); font-size: 0.85rem; margin-top: 0.2rem; margin-bottom: 0; }
    .pageheader-title {
        display: flex;
        align-items: center;
        gap: 10px;
        color: #6F4E37 !important;
    }
    .pageheader-title i {
        color: #6F4E37;
    }

    /* =====================
       Sidebar (igual a productor)
    ====================== */
    .nav-left-sidebar {
        width: 250px;
        background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%);
        min-height: 100vh;
        position: fixed;
        left: 0;
        top: 0;
        z-index: 1000;
        box-shadow: 3px 0 15px rgba(0,0,0,.12);
    }
    .navbar-brand { font-weight: 700; color: #6F4E37; }
    .nav-link {
        color: #F5DEB3 !important;
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
        background-color: rgba(245, 222, 179, 0.15);
        color: #FFF8DC !important;
        transform: translateX(8px);
        box-shadow: 0 4px 12px rgba(0,0,0,.15);
    }
    .nav-link:hover::before, .nav-link.active::before {
        transform: scaleY(1);
    }
    .nav-link i { margin-right: 12px; width: 22px; font-size: 1.1rem; }
    .nav-divider {
        color: #F5DEB3;
        font-weight: 700;
        padding: 18px 20px 8px;
        margin-top: 25px;
        font-size: .8rem;
        text-transform: uppercase;
        letter-spacing: 1.5px;
        border-top: 1px solid rgba(245, 222, 179, 0.3);
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
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .stat-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 10px rgba(0,0,0,0.08);
    }
    .stat-card h3 { margin: 0 0 10px 0; font-size: 1rem; color: #6c757d; font-weight: 600; }
    .stat-card p { margin: 0; font-size: 2rem; font-weight: 800; color: #6F4E37; }
    .stat-icon {
        font-size: 2.2rem;
        opacity: 0.15;
        flex-shrink: 0;
    }
    .stat-number {
        font-size: 2.5rem;
        font-weight: 700;
        color: #6F4E37;
    }
    .stat-label {
        color: var(--text-muted);
        font-size: 0.9rem;
        margin-top: 8px;
    }
    
    .card {
        border: 2px solid #6F4E37;
        border-radius: 15px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.08);
        transition: transform 0.3s ease;
        margin-bottom: 20px;
        background-color: #FFFEF9;
    }
    .card:hover {
        transform: translateY(-2px);
    }
    .card-header {
        background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%);
        color: white;
        border-radius: 15px 15px 0 0 !important;
        border: none;
        padding: 15px 20px;
    }
    
    .table {
        margin-bottom: 0;
    }
    .table thead {
        background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%);
        color: white;
    }
    .table thead th {
        border: none;
        padding: 15px;
        font-weight: 600;
        text-transform: uppercase;
        font-size: 0.85rem;
        letter-spacing: 0.5px;
    }
    .table tbody tr {
        transition: background-color 0.2s;
    }
    .table tbody tr:hover {
        background-color: var(--seafoam-light);
    }
    .table tbody td {
        padding: 15px;
        vertical-align: middle;
    }
    
    /* Botón Hamburguesa */
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
        display: block;
        opacity: 1;
    }
    /* Responsive sidebar */
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
        .dashboard-header { left: 0; }
        .dashboard-wrapper { margin-left: 0; width: 100%; }
    }
    
    @media (max-width: 768px) {
        .stats-container { grid-template-columns: 1fr; }
    }
</style>

