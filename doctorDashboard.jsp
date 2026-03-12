<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
HttpSession s = request.getSession(false);
if(s==null || s.getAttribute("user_id")==null || !"doctor".equals(s.getAttribute("role"))){
    response.sendRedirect("index.html");
    return;
}

String doctorName = (String)s.getAttribute("user_name");
int doctorId = (int)s.getAttribute("user_id");

int totalPatients = 0;
int todayAppointments = 0;

Connection con = null;
Statement st = null;
ResultSet rs = null;

try{
Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
st = con.createStatement();

rs = st.executeQuery("SELECT COUNT(DISTINCT USER_ID) FROM APPOINTMENT WHERE DOCTOR_NAME='"+doctorName+"'");
if(rs.next()) totalPatients = rs.getInt(1);
rs.close();

rs = st.executeQuery("SELECT COUNT(*) FROM APPOINTMENT WHERE DOCTOR_NAME='"+doctorName+"' AND TRUNC(APPOINTMENT_DATE)=TRUNC(SYSDATE)");
if(rs.next()) todayAppointments = rs.getInt(1);

} catch(Exception e){
    e.printStackTrace();
} finally {
    try{if(rs!=null)rs.close();}catch(Exception e){}
    try{if(st!=null)st.close();}catch(Exception e){}
    try{if(con!=null)con.close();}catch(Exception e){}
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Doctor Dashboard - MedAxis</title>
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

.dark-mode .text-muted {
    color: var(--muted-dark) !important;
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
    transition: all 0.3s ease;
}

.card:hover{
    box-shadow: 0 8px 30px rgba(0,102,204,0.15);
}

.welcome{
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    padding: 25px 35px;
    border-radius: 16px;
    margin-bottom: 25px;
    box-shadow: 0 10px 40px rgba(0,102,204,0.2);
}

.stat-card{
    padding: 30px;
    text-align: center;
    transition: all 0.3s;
}

.stat-card:hover{
    transform: translateY(-5px);
}

.stat-number{
    font-size: 42px;
    font-weight: 700;
    color: var(--primary);
}

.btn-primary-custom{
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border: none;
    border-radius: 10px;
    color: white;
    font-weight: 600;
    transition: all 0.3s;
}

.btn-primary-custom:hover{
    background: linear-gradient(135deg, var(--primary-dark), var(--primary));
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0,102,204,0.3);
}

.divider{
    height: 1px;
    background: rgba(255,255,255,0.2);
    margin: 20px 0;
}

.theme-toggle {
    position: fixed;
    top: 20px;
    right: 20px;
    width: 45px;
    height: 45px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border: none;
    color: white;
    font-size: 20px;
    cursor: pointer;
    box-shadow: 0 4px 15px rgba(0,102,204,0.3);
    transition: all 0.3s ease;
    z-index: 1000;
    display: flex;
    align-items: center;
    justify-content: center;
}

.theme-toggle:hover {
    transform: scale(1.1);
    box-shadow: 0 6px 20px rgba(0,102,204,0.4);
}

.dark-mode .theme-toggle {
    background: linear-gradient(135deg, #ffd700, #ff8c00);
    box-shadow: 0 4px 15px rgba(255,140,0,0.3);
}
</style>
</head>

<body>

<div class="sidebar">
<h4>MedAxis</h4>
<a href="doctorDashboard.jsp" class="active">Dashboard</a>
<a href="doctorAppointments.jsp">My Appointments</a>
<a href="doctorPatients.jsp">My Patients</a>
<a href="doctorPrescription.jsp">New Prescription</a>
<a href="doctorViewPrescriptions.jsp">Past Prescriptions</a>
<a href="doctorAdvice.jsp">New Advice</a>
<a href="doctorViewAdvice.jsp">Past Advice</a>
<a href="LogoutServlet">Logout</a>
</div>

<button class="theme-toggle" onclick="toggleDarkMode()" title="Toggle Dark Mode">
    <span id="themeIcon">&#9788;</span>
</button>

<div class="main">

<div class="welcome">
<h2>Welcome, Dr. <%=doctorName%></h2>
<p class="mb-0">Doctor Panel - Manage your appointments and patients</p>
</div>

<div class="row g-4">

<div class="col-md-6">
<div class="card stat-card">
<div class="stat-number"><%=totalPatients%></div>
<h5 class="text-muted mt-2">Total Patients</h5>
</div>
</div>

<div class="col-md-6">
<div class="card stat-card">
<div class="stat-number"><%=todayAppointments%></div>
<h5 class="text-muted mt-2">Today's Appointments</h5>
</div>
</div>

</div>

<div class="card mt-4 p-4">
<h5 class="mb-3">Quick Actions</h5>
<div class="row mt-3">
<div class="col-md-6 mb-3">
<a href="doctorAppointments.jsp" class="btn btn-primary-custom w-100">View Appointments</a>
</div>
<div class="col-md-6 mb-3">
<a href="doctorPatients.jsp" class="btn btn-primary-custom w-100">View Patients</a>
</div>
<div class="col-md-6 mb-3">
<a href="doctorPrescription.jsp" class="btn btn-primary-custom w-100">Write Prescription</a>
</div>
<div class="col-md-6 mb-3">
<a href="doctorAdvice.jsp" class="btn btn-primary-custom w-100">Send Medical Advice</a>
</div>
</div>
</div>

</div>

<script>
// Dark Mode
function toggleDarkMode() {
    const body = document.body;
    const isDark = body.classList.toggle('dark-mode');
    localStorage.setItem('darkMode', isDark);
    const themeIcon = document.getElementById('themeIcon');
    if(themeIcon) themeIcon.innerHTML = isDark ? '&#9790;' : '&#9788;';
}

// Load saved dark mode preference
if(localStorage.getItem('darkMode') === 'true') {
    document.body.classList.add('dark-mode');
    const themeIcon = document.getElementById('themeIcon');
    if(themeIcon) themeIcon.innerHTML = '&#9790;';
}
</script>

</body>
</html>
