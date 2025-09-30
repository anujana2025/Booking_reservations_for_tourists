package com.replp.booking_reservations_for_tourists.user.controller;

import com.replp.booking_reservations_for_tourists.util.DBconnect;
import com.replp.booking_reservations_for_tourists.util.PasswordHash;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;

@WebServlet("/TouristSignup")
public class TouristSignupServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();

        // Form fields
        String firstname = trim(request.getParameter("firstname"));
        String lastname  = trim(request.getParameter("lastname"));
        String email     = trim(request.getParameter("email"));
        String phone     = trim(request.getParameter("phone"));     // optional in schema
        String password  = trim(request.getParameter("password"));

        // Basic validation
        if (isBlank(firstname) || isBlank(lastname) || isBlank(email) || isBlank(password)) {
            response.sendRedirect(ctx + "/tourist-signup.jsp?error=missing");
            return;
        }

        String passwordHash = PasswordHash.hashPassword(password);

        try (Connection conn = DBconnect.get()) {
            conn.setAutoCommit(false);

            // 1) Duplicate email check (Email is UNIQUE in Tourist table)
            try (PreparedStatement chk = conn.prepareStatement(
                    "SELECT 1 FROM Tourist WHERE Email = ?")) {
                chk.setString(1, email);
                try (ResultSet rs = chk.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        response.sendRedirect(ctx + "/tourist-signup.jsp?error=email_exists");
                        return;
                    }
                }
            }

            // 2) Insert Tourist
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO Tourist (FirstName, LastName, Email, PhoneNumber, PasswordHash) " +
                            "VALUES (?,?,?,?,?)")) {
                ps.setString(1, firstname);
                ps.setString(2, lastname);
                ps.setString(3, email);
                ps.setString(4, phone);        // nullable
                ps.setString(5, passwordHash);
                ps.executeUpdate();
            }

            conn.commit();
            response.sendRedirect(ctx + "/tourist-signin.jsp?success=1");
        } catch (SQLException e) {
            // SQLState starting with "23" => constraint violation (e.g., duplicate)
            if (e.getSQLState() != null && e.getSQLState().startsWith("23")) {
                response.sendRedirect(ctx + "/tourist-signup.jsp?error=email_exists");
            } else {
                e.printStackTrace();
                response.sendRedirect(ctx + "/tourist-signup.jsp?error=server");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(ctx + "/tourist-signup.jsp?error=server");
        }
    }

    // Optional: handle GET by redirecting to the signup page
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/tourist-signup.jsp");
    }

    private static String trim(String s) { return s == null ? null : s.trim(); }
    private static boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
}
