<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
HttpSession s = request.getSession(false);
if(s==null || s.getAttribute("user_id")==null || !"admin".equals(s.getAttribute("role"))){
    response.sendRedirect("index.html");
    return;
}

// Database metadata
String dbName = "";
String dbVersion = "";
int tableCount = 0;
int totalRecords = 0;
int userCount = 0;
int doctorCount = 0;
int appointmentCount = 0;
int healthRecords = 0;

Connection con = null;
Statement st = null;
ResultSet rs = null;
ResultSet tables = null;

try{
Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
DatabaseMetaData metaData = con.getMetaData();
dbName = metaData.getDatabaseProductName();
dbVersion = metaData.getDatabaseProductVersion();

st = con.createStatement();

rs = st.executeQuery("SELECT COUNT(*) FROM USERS WHERE ROLE='user'");
if(rs.next()) userCount = rs.getInt(1);
rs.close();

rs = st.executeQuery("SELECT COUNT(*) FROM USERS WHERE ROLE='doctor'");
if(rs.next()) doctorCount = rs.getInt(1);
rs.close();

rs = st.executeQuery("SELECT COUNT(*) FROM APPOINTMENT");
if(rs.next()) appointmentCount = rs.getInt(1);
rs.close();

rs = st.executeQuery("SELECT COUNT(*) FROM FITNESS_DATA");
if(rs.next()) healthRecords = rs.getInt(1);
rs.close();

totalRecords = userCount + doctorCount + appointmentCount + healthRecords;

} catch(Exception e){
    e.printStackTrace();
} finally {
    try{if(tables!=null)tables.close();}catch(Exception e){}
    try{if(rs!=null)rs.close();}catch(Exception e){}
    try{if(st!=null)st.close();}catch(Exception e){}
    try{if(con!=null)con.close();}catch(Exception e){}
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Database Report - MedAxis</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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

.schema-box{
    background: #f8f9fa;
    border: 2px solid #dee2e6;
    border-radius: 10px;
    padding: 20px;
    margin: 10px 0;
    font-family: monospace;
}

.dark-mode .schema-box{
    background: #1a1a2e;
    border-color: #495057;
    color: #e6f2ff;
}

.table-card{
    border-left: 4px solid var(--primary);
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
<a href="adminDashboard.jsp">Dashboard</a>
<a href="adminUsers.jsp">Manage Users</a>
<a href="dbReport.jsp" class="active">DB Schema Report</a>
<a href="dataAnalytics.jsp">Data Analytics</a>
<a href="LogoutServlet">Logout</a>
<div class="divider"></div>
<a href="#" onclick="toggleDarkMode(); return false;">
    <span id="modeText">Dark Mode</span>
</a>
</div>

<div class="main">

<h2 class="mb-4">Database Schema & Statistics Report</h2>

<div class="row mb-4">
<div class="col-md-6">
<div class="card p-4">
<h5>Database Information</h5>
<table class="table table-borderless">
<tr><td><b>Database:</b></td><td><%=dbName%></td></tr>
<tr><td><b>Version:</b></td><td><%=dbVersion%></td></tr>
<tr><td><b>Schema Owner:</b></td><td>ABHI</td></tr>
</table>
</div>
</div>
<div class="col-md-6">
<div class="card p-4">
<h5>Data Statistics</h5>
<canvas id="statsChart" height="150"></canvas>
</div>
</div>
</div>

<div class="card p-4 mb-4">
<h5 class="mb-3">Entity Relationship Overview</h5>
<div class="row">
<div class="col-md-3">
<div class="card table-card p-3">
<h6>USERS</h6>
<p class="small text-muted">Master table for all users</p>
<span class="badge bg-primary"><%=userCount+doctorCount%> records</span>
</div>
</div>
<div class="col-md-3">
<div class="card table-card p-3" style="border-left-color:#198754;">
<h6>FITNESS_DATA</h6>
<p class="small text-muted">Health metrics storage</p>
<span class="badge bg-success"><%=healthRecords%> records</span>
</div>
</div>
<div class="col-md-3">
<div class="card table-card p-3" style="border-left-color:#dc3545;">
<h6>APPOINTMENT</h6>
<p class="small text-muted">Doctor appointments</p>
<span class="badge bg-danger"><%=appointmentCount%> records</span>
</div>
</div>
<div class="col-md-3">
<div class="card table-card p-3" style="border-left-color:#ffc107;">
<h6>PROFILE</h6>
<p class="small text-muted">User profile details</p>
<span class="badge bg-warning">Linked to USERS</span>
</div>
</div>
</div>
</div>

<div class="card p-4 mb-4">
<h5 class="mb-3">Table Structures (DDL)</h5>

<div class="schema-box">
<h6>USERS Table</h6>
<pre>CREATE TABLE USERS (
    USER_ID     NUMBER(38) PRIMARY KEY,
    NAME        VARCHAR2(50) NOT NULL,
    AGE         NUMBER(38),
    EMAIL       VARCHAR2(100) NOT NULL UNIQUE,
    PASSWORD    VARCHAR2(100),
    ROLE        VARCHAR2(20) DEFAULT 'user'
);</pre>
</div>

<div class="schema-box">
<h6>FITNESS_DATA Table</h6>
<pre>CREATE TABLE FITNESS_DATA (
    DATA_ID     NUMBER PRIMARY KEY,
    USER_ID     NUMBER REFERENCES USERS(USER_ID),
    HEIGHT      NUMBER,
    WEIGHT      NUMBER,
    STEPS       NUMBER,
    HEART_RATE  NUMBER,
    TIMESTAMP   DATE
);</pre>
</div>

<div class="schema-box">
<h6>APPOINTMENT Table</h6>
<pre>CREATE TABLE APPOINTMENT (
    APPOINTMENT_ID   NUMBER PRIMARY KEY,
    USER_ID          NUMBER REFERENCES USERS(USER_ID),
    DOCTOR_NAME      VARCHAR2(50),
    APPOINTMENT_DATE DATE,
    STATUS           VARCHAR2(20)
);</pre>
</div>

<div class="schema-box">
<h6>PROFILE Table</h6>
<pre>CREATE TABLE PROFILE (
    USER_ID   NUMBER PRIMARY KEY REFERENCES USERS(USER_ID),
    CITY      VARCHAR2(50),
    PHONE     VARCHAR2(20)
);</pre>
</div>
</div>

<div class="card p-4">
<h5 class="mb-3">Key Features Implemented</h5>
<div class="row">
<div class="col-md-6">
<ul class="list-group">
<li class="list-group-item"><b>Primary Keys:</b> All tables have PK constraints</li>
<li class="list-group-item"><b>Foreign Keys:</b> FITNESS_DATA, APPOINTMENT, PROFILE reference USERS</li>
<li class="list-group-item"><b>Unique Constraints:</b> EMAIL in USERS table</li>
</ul>
</div>
<div class="col-md-6">
<ul class="list-group">
<li class="list-group-item"><b>Sequences:</b> USER_SEQ, FITNESS_SEQ, APPOINTMENT_SEQ</li>
<li class="list-group-item"><b>Role-Based Access:</b> user, doctor, admin roles</li>
<li class="list-group-item"><b>Password Security:</b> SHA-256 hashing with Base64</li>
</ul>
</div>
</div>
</div>

</div>

<script>
const ctx = document.getElementById('statsChart').getContext('2d');
new Chart(ctx, {
    type: 'doughnut',
    data: {
        labels: ['Users', 'Doctors', 'Appointments', 'Health Records'],
        datasets: [{
            data: [<%=userCount%>, <%=doctorCount%>, <%=appointmentCount%>, <%=healthRecords%>],
            backgroundColor: ['#0066cc', '#00d4aa', '#dc3545', '#ffc107']
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: { position: 'bottom' }
        }
    }
});

function toggleDarkMode() {
    var body = document.body;
    var isDark = body.classList.toggle('dark-mode');
    localStorage.setItem('darkMode', isDark);
    var modeText = document.getElementById('modeText');
    if(modeText) modeText.textContent = isDark ? 'Light Mode' : 'Dark Mode';
}

if(localStorage.getItem('darkMode') === 'true') {
    document.body.classList.add('dark-mode');
    var modeText = document.getElementById('modeText');
    if(modeText) modeText.textContent = 'Light Mode';
}
</script>

</body>
</html>
