package com.replp.booking_reservations_for_tourists.user.controller;

import com.replp.booking_reservations_for_tourists.util.DBconnect;
import com.replp.booking_reservations_for_tourists.util.PasswordHash;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Tourist login using email OR phone + password.
 * Verifies SHA-256 hash (with one-time plaintext fallback) and starts a session.
 */
@WebServlet("/TouristSignin")
public class TouristSigninServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Support either 'identifier' (email/phone) or legacy 'email' field names
        String identifier = trim(coalesce(
                req.getParameter("identifier"),
                req.getParameter("email")
        ));
        String password = trim(req.getParameter("password"));

        if (isBlank(identifier) || isBlank(password)) {
            resp.sendRedirect(req.getContextPath() + "/tourist-signin.jsp?error=required");
            return;
        }

        final String sql = """
                SELECT TouristID, FirstName, LastName, Email, PhoneNumber, PasswordHash
                FROM Tourist
                WHERE Email = ? OR PhoneNumber = ?
                """;

        try (Connection conn = DBconnect.get();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, identifier);
            ps.setString(2, identifier);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    resp.sendRedirect(req.getContextPath() + "/tourist-signin.jsp?error=invalid");
                    return;
                }

                long touristId     = rs.getLong("TouristID");
                String storedHash  = rs.getString("PasswordHash");

                String incomingHash = PasswordHash.hashPassword(password);
                boolean ok = storedHash != null && storedHash.equalsIgnoreCase(incomingHash);

                boolean needsUpgrade = false;
                if (!ok && storedHash != null && storedHash.equals(password)) {
                    ok = true;
                    needsUpgrade = true; // legacy plaintext
                }

                if (!ok) {
                    resp.sendRedirect(req.getContextPath() + "/tourist-signin.jsp?error=invalid");
                    return;
                }

                if (needsUpgrade) {
                    try (PreparedStatement up = conn.prepareStatement(
                            "UPDATE Tourist SET PasswordHash=? WHERE TouristID=?")) {
                        up.setString(1, incomingHash);
                        up.setLong(2, touristId);
                        up.executeUpdate();
                    } catch (Exception ignore) { /* best effort */ }
                }

                // Session: keep names parallel to your staff session keys
                HttpSession session = req.getSession(true);
                session.setAttribute("touristId",        touristId);
                session.setAttribute("touristFirstName", rs.getString("FirstName"));
                session.setAttribute("touristLastName",  rs.getString("LastName"));
                session.setAttribute("touristEmail",     rs.getString("Email"));
                session.setAttribute("touristPhone",     rs.getString("PhoneNumber"));

                // Redirect to tourist dashboard/home
                resp.sendRedirect(req.getContextPath() + "/tourist-profile.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/tourist-signin.jsp?error=server");
        }
    }

    // Optional: direct GET to the form
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/tourist-signin.jsp");
    }

    // helpers
    private static boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
    private static String trim(String s) { return s == null ? null : s.trim(); }
    private static String coalesce(String a, String b) { return a != null ? a : b; }
}
