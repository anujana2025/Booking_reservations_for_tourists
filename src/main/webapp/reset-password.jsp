<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctx = request.getContextPath();

  // actor: staff | tourist  (default staff if missing)
  String actor = request.getParameter("actor");
  if (actor == null || actor.isBlank()) actor = (String) session.getAttribute("actor");
  if (actor == null || !(actor.equalsIgnoreCase("staff") || actor.equalsIgnoreCase("tourist"))) actor = "staff";
  session.setAttribute("actor", actor);

  boolean isStaff = "staff".equalsIgnoreCase(actor);
  String roleTitle = isStaff ? "Staff" : "Tourist";
  String backSignin = isStaff ? "staff-signin.jsp" : "tourist-signin.jsp";

  // message toasts (your pattern)
  String message = (String) request.getAttribute("message");
  String type    = (String) request.getAttribute("type"); // success | danger | warning | error
  String toastClass = null;
  if (message != null && type != null) {
    if ("success".equalsIgnoreCase(type))      toastClass = "message-success";
    else if ("danger".equalsIgnoreCase(type) ||
            "error".equalsIgnoreCase(type))   toastClass = "message-error";
    else                                       toastClass = "message-warning";
  }

  // email comes from session set during Forgot (use the same key you used there)
  String resetEmail = (String) session.getAttribute("reset_email"); // <- ensure your servlet sets this
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title><%= roleTitle %> Reset Password</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <link rel="stylesheet" href="<%=ctx%>/assets/css/auth.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>

<% if (toastClass != null) { %>
<div class="message-container">
  <div class="message <%= toastClass %>">
    <span class="message-icon">
      <% if ("message-success".equals(toastClass)) { %>
        <i class="fas fa-check-circle"></i>
      <% } else if ("message-error".equals(toastClass)) { %>
        <i class="fas fa-triangle-exclamation"></i>
      <% } else { %>
        <i class="fas fa-info-circle"></i>
      <% } %>
    </span>
    <span class="message-text"><%= message %></span>
    <button class="message-close" onclick="this.closest('.message').remove()">
      <i class="fas fa-times"></i>
    </button>
  </div>
</div>
<% } %>

<div class="auth-container">
  <div class="auth-image"></div>

  <div class="auth-form-container muted center">
    <div class="auth-form-content wide">

      <div class="logo-container">
        <img src="<%=ctx%>/assets/images/logo2.png" alt="Logo" class="logo">
      </div>

      <h1>Reset Password</h1>
      <p class="subtitle">
        Enter your new password for
        <% if (resetEmail != null) { %>
        <strong><%= resetEmail %></strong>
        <% } else { %>
        <em>your account</em>
        <% } %>
        (<%= roleTitle %>).
      </p>

      <!-- IMPORTANT: use ctx, carry actor -->
      <form action="<%=ctx%>/ResetPasswordServlet" method="post" novalidate id="resetForm">
        <input type="hidden" name="actor" value="<%= actor %>">
        <!-- Rely on session email on the server for security; keep hidden only if your servlet expects it -->
        <input type="hidden" name="email" value="<%= resetEmail != null ? resetEmail : "" %>">

        <div class="form-group">
          <label for="password" class="form-label">New Password</label>
          <div class="password-field">
            <input type="password" id="password" name="newPassword" required minlength="8"
                   placeholder="At least 6 characters" autocomplete="new-password" autofocus>
          </div>
          <%
            String passwordError = (String) request.getAttribute("passwordError");
            if (passwordError != null) {
          %>
          <div class="text-danger small"><%= passwordError %></div>
          <% } %>
        </div>

        <div class="form-group">
          <label for="confirmPassword" class="form-label">Confirm Password</label>
          <div class="password-field">
            <input type="password" id="confirmPassword" name="confirmPassword" required
                   placeholder="Re-enter new password" autocomplete="new-password">
          </div>
          <%
            String confirmPasswordError = (String) request.getAttribute("confirmPasswordError");
            if (confirmPasswordError != null) {
          %>
          <div class="text-danger small"><%= confirmPasswordError %></div>
          <% } %>
        </div>

        <!-- Optional hint / strength meter area -->
        <div id="pwHint" class="small text-muted mb-2"></div>

        <button type="submit" class="btn-primary w-100">Reset Password</button>
      </form>

      <div class="mt-3">
        <a class="back-link" href="<%=ctx%>/forgot-password.jsp?actor=<%=actor%>">
          <i class="fas fa-arrow-left"></i> Back
        </a>
        <span class="mx-2">•</span>
        <a class="back-link" href="<%=ctx%>/<%= backSignin %>">
          Go to <%= roleTitle %> Sign In
        </a>
      </div>

      <div class="auth-footer">
        © <%= java.time.Year.now() %> 93 Hotel Reservation | Year 2 Semester 1 | Group 93
      </div>
    </div>
  </div>
</div>


</body>
</html>
