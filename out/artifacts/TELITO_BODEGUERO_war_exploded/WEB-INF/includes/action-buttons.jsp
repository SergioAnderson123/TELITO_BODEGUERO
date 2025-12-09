<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    boolean isReadOnly = "readonly".equals(session.getAttribute("viewMode"));
%>

<%!
    public String getActionButtonHtml(HttpServletRequest request, String href, String icon, String text, String btnClass) {
        boolean isReadOnly = "readonly".equals(request.getSession().getAttribute("viewMode"));
        if (isReadOnly) {
            return "";
        }
        return String.format(
            "<a href=\"%s\" class=\"btn btn-sm %s\"><i class=\"%s me-2\"></i>%s</a>",
            href, btnClass, icon, text
        );
    }

    public String getActionDropdownHtml(HttpServletRequest request, String baseUrl, String id) {
        boolean isReadOnly = "readonly".equals(request.getSession().getAttribute("viewMode"));
        if (isReadOnly) {
            return "<button class=\"btn btn-sm btn-light\" type=\"button\"><i class=\"fas fa-eye\"></i></button>";
        }
        return String.format(
            "<div class=\"dropdown\">" +
            "    <button class=\"btn btn-sm btn-light\" type=\"button\" data-bs-toggle=\"dropdown\"><i class=\"fas fa-ellipsis-h\"></i></button>" +
            "    <ul class=\"dropdown-menu dropdown-menu-end\">" +
            "        <li><a class=\"dropdown-item\" href=\"%s/action=editar&id=%s\"><i class=\"fas fa-edit me-2\"></i>Editar</a></li>" +
            "        <li><a class=\"dropdown-item text-danger\" href=\"%s/action=borrar&id=%s\" onclick=\"return confirm('¿Estás seguro?');\"><i class=\"fas fa-trash me-2\"></i>Eliminar</a></li>" +
            "    </ul>" +
            "</div>",
            baseUrl, id, baseUrl, id
        );
    }
%>