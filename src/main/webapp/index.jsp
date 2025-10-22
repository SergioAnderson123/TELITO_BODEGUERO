<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Redirige a la página de login correcta
    response.sendRedirect(request.getContextPath() + "/acceso/login");
%>