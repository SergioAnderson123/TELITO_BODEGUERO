package com.example.telito.logistica.servlets;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.example.telito.logistica.beans.PlanTransporteBean;
import com.example.telito.logistica.daos.ConductorDao;
import com.example.telito.logistica.daos.DistritoDao;
import com.example.telito.logistica.daos.LoteDao;
import com.example.telito.logistica.daos.PlanTransporteDao;
import com.example.telito.logistica.daos.VehiculoDao;
import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "PlanTransporteServlet", value = "/planes-transporte")
public class PlanTransporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");

        PlanTransporteDao planTransporteDao = new PlanTransporteDao();
        RequestDispatcher rd;

        switch (action) {
            case "listar":
                String busqueda = request.getParameter("busqueda");
                String conductorId = request.getParameter("conductor");
                String estado = request.getParameter("estado");
                String fechaDesde = request.getParameter("fecha_desde");
                String fechaHasta = request.getParameter("fecha_hasta");

                ConductorDao conductorDao = new ConductorDao();

                ArrayList<PlanTransporteBean> listaPlanes = planTransporteDao.listarPlanesDeTransporte(busqueda, conductorId, estado, fechaDesde, fechaHasta);

                request.setAttribute("listaConductores", conductorDao.listarConductores());
                request.setAttribute("listaPlanes", listaPlanes);

                rd = request.getRequestDispatcher("/logistica/Distribucion/distribucion.jsp");
                rd.forward(request, response);
                break;

            case "crear":
                LoteDao loteDao = new LoteDao();
                ConductorDao conductorDaoForm = new ConductorDao();
                VehiculoDao vehiculoDao = new VehiculoDao();
                DistritoDao distritoDao = new DistritoDao();

                request.setAttribute("listaLotes", loteDao.listarLotesDisponibles());
                request.setAttribute("listaConductores", conductorDaoForm.listarConductores());
                request.setAttribute("listaVehiculos", vehiculoDao.listarVehiculos());
                request.setAttribute("listaDistritos", distritoDao.listarDistritos());

                rd = request.getRequestDispatcher("/logistica/Distribucion/form_plan_transporte.jsp");
                rd.forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // === LÓGICA PARA GUARDAR EL NUEVO PLAN ===

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        PlanTransporteDao planTransporteDao = new PlanTransporteDao();

        if ("guardar".equals(action)) {
            // 1. Leemos los datos enviados desde el formulario
            int loteId = Integer.parseInt(request.getParameter("lote_id"));
            int conductorId = Integer.parseInt(request.getParameter("conductor_id"));
            int vehiculoId = Integer.parseInt(request.getParameter("vehiculo_id"));
            String fechaEntrega = request.getParameter("fecha_entrega");
            int distritoId = Integer.parseInt(request.getParameter("distrito_id"));

            // 2. Generamos el número de plan secuencial
            int ultimoId = planTransporteDao.obtenerUltimoId();
            int nuevoId = ultimoId + 1;
            String numeroPlan = String.format("PT%03d", nuevoId); // Formato PT001, PT011, etc.

            // 3. Llamamos al DAO para guardar en la BD
            planTransporteDao.crearPlan(numeroPlan, loteId, conductorId, vehiculoId, fechaEntrega, distritoId);

            // 4. Redirigimos al usuario a la lista para que vea el nuevo plan
            response.sendRedirect(request.getContextPath() + "/planes-transporte");

        } else {
            // Si la acción no es "guardar", simplemente mostramos la lista
            doGet(request, response);
        }
    }
}