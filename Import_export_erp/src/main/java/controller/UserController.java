package controller;

import model.UserPojo;
import util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/UserController")
public class UserController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        UserPojo userPojo = new UserPojo();

       
        if ("register".equals(action)) {

            String portId = request.getParameter("portId");
            if (userPojo.getUserByPortId(portId) != null) {
                response.sendRedirect("register.jsp?error=duplicate_port");
                return;
            }

            String rawPassword = request.getParameter("password");
            if (rawPassword == null || rawPassword.length() < 6) {
                response.sendRedirect("register.jsp?error=password_short");
                return;
            }

            UserPojo user = new UserPojo();
            user.setPortId(portId);
            user.setName(request.getParameter("name"));
            user.setEmail(request.getParameter("email"));
            user.setLocation(request.getParameter("location"));
            user.setPassword(PasswordUtil.hashPassword(rawPassword));
            userPojo.registerUser(user);
            response.sendRedirect("login.jsp");
            
        }

      
        else if ("login".equals(action)) {

            String portId = request.getParameter("portId");
            String rawPassword = request.getParameter("password");

            if (rawPassword == null || rawPassword.length() < 6) {
                response.sendRedirect("login.jsp?error=short_password");
                return;
            }

            String hashedPassword = PasswordUtil.hashPassword(rawPassword);

            UserPojo loggedUser =
                    userPojo.loginUser(portId, hashedPassword);

            if (loggedUser != null) {
                HttpSession session = request.getSession();
                session.setAttribute("userProfile", loggedUser);
                session.setAttribute("port_id", loggedUser.getPortId());
                response.sendRedirect("ProductController");
            } else {
                response.sendRedirect("login.jsp?error=invalid");
            }
        }

        else if ("update".equals(action)) {

            HttpSession session = request.getSession(false);
            UserPojo oldUser =
                    (UserPojo) session.getAttribute("userProfile");

            if (oldUser == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            String oldPortId = oldUser.getPortId();

            UserPojo user = new UserPojo();
            user.setPortId(request.getParameter("portId"));
            user.setName(request.getParameter("name"));
            user.setEmail(request.getParameter("email"));
            user.setLocation(request.getParameter("location"));

            userPojo.updateUser(oldPortId, user);

            UserPojo updatedUser =
                    userPojo.getUserByPortId(user.getPortId());

            session.setAttribute("userProfile", updatedUser);
            session.setAttribute("port_id", updatedUser.getPortId());

            response.sendRedirect("ProductController");
        }

        else if ("forget".equals(action)) {

            String portId = request.getParameter("portId");
            String newPassword = request.getParameter("newPassword");

            if (newPassword == null || newPassword.length() < 6) {
                response.sendRedirect("forget_password.jsp?error=short_password");
                return;
            }

            boolean success =
                    userPojo.forgetPassword(portId, newPassword);

            if (success) {
                response.sendRedirect("login.jsp?msg=password_updated");
            } else {
                response.sendRedirect("forget_password.jsp?error=invalid_port");
            }
        }

        else if ("delete".equals(action)) {

            String portId = request.getParameter("portId");
            System.out.println("[DEBUG] Deleting user: " + portId);

            UserPojo user = new UserPojo();
            user.deleteUser(portId);

            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }

            response.sendRedirect("login.jsp?msg=account_deleted");
        }
        

        else if ("dashboard".equals(action)) {

            HttpSession session = request.getSession(false);
            String portId = (String) session.getAttribute("port_id");

            if (portId != null) {
                UserPojo user =
                        userPojo.getUserByPortId(portId);
                session.setAttribute("userProfile", user);
                response.sendRedirect("dashboard.jsp");
            } else {
                response.sendRedirect("login.jsp");
            }
        }
    }
}
