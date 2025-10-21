package com.serenityhaven.model;

import java.math.BigDecimal;
import java.time.LocalDate;

public class Reservation {
    private int id;
    private int userId;
    private String roomType;
    private LocalDate checkIn;
    private LocalDate checkOut;
    private int guests;
    private String status;       // BOOKED | CANCELLED | COMPLETED

    // optional user-facing fields (if you added them earlier)
    private String fullName;
    private String contactNumber;
    private String email;

    private BigDecimal totalPrice;

    // getters
    public int getId() { return id; }
    public int getUserId() { return userId; }
    public String getRoomType() { return roomType; }
    public LocalDate getCheckIn() { return checkIn; }
    public LocalDate getCheckOut() { return checkOut; }
    public int getGuests() { return guests; }
    public String getStatus() { return status; }
    public String getFullName() { return fullName; }
    public String getContactNumber() { return contactNumber; }
    public String getEmail() { return email; }
    public BigDecimal getTotalPrice() { return totalPrice; }

    // setters
    public void setId(int id) { this.id = id; }
    public void setUserId(int userId) { this.userId = userId; }
    public void setRoomType(String roomType) { this.roomType = roomType; }
    public void setCheckIn(LocalDate checkIn) { this.checkIn = checkIn; }
    public void setCheckOut(LocalDate checkOut) { this.checkOut = checkOut; }
    public void setGuests(int guests) { this.guests = guests; }
    public void setStatus(String status) { this.status = status; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }
    public void setEmail(String email) { this.email = email; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }
}
