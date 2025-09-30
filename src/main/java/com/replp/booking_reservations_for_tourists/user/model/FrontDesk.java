package com.replp.booking_reservations_for_tourists.user.model;

public class FrontDesk extends Staff {
    private String shift;   // e.g., MORNING/EVENING/NIGHT
    private String deskNo;

    public String getShift() { return shift; }
    public void setShift(String shift) { this.shift = shift; }

    public String getDeskNo() { return deskNo; }
    public void setDeskNo(String deskNo) { this.deskNo = deskNo; }
}


