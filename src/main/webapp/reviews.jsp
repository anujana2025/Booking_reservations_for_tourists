<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, com.wbhrs.webbasedhotelreservationsystemfortourists.model.Review" %>
<%
    String ctx = request.getContextPath();
    boolean isTouristLoggedIn = (session != null && session.getAttribute("touristId") != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Reviews</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/staff-dashboard.css" />
    <link rel="stylesheet" href="<%=ctx%>/assets/css/profile.css" />
    <style>
        .reviews { max-width: 960px; margin: 24px auto; padding: 0 16px; }
        .review-card { background: #fff; border: 1px solid #e5e7eb; border-radius: 10px; padding: 18px; margin-bottom: 14px; box-shadow: 0 1px 2px rgba(16,24,40,.06); transition: box-shadow .2s ease, transform .2s ease; }
        .review-card:hover { box-shadow: 0 6px 16px rgba(16,24,40,.12); transform: translateY(-1px); }
        .review-meta { color: #6b7280; font-size: 13px; display: flex; align-items: center; gap: 8px; }
        .stars { color: #f59e0b; letter-spacing: 1px; font-size: 14px; }
        .badge { display: inline-block; background: #eef2ff; color: #3730a3; border: 1px solid #e0e7ff; padding: 2px 8px; border-radius: 999px; font-size: 12px; }
        .review-actions { display: flex; gap: 8px; margin-top: 8px; }
        .form-card { background: #fff; border: 1px solid #e5e7eb; border-radius: 12px; padding: 18px; margin: 16px 0; box-shadow: 0 1px 2px rgba(16,24,40,.06); }
        .form-card h2 { margin: 0 0 10px 0; font-size: 18px; }
        .field { margin-bottom: 10px; }
        .field label { display: block; font-weight: 600; margin-bottom: 6px; }
        .field input[type=text], .field textarea, .field select { width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 8px; background: #fafafa; }
        .muted { color: #6b7280; font-size: 14px; }
        .btn.lg { font-size: 16px; padding: 10px 16px; }
        .signin-callout { background: #f0f9ff; border: 1px solid #bae6fd; color: #0c4a6e; padding: 12px 14px; border-radius: 10px; font-size: 16px; text-align: center; }
        .signin-callout a { color: #2563eb; font-weight: 700; text-decoration: none; }
        .signin-callout a:hover { text-decoration: underline; }
    </style>
</head>
<body>
<header class="header">
    <div class="logo"><a href="<%=ctx%>/index.jsp"><img src="<%=ctx%>/assets/images/logo2.png" alt="logo" height="36"/></a></div>
    <h1 style="text-align:center">Reviews</h1>
</header>

<main class="reviews">
    <% if (request.getParameter("deleted") != null) { %>
        <div class="alert success">Review deleted.</div>
    <% } %>
    <% if (request.getParameter("success") != null) { %>
        <div class="alert success">Review saved.</div>
    <% } %>
    <% if (request.getParameter("error") != null) { %>
        <div class="alert error">Action failed. Please try again.</div>
    <% } %>

    <% if (isTouristLoggedIn) { %>
    <!-- Create/Update form (tourists only) -->
    <div class="form-card">
        <h2>Share your experience</h2>
        <form method="post" action="<%=ctx%>/reviews/save">
            <input type="hidden" name="reviewId" id="reviewId" />
            <div class="field">
                <label for="title">Title (optional)</label>
                <input type="text" name="title" id="title" maxlength="120" />
            </div>
            <div class="field">
                <label for="content">Content</label>
                <textarea name="content" id="content" rows="4" maxlength="1000" required></textarea>
            </div>
            <div class="field">
                <label for="rating">Rating</label>
                <select name="rating" id="rating" required>
                    <option value="">Select rating</option>
                    <option value="1">1</option>
                    <option value="2">2</option>
                    <option value="3">3</option>
                    <option value="4">4</option>
                    <option value="5">5</option>
                </select>
            </div>
            <div>
                <button class="btn" type="submit">Save Review</button>
                <button class="btn secondary" type="button" onclick="resetForm()">Reset</button>
            </div>
        </form>
    </div>
    <% } else { %>
        <p class="signin-callout">Only registered tourists can write reviews. <a href="<%=ctx%>/tourist-signin.jsp">Sign in</a> to share yours.</p>
    <% } %>

    <!-- Reviews list (visible to all) -->
    <section>
        <%
            List<Review> reviews = (List<Review>) request.getAttribute("reviews");
            if (reviews == null || reviews.isEmpty()) {
        %>
        <p class="muted">No reviews yet. Be the first to share your experience.</p>
        <% } else { %>
        <%
            Long sessionTouristId = (session != null && session.getAttribute("touristId") != null)
                ? Long.parseLong(String.valueOf(session.getAttribute("touristId"))) : null;
            for (Review r : reviews) {
                boolean isOwner = (sessionTouristId != null && sessionTouristId.equals(r.getTouristId()));
        %>
        <div class="review-card">
            <div class="review-meta">
                <span class="stars">
                    <%
                        String full = "★★★★★".substring(0, Math.max(0, Math.min(5, r.getRating())));
                        String empty = "☆☆☆☆☆".substring(0, 5 - Math.max(0, Math.min(5, r.getRating())));
                    %>
                    <%= full %><span style="color:#d1d5db"><%= empty %></span>
                </span>
                <span class="badge">Posted <%= r.getCreatedAt() %></span>
            </div>
            <h3 style="margin: 8px 0 4px 0;"><%= r.getTitle() == null ? "(No title)" : r.getTitle() %></h3>
            <p><%= r.getContent() %></p>
            <% if (isOwner) { %>
            <div class="review-actions">
                <button class="btn" onclick="editReview('<%= r.getReviewId() %>','<%= (r.getTitle()==null?"":r.getTitle()).replace("'","&#39;").replace("\"","&quot;") %>','<%= r.getContent().replace("'","&#39;").replace("\"","&quot;") %>',<%= r.getRating() %>)">Edit</button>
                <form method="post" action="<%=ctx%>/reviews/delete" onsubmit="return confirm('Delete this review?');">
                    <input type="hidden" name="id" value="<%= r.getReviewId() %>" />
                    <button class="btn danger" type="submit">Delete</button>
                </form>
            </div>
            <% } %>
        </div>
        <% } } %>
    </section>

    <div style="text-align:center; margin: 20px 0;">
        <a class="btn lg" href="<%=ctx%>/index.jsp">Back to home</a>
    </div>
</main>

<script>
function editReview(id, title, content, rating) {
    document.getElementById('reviewId').value = id;
    document.getElementById('title').value = title || '';
    document.getElementById('content').value = content || '';
    document.getElementById('rating').value = String(rating || '');
    window.scrollTo({ top: 0, behavior: 'smooth' });
}
function resetForm() {
    document.getElementById('reviewId').value = '';
    document.getElementById('title').value = '';
    document.getElementById('content').value = '';
    document.getElementById('rating').value = '';
}
</script>

</body>
</html>


