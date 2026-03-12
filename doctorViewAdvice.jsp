<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
HttpSession s = request.getSession(false);
if(s==null || s.getAttribute("user_id")==null || !"doctor".equals(s.getAttribute("role"))){
    response.sendRedirect("index.html");
    return;
}

String doctorName = (String)s.getAttribute("user_name");
%>

<!DOCTYPE html>
<html>
<head>
<title>Past Medical Advice - MedAxis Doctor</title>
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
}

.page-header{
    color: var(--primary);
    font-weight: 700;
    margin-bottom: 30px;
}

.advice-card{
    border-left: 4px solid var(--accent);
    margin-bottom: 20px;
    padding: 20px;
}

.badge-priority{
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.badge-high{
    background: #dc3545;
    color: white;
}

.badge-urgent{
    background: #fd7e14;
    color: white;
}

.badge-normal{
    background: #198754;
    color: white;
}

.divider{
    height: 1px;
    background: rgba(255,255,255,0.2);
    margin: 20px 0;
}
</style>
</head>

<body>

<div class="sidebar">
<h4>MedAxis</h4>
<a href="doctorDashboard.jsp">Dashboard</a>
<a href="doctorAppointments.jsp">My Appointments</a>
<a href="doctorPatients.jsp">My Patients</a>
<a href="doctorPrescription.jsp">New Prescription</a>
<a href="doctorViewPrescriptions.jsp">Past Prescriptions</a>
<a href="doctorAdvice.jsp">New Advice</a>
<a href="doctorViewAdvice.jsp" class="active">Past Advice</a>
<a href="LogoutServlet">Logout</a>
<div class="divider"></div>
<a href="#" onclick="toggleDarkMode(); return false;">
    <span id="modeText">Dark Mode</span>
</a>
</div>

<div class="main">

<h2 class="page-header">Past Medical Advice</h2>

<%
Connection con = null;
Statement st = null;
ResultSet rs = null;

try{
Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
st = con.createStatement();

rs = st.executeQuery("SELECT * FROM MEDICAL_ADVICE WHERE DOCTOR_NAME = '"+doctorName+"' ORDER BY ADVICE_DATE DESC");

boolean hasData = false;
while(rs.next()){
    hasData = true;
    String patientName = rs.getString("PATIENT_NAME");
    String category = rs.getString("CATEGORY");
    String advice = rs.getString("ADVICE_TEXT");
    String priority = rs.getString("PRIORITY");
    Date adviceDate = rs.getDate("ADVICE_DATE");
    
    String badgeClass = "badge-normal";
    if("High".equals(priority)) badgeClass = "badge-high";
    else if("Urgent".equals(priority)) badgeClass = "badge-urgent";
%>

<div class="card advice-card">
<div class="row">
<div class="col-md-3">
<h6 class="text-muted">Patient</h6>
<p class="fw-bold"><%=patientName%></p>
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
<p><span class="badge-priority <%=badgeClass%>"><%=priority%></span></p>
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

if(!hasData){
%>
<div class="card p-5 text-center">
<p class="text-muted">No medical advice found</p>
<a href="doctorAdvice.jsp" class="btn btn-primary mt-3">Send New Advice</a>
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
