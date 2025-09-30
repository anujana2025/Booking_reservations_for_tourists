package com.replp.booking_reservations_for_tourists.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBconnect {

    private static final String URL = "jdbc:h2:~/projdb;AUTO_SERVER=TRUE";
    // Or use "jdbc:h2:mem:projdb" for in-memory only

    private static final String USER = "sa";   // default user
    private static final String PASS = "";     // default password is empty

    static {
        try {
            Class.forName("org.h2.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("H2 Driver not found!", e);
        }
    }

    public static Connection get() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}

