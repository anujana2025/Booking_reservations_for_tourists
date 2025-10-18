package com.replp.booking_reservations_for_tourists.user.controller;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.Instant;

@WebServlet("/OtpServlet")
public class OtpServlet extends HttpServlet {

    private static String actorOf(HttpServletRequest req) {
        String a = req.getParameter("actor");
        if (a == null || a.isBlank()) {
            Object s = req.getSession(true).getAttribute("actor");
            a = (s != null) ? s.toString() : "staff";
        }
        return "tourist".equalsIgnoreCase(a) ? "tourist" : "staff";
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        final String actor = actorOf(request);
        final HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/forgot-password.jsp?actor=" + actor);
            return;
        }

        // Accept either a single hidden "otp" or six inputs "otp0".."otp5"
        String otp = request.getParameter("otp");
        if (otp == null || otp.length() != 6) {
            StringBuilder sb = new StringBuilder(6);
            for (int i = 0; i < 6; i++) {
                String part = request.getParameter("otp" + i);
                sb.append(part == null ? "" : part);
            }
            otp = sb.toString();
        }

        // Read OTP info from session (set by ForgotPasswordServlet)
        String expected = (String) session.getAttribute("otp_code");
        Instant expires = (Instant) session.getAttribute("otp_expires");
        Integer attempts = (Integer) session.getAttribute("otp_attempts");
        if (attempts == null) attempts = 0;

        // Validate
        if (expected == null || expires == null || Instant.now().isAfter(expires)) {
            request.setAttribute("error", "The code has expired. Please request a new one.");
            request.getRequestDispatcher("verify-otp.jsp").forward(request, response);
            return;
        }
        if (attempts >= 5) {
            request.setAttribute("error", "Too many attempts. Please request a new code.");
            request.getRequestDispatcher("verify-otp.jsp").forward(request, response);
            return;
        }
        if (otp == null || !otp.matches("\\d{6}") || !otp.equals(expected)) {
            session.setAttribute("otp_attempts", attempts + 1);
            request.setAttribute("error", "Invalid OTP. Please try again.");
            request.getRequestDispatcher("verify-otp.jsp").forward(request, response);
            return;
        }

        // Success → clear code, mark verified, continue to reset
        session.removeAttribute("otp_code");
        session.removeAttribute("otp_expires");
        session.setAttribute("otp_verified", Boolean.TRUE);

        response.sendRedirect(request.getContextPath() + "/reset-password.jsp?actor=" + actor);
    }
}
