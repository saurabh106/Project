package controller;

import model.OrderPojo;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/OrderController")
public class OrderController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        OrderPojo orderPojo = new OrderPojo();

        if ("updateStatus".equals(action)) {

            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String status = request.getParameter("status");

            orderPojo.updateOrderStatus(orderId, status);
            response.sendRedirect("OrderController");
        }

        else if ("cancelOrder".equals(action)) {

            int orderId = Integer.parseInt(request.getParameter("orderId"));
            orderPojo.updateOrderStatus(orderId, "CANCELLED");
            response.sendRedirect("OrderController");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        

        String portId = (String) session.getAttribute("port_id");
        OrderPojo orderPojo = new OrderPojo();

        List<OrderPojo> orders =
                orderPojo.viewOrdersBySeller(portId);


        request.setAttribute("orders", orders);
        request.getRequestDispatcher("orders.jsp")
               .forward(request, response);
    }
}
