<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
HttpSession s = request.getSession(false);
if(s==null || s.getAttribute("user_id")==null || !"admin".equals(s.getAttribute("role"))){
    response.sendRedirect("index.html");
    return;
}

String adminName = (String)s.getAttribute("user_name");

int totalUsers = 0;
int totalDoctors = 0;
int totalAppointments = 0;

Connection con = null;
Statement st = null;
ResultSet rs = null;

try{
Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
st = con.createStatement();

rs = st.executeQuery("SELECT COUNT(*) FROM Users WHERE ROLE='user'");
if(rs.next()) totalUsers = rs.getInt(1);
rs.close();

rs = st.executeQuery("SELECT COUNT(*) FROM Users WHERE ROLE='doctor'");
if(rs.next()) totalDoctors = rs.getInt(1);
rs.close();

rs = st.executeQuery("SELECT COUNT(*) FROM APPOINTMENT");
if(rs.next()) totalAppointments = rs.getInt(1);

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
<title>Admin Dashboard - MedAxis</title>
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

.btn-admin{
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border: none;
    border-radius: 10px;
    color: white;
    font-weight: 600;
    transition: all 0.3s;
}

.btn-admin:hover{
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
<a href="adminDashboard.jsp" class="active">Dashboard</a>
<a href="adminUsers.jsp">Manage Users</a>
<a href="dataAnalytics.jsp">Analytics</a>
<a href="LogoutServlet">Logout</a>
</div>

<button class="theme-toggle" onclick="toggleDarkMode()" title="Toggle Dark Mode">
    <span id="themeIcon">&#9788;</span>
</button>

<div class="main">

<div class="welcome">
<h2>Welcome, <%=adminName%></h2>
<p class="mb-0">Administrator Control Panel</p>
</div>

<div class="row g-4">

<div class="col-md-4">
<div class="card stat-card">
<div class="stat-number"><%=totalUsers%></div>
<h5 class="text-muted mt-2">Registered Users</h5>
</div>
</div>

<div class="col-md-4">
<div class="card stat-card">
<div class="stat-number" style="color:#198754;"><%=totalDoctors%></div>
<h5 class="text-muted mt-2">Active Doctors</h5>
</div>
</div>

<div class="col-md-4">
<div class="card stat-card">
<div class="stat-number" style="color:#dc3545;"><%=totalAppointments%></div>
<h5 class="text-muted mt-2">Total Appointments</h5>
</div>
</div>

</div>

<div class="card mt-4 p-4">
<h5 class="mb-3">Quick Actions</h5>
<div class="row mt-3">
<div class="col-md-4 mb-3">
<a href="adminUsers.jsp" class="btn btn-admin w-100">
Manage Users
</a>
<p class="small text-muted mt-2">Add, edit, or remove users</p>
</div>
<div class="col-md-4 mb-3">
<a href="dataAnalytics.jsp" class="btn btn-admin w-100">
View Analytics
</a>
<p class="small text-muted mt-2">System usage statistics</p>
</div>
<div class="col-md-4 mb-3">
<button class="btn btn-admin w-100" onclick="exportReport()">
Export Data
</button>
<p class="small text-muted mt-2">Download system report</p>
</div>
</div>
</div>

<div class="card mt-4 p-4">
<h5>Admin Operations</h5>
<div class="row mt-3">
<div class="col-md-6">
<h6>User Management</h6>
<ul class="list-unstyled">
<li>View all registered users and their roles</li>
<li>Change user roles (Admin/Doctor/Patient)</li>
<li>Delete inactive or suspicious accounts</li>
<li>Monitor user login activity</li>
</ul>
</div>
<div class="col-md-6">
<h6>System Monitoring</h6>
<ul class="list-unstyled">
<li>Track total appointments booked</li>
<li>View doctor-patient interactions</li>
<li>Export data for external analysis</li>
<li>Manage system access permissions</li>
</ul>
</div>
</div>
</div>

</div>

<script>
function exportReport() {
    var report = "MEDAXIS ADMIN REPORT\n\n" +
    "Generated: " + new Date().toLocaleString() + "\n\n" +
    "System Statistics:\n" +
    "- Registered Users: <%=totalUsers%>\n" +
    "- Active Doctors: <%=totalDoctors%>\n" +
    "- Total Appointments: <%=totalAppointments%>\n\n" +
    "Admin Actions Available:\n" +
    "1. User Management - View, edit roles, delete accounts\n" +
    "2. System Analytics - Monitor usage and statistics\n" +
    "3. Data Export - Download system reports\n\n" +
    "Report Generated By: <%=adminName%>";

    var blob = new Blob([report], {type: 'text/plain'});
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url;
    a.download = 'MedAxis_Admin_Report.txt';
    a.click();
    URL.revokeObjectURL(url);
}

function toggleDarkMode() {
    var body = document.body;
    var isDark = body.classList.toggle('dark-mode');
    localStorage.setItem('darkMode', isDark);
    var themeIcon = document.getElementById('themeIcon');
    if(themeIcon) themeIcon.innerHTML = isDark ? '&#9790;' : '&#9788;';
}

if(localStorage.getItem('darkMode') === 'true') {
    document.body.classList.add('dark-mode');
    var themeIcon = document.getElementById('themeIcon');
    if(themeIcon) themeIcon.innerHTML = '&#9790;';
}
</script>

</body>
</html>
