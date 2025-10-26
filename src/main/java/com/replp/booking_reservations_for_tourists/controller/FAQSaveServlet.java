package com.wbhrs.webbasedhotelreservationsystemfortourists.controller;

import com.wbhrs.webbasedhotelreservationsystemfortourists.dao.FAQDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "FAQSaveServlet", urlPatterns = "/faq/save")
public class FAQSaveServlet extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		Object staffType = (session == null) ? null : session.getAttribute("staffType");
		if (staffType == null || !"FRONT_DESK".equals(String.valueOf(staffType))) {
			resp.sendRedirect(req.getContextPath() + "/staff-signin.jsp");
			return;
		}

		String idStr = req.getParameter("faqId");
		String question = trim(req.getParameter("question"));
		String answer = trim(req.getParameter("answer"));
		if (question == null || question.isEmpty() || answer == null || answer.isEmpty()) {
			resp.sendRedirect(req.getContextPath() + "/faq?error=invalid");
			return;
		}

		try {
			FAQDAO dao = new FAQDAO();
			if (idStr == null || idStr.isBlank()) {
				dao.create(question, answer);
			} else {
				long id = Long.parseLong(idStr);
				dao.update(id, question, answer);
			}
			resp.sendRedirect(req.getContextPath() + "/faq?success=1");
		} catch (Exception e) {
			e.printStackTrace();
			resp.sendRedirect(req.getContextPath() + "/faq?error=server");
		}
	}

	private static String trim(String s) { return s == null ? null : s.trim(); }
}


