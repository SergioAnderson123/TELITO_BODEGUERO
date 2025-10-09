
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.example.webbapplogistica.model.beans.Job" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%

    ArrayList<Job> lista = (ArrayList<Job>) request.getAttribute("lista");
%>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <h1>Lista de Trabajos</h1>
    <table>
        <tr>
            <th>ID</th>
            <th>Zona</th>
        </tr>
        <% for (Job job : lista){ %>
        <tr>
            <td><%=job.getIdZona()%></td>
            <td><%=job.getNombre()%></td>
        </tr>
        <% } %>
    </table>
</body>
</html>
