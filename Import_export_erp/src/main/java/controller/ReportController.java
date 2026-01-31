package controller;

import model.ReportPojo;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/ReportController")
public class ReportController extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String action = request.getParameter("action");
		ReportPojo reportPojo = new ReportPojo();

		if ("resolve".equals(action)) {

			int reportId = Integer.parseInt(request.getParameter("reportId"));
			reportPojo.updateReportStatus(reportId);

			response.sendRedirect("ReportController");
		}
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		if (session == null || session.getAttribute("port_id") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String portId = session.getAttribute("port_id").toString();
		ReportPojo reportPojo = new ReportPojo();

		List<ReportPojo> reports = reportPojo.viewReportsByUser(portId);

		request.setAttribute("reports", reports);
		request.getRequestDispatcher("reported_products.jsp").forward(request, response);
	}
}
