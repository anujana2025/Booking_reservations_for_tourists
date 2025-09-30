<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Tourist Sign Up - Hotel Reservation System</title>

    <!-- Fonts & Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Page CSS -->
    <link rel="stylesheet" href="<%=ctx%>/assets/css/signup.css">
</head>
<body>
<div class="container-fluid auth-container d-flex">
    <!-- Left: image -->
    <div class="col-lg-6 d-none d-lg-block auth-image"></div>

    <!-- Right: form (centered like admin) -->
    <div class="col-lg-6 d-flex flex-column auth-form-container">
        <div class="auth-form-content">
            <!-- Logo -->
            <div class="logo-container text-center">
                <img class="logo" src="<%=ctx%>/assets/images/logo2.png" alt="Logo">
            </div>

            <!-- Heading -->
            <h1 class="text-center">Create Tourist Account</h1>
            <p class="subtitle text-center">Fill in your details to register as a tourist.</p>

            <!-- Optional flash messages -->
            <%
                String code = request.getParameter("error");
                String ok   = request.getParameter("success");
                if (ok != null) {
            %>
            <div class="alert alert-success" role="alert">Registered successfully.</div>
            <%
            } else if (code != null) {
                String msg = switch (code) {
                    case "email_exists" -> "An account with this email already exists. Please <a class='auth-link' href='" + ctx + "/tourist-login.jsp'>sign in</a>.";
                    case "missing"      -> "Please fill in all required fields.";
                    case "server"       -> "Something went wrong. Please try again.";
                    default             -> "Unexpected error.";
                };
            %>
            <div class="auth-error"><%= msg %></div>
            <% } %>

            <!-- Form -->
            <form class="auth-form" action="<%=ctx%>/TouristSignup" method="post" novalidate>
                <!-- Common fields -->
                <div class="row g-3">
                    <div class="col-sm-6 form-group">
                        <input type="text" name="firstname" class="form-control" placeholder="First Name" required>
                    </div>
                    <div class="col-sm-6 form-group">
                        <input type="text" name="lastname" class="form-control" placeholder="Last Name" required>
                    </div>
                </div>

                <div class="form-group">
                    <input type="email" name="email" class="form-control" placeholder="Email" required>
                </div>

                <div class="form-group">
                    <input type="text" name="phone" class="form-control" placeholder="Phone">
                </div>

                <div class="form-group">
                    <input type="password" name="password" class="form-control" placeholder="Password" minlength="6" required>
                </div>

                <!-- Placeholder kept to preserve class names/structure; empty for Tourist -->
                <div id="extraFields"></div>

                <button type="submit" class="btn btn-primary">Sign Up</button>

                <div class="auth-footer">
                    <p>Already have an account?
                        <a class="auth-link" href="<%=ctx%>/tourist-signin.jsp">Sign in</a>
                    </p>
                </div>

                <div class="auth-copyright">
                    © <%= java.time.Year.now() %> Hotel Reservation System — Tourist
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>

