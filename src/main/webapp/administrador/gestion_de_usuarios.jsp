<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%@ page import="com.example.telito.almacen.beans.Distrito" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    ArrayList<Usuario> listaUsuarios = (ArrayList<Usuario>) request.getAttribute("lista");
    String busqueda = (String) request.getAttribute("busqueda");
    String rolFiltro = (String) request.getAttribute("rolFiltro");
    String estadoFiltro = (String) request.getAttribute("estadoFiltro");
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) {
        session.removeAttribute("successMsg");
    }

    // Parámetros de ordenamiento actuales
    String currentSortBy = (String) request.getAttribute("sortBy");
    String currentSortOrder = (String) request.getAttribute("sortOrder");
    
    // Cargar distritos para el select de Gerente de Tienda
    ArrayList<Distrito> distritos = (ArrayList<Distrito>) request.getAttribute("distritos");
    if (distritos == null) {
        distritos = new ArrayList<>();
    }
%>

<%! // BLOQUE DE DECLARACIÓN JSP PARA MÉTODOS AUXILIARES
    // Función auxiliar para generar URLs de ordenamiento
    public String getSortUrl(jakarta.servlet.http.HttpServletRequest request, String sortByColumn, String currentSortBy, String currentSortOrder, String busqueda, String rolFiltro, String estadoFiltro, int size) {
        String newSortOrder = "asc";
        if (sortByColumn.equals(currentSortBy)) {
            newSortOrder = (currentSortOrder != null && currentSortOrder.equalsIgnoreCase("asc")) ? "desc" : "asc";
        }
        String baseUrl = request.getContextPath() + "/UsuarioServlet?action=listar";
        if (busqueda != null && !busqueda.isEmpty()) baseUrl += "&busqueda=" + busqueda;
        if (rolFiltro != null && !rolFiltro.isEmpty()) baseUrl += "&rol=" + rolFiltro;
        if (estadoFiltro != null && !estadoFiltro.isEmpty()) baseUrl += "&estado=" + estadoFiltro;
        baseUrl += "&sortBy=" + sortByColumn + "&sortOrder=" + newSortOrder + "&page=1&size=" + (size > 0 ? size : 5);
        return baseUrl;
    }

    // Función auxiliar para mostrar el icono de ordenamiento
    public String getSortIcon(String sortByColumn, String currentSortBy, String currentSortOrder) {
        // Retornar cadena vacía, los iconos se mostrarán con CSS ::after
        return "";
    }
    
    // Función auxiliar para obtener la clase CSS de ordenamiento
    public String getSortClass(String sortByColumn, String currentSortBy, String currentSortOrder) {
        if (sortByColumn.equals(currentSortBy)) {
            return (currentSortOrder != null && currentSortOrder.equalsIgnoreCase("asc")) ? "sort-asc" : "sort-desc";
        }
        return ""; // Sin clase si no está ordenado por esta columna
    }
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Usuarios"/>
    </jsp:include>
    <style>
        /* Estilo para el botón Limpiar */
        .btn-outline-secondary {
            color: #6c757d !important;
            border: 1px solid #6c757d !important;
            background-color: transparent !important;
            background-image: none !important;
        }
        .btn-outline-secondary:hover {
            color: #fff !important;
            background-color: #6c757d !important;
            border: 1px solid #6c757d !important;
            background-image: none !important;
        }
    </style>
    <style>
        /* Estilos mejorados para el dropdown de acciones */
        .dropdown-menu {
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15) !important;
            border: 1px solid rgba(0, 0, 0, 0.08) !important;
            animation: fadeInDown 0.2s ease-out;
        }
        
        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .dropdown-item {
            border-radius: 4px;
            margin: 2px 8px;
        }
        
        .dropdown-item:hover {
            transform: translateX(3px);
        }
        
        /* Mejora del botón de acciones */
        .btn-outline-success:hover {
            transform: scale(1.05);
        }
        
        /* Estilos para el botón Agregar Usuario */
        .btn-agregar-usuario {
            transition: all 0.3s ease;
        }
        
        .btn-agregar-usuario:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(40, 167, 69, 0.4) !important;
        }
        
        /* ===================== Estilos para Modal de Agregar Usuario ===================== */
        #addUserModal.modal { 
            display: none; 
            position: fixed; 
            z-index: 1050; 
            left: 0; 
            top: 0; 
            width: 100%; 
            height: 100%; 
            background-color: rgba(0,0,0,0.6); 
            backdrop-filter: blur(4px);
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }
        #addUserModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #addUserModal .modal-content { 
            background-color: #ffffff; 
            width: 100%;
            max-width: 700px; 
            max-height: 90vh; 
            border: none; 
            border-radius: 16px; 
            box-shadow: 0 20px 60px rgba(0,0,0,0.3); 
            animation: modalSlideIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            display: flex;
            flex-direction: column;
        }
        @keyframes modalSlideIn { 
            from { 
                transform: scale(0.9) translateY(-20px); 
                opacity: 0; 
            } 
            to { 
                transform: scale(1) translateY(0); 
                opacity: 1; 
            } 
        }
        #addUserModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%); 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(0,168,150,0.2);
        }
        #addUserModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #addUserModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #addUserModal .modal-close { 
            color: white; 
            font-size: 24px; 
            font-weight: normal; 
            cursor: pointer; 
            opacity: 0.9; 
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        #addUserModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #addUserModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 160px);
        }
        #addUserModal .form-group {
            margin-bottom: 1rem;
        }
        #addUserModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #addUserModal .form-group label i {
            color: #6F4E37;
            font-size: 0.85rem;
        }
        #addUserModal .form-group input,
        #addUserModal .form-group select {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }
        #addUserModal .form-group input:focus,
        #addUserModal .form-group select:focus {
            border-color: #6F4E37;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        #addUserModal .form-hint {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #6c757d;
            font-size: 0.8rem;
            margin-top: 6px;
            padding: 8px 12px;
            background: rgba(0,168,150,0.05);
            border-radius: 6px;
        }
        #addUserModal .form-hint i {
            color: #6F4E37;
            flex-shrink: 0;
        }
        #addUserModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #addUserModal .modal-footer button {
            padding: 12px 28px;
            font-size: 0.95rem;
            font-weight: 600;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        #addUserModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #addUserModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #addUserModal .modal-footer button[type="submit"] {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(40,167,69,0.3);
        }
        #addUserModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(40,167,69,0.4);
        }
        @media (max-width: 768px) {
            #addUserModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #addUserModal.show {
                padding: 10px;
            }
        }
        
        /* ===================== Estilos para Modal de Enviar por Correo ===================== */
        #sendEmailModal.modal { 
            display: none; 
            position: fixed; 
            z-index: 1050; 
            left: 0; 
            top: 0; 
            width: 100%; 
            height: 100%; 
            background-color: rgba(0,0,0,0.6); 
            backdrop-filter: blur(4px);
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }
        #sendEmailModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #sendEmailModal .modal-content { 
            background-color: #ffffff; 
            width: 100%;
            max-width: 700px; 
            max-height: 90vh; 
            border: none; 
            border-radius: 16px; 
            box-shadow: 0 20px 60px rgba(0,0,0,0.3); 
            animation: modalSlideIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            display: flex;
            flex-direction: column;
        }
        #sendEmailModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%); 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(0,168,150,0.2);
        }
        #sendEmailModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #sendEmailModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #sendEmailModal .modal-close { 
            color: white; 
            font-size: 24px; 
            font-weight: normal; 
            cursor: pointer; 
            opacity: 0.9; 
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        #sendEmailModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #sendEmailModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 200px);
        }
        #sendEmailModal .form-group {
            margin-bottom: 1.25rem;
        }
        #sendEmailModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #sendEmailModal .form-group label i {
            color: #6F4E37;
            font-size: 0.85rem;
        }
        #sendEmailModal .form-group input,
        #sendEmailModal .form-group textarea {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }
        #sendEmailModal .form-group input:focus,
        #sendEmailModal .form-group textarea:focus {
            border-color: #6F4E37;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        #sendEmailModal .form-hint {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #6c757d;
            font-size: 0.8rem;
            margin-top: 6px;
            padding: 8px 12px;
            background: rgba(0,168,150,0.05);
            border-radius: 6px;
        }
        #sendEmailModal .form-hint i {
            color: #6F4E37;
            flex-shrink: 0;
        }
        #sendEmailModal .alert-info {
            background: rgba(0,168,150,0.1);
            border-left: 4px solid #6F4E37;
            border-radius: 8px;
            padding: 12px 16px;
            margin-bottom: 20px;
        }
        #sendEmailModal .alert-warning {
            background: rgba(255,193,7,0.1);
            border-left: 4px solid #ffc107;
            border-radius: 8px;
            padding: 12px 16px;
            margin-bottom: 20px;
        }
        #sendEmailModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #sendEmailModal .modal-footer button {
            padding: 12px 28px;
            font-size: 0.95rem;
            font-weight: 600;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        #sendEmailModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #sendEmailModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #sendEmailModal .modal-footer button[type="submit"] {
            background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(0,168,150,0.3);
        }
        #sendEmailModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,168,150,0.4);
        }
        @media (max-width: 768px) {
            #sendEmailModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #sendEmailModal.show {
                padding: 10px;
            }
        }
        
        /* ===================== Estilos para Modal de Editar Usuario ===================== */
        #editUserModal.modal { 
            display: none; 
            position: fixed; 
            z-index: 1050; 
            left: 0; 
            top: 0; 
            width: 100%; 
            height: 100%; 
            background-color: rgba(0,0,0,0.6); 
            backdrop-filter: blur(4px);
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }
        #editUserModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #editUserModal .modal-content { 
            background-color: #ffffff; 
            width: 100%;
            max-width: 700px; 
            max-height: 90vh; 
            border: none; 
            border-radius: 16px; 
            box-shadow: 0 20px 60px rgba(0,0,0,0.3); 
            animation: modalSlideIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            display: flex;
            flex-direction: column;
        }
        #editUserModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(0,168,150,0.2);
        }
        #editUserModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #editUserModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #editUserModal .modal-close { 
            color: white; 
            font-size: 24px; 
            font-weight: normal; 
            cursor: pointer; 
            opacity: 0.9; 
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        #editUserModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #editUserModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 160px);
        }
        #editUserModal .form-group {
            margin-bottom: 1rem;
        }
        #editUserModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #editUserModal .form-group label i {
            color: #6F4E37;
            font-size: 0.85rem;
        }
        #editUserModal .form-group input,
        #editUserModal .form-group select {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }
        #editUserModal .form-group input:focus,
        #editUserModal .form-group select:focus {
            border-color: #6F4E37;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        #editUserModal .form-hint {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #6c757d;
            font-size: 0.8rem;
            margin-top: 6px;
            padding: 8px 12px;
            background: rgba(0,168,150,0.05);
            border-radius: 6px;
        }
        #editUserModal .form-hint i {
            color: #6F4E37;
            flex-shrink: 0;
        }
        #editUserModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #editUserModal .modal-footer button {
            padding: 12px 28px;
            font-size: 0.95rem;
            font-weight: 600;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        #editUserModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #editUserModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #editUserModal .modal-footer button[type="submit"] {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(0,168,150,0.3);
        }
        #editUserModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,168,150,0.4);
        }
        @media (max-width: 768px) {
            #editUserModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #editUserModal.show {
                padding: 10px;
            }
        }
        
        /* Eliminar scroll horizontal de la tabla */
        #userTable {
            width: 100% !important;
            max-width: 100% !important;
        }
        
        #userTable th,
        #userTable td {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        /* Prevenir movimiento durante la carga - fijar dimensiones de imágenes */
        #userTable img {
            width: 38px !important;
            height: 38px !important;
            min-width: 38px;
            min-height: 38px;
            flex-shrink: 0;
        }
        
        /* Prevenir reflow al cargar */
        #userTable tbody tr {
            min-height: 50px;
        }
        
        /* Permitir que el dropdown sea visible en la columna de acciones */
        #userTable tbody tr {
            position: relative;
            z-index: 1;
        }
        
        #userTable tbody tr:hover {
            z-index: 2;
        }
        
        #userTable tbody tr.dropdown-open {
            z-index: 1000 !important;
        }
        
        #userTable td:last-child {
            overflow: visible !important;
            position: relative;
            z-index: 10;
        }
        
        #userTable td:last-child.dropdown-open {
            z-index: 1001 !important;
        }
        
        #userTable td:last-child .dropdown {
            position: relative !important;
            display: inline-block !important;
            z-index: 1000;
        }
        
        #userTable td:last-child .dropdown.dropdown-open {
            z-index: 1002 !important;
        }
        
        #userTable td:last-child .dropdown-toggle::after {
            display: none;
        }
        
        #userTable td:last-child .dropdown-menu {
            position: absolute !important;
            right: 0 !important;
            left: auto !important;
            top: 100% !important;
            bottom: auto !important;
            z-index: 99999 !important;
            margin-top: 0.25rem !important;
            margin-bottom: 0 !important;
            min-width: 180px !important;
            display: none;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15) !important;
            transform: none !important;
        }
        
        #userTable td:last-child .dropdown-menu.show {
            display: block !important;
            position: absolute !important;
        }
        
        /* Asegurar que el contenedor no corte el dropdown */
        #userTable tbody {
            overflow: visible !important;
        }
        
        #userTable {
            overflow: visible !important;
        }
        
        #userTable tbody tr td {
            overflow: visible !important;
        }
        
        .table-responsive {
            overflow: visible !important;
        }
        
        .table-card .card-body {
            overflow: visible !important;
        }
        
        .table-card {
            overflow: visible !important;
        }
        
        div[style*="overflow"]:not(.modal):not(.modal-content) {
            overflow: visible !important;
        }
        
        #userTable th:nth-child(2),
        #userTable td:nth-child(2) {
            max-width: 200px;
        }
        
        #userTable th:nth-child(3),
        #userTable td:nth-child(3) {
            max-width: 250px;
        }
        
        /* Estilos para encabezados de tabla con hover verde y ordenamiento */
        #userTable thead th {
            position: relative;
            user-select: none;
            color: var(--text-muted) !important;
            text-transform: uppercase;
        }
        
        /* Solo los th ordenables (que no son "Acciones") tienen hover y cursor pointer */
        #userTable thead th:not(:last-child) {
            cursor: pointer;
        }
        
        #userTable thead th:not(:last-child):hover {
            background-color: var(--seafoam) !important;
        }
        
        /* Eliminar cualquier flecha de ordenamiento de TODOS los encabezados */
        #userTable thead th::after,
        #userTable thead th::before {
            content: none !important;
            display: none !important;
        }
        
        #userTable thead th.sort-asc::after,
        #userTable thead th.sort-desc::after,
        #userTable thead th.sort-asc::before,
        #userTable thead th.sort-desc::before {
            content: none !important;
            display: none !important;
        }
        
        /* Asegurar que los enlaces dentro de th no interfieran con el hover */
        #userTable thead th a {
            display: block;
            width: 100%;
            color: inherit;
        }
        
        #userTable thead th a:hover {
            color: inherit;
        }
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
    <% if (successMsg != null) { %>
    <div class="alert alert-success alert-dismissible fade show" role="alert" style="padding: 0.5rem 0.75rem; margin-bottom: 0.5rem; font-size: 0.85rem;">
        <%= successMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
    </div>
    <% } %>

    <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
            <div>
                <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-users me-2"></i>Gestión de Usuarios</h2>
                <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Administra los usuarios del sistema.</p>
            </div>
            <div class="d-flex gap-2 flex-wrap">
                <%
                    // Construir URL de parámetros para mantener filtros en la exportación
                    String exportUrl = request.getContextPath() + "/UsuarioReporteServlet?action=exportar";
                    if (busqueda != null && !busqueda.isEmpty()) exportUrl += "&busqueda=" + java.net.URLEncoder.encode(busqueda, "UTF-8");
                    if (rolFiltro != null && !rolFiltro.isEmpty()) exportUrl += "&rol=" + rolFiltro;
                    if (estadoFiltro != null && !estadoFiltro.isEmpty()) exportUrl += "&estado=" + estadoFiltro;
                    if (currentSortBy != null && !currentSortBy.isEmpty()) exportUrl += "&sortBy=" + currentSortBy;
                    if (currentSortOrder != null && !currentSortOrder.isEmpty()) exportUrl += "&sortOrder=" + currentSortOrder;
                    
                    String sendUrl = request.getContextPath() + "/UsuarioReporteServlet?action=formEnviar";
                    if (busqueda != null && !busqueda.isEmpty()) sendUrl += "&busqueda=" + java.net.URLEncoder.encode(busqueda, "UTF-8");
                    if (rolFiltro != null && !rolFiltro.isEmpty()) sendUrl += "&rol=" + rolFiltro;
                    if (estadoFiltro != null && !estadoFiltro.isEmpty()) sendUrl += "&estado=" + estadoFiltro;
                    if (currentSortBy != null && !currentSortBy.isEmpty()) sendUrl += "&sortBy=" + currentSortBy;
                    if (currentSortOrder != null && !currentSortOrder.isEmpty()) sendUrl += "&sortOrder=" + currentSortOrder;
                %>
                <a href="<%= exportUrl %>" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                    <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                </a>
                <button type="button" id="openSendEmailModalBtn" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                    <i class="fas fa-envelope me-1"></i>Enviar por Correo
                </button>
                <button type="button" id="openModalBtn" class="btn btn-sm shadow-sm btn-agregar-usuario" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); border: none; color: white; font-weight: 600;">
                    <i class="fas fa-plus me-1"></i>Agregar Usuario
                </button>
            </div>
        </div>
    </div>

    <%
        // Obtener estadísticas del servlet
        Integer totalUsuariosAttr = (Integer) request.getAttribute("totalUsuarios");
        Integer usuariosActivosAttr = (Integer) request.getAttribute("usuariosActivos");
        Integer usuariosInactivosAttr = (Integer) request.getAttribute("usuariosInactivos");
        int totalUsuarios = (totalUsuariosAttr != null) ? totalUsuariosAttr : 0;
        int usuariosActivos = (usuariosActivosAttr != null) ? usuariosActivosAttr : 0;
        int usuariosInactivos = (usuariosInactivosAttr != null) ? usuariosInactivosAttr : 0;
    %>

    <!-- ===================== Tarjetas de estadísticas ===================== -->
    <div class="row g-2 mb-3">
        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
            <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Total de Usuarios</h3>
                <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= totalUsuarios %></p>
            </div>
        </div>
        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
            <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Activos</h3>
                <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= usuariosActivos %></p>
            </div>
        </div>
        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
            <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Inactivos</h3>
                <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= usuariosInactivos %></p>
            </div>
        </div>
    </div>

    <!-- ===================== Card: Búsqueda y filtros ===================== -->
    <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
        <form action="<%= request.getContextPath() %>/UsuarioServlet" method="GET" id="filterForm">
            <input type="hidden" name="action" value="listar">
            <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
            <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                <div class="col-xl-5 col-lg-5 col-md-12 col-sm-12">
                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                    <div class="input-group">
                        <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="Nombre, correo o código..." value="<%= busqueda != null ? busqueda : "" %>" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                        <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6">
                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-user-tag me-1"></i>Rol</label>
                    <select class="form-select form-select-sm shadow-sm" name="rol" id="rolFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                        <option value="" <%= (rolFiltro == null || rolFiltro.isEmpty()) ? "selected" : "" %>>Todos los Roles</option>
                        <option value="1" <%= "1".equals(rolFiltro) ? "selected" : "" %>>Administrador</option>
                        <option value="2" <%= "2".equals(rolFiltro) ? "selected" : "" %>>Logística</option>
                        <option value="3" <%= "3".equals(rolFiltro) ? "selected" : "" %>>Productor</option>
                        <option value="4" <%= "4".equals(rolFiltro) ? "selected" : "" %>>Almacén</option>
                        <option value="7" <%= "7".equals(rolFiltro) ? "selected" : "" %>>Gerente de Tienda</option>
                    </select>
                </div>
                <div class="col-xl-2 col-lg-2 col-md-6 col-sm-6">
                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado</label>
                    <select class="form-select form-select-sm shadow-sm" name="estado" id="estadoFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                        <option value="" <%= (estadoFiltro == null || estadoFiltro.isEmpty()) ? "selected" : "" %>>Todos</option>
                        <option value="1" <%= "1".equals(estadoFiltro) ? "selected" : "" %>>Activo</option>
                        <option value="0" <%= "0".equals(estadoFiltro) ? "selected" : "" %>>Inactivo</option>
                    </select>
                </div>
                <div class="col-xl-2 col-lg-2 col-md-6 col-sm-6 d-flex align-items-end">
                    <a href="<%= request.getContextPath() %>/UsuarioServlet" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                        <i class="fas fa-sync-alt me-1"></i>Limpiar
                    </a>
                </div>
            </div>
        </form>
    </div>

    <!-- ===================== Card: Tabla de usuarios ===================== -->
    <div class="row">
        <div class="col-12">
            <div class="table-card shadow-sm">
                <div class="card-header" style="padding: 0.5rem 0.75rem;">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div>
                            <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-users me-2"></i>Tabla de Usuarios</h5>
                            <small class="text-white" style="font-size: 0.75rem; line-height: 1.2; opacity: 1;">Gestiona todos los usuarios del sistema</small>
                        </div>
                    </div>
                </div>
                <div class="card-body" style="padding: 0.75rem;">

                    <div class="table-responsive">
                        <table id="userTable" class="table table-hover align-middle mb-0 datatable-server-side" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                            <thead class="table-light">
                            <tr>
                                <th class="fw-semibold" onclick="sortUserTable(0)" style="width: 5%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor: pointer; text-align: center;">
                                    <i class="fas fa-hashtag me-1"></i>ID
                                </th>
                                <th class="fw-semibold" onclick="sortUserTable(1)" style="width: 25%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor: pointer;">
                                    <i class="fas fa-user me-1"></i>Usuario
                                </th>
                                <th class="fw-semibold" onclick="sortUserTable(2)" style="width: 25%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor: pointer; text-align: center;">
                                    <i class="fas fa-envelope me-1"></i>Correo
                                </th>
                                <th class="fw-semibold" onclick="sortUserTable(3)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor: pointer; text-align: center;">
                                    <i class="fas fa-user-tag me-1"></i>Rol
                                </th>
                                <th class="fw-semibold" onclick="sortUserTable(4)" style="width: 8%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor: pointer; text-align: center;">
                                    <i class="fas fa-toggle-on me-1"></i>Estado
                                </th>
                                <th class="text-end fw-semibold text-success" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor: default;">
                                    <i class="fas fa-cog me-1"></i>Acciones
                                </th>
                            </tr>
                            </thead>
                            <tbody>
                            <% if (listaUsuarios != null && !listaUsuarios.isEmpty()) { %>
                            <% for (Usuario usuario : listaUsuarios) {
                                String roleName = usuario.getRol().getNombre();
                                String badgeClass = "text-bg-secondary"; // Default color
                                switch (roleName) {
                                    case "Administrador":
                                        badgeClass = "text-bg-primary";
                                        break;
                                    case "Logística":
                                        badgeClass = "text-bg-info";
                                        break;
                                    case "Productor":
                                        badgeClass = "text-bg-success";
                                        break;
                                    case "Almacén":
                                        badgeClass = "text-bg-warning";
                                        break;
                                }
                            %>
                            <tr class="align-middle" style="padding: 0;">
                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                    <span style="font-size: 0.9rem; font-weight: 600; color: #2b2d42;">
                                        USR<%= String.format("%03d", usuario.getIdUsuario()) %>
                                    </span>
                                </td>
                                <td style="padding: 0.35rem 0.5rem;">
                                    <div class="d-flex align-items-center">
                                        <div class="avatar-wrapper me-2">
                                            <%
                                                // Construir la URL correcta de la foto de perfil
                                                String fotoUrl = usuario.getFotoPerfil();
                                                if (fotoUrl != null && !fotoUrl.trim().isEmpty()) {
                                                    // Si es una ruta local (no una URL externa), usar el contexto
                                                    if (!fotoUrl.startsWith("http://") && !fotoUrl.startsWith("https://")) {
                                                        // La ruta viene como "uploads/perfiles/xxx.jpg", necesitamos "/uploads/perfiles/xxx.jpg"
                                                        if (!fotoUrl.startsWith("/")) {
                                                            fotoUrl = "/" + fotoUrl;
                                                        }
                                                        fotoUrl = request.getContextPath() + fotoUrl;
                                                    }
                                                } else {
                                                    // Si no hay foto, generar avatar con iniciales
                                                    fotoUrl = usuario.getFotoPerfilUrl();
                                                }
                                            %>
                                            <img src="<%= fotoUrl %>" 
                                                 alt="<%= usuario.getNombres() %> <%= usuario.getApellidos() %>" 
                                                 class="rounded-circle shadow-sm" 
                                                 width="38" 
                                                 height="38"
                                                 style="object-fit: cover; border: 2px solid #e9ecef; display: block;"
                                                 loading="lazy"
                                                 onerror="this.src='<%= usuario.getFotoPerfilUrl() %>'">
                                        </div>
                                        <div>
                                            <h6 class="mb-0 fw-semibold text-dark" style="font-size: 0.9rem; line-height: 1.2;"><%= usuario.getNombres() %> <%= usuario.getApellidos() %></h6>
                                        </div>
                                    </div>
                                </td>
                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                    <div style="font-size: 0.85rem; line-height: 1.3;">
                                        <span class="text-dark"><%= usuario.getEmail() %></span>
                                    </div>
                                    <% if (usuario.getCodigoProductor() != null && !usuario.getCodigoProductor().isEmpty()) { %>
                                        <div class="mt-0" style="margin-top: 0.2rem !important;">
                                            <span class="badge bg-info-subtle text-info border border-info" style="font-size: 0.7rem; padding: 0.15rem 0.4rem;">
                                                <i class="fas fa-tag me-1"></i><%= usuario.getCodigoProductor() %>
                                            </span>
                                        </div>
                                    <% } %>
                                </td>
                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                    <span class="badge <%= badgeClass %> shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                        <i class="fas fa-user-tag me-1"></i><%= roleName %>
                                    </span>
                                </td>
                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                    <% if (usuario.isActivo()) { %>
                                        <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                            <i class="fas fa-check-circle me-1"></i>Activo
                                        </span>
                                    <% } else { %>
                                        <span class="badge text-bg-danger shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                            <i class="fas fa-times-circle me-1"></i>Inactivo
                                        </span>
                                    <% } %>
                                </td>
                                <td class="text-end" style="padding: 0.35rem 0.5rem;">
                                    <div class="dropdown">
                                        <button class="btn btn-sm btn-outline-success shadow-sm" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="font-size: 0.8rem; padding: 0.35rem 0.6rem; border-color: #28a745; color: #28a745; transition: all 0.2s ease;" onmouseover="this.style.background='#28a745'; this.style.color='white';" onmouseout="this.style.background='transparent'; this.style.color='#28a745';">
                                            <i class="fas fa-ellipsis-v"></i>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-end shadow-lg border-0" style="min-width: 180px; font-size: 0.9rem; border-radius: 8px; padding: 8px 0; margin-top: 8px;">
                                            <li>
                                                <a class="dropdown-item d-flex align-items-center py-2 px-3" href="#" onclick="editarUsuario(<%= usuario.getIdUsuario() %>); return false;" style="transition: all 0.2s ease; color: #495057;" onmouseover="this.style.background='#e3f2fd'; this.style.color='#1976d2'; this.style.paddingLeft='20px';" onmouseout="this.style.background='transparent'; this.style.color='#495057'; this.style.paddingLeft='12px';">
                                                    <i class="fas fa-edit me-3" style="width: 20px; color: #1976d2; font-size: 1rem;"></i>
                                                    <span style="font-weight: 500;">Editar</span>
                                                </a>
                                            </li>
                                            <li><hr class="dropdown-divider my-1" style="margin: 4px 0;"></li>
                                            <li>
                                                <a class="dropdown-item d-flex align-items-center py-2 px-3" href="#" onclick="confirmarEliminar('<%= request.getContextPath() %>/UsuarioServlet?action=borrar&id=<%= usuario.getIdUsuario() %>'); return false;" style="transition: all 0.2s ease; color: #dc3545;" onmouseover="this.style.background='#ffebee'; this.style.color='#c62828'; this.style.paddingLeft='20px';" onmouseout="this.style.background='transparent'; this.style.color='#dc3545'; this.style.paddingLeft='12px';">
                                                    <i class="fas fa-trash-alt me-3" style="width: 20px; color: #dc3545; font-size: 1rem;"></i>
                                                    <span style="font-weight: 500;">Eliminar</span>
                                                </a>
                                            </li>
                                        </ul>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                            <% } else { %>
                            <tr>
                                <td colspan="7" class="text-center py-5">
                                    <div class="text-muted">
                                        <i class="fas fa-users-slash fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                        <p class="mb-0">No se encontraron usuarios con los filtros aplicados.</p>
                                        <small>Intenta ajustar los filtros de búsqueda</small>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                        
                        <%-- Incluir componente de paginación --%>
                        <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                    </div>
                </div>
            </div>
        </div>
    </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<!-- Bootstrap JS ya está incluido en footer.jsp -->
<script>
    // Función para ajustar el posicionamiento de los dropdowns
    function ajustarDropdowns() {
        document.querySelectorAll('#userTable td:last-child .dropdown').forEach(function(dropdown) {
            const button = dropdown.querySelector('button[data-bs-toggle="dropdown"]');
            const menu = dropdown.querySelector('.dropdown-menu');
            
            if (button && menu) {
                // Función para posicionar el dropdown
                function posicionarDropdown() {
                    if (menu.classList.contains('show')) {
                        // Agregar clases para aumentar z-index
                        const tr = button.closest('tr');
                        const td = button.closest('td');
                        if (tr) tr.classList.add('dropdown-open');
                        if (td) td.classList.add('dropdown-open');
                        dropdown.classList.add('dropdown-open');
                        
                        menu.style.position = 'absolute';
                        menu.style.right = '0';
                        menu.style.left = 'auto';
                        menu.style.top = '100%';
                        menu.style.bottom = 'auto';
                        menu.style.transform = 'none';
                        menu.style.zIndex = '99999';
                        menu.style.marginTop = '0.25rem';
                        menu.style.marginBottom = '0';
                        menu.removeAttribute('data-bs-popper');
                    } else {
                        // Remover clases cuando se cierra
                        const tr = button.closest('tr');
                        const td = button.closest('td');
                        if (tr) tr.classList.remove('dropdown-open');
                        if (td) td.classList.remove('dropdown-open');
                        dropdown.classList.remove('dropdown-open');
                    }
                }
                
                // Ajustar cuando el dropdown se muestra
                button.addEventListener('shown.bs.dropdown', function() {
                    posicionarDropdown();
                });
                
                // Ajustar cuando el dropdown se oculta
                button.addEventListener('hidden.bs.dropdown', function() {
                    posicionarDropdown();
                });
                
                // Ajustar después de un pequeño delay para asegurar que Bootstrap haya aplicado sus estilos
                button.addEventListener('click', function(e) {
                    setTimeout(function() {
                        posicionarDropdown();
                    }, 10);
                });
                
                // Ajustar posición al hacer scroll o redimensionar
                let scrollTimeout;
                function ajustarEnScroll() {
                    clearTimeout(scrollTimeout);
                    scrollTimeout = setTimeout(function() {
                        if (menu.classList.contains('show')) {
                            posicionarDropdown();
                        }
                    }, 10);
                }
                
                window.addEventListener('scroll', ajustarEnScroll, true);
                window.addEventListener('resize', ajustarEnScroll);
            }
        });
    }
    
    // Función para ordenar la tabla de usuarios sin recargar la página
    let sortDirection = {}; // Almacena la dirección de ordenamiento para cada columna
    
    function sortUserTable(columnIndex) {
        const table = document.getElementById('userTable');
        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));
        
        // Determinar dirección de ordenamiento
        if (!sortDirection[columnIndex]) {
            sortDirection[columnIndex] = 'asc';
        } else {
            sortDirection[columnIndex] = sortDirection[columnIndex] === 'asc' ? 'desc' : 'asc';
        }
        
        // Ordenar las filas según el tipo de columna
        rows.sort((a, b) => {
            let aText, bText;
            
            switch(columnIndex) {
                case 0: // ID (USR001)
                    aText = a.cells[0].textContent.trim();
                    bText = b.cells[0].textContent.trim();
                    // Extraer número de "USR001" -> 1
                    const aIdNum = parseInt(aText.replace('USR', '')) || 0;
                    const bIdNum = parseInt(bText.replace('USR', '')) || 0;
                    return sortDirection[columnIndex] === 'asc' ? aIdNum - bIdNum : bIdNum - aIdNum;
                    
                case 1: // Usuario (Nombre completo)
                    aText = a.cells[1].querySelector('h6') ? a.cells[1].querySelector('h6').textContent.trim() : a.cells[1].textContent.trim();
                    bText = b.cells[1].querySelector('h6') ? b.cells[1].querySelector('h6').textContent.trim() : b.cells[1].textContent.trim();
                    break;
                    
                case 2: // Correo
                    aText = a.cells[2].querySelector('span.text-dark') ? a.cells[2].querySelector('span.text-dark').textContent.trim() : a.cells[2].textContent.trim();
                    bText = b.cells[2].querySelector('span.text-dark') ? b.cells[2].querySelector('span.text-dark').textContent.trim() : b.cells[2].textContent.trim();
                    break;
                    
                case 3: // Rol (badge)
                    aText = a.cells[3].querySelector('span.badge') ? a.cells[3].querySelector('span.badge').textContent.trim() : a.cells[3].textContent.trim();
                    bText = b.cells[3].querySelector('span.badge') ? b.cells[3].querySelector('span.badge').textContent.trim() : b.cells[3].textContent.trim();
                    break;
                    
                case 4: // Estado (badge)
                    aText = a.cells[4].querySelector('span.badge') ? a.cells[4].querySelector('span.badge').textContent.trim() : a.cells[4].textContent.trim();
                    bText = b.cells[4].querySelector('span.badge') ? b.cells[4].querySelector('span.badge').textContent.trim() : b.cells[4].textContent.trim();
                    break;
                    
                default:
                    aText = a.cells[columnIndex].textContent.trim();
                    bText = b.cells[columnIndex].textContent.trim();
            }
            
            // Comparar como texto
            const comparison = aText.localeCompare(bText, 'es', { numeric: true, sensitivity: 'base' });
            return sortDirection[columnIndex] === 'asc' ? comparison : -comparison;
        });
        
        // Reordenar las filas en el DOM
        rows.forEach(row => tbody.appendChild(row));
        
        // Actualizar indicadores visuales en los encabezados
        const headers = table.querySelectorAll('thead th');
        headers.forEach((header, index) => {
            header.classList.remove('sort-asc', 'sort-desc');
            if (index === columnIndex && index !== 6) { // No aplicar a la columna de Acciones
                header.classList.add(sortDirection[columnIndex] === 'asc' ? 'sort-asc' : 'sort-desc');
            }
        });
    }
    
    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function() {
        // Ajustar dropdowns después de que la página cargue completamente para evitar movimiento
        // Usar requestAnimationFrame para asegurar que el renderizado esté completo
        requestAnimationFrame(function() {
            setTimeout(function() {
                ajustarDropdowns();
            }, 0);
        });
        const filterForm = document.getElementById('filterForm');
        const searchInput = document.getElementById('searchInput');
        const rolFilter = document.getElementById('rolFilter');
        const estadoFilter = document.getElementById('estadoFilter');
        
        // Variable para el timeout del debounce
        let searchTimeout = null;
        
        // Aplicar filtros automáticamente mientras se escribe en el campo de búsqueda (con debounce)
        if (searchInput && filterForm) {
            searchInput.addEventListener('input', function(e) {
                // Limpiar el timeout anterior
                if (searchTimeout) {
                    clearTimeout(searchTimeout);
                }
                
                // Esperar 500ms después de que el usuario deje de escribir antes de enviar
                searchTimeout = setTimeout(function() {
                    filterForm.submit();
                }, 500);
            });
            
            // Aplicar filtros al presionar Enter en el campo de búsqueda (inmediato)
            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    // Cancelar el timeout si existe
                    if (searchTimeout) {
                        clearTimeout(searchTimeout);
                    }
                    filterForm.submit();
                }
            });
        }
        
        // Aplicar filtros cuando cambien los selects
        if (rolFilter && filterForm) {
            rolFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        if (estadoFilter && filterForm) {
            estadoFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
    });

    // Función para confirmar eliminación (desactivación) con modal personalizado
    function confirmarEliminar(url) {
        showConfirm(
            '¿Estás seguro de que deseas desactivar este usuario? El usuario no podrá acceder al sistema, pero sus datos se mantendrán. Puedes reactivarlo desde el botón Editar.',
            function() {
                window.location.href = url;
            },
            'Confirmar desactivación'
        );
    }
    
    // Inicializar tooltips después de que la página cargue
    document.addEventListener('DOMContentLoaded', function() {
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
        
        // ===================== Manejo del Modal de Agregar Usuario =====================
        const addUserModal = document.getElementById('addUserModal');
        const openModalBtn = document.getElementById('openModalBtn');
        const closeModalBtn = document.querySelector('#addUserModal .modal-close');
        const cancelModalBtn = document.querySelector('#addUserModal .modal-cancel');
        const rolSelect = document.getElementById('modalRol');
        const codigoProductorContainer = document.getElementById('modalCodigoProductorContainer');
        const codigoProductorInput = document.getElementById('modalCodigoProductor');
        const distritoContainer = document.getElementById('modalDistritoContainer');
        const distritoSelect = document.getElementById('modalDistrito');
        
        // Función para abrir el modal
        function abrirModalUsuario() {
            if (addUserModal) {
                addUserModal.classList.add('show');
                addUserModal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
                limpiarFormularioUsuario();
                toggleCodigoProductor();
                toggleDistrito();
            } else {
                console.error('Modal no encontrado');
            }
        }
        
        // Función para cerrar el modal
        function cerrarModalUsuario() {
            if (addUserModal) {
                addUserModal.classList.remove('show');
                addUserModal.style.display = 'none';
                document.body.style.overflow = '';
            }
        }
        
        // Función para limpiar el formulario
        function limpiarFormularioUsuario() {
            const nombres = document.getElementById('modalNombres');
            const apellidos = document.getElementById('modalApellidos');
            const email = document.getElementById('modalEmail');
            const password = document.getElementById('modalPassword');
            const passwordConfirm = document.getElementById('modalPasswordConfirm');
            
            if (nombres) nombres.value = '';
            if (apellidos) apellidos.value = '';
            if (email) email.value = '';
            if (password) password.value = '';
            if (passwordConfirm) passwordConfirm.value = '';
            if (rolSelect) rolSelect.selectedIndex = 0;
            if (codigoProductorInput) codigoProductorInput.value = '';
            if (codigoProductorContainer) codigoProductorContainer.style.display = 'none';
            if (distritoSelect) distritoSelect.selectedIndex = 0;
            if (distritoContainer) distritoContainer.style.display = 'none';
        }
        
        // Validación de contraseñas coincidentes
        const formAgregarUsuario = document.getElementById('formAgregarUsuario');
        if (formAgregarUsuario) {
            formAgregarUsuario.addEventListener('submit', function(e) {
                const password = document.getElementById('modalPassword').value;
                const passwordConfirm = document.getElementById('modalPasswordConfirm').value;
                
                if (password !== passwordConfirm) {
                    e.preventDefault();
                    alert('Las contraseñas no coinciden. Por favor, verifica que ambas contraseñas sean iguales.');
                    document.getElementById('modalPasswordConfirm').focus();
                    return false;
                }
            });
        }
        
        // Función para mostrar/ocultar campo de código de productor
        function toggleCodigoProductor() {
            if (rolSelect && codigoProductorContainer && codigoProductorInput) {
                if (rolSelect.value === '3') { // Rol Productor
                    codigoProductorContainer.style.display = 'block';
                    codigoProductorInput.removeAttribute('disabled');
                } else {
                    codigoProductorContainer.style.display = 'none';
                    codigoProductorInput.setAttribute('disabled', 'disabled');
                    codigoProductorInput.value = '';
                }
            }
        }
        
        // Función para mostrar/ocultar campo de distrito
        function toggleDistrito() {
            if (rolSelect && distritoContainer && distritoSelect) {
                if (rolSelect.value === '7') { // Rol Gerente de Tienda
                    distritoContainer.style.display = 'block';
                    distritoSelect.removeAttribute('disabled');
                    distritoSelect.setAttribute('required', 'required');
                } else {
                    distritoContainer.style.display = 'none';
                    distritoSelect.setAttribute('disabled', 'disabled');
                    distritoSelect.removeAttribute('required');
                    distritoSelect.selectedIndex = 0;
                }
            }
        }
        
        // Event listeners
        if (openModalBtn) {
            openModalBtn.addEventListener('click', function(e) {
                e.preventDefault();
                abrirModalUsuario();
            });
        } else {
            console.error('Botón openModalBtn no encontrado');
        }
        
        if (closeModalBtn) {
            closeModalBtn.addEventListener('click', cerrarModalUsuario);
        }
        
        if (cancelModalBtn) {
            cancelModalBtn.addEventListener('click', cerrarModalUsuario);
        }
        
        if (rolSelect) {
            rolSelect.addEventListener('change', function() {
                toggleCodigoProductor();
                toggleDistrito();
            });
        }
        
        // Cerrar modal al hacer clic fuera del contenido
        if (addUserModal) {
            addUserModal.addEventListener('click', function(event) {
                if (event.target === addUserModal) {
                    cerrarModalUsuario();
                }
            });
        }
        
        // Cerrar modal con la tecla ESC
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape' && addUserModal && addUserModal.classList.contains('show')) {
                cerrarModalUsuario();
            }
        });
        
        // ===================== Manejo del Modal de Enviar por Correo =====================
        const sendEmailModal = document.getElementById('sendEmailModal');
        const openSendEmailModalBtn = document.getElementById('openSendEmailModalBtn');
        const closeSendEmailModalBtn = document.querySelector('#sendEmailModal .modal-close');
        const cancelSendEmailModalBtn = document.querySelector('#sendEmailModal .modal-cancel');
        
        // Función para obtener los filtros actuales de la URL
        function obtenerFiltrosActuales() {
            const urlParams = new URLSearchParams(window.location.search);
            const busqueda = urlParams.get('busqueda') || '';
            const rol = urlParams.get('rol') || '';
            const estado = urlParams.get('estado') || '';
            const sortBy = urlParams.get('sortBy') || '';
            const sortOrder = urlParams.get('sortOrder') || '';
            
            return { busqueda, rol, estado, sortBy, sortOrder };
        }
        
        // Función para generar información de filtros
        function generarInfoFiltros(filtros) {
            let info = [];
            if (filtros.busqueda) info.push('Búsqueda: ' + filtros.busqueda);
            if (filtros.rol) {
                const rolNames = { '1': 'Administrador', '2': 'Logística', '3': 'Productor', '4': 'Almacén' };
                info.push('Rol: ' + (rolNames[filtros.rol] || filtros.rol));
            }
            if (filtros.estado) {
                info.push('Estado: ' + (filtros.estado === '1' ? 'Activo' : 'Inactivo'));
            }
            return info.length > 0 ? info.join('; ') : 'Sin filtros aplicados';
        }
        
        // Función para abrir el modal de enviar correo
        function abrirModalEnviarCorreo() {
            if (sendEmailModal) {
                const filtros = obtenerFiltrosActuales();
                
                // Actualizar campos hidden del formulario
                const busquedaInput = document.getElementById('modalBusqueda');
                const rolInput = document.getElementById('modalRolFiltro');
                const estadoInput = document.getElementById('modalEstadoFiltro');
                
                if (busquedaInput) busquedaInput.value = filtros.busqueda;
                if (rolInput) rolInput.value = filtros.rol;
                if (estadoInput) estadoInput.value = filtros.estado;
                
                // Limpiar formulario
                document.getElementById('modalEmailDestino').value = '';
                document.getElementById('modalAsunto').value = 'Reporte de Usuarios - TELITO BODEGUERO';
                document.getElementById('modalMensaje').value = '';
                
                sendEmailModal.classList.add('show');
                sendEmailModal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            } else {
                console.error('Modal sendEmailModal no encontrado');
            }
        }
        
        // Función para cerrar el modal de enviar correo
        function cerrarModalEnviarCorreo() {
            if (sendEmailModal) {
                sendEmailModal.classList.remove('show');
                sendEmailModal.style.display = 'none';
                document.body.style.overflow = '';
            }
        }
        
        // Event listeners para el modal de enviar correo
        if (openSendEmailModalBtn) {
            openSendEmailModalBtn.addEventListener('click', function(e) {
                e.preventDefault();
                abrirModalEnviarCorreo();
            });
        } else {
            console.error('Botón openSendEmailModalBtn no encontrado');
        }
        
        if (closeSendEmailModalBtn) {
            closeSendEmailModalBtn.addEventListener('click', cerrarModalEnviarCorreo);
        }
        
        if (cancelSendEmailModalBtn) {
            cancelSendEmailModalBtn.addEventListener('click', cerrarModalEnviarCorreo);
        }
        
        // Cerrar modal al hacer clic fuera del contenido
        if (sendEmailModal) {
            sendEmailModal.addEventListener('click', function(event) {
                if (event.target === sendEmailModal) {
                    cerrarModalEnviarCorreo();
                }
            });
        }
        
        // Cerrar modal con la tecla ESC
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape' && sendEmailModal && sendEmailModal.classList.contains('show')) {
                cerrarModalEnviarCorreo();
            }
            if (event.key === 'Escape' && editUserModal && editUserModal.classList.contains('show')) {
                cerrarModalEditarUsuario();
            }
        });
        
        // ===================== Manejo del Modal de Editar Usuario =====================
        const editUserModal = document.getElementById('editUserModal');
        const closeEditModalBtn = document.querySelector('#editUserModal .modal-close');
        const cancelEditModalBtn = document.querySelector('#editUserModal .modal-cancel');
        const editRolSelect = document.getElementById('editRol');
        const editCodigoProductorContainer = document.getElementById('editCodigoProductorContainer');
        const editCodigoProductorInput = document.getElementById('editCodigoProductor');
        const editDistritoContainer = document.getElementById('editDistritoContainer');
        const editDistritoSelect = document.getElementById('editDistrito');
        
        // Función para abrir el modal de edición
        function abrirModalEditarUsuario() {
            if (editUserModal) {
                editUserModal.classList.add('show');
                editUserModal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            }
        }
        
        // Función para cerrar el modal de edición
        function cerrarModalEditarUsuario() {
            if (editUserModal) {
                editUserModal.classList.remove('show');
                editUserModal.style.display = 'none';
                document.body.style.overflow = '';
            }
        }
        
        // Función para mostrar/ocultar campos según el rol
        function toggleEditCodigoProductor() {
            if (editRolSelect.value === '3') {
                editCodigoProductorContainer.style.display = 'block';
                editCodigoProductorInput.removeAttribute('disabled');
            } else {
                editCodigoProductorContainer.style.display = 'none';
                editCodigoProductorInput.setAttribute('disabled', 'disabled');
            }
        }
        
        function toggleEditDistrito() {
            if (editRolSelect.value === '7') {
                editDistritoContainer.style.display = 'block';
                editDistritoSelect.removeAttribute('disabled');
                editDistritoSelect.setAttribute('required', 'required');
            } else {
                editDistritoContainer.style.display = 'none';
                editDistritoSelect.setAttribute('disabled', 'disabled');
                editDistritoSelect.removeAttribute('required');
            }
        }
        
        // Event listeners para el modal de edición
        if (closeEditModalBtn) {
            closeEditModalBtn.addEventListener('click', cerrarModalEditarUsuario);
        }
        
        if (cancelEditModalBtn) {
            cancelEditModalBtn.addEventListener('click', cerrarModalEditarUsuario);
        }
        
        if (editRolSelect) {
            editRolSelect.addEventListener('change', function() {
                toggleEditCodigoProductor();
                toggleEditDistrito();
            });
        }
        
        // Función para actualizar el toggle switch visualmente
        function actualizarToggleSwitch() {
            const editActivoCheckbox = document.getElementById('editActivo');
            const estadoLabelInactivo = document.getElementById('estadoLabelInactivo');
            const estadoLabelActivo = document.getElementById('estadoLabelActivo');
            
            if (editActivoCheckbox) {
                const toggleSlider = editActivoCheckbox.nextElementSibling;
                const toggleKnob = toggleSlider ? toggleSlider.querySelector('.toggle-knob') : null;
                
                if (editActivoCheckbox.checked) {
                    // Activo: mover a la derecha, fondo verde
                    if (toggleSlider) {
                        toggleSlider.style.backgroundColor = '#28a745';
                    }
                    if (toggleKnob) {
                        toggleKnob.style.transform = 'translateX(35px)';
                    }
                    if (estadoLabelInactivo) estadoLabelInactivo.style.opacity = '0.4';
                    if (estadoLabelActivo) estadoLabelActivo.style.opacity = '1';
                } else {
                    // Inactivo: mover a la izquierda, fondo rojo
                    if (toggleSlider) {
                        toggleSlider.style.backgroundColor = '#dc3545';
                    }
                    if (toggleKnob) {
                        toggleKnob.style.transform = 'translateX(0)';
                    }
                    if (estadoLabelInactivo) estadoLabelInactivo.style.opacity = '1';
                    if (estadoLabelActivo) estadoLabelActivo.style.opacity = '0.4';
                }
            }
        }
        
        // Configurar el toggle switch - debe llamarse después de cargar el modal
        function configurarToggleSwitch() {
            const editActivoCheckbox = document.getElementById('editActivo');
            if (!editActivoCheckbox) {
                console.log('Checkbox no encontrado');
                return;
            }
            
            const toggleSlider = editActivoCheckbox.nextElementSibling;
            if (!toggleSlider) {
                console.log('Toggle slider no encontrado');
                return;
            }
            
            // Event listener para el cambio del checkbox
            editActivoCheckbox.addEventListener('change', function() {
                actualizarToggleSwitch();
            });
            
            // Hacer que el toggle-slider sea clickeable
            toggleSlider.style.pointerEvents = 'auto';
            toggleSlider.style.cursor = 'pointer';
            toggleSlider.onclick = function(e) {
                e.preventDefault();
                e.stopPropagation();
                console.log('Toggle clicked, estado actual:', editActivoCheckbox.checked);
                editActivoCheckbox.checked = !editActivoCheckbox.checked;
                console.log('Nuevo estado:', editActivoCheckbox.checked);
                editActivoCheckbox.dispatchEvent(new Event('change', { bubbles: true }));
            };
            
            // También hacer clickeable el label completo
            const toggleLabel = editActivoCheckbox.closest('.toggle-switch');
            if (toggleLabel) {
                toggleLabel.style.cursor = 'pointer';
                toggleLabel.onclick = function(e) {
                    // Si el click fue en el slider, no hacer nada (ya se maneja arriba)
                    if (e.target === toggleSlider || toggleSlider.contains(e.target)) {
                        return;
                    }
                    e.preventDefault();
                    e.stopPropagation();
                    editActivoCheckbox.checked = !editActivoCheckbox.checked;
                    editActivoCheckbox.dispatchEvent(new Event('change', { bubbles: true }));
                };
            }
            
            // Inicializar el estado visual
            setTimeout(function() {
                actualizarToggleSwitch();
            }, 50);
        }
        
        // Manejar envío del formulario de edición
        const formEditarUsuario = document.getElementById('formEditarUsuario');
        if (formEditarUsuario) {
            formEditarUsuario.addEventListener('submit', function(e) {
                // El formulario se enviará normalmente, el servlet redirigirá después
                // No necesitamos prevenir el comportamiento por defecto
            });
        }
        
        // Cerrar modal al hacer clic fuera
        if (editUserModal) {
            editUserModal.addEventListener('click', function(event) {
                if (event.target === editUserModal) {
                    cerrarModalEditarUsuario();
                }
            });
        }
        
        // Guardar el HTML original del modal body
        const editModalBodyOriginal = document.querySelector('#editUserModal .modal-body') ? 
            document.querySelector('#editUserModal .modal-body').innerHTML : null;
        
        // Función para editar usuario (cargar datos y abrir modal)
        window.editarUsuario = function(idUsuario) {
            // Restaurar el HTML original si fue modificado
            const modalBody = document.querySelector('#editUserModal .modal-body');
            if (modalBody && editModalBodyOriginal) {
                modalBody.innerHTML = editModalBodyOriginal;
            }
            
            // Mostrar overlay de carga
            const loadingOverlay = document.createElement('div');
            loadingOverlay.id = 'editUserLoadingOverlay';
            loadingOverlay.style.cssText = 'position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(255,255,255,0.9); display: flex; align-items: center; justify-content: center; z-index: 10; border-radius: 16px;';
            loadingOverlay.innerHTML = '<div class="text-center"><i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: #6F4E37;"></i><p style="color: #6F4E37; font-weight: 600;">Cargando datos del usuario...</p></div>';
            
            const modalContent = document.querySelector('#editUserModal .modal-content');
            if (modalContent) {
                modalContent.style.position = 'relative';
                modalContent.appendChild(loadingOverlay);
            }
            
            abrirModalEditarUsuario();
            
            // Cargar datos del usuario vía AJAX
            fetch('<%= request.getContextPath() %>/UsuarioServlet?action=obtenerUsuarioJson&id=' + idUsuario, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Error al cargar los datos del usuario');
                }
                return response.json();
            })
            .then(data => {
                // Remover overlay de carga
                const overlay = document.getElementById('editUserLoadingOverlay');
                if (overlay) {
                    overlay.remove();
                }
                
                // Llenar el formulario con los datos
                const idInput = document.getElementById('editIdUsuario');
                const nombresInput = document.getElementById('editNombres');
                const apellidosInput = document.getElementById('editApellidos');
                const emailInput = document.getElementById('editEmail');
                const rolSelect = document.getElementById('editRol');
                const codigoProductorInput = document.getElementById('editCodigoProductor');
                const distritoSelect = document.getElementById('editDistrito');
                const activoCheckbox = document.getElementById('editActivo');
                
                if (idInput) idInput.value = data.idUsuario || '';
                if (nombresInput) nombresInput.value = data.nombres || '';
                if (apellidosInput) apellidosInput.value = data.apellidos || '';
                if (emailInput) emailInput.value = data.email || '';
                if (rolSelect) rolSelect.value = data.rolId || '';
                
                // Código de productor
                if (codigoProductorInput) {
                    codigoProductorInput.value = data.codigoProductor || '';
                }
                
                // Distrito
                if (distritoSelect && data.distritoId) {
                    distritoSelect.value = data.distritoId;
                }
                
                // Estado activo
                if (activoCheckbox) {
                    activoCheckbox.checked = data.activo === true;
                }
                
                // Configurar el toggle switch después de cargar los datos
                setTimeout(function() {
                    configurarToggleSwitch();
                }, 150);
                
                // Mostrar/ocultar campos según el rol
                toggleEditCodigoProductor();
                toggleEditDistrito();
            })
            .catch(error => {
                console.error('Error al cargar usuario:', error);
                const overlay = document.getElementById('editUserLoadingOverlay');
                if (overlay) {
                    overlay.remove();
                }
                cerrarModalEditarUsuario();
                alert('Error al cargar los datos del usuario. Por favor, intenta nuevamente.');
            });
        };
    });
</script>

<!-- ===================== Modal: Agregar Usuario ===================== -->
<div id="addUserModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-user-plus"></i> Agregar Nuevo Usuario</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="<%= request.getContextPath() %>/UsuarioServlet?action=guardar" id="formAgregarUsuario">
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modalNombres">
                                <i class="fas fa-user"></i>
                                Nombres <span class="text-danger">*</span>
                            </label>
                            <input type="text" 
                                   name="nombres" 
                                   id="modalNombres" 
                                   placeholder="Ej: Juan" 
                                   required>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modalApellidos">
                                <i class="fas fa-user"></i>
                                Apellidos <span class="text-danger">*</span>
                            </label>
                            <input type="text" 
                                   name="apellidos" 
                                   id="modalApellidos" 
                                   placeholder="Ej: Pérez" 
                                   required>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalEmail">
                        <i class="fas fa-envelope"></i>
                        Correo electrónico <span class="text-danger">*</span>
                    </label>
                    <input type="email" 
                           name="email" 
                           id="modalEmail" 
                           placeholder="Ej: juan.perez@example.com" 
                           required>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modalPassword">
                                <i class="fas fa-lock"></i>
                                Contraseña <span class="text-danger">*</span>
                            </label>
                            <input type="password" 
                                   name="password" 
                                   id="modalPassword" 
                                   placeholder="********" 
                                   required>
                            <div class="form-hint">
                                <i class="fas fa-info-circle"></i>
                                <span>Mínimo 4 caracteres</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modalPasswordConfirm">
                                <i class="fas fa-lock"></i>
                                Confirmar Contraseña <span class="text-danger">*</span>
                            </label>
                            <input type="password" 
                                   id="modalPasswordConfirm" 
                                   placeholder="********" 
                                   required>
                            <div class="form-hint">
                                <i class="fas fa-info-circle"></i>
                                <span>Repite la contraseña</span>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalRol">
                        <i class="fas fa-user-tag"></i>
                        Rol <span class="text-danger">*</span>
                    </label>
                    <select name="rol_id" id="modalRol" required>
                        <option value="" disabled selected>Selecciona un rol</option>
                        <option value="1">Administrador</option>
                        <option value="2">Logística</option>
                        <option value="3">Productor</option>
                        <option value="4">Almacén</option>
                        <option value="7">Gerente de Tienda</option>
                    </select>
                </div>
                
                <!-- Campo de código de productor (solo visible si el rol es Productor) -->
                <div class="form-group" id="modalCodigoProductorContainer" style="display: none;">
                    <label for="modalCodigoProductor">
                        <i class="fas fa-tag"></i>
                        Código de Productor
                    </label>
                    <input type="text" 
                           name="codigo_productor" 
                           id="modalCodigoProductor" 
                           placeholder="Ej: PROD-0001 (se generará automáticamente si se deja vacío)" 
                           pattern="PROD-[0-9]{4}" 
                           title="Formato: PROD-0001"
                           disabled>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Si se deja vacío, se generará automáticamente. Formato: PROD-0001, PROD-0002, etc.</span>
                    </div>
                </div>
                
                <!-- Campo de distrito (solo visible si el rol es Gerente de Tienda) -->
                <div class="form-group" id="modalDistritoContainer" style="display: none;">
                    <label for="modalDistrito">
                        <i class="fas fa-map-marker-alt"></i>
                        Distrito <span class="text-danger">*</span>
                    </label>
                    <select name="distrito_id" id="modalDistrito" required disabled>
                        <option value="" disabled selected>Selecciona un distrito</option>
                        <% for (Distrito distrito : distritos) { %>
                            <option value="<%= distrito.getIdDistrito() %>"><%= distrito.getNombre() %></option>
                        <% } %>
                    </select>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Selecciona el distrito donde trabajará este gerente de tienda.</span>
                    </div>
                </div>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn-secondary modal-cancel">
                    <i class="fas fa-times"></i>
                    Cancelar
                </button>
                <button type="submit">
                    <i class="fas fa-check"></i>
                    Crear Usuario
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ===================== Modal: Enviar Reporte por Correo ===================== -->
<div id="sendEmailModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-envelope"></i> Enviar Reporte por Correo</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="<%= request.getContextPath() %>/UsuarioReporteServlet" id="formEnviarCorreo">
            <input type="hidden" name="action" value="enviar">
            <input type="hidden" name="busqueda" id="modalBusqueda" value="">
            <input type="hidden" name="rol" id="modalRolFiltro" value="">
            <input type="hidden" name="estado" id="modalEstadoFiltro" value="">
            
            <div class="modal-body">
                <div class="form-group">
                    <label for="modalEmailDestino">
                        <i class="fas fa-envelope"></i>
                        Email de Destino <span class="text-danger">*</span>
                    </label>
                    <input type="email" 
                           name="email_destino" 
                           id="modalEmailDestino" 
                           placeholder="correo@ejemplo.com" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el correo electrónico donde deseas recibir el reporte.</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalAsunto">
                        <i class="fas fa-tag"></i>
                        Asunto del Correo
                    </label>
                    <input type="text" 
                           name="asunto" 
                           id="modalAsunto" 
                           value="Reporte de Usuarios - TELITO BODEGUERO" 
                           placeholder="Asunto del correo">
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Si no especificas un asunto, se usará uno por defecto.</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalMensaje">
                        <i class="fas fa-comment"></i>
                        Mensaje Adicional (Opcional)
                    </label>
                    <textarea name="mensaje" 
                              id="modalMensaje" 
                              rows="4" 
                              placeholder="Escribe un mensaje personalizado que aparecerá en el correo..."></textarea>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Puedes agregar un mensaje personalizado que aparecerá en el cuerpo del correo.</span>
                    </div>
                </div>
                
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <strong>Nota:</strong> El archivo Excel se generará con los mismos filtros que tienes aplicados en la tabla de usuarios. 
                    Incluirá todas las columnas (ID, Nombres, Apellidos, Correo, Rol, Estado) y tendrá filtros automáticos habilitados.
                </div>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn-secondary modal-cancel">
                    <i class="fas fa-times"></i>
                    Cancelar
                </button>
                <button type="submit">
                    <i class="fas fa-paper-plane"></i>
                    Enviar Reporte
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ===================== Modal: Editar Usuario ===================== -->
<div id="editUserModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-user-edit"></i> Editar Usuario</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="<%= request.getContextPath() %>/UsuarioServlet?action=actualizar" id="formEditarUsuario">
            <input type="hidden" name="id_usuario" id="editIdUsuario">
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="editNombres">
                                <i class="fas fa-user"></i>
                                Nombres <span class="text-danger">*</span>
                            </label>
                            <input type="text" 
                                   name="nombres" 
                                   id="editNombres" 
                                   placeholder="Ej: Juan" 
                                   required>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="editApellidos">
                                <i class="fas fa-user"></i>
                                Apellidos <span class="text-danger">*</span>
                            </label>
                            <input type="text" 
                                   name="apellidos" 
                                   id="editApellidos" 
                                   placeholder="Ej: Pérez" 
                                   required>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editEmail">
                        <i class="fas fa-envelope"></i>
                        Correo electrónico <span class="text-danger">*</span>
                    </label>
                    <input type="email" 
                           name="email" 
                           id="editEmail" 
                           placeholder="Ej: juan.perez@example.com" 
                           required>
                </div>
                
                <div class="form-group">
                    <label for="editRol">
                        <i class="fas fa-user-tag"></i>
                        Rol <span class="text-danger">*</span>
                    </label>
                    <select name="rol_id" id="editRol" required>
                        <option value="" disabled>Selecciona un rol</option>
                        <option value="1">Administrador</option>
                        <option value="2">Logística</option>
                        <option value="3">Productor</option>
                        <option value="4">Almacén</option>
                        <option value="7">Gerente de Tienda</option>
                    </select>
                </div>
                
                <!-- Campo de código de productor (solo visible si el rol es Productor) -->
                <div class="form-group" id="editCodigoProductorContainer" style="display: none;">
                    <label for="editCodigoProductor">
                        <i class="fas fa-tag"></i>
                        Código de Productor
                    </label>
                    <input type="text" 
                           name="codigo_productor" 
                           id="editCodigoProductor" 
                           placeholder="Ej: PROD-0001" 
                           pattern="PROD-[0-9]{4}" 
                           title="Formato: PROD-0001"
                           disabled>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Código único para identificar al productor. Formato: PROD-0001, PROD-0002, etc.</span>
                    </div>
                </div>
                
                <!-- Campo de distrito (solo visible si el rol es Gerente de Tienda) -->
                <div class="form-group" id="editDistritoContainer" style="display: none;">
                    <label for="editDistrito">
                        <i class="fas fa-map-marker-alt"></i>
                        Distrito <span class="text-danger">*</span>
                    </label>
                    <select name="distrito_id" id="editDistrito">
                        <option value="" disabled selected>Selecciona un distrito</option>
                        <% for (Distrito distrito : distritos) { %>
                            <option value="<%= distrito.getIdDistrito() %>"><%= distrito.getNombre() %></option>
                        <% } %>
                    </select>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Selecciona el distrito donde trabajará este gerente de tienda.</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="fw-semibold mb-2" style="font-size: 0.95rem; display: block;">
                        <i class="fas fa-user-check me-2"></i>Estado del Usuario
                    </label>
                    <div style="display: flex; align-items: center; gap: 15px; padding: 15px; background: rgba(0,168,150,0.05); border-radius: 10px; border: 2px solid rgba(0,168,150,0.2);">
                        <span id="estadoLabelInactivo" style="font-weight: 600; color: #dc3545; font-size: 0.9rem;">Inactivo</span>
                        <label class="toggle-switch" style="position: relative; display: inline-block; width: 70px; height: 35px; margin: 0; cursor: pointer; user-select: none;">
                            <input type="checkbox" id="editActivo" name="activo" value="true" style="opacity: 0; width: 0; height: 0; position: absolute; pointer-events: none;">
                            <span class="toggle-slider" style="position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #dc3545; transition: 0.4s; border-radius: 35px; box-shadow: 0 2px 5px rgba(0,0,0,0.2); z-index: 1; pointer-events: auto;">
                                <span class="toggle-knob" style="position: absolute; content: ''; height: 28px; width: 28px; left: 4px; bottom: 3.5px; background-color: white; transition: 0.4s; border-radius: 50%; box-shadow: 0 2px 4px rgba(0,0,0,0.3); pointer-events: none;"></span>
                            </span>
                        </label>
                        <span id="estadoLabelActivo" style="font-weight: 600; color: #28a745; font-size: 0.9rem;">Activo</span>
                    </div>
                    <div class="form-hint mt-2">
                        <i class="fas fa-info-circle"></i>
                        <span>Desliza el botón para cambiar el estado del usuario. Si es productor, sus productos también cambiarán de estado.</span>
                    </div>
                </div>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn-secondary modal-cancel">
                    <i class="fas fa-times"></i>
                    Cancelar
                </button>
                <button type="submit">
                    <i class="fas fa-save"></i>
                    Guardar Cambios
                </button>
            </div>
        </form>
    </div>
</div>

</body>
</html>