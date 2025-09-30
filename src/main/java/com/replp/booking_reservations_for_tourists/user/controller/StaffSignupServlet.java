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

@WebServlet("/StaffSignup")
public class StaffSignupServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Common fields
        String firstname  = request.getParameter("firstname");
        String lastname   = request.getParameter("lastname");
        String email      = request.getParameter("email");
        String phone      = request.getParameter("phone");
        String password   = request.getParameter("password");
        String type       = request.getParameter("type");        // FRONT_DESK | MARKETING | MANAGER | IT
        String department = request.getParameter("department");  // required

        // Subtype fields
        String deskCode       = request.getParameter("deskCode");        // FRONT_DESK
        String campaignsManaged = request.getParameter("campaignsManaged");    // MARKETING (string)
        String role           = request.getParameter("role");            // MANAGER
        String specialization = request.getParameter("specialization");  // IT

        // Basic guard (now includes department)
        if (isBlank(firstname) || isBlank(lastname) || isBlank(email) ||
                isBlank(password)  || isBlank(type)     || isBlank(department)) {
            response.sendRedirect(request.getContextPath() + "/staff-signup.jsp?error=missing");
            return;
        }

        String passwordHash = PasswordHash.hashPassword(password);

        try (Connection conn = DBconnect.get()) {
            conn.setAutoCommit(false);

            // 1) Duplicate email check
            try (PreparedStatement check = conn.prepareStatement(
                    "SELECT 1 FROM Staff WHERE Email=?")) {
                check.setString(1, email);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        response.sendRedirect(request.getContextPath() + "/staff-signup.jsp?error=email_exists");
                        return;
                    }
                }
            }

            // 2) Insert into Staff (includes Department)
            long staffId;
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO Staff (FirstName, LastName, Email, PhoneNumber, PasswordHash, Department, StaffType) " +
                            "VALUES (?,?,?,?,?,?,?)",
                    Statement.RETURN_GENERATED_KEYS)) {

                ps.setString(1, firstname);
                ps.setString(2, lastname);
                ps.setString(3, email);
                ps.setString(4, phone);
                ps.setString(5, passwordHash);
                ps.setString(6, department);
                ps.setString(7, type);
                ps.executeUpdate();

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) {
                        conn.rollback();
                        response.sendRedirect(request.getContextPath() + "/staff-signup.jsp?error=server");
                        return;
                    }
                    staffId = keys.getLong(1);
                }
            }

            // 3) Insert into the subtype table
            switch (type) {
                case "FRONT_DESK" -> {
                    if (isBlank(deskCode)) {
                        conn.rollback();
                        response.sendRedirect(request.getContextPath() + "/staff-signup.jsp?error=desk_required");
                        return;
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO FrontDesk (StaffID, DeskCode) VALUES (?,?)")) {
                        ps.setLong(1, staffId);
                        ps.setString(2, deskCode);
                        ps.executeUpdate();
                    }
                }
                case "MARKETING" -> {
                    if (isBlank(campaignsManaged)) {
                        conn.rollback();
                        response.sendRedirect(request.getContextPath() + "/staff-signup.jsp?error=campaign_required");
                        return;
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO MarketingTeam (StaffID, CampaignsManaged) VALUES (?,?)")) {
                        ps.setLong(1, staffId);
                        ps.setString(2, campaignsManaged);
                        ps.executeUpdate();
                    }
                }
                case "MANAGER" -> {
                    if (isBlank(role)) {
                        conn.rollback();
                        response.sendRedirect(request.getContextPath() + "/staff-signup.jsp?error=role_required");
                        return;
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO Manager (StaffID, Role) VALUES (?,?)")) {
                        ps.setLong(1, staffId);
                        ps.setString(2, role);
                        ps.executeUpdate();
                    }
                }
                case "IT" -> {
                    if (isBlank(specialization)) {
                        conn.rollback();
                        response.sendRedirect(request.getContextPath() + "/staff-signup.jsp?error=spec_required");
                        return;
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO ITStaff (StaffID, Specialization) VALUES (?,?)")) {
                        ps.setLong(1, staffId);
                        ps.setString(2, specialization);
                        ps.executeUpdate();
                    }
                }
                default -> {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/staff-signup.jsp?error=type_invalid");
                    return;
                }
            }

            conn.commit();
            response.sendRedirect(request.getContextPath() + "/staff-signin.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/staff-signup.jsp?error=server");
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}

