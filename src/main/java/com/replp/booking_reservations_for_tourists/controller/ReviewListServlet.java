package com.wbhrs.webbasedhotelreservationsystemfortourists.controller;

import com.wbhrs.webbasedhotelreservationsystemfortourists.dao.ReviewDAO;
import com.wbhrs.webbasedhotelreservationsystemfortourists.model.Review;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ReviewListServlet", urlPatterns = "/reviews")
public class ReviewListServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		try {
			List<Review> reviews = new ReviewDAO().findAll();
			req.setAttribute("reviews", reviews);
			req.getRequestDispatcher("/reviews.jsp").forward(req, resp);
		} catch (Exception e) {
			e.printStackTrace();
			req.setAttribute("message", "Failed to load reviews: " + e.getMessage());
			req.getRequestDispatcher("/index.jsp").forward(req, resp);
		}
	}
}


