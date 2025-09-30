<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- =========================
     1) Read context + optional query messages
     ========================= --%>
<%
  String ctx = request.getContextPath();               // Base path for links/assets (works under any context root)
  String err = request.getParameter("error");          // Optional: "invalid" or "required" to show alerts
  String ok  = request.getParameter("success");        // Optional: e.g., "1" after signup to show success
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <!-- Meta + title -->
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Staff Sign In</title>

  <!-- Google Fonts (Poppins) -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <!-- Bootstrap CSS for layout/components -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Font Awesome (icons) -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- Page stylesheet (your custom styles) -->
  <link rel="stylesheet" href="<%=ctx%>/assets/css/signin.css">
</head>
<body>

<!-- Full-height container: two columns (image left, form right) -->
<div class="container-fluid min-vh-100 d-flex">
  <!-- Left Side: decorative/auth image; hidden on small screens -->
  <div class="col-md-6 d-none d-md-block auth-image"></div>

  <!-- Right Side: sign-in form centered -->
  <div class="col-md-6 d-flex align-items-center justify-content-center">
    <div class="w-75"><!-- limit content width for nice readable form -->

      <!-- Logo -->
      <div class="text-center mb-4">
        <img src="<%=ctx%>/assets/images/logo2.png" alt="Logo" class="img-fluid" style="max-width:150px;">
      </div>

      <!-- Page heading -->
      <h1 class="text-center">Staff Sign In</h1>
      <p class="text-muted text-center">Access your staff account</p>

      <%-- =========================
           2) Flash messages (from query params)
           ========================= --%>
      <% if ("invalid".equals(err)) { %>
      <div class="alert alert-danger text-center py-2">Invalid email or password.</div>
      <% } else if ("required".equals(err)) { %>
      <div class="alert alert-warning text-center py-2">Please fill in both fields.</div>
      <% } %>

      <%-- You could also show success after signup like:
         <% if ("1".equals(ok)) { %>
            <div class="alert alert-success text-center py-2">Account created. Please sign in.</div>
         <% } %>
      --%>

      <!-- =========================
           3) Sign-in form: posts to /StaffSignin
           Backend should:
             - validate identifier (email or phone) + password
             - set session attributes on success
             - redirect back with ?error=invalid on failure
           ========================= -->
      <form action="<%=ctx%>/StaffSignin" method="post">
        <!-- Email or Phone -->
        <div class="mb-3">
          <input type="text" name="identifier" class="form-control" placeholder="Email or Phone" required>
        </div>

        <!-- Password + forgot link -->
        <div class="mb-3">
          <input type="password" name="password" class="form-control" placeholder="Password" required>
          <div class="text-end mt-1">
            <a href="<%=ctx%>/staff-forgot-password.jsp" class="text-decoration-none small">Forgot Password?</a>
          </div>
        </div>

        <!-- Submit -->
        <div class="d-grid">
          <button type="submit" class="btn btn-primary">Sign in</button>
        </div>
      </form>

      <!-- Links / footer -->
      <div class="text-center mt-4">
        <small>
          Don’t have an account?
          <a href="<%=ctx%>/staff-signup.jsp" class="text-decoration-none">Sign up</a>
        </small>
      </div>

      <!-- Year auto-updates via java.time.Year on server -->
      <div class="text-center mt-4">
        <small class="text-muted">© <%= java.time.Year.now() %> 93 Hotel Reservation | Year 2 Semester 1 | Group 93</small>
      </div>

    </div>
  </div>
</div>
</body>
</html>
