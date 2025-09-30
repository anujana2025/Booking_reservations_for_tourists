package com.replp.booking_reservations_for_tourists.user.model;

import com.replp.booking_reservations_for_tourists.util.PasswordHash;

public class Staff {
    protected String id;             // UUID PK
    protected String firstname;
    protected String lastname;
    protected String email;
    protected String phone;
    protected String passwordHashed; // SHA-256 hex
    protected boolean active = true;

    protected String otp;
    protected long otpTimestamp;

    public Staff() {}

    public Staff(String id, String firstname, String lastname,
                 String email, String phone, String rawPassword) {
        this.id = id;
        this.firstname = firstname;
        this.lastname = lastname;
        this.email = email;
        this.phone = phone;
        setPasswordRaw(rawPassword);
    }

    // Password handling
    public void setPasswordRaw(String rawPassword) {
        this.passwordHashed = PasswordHash.hashPassword(rawPassword);
    }
    public void setPasswordHashed(String hashed) { this.passwordHashed = hashed; }
    public String getPasswordHashed() { return passwordHashed; }
    public boolean checkPassword(String rawPassword) {
        return passwordHashed != null &&
                passwordHashed.equals(PasswordHash.hashPassword(rawPassword));
    }

    // Authentication
    public boolean authenticate(String input, String rawPassword) {
        boolean idMatch = (email != null && email.equals(input)) ||
                (phone != null && phone.equals(input));
        return idMatch && checkPassword(rawPassword);
    }

    // Getters/Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getFirstname() { return firstname; }
    public void setFirstname(String firstname) { this.firstname = firstname; }

    public String getLastname() { return lastname; }
    public void setLastname(String lastname) { this.lastname = lastname; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }

    public long getOtpTimestamp() { return otpTimestamp; }
    public void setOtpTimestamp(long otpTimestamp) { this.otpTimestamp = otpTimestamp; }
}
