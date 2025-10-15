
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.Job" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%

    ArrayList<Job> lista = (ArrayList<Job>) request.getAttribute("lista");
%>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Lista de Trabajos"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='Distribucion'/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="row">
                <div class="col-12">
                    <div class="page-header"><h2><i class="fas fa-list me-2"></i>Lista de Trabajos</h2></div>
                </div>
            </div>
            <div class="card">
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover text-center">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Zona</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% for (Job job : lista){ %>
                                <tr>
                                    <td><%=job.getIdZona()%></td>
                                    <td><%=job.getNombre()%></td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/logistica/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
