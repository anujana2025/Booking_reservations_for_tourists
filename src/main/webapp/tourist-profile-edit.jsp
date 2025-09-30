<%--
  File: tourist-profile-edit.jsp
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
  String ctx = request.getContextPath();

  // Values placed in session at tourist sign-in
  String firstName = (String) session.getAttribute("touristFirstName");
  String lastName  = (String) session.getAttribute("touristLastName");
  String phone     = (String) session.getAttribute("touristPhone");
  String email     = (String) session.getAttribute("touristEmail");

  // Simple access guard: if not logged in, redirect to sign-in
  if (email == null && firstName == null) {
    response.sendRedirect(ctx + "/tourist-signin.jsp");
    return; // stop rendering this page
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Edit Profile – Tourist</title>

  <!-- Fonts & Icons -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- Page CSS -->
  <link rel="stylesheet" href="<%=ctx%>/assets/css/profile-edit.css?v=1">
</head>
<body>
<div class="staff-layout"><!-- Overall 2-column layout: sidebar + main -->

  <!-- ========== Sidebar ========== -->
  <aside class="sidebar">
    <div class="sidebar-header">
      <a href="tourist-dashboard.jsp" class="logo-container">
        <img src="assets/images/logo2.png" alt="93 Hotel Reservation" class="logo">
      </a>
    </div>

    <nav class="sidebar-nav">
      <ul class="nav-list">
        <li class="nav-item">
          <a href="tourist-dashboard.jsp" class="nav-link">
            <i class="fas fa-building"></i><span>Dashboard</span>
            <i class="fas fa-chevron-right nav-arrow"></i>
          </a>
        </li>
        <li class="nav-item">
          <a href="tourist-profile.jsp" class="nav-link">
            <i class="fa-solid fa-user"></i><span>My Profile</span>
            <i class="fas fa-chevron-right nav-arrow"></i>
          </a>
        </li>
      </ul>
    </nav>

    <div class="sidebar-footer">
      <!-- Mini profile card (no avatar) -->
      <div class="staff-profile">
        <a href="tourist-profile.jsp" class="profile-link active">
          <div class="profile-info">
            <h4 class="profile-name"><%= firstName==null?"":firstName %> <%= lastName==null?"":lastName %></h4>
            <p class="profile-role">Tourist</p>
          </div>
          <i class="fas fa-chevron-right profile-arrow"></i>
        </a>
      </div>

      <!-- Logout -->
      <a href="tourist-signin.jsp" class="logout-btn">
        <i class="fas fa-sign-out-alt"></i><span>Logout</span>
      </a>
    </div>
  </aside>

  <!-- ========== Main content ========== -->
  <main class="main-content">
    <header class="content-header">
      <h2 class="greeting">Hello <%= firstName==null?"there":firstName %>,</h2>
    </header>

    <div class="content-container" id="profile-edit-page">

      <%
        String msg = (String) request.getAttribute("message"); // set via req.setAttribute(...) + forward
        if (msg == null) msg = request.getParameter("m");      // set via ...?m=Your+message (redirect)
        String flash = (String) session.getAttribute("flash"); // set via session.setAttribute("flash", ...)
        if (msg == null && flash != null) {
          msg = flash;
          session.removeAttribute("flash");
        }
      %>
      <% if (msg != null && !msg.isEmpty()) { %>
      <div style="
      margin: 12px 0;
      padding: 12px 14px;
      border: 1px solid #b6e0fe;
      background: #e8f4ff;
      color: #084c7f;
      border-radius: 8px;
      font: 500 14px/1.4 'Poppins', system-ui, -apple-system, Segoe UI, Roboto, Arial;
    ">
        <%= msg %>
      </div>
      <% } %>

      <h1 class="page-title">Profile</h1>

      <div class="profile-container">
        <!-- ===== Card: Profile details form (no image, no member since) ===== -->
        <div class="card profile-card">
          <div class="profile-content">

            <!-- Right: editable info only (stretch full width) -->
            <div class="profile-info-container full-width">
              <%-- Uses TouristUpdateServlet (no file upload now) --%>
              <form action="TouristUpdateServlet" method="post" class="profile-form">
                <h2 class="section-title">Profile Information</h2>

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

                <!-- Role (read-only, kept for layout consistency) -->
                <div class="info-group">
                  <label>Role</label>
                  <p>Tourist</p>
                </div>

                <!-- Actions -->
                <div class="profile-actions">
                  <a href="tourist-profile.jsp" class="btn btn-secondary">
                    <i class="fa fa-arrow-left"></i> Cancel
                  </a>

                  <button type="submit" name="action" value="delete"
                          class="btn btn-danger"
                          onclick="return confirm('Delete your account? This cannot be undone.');">
                    <i class="fa fa-trash"></i> Delete
                  </button>

                  <button type="submit" name="action" value="save" class="btn btn-primary">
                    <i class="fa fa-save"></i> Save
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>

        <!-- ===== Card: Password change form ===== -->
        <div class="card password-card">
          <h2 class="section-title">Change Password</h2>

          <form action="TouristUpdateServlet" method="post">
            <div class="form-group">
              <label>Password</label>
              <input class="form-control" type="password" name="password" minlength="6" required>
            </div>
            <div class="form-group">
              <label>Confirm Password</label>
              <input class="form-control" type="password" name="confirmPassword" minlength="6" required>
            </div>

            <button type="submit" name="action" value="changePassword" class="btn btn-primary btn-block">
              Update Password
            </button>
          </form>
        </div>
      </div>
    </div>

    <footer class="content-footer">
      <p>Copyright 2025 © 93 Hotel Reservation | Year 2 Semester 1 | Group 93</p>
    </footer>
  </main>
</div>

</body>
</html>


