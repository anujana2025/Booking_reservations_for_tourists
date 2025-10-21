<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String id  = request.getParameter("id");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"/>
    <title>Reservation Confirmed</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
</head>
<body class="bg-light">
<div class="container py-5" style="max-width:720px;">
    <div class="card shadow-sm p-4">
        <h3 class="mb-3">Thank you! 🎉</h3>
        <p>Your reservation has been created successfully.</p>
        <p class="mb-4">Reservation ID: <strong>#<%= (id!=null ? id : "-") %></strong></p>

        <a class="btn btn-primary" href="<%=ctx%>/dashboard.jsp">Go to Dashboard</a>
        <br>
        <a class="btn btn-outline-secondary ms-2" href="<%=ctx%>/">Back to Home</a>
    </div>
</div>
</body>
</html>
