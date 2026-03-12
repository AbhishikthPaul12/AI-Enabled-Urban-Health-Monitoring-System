<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
HttpSession s = request.getSession(false);
if(s==null || s.getAttribute("user_id")==null){
    response.sendRedirect("index.html");
    return;
}

String patientName = (String)s.getAttribute("user_name");
int patientId = (int)s.getAttribute("user_id");
%>

<!DOCTYPE html>
<html>
<head>
<title>My Medical History - MedAxis</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
:root {
    --primary: #0066cc;
    --primary-dark: #004d99;
    --secondary: #00a8e8;
    --accent: #00d4aa;
    --bg-light: #f0f7ff;
    --bg-dark: #0a1929;
    --card-light: #ffffff;
    --card-dark: #132f4c;
    --text-light: #1a1a2e;
    --text-dark: #e6f2ff;
    --muted-light: #5a6a7a;
    --muted-dark: #8b9dc3;
}

body{
    background: var(--bg-light);
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    transition: all 0.3s ease;
}

body.dark-mode {
    background: var(--bg-dark);
    color: var(--text-dark);
}

.dark-mode .card {
    background: var(--card-dark);
    color: var(--text-dark);
}

.sidebar{
    height: 100vh;
    width: 260px;
    position: fixed;
    background: linear-gradient(180deg, var(--primary), var(--primary-dark));
    color: white;
    padding: 35px 20px;
    box-shadow: 4px 0 20px rgba(0,0,0,0.15);
}

.sidebar h4{
    margin-bottom: 40px;
    font-size: 28px;
    font-weight: 700;
    letter-spacing: 1px;
    text-align: center;
    padding-bottom: 20px;
    border-bottom: 2px solid rgba(255,255,255,0.2);
}

.sidebar a{
    display: block;
    color: white;
    margin: 15px 0;
    text-decoration: none;
    font-size: 15px;
    font-weight: 500;
    padding: 12px 18px;
    border-radius: 8px;
    transition: all 0.3s;
    border-left: 3px solid transparent;
}

.sidebar a:hover{
    background: rgba(255,255,255,0.15);
    border-left: 3px solid var(--accent);
    transform: translateX(5px);
}

.sidebar a.active{
    background: rgba(255,255,255,0.2);
    border-left: 3px solid var(--accent);
}

.main{margin-left: 280px; padding: 30px;}

.card{
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0,102,204,0.1);
    border: none;
    background: var(--card-light);
    margin-bottom: 20px;
}

.page-header{
    color: var(--primary);
    font-weight: 700;
    margin-bottom: 30px;
}

.prescription-card{
    border-left: 4px solid var(--primary);
}

.advice-card{
    border-left: 4px solid var(--accent);
}

.badge-priority{
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.divider{
    height: 1px;
    background: rgba(255,255,255,0.2);
    margin: 20px 0;
}

.nav-tabs .nav-link{
    color: var(--primary);
    font-weight: 600;
}

.nav-tabs .nav-link.active{
    background: var(--primary);
    color: white;
}
</style>
</head>

<body>

<div class="sidebar">
<h4>MedAxis</h4>
<a href="dashboard.jsp">Dashboard</a>
<a href="health.jsp">Health</a>
<a href="healthTrends.jsp">Trends</a>
<a href="appointment.jsp">Appointments</a>
<a href="calendar.jsp">Calendar</a>
<a href="patientMedicalHistory.jsp" class="active">Medical History</a>
<a href="profile.jsp">Profile</a>
<a href="ai.jsp">AI Assistant</a>
<a href="LogoutServlet">Logout</a>
<div class="divider"></div>
<a href="#" onclick="toggleDarkMode(); return false;">
    <span id="modeText">Dark Mode</span>
</a>
</div>

<div class="main">

<h2 class="page-header">My Medical History</h2>

<ul class="nav nav-tabs mb-4" id="historyTab" role="tablist">
<li class="nav-item" role="presentation">
<button class="nav-link active" id="prescriptions-tab" data-bs-toggle="tab" data-bs-target="#prescriptions" type="button">Prescriptions</button>
</li>
<li class="nav-item" role="presentation">
<button class="nav-link" id="advice-tab" data-bs-toggle="tab" data-bs-target="#advice" type="button">Medical Advice</button>
</li>
</ul>

<div class="tab-content" id="historyTabContent">

<div class="tab-pane fade show active" id="prescriptions" role="tabpanel">
<%
Connection con = null;
Statement st = null;
ResultSet rs = null;

try{
Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
st = con.createStatement();

rs = st.executeQuery("SELECT * FROM PRESCRIPTION WHERE PATIENT_NAME = '"+patientName+"' ORDER BY PRESCRIPTION_DATE DESC");

boolean hasPrescriptions = false;
while(rs.next()){
    hasPrescriptions = true;
    String doctorName = rs.getString("DOCTOR_NAME");
    String medication = rs.getString("MEDICATION");
    String dosage = rs.getString("DOSAGE");
    String duration = rs.getString("DURATION");
    String instructions = rs.getString("INSTRUCTIONS");
    Date presDate = rs.getDate("PRESCRIPTION_DATE");
%>

<div class="card prescription-card p-4">
<div class="row">
<div class="col-md-4">
<h6 class="text-muted">Doctor</h6>
<p class="fw-bold"><%=doctorName%></p>
</div>
<div class="col-md-4">
<h6 class="text-muted">Date</h6>
<p><%=presDate%></p>
</div>
<div class="col-md-4">
<h6 class="text-muted">Medication</h6>
<p class="fw-bold text-primary"><%=medication%></p>
</div>
</div>
<div class="row mt-3">
<div class="col-md-4">
<h6 class="text-muted">Dosage</h6>
<p><%=dosage%></p>
</div>
<div class="col-md-4">
<h6 class="text-muted">Duration</h6>
<p><%=duration%></p>
</div>
<div class="col-md-4">
<h6 class="text-muted">Instructions</h6>
<p><%=instructions != null ? instructions : "None"%></p>
</div>
</div>
</div>

<%
}

if(!hasPrescriptions){
%>
<div class="card p-5 text-center">
<p class="text-muted">No prescriptions found</p>
</div>
<%
}

rs.close();
%>
</div>

<div class="tab-pane fade" id="advice" role="tabpanel">
<%
rs = st.executeQuery("SELECT * FROM MEDICAL_ADVICE WHERE PATIENT_NAME = '"+patientName+"' ORDER BY ADVICE_DATE DESC");

boolean hasAdvice = false;
while(rs.next()){
    hasAdvice = true;
    String doctorName = rs.getString("DOCTOR_NAME");
    String category = rs.getString("CATEGORY");
    String advice = rs.getString("ADVICE_TEXT");
    String priority = rs.getString("PRIORITY");
    Date adviceDate = rs.getDate("ADVICE_DATE");
    
    String badgeColor = "bg-success";
    if("High".equals(priority)) badgeColor = "bg-warning";
    else if("Urgent".equals(priority)) badgeColor = "bg-danger";
%>

<div class="card advice-card p-4">
<div class="row">
<div class="col-md-3">
<h6 class="text-muted">Doctor</h6>
<p class="fw-bold"><%=doctorName%></p>
</div>
<div class="col-md-3">
<h6 class="text-muted">Date</h6>
<p><%=adviceDate%></p>
</div>
<div class="col-md-3">
<h6 class="text-muted">Category</h6>
<p><span class="badge bg-primary"><%=category%></span></p>
</div>
<div class="col-md-3">
<h6 class="text-muted">Priority</h6>
<p><span class="badge <%=badgeColor%>"><%=priority%></span></p>
</div>
</div>
<div class="row mt-3">
<div class="col-12">
<h6 class="text-muted">Advice</h6>
<p style="white-space: pre-wrap;"><%=advice%></p>
</div>
</div>
</div>

<%
}

if(!hasAdvice){
%>
<div class="card p-5 text-center">
<p class="text-muted">No medical advice found</p>
</div>
<%
}

} catch(Exception e){
    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
} finally {
    try{if(rs!=null)rs.close();}catch(Exception e){}
    try{if(st!=null)st.close();}catch(Exception e){}
    try{if(con!=null)con.close();}catch(Exception e){}
}
%>
</div>

</div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
function toggleDarkMode() {
    const body = document.body;
    const isDark = body.classList.toggle('dark-mode');
    localStorage.setItem('darkMode', isDark);
    const modeText = document.getElementById('modeText');
    if(modeText) modeText.textContent = isDark ? 'Light Mode' : 'Dark Mode';
}

if(localStorage.getItem('darkMode') === 'true') {
    document.body.classList.add('dark-mode');
    const modeText = document.getElementById('modeText');
    if(modeText) modeText.textContent = 'Light Mode';
}
</script>

</body>
</html>
