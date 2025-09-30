<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String ctx = request.getContextPath();

  String firstName = (String) session.getAttribute("touristFirstName");
  String lastName  = (String) session.getAttribute("touristLastName");
  String phone     = (String) session.getAttribute("touristPhone");
  String email     = (String) session.getAttribute("touristEmail");

  String fullName = ((firstName != null) ? firstName : "")
          + ((lastName != null && !lastName.isEmpty()) ? " " + lastName : "");

  if (email == null && firstName == null) {
    response.sendRedirect(ctx + "/tourist-signin.jsp");
    return;
  }
%>

<%
  String msg = (String) request.getAttribute("message");
  if (msg == null) msg = request.getParameter("m");
  String flash = (String) session.getAttribute("flash");
  if (msg == null && flash != null) { msg = flash; session.removeAttribute("flash"); }
%>
<% if (msg != null && !msg.isEmpty()) { %>
<div style="margin:12px 0;padding:12px 14px;border:1px solid #b6e0fe;background:#e8f4ff;color:#084c7f;border-radius:8px">
  <%= msg %>
</div>
<% } %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tourist Profile</title>

  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="<%=ctx%>/assets/css/profile.css">
</head>
<body>

<div class="staff-layout"><%-- shared styling --%>

  <!-- Sidebar (no avatar) -->
  <aside class="sidebar">
    <div class="sidebar-header">
      <a href="<%=ctx%>/tourist-dashboard.jsp" class="logo-container">
        <img src="<%=ctx%>/assets/images/logo2.png" alt="93 hotel reservation" class="logo">
      </a>
    </div>

    <nav class="sidebar-nav">
      <ul class="nav-list">
        <li class="nav-item">
          <a href="<%=ctx%>/tourist-dashboard.jsp" class="nav-link">
            <i class="fas fa-building"></i>
            <span>Dashboard</span>
            <i class="fas fa-chevron-right nav-arrow"></i>
          </a>
        </li>
        <li class="nav-item">
          <a href="<%=ctx%>/tourist-profile.jsp" class="nav-link">
            <i class="fa-solid fa-comments"></i>
            <span>My Profile</span>
            <i class="fas fa-chevron-right nav-arrow"></i>
          </a>
        </li>
      </ul>
    </nav>

    <div class="sidebar-footer">
      <div class="staff-profile">
        <a href="<%=ctx%>/tourist-profile.jsp" class="profile-link active">
          <div class="profile-info">
            <h4 class="profile-name" id="sidebarProfileName"><%= fullName %></h4>
            <p class="profile-role">Tourist</p>
          </div>
          <i class="fas fa-chevron-right profile-arrow"></i>
        </a>
      </div>

      <a href="<%=ctx%>/tourist-signin.jsp" class="logout-btn">
        <i class="fas fa-sign-out-alt"></i>
        <span>Logout</span>
      </a>
    </div>
  </aside>

  <!-- Main content (no image, no "Member Since") -->
  <main class="main-content">
    <header class="content-header">
      <h2 class="greeting">Hello <%= (firstName != null ? firstName : "Tourist") %>,</h2>
    </header>

    <div class="content-container">
      <h1 class="page-title">Profile</h1>

      <div class="profile-container">
        <div class="card profile-card">
          <div class="profile-content">
            <div class="profile-info-container full-width">
              <h2 class="section-title">Profile Information</h2>

              <div class="profile-info-view" id="profileInfoView">
                <div class="info-group">
                  <label>First Name</label>
                  <p id="firstname"><%= (firstName != null ? firstName : "") %></p>
                </div>

                <div class="info-group">
                  <label>Last Name</label>
                  <p id="lastname"><%= (lastName != null ? lastName : "") %></p>
                </div>

                <div class="info-group">
                  <label>Phone</label>
                  <p id="phone"><%= (phone != null && !phone.isEmpty() ? phone : "-") %></p>
                </div>

                <div class="info-group">
                  <label>Email</label>
                  <p id="email"><%= (email != null && !email.isEmpty() ? email : "-") %></p>
                </div>

                <div class="profile-actions">
                  <a href="<%=ctx%>/tourist-profile-edit.jsp" class="btn btn-secondary">
                    <i class="fas fa-edit"></i> Edit Profile
                  </a>
                </div>
              </div><!-- /profile-info-view -->
            </div><!-- /profile-info-container -->
          </div><!-- /profile-content -->
        </div><!-- /card -->
      </div><!-- /profile-container -->
    </div><!-- /content-container -->

    <footer class="content-footer">
      <p>Copyright 2025 © 93 Hotel Reservation | Year 2 Semester 1 | Group 93</p>
    </footer>
  </main>
</div>

</body>
</html>
