<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Crear Usuario"/>
    </jsp:include>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="<%= request.getContextPath() %>/administrador/assets/css/style.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <title>Crear Usuario – Telito Bodeguero</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta charset="UTF-8">
    <style>
        .form-label { font-weight: 700; }
        .form-control, .form-select { font-weight: 600; }
        .form-control::placeholder { font-weight: 600; }
        .form-select option { font-weight: 600; }
        .btn { font-weight: 700; }
        .page-header .pageheader-title { font-weight: 800; }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Usuarios'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="row">
                <div class="col-12">
                    <div class="page-header pt-3">
                        <h2 class="pageheader-title"><i class="fas fa-user-plus me-2"></i>Crear Nuevo Usuario</h2>
                        <p class="pageheader-text">Complete los datos para registrar un nuevo usuario en el sistema.</p>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-xl-8 col-lg-10 col-md-12 col-sm-12 col-12 mx-auto">
                    <div class="card">
                        <div class="card-body">
                            <form action="<%= request.getContextPath() %>/UsuarioServlet?action=guardar" method="POST" autocomplete="off">
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="nombres" class="form-label">Nombres</label>
                                        <input type="text" class="form-control" id="nombres" name="nombres" placeholder="Ej: Juan" required>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="apellidos" class="form-label">Apellidos</label>
                                        <input type="text" class="form-control" id="apellidos" name="apellidos" placeholder="Ej: Pérez" required>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="email" class="form-label">Correo electrónico</label>
                                    <input type="email" class="form-control" id="email" name="email" placeholder="Ej: juan.perez@example.com" required>
                                </div>

                                <div class="mb-3">
                                    <label for="password" class="form-label">Contraseña</label>
                                    <input type="password" class="form-control" id="password" name="password" placeholder="********" required>
                                </div>

                                <div class="mb-3">
                                    <label for="rol" class="form-label">Rol</label>
                                    <select id="rol" name="rol_id" class="form-select" required>
                                        <option value="" disabled selected>Selecciona un rol</option>
                                        <option value="1">Administrador</option>
                                        <option value="2">Logística</option>
                                        <option value="3">Productor</option>
                                        <option value="4">Almacén</option>
                                    </select>
                                </div>

                                <div class="mt-4 pt-3 border-top d-flex justify-content-end">
                                    <a href="<%= request.getContextPath() %>/UsuarioServlet" class="btn btn-light me-2">Cancelar</a>
                                    <button type="submit" class="btn btn-primary">Crear Usuario</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
