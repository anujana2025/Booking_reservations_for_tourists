<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Staff Sign Up - Hotel Reservation System</title>

  <!-- Fonts & Icons -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- Bootstrap -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Page CSS -->
  <link rel="stylesheet" href="<%=ctx%>/assets/css/signup.css">
</head>
<body>
<div class="container-fluid auth-container d-flex">
  <!-- Left: image -->
  <div class="col-lg-6 d-none d-lg-block auth-image"></div>

  <!-- Right: form (centered like admin) -->
  <div class="col-lg-6 d-flex flex-column auth-form-container">
    <div class="auth-form-content">
      <!-- Logo -->
      <div class="logo-container text-center">
        <img class="logo" src="<%=ctx%>/assets/images/logo2.png" alt="Logo">
      </div>

      <!-- Heading -->
      <h1 class="text-center">Create Staff Account</h1>
      <p class="subtitle text-center">Fill in your details to register as a staff member.</p>

      <!-- Optional flash messages -->
      <%
        String code = request.getParameter("error");
        String ok   = request.getParameter("success");
        if (ok != null) {
      %>
      <div class="alert alert-success" role="alert">Registered successfully.</div>
      <%
      } else if (code != null) {
        String msg = switch (code) {
          case "email_exists"      -> "An account with this email already exists. Please <a class='auth-link' href='" + ctx + "/staff-login.jsp'>sign in</a>.";
          case "missing"           -> "Please fill in all required fields.";
          case "desk_required"     -> "Front Desk staff must provide a desk code.";
          case "campaigns_required"-> "Marketing staff must provide campaigns managed.";
          case "campaigns_number"  -> "Campaigns managed must be a valid number.";
          case "role_required"     -> "Manager must have a role specified.";
          case "spec_required"     -> "IT staff must provide a specialization.";
          case "type_invalid"      -> "Invalid staff type.";
          case "server"            -> "Something went wrong. Please try again.";
          default                  -> "Unexpected error.";
        };
      %>
      <div class="auth-error"><%= msg %></div>
      <% } %>

      <!-- Form -->
      <form class="auth-form" action="<%=ctx%>/StaffSignup" method="post" novalidate>
        <!-- Common fields -->
        <div class="row g-3">
          <div class="col-sm-6 form-group">
            <input type="text" name="firstname" class="form-control" placeholder="First Name" required>
          </div>
          <div class="col-sm-6 form-group">
            <input type="text" name="lastname" class="form-control" placeholder="Last Name" required>
          </div>
        </div>

        <div class="form-group">
          <input type="email" name="email" class="form-control" placeholder="Email" required>
        </div>

        <div class="form-group">
          <input type="text" name="phone" class="form-control" placeholder="Phone" required>
        </div>

        <div class="form-group">
          <input type="password" name="password" class="form-control" placeholder="Password" minlength="6" required>
        </div>

        <div class="form-group">
          <input type="text" name="department" class="form-control" placeholder="Department (e.g. Front Office, Sales)" required>
        </div>

        <!-- StaffType (values match your CHECK constraint) -->
        <div class="form-group">
          <select name="type" id="staffType" class="form-select" required>
            <option value="">-- Select Staff Type --</option>
            <option value="FRONT_DESK">Front Desk</option>
            <option value="MARKETING">Marketing Team</option>
            <option value="MANAGER">Manager</option>
            <option value="IT">IT Staff</option>
          </select>
        </div>

        <!-- Role-specific fields (exactly as in DBInit.java) -->
        <div id="extraFields"></div>

        <button type="submit" class="btn btn-primary">Sign Up</button>

        <div class="auth-footer">
          <p>Already have an account?
            <a class="auth-link" href="<%=ctx%>/staff-signin.jsp">Sign in</a>
          </p>
        </div>

        <div class="auth-copyright">
          © <%= java.time.Year.now() %> Hotel Reservation System — Staff
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- Dynamic extra fields per staff type (DBInit-aligned) -->
<script>
  const typeSelect = document.getElementById('staffType');
  const extraFieldsDiv = document.getElementById('extraFields');

  function renderExtra(type) {
    let html = '';
    if (type === 'FRONT_DESK') {
      html = `
        <div class="form-group">
          <input type="text" name="deskCode" class="form-control" placeholder="Desk Code" required>
        </div>`;
    } else if (type === 'MARKETING') {
      html = `
        <div class="form-group">
          <input type="text"  name="campaignsManaged" class="form-control" placeholder="Campaign Name"  required>
        </div>`;
    } else if (type === 'MANAGER') {
      html = `
        <div class="form-group">
          <input type="text" name="role" class="form-control" placeholder="Role (e.g., Duty Manager)" required>
        </div>`;
    } else if (type === 'IT') {
      html = `
        <div class="form-group">
          <input type="text" name="specialization" class="form-control" placeholder="Specialization (e.g., Network, Backend)" required>
        </div>`;
    }
    extraFieldsDiv.innerHTML = html;
  }

  typeSelect.addEventListener('change', () => renderExtra(typeSelect.value));
</script>
</body>
</html>
