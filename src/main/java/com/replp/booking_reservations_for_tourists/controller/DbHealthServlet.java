package com.replp.booking_reservations_for_tourists.controller;

import com.replp.booking_reservations_for_tourists.util.DBconnect;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

@WebServlet(name = "DbHealthServlet",
        urlPatterns = {"/health/db"},
        loadOnStartup = 1            // <— this forces init() to run at app boot
)
public class DbHealthServlet extends HttpServlet {

    @Override
    public void init() {
        // create Tourist, Staff, FrontDesk, MarketingTeam, Manager, ITStaff
        com.replp.booking_reservations_for_tourists.util.DBInit.init();
        // This will print in Tomcat logs when servlet is created
        System.out.println("DbHealthServlet loaded!");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try (Connection c = DBconnect.get();
             Statement s = c.createStatement();
             ResultSet rs = s.executeQuery("SELECT COUNT(*) n FROM Staff")) {

            rs.next();
            int count = rs.getInt("n");
            resp.setContentType("text/plain");
            resp.getWriter().println("DB OK: Staff rows = " + count);

        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().println("DB ERROR  " + e.getMessage());
        }
    }
}
