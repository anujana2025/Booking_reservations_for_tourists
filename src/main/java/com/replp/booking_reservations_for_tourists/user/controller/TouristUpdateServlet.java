package com.replp.booking_reservations_for_tourists.user.controller;

import com.replp.booking_reservations_for_tourists.util.DBconnect;
import com.replp.booking_reservations_for_tourists.util.PasswordHash;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet(name = "TouristUpdateServlet", urlPatterns = {"/TouristUpdateServlet"})
public class TouristUpdateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("touristEmail") == null) {
            resp.sendRedirect(req.getContextPath() + "/tourist-signin.jsp");
            return;
        }

        Object idObj = session.getAttribute("touristId");
        if (idObj == null) {
            req.setAttribute("message", "Missing session: touristId not found.");
            req.getRequestDispatcher("tourist-profile-edit.jsp").forward(req, resp);
            return;
        }
        long touristId = Long.parseLong(String.valueOf(idObj));

        String action = req.getParameter("action");
        if ("changePassword".equalsIgnoreCase(action)) {
            changePassword(req, resp, touristId);
        } else if ("delete".equalsIgnoreCase(action)) {
            deleteAccount(req, resp, touristId, session);
        } else { // default -> save
            saveProfile(req, resp, touristId, session);
        }
    }

    // -------- action=save --------
    private void saveProfile(HttpServletRequest req, HttpServletResponse resp,
                             long touristId, HttpSession session)
            throws IOException, ServletException {

        String first = trim(req.getParameter("firstname"));
        String last  = trim(req.getParameter("lastname"));
        String phone = trim(req.getParameter("phone"));
        String email = trim(req.getParameter("email"));

        final String SQL =
                "UPDATE Tourist SET FirstName=?, LastName=?, PhoneNumber=?, Email=? WHERE TouristID=?";

        int rows;
        try (Connection con = DBconnect.get();
             PreparedStatement ps = con.prepareStatement(SQL)) {

            ps.setString(1, first);
            ps.setString(2, last);
            ps.setString(3, phone);
            ps.setString(4, email);
            ps.setLong(5, touristId);

            rows = ps.executeUpdate();
        } catch (SQLException e) {
            if (e.getSQLState() != null && e.getSQLState().startsWith("23")) {
                req.setAttribute("message", "Email already in use.");
            } else {
                req.setAttribute("message", "Database error while saving profile: " + e.getMessage());
            }
            req.getRequestDispatcher("tourist-profile-edit.jsp").forward(req, resp);
            return;
        }

        if (rows == 0) {
            req.setAttribute("message", "No profile updated (invalid tourist id?).");
            req.getRequestDispatcher("tourist-profile-edit.jsp").forward(req, resp);
            return;
        }

        // keep session in sync
        if (first != null) session.setAttribute("touristFirstName", first);
        if (last  != null) session.setAttribute("touristLastName",  last);
        session.setAttribute("touristPhone", phone == null ? "" : phone);
        session.setAttribute("touristEmail", email == null ? "" : email);

        req.setAttribute("message", "Profile updated successfully.");
        req.getRequestDispatcher("tourist-profile-edit.jsp").forward(req, resp);
    }

    // -------- action=changePassword --------
    private void changePassword(HttpServletRequest req, HttpServletResponse resp, long touristId)
            throws IOException, ServletException {

        String pwd = req.getParameter("password");
        String cfm = req.getParameter("confirmPassword");

        if (pwd == null || pwd.length() < 6) {
            req.setAttribute("message", "Password must be at least 6 characters.");
            req.getRequestDispatcher("tourist-profile-edit.jsp").forward(req, resp);
            return;
        }
        if (!pwd.equals(cfm)) {
            req.setAttribute("message", "Passwords do not match.");
            req.getRequestDispatcher("tourist-profile-edit.jsp").forward(req, resp);
            return;
        }

        String hashed = PasswordHash.hashPassword(pwd);

        try (Connection con = DBconnect.get();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE Tourist SET PasswordHash=? WHERE TouristID=?")) {
            ps.setString(1, hashed);
            ps.setLong(2, touristId);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                req.setAttribute("message", "Password not updated (invalid tourist id?).");
                req.getRequestDispatcher("tourist-profile-edit.jsp").forward(req, resp);
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("message", "Database error while updating password: " + e.getMessage());
            req.getRequestDispatcher("tourist-profile-edit.jsp").forward(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/tourist-profile.jsp?m=Password+updated");
    }

    // -------- action=delete --------
    private void deleteAccount(HttpServletRequest req, HttpServletResponse resp,
                               long touristId, HttpSession session)
            throws IOException {

        String ctx = req.getContextPath();
        try (Connection con = DBconnect.get();
             PreparedStatement ps = con.prepareStatement(
                     "DELETE FROM Tourist WHERE TouristID=?")) {
            ps.setLong(1, touristId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(ctx + "/tourist-profile-edit.jsp?error=server");
            return;
        }

        session.invalidate();
        resp.sendRedirect(ctx + "/tourist-signin.jsp?deleted=1");
    }

    // -------- helpers --------
    private static String trim(String s) { return s == null ? null : s.trim(); }
}
