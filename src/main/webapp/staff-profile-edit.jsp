<%--
  Created by IntelliJ IDEA.
  User: dewmi
  Date: 9/30/2025
  Time: 2:01 PM
  To change this template use File | Settings | File Templates.
--%>
<%--
  File: staff-profile-edit.jsp
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- ========== 1) Read session + guard page access ========== --%>
<%
  // Context path so links and assets work no matter where the app is deployed (e.g., /wbhrs)
  String ctx        = request.getContextPath();

  // Values placed in session at login time
  String firstName  = (String) session.getAttribute("staffFirstName");
  String lastName   = (String) session.getAttribute("staffLastName");
  String staffType  = (String) session.getAttribute("staffType");   // e.g., FRONT_DESK / MARKETING / MANAGER / IT
  String department = (String) session.getAttribute("department");
  String phone      = (String) session.getAttribute("staffPhone");
  String email      = (String) session.getAttribute("staffEmail");

  // Simple access guard: if not logged in, redirect to sign-in
  if (staffType == null) {
    response.sendRedirect(ctx + "/staff-signin.jsp");
    return; // stop rendering this page
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <!-- Meta + fonts + icons (client-visible) -->
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Edit Profile – Staff</title>

  <!-- Typography + Icons -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- Page-specific CSS (versioned with ?v=1 to help cache refresh) -->
  <link rel="stylesheet" href="<%=ctx%>/assets/css/profile-edit.css?v=1">
</head>
<body>
<div class="staff-layout"><!-- Overall 2-column layout: sidebar + main -->

  <!-- ========== 2) Sidebar (logo, nav, mini profile, logout) ========== -->
  <aside class="sidebar">
    <div class="sidebar-header">
      <!-- Logo links back to dashboard -->
      <a href="staff-dashboard.jsp" class="logo-container">
        <img src="assets/images/logo2.png" alt="93 Hotel Reservation" class="logo">
      </a>
    </div>

    <!-- Minimal nav for the edit page -->
    <nav class="sidebar-nav">
      <ul class="nav-list">
        <li class="nav-item">
          <a href="staff-dashboard.jsp" class="nav-link">
            <i class="fas fa-building"></i><span>Dashboard</span>
            <i class="fas fa-chevron-right nav-arrow"></i>
          </a>
        </li>
        <li class="nav-item">
          <a href="staff-profile.jsp" class="nav-link">
            <i class="fa-solid fa-user"></i><span>My Profile</span>
            <i class="fas fa-chevron-right nav-arrow"></i>
          </a>
        </li>
      </ul>
    </nav>

    <div class="sidebar-footer">
      <!-- Mini profile card; ?v=timestamp cache-busts the avatar after update -->
      <div class="staff-profile">
        <a href="staff-profile.jsp" class="profile-link active">
          <div class="profile-image">
            <img src="<%=ctx%>/staff/avatar?v=<%=System.currentTimeMillis()%>" alt="Staff" id="sidebarProfileImage">
          </div>
          <div class="profile-info">
            <h4 class="profile-name"><%= firstName==null?"":firstName %> <%= lastName==null?"":lastName %></h4>
            <p class="profile-role">Staff</p> <%-- could print staffType if desired --%>
          </div>
          <i class="fas fa-chevron-right profile-arrow"></i>
        </a>
      </div>

      <!-- Logout via servlet that invalidates session -->
      <a href="staff-signin.jsp" class="logout-btn">
        <i class="fas fa-sign-out-alt"></i><span>Logout</span>
      </a>
    </div>
  </aside>

  <!-- ========== 3) Main content (profile edit + password change) ========== -->
  <main class="main-content">
    <header class="content-header">
      <!-- Friendly greeting (falls back to 'there' if firstName missing) -->
      <h2 class="greeting">Hello <%= firstName==null?"there":firstName %>,</h2>
    </header>

    <div class="content-container" id="profile-edit-page">
      <h1 class="page-title">Profile</h1>

      <div class="profile-container">
        <!-- ===== Card: Profile details form ===== -->
        <div class="card profile-card">
          <div class="profile-content">
            <!-- Left: current profile picture -->
            <div class="profile-image-container">
              <div class="profile-image-wrapper">
                <!-- Same cache-busting trick for main avatar -->
                <img src="<%=ctx%>/staff/avatar?v=<%=System.currentTimeMillis()%>" alt="Profile">
              </div>
            </div>

            <!-- Right: editable info -->
            <div class="profile-info-container">
              <%-- The same servlet handles both "save" and "changePassword" using the 'action' field --%>
              <form action="StaffUpdateServlet" method="post" enctype="multipart/form-data" class="profile-form">
                <h2 class="section-title">Profile Information</h2>

                <!-- Text inputs are prefilled from session values -->
                <div class="form-group">
                  <label>First Name</label>
                  <input class="form-control" type="text" name="firstname" value="<%= firstName==null? "": firstName %>" required>
                </div>

                <div class="form-group">
                  <label>Last Name</label>
                  <input class="form-control" type="text" name="lastname" value="<%= lastName==null? "": lastName %>" required>
                </div>

                <div class="form-group">
                  <label>Phone</label>
                  <input class="form-control" type="tel" name="phone" value="<%= phone==null? "": phone %>" placeholder="+94 xx xxx xxxx">
                </div>

                <div class="form-group">
                  <label>Email</label>
                  <input class="form-control" type="email" name="email" value="<%= email==null? "": email %>" required>
                </div>

                <!-- Read-only information (not editable here) -->
                <div class="info-group">
                  <label>Department</label>
                  <p><%= department!=null && !department.isEmpty()? department: "-" %></p>
                </div>
                <div class="info-group">
                  <label>Role</label>
                  <p><%= staffType %></p>
                </div>

                <!-- File input requires enctype="multipart/form-data" -->
                <div class="form-group">
                  <label class="form-label">Update Profile Picture</label>
                  <input class="form-control" type="file" name="profilePic" accept="image/*">
                </div>

                <!-- Buttons: Cancel goes back; Save submits with action=save -->
                <div class="profile-actions">
                  <a href="staff-profile.jsp" class="btn btn-secondary"><i class="fa fa-arrow-left"></i> Cancel</a>
                  <button type="submit" name="action" value="save" class="btn btn-primary">
                    <i class="fa fa-save"></i> Save Changes
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>

        <!-- ===== Card: Password change form (separate POST) ===== -->
        <div class="card password-card">
          <h2 class="section-title">Change Password</h2>

          <%-- Same servlet, different intent via name="action" value="changePassword" --%>
          <form action="StaffUpdateServlet" method="post">
            <div class="form-group">
              <label>Password</label>
              <input class="form-control" type="password" name="password" minlength="6" required>
            </div>
            <div class="form-group">
              <label>Confirm Password</label>
              <input class="form-control" type="password" name="confirmPassword" minlength="6" required>
            </div>

            <!-- Single action button for password update -->
            <button type="submit" name="action" value="changePassword" class="btn btn-primary btn-block">
              Update Password
            </button>
          </form>
        </div>
      </div>
    </div>

    <!-- Coursework footer text -->
    <footer class="content-footer">
      <p>Copyright 2025 © 93 Hotel Reservation | Year 2 Semester 1 | Group 93</p>
    </footer>
  </main>
</div>
</body>
</html>

