<%--
  Created by IntelliJ IDEA.
  User: dewmi
  Date: 9/30/2025
  Time: 2:00 PM
  To change this template use File | Settings | File Templates.
--%>
<%--
  File: staff-profile.jsp
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- ========= 1) Read session + access guard ========= --%>
<%
  // Base path of the webapp (helps links work even if deployed under a context, e.g., /wbhrs)
  String ctx        = request.getContextPath();

  // These values are put into the session at login
  String firstName  = (String) session.getAttribute("staffFirstName");
  String lastName   = (String) session.getAttribute("staffLastName");
  String staffType  = (String) session.getAttribute("staffType");   // e.g., FRONT_DESK / MARKETING / MANAGER / IT
  String department = (String) session.getAttribute("department");  // optional

  // Optional profile fields
  String phone      = (String) session.getAttribute("staffPhone");
  String email      = (String) session.getAttribute("staffEmail");

  // Safe full name builder (handles null/empty parts)
  String fullName = ((firstName != null) ? firstName : "")
          + ((lastName != null && !lastName.isEmpty()) ? " " + lastName : "");

  // Convenience flag for role checks
  boolean isIT = "IT".equals(staffType);

  // If not logged in, redirect to sign in and STOP rendering this page
  if (staffType == null) {
    response.sendRedirect(ctx + "/staff-signin.jsp");
    return;
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <!-- Meta + fonts + icons (client-side; visible in page source) -->
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Staff Profile </title>

  <!-- Google Fonts for consistent typography -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <!-- Font Awesome for icons -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- Page-specific stylesheet (kept separate from dashboard CSS) -->
  <link rel="stylesheet" href="<%=ctx%>/assets/css/profile.css">
</head>
<body>

<!-- ========= 2) App layout: Sidebar (left) + Main (right) ========= -->
<div class="staff-layout">

  <!-- ===== Sidebar: logo, nav, mini-profile, logout ===== -->
  <aside class="sidebar">
    <div class="sidebar-header">
      <!-- Logo links back to staff dashboard -->
      <a href="staff-dashboard.jsp" class="logo-container">
        <img src="assets/images/logo2.png" alt="93 hotel reservation" class="logo">
      </a>
    </div>

    <!-- Main navigation (kept minimal on profile page) -->
    <nav class="sidebar-nav">
      <ul class="nav-list">
        <li class="nav-item">
          <a href="staff-dashboard.jsp" class="nav-link">
            <i class="fas fa-building"></i>
            <span>Dashboard</span>
            <i class="fas fa-chevron-right nav-arrow"></i>
          </a>
        </li>

        <!-- Current page link (Profile) -->
        <li class="nav-item">
          <a href="staff-profile.jsp" class="nav-link">
            <i class="fa-solid fa-comments"></i>
            <span>My Profile</span>
            <i class="fas fa-chevron-right nav-arrow"></i>
          </a>
        </li>
      </ul>
    </nav>

    <div class="sidebar-footer">
      <!-- Mini profile card. Cache-busting query (?v=timestamp) forces latest avatar after update -->
      <div class="staff-profile">
        <a href="staff-profile.jsp" class="profile-link active">
          <div class="profile-image">
            <img src="<%=ctx%>/staff/avatar?v=<%=System.currentTimeMillis()%>" alt="Staff" id="sidebarProfileImage">
          </div>
          <div class="profile-info">
            <h4 class="profile-name" id="sidebarProfileName"><%= firstName  %> <%= lastName %></h4>
            <p class="profile-role">Staff</p> <%-- You could print staffType here if you prefer --%>
          </div>
          <i class="fas fa-chevron-right profile-arrow"></i>
        </a>
      </div>

      <!-- Logout link: goes to servlet that invalidates session and redirects -->
      <a href="staff-signin.jsp" class="logout-btn">
        <i class="fas fa-sign-out-alt"></i>
        <span>Logout</span>
      </a>
    </div>
  </aside>

  <!-- ===== Main content area ===== -->
  <main class="main-content">
    <!-- Greeting (simple header) -->
    <header class="content-header">
      <h2 class="greeting">Hello <%= firstName  %>,</h2>
    </header>

    <!-- Centered content container -->
    <div class="content-container">
      <h1 class="page-title">Profile</h1>

      <!-- Card wrapper for the profile section -->
      <div class="profile-container">
        <div class="card profile-card">
          <div class="profile-content">

            <!-- Left: profile picture -->
            <div class="profile-image-container">
              <div class="profile-image-wrapper">
                <!-- Same cache-busting trick for the main profile image -->
                <img src="<%=ctx%>/staff/avatar?v=<%=System.currentTimeMillis()%>" alt="Profile" id="profileImage">
              </div>
            </div>

            <!-- Right: profile information -->
            <div class="profile-info-container">
              <h2 class="section-title">Profile Information</h2>

              <!-- Read-only view (Edit button goes to edit page) -->
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
                  <!-- Show "-" if not provided -->
                  <p id="phone"><%= (phone != null && !phone.isEmpty() ? phone : "-") %></p>
                </div>

                <div class="info-group">
                  <label>Email</label>
                  <!-- Show "-" if not provided -->
                  <p id="email"><%= (email != null && !email.isEmpty() ? email : "-") %></p>
                </div>

                <div class="info-group">
                  <label>Department</label>
                  <p id="department"><%= (department != null && !department.isEmpty() ? department : "-") %></p>
                </div>

                <div class="info-group">
                  <label>Role</label>
                  <p id="role"><%= staffType %></p>
                </div>

                <!-- Edit navigates to a separate JSP that allows updating fields -->
                <div class="profile-actions">
                  <a href="<%=ctx%>/staff-profile-edit.jsp" class="btn btn-secondary">
                    <i class="fas fa-edit"></i> Edit Profile
                  </a>
                </div>
              </div><!-- /profile-info-view -->
            </div><!-- /profile-info-container -->

          </div><!-- /profile-content -->
        </div><!-- /card -->
      </div><!-- /profile-container -->
    </div><!-- /content-container -->

    <!-- Footer (static text for the coursework footer requirement) -->
    <footer class="content-footer">
      <p>Copyright 2025 © 93 Hotel Reservation | Year 2 Semester 1 | Group 93</p>
    </footer>
  </main>
</div>

</body>
</html>

