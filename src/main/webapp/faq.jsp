<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, com.wbhrs.webbasedhotelreservationsystemfortourists.model.FAQ" %>
<%
    String ctx = request.getContextPath();
    Object staffType = (session == null) ? null : session.getAttribute("staffType");
    boolean isFrontDesk = (staffType != null && "FRONT_DESK".equals(String.valueOf(staffType)));
    List<FAQ> faqs = (List<FAQ>) request.getAttribute("faqs");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>FAQ - Web Hotel Reservation System</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/staff-dashboard.css" />
    <link rel="stylesheet" href="<%=ctx%>/assets/css/profile.css" />
    <style>
        .faq-container { max-width: 960px; margin: 32px auto; padding: 0 16px; }
        .faq-item { background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; margin-bottom: 12px; }
        .faq-q { padding: 16px 20px; font-weight: 600; cursor: pointer; display: flex; justify-content: space-between; align-items: center; }
        .faq-a { padding: 0 20px 16px 20px; color: #374151; display: none; }
        .faq-item.open .faq-a { display: block; }
        .faq-item.open .faq-q { border-bottom: 1px solid #e5e7eb; }
        .faq-title { text-align: center; margin: 16px 0 24px 0; }
        .muted { color: #6b7280; font-size: 14px; text-align: center; margin-bottom: 24px; }
        .btn.lg { font-size: 16px; padding: 10px 16px; }
        .form-card { background:#fff; border:1px solid #e5e7eb; border-radius:12px; padding:18px; margin:16px 0; box-shadow:0 1px 2px rgba(16,24,40,.06); }
        .field { margin-bottom:10px; }
        .field label { display:block; font-weight:600; margin-bottom:6px; }
        .field input[type=text], .field textarea { width:100%; padding:10px; border:1px solid #d1d5db; border-radius:8px; background:#fafafa; }
        .faq-actions { display:flex; gap:8px; padding: 0 16px 16px 16px; }
    </style>
</head>
<body>
<header class="header">
    <div class="logo"><a href="<%=ctx%>/index.jsp"><img src="<%=ctx%>/assets/images/logo2.png" alt="logo" height="36"/></a></div>
    <h1 style="text-align:center">Frequently Asked Questions</h1>
</header>

<main class="faq-container">
    <p class="muted">Find quick answers about signing up, booking and managing your profile.</p>

    <% if (isFrontDesk) { %>
    <div class="form-card">
        <form method="post" action="<%=ctx%>/faq/save">
            <input type="hidden" name="faqId" id="faqId" />
            <div class="field">
                <label for="question">Question</label>
                <input type="text" id="question" name="question" maxlength="255" required />
            </div>
            <div class="field">
                <label for="answer">Answer</label>
                <textarea id="answer" name="answer" rows="4" maxlength="2000" required></textarea>
            </div>
            <div>
                <button class="btn" type="submit">Save FAQ</button>
                <button class="btn secondary" type="button" onclick="resetFaqForm()">Reset</button>
            </div>
        </form>
    </div>
    <% } %>

    <% if (faqs == null || faqs.isEmpty()) { %>
        <p class="muted" style="text-align:center;">No FAQs yet.</p>
    <% } else { %>
        <% int idx = 0; for (FAQ f : faqs) { idx++; %>
        <section class="faq-item" id="faq-<%=idx%>">
            <div class="faq-q"><%= f.getQuestion() %> <span>+</span></div>
            <div class="faq-a"><%= f.getAnswer() %></div>
            <% if (isFrontDesk) { %>
            <div class="faq-actions">
                <button class="btn" onclick="editFaq('<%= f.getFaqId() %>', '<%= f.getQuestion().replace("'","&#39;").replace("\"","&quot;") %>', '<%= f.getAnswer().replace("'","&#39;").replace("\"","&quot;") %>')">Edit</button>
                <form method="post" action="<%=ctx%>/faq/delete" onsubmit="return confirm('Delete this FAQ?');">
                    <input type="hidden" name="id" value="<%= f.getFaqId() %>" />
                    <button class="btn danger" type="submit">Delete</button>
                </form>
            </div>
            <% } %>
        </section>
        <% } %>
    <% } %>

    <div style="text-align:center; margin-top: 20px;">
        <a class="btn lg" href="<%=ctx%>/index.jsp">Back to home</a>
    </div>
</main>

<script>
    // Small vanilla JS toggle for FAQ items
    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.faq-item .faq-q').forEach(function (q) {
            q.addEventListener('click', function () {
                var item = q.parentElement;
                item.classList.toggle('open');
            });
        });
    });

    function editFaq(id, question, answer) {
        var idEl = document.getElementById('faqId');
        if (!idEl) return;
        idEl.value = id;
        document.getElementById('question').value = question || '';
        document.getElementById('answer').value = answer || '';
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
    function resetFaqForm() {
        var idEl = document.getElementById('faqId');
        if (idEl) idEl.value = '';
        var q = document.getElementById('question');
        var a = document.getElementById('answer');
        if (q) q.value = '';
        if (a) a.value = '';
    }
    </script>
</body>
</html>


