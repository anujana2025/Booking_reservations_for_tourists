package com.replp.booking_reservations_for_tourists.util;

import java.sql.Connection;
import java.sql.Statement;

public class DBInit {

    private static final String[] DDL = new String[] {
            // Tourist
            """
        CREATE TABLE IF NOT EXISTS Tourist (
          TouristID     BIGINT AUTO_INCREMENT PRIMARY KEY,
          FirstName     VARCHAR(80)  NOT NULL,
          LastName      VARCHAR(80)  NOT NULL,
          Email         VARCHAR(120) NOT NULL UNIQUE,
          PhoneNumber   VARCHAR(30),
          PasswordHash  VARCHAR(120) NOT NULL,
          CreatedAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """,

            // Staff supertype
            """
        CREATE TABLE IF NOT EXISTS Staff (
          StaffID       BIGINT AUTO_INCREMENT PRIMARY KEY,
          FirstName     VARCHAR(80)  NOT NULL,
          LastName      VARCHAR(80)  NOT NULL,
          Email         VARCHAR(120) NOT NULL UNIQUE,
          PhoneNumber   VARCHAR(30),
          PasswordHash  VARCHAR(120) NOT NULL,
          Department    VARCHAR(80),
          StaffType     VARCHAR(20)  NOT NULL,
          CreatedAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          CONSTRAINT CK_StaffType CHECK (StaffType IN ('FRONT_DESK','MARKETING','MANAGER','IT'))
        )
        """,

            // Add BLOB columns for avatar storage
            """
                 ALTER TABLE Staff ADD COLUMN IF NOT EXISTS ProfilePicBlob BLOB
                 """,
            """
                 ALTER TABLE Staff ADD COLUMN IF NOT EXISTS ProfilePicMime VARCHAR(100)
                 """,
            """
                ALTER TABLE Staff ADD COLUMN IF NOT EXISTS ProfilePicUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                """ ,

            // Subtypes
            """
        CREATE TABLE IF NOT EXISTS FrontDesk (
          StaffID   BIGINT PRIMARY KEY,
          DeskCode  VARCHAR(20),
          CONSTRAINT FK_FrontDesk_Staff
            FOREIGN KEY (StaffID) REFERENCES Staff(StaffID) ON DELETE CASCADE
        )
        """,
            """
        CREATE TABLE IF NOT EXISTS MarketingTeam (
          StaffID           BIGINT PRIMARY KEY,
          CampaignsManaged  VARCHAR(255),
          CONSTRAINT FK_Marketing_Staff
            FOREIGN KEY (StaffID) REFERENCES Staff(StaffID) ON DELETE CASCADE
        )
        """,
            """
        CREATE TABLE IF NOT EXISTS Manager (
          StaffID BIGINT PRIMARY KEY,
          Role    VARCHAR(80),
          CONSTRAINT FK_Manager_Staff
            FOREIGN KEY (StaffID) REFERENCES Staff(StaffID) ON DELETE CASCADE
        )
        """,
            """
        CREATE TABLE IF NOT EXISTS ITStaff (
          StaffID        BIGINT PRIMARY KEY,
          Specialization VARCHAR(120),
          CONSTRAINT FK_IT_Staff
            FOREIGN KEY (StaffID) REFERENCES Staff(StaffID) ON DELETE CASCADE
        )
        """
    };

    public static void init() {
        try (Connection conn = DBconnect.get(); Statement st = conn.createStatement()) {
            for (String sql : DDL) {
                st.execute(sql);
            }
            System.out.println("✅ EER schema ensured (Tourist, Staff + ISA subtypes).");
        } catch (Exception e) {
            throw new RuntimeException("Schema init failed", e);
        }
    }


}
