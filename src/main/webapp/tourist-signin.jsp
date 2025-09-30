<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String err = request.getParameter("error");   // "invalid" | "required"
    String ok  = request.getParameter("success"); // "1" after signup
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tourist Sign In</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/signin.css">
</head>
<body>
<div class="container-fluid min-vh-100 d-flex">
    <div class="col-md-6 d-none d-md-block auth-image"></div>

    <div class="col-md-6 d-flex align-items-center justify-content-center">
        <div class="w-75">
            <div class="text-center mb-4">
                <img src="<%=ctx%>/assets/images/logo2.png" alt="Logo" class="img-fluid" style="max-width:150px;">
            </div>

            <h1 class="text-center">Tourist Sign In</h1>
            <p class="text-muted text-center">Access your bookings and profile</p>

            <% if ("invalid".equals(err)) { %>
            <div class="alert alert-danger text-center py-2">Invalid email or password.</div>
            <% } else if ("required".equals(err)) { %>
            <div class="alert alert-warning text-center py-2">Please fill in both fields.</div>
            <% } %>

            <% if ("1".equals(ok)) { %>
            <div class="alert alert-success text-center py-2">Account created. Please sign in.</div>
            <% } %>

            <!-- If you accept phone too, change placeholder accordingly -->
            <form action="<%=ctx%>/TouristSignin" method="post">
                <div class="mb-3">
                    <input type="email" name="email" class="form-control" placeholder="Email" required>
                </div>
                <div class="mb-3">
                    <input type="password" name="password" class="form-control" placeholder="Password" required>
                    <div class="text-end mt-1">
                        <a href="<%=ctx%>/tourist-forgot-password.jsp" class="text-decoration-none small">Forgot Password?</a>
                    </div>
                </div>
                <div class="d-grid">
                    <button type="submit" class="btn btn-primary">Sign in</button>
                </div>
            </form>

            <div class="text-center mt-4">
                <small>
                    Don’t have an account?
                    <a class="text-decoration-none" href="<%=ctx%>/tourist-signup.jsp">Sign up</a>
                </small>
            </div>

            <div class="text-center mt-4">
                <small class="text-muted">© <%= java.time.Year.now() %> Copyright 93 Hotel Reservation | Year 2 Semester 1 | Group 93</small>
            </div>
        </div>
    </div>
</div>
</body>
</html>

