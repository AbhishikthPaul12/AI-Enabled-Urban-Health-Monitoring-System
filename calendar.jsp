<%@ page import="java.sql.*,java.util.*,java.text.*" %>
<%@ page session="true" %>

<%
HttpSession s = request.getSession(false);
if(s==null || s.getAttribute("user_id")==null){
    response.sendRedirect("index.html");
    return;
}

int uid = (int)s.getAttribute("user_id");

// Get current month
Calendar cal = Calendar.getInstance();
int currentMonth = cal.get(Calendar.MONTH);
int currentYear = cal.get(Calendar.YEAR);

// Build appointment data
Map<String, String> appointments = new HashMap<>();

Connection con = null;
Statement st = null;
ResultSet rs = null;

try{
Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
st = con.createStatement();

rs = st.executeQuery("SELECT TO_CHAR(APPOINTMENT_DATE,'YYYY-MM-DD') as dt, DOCTOR_NAME FROM APPOINTMENT WHERE USER_ID="+uid+" AND EXTRACT(MONTH FROM APPOINTMENT_DATE)="+(currentMonth+1));

while(rs.next()){
    appointments.put(rs.getString("dt"), rs.getString("DOCTOR_NAME"));
}

} catch(Exception e){
    e.printStackTrace();
} finally {
    try{if(rs!=null)rs.close();}catch(Exception e){}
    try{if(st!=null)st.close();}catch(Exception e){}
    try{if(con!=null)con.close();}catch(Exception e){}
}

// Build calendar
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
cal.set(currentYear, currentMonth, 1);
int firstDay = cal.get(Calendar.DAY_OF_WEEK) - 1;
int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
String[] monthNames = {"January","February","March","April","May","June","July","August","September","October","November","December"};
%>

<!DOCTYPE html>
<html>
<head>
<title>Appointment Calendar - MedAxis</title>
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
    padding: 30px;
}

.page-header{
    color: var(--primary);
    font-weight: 700;
    margin-bottom: 30px;
}

.calendar-table{width:100%;}
.calendar-table th{background:linear-gradient(135deg, var(--primary), var(--secondary));color:white;padding:15px;text-align:center;}
.calendar-table td{width:14%;height:80px;border:1px solid #e0e8f0;padding:10px;vertical-align:top;background:white;}
.calendar-table td:hover{background:#f0f7ff;}
.day-number{font-weight:bold;color:var(--primary);font-size:18px;}
.appointment-badge{background:linear-gradient(135deg, var(--primary), var(--secondary));color:white;padding:3px 8px;border-radius:10px;font-size:11px;margin-top:5px;display:inline-block;}
.empty-day{background:#f0f7ff;}

.btn-book{
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border: none;
    border-radius: 10px;
    color: white;
    font-weight: 600;
    padding: 12px 24px;
}

.btn-book:hover{
    background: linear-gradient(135deg, var(--primary-dark), var(--primary));
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0,102,204,0.3);
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
<a href="dashboard.jsp">Dashboard</a>
<a href="health.jsp">Health</a>
<a href="healthTrends.jsp">Trends</a>
<a href="appointment.jsp">Appointments</a>
<a href="calendar.jsp" class="active">Calendar</a>
<a href="profile.jsp">Profile</a>
<a href="ai.jsp">AI Assistant</a>
<div class="divider"></div>
<a href="#" onclick="toggleDarkMode(); return false;">
    <span id="modeText">Dark Mode</span>
</a>
<a href="LogoutServlet">Logout</a>
</div>

<div class="main">

<h2 class="page-header">Appointment Calendar - <%=monthNames[currentMonth]%> <%=currentYear%></h2>

<div class="card">
<table class="calendar-table">
<thead>
<tr>
<th>Sun</th><th>Mon</th><th>Tue</th><th>Wed</th><th>Thu</th><th>Fri</th><th>Sat</th>
</tr>
</thead>
<tbody>
<%
int day = 1;
for(int week = 0; week < 6 && day <= daysInMonth; week++) {
    out.println("<tr>");
    for(int dow = 0; dow < 7; dow++) {
        if((week == 0 && dow < firstDay) || day > daysInMonth) {
            out.println("<td class='empty-day'></td>");
        } else {
            String dateKey = currentYear + "-" + String.format("%02d", currentMonth+1) + "-" + String.format("%02d", day);
            String appt = appointments.get(dateKey);
            out.println("<td>");
            out.println("<div class='day-number'>" + day + "</div>");
            if(appt != null) {
                String displayName = appt.startsWith("Dr.") ? appt : "Dr. " + appt;
                out.println("<span class='appointment-badge'>" + displayName + "</span>");
            }
            out.println("</td>");
            day++;
        }
    }
    out.println("</tr>");
}
%>
</tbody>
</table>

<div class="mt-4 text-center">
<a href="appointment.jsp" class="btn btn-book px-4">+ Book New Appointment</a>
</div>
</div>

</div>

<script>
// Dark Mode
function toggleDarkMode() {
    const body = document.body;
    const isDark = body.classList.toggle('dark-mode');
    localStorage.setItem('darkMode', isDark);
    const modeText = document.getElementById('modeText');
    if(modeText) modeText.textContent = isDark ? 'Light Mode' : 'Dark Mode';
}

// Load saved dark mode preference
if(localStorage.getItem('darkMode') === 'true') {
    document.body.classList.add('dark-mode');
    const modeText = document.getElementById('modeText');
    if(modeText) modeText.textContent = 'Light Mode';
}
</script>

</body>
</html>
