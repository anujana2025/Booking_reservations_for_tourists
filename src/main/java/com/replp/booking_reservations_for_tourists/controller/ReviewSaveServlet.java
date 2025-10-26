package com.wbhrs.webbasedhotelreservationsystemfortourists.controller;

import com.wbhrs.webbasedhotelreservationsystemfortourists.dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "ReviewSaveServlet", urlPatterns = "/reviews/save")
public class ReviewSaveServlet extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		if (session == null || session.getAttribute("touristId") == null) {
			resp.sendRedirect(req.getContextPath() + "/tourist-signin.jsp");
			return;
		}
		long touristId = Long.parseLong(String.valueOf(session.getAttribute("touristId")));

		String reviewIdStr = req.getParameter("reviewId");
		String title = trim(req.getParameter("title"));
		String content = trim(req.getParameter("content"));
		String ratingStr = req.getParameter("rating");

		int rating = 0;
		try { rating = Integer.parseInt(ratingStr); } catch (Exception ignored) {}
		if (rating < 1 || rating > 5 || content == null || content.isEmpty()) {
			resp.sendRedirect(req.getContextPath() + "/reviews?error=invalid");
			return;
		}

		try {
			ReviewDAO dao = new ReviewDAO();
			if (reviewIdStr == null || reviewIdStr.isBlank()) {
				dao.create(touristId, title, content, rating);
			} else {
				long reviewId = Long.parseLong(reviewIdStr);
				dao.update(reviewId, touristId, title, content, rating);
			}
			resp.sendRedirect(req.getContextPath() + "/reviews?success=1");
		} catch (Exception e) {
			e.printStackTrace();
			resp.sendRedirect(req.getContextPath() + "/reviews?error=server");
		}
	}

	private static String trim(String s) { return s == null ? null : s.trim(); }
}


