<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Session attributes for authentication
    String staffId   = (String) session.getAttribute("staffId");
    String staffName = (String) session.getAttribute("staffName");
    String staffType = (String) session.getAttribute("staffType"); // FRONTDESK / MANAGER / MARKETING / IT
    Object touristIdObj = session.getAttribute("touristId");
    String touristName  = (String) session.getAttribute("touristName");
    boolean isTouristLoggedIn = (touristIdObj != null);
    boolean isStaffLoggedIn   = (staffId != null);
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Serenity Haven | Web Hotel Reservation System</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />

    <!-- Custom CSS -->
    <style>
        :root {
            --primary: #4361ee;
            --primary-dark: #3a56d4;
            --dark: #1a1a2e;
            --light: #f8f9fa;
            --hover-bg: rgba(67, 97, 238, 0.1);
            --border-radius: 8px;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            color: var(--dark);
            background-color: var(--light);
            line-height: 1.6;
        }

        .container {
            width: 90%;
            max-width: 1200px;
            margin: 0 auto;
        }

        .btn {
            display: inline-block;
            background: var(--primary);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-weight: 600;
            font-size: 16px;
            text-decoration: none;
            transition: background 0.3s;
        }

        .btn:hover {
            background: var(--primary-dark);
        }

        .btn-outline-secondary {
            background: transparent;
            color: var(--dark);
            border: 1px solid var(--dark);
        }

        .btn-outline-secondary:hover {
            background: var(--hover-bg);
        }

        .navbar {
            background-color: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .navbar-brand {
            font-size: 28px;
            font-weight: 700;
            color: var(--dark);
        }

        .navbar-brand span {
            color: var(--primary);
        }

        .hero {
            background: linear-gradient(rgba(0,0,0,0.5), rgba(0,0,0,0.5)), url("https://images.squarespace-cdn.com/content/v1/52c9f4ebe4b02c7007cdd86a/1648474902671-WN34L2FUABNAONJ9RX4V/juvet.jpg");
            background-size: cover;
            background-position: center;
            height: 70vh;
            display: flex;
            align-items: center;
            color: white;
            text-align: center;
        }

        .hero-content {
            max-width: 800px;
            margin: 0 auto;
        }

        .hero h1 {
            font-size: 48px;
            margin-bottom: 20px;
        }

        .hero p {
            font-size: 18px;
            margin-bottom: 30px;
        }

        .featured {
            padding: 80px 0;
        }

        .section-title {
            text-align: center;
            margin-bottom: 50px;
        }

        .section-title h2 {
            font-size: 36px;
            color: var(--dark);
            margin-bottom: 15px;
        }

        .section-title p {
            color: #7f8c8d;
            max-width: 700px;
            margin: 0 auto;
        }

        .rooms-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 30px;
        }

        .room-card {
            border-radius: var(--border-radius);
            overflow: hidden;
            box-shadow: 0 3px 10px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }

        .room-card:hover {
            transform: translateY(-5px);
        }

        .room-img {
            height: 250px;
            overflow: hidden;
        }

        .room-img img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.5s;
        }

        .room-card:hover .room-img img {
            transform: scale(1.05);
        }

        .room-info {
            padding: 20px;
        }

        .price {
            font-size: 22px;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 10px;
        }

        .address {
            color: #7f8c8d;
            margin-bottom: 15px;
        }

        .features {
            display: flex;
            justify-content: space-between;
            border-top: 1px solid #eee;
            padding-top: 15px;
            margin-top: 15px;
        }

        .feature {
            text-align: center;
        }

        .feature span {
            display: block;
            color: #7f8c8d;
            font-size: 14px;
        }

        .feature i {
            color: var(--primary);
            margin-bottom: 5px;
        }

        footer {
            padding: 20px 0;
            border-top: 1px solid #eee;
            text-align: center;
            color: #7f8c8d;
            font-size: 14px;
        }
    </style>
</head>
<body>
<!-- Navbar -->
<nav class="navbar navbar-expand-lg">
    <div class="container">
        <a class="navbar-brand" href="<%=ctx%>/index.jsp">Serenity <span>Haven</span></a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#navbarNav" aria-controls="navbarNav"
                aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggl
er-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-lg-center">
                <% if (!isTouristLoggedIn && !isStaffLoggedIn) { %>
                <!-- Not logged in: show both portals -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" role="button"
                       data-bs-toggle="dropdown" aria-expanded="false">
                        Tourist
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="<%=ctx%>/tourist-signin.jsp">Login</a></li>
                        <li><a class="dropdown-item" href="<%=ctx%>/tourist-signup.jsp">Sign Up</a></li>
                    </ul>
                </li>
                <li class="nav-item dropdown ms-lg-2">
                    <a class="nav-link dropdown-toggle" href="#" role="button"
                       data-bs-toggle="dropdown" aria-expanded="false">
                        Staff
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="<%=ctx%>/staff-signin.jsp">Login</a></li>
                        <li><a class="dropdown-item" href="<%=ctx%>/staff-signup.jsp">Register</a></li>
                    </ul>
                </li>
                <% } %>
                <% if (isTouristLoggedIn) { %>
                <!-- Tourist logged in -->
                <li class="nav-item">
                    <a class="nav-link" href="<%=ctx%>/tourist/reservations.jsp">My Reservations</a>
                </li>
                <li class="nav-item ms-lg-2">
                    <a class="nav-link" href="<%=ctx%>/tourist/profile.jsp">Hi, <%= (touristName!=null?touristName:"Tourist") %></a>
                </li>
                <li class="nav-item ms-lg-2">
                    <a class="btn btn-outline-danger btn-sm" href="<%=ctx%>/logout">Logout</a>
                </li>
                <% } %>
                <% if (isStaffLoggedIn) { %>
                <!-- Staff logged in -->
                <li class="nav-item">
                    <a class="nav-link" href="<%=ctx%>/staff/dashboard">Dashboard</a>
                </li>
                <li class="nav-item ms-lg-2">
                    <a class="nav-link" href="<%=ctx%>/staff/profile">Hi, <%= (staffName!=null?staffName:"Staff") %> (<%= (staffType!=null?staffType:"") %>)</a>
                </li>
                <li class="nav-item ms-lg-2">
                    <a class="btn btn-outline-danger btn-sm" href="<%=ctx%>/logout">Logout</a>
                </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<!-- Hero Section -->
<section class="hero">
    <div class="container">
        <div class="hero-content">
            <h1>Find Your Perfect Stay Today</h1>
            <p>Discover the perfect rooms that match your lifestyle and budget within our hotel.</p>
            <% if (!isTouristLoggedIn && !isStaffLoggedIn) { %>
            <div class="d-flex flex-column flex-sm-row gap-3 justify-content-center">
                <a href="<%=ctx%>/tourist-signup.jsp" class="btn btn-lg">Get Started (Tourist)</a>
                <a href="<%=ctx%>/staff-signin.jsp" class="btn btn-outline-secondary btn-lg">Staff Portal</a>
            </div>
            <% } else if (isTouristLoggedIn) { %>
            <div class="d-flex gap-3 justify-content-center">
                <a href="<%=ctx%>/rooms/browse.jsp" class="btn btn-lg">Browse Rooms</a>
                <a href="<%=ctx%>/tourist/reservations.jsp" class="btn btn-outline-secondary btn-lg">My Reservations</a>
            </div>
            <% } else if (isStaffLoggedIn) { %>
            <div class="d-flex gap-3 justify-content-center">
                <a href="<%=ctx%>/staff/dashboard" class="btn btn-lg">Go to Dashboard</a>
                <a href="<%=ctx%>/staff/profile" class="btn btn-outline-secondary btn-lg">My Profile</a>
            </div>
            <% } %>
        </div>
    </div>
</section>

<!-- Featured Rooms -->
<section class="featured">
    <div class="container">
        <div class="section-title">
            <h2>Featured Chambers</h2>
            <p>Explore what you most like</p>
        </div>
        <div class="rooms-grid">
            <!-- Room 1 -->
            <div class="room-card">
                <div class="room-img">
                    <img src="https://scdn.aro.ie/Sites/50/imperialhotels2022/uploads/images/FullLengthImages/Small/156757411_Bedford_Hotel__Single_Room._4500x3000.jpg" alt="Single Room">
                </div>
                <div class="room-info">
                    <div class="price">$450</div>
                    <h3>Modern Single Room</h3>
                    <div class="address"></div>
                    <div class="features">
                        <div class="feature">
                            <i>🛏</i>
                            <span>1 Bed</span>
                        </div>
                        <div class="feature">
                            <i>🚿</i>
                            <span>1 Bath</span>
                        </div>
                        <div class="feature">
                            <i>📐</i>
                            <span>2,100 sqft</span>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Room 2 -->
            <div class="room-card">
                <div class="room-img">
                    <img src="https://www.shutterstock.com/image-photo/hotel-room-interior-modern-seaside-600nw-1387008533.jpg" alt="Double Bed Room">
                </div>
                <div class="room-info">
                    <div class="price">$500</div>
                    <h3>Double Bed Room</h3>
                    <div class="address"></div>
                    <div class="features">
                        <div class="feature">
                            <i>🛏</i>
                            <span>2 Beds</span>
                        </div>
                        <div class="feature">
                            <i>🚿</i>
                            <span>1 Bath</span>
                        </div>
                        <div class="feature">
                            <i>📐</i>
                            <span>1,500 sqft</span>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Room 3 -->
            <div class="room-card">
                <div class="room-img">
                    <img src="https://www.thebeacheshotel.com/wp-content/uploads/2024/04/superior-sea-view-triple-room-218-the-beaches-hotel-1366x768-fp_mm-fpoff_0_0.jpg" alt="Triple Bed Room">
                </div>
                <div class="room-info">
                    <div class="price">$600</div>
                    <h3>Triple Bed Room</h3>
                    <div class="address"></div>
                    <div class="features">
                        <div class="feature">
                            <i>🛏</i>
                            <span>3 Beds</span>
                        </div>
                        <div class="feature">
                            <i>🚿</i>
                            <span>1 Bath</span>
                        </div>
                        <div class="feature">
                            <i>📐</i>
                            <span>1,800 sqft</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Footer -->
<footer>
    <div class="container">
        © <%= java.time.Year.now() %> Serenity Haven — Web Hotel Reservation System
    </div>
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>