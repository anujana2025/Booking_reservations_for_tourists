package com.replp.booking_reservations_for_tourists.user.controller;

import com.replp.booking_reservations_for_tourists.util.DBconnect;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {

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
            throws IOException {
        final String actor = actorOf(request);
        final HttpSession ses = request.getSession(false);

        if (ses == null || !Boolean.TRUE.equals(ses.getAttribute("otp_verified"))) {
            response.sendRedirect(request.getContextPath() + "/forgot-password.jsp?actor=" + actor + "&error=invalid");
            return;
        }

        final String email = (String) ses.getAttribute("reset_email");
        final String p1 = request.getParameter("newPassword");
        final String p2 = request.getParameter("confirmPassword");

        // ---- Validation (min 6 + must match). On error -> forward with messages (no refresh blank). ----
        boolean hasError = false;
        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/forgot-password.jsp?actor=" + actor + "&error=invalid");
            return;
        }
        if (p1 == null || p1.length() < 6) {
            request.setAttribute("passwordError", "Password must be at least 6 characters.");
            hasError = true;
        }
        if (p2 == null || !String.valueOf(p1).equals(p2)) {
            request.setAttribute("confirmPasswordError", "Passwords do not match.");
            hasError = true;
        }
        if (hasError) {
            request.setAttribute("type", "warning");
            request.setAttribute("message", "Please fix the errors below and try again.");
            try {
                request.getRequestDispatcher("/reset-password.jsp?actor=" + actor).forward(request, response);
            } catch (ServletException e) {
                throw new IOException(e);
            }
            return;
        }

        // ---- Update DB (hash with SHA-256) ----
        final String sql = "staff".equals(actor)
                ? "UPDATE Staff   SET PasswordHash=? WHERE Email=?"
                : "UPDATE Tourist SET PasswordHash=? WHERE Email=?";
        try (Connection c = DBconnect.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, sha256(p1));
            ps.setString(2, email);
            int changed = ps.executeUpdate();
            if (changed == 0) {
                response.sendRedirect(request.getContextPath() + "/forgot-password.jsp?actor=" + actor + "&error=invalid");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
            return;
        }

        // ---- Cleanup + success redirect ----
        ses.removeAttribute("otp_verified");
        ses.removeAttribute("reset_email");

        final String signin = "staff".equals(actor) ? "staff-signin.jsp" : "tourist-signin.jsp";
        final String url = request.getContextPath() + "/" + signin
                + "?reset=ok&email=" + URLEncoder.encode(email, StandardCharsets.UTF_8)
                + "&actor=" + actor;
        response.sendRedirect(url);
    }

    private static String sha256(String s) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] dig = md.digest(s.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(dig.length * 2);
            for (byte b : dig) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Hashing failed", e);
        }
    }
}
