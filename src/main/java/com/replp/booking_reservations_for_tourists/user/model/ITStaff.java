package com.replp.booking_reservations_for_tourists.user.model;

public class ITStaff extends Staff {
    private String specialization; // Backend, Network, etc.

    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }

}
