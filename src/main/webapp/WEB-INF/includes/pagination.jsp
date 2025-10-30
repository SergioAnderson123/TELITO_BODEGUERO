<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
    Componente reutilizable de paginación
    
    Parámetros requeridos:
    - currentPage: Página actual (Integer)
    - totalPages: Total de páginas (Integer)
    - totalRows: Total de registros (Integer)
    - size: Registros por página (Integer)
    - baseUrl: URL base del servlet (String)
    - itemName: Nombre del tipo de item (ej: "productos", "usuarios") (String)
    
    Parámetros opcionales (filtros que se deben mantener):
    - param1Name, param1Value
    - param2Name, param2Value
    - param3Name, param3Value
--%>
<%
    // Obtener parámetros
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalRows = (Integer) request.getAttribute("totalRows");
    Integer size = (Integer) request.getAttribute("size");
    String baseUrl = (String) request.getAttribute("baseUrl");
    String itemName = (String) request.getAttribute("itemName");
    
    // Parámetros adicionales para filtros
    String param1Name = (String) request.getAttribute("param1Name");
    String param1Value = (String) request.getAttribute("param1Value");
    String param2Name = (String) request.getAttribute("param2Name");
    String param2Value = (String) request.getAttribute("param2Value");
    String param3Name = (String) request.getAttribute("param3Name");
    String param3Value = (String) request.getAttribute("param3Value");
    
    // Valores por defecto
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;
    if (totalRows == null) totalRows = 0;
    if (size == null) size = 10;
    if (itemName == null) itemName = "registros";
    
    // Calcular rango de registros mostrados
    int startRow = totalRows > 0 ? (currentPage - 1) * size + 1 : 0;
    int endRow = Math.min(currentPage * size, totalRows);
    
    // Construir string de parámetros adicionales
    StringBuilder additionalParams = new StringBuilder();
    if (param1Name != null && param1Value != null && !param1Value.isEmpty()) {
        additionalParams.append("&").append(param1Name).append("=").append(java.net.URLEncoder.encode(param1Value, "UTF-8"));
    }
    if (param2Name != null && param2Value != null && !param2Value.isEmpty()) {
        additionalParams.append("&").append(param2Name).append("=").append(java.net.URLEncoder.encode(param2Value, "UTF-8"));
    }
    if (param3Name != null && param3Value != null && !param3Value.isEmpty()) {
        additionalParams.append("&").append(param3Name).append("=").append(java.net.URLEncoder.encode(param3Value, "UTF-8"));
    }
%>

<% if (totalPages > 1 || totalRows > 0) { %>
<div class="d-flex justify-content-between align-items-center mt-3 flex-wrap">
    <div class="pagination-info mb-2 mb-sm-0">
        <span class="text-muted">
            <% if (totalRows > 0) { %>
                Mostrando <%= startRow %>-<%= endRow %> de <%= totalRows %> <%= itemName %>
            <% } else { %>
                No hay registros para mostrar
            <% } %>
        </span>
    </div>

    <% if (totalPages > 1) { %>
    <nav aria-label="Paginación">
        <ul class="pagination pagination-sm mb-0">
            <%-- Botón Anterior --%>
            <li class="page-item <%= (currentPage <= 1) ? "disabled" : "" %>">
                <a class="page-link" href="<%= baseUrl %>?page=<%= currentPage - 1 %>&size=<%= size %><%= additionalParams %>" tabindex="-1">
                    <i class="fas fa-chevron-left"></i>
                </a>
            </li>

            <%-- Primera página --%>
            <% if (currentPage > 3) { %>
            <li class="page-item">
                <a class="page-link" href="<%= baseUrl %>?page=1&size=<%= size %><%= additionalParams %>">1</a>
            </li>
            <% if (currentPage > 4) { %>
            <li class="page-item disabled"><span class="page-link">...</span></li>
            <% } %>
            <% } %>

            <%-- Páginas alrededor de la actual --%>
            <%
                int startPage = Math.max(1, currentPage - 2);
                int endPage = Math.min(totalPages, currentPage + 2);
                for (int i = startPage; i <= endPage; i++) {
            %>
            <li class="page-item <%= (i == currentPage) ? "active" : "" %>">
                <a class="page-link" href="<%= baseUrl %>?page=<%= i %>&size=<%= size %><%= additionalParams %>"><%= i %></a>
            </li>
            <% } %>

            <%-- Última página --%>
            <% if (currentPage < totalPages - 2) { %>
            <% if (currentPage < totalPages - 3) { %>
            <li class="page-item disabled"><span class="page-link">...</span></li>
            <% } %>
            <li class="page-item">
                <a class="page-link" href="<%= baseUrl %>?page=<%= totalPages %>&size=<%= size %><%= additionalParams %>"><%= totalPages %></a>
            </li>
            <% } %>

            <%-- Botón Siguiente --%>
            <li class="page-item <%= (currentPage >= totalPages) ? "disabled" : "" %>">
                <a class="page-link" href="<%= baseUrl %>?page=<%= currentPage + 1 %>&size=<%= size %><%= additionalParams %>">
                    <i class="fas fa-chevron-right"></i>
                </a>
            </li>
        </ul>
    </nav>
    <% } %>
</div>
<% } %>

