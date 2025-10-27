package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.StockMinimoConfig;
import com.example.telito.administrador.beans.Producto;
import com.example.telito.administrador.daos.StockMinimoDAO;
import com.example.telito.administrador.daos.ProductoDAO;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "StockMinimoServlet", value = "/StockMinimoServlet")
public class StockMinimoServlet extends HttpServlet {

    private StockMinimoDAO stockMinimoDAO = new StockMinimoDAO();
    private ProductoDAO productoDAO = new ProductoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null) {
            action = "listar";
        }

        switch (action) {
            case "listar":
                listarConfiguraciones(request, response);
                break;
            case "editar":
                mostrarFormularioEdicion(request, response);
                break;
            default:
                listarConfiguraciones(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null) {
            action = "listar";
        }

        switch (action) {
            case "crear":
                crearConfiguracion(request, response);
                break;
            case "actualizar":
                actualizarConfiguracion(request, response);
                break;
            case "eliminar":
                eliminarConfiguracion(request, response);
                break;
            case "aplicarGlobal":
                aplicarConfiguracionGlobal(request, response);
                break;
            default:
                listarConfiguraciones(request, response);
                break;
        }
    }

    private void listarConfiguraciones(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Obtener lista de configuraciones de stock mínimo
            ArrayList<StockMinimoConfig> listaStockMinimo = stockMinimoDAO.listarConfiguraciones();
            request.setAttribute("listaStockMinimo", listaStockMinimo);

            // Obtener lista de productos para el formulario
            ArrayList<Producto> listaProductos = productoDAO.listarProductos();
            request.setAttribute("listaProductos", listaProductos);

            // Obtener valores globales
            int stockMinimoGlobal = stockMinimoDAO.obtenerStockMinimoGlobal();
            int stockCriticoGlobal = stockMinimoDAO.obtenerStockCriticoGlobal();
            request.setAttribute("stockMinimoGlobal", stockMinimoGlobal);
            request.setAttribute("stockCriticoGlobal", stockCriticoGlobal);

            RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/gestion-stock-minimo.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar las configuraciones: " + e.getMessage());
            RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/gestion-stock-minimo.jsp");
            dispatcher.forward(request, response);
        }
    }

    private void mostrarFormularioEdicion(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int productoId = Integer.parseInt(request.getParameter("id"));

            // Obtener la configuración específica
            StockMinimoConfig stockMinimo = stockMinimoDAO.obtenerPorProducto(productoId);
            request.setAttribute("stockMinimo", stockMinimo);

            // Obtener lista de productos para el formulario
            ArrayList<Producto> listaProductos = productoDAO.listarProductos();
            request.setAttribute("listaProductos", listaProductos);

            RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/editar-stock-minimo.jsp");
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID de producto inválido");
            listarConfiguraciones(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar la configuración: " + e.getMessage());
            listarConfiguraciones(request, response);
        }
    }

    private void crearConfiguracion(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int productoId = Integer.parseInt(request.getParameter("productoId"));
            int stockMinimoLote = Integer.parseInt(request.getParameter("stockMinimoLote"));
            int stockCriticoLote = Integer.parseInt(request.getParameter("stockCriticoLote"));
            int stockMinimoProducto = Integer.parseInt(request.getParameter("stockMinimoProducto"));
            int stockCriticoProducto = Integer.parseInt(request.getParameter("stockCriticoProducto"));
            boolean activo = request.getParameter("activo") != null;

            // Verificar que los stocks críticos sean menores o iguales a los stocks mínimos
            if (stockCriticoLote > stockMinimoLote || stockCriticoProducto > stockMinimoProducto) {
                request.setAttribute("error", "Los stocks críticos no pueden ser mayores a los stocks mínimos");
                listarConfiguraciones(request, response);
                return;
            }

            // Crear objeto de configuración
            Producto producto = new Producto();
            producto.setIdProducto(productoId);

            StockMinimoConfig config = new StockMinimoConfig();
            config.setProducto(producto);
            config.setStockMinimoLote(stockMinimoLote);
            config.setStockCriticoLote(stockCriticoLote);
            config.setStockMinimoProducto(stockMinimoProducto);
            config.setStockCriticoProducto(stockCriticoProducto);
            config.setActivo(activo);

            // Verificar si ya existe una configuración para este producto
            StockMinimoConfig configExistente = stockMinimoDAO.obtenerPorProducto(productoId);
            if (configExistente != null) {
                request.setAttribute("error", "Ya existe una configuración para este producto");
                listarConfiguraciones(request, response);
                return;
            }

            boolean exito = stockMinimoDAO.crearConfiguracion(config);

            if (exito) {
                request.setAttribute("mensaje", "Configuración creada exitosamente");
            } else {
                request.setAttribute("error", "Error al crear la configuración");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Los valores de stock deben ser números válidos");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al crear la configuración: " + e.getMessage());
        }

        listarConfiguraciones(request, response);
    }

    private void actualizarConfiguracion(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int idStockMinimo = Integer.parseInt(request.getParameter("idStockMinimo"));
            int stockMinimoLote = Integer.parseInt(request.getParameter("stockMinimoLote"));
            int stockCriticoLote = Integer.parseInt(request.getParameter("stockCriticoLote"));
            int stockMinimoProducto = Integer.parseInt(request.getParameter("stockMinimoProducto"));
            int stockCriticoProducto = Integer.parseInt(request.getParameter("stockCriticoProducto"));
            boolean activo = request.getParameter("activo") != null;

            // Verificar que los stocks críticos sean menores o iguales a los stocks mínimos
            if (stockCriticoLote > stockMinimoLote || stockCriticoProducto > stockMinimoProducto) {
                request.setAttribute("error", "Los stocks críticos no pueden ser mayores a los stocks mínimos");
                listarConfiguraciones(request, response);
                return;
            }

            // Crear configuración con el ID existente
            StockMinimoConfig config = new StockMinimoConfig();
            config.setIdStockMinimo(idStockMinimo);
            config.setStockMinimoLote(stockMinimoLote);
            config.setStockCriticoLote(stockCriticoLote);
            config.setStockMinimoProducto(stockMinimoProducto);
            config.setStockCriticoProducto(stockCriticoProducto);
            config.setActivo(activo);

            boolean exito = stockMinimoDAO.actualizarConfiguracion(config);

            if (exito) {
                request.setAttribute("mensaje", "Configuración actualizada exitosamente");
            } else {
                request.setAttribute("error", "Error al actualizar la configuración");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Los valores de stock deben ser números válidos");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al actualizar la configuración: " + e.getMessage());
        }

        listarConfiguraciones(request, response);
    }

    private void eliminarConfiguracion(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int idStockMinimo = Integer.parseInt(request.getParameter("idStockMinimo"));

            boolean exito = stockMinimoDAO.eliminarConfiguracion(idStockMinimo);

            if (exito) {
                request.setAttribute("mensaje", "Configuración eliminada exitosamente");
            } else {
                request.setAttribute("error", "Error al eliminar la configuración");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID de configuración inválido");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al eliminar la configuración: " + e.getMessage());
        }

        listarConfiguraciones(request, response);
    }

    private void aplicarConfiguracionGlobal(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Obtener valores del formulario enviado por el admin
            int stockMinimoLote = Integer.parseInt(request.getParameter("stockMinimoLote"));
            int stockCriticoLote = Integer.parseInt(request.getParameter("stockCriticoLote"));
            int stockMinimoProducto = Integer.parseInt(request.getParameter("stockMinimoProducto"));
            int stockCriticoProducto = Integer.parseInt(request.getParameter("stockCriticoProducto"));

            // Validar que los stocks críticos sean menores o iguales a los stocks mínimos
            if (stockCriticoLote > stockMinimoLote || stockCriticoProducto > stockMinimoProducto) {
                request.setAttribute("error", "Los stocks críticos no pueden ser mayores a los stocks mínimos");
                listarConfiguraciones(request, response);
                return;
            }

            // Obtener todos los productos
            ArrayList<Producto> listaProductos = productoDAO.listarProductos();
            int configuracionesCreadas = 0;

            for (Producto producto : listaProductos) {
                // Verificar si ya existe configuración para este producto
                StockMinimoConfig configExistente = stockMinimoDAO.obtenerPorProducto(producto.getIdProducto());

                if (configExistente == null) {
                    // Crear nueva configuración con los valores elegidos por el admin
                    StockMinimoConfig config = new StockMinimoConfig();
                    config.setProducto(producto);
                    config.setStockMinimoLote(stockMinimoLote);
                    config.setStockCriticoLote(stockCriticoLote);
                    config.setStockMinimoProducto(stockMinimoProducto);
                    config.setStockCriticoProducto(stockCriticoProducto);
                    config.setActivo(true);

                    if (stockMinimoDAO.crearConfiguracion(config)) {
                        configuracionesCreadas++;
                    }
                }
            }

            request.setAttribute("mensaje", "Se aplicó la configuración global a " + configuracionesCreadas + " productos");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al aplicar configuración global: " + e.getMessage());
        }

        listarConfiguraciones(request, response);
    }
}