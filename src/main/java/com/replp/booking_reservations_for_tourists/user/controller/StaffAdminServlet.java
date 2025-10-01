package com.replp.booking_reservations_for_tourists.user.controller;

import com.replp.booking_reservations_for_tourists.Dao.StaffAdminDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

/** ONE endpoint: /it/admin  */
@WebServlet("/it/admin")
public class StaffAdminServlet extends HttpServlet {
    private final StaffAdminDao dao = new StaffAdminDao();

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        String role = (s == null) ? null : (String) s.getAttribute("staffType");
        if (role == null) { resp.sendRedirect(req.getContextPath()+"/staff-signin.jsp"); return; }
        if (!"IT".equals(role)) { resp.sendRedirect(req.getContextPath()+"/staff-dashboard.jsp?error=forbidden"); return; }

        String q   = req.getParameter("q");
        String rf  = req.getParameter("role");
        String dep = req.getParameter("dept");

        try {
            req.setAttribute("staffList", dao.listStaff(q, rf, dep));
            req.setAttribute("touristList", dao.listTourists());
            req.getRequestDispatcher("/staff-admin.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Failed to load admin data", e);
        }
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        String role = (s == null) ? null : (String) s.getAttribute("staffType");
        if (role == null) { resp.sendRedirect(req.getContextPath()+"/staff-signin.jsp"); return; }
        if (!"IT".equals(role)) { resp.sendRedirect(req.getContextPath()+"/staff-dashboard.jsp?error=forbidden"); return; }

        String action = req.getParameter("action");
        if (action == null) { resp.sendRedirect(req.getContextPath()+"/it/admin?error=No%20action"); return; }

        try {
            switch (action) {
                case "staff.update" -> {
                    long staffId = Long.parseLong(req.getParameter("staffId"));
                    dao.updateStaffAndSubtype(
                            staffId,
                            req.getParameter("staffType"),
                            req.getParameter("department"),
                            req.getParameter("deskCode"),
                            req.getParameter("campaignsManaged"),
                            req.getParameter("managerRole"),
                            req.getParameter("specialization")
                    );
                    resp.sendRedirect(req.getContextPath()+"/it/admin?success=1");
                }
                case "staff.delete" -> {
                    long staffId = Long.parseLong(req.getParameter("staffId"));
                    dao.deleteStaff(staffId);
                    resp.sendRedirect(req.getContextPath()+"/it/admin?success=1");
                }
                case "tourist.delete" -> {
                    long touristId = Long.parseLong(req.getParameter("touristId"));
                    dao.deleteTourist(touristId);
                    resp.sendRedirect(req.getContextPath()+"/it/admin?success=1");
                }
                default -> resp.sendRedirect(req.getContextPath()+"/it/admin?error=Unknown%20action");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath()+"/it/admin?error=Invalid%20ID");
        } catch (SQLException e) {
            throw new ServletException("Operation failed", e);
        }
    }
}
