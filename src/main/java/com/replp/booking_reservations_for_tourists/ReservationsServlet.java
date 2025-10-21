package com.serenityhaven.web;

import com.serenityhaven.dao.ReservationDao;
import com.serenityhaven.model.Reservation;
import com.serenityhaven.util.Pricing;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.regex.Pattern;

@WebServlet(name = "ReservationsServlet", urlPatterns = {"/api/reservations"})
public class ReservationsServlet extends HttpServlet {

    private final ReservationDao dao = new ReservationDao();

    // simple validators
    private static final Pattern EMAIL_RE =
            Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    private static final Pattern PHONE_RE =
            Pattern.compile("^[+()0-9\\s-]{7,20}$");

    private static int capacityFor(String roomType) {
        if (roomType == null) return 1;
        switch (roomType.toLowerCase()) {
            case "double": return 2;
            case "triple": return 3;
            default: return 1;
        }
    }

    private static void require(boolean cond, String message) throws ServletException {
        if (!cond) throw new ServletException(message);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer userId = (Integer) req.getSession().getAttribute("userId");
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/user-login.jsp");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String action = nvl(req.getParameter("action"), "create").trim().toLowerCase();

        try {
            switch (action) {
                case "create": {
                    String fullName      = trim(req.getParameter("fullName"));
                    String contactNumber = trim(req.getParameter("contactNumber"));
                    String email         = trim(req.getParameter("email"));
                    String roomType      = trim(req.getParameter("roomType"));

                    LocalDate checkIn    = LocalDate.parse(req.getParameter("checkIn"));
                    LocalDate checkOut   = LocalDate.parse(req.getParameter("checkOut"));
                    int guests           = Integer.parseInt(req.getParameter("guests"));

                    // validations
                    LocalDate minIn = LocalDate.now().plusDays(2);
                    require(fullName != null && fullName.length() >= 2, "Name is required");
                    require(contactNumber != null && PHONE_RE.matcher(contactNumber).matches(), "Invalid phone number");
                    require(email != null && EMAIL_RE.matcher(email).matches(), "Invalid email");
                    require(roomType != null && !roomType.isBlank(), "Room type is required");
                    require(!checkIn.isBefore(minIn), "Check-in must be at least 2 days from today");
                    require(checkOut.isAfter(checkIn), "Check-out must be after check-in");

                    int cap = capacityFor(roomType);
                    require(guests >= 1 && guests <= cap, "Guests must be within capacity for room");

                    // server-side price (authoritative)
                    BigDecimal total = Pricing.estimateTotal(roomType, checkIn, checkOut);

                    Reservation r = new Reservation();
                    r.setUserId(userId);
                    r.setFullName(fullName);
                    r.setContactNumber(contactNumber);
                    r.setEmail(email);
                    r.setRoomType(roomType);
                    r.setCheckIn(checkIn);
                    r.setCheckOut(checkOut);
                    r.setGuests(guests);
                    r.setTotalPrice(total);
                    r.setStatus("BOOKED");

                    int id = dao.create(r);
                    resp.sendRedirect(req.getContextPath() + "/reservations/confirm.jsp?id=" + id);
                    return;
                }

                case "cancel": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.cancel(id, userId);
                    resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
                    return;
                }

                case "update": {
                    int id             = Integer.parseInt(req.getParameter("id"));
                    String roomType    = trim(req.getParameter("roomType"));
                    LocalDate checkIn  = LocalDate.parse(req.getParameter("checkIn"));
                    LocalDate checkOut = LocalDate.parse(req.getParameter("checkOut"));
                    int guests         = Integer.parseInt(req.getParameter("guests"));

                    LocalDate minIn = LocalDate.now().plusDays(2);
                    require(roomType != null && !roomType.isBlank(), "Room type is required");
                    require(!checkIn.isBefore(minIn), "Check-in must be at least 2 days from today");
                    require(checkOut.isAfter(checkIn), "Check-out must be after check-in");
                    int cap = capacityFor(roomType);
                    require(guests >= 1 && guests <= cap, "Guests must be within capacity for room");

                    // recompute price and persist it
                    BigDecimal total = Pricing.estimateTotal(roomType, checkIn, checkOut);

                    dao.update(id, userId, roomType, checkIn, checkOut, guests, total);

                    resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
                    return;
                }


                case "delete": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.delete(id, userId);
                    resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
                    return;
                }

                default:
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action: " + action);
            }
        } catch (ServletException se) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, se.getMessage());
        } catch (Exception ex) {
            throw new ServletException("Reservation action failed: " + action, ex);
        }
    }

    private static String nvl(String s, String def) { return (s == null) ? def : s; }
    private static String trim(String s) { return s == null ? null : s.trim(); }
}
