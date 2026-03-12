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
%>

<!DOCTYPE html>
<html>
<head>
<title>My Appointments - MedAxis Doctor</title>
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

.dark-mode .table {
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

.table th{
    background: var(--primary);
    color: white;
}

.btn-action{
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border: none;
    border-radius: 8px;
    color: white;
    padding: 8px 16px;
    font-size: 13px;
    transition: all 0.3s;
}

.btn-action:hover{
    background: linear-gradient(135deg, var(--primary-dark), var(--primary));
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
<a href="doctorAppointments.jsp" class="active">My Appointments</a>
<a href="doctorPatients.jsp">My Patients</a>
<a href="doctorPrescription.jsp">New Prescription</a>
<a href="doctorViewPrescriptions.jsp">Past Prescriptions</a>
<a href="doctorAdvice.jsp">New Advice</a>
<a href="doctorViewAdvice.jsp">Past Advice</a>
<a href="LogoutServlet">Logout</a>
<div class="divider"></div>
<a href="#" onclick="toggleDarkMode(); return false;">
    <span id="modeText">Dark Mode</span>
</a>
</div>

<div class="main">

<h2 class="page-header">My Appointments</h2>

<div class="card p-4">
<table class="table table-hover">
<thead>
<tr>
<th>Patient Name</th>
<th>Appointment Date</th>
<th>Status</th>
<th>Actions</th>
</tr>
</thead>
<tbody>

<%
Connection con = null;
Statement st = null;
ResultSet rs = null;

try{
Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
st = con.createStatement();

rs = st.executeQuery("SELECT a.*, u.NAME as PATIENT_NAME FROM APPOINTMENT a JOIN USERS u ON a.USER_ID = u.USER_ID WHERE a.DOCTOR_NAME LIKE '%" + doctorName.replace("Dr. ","") + "%' ORDER BY a.APPOINTMENT_DATE DESC");

boolean hasAppointments = false;
while(rs.next()){
    hasAppointments = true;
    String patientName = rs.getString("PATIENT_NAME");
    Date apptDate = rs.getDate("APPOINTMENT_DATE");
    String status = rs.getString("STATUS");
    if(status == null) status = "Scheduled";
%>
<tr>
<td><%=patientName%></td>
<td><%=apptDate%></td>
<td><span class="badge bg-primary"><%=status%></span></td>
<td>
<a href="doctorPrescription.jsp?patient=<%=patientName%>" class="btn btn-action btn-sm">Prescribe</a>
<a href="doctorAdvice.jsp?patient=<%=patientName%>" class="btn btn-action btn-sm ms-2">Advice</a>
</td>
</tr>
<%
}

if(!hasAppointments){
%>
<tr>
<td colspan="4" class="text-center text-muted py-4">No appointments found</td>
</tr>
<%
}

} catch(Exception e){
    out.println("<tr><td colspan='4' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
} finally {
    try{if(rs!=null)rs.close();}catch(Exception e){}
    try{if(st!=null)st.close();}catch(Exception e){}
    try{if(con!=null)con.close();}catch(Exception e){}
}
%>

</tbody>
</table>
</div>

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
