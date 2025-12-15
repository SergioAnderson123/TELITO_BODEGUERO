<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Redirección automática a la URL correcta del servlet
    response.sendRedirect(request.getContextPath() + "/almacen/PedidoServlet?action=lista");
%>
