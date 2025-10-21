package com.serenityhaven.dao;

import com.serenityhaven.config.ConnectionFactory;
import com.serenityhaven.model.Reservation;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;


public class ReservationDao {

    public int create(Reservation r) throws SQLException {
        String sql = "INSERT INTO dbo.Reservations (" +
                " user_id, full_name, contact_number, email, " +   // <-- add these
                " room_type, check_in, check_out, guests, status, total_price" +
                ") VALUES (?,?,?,?, ?,?,?,?, 'BOOKED', ?)";

        try (Connection con = ConnectionFactory.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1,  r.getUserId());
            ps.setString(2, r.getFullName());
            ps.setString(3, r.getContactNumber());
            ps.setString(4, r.getEmail());
            ps.setString(5, r.getRoomType());
            ps.setDate(6,  java.sql.Date.valueOf(r.getCheckIn()));
            ps.setDate(7,  java.sql.Date.valueOf(r.getCheckOut()));
            ps.setInt(8,   r.getGuests());
            ps.setBigDecimal(9, r.getTotalPrice());

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    public List<Reservation> listByUser(int userId, String status) throws SQLException {
        String sql = "SELECT id, user_id, room_type, check_in, check_out, guests, status, total_price " +
                "FROM dbo.Reservations WHERE user_id = ? " +
                (status != null ? "AND status = ? " : "") +
                "ORDER BY check_in DESC";
        try (Connection con = ConnectionFactory.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            if (status != null) ps.setString(2, status);

            List<Reservation> out = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Reservation r = new Reservation();
                    r.setId(rs.getInt("id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setRoomType(rs.getString("room_type"));
                    r.setCheckIn(rs.getDate("check_in").toLocalDate());
                    r.setCheckOut(rs.getDate("check_out").toLocalDate());
                    r.setGuests(rs.getInt("guests"));
                    r.setStatus(rs.getString("status"));
                    r.setTotalPrice(rs.getBigDecimal("total_price"));   // <-- load it
                    out.add(r);
                }
            }
            return out;
        }
    }

    // ReservationDao.java
    public boolean update(int id, int userId, String roomType,
                          LocalDate checkIn, LocalDate checkOut, int guests, BigDecimal totalPrice) throws SQLException {
        final String sql =
                "UPDATE dbo.Reservations " +
                        "SET room_type=?, check_in=?, check_out=?, guests=?, total_price=?, status='UPDATED', updated_at=SYSUTCDATETIME() " +
                        "WHERE id=? AND user_id=?";
        try (Connection con = ConnectionFactory.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, roomType);
            ps.setDate(2, java.sql.Date.valueOf(checkIn));
            ps.setDate(3, java.sql.Date.valueOf(checkOut));
            ps.setInt(4, guests);
            ps.setBigDecimal(5, totalPrice);
            ps.setInt(6, id);
            ps.setInt(7, userId);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean cancel(int id, int userId) throws SQLException {
        String sql = "UPDATE dbo.Reservations SET status='CANCELLED', updated_at=SYSUTCDATETIME() WHERE id=? AND user_id=?";
        try (Connection con = ConnectionFactory.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() == 1;
        }
    }

    /** Permanently delete a reservation owned by the user. */
    public boolean delete(int id, int userId) throws SQLException {
        final String sql = "DELETE FROM dbo.Reservations WHERE id = ? AND user_id = ?";
        try (Connection con = ConnectionFactory.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() == 1;
        }
    }
}
