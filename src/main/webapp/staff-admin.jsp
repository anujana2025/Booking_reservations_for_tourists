<%--
  IT Tools: Staff Administration
  Requires session attribute: staffType == "IT"
  Requires request attributes:
    - staffList:   List<Staff> (from DB)
    - touristList: List<Tourist> (from DB)
  POST endpoints the page calls:
    - <ctx>/it/staff-update
    - <ctx>/it/staff-delete
    - <ctx>/it/tourist-delete
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%! // --- reflection helpers (unchanged) ---
    private String str(Object o, String... names) {
        if (o == null) return "";
        Class<?> c = o.getClass();
        for (String n : names) {
            try { var m = c.getMethod(n); Object v = m.invoke(o); return v == null ? "" : String.valueOf(v); } catch (Exception ignored) {}
            try { var f = c.getField(n);  Object v = f.get(o);    return v == null ? "" : String.valueOf(v); } catch (Exception ignored) {}
        }
        return "";
    }
    private long lng(Object o, String... names) {
        String v = str(o, names);
        try { return Long.parseLong(v); } catch (Exception e) { return -1L; }
    }
%>

<%
    String ctx        = request.getContextPath();
    String staffType  = (String) session.getAttribute("staffType");
    String firstName  = (String) session.getAttribute("staffFirstName");
    String lastName   = (String) session.getAttribute("staffLastName");

    if (staffType == null) { response.sendRedirect(ctx + "/staff-signin.jsp"); return; }
    if (!"IT".equals(staffType)) { response.sendRedirect(ctx + "/staff-dashboard.jsp?error=forbidden"); return; }

    java.util.List<?> staffList   = (java.util.List<?>) request.getAttribute("staffList");
    java.util.List<?> touristList = (java.util.List<?>) request.getAttribute("touristList");

    String ok  = request.getParameter("success");
    String err = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>IT Tools — Staff Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/staff-dashboard.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/staff-admin.css">
    <style>
        /* small widths so Email/Phone fit nicely */
        .col-id{width:72px}
        .col-actions{width:240px}
        .col-phone{white-space:nowrap}
    </style>
</head>
<body>
<div class="layout">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar__header">
            <img src="<%=ctx%>/assets/images/logo2.png" alt="Logo" class="logo">
        </div>
        <div class="sidebar__nav">
            <ul class="nav">
                <li><a class="nav__link" href="<%=ctx%>/staff-dashboard.jsp"><i class="fa-solid fa-gauge-high"></i><span>Dashboard</span></a></li>
                <li><a class="nav__link" href="<%=ctx%>/staff-admin.jsp"><i class="fa-solid fa-users-gear"></i><span>IT Tools</span></a></li>
                <li><a class="nav__link" href="<%=ctx%>/staff-profile.jsp"><i class="fa-regular fa-user"></i><span>My Profile</span></a></li>
            </ul>
        </div>
        <div class="sidebar__footer">
            <a href="<%=ctx%>/staff-profile.jsp" class="me-card">
                <div class="me-card__avatar"><img src="<%=ctx%>/staff/avatar?v=<%=System.currentTimeMillis()%>" alt="Staff"></div>
                <div>
                    <div class="me-card__name"><%= (firstName!=null?firstName:"") %> <%= (lastName!=null?lastName:"") %></div>
                    <div class="me-card__role">IT</div>
                </div>
            </a>
            <a href="<%=ctx%>/staff-signin.jsp" class="logout"><i class="fa-solid fa-right-from-bracket"></i>Logout</a>
        </div>
    </aside>

    <!-- Main -->
    <main class="main">
        <div class="main__header">
            <h2 class="greet">IT Tools — Staff & Tourist Administration</h2>
            <span class="pill"><i class="fa-solid fa-shield-halved"></i> IT</span>
        </div>

        <div class="container">
            <% if (ok != null) { %>
            <div class="alert alert--success"><i class="fa-solid fa-circle-check"></i> Action completed successfully.</div>
            <% } %>
            <% if (err != null) { %>
            <div class="alert alert--error"><i class="fa-solid fa-triangle-exclamation"></i> <%= err %></div>
            <% } %>

            <!-- ================= STAFF DIRECTORY ================= -->
            <section class="page-intro">
                <h2>Staff Directory</h2>
                <p>Edit staff type, department and subtype attributes. Email & Phone are separate columns.</p>
            </section>

            <div class="card card--table">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                        <tr>
                            <th class="col-id">ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Staff Type</th>
                            <th>Department</th>
                            <th>Subtype Attributes</th>
                            <th class="col-actions">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            if (staffList == null || staffList.isEmpty()) {
                        %>
                        <tr><td colspan="8" class="empty"><i class="fa-regular fa-face-smile-wink"></i> No staff found.</td></tr>
                        <%
                        } else {
                            int rowIdx = 0;
                            for (Object s : staffList) {
                                long   id   = lng(s, "getStaffId","getId","staffId","id");
                                String fn   = str(s, "getFirstName","firstName","FirstName");
                                String ln   = str(s, "getLastName","lastName","LastName");
                                String email= str(s, "getEmail","email","Email");
                                String phone= str(s, "getPhone","getPhoneNumber","phone","PhoneNumber");
                                String type = str(s, "getStaffType","staffType","type","role");
                                if (type == null || type.isEmpty()) type = "FRONT_DESK";
                                String dept = str(s, "getDepartment","department","Department");

                                String deskCode        = str(s, "getDeskCode","deskCode","DeskCode");
                                String campaignsManaged= str(s, "getCampaignsManaged","campaignsManaged","CampaignsManaged");
                                String managerRole     = str(s, "getManagerRole","managerRole","ManagerRole");
                                String specialization  = str(s, "getSpecialization","specialization","Specialization");

                                String rowId = "r" + (++rowIdx);
                        %>
                        <tr id="<%=rowId%>">
                            <td><%= id %></td>
                            <td><strong><%= fn %> <%= ln %></strong></td>
                            <td><i class="fa-regular fa-envelope"></i> <%= email %></td>
                            <td class="col-phone"><i class="fa-solid fa-phone"></i> <%= phone %></td>

                            <form method="post" action="<%=ctx%>/it/staff-update" class="inline-form" onsubmit="return validateRow('<%=rowId%>')">
                                <input type="hidden" name="staffId" value="<%=id%>">

                                <td>
                                    <select name="staffType" class="select select--sm" id="<%=rowId%>-type" onchange="toggleSubtype('<%=rowId%>')">
                                        <option value="FRONT_DESK" <%= "FRONT_DESK".equals(type)?"selected":"" %>>FRONT_DESK</option>
                                        <option value="MARKETING"  <%= "MARKETING".equals(type) ?"selected":"" %>>MARKETING</option>
                                        <option value="MANAGER"    <%= "MANAGER".equals(type)   ?"selected":"" %>>MANAGER</option>
                                        <option value="IT"         <%= "IT".equals(type)        ?"selected":"" %>>IT</option>
                                    </select>
                                </td>

                                <td>
                                    <input type="text" name="department" class="input input--sm" value="<%= dept %>" placeholder="Department">
                                </td>

                                <td>
                                    <div class="subwrap" id="<%=rowId%>-sub">
                                        <div class="sub sub--FRONT_DESK">
                                            <label class="sub__label">Desk Code</label>
                                            <input type="text" class="input input--sm" name="deskCode" value="<%= deskCode %>" placeholder="e.g. FD-01">
                                        </div>
                                        <div class="sub sub--MARKETING">
                                            <label class="sub__label">Campaigns Managed</label>
                                            <input type="text" class="input input--sm" name="campaignsManaged" value="<%= campaignsManaged %>" placeholder="e.g. Summer Promo">
                                        </div>
                                        <div class="sub sub--MANAGER">
                                            <label class="sub__label">Manager Role</label>
                                            <input type="text" class="input input--sm" name="managerRole" value="<%= managerRole %>" placeholder="e.g. Operations Manager">
                                        </div>
                                        <div class="sub sub--IT">
                                            <label class="sub__label">Specialization</label>
                                            <input type="text" class="input input--sm" name="specialization" value="<%= specialization %>" placeholder="e.g. DevOps, SecOps">
                                        </div>
                                    </div>
                                </td>

                                <td class="col-actions">
                                    <button class="btn btn--primary btn--sm" type="submit">
                                        <i class="fa-solid fa-floppy-disk"></i> Save
                                    </button>
                            </form>

                            <form method="post" action="<%=ctx%>/it/staff-delete" class="inline-form" onsubmit="return confirm('Delete staff #<%=id%>? This cannot be undone.');">
                                <input type="hidden" name="staffId" value="<%=id%>">
                                <button class="btn btn--ghost btn--sm" type="submit">
                                    <i class="fa-solid fa-trash"></i> Delete
                                </button>
                            </form>
                            </td>
                        </tr>
                        <script>document.addEventListener('DOMContentLoaded',()=>toggleSubtype('<%=rowId%>'));</script>
                        <%
                                } // for
                            } // else
                        %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- ================= TOURIST DIRECTORY ================= -->
            <section class="page-intro" style="margin-top:22px">
                <h2>Tourist Directory</h2>
                <p>Email & Phone are separate. Delete accounts when needed.</p>
            </section>

            <div class="card card--table">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                        <tr>
                            <th class="col-id">ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th class="col-actions">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            if (touristList == null || touristList.isEmpty()) {
                        %>
                        <tr><td colspan="5" class="empty"><i class="fa-regular fa-face-smile"></i> No tourists found.</td></tr>
                        <%
                        } else {
                            for (Object t : touristList) {
                                long   tid   = lng(t, "getTouristId","getId","touristId","id");
                                String tfn   = str(t, "getFirstName","firstName","FirstName");
                                String tln   = str(t, "getLastName","lastName","LastName");
                                String temail= str(t, "getEmail","email","Email");
                                String tph   = str(t, "getPhone","getPhoneNumber","phone","PhoneNumber");
                        %>
                        <tr>
                            <td><%= tid %></td>
                            <td><strong><%= tfn %> <%= tln %></strong></td>
                            <td><i class="fa-regular fa-envelope"></i> <%= temail %></td>
                            <td class="col-phone"><i class="fa-solid fa-phone"></i> <%= tph %></td>
                            <td class="col-actions">
                                <form method="post" action="<%=ctx%>/it/tourist-delete" onsubmit="return confirm('Delete tourist #<%=tid%>? This cannot be undone.');">
                                    <input type="hidden" name="touristId" value="<%=tid%>">
                                    <button class="btn btn--ghost btn--sm" type="submit">
                                        <i class="fa-solid fa-trash"></i> Delete
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                                } // for
                            } // else
                        %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div><!-- /container -->

        <footer class="main__footer">© 2025 • 93 Hotel Reservation • Y2S1 • Group 93</footer>
    </main>
</div>

<script>
    function toggleSubtype(rowId) {
        const select = document.getElementById(rowId + '-type');
        if (!select) return;
        const value = select.value; // FRONT_DESK / MARKETING / MANAGER / IT
        const wrap  = document.getElementById(rowId + '-sub');
        if (!wrap) return;
        wrap.querySelectorAll('.sub').forEach(el => el.style.display = 'none');
        const block = wrap.querySelector('.sub--' + value);
        if (block) block.style.display = '';
    }
    function validateRow(){ return true; }
    document.querySelectorAll('.alert').forEach(a => setTimeout(()=>a.classList.add('is-hidden'), 2400));
</script>
</body>
</html>
