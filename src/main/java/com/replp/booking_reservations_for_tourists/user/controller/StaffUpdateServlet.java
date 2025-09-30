package com.replp.booking_reservations_for_tourists.user.controller;

import com.replp.booking_reservations_for_tourists.util.DBconnect;
import com.replp.booking_reservations_for_tourists.util.PasswordHash;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.sql.*;

/**
 * Handles staff profile edits and password changes.
 *
 * Expects these form fields for action=save:
 *   - firstname, lastname, phone, email
 *   - profilePic (file input; optional)
 *
 * For action=changePassword:
 *   - password, confirmPassword
 *
 * Session requirements (set at login):
 *   - staffId          (Long/long or String convertible to long)
 *   - staffType        (non-null; used only to ensure user is logged in)
 *   - staffFirstName, staffLastName, staffEmail, staffPhone (updated after save)
 *
 * DB tables/columns used (H2):
 *   - Staff(StaffID BIGINT PK, FirstName, LastName, PhoneNumber, Email, PasswordHash,
 *           ProfilePicBlob BLOB, ProfilePicMime VARCHAR(100), ProfilePicUpdated TIMESTAMP)
 */
@WebServlet(name = "StaffUpdateServlet", urlPatterns = {"/StaffUpdateServlet"})
@MultipartConfig(
        fileSizeThreshold = 512 * 1024,      // buffer to disk after 512KB
        maxFileSize = 5 * 1024 * 1024,       // 5 MB per file
        maxRequestSize = 10 * 1024 * 1024    // 10 MB per request
)
public class StaffUpdateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ---- 0) Basic session / auth checks ----
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("staffType") == null) {
            resp.sendRedirect(req.getContextPath() + "/staff-signin.jsp");
            return;
        }

        Object idObj = session.getAttribute("staffId");
        if (idObj == null) {
            // We can’t update if we don’t know who the staff member is
            req.setAttribute("message", "Missing session: staffId not found.");
            req.getRequestDispatcher("staff-profile-edit.jsp").forward(req, resp);
            return;
        }
        long staffId = Long.parseLong(String.valueOf(idObj));

        // What operation is requested?
        String action = req.getParameter("action");
        if ("changePassword".equalsIgnoreCase(action)) {
            handlePasswordChange(req, resp, staffId);
        } else {
            handleProfileSave(req, resp, staffId, session);
        }
    }

    /**
     * Save first/last name, phone, email and (optionally) profile picture BLOB.
     */
    private void handleProfileSave(HttpServletRequest req, HttpServletResponse resp,
                                   long staffId, HttpSession session)
            throws IOException, ServletException {

        // ---- 1) Read form fields ----
        String first = trim(req.getParameter("firstname"));
        String last  = trim(req.getParameter("lastname"));
        String phone = trim(req.getParameter("phone"));
        String email = trim(req.getParameter("email"));

        // ---- 2) Try to get uploaded file part (optional) ----
        Part picPart = null;
        try { picPart = req.getPart("profilePic"); } catch (Exception ignored) {}
        boolean hasNewPic = (picPart != null && picPart.getSize() > 0);

        // ---- 3) Build SQL (update with or without picture) ----
        final String SQL_UPDATE_WITH_BLOB =
                "UPDATE Staff " +
                        "SET FirstName=?, LastName=?, PhoneNumber=?, Email=?, " +
                        "    ProfilePicBlob=?, ProfilePicMime=?, ProfilePicUpdated=CURRENT_TIMESTAMP " +
                        "WHERE StaffID=?";
        final String SQL_UPDATE_NO_BLOB =
                "UPDATE Staff " +
                        "SET FirstName=?, LastName=?, PhoneNumber=?, Email=? " +
                        "WHERE StaffID=?";

        int rows;
        try (Connection con = DBconnect.get()) {
            if (hasNewPic) {
                // Update text columns + new BLOB
                try (PreparedStatement ps = con.prepareStatement(SQL_UPDATE_WITH_BLOB);
                     InputStream in = picPart.getInputStream()) {

                    ps.setString(1, first);
                    ps.setString(2, last);
                    ps.setString(3, phone);
                    ps.setString(4, email);
                    ps.setBinaryStream(5, in, (int) picPart.getSize());
                    String mime = picPart.getContentType();
                    ps.setString(6, (mime == null || mime.isBlank()) ? "image/jpeg" : mime);
                    ps.setLong(7, staffId);

                    rows = ps.executeUpdate();
                }
            } else {
                // Update only text columns (keep existing BLOB as-is)
                try (PreparedStatement ps = con.prepareStatement(SQL_UPDATE_NO_BLOB)) {
                    ps.setString(1, first);
                    ps.setString(2, last);
                    ps.setString(3, phone);
                    ps.setString(4, email);
                    ps.setLong(5, staffId);
                    rows = ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            // On DB error, show a friendly message
            e.printStackTrace();
            req.setAttribute("message", "Database error while saving profile: " + e.getMessage());
            req.getRequestDispatcher("staff-profile-edit.jsp").forward(req, resp);
            return;
        }

        if (rows == 0) {
            req.setAttribute("message", "No profile updated (invalid staff id?).");
            req.getRequestDispatcher("staff-profile-edit.jsp").forward(req, resp);
            return;
        }

        // ---- 4) Keep session display values in sync for the header/JSP ----
        if (first != null) session.setAttribute("staffFirstName", first);
        if (last  != null) session.setAttribute("staffLastName",  last);
        session.setAttribute("staffPhone", phone == null ? "" : phone);
        session.setAttribute("staffEmail", email == null ? "" : email);

        // ---- 5) stay in profile edit page with a success message ----
        req.setAttribute("message", "Profile updated successfully.");
        req.getRequestDispatcher("staff-profile-edit.jsp").forward(req, resp);
    }

    /**
     * Change password with basic validation, store as SHA-256 hash.
     */
    private void handlePasswordChange(HttpServletRequest req, HttpServletResponse resp, long staffId)
            throws IOException, ServletException {

        String pwd = req.getParameter("password");
        String cfm = req.getParameter("confirmPassword");

        if (pwd == null || pwd.length() < 6) {
            req.setAttribute("message", "Password must be at least 6 characters.");
            req.getRequestDispatcher("staff-profile-edit.jsp").forward(req, resp);
            return;
        }
        if (!pwd.equals(cfm)) {
            req.setAttribute("message", "Passwords do not match.");
            req.getRequestDispatcher("staff-profile-edit.jsp").forward(req, resp);
            return;
        }

        String hashed = PasswordHash.hashPassword(pwd); // UPPERCASE HEX

        try (Connection con = DBconnect.get();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE Staff SET PasswordHash=? WHERE StaffID=?")) {
            ps.setString(1, hashed);
            ps.setLong(2, staffId);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                req.setAttribute("message", "Password not updated (invalid staff id?).");
                req.getRequestDispatcher("staff-profile-edit.jsp").forward(req, resp);
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("message", "Database error while updating password: " + e.getMessage());
            req.getRequestDispatcher("staff-profile-edit.jsp").forward(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/staff-profile.jsp?m=Password+updated");
    }


    // -------- small helpers --------

    private static String trim(String s) { return s == null ? null : s.trim(); }

    /** Simple SHA-256 for demo purposes. (For production, use bcrypt/argon2.) */
    private static String sha256(String s) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] out = md.digest(s.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder(out.length * 2);
            for (byte b : out) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Could not hash password", e);
        }
    }
}

