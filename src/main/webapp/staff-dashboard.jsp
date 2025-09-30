<%--
  Created by IntelliJ IDEA.
  User: dewmi
  Date: 9/30/2025
  Time: 2:00 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- =========================
     1) Read session data and guard access
     ========================= --%>
<%
  // App base path like "/wbhrs" so links work even if app is not at server root
  String ctx        = request.getContextPath();

  // These come from session attributes set at login time
  String firstName  = (String) session.getAttribute("staffFirstName");
  String lastName   = (String) session.getAttribute("staffLastName");
  String staffType  = (String) session.getAttribute("staffType");   // e.g. FRONT_DESK / MARKETING / MANAGER / IT
  String department = (String) session.getAttribute("department");  // optional

  // Build a nice display name even if last name is missing
  String fullName = ((firstName != null) ? firstName : "")
          + ((lastName  != null && !lastName.isEmpty()) ? " " + lastName : "");


  // If user is not logged in (no staffType in session), send to sign-in page
  if (staffType == null) {
    response.sendRedirect(ctx + "/staff-signin.jsp");
    return; // stop rendering this page
  }
  String staffTypeDisplay = staffType.replace('_',' ');
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Staff Dashboard</title>

  <!-- Google font + icons + our page CSS -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <link rel="stylesheet" href="<%=ctx%>/assets/css/staff-dashboard.css">
</head>
<body>

<div class="layout"><!-- Main 2-column layout: sidebar (left) + main content (right) -->

  <!-- =========================
       2) Sidebar (logo, nav, profile, logout)
       ========================= -->
  <aside class="sidebar">
    <div class="sidebar__header">
      <!-- Project logo -->
      <img src="<%=ctx%>/assets/images/logo2.png" alt="Logo" class="logo">
    </div>

    <div class="sidebar__nav">
      <!-- Role-aware navigation. Items appear based on staffType -->
      <ul class="nav">
        <!-- Always visible -->
        <li>
          <a class="nav__link" href="<%=ctx%>/staff-dashboard.jsp">
            <i class="fa-solid fa-gauge-high"></i><span>Dashboard</span>
          </a>
        </li>

        <%-- FRONT_DESK or MANAGER see Reservations and Room Availability --%>
        <% if ("FRONT_DESK".equals(staffType) || "MANAGER".equals(staffType)) { %>
        <li>
          <a class="nav__link" href="<%=ctx%>/reservations.jsp">
            <i class="fa-solid fa-calendar-check"></i><span>Reservations</span>
          </a>
        </li>
        <li>
          <a class="nav__link" href="<%=ctx%>/rooms.jsp">
            <i class="fa-solid fa-bed"></i><span>Room Availability</span>
          </a>
        </li>

        <li>
          <a class="nav__link" href="<%=ctx%>/rooms.jsp">
            <i class="fa-solid fa-bed"></i><span>FAQ n Reviews</span>
          </a>
        </li>
        <% } %>

        <%-- MARKETING or MANAGER see Promotions --%>
        <% if ("MARKETING".equals(staffType) || "MANAGER".equals(staffType)) { %>
        <li>
          <a class="nav__link" href="<%=ctx%>/promotions.jsp">
            <i class="fa-solid fa-bullhorn"></i><span>Promotions</span>
          </a>
        </li>
        <% } %>

        <%-- Only MANAGER sees Reports --%>
        <% if ("MANAGER".equals(staffType)) { %>
        <li>
          <a class="nav__link" href="<%=ctx%>/reports.jsp">
            <i class="fa-solid fa-chart-line"></i><span>Reports</span>
          </a>
        </li>
        <% } %>

        <%-- Only IT sees IT Tools --%>
        <% if ("IT".equals(staffType)) { %>
        <li>
          <a class="nav__link" href="<%=ctx%>/staff-admin.jsp">
            <i class="fa-solid fa-users-gear"></i><span>IT Tools</span>
          </a>
        </li>
        <% } %>

        <!-- Everyone can view their own profile -->
        <li>
          <a class="nav__link" href="<%=ctx%>/staff-profile.jsp">
            <i class="fa-regular fa-user"></i><span>My Profile</span>
          </a>
        </li>
      </ul>
    </div>

    <div class="sidebar__footer">
      <!-- Mini profile card (click to open full profile) -->
      <a href="<%=ctx%>/staff-profile.jsp" class="me-card">
        <div class="me-card__avatar">
          <!-- Cache-buster query (?v=time) ensures updated avatar shows immediately -->
          <img src="<%=ctx%>/staff/avatar?v=<%=System.currentTimeMillis()%>" alt="Staff" id="sidebarProfileImage">
        </div>
        <div>
          <div class="me-card__name"><%= (firstName!=null?firstName:"") %> <%= (lastName!=null?lastName:"") %></div>
          <div class="me-card__role"><%= staffTypeDisplay %></div>
        </div>
      </a>

      <!-- Logout goes to a servlet that clears session and redirects -->
      <a href="staff-signin.jsp" class="logout">
        <i class="fa-solid fa-right-from-bracket"></i>Logout
      </a>
    </div>
  </aside>

  <!-- =========================
       3) Main content area
       ========================= -->
  <main class="main">
    <!-- Top bar with greeting + role pill -->
    <div class="main__header">
      <h2 class="greet">Hello <%= (firstName!=null?firstName:"") %> 👋</h2>
      <span class="pill">
                <i class="fa-solid fa-user-tag"></i> <%= staffTypeDisplay %>
            </span>
    </div>

    <!-- Centered page content container -->
    <div class="container">
      <!-- Intro block -->
      <section class="page-intro">
        <h2>Welcome to <%= staffTypeDisplay %> staff Dashboard</h2>
        <p>Use the sidebar to navigate to tools or open your profile.</p>
      </section>

      <!-- Quick access cards; each block is shown only for allowed roles -->
      <div class="cards">
        <% if ("FRONT_DESK".equals(staffType) || "MANAGER".equals(staffType)) { %>
        <a href="<%=ctx%>/reservations.jsp" class="card">
          <i class="fa-solid fa-calendar-check"></i>
          <div>
            <h3>Reservations</h3>
            <p>View and manage upcoming reservations</p>
          </div>
        </a>

        <a href="<%=ctx%>/rooms.jsp" class="card">
          <i class="fa-solid fa-bed"></i>
          <div>
            <h3>Room Availability</h3>
            <p>Check room status and assign rooms</p>
          </div>
        </a>

        <a href="<%=ctx%>/rooms.jsp" class="card">
          <i class="fa-solid fa-bed"></i>
          <div>
            <h3>FAQ & Reviews</h3>
            <p>Check room status and assign rooms</p>
          </div>
        </a>
        <% } %>

        <% if ("MARKETING".equals(staffType) || "MANAGER".equals(staffType)) { %>
        <a href="<%=ctx%>/promotions.jsp" class="card">
          <i class="fa-solid fa-bullhorn"></i>
          <div>
            <h3>Promotions</h3>
            <p>Create and manage campaigns</p>
          </div>
        </a>
        <% } %>

        <% if ("MANAGER".equals(staffType)) { %>
        <a href="<%=ctx%>/reports.jsp" class="card">
          <i class="fa-solid fa-chart-line"></i>
          <div>
            <h3>Reports</h3>
            <p>View performance and reports</p>
          </div>
        </a>
        <% } %>

        <% if ("IT".equals(staffType)) { %>
        <a href="<%=ctx%>/staff-admin.jsp" class="card">
          <i class="fa-solid fa-users-gear"></i>
          <div>
            <h3>IT Tools</h3>
            <p>Manage staff accounts and roles</p>
          </div>
        </a>
        <% } %>
      </div>
    </div>

    <!-- Footer stays at bottom of main area -->
    <footer class="main__footer">
      Copyright 2025 © 93 Hotel Reservation | Year 2 Semester 1 | Group 93
    </footer>
  </main>
</div>
</body>
</html>

