<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<title>${param.pageTitle} - Telito Bodeguero</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

<style>
    :root { --turquoise-dark:#006d77; --seafoam:#83c5be; --seafoam-light:#edf6f9; --white:#ffffff; --text-dark:#2b2d42; --text-muted:#6c757d; --border-color:#e9ecef; }
    body { font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif; margin:0; background-color:var(--seafoam-light); color:var(--text-dark); }
    .dashboard-main-wrapper { display:flex; min-height:100vh; }
    .dashboard-header { background:#fff; box-shadow:0 2px 10px rgba(0,0,0,.1); position:fixed; top:0; right:0; left:250px; z-index:999; height:70px; border-bottom:1px solid var(--border-color); }
    .dashboard-wrapper { margin-left:250px; width:calc(100% - 250px); min-height:100vh; }
    .dashboard-content { margin-top:70px; padding:30px; }
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

    @media (max-width: 992px) { .nav-left-sidebar { transform:translateX(-100%); transition:transform .3s ease; } .nav-left-sidebar.open { transform:translateX(0); } .dashboard-header { left:0; } .dashboard-wrapper { margin-left:0; width:100%; } .dashboard-content { padding:20px; } }
</style>

