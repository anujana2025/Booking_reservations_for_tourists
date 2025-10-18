package com.replp.booking_reservations_for_tourists.util;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailSender {
    private static final String HOST = "smtp.gmail.com";
    private static final String PORT = "587";
    private static final String USERNAME = "hotel.reservation.93.2025@gmail.com";
    private static final String PASSWORD = "cctp vvct yjca xrno"; // 16-char app password

    public static boolean sendEmail(String to, String subject, String message){
        try {
            Properties properties = new Properties();
            properties.put("mail.smtp.host", HOST);
            properties.put("mail.smtp.port", PORT);
            properties.put("mail.smtp.auth", "true");
            properties.put("mail.smtp.starttls.enable", "true");
            properties.put("mail.smtp.ssl.trust", HOST);

            Session session = Session.getInstance(properties, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USERNAME, PASSWORD);
                }
            });

            Message mimeMessage = new MimeMessage(session);
            mimeMessage.setFrom(new InternetAddress(USERNAME));
            mimeMessage.setRecipient(Message.RecipientType.TO, new InternetAddress(to));
            mimeMessage.setSubject(subject);
            mimeMessage.setText(message);

            Transport.send(mimeMessage);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}

