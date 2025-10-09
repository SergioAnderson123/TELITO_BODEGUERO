<div class="dashboard-header">
    <nav class="navbar navbar-expand fixed-top">
        <div class="container-fluid">
            <button class="navbar-toggler sidebar-toggler me-3 d-lg-none" type="button" aria-label="Toggle sidebar">
                <span class="navbar-toggler-icon"></span>
            </button>

            <a class="navbar-brand d-flex align-items-center ms-3" href="${pageContext.request.contextPath}/almacen/LoteServlet">
                <img src="${pageContext.request.contextPath}/almacen/dist/assets/images/telito-CfoOZLNj.jpg"
                     alt="Logo Telito" style="height:32px; width:auto;" class="me-2">
                <span class="fw-bold">Telito Bodeguero</span>
            </a>

            <ul class="navbar-nav ms-auto navbar-right-top">
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
                        <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/LogoutServlet"><i class="fas fa-power-off me-2"></i>Logout</a>
                    </div>
                </li>
            </ul>
        </div>
    </nav>
</div>