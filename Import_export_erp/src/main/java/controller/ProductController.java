package controller;

import model.ProductPojo;
import model.ReportPojo;
import model.OrderPojo;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/ProductController")
public class ProductController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sellerPortId = (String) session.getAttribute("port_id");
        ProductPojo productPojo = new ProductPojo();

        if ("add".equals(action)) {

            ProductPojo p = new ProductPojo();
            p.setProductName(request.getParameter("productName"));
            p.setDescription(request.getParameter("description"));
            p.setQuantity(Integer.parseInt(request.getParameter("quantity")));
            p.setPrice(Double.parseDouble(request.getParameter("price")));
            p.setSellerPortId(sellerPortId);

            productPojo.addProduct(p);
            response.sendRedirect("ProductController?view=products");
            return;
        }
        if ("edit".equals(action)) {

            int productId = Integer.parseInt(request.getParameter("productId"));
            ProductPojo product = productPojo.getProductById(productId);

            request.setAttribute("product", product);
            request.getRequestDispatcher("update_product.jsp")
                   .forward(request, response);
            return;
        }
        if ("update".equals(action)) {

            ProductPojo p = new ProductPojo();
            p.setProductId(Integer.parseInt(request.getParameter("productId")));
            p.setProductName(request.getParameter("productName"));
            p.setDescription(request.getParameter("description"));
            p.setQuantity(Integer.parseInt(request.getParameter("quantity")));
            p.setPrice(Double.parseDouble(request.getParameter("price")));

            productPojo.updateProduct(p);
            response.sendRedirect("ProductController?view=products");
            return;
        }

        if ("delete".equals(action)) {

            int productId = Integer.parseInt(request.getParameter("productId"));
            productPojo.deleteProduct(productId);
            response.sendRedirect("ProductController?view=products");
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

        String sellerPortId = (String) session.getAttribute("port_id");

        ProductPojo productPojo = new ProductPojo();
        OrderPojo orderPojo = new OrderPojo();
        ReportPojo reportPojo = new ReportPojo();

        List<ProductPojo> products =
                productPojo.getProductsBySeller(sellerPortId);

        List<OrderPojo> orders =
                orderPojo.viewOrdersBySeller(sellerPortId);

        List<ReportPojo> reports =
                reportPojo.viewReportsByUser(sellerPortId);

        request.setAttribute("products", products);
        request.setAttribute("orders", orders);
        request.setAttribute("reports", reports);

        String view = request.getParameter("view");

        if ("products".equals(view)) {
                  request.getRequestDispatcher("add_product.jsp")
                   .forward(request, response);
        } else {
        
            request.getRequestDispatcher("dashboard.jsp")
                   .forward(request, response);
        }
    }

}
