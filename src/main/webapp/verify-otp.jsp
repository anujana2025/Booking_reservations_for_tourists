<%@ page isErrorPage="true" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.*" %>
<%
    String ctx = request.getContextPath();

    // read actor
    String actor = request.getParameter("actor");
    if (actor == null || actor.isBlank()) actor = (String) session.getAttribute("actor");
    if (actor == null || !(actor.equalsIgnoreCase("staff") || actor.equalsIgnoreCase("tourist"))) actor = "staff";
    session.setAttribute("actor", actor);

    String roleTitle = "staff".equalsIgnoreCase(actor) ? "Staff" : "Tourist";

    // show which email we’re verifying, if you stored it in session:
    String sessEmail = (String) session.getAttribute("reset_email");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= roleTitle %> Verify OTP</title>

    <!-- Fonts & Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- (Optional) Bootstrap (alerts only) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- auth stylesheet -->
    <link rel="stylesheet" href="<%=ctx%>/assets/css/auth.css"><!-- fixed path -->
</head>
<body>

<div class="auth-container">
    <div class="auth-image"></div>

    <div class="auth-form-container muted center">
        <div class="auth-form-content wide">

            <div class="logo-container">
                <img src="<%=ctx%>/assets/images/logo2.png" alt="Logo" class="logo">
            </div>
            <h1>Verify OTP</h1>
            <p class="subtitle">
                Enter the 6-digit code sent to your email
                <% if (sessEmail != null) { %> (<strong><%= sessEmail %></strong>)<% } %>.
            </p>

            <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= request.getAttribute("error") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>

            <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <%= request.getAttribute("success") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>

            <!-- OTP form -->
            <form action="<%=ctx%>/OtpServlet" method="post"><!-- added ctx -->
                <!-- carry actor -->
                <input type="hidden" name="actor" value="<%= actor %>">

                <!-- optional: single joined value the servlet can read as request.getParameter("otp") -->
                <input type="hidden" name="otp" id="otpFull">

                <div class="otp-container">
                    <% for (int i = 0; i < 6; i++) { %>
                    <input
                            type="text"
                            name="otp<%= i %>"
                            class="otp-input"
                            inputmode="numeric"
                            autocomplete="one-time-code"
                            pattern="[0-9]"      <%-- exact: a single digit --%>
                            maxlength="1"
                            required
                    >
                    <% } %>
                </div>

                <div class="resend-container">
                    <span id="otpTimer">You can resend a new code in 60s</span>
                    <button type="button" class="resend-btn" id="resendBtn"
                            onclick="location.href='<%=ctx%>/ResendOtpServlet?actor=<%=actor%>'" disabled>
                        Resend Code
                    </button>
                </div>

                <button type="submit" class="btn-primary">Verify</button>
            </form>

            <!-- Back keeps actor -->
            <a href="<%=ctx%>/forgot-password.jsp?actor=<%=actor%>" class="back-link">
                <i class="fas fa-arrow-left"></i> Back
            </a>
        </div>

        <div class="auth-footer">
            © <%= java.time.Year.now() %> Copyright 93 Hotel Reservation | Year 2 Semester 1 | Group 93
        </div>
    </div>
</div>

<script>
    (function () {
        const btn = document.getElementById('resendBtn');
        const timerEl = document.getElementById('otpTimer');
        if (btn && timerEl) {
            let secs = 60;
            const tick = () => {
                if (secs <= 0) { timerEl.textContent = 'You can request a new code now.'; btn.disabled = false; return; }
                timerEl.textContent = 'You can resend a new code in ' + secs + 's';
                secs -= 1; setTimeout(tick, 1000);
            };
            tick();
        }

        // auto-advance + sanitize digits
        const inputs = Array.from(document.querySelectorAll('.otp-input'));
        const form   = document.getElementById('otpForm');
        const hidden = document.getElementById('otpFull');

        // sanitize + auto-advance
        inputs.forEach((inp, i) => {
            inp.addEventListener('input', () => {
                inp.value = (inp.value || '').replace(/\D/g,'').slice(0,1);
                if (inp.value && i < inputs.length - 1) inputs[i+1].focus();
            });
            inp.addEventListener('keydown', (e) => {
                if (e.key === 'Backspace' && !inp.value && i > 0) inputs[i-1].focus();
            });
        });

        // join into hidden before submit so the servlet can read request.getParameter("otp")
        form.addEventListener('submit', () => {
            hidden.value = inputs.map(x => x.value || '').join('');
        });
    })();
</script>
</body>
</html>
