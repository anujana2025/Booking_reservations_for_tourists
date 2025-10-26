package com.wbhrs.webbasedhotelreservationsystemfortourists.controller;

import com.wbhrs.webbasedhotelreservationsystemfortourists.dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "ReviewDeleteServlet", urlPatterns = "/reviews/delete")
public class ReviewDeleteServlet extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("touristId") == null) {
			resp.sendRedirect(req.getContextPath() + "/tourist-signin.jsp");
			return;
		}
		long touristId = Long.parseLong(String.valueOf(session.getAttribute("touristId")));
		String idStr = req.getParameter("id");
		try {
			long reviewId = Long.parseLong(idStr);
			new ReviewDAO().delete(reviewId, touristId);
			resp.sendRedirect(req.getContextPath() + "/reviews?deleted=1");
		} catch (Exception e) {
			e.printStackTrace();
			resp.sendRedirect(req.getContextPath() + "/reviews?error=server");
		}
	}
}


