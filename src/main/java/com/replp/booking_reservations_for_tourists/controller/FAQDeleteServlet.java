package com.wbhrs.webbasedhotelreservationsystemfortourists.controller;

import com.wbhrs.webbasedhotelreservationsystemfortourists.dao.FAQDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "FAQDeleteServlet", urlPatterns = "/faq/delete")
public class FAQDeleteServlet extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		Object staffType = (session == null) ? null : session.getAttribute("staffType");
		if (staffType == null || !"FRONT_DESK".equals(String.valueOf(staffType))) {
			resp.sendRedirect(req.getContextPath() + "/staff-signin.jsp");
			return;
		}

		String idStr = req.getParameter("id");
		try {
			long id = Long.parseLong(idStr);
			new FAQDAO().delete(id);
			resp.sendRedirect(req.getContextPath() + "/faq?deleted=1");
		} catch (Exception e) {
			e.printStackTrace();
			resp.sendRedirect(req.getContextPath() + "/faq?error=server");
		}
	}
}


