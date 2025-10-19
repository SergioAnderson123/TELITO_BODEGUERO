<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Redirigir automáticamente al inicio
    response.sendRedirect(request.getContextPath() + "/home");
%>