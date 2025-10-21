<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="com.serenityhaven.util.Pricing" %>
<%
  String ctx  = request.getContextPath();
  String room = request.getParameter("room");
  if (room == null || room.isBlank()) room = "single";
  BigDecimal nightly = Pricing.priceFor(room);

  // capacity per room for client-side hints
  int maxGuests = "single".equalsIgnoreCase(room) ? 1 :
          "double".equalsIgnoreCase(room) ? 2 : 3;

  // min check-in date = today + 2 days
  LocalDate minIn = LocalDate.now().plusDays(2);
  LocalDate minOut = minIn.plusDays(1);

  Integer userId   = (Integer) session.getAttribute("userId");
  String  userName = (String)  session.getAttribute("userName");
  if (userId == null) { response.sendRedirect(ctx + "/user-login.jsp?next=" + ctx + "/reservations/new.jsp?room=" + room); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Make a Reservation • <%= room %></title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <style>
    body{background:#f8f9fa}
    .cardx{background:#fff;border-radius:12px;box-shadow:0 10px 30px rgba(0,0,0,.08);padding:24px}
  </style>
</head>
<body>
<div class="container py-4" style="max-width:820px;">
  <div class="mb-3">
    <a href="<%=ctx%>/" class="text-decoration-none">&larr; Back to Home</a>
  </div>

  <div class="cardx">
    <h3 class="mb-3">Reservation Form</h3>
    <p class="text-muted mb-4">
      Room Type: <strong class="text-primary text-uppercase"><%= room %></strong>
      • Nightly: <strong>$<%= nightly %></strong>
      • Max Guests: <strong><%= maxGuests %></strong>
    </p>

    <!-- Bootstrap driven validation -->
    <form action="<%=ctx%>/api/reservations" method="post" id="resForm" class="needs-validation" novalidate>
      <!-- fixed values -->
      <input type="hidden" name="roomType" value="<%= room %>"/>

      <div class="row g-3">
        <!-- Customer name -->
        <div class="col-md-6">
          <label class="form-label">Customer Name</label>
          <input type="text" name="fullName" class="form-control" value="<%= (userName!=null?userName:"") %>"
                 minlength="2" maxlength="80" required>
          <div class="invalid-feedback">Please enter your name (2–80 chars).</div>
        </div>

        <!-- Contact Number -->
        <div class="col-md-6">
          <label class="form-label">Contact Number</label>
          <input
                  id="contactNumber"
                  type="tel"
                  name="contactNumber"
                  placeholder = "+94 71 234 5678"
                  class="form-control"
                  inputmode="tel"
                  pattern="^[0-9()\+\-\s]{7,20}$"
                  required>
          <div class="invalid-feedback">Use digits, +, space, (), -; 7–20 chars.</div>
        </div>

        <!-- Email -->
        <div class="col-md-12">
          <label class="form-label">Email</label>
          <input
                  id="email"
                  type="email"
                  name="email"
                  class="form-control"
                  placeholder="you@example.com"
                  required
          >
          <div class="invalid-feedback">Enter a valid email address.</div>
        </div>


        <!-- Dates -->
        <div class="col-md-4">
          <label class="form-label">Check-in</label>
          <input type="date" name="checkIn" id="checkIn" class="form-control"
                 min="<%= minIn %>" required>
          <div class="invalid-feedback">Check-in must be on/after <%= minIn %> (2+ days from today).</div>
        </div>

        <div class="col-md-4">
          <label class="form-label">Check-out</label>
          <input type="date" name="checkOut" id="checkOut" class="form-control"
                 min="<%= minOut %>" required>
          <div class="invalid-feedback">Check-out must be after check-in.</div>
        </div>

        <!-- Guests -->
        <div class="col-md-4">
          <label class="form-label">Participants</label>
          <input type="number" name="guests" id="guests" class="form-control"
                 min="1" max="<%= maxGuests %>" value="1" required>
          <div class="invalid-feedback">Guests must be between 1 and <%= maxGuests %> for this room.</div>
        </div>

        <!-- Total (auto) -->
        <div class="col-md-6">
          <label class="form-label">Total Price (USD)</label>
          <input type="text" name="totalPrice" id="totalPrice" class="form-control" readonly>
        </div>
      </div>

      <div class="d-flex gap-2 mt-4">
        <button class="btn btn-primary" type="submit">Confirm Booking</button>
        <a class="btn btn-outline-secondary" href="<%=ctx%>/">Cancel</a>
      </div>
    </form>
  </div>
</div>

<script>
  // ---- Config / elements ----
  const nightly   = parseFloat("<%= nightly %>");
  const maxGuests = parseInt("<%= maxGuests %>", 10);

  const form   = document.getElementById('resForm');
  const nameEl = document.getElementById('fullName') || document.querySelector('input[name="fullName"]');
  const phone  = document.getElementById('contactNumber') || document.querySelector('input[name="contactNumber"]');
  const email  = document.getElementById('email') || document.querySelector('input[name="email"]');
  const ci     = document.getElementById('checkIn');
  const co     = document.getElementById('checkOut');
  const guests = document.getElementById('guests');
  const total  = document.getElementById('totalPrice');

  const PHONE_RE = /^[+()0-9\s-]{7,20}$/;
  const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  // ---- helpers ----
  function addDays(dateStr, days){
    const d = new Date(dateStr);
    d.setDate(d.getDate() + days);
    return d.toISOString().slice(0,10);
  }
  function daysBetween(a, b){
    const d1 = new Date(a), d2 = new Date(b);
    if (isNaN(d1) || isNaN(d2)) return 0;
    return Math.max(0, Math.ceil((d2 - d1) / (1000*60*60*24)));
  }
  function enforceOutMin(){
    if (ci.value) {
      co.min = addDays(ci.value, 1);
      if (co.value && co.value <= ci.value) co.value = co.min;
    }
  }
  function recalc(){
    const n = daysBetween(ci.value, co.value);
    total.value = n > 0 ? (n * nightly).toFixed(2) : "";
  }
  function setValidity(el, ok, msg=""){
    el.setCustomValidity(ok ? "" : msg);
    // show Bootstrap states immediately
    if (el.value.length === 0) {
      el.classList.remove('is-valid', 'is-invalid');
    } else {
      el.classList.toggle('is-valid', ok);
      el.classList.toggle('is-invalid', !ok);
    }
  }

  // ---- live validators ----
  // Name: 2–80 chars
  nameEl.addEventListener('input', () => {
    const ok = nameEl.value.trim().length >= 2 && nameEl.value.trim().length <= 80;
    setValidity(nameEl, ok, "Please enter your name (2–80 chars).");
  });

  // Phone: sanitize & validate as you type
  function sanitizePhone(){
    const cleaned = phone.value.replace(/[^0-9+\s()-]/g, ""); // strip letters/illegal chars
    if (cleaned !== phone.value) phone.value = cleaned;
    const ok = PHONE_RE.test(phone.value);
    setValidity(phone, ok, "Use digits, +, space, (), -; 7–20 chars.");
  }
  phone.addEventListener('input', sanitizePhone);
  phone.addEventListener('paste', (e) => {
    // paste, then sanitize on next task
    setTimeout(sanitizePhone, 0);
  });

  // Email: live validation
  email.addEventListener('input', () => {
    const ok = EMAIL_RE.test(email.value);
    setValidity(email, ok, "Enter a valid email address.");
  });

  // Dates: live validation + total recompute
  function validateDates(){
    enforceOutMin();
    recalc();
    const okIn  = ci.value && ci.value >= ci.min;
    const okOut = co.value && co.value > ci.value;
    setValidity(ci, okIn,  "Check-in must be on/after " + ci.min + ".");
    setValidity(co, okOut, "Check-out must be after check-in.");
  }
  ci.addEventListener('change', validateDates);
  co.addEventListener('change', validateDates);
  ci.addEventListener('input',  validateDates);
  co.addEventListener('input',  validateDates);

  // Guests: 1..maxGuests
  function validateGuests(){
    const g = parseInt(guests.value || "0", 10);
    const ok = g >= 1 && g <= maxGuests;
    setValidity(guests, ok, "Guests must be 1–" + maxGuests + " for this room.");
  }
  guests.addEventListener('input', validateGuests);
  guests.addEventListener('change', validateGuests);

  // ---- submit gate ----
  form.addEventListener('submit', (e) => {
    // run all checks once more
    sanitizePhone();
    validateDates();
    validateGuests();
    nameEl.dispatchEvent(new Event('input'));
    email.dispatchEvent(new Event('input'));

    if (!form.checkValidity()) {
      e.preventDefault();
      e.stopPropagation();
    }
    form.classList.add('was-validated');
  });

  // initial state when page opens
  sanitizePhone();
  validateDates();
  validateGuests();
  nameEl.dispatchEvent(new Event('input'));
  email.dispatchEvent(new Event('input'));
</script>
</body>
</html>
