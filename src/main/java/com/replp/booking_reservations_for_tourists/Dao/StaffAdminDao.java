package com.replp.booking_reservations_for_tourists.Dao;

import com.replp.booking_reservations_for_tourists.util.DBconnect;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * StaffAdminDao (uses your DBInit schema)
 * Tables: Staff, FrontDesk, MarketingTeam, Manager, ITStaff, Tourist
 * Columns: Staff.PhoneNumber, Tourist.PhoneNumber, Manager.Role
 */
public class StaffAdminDao {

    /* ---------- Simple view models for the JSP ---------- */
    public static class StaffView {
        private final long staffId;
        private final String firstName, lastName, email, phoneNumber, department, staffType;
        private final String deskCode;         // FrontDesk
        private final String campaignsManaged; // MarketingTeam
        private final String managerRole;      // Manager.Role
        private final String specialization;   // ITStaff

        public StaffView(long staffId, String firstName, String lastName, String email,
                         String phoneNumber, String department, String staffType,
                         String deskCode, String campaignsManaged, String managerRole, String specialization) {
            this.staffId = staffId; this.firstName = firstName; this.lastName = lastName; this.email = email;
            this.phoneNumber = phoneNumber; this.department = department; this.staffType = staffType;
            this.deskCode = deskCode; this.campaignsManaged = campaignsManaged; this.managerRole = managerRole; this.specialization = specialization;
        }
        public long getStaffId() { return staffId; }
        public String getFirstName() { return firstName; }
        public String getLastName() { return lastName; }
        public String getEmail() { return email; }
        public String getPhoneNumber() { return phoneNumber; }
        public String getDepartment() { return department; }
        public String getStaffType() { return staffType; }
        public String getDeskCode() { return deskCode; }
        public String getCampaignsManaged() { return campaignsManaged; }
        public String getManagerRole() { return managerRole; }
        public String getSpecialization() { return specialization; }
    }

    public static class TouristView {
        private final long touristId;
        private final String firstName, lastName, email, phone;
        public TouristView(long id, String fn, String ln, String em, String ph) {
            touristId = id; firstName = fn; lastName = ln; email = em; phone = ph;
        }
        public long getTouristId() { return touristId; }
        public String getFirstName() { return firstName; }
        public String getLastName() { return lastName; }
        public String getEmail() { return email; }
        public String getPhone() { return phone; }
    }

    /* ---------- Lists ---------- */

    /** List staff with subtype fields; q= free text; role= exact; dept= partial. */
    public List<StaffView> listStaff(String q, String roleFilter, String deptFilter) throws SQLException {
        // normalize once
        String qNorm = q == null ? "" : q.trim().toLowerCase();
        String role  = roleFilter == null ? "" : roleFilter.trim();
        String dept  = deptFilter == null ? "" : deptFilter.trim().toLowerCase();

        StringBuilder sql = new StringBuilder(
                "SELECT s.StaffID, s.FirstName, s.LastName, s.Email, " +
                        "       s.PhoneNumber AS PhoneNumber, " +
                        "       s.Department, s.StaffType, " +
                        "       fd.DeskCode, " +
                        "       mk.CampaignsManaged, " +
                        "       mg.Role AS ManagerRole, " +
                        "       it.Specialization " +
                        "FROM Staff s " +
                        "LEFT JOIN FrontDesk     fd ON fd.StaffID = s.StaffID " +
                        "LEFT JOIN MarketingTeam mk ON mk.StaffID = s.StaffID " +
                        "LEFT JOIN Manager       mg ON mg.StaffID = s.StaffID " +
                        "LEFT JOIN ITStaff       it ON it.StaffID = s.StaffID " +
                        "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (!qNorm.isBlank()) {
            sql.append("AND (LOWER(s.FirstName) LIKE ? OR LOWER(s.LastName) LIKE ? OR LOWER(s.Email) LIKE ? " +
                    "OR REPLACE(s.PhoneNumber,' ','') LIKE ?) ");
            String like = "%" + qNorm + "%";
            params.add(like); params.add(like); params.add(like);
            params.add("%" + qNorm.replaceAll("\\s+","") + "%"); // phone fragment ignoring spaces
        }
        if (!role.isBlank()) {
            sql.append("AND s.StaffType = ? ");
            params.add(role);
        }
        if (!dept.isBlank()) {
            sql.append("AND LOWER(s.Department) LIKE ? ");
            params.add("%" + dept + "%"); // partial + case-insensitive
        }
        sql.append("ORDER BY s.StaffID ASC");

        try (Connection c = DBconnect.get();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            List<StaffView> out = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(new StaffView(
                            rs.getLong("StaffID"),
                            rs.getString("FirstName"),
                            rs.getString("LastName"),
                            rs.getString("Email"),
                            rs.getString("PhoneNumber"),
                            rs.getString("Department"),
                            rs.getString("StaffType"),
                            rs.getString("DeskCode"),
                            rs.getString("CampaignsManaged"),
                            rs.getString("ManagerRole"),
                            rs.getString("Specialization")
                    ));
                }
            }
            return out;
        }
    }

    /** List all tourists (your schema uses PhoneNumber) */
    public List<TouristView> listTourists() throws SQLException {
        String sql = "SELECT TouristID, FirstName, LastName, Email, PhoneNumber AS Phone FROM Tourist ORDER BY TouristID ASC";
        try (Connection c = DBconnect.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<TouristView> out = new ArrayList<>();
            while (rs.next()) {
                out.add(new TouristView(
                        rs.getLong("TouristID"),
                        rs.getString("FirstName"),
                        rs.getString("LastName"),
                        rs.getString("Email"),
                        rs.getString("Phone")
                ));
            }
            return out;
        }
    }

    /* ---------- Mutations ---------- */

    /** Update Staff + exactly one subtype (MERGE creates/updates). */
    public void updateStaffAndSubtype(long staffId,
                                      String staffType,
                                      String department,
                                      String deskCode,
                                      String campaignsManaged,
                                      String managerRole,
                                      String specialization) throws SQLException {

        String t = staffType == null ? "FRONT_DESK" : staffType.trim();

        try (Connection c = DBconnect.get()) {
            c.setAutoCommit(false);
            try {
                // main staff
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE Staff SET StaffType=?, Department=? WHERE StaffID=?")) {
                    ps.setString(1, t);
                    ps.setString(2, department == null ? "" : department.trim());
                    ps.setLong(3, staffId);
                    ps.executeUpdate();
                }

                // clear all subtypes
                clearSubtypes(c, staffId);

                // upsert chosen subtype
                switch (t) {
                    case "MARKETING" -> merge(c,
                            "MERGE INTO MarketingTeam (StaffID, CampaignsManaged) KEY(StaffID) VALUES (?, ?)",
                            staffId, campaignsManaged == null ? "" : campaignsManaged.trim()
                    );
                    case "MANAGER" -> merge(c,
                            "MERGE INTO Manager (StaffID, Role) KEY(StaffID) VALUES (?, ?)",
                            staffId, managerRole == null ? "" : managerRole.trim()
                    );
                    case "IT" -> merge(c,
                            "MERGE INTO ITStaff (StaffID, Specialization) KEY(StaffID) VALUES (?, ?)",
                            staffId, specialization == null ? "" : specialization.trim()
                    );
                    default -> merge(c, // FRONT_DESK
                            "MERGE INTO FrontDesk (StaffID, DeskCode) KEY(StaffID) VALUES (?, ?)",
                            staffId, deskCode == null ? "" : deskCode.trim()
                    );
                }

                c.commit();
            } catch (SQLException e) {
                c.rollback();
                throw e;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public void deleteStaff(long staffId) throws SQLException {
        try (Connection c = DBconnect.get()) {
            c.setAutoCommit(false);
            try {
                clearSubtypes(c, staffId);
                try (PreparedStatement ps = c.prepareStatement("DELETE FROM Staff WHERE StaffID=?")) {
                    ps.setLong(1, staffId);
                    ps.executeUpdate();
                }
                c.commit();
            } catch (SQLException e) {
                c.rollback();
                throw e;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public void deleteTourist(long touristId) throws SQLException {
        try (Connection c = DBconnect.get();
             PreparedStatement ps = c.prepareStatement("DELETE FROM Tourist WHERE TouristID=?")) {
            ps.setLong(1, touristId);
            ps.executeUpdate();
        }
    }

    /* ---------- helpers ---------- */
    private void clearSubtypes(Connection c, long staffId) throws SQLException {
        try (PreparedStatement a = c.prepareStatement("DELETE FROM FrontDesk WHERE StaffID=?");
             PreparedStatement b = c.prepareStatement("DELETE FROM MarketingTeam WHERE StaffID=?");
             PreparedStatement d = c.prepareStatement("DELETE FROM Manager WHERE StaffID=?");
             PreparedStatement e = c.prepareStatement("DELETE FROM ITStaff WHERE StaffID=?")) {
            a.setLong(1, staffId); a.executeUpdate();
            b.setLong(1, staffId); b.executeUpdate();
            d.setLong(1, staffId); d.executeUpdate();
            e.setLong(1, staffId); e.executeUpdate();
        }
    }

    private void merge(Connection c, String sql, long id, String value) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.setString(2, value);
            ps.executeUpdate();
        }
    }
}
