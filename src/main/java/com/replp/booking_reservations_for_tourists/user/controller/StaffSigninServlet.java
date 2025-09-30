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
 * Staff login using email OR phone + password.
 * Checks DB, verifies password (hash first, legacy plaintext fallback), then starts a session.
 */
@WebServlet("/StaffSignin")
public class StaffSigninServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Read inputs
        String identifier = trim(req.getParameter("identifier")); // can be email or phone
        String password   = trim(req.getParameter("password"));

        // Basic validation
        if (isBlank(identifier) || isBlank(password)) {
            resp.sendRedirect(req.getContextPath() + "/staff-signin.jsp?error=required");
            return;
        }

        // Query to fetch staff by email or phone
        final String sql = """
                SELECT StaffID, FirstName, LastName, Email, PhoneNumber, PasswordHash, StaffType, Department
                FROM Staff
                WHERE Email = ? OR PhoneNumber = ?
                """;

        try (Connection conn = DBconnect.get();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            // Bind both params to the same identifier
            ps.setString(1, identifier);
            ps.setString(2, identifier);

            try (ResultSet rs = ps.executeQuery()) {
                // If no record found → invalid login
                if (!rs.next()) {
                    resp.sendRedirect(req.getContextPath() + "/staff-signin.jsp?error=invalid");
                    return;
                }

                long   staffId     = rs.getLong("StaffID");
                String storedHash  = rs.getString("PasswordHash"); // may be hash or legacy plaintext

                // Preferred: compare hashes (our app stores SHA-256 hex)
                String incomingHash = PasswordHash.hashPassword(password);
                boolean ok = storedHash != null && storedHash.equalsIgnoreCase(incomingHash);

                // Fallback: if old DB kept plaintext, accept once and upgrade
                boolean needsUpgrade = false;
                if (!ok && storedHash != null && storedHash.equals(password)) {
                    ok = true;
                    needsUpgrade = true;
                }

                if (!ok) {
                    // Password mismatch
                    resp.sendRedirect(req.getContextPath() + "/staff-signin.jsp?error=invalid");
                    return;
                }

                // If we authenticated via plaintext, immediately upgrade to hash
                if (needsUpgrade) {
                    try (PreparedStatement up = conn.prepareStatement(
                            "UPDATE Staff SET PasswordHash=? WHERE StaffID=?")) {
                        up.setString(1, incomingHash);
                        up.setLong(2, staffId);
                        up.executeUpdate();
                    } catch (Exception ignore) { /* best effort only */ }
                }

                // Create session on success (store basic profile info)
                HttpSession session = req.getSession(true);
                session.setAttribute("staffId",        staffId);
                session.setAttribute("staffFirstName", rs.getString("FirstName"));
                session.setAttribute("staffLastName",  rs.getString("LastName"));
                session.setAttribute("staffEmail",     rs.getString("Email"));
                session.setAttribute("staffPhone",     rs.getString("PhoneNumber"));
                session.setAttribute("staffType",      rs.getString("StaffType"));
                session.setAttribute("department",     rs.getString("Department"));

                // Go to staff dashboard
                resp.sendRedirect(req.getContextPath() + "/staff-dashboard.jsp");
            }
        } catch (Exception e) {
            // Any unexpected error → back to sign-in with error flag
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/staff-signin.jsp?error=server");
        }
    }

    // Helper: true if null or only spaces
    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    // Helper: safe trim (keeps null as null)
    private static String trim(String s) {
        return s == null ? null : s.trim();
    }
}
