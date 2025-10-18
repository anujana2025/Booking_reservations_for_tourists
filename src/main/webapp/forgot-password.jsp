<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();

    // Read actor from query first, then session; default to "staff"
    String actor = request.getParameter("actor");
    if (actor == null || actor.isBlank()) {
        actor = (String) session.getAttribute("actor");
    }
    if (actor == null || (!actor.equalsIgnoreCase("staff") && !actor.equalsIgnoreCase("tourist"))) {
        actor = "staff";
    }
    session.setAttribute("actor", actor);

    // For dynamic UI bits
    boolean isStaff = "staff".equalsIgnoreCase(actor);
    String roleTitle = isStaff ? "Staff" : "Tourist";
    String backSignin = isStaff ? "staff-signin.jsp" : "tourist-signin.jsp";

    // Optional query flags you were using
    String err = request.getParameter("error");   // "invalid" | "required" | etc.
    String ok  = request.getParameter("success"); // "1"
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <!-- Page Metadata -->
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= roleTitle %> Forgot Password</title>

    <!-- External Styles and Fonts -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Custom CSS file -->
    <link rel="stylesheet" href="<%=ctx%>/assets/css/auth.css">
</head>
<body>
<!-- Full screen container -->
<div class="auth-container">

    <!-- Left side image -->
    <div class="auth-image"></div>

    <!-- Right side form container -->
    <div class="auth-form-container muted center">
        <div class="auth-form-content wide">

            <!-- Logo at the top -->
            <div class="logo-container text-center mb-4">
                <img src="<%=ctx%>/assets/images/logo2.png" alt="Logo" class="logo">
            </div>

            <!-- Page title and instructions -->
            <h1 class="mb-1"><%= roleTitle %> Forgot Password</h1>
            <p class="subtitle mb-3">
                Enter your email address to receive a verification code.
            </p>


            <!-- Bootstrap alert via request attributes (your original pattern) -->
            <%
                String message = (String) request.getAttribute("message");
                String messageType = (String) request.getAttribute("messageType"); // "success", "danger", etc.
                if (message != null && messageType != null) {
            %>
            <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
                <%= message %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>

            <!-- Also support simple query param alerts if you prefer -->
            <% if ("required".equals(err)) { %>
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
                Email is required.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } else if ("invalid".equals(err)) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                We couldn’t find that email for <%= roleTitle.toLowerCase() %>.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } else if ("1".equals(ok)) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                Password reset successful. Please sign in below.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>

            <!-- Forgot Password Form (shared) -->
            <form action="<%=ctx%>/forgotPasswordServlet" method="post" class="mb-3">
                <!-- carry actor -->
                <input type="hidden" name="actor" value="<%= actor %>">
                <div class="form-group">
                    <input type="email" name="email" placeholder="Email" required>
                </div>
                <button type="submit" class="btn-primary w-100">Send Verification Code</button>
            </form>

            <!-- Back to the correct sign-in -->
            <a href="<%= backSignin %>" class="back-link">
                <i class="fas fa-arrow-left"></i> Back to <%= roleTitle %> Sign In
            </a>
        </div>

        <!-- Page footer -->
        <div class="auth-footer">
            © <%= java.time.Year.now() %> 93 Hotel Reservation | Year 2 Semester 1 | Group 93
        </div>
    </div>
</div>

<!-- Bootstrap JS (for dismissible alerts) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
