package com.wbhrs.webbasedhotelreservationsystemfortourists.controller;

import com.wbhrs.webbasedhotelreservationsystemfortourists.dao.FAQDAO;
import com.wbhrs.webbasedhotelreservationsystemfortourists.model.FAQ;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "FAQListServlet", urlPatterns = "/faq")
public class FAQListServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		try {
			List<FAQ> faqs = new FAQDAO().findAll();
			req.setAttribute("faqs", faqs);
			req.getRequestDispatcher("/faq.jsp").forward(req, resp);
		} catch (Exception e) {
			e.printStackTrace();
			req.setAttribute("message", "Failed to load FAQs: " + e.getMessage());
			req.getRequestDispatcher("/index.jsp").forward(req, resp);
		}
	}
}


