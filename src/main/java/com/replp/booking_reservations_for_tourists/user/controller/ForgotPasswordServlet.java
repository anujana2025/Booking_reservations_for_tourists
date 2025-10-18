package com.replp.booking_reservations_for_tourists.user.controller;

import com.replp.booking_reservations_for_tourists.util.DBconnect;
import com.replp.booking_reservations_for_tourists.util.EmailSender;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.Duration;
import java.time.Instant;
import java.util.Random;

@WebServlet("/forgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    private static final int OTP_TTL_MIN = 5;

    private static String actorOf(HttpServletRequest req) {
        String a = req.getParameter("actor");
        if (a == null || a.isBlank()) {
            Object s = req.getSession(true).getAttribute("actor");
            a = (s != null) ? s.toString() : "staff";
        }
        return "tourist".equalsIgnoreCase(a) ? "tourist" : "staff";
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        final String actor = actorOf(request);
        final String email = trimOrNull(request.getParameter("email"));
        if (email == null) {
            redirect(request, response, "/forgot-password.jsp?actor=" + actor + "&error=required");
            return;
        }

        // 1) Check existence in Staff/Tourist
        final String existsSql = "staff".equals(actor)
                ? "SELECT 1 FROM Staff   WHERE Email=?"
                : "SELECT 1 FROM Tourist WHERE Email=?";
        try (Connection c = DBconnect.get(); PreparedStatement ps = c.prepareStatement(existsSql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    redirect(request, response, "/forgot-password.jsp?actor=" + actor + "&error=invalid");
                    return;
                }
            }
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
            return;
        }

        // 2) Generate OTP and store in session (not DB)
        String otp = String.format("%06d", new Random().nextInt(1_000_000));
        Instant exp = Instant.now().plus(Duration.ofMinutes(OTP_TTL_MIN));

        HttpSession ses = request.getSession(true);
        ses.setAttribute("actor", actor);
        ses.setAttribute("reset_email", email);
        ses.setAttribute("otp_code", otp);
        ses.setAttribute("otp_expires", exp);
        ses.setAttribute("otp_attempts", 0);

        // 3) Send email (or log if SMTP blocked)
        boolean sent;
        try {
            sent = EmailSender.sendEmail(
                    email,
                    "Your verification code (" + OTP_TTL_MIN + " min)",
                    "Hi,\n\nYour OTP is: " + otp + "\nIt expires in " + OTP_TTL_MIN +
                            " minutes.\n\nIf you did not request this, ignore this email."
            );
        } catch (Exception ex) {
            sent = false;
        }
        if (!sent) {
            System.out.println("[DEBUG] OTP for " + email + " = " + otp + " (valid " + OTP_TTL_MIN + "m)");
        }

        // 4) Go to verify page
        redirect(request, response, "/verify-otp.jsp?actor=" + actor);
    }

    private static String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private static void redirect(HttpServletRequest req, HttpServletResponse resp, String path) throws IOException {
        resp.sendRedirect(req.getContextPath() + path);
    }
}
