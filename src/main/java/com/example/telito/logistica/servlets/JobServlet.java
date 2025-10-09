package com.example.telito.logistica.servlets;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.example.telito.logistica.beans.Job;
import com.example.telito.logistica.daos.JobDao;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;


@WebServlet(name = "JobServlet", value = "/JobServlet")
public class JobServlet extends HttpServlet {

    public void doGet(HttpServletRequest request,
                      HttpServletResponse response) throws IOException, ServletException {
            response.setContentType("text/html");


            //saca del modelo
            JobDao jobDao = new JobDao();
            ArrayList<Job> list = jobDao.listar();

            // Como mandar a la vista  -> job/lista.jsp

            String vista = "/logistica/job/lista.jsp";
            request.setAttribute("lista", list);
            RequestDispatcher rd = request.getRequestDispatcher(vista);
            rd.forward(request,response);

        }


}
