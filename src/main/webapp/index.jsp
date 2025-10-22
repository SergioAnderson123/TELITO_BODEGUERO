<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    System.out.println("index.jsp ejecutándose - redirigiendo a LoginServlet");
    // Redirect to login page
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
%>