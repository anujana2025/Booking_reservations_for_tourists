package com.replp.booking_reservations_for_tourists.user.controller;

import com.replp.booking_reservations_for_tourists.util.DBconnect;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.InputStream;
import java.io.OutputStream;
import java.sql.*;

/**
 * StaffAvatarServlet
 * ------------------
 * Purpose: Return a staff member's profile picture as an image HTTP response.
 * URL:     /staff/avatar
 *
 * How it works (high level):
 * 1) Figure out which staffId to use (query param "staffId" or session "staffId").
 * 2) If we have a staffId, read the image BLOB + MIME type from DB.
 * 3) Stream the image bytes to the browser with the correct Content-Type.
 * 4) If no image found (or any issue), stream a local placeholder PNG.
 *
 * Notes:
 * - We set "Cache-Control: no-cache" so updated avatars show immediately.
 * - We stream directly (no big arrays) to save memory.
 */
@WebServlet("/staff/avatar")
public class StaffAvatarServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) {
        Long staffId = null;

        // -------- 1) Identify which staff's avatar to serve --------
        try {
            // First, try ?staffId=... in the URL (e.g., /staff/avatar?staffId=12)
            String q = req.getParameter("staffId");
            if (q != null && !q.isBlank()) staffId = Long.parseLong(q);
        } catch (Exception ignored) {
            // Safe to ignore: if parsing fails, we'll fallback to session
        }

        if (staffId == null) {
            // Fallback: if no query param, use the logged-in user's staffId from session
            HttpSession session = req.getSession(false); // false = don't create if missing
            Object sid = (session == null) ? null : session.getAttribute("staffId");
            if (sid != null) {
                // session attribute could be Long or String; handle both
                staffId = Long.parseLong(String.valueOf(sid));
            }
        }

        // If we still don't know who to serve, send the placeholder image and exit
        if (staffId == null) {
            sendPlaceholder(req, resp);
            return;
        }

        // -------- 2) Try to read avatar from database --------
        String sql = "SELECT ProfilePicBlob, ProfilePicMime FROM Staff WHERE StaffID=?";

        try (Connection con = DBconnect.get();                 // get a DB connection
             PreparedStatement ps = con.prepareStatement(sql)) // prepare statement
        {
            ps.setLong(1, staffId);                            // bind the ID
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getBinaryStream(1) != null) {
                    // Column 1 = BLOB stream; Column 2 = MIME type like "image/png"
                    String mime = rs.getString(2);
                    if (mime == null || mime.isBlank()) mime = "image/jpeg"; // sensible default

                    // Set HTTP headers for correct rendering + avoid stale cache
                    resp.setContentType(mime);
                    resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

                    // -------- 3) Stream image bytes to client --------
                    try (InputStream in = rs.getBinaryStream(1);
                         OutputStream out = resp.getOutputStream()) {
                        // transferTo streams data efficiently without loading whole file in memory
                        in.transferTo(out);
                    }
                    return; // success; stop here
                }
            }
        } catch (Exception ignored) {
            // Any DB/IO problem: we fall back to placeholder below
        }

        // -------- 4) No avatar in DB or error occurred: send placeholder --------
        sendPlaceholder(req, resp);
    }

    /**
     * Streams a local placeholder image when there's no user-uploaded avatar.
     * - Content-Type: image/png
     * - Cache disabled to show latest placeholder (consistent behavior with real avatar).
     */
    private void sendPlaceholder(HttpServletRequest req, HttpServletResponse resp) {
        resp.setContentType("image/png");
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        // The placeholder file should exist under: src/main/webapp/assets/images/avatar-placeholder.png
        try (InputStream in = req.getServletContext()
                .getResourceAsStream("/assets/images/avatar-placeholder.png");
             OutputStream out = resp.getOutputStream()) {
            if (in != null) {
                in.transferTo(out);
            }
            // If 'in' is null (file missing), we silently return an empty body.
        } catch (Exception ignored) {
            // If even placeholder fails, we keep response minimal.
        }
    }
}

