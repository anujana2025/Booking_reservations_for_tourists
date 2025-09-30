package com.replp.booking_reservations_for_tourists.user.model;

import com.replp.booking_reservations_for_tourists.util.PasswordHash;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class Tourist {

    // Matches DB columns
    private Long touristId;            // BIGINT AUTO_INCREMENT PK
    private String firstName;
    private String lastName;
    private String email;
    private String phoneNumber;
    private String passwordHashed;     // SHA-256 hex
    private Timestamp createdAt;       // DEFAULT CURRENT_TIMESTAMP

    public Tourist() {}

    public Tourist(Long touristId, String firstName, String lastName,
                   String email, String phoneNumber, String rawPassword) {
        this.touristId = touristId;
        this.firstName = firstName;
        this.lastName  = lastName;
        this.email     = email;
        this.phoneNumber = phoneNumber;
        setPasswordRaw(rawPassword);
    }

    // Convenience ctor for sign-up (ID/createdAt from DB)
    public Tourist(String firstName, String lastName,
                   String email, String phoneNumber, String rawPassword) {
        this(null, firstName, lastName, email, phoneNumber, rawPassword);
    }

    /* ---------------- Password helpers (same style as Staff) ---------------- */

    public void setPasswordRaw(String rawPassword) {
        this.passwordHashed = PasswordHash.hashPassword(rawPassword);
    }

    public void setPasswordHashed(String hashed) { this.passwordHashed = hashed; }

    public String getPasswordHashed() { return passwordHashed; }

    public boolean checkPassword(String rawPassword) {
        return passwordHashed != null &&
                passwordHashed.equals(PasswordHash.hashPassword(rawPassword));
    }

    /** Accepts email OR phone as identifier */
    public boolean authenticate(String identifier, String rawPassword) {
        boolean idMatch = (email != null && email.equals(identifier)) ||
                (phoneNumber != null && phoneNumber.equals(identifier));
        return idMatch && checkPassword(rawPassword);
    }

    /* ----------------------------- Getters/Setters -------------------------- */

    public Long getTouristId() { return touristId; }
    public void setTouristId(Long touristId) { this.touristId = touristId; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}

