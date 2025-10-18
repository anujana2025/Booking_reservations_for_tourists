package com.replp.booking_reservations_for_tourists.user.controller;

import com.replp.booking_reservations_for_tourists.util.EmailSender;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.Duration;
import java.time.Instant;
import java.util.Random;

@WebServlet("/ResendOtpServlet")
public class ResendOtpServlet extends HttpServlet {

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
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        final String actor = actorOf(request);
        final HttpSession ses = request.getSession(false);

        // If no session or no email, go back to the proper forgot page
        if (ses == null) {
            response.sendRedirect(request.getContextPath() + "/forgot-password.jsp?actor=" + actor);
            return;
        }
        final String email = (String) ses.getAttribute("reset_email");
        if (email == null || email.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/forgot-password.jsp?actor=" + actor);
            return;
        }

        // Generate new OTP and reset attempts/expiry (session-only)
        final String otp = String.format("%06d", new Random().nextInt(1_000_000));
        final Instant exp = Instant.now().plus(Duration.ofMinutes(OTP_TTL_MIN));
        ses.setAttribute("otp_code", otp);
        ses.setAttribute("otp_expires", exp);
        ses.setAttribute("otp_attempts", 0);

        // Send email (or log if SMTP blocked)
        boolean sent;
        try {
            sent = EmailSender.sendEmail(
                    email,
                    "Your new verification code (" + OTP_TTL_MIN + " min)",
                    "Hi,\n\nYour new OTP is: " + otp +
                            "\nIt expires in " + OTP_TTL_MIN + " minutes.\n\nIf you didn’t request this, please ignore."
            );
        } catch (Exception e) {
            sent = false;
        }
        if (!sent) {
            System.out.println("[DEBUG] RESEND OTP for " + email + " = " + otp + " (valid " + OTP_TTL_MIN + "m)");
        }

        // Back to verify page (carry actor and show a small success hint)
        response.sendRedirect(request.getContextPath() + "/verify-otp.jsp?actor=" + actor + "&success=resend");
    }
}
