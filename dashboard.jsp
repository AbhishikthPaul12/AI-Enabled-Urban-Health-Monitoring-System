<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
HttpSession s = request.getSession(false);
if(s==null || s.getAttribute("user_id")==null || !"user".equals(s.getAttribute("role"))){
    response.sendRedirect("index.html");
    return;
}

int uid = (int)s.getAttribute("user_id");
String userName = (String)s.getAttribute("user_name");

/* ---------- VARIABLES ---------- */
double h=0,w=0;
int steps=0,heart=0;
String doctor="None";
String adate="None";
String city="Not set";
String phone="Not set";
String uname="";
String uemail="";

/* ---------- DB ---------- */
Connection con = null;
Statement st = null;
ResultSet rs = null;
ResultSet rs2 = null;
ResultSet ru = null;
ResultSet rp = null;

try{
Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
st = con.createStatement();

/* USER */
ru = st.executeQuery("SELECT NAME,EMAIL FROM USERS WHERE USER_ID="+uid);
if(ru.next()){
    uname = ru.getString("NAME");
    uemail = ru.getString("EMAIL");
}

rs = st.executeQuery("SELECT * FROM (SELECT * FROM FITNESS_DATA WHERE USER_ID="+uid+" ORDER BY TIMESTAMP DESC) WHERE ROWNUM=1");
if(rs.next()){
    h = rs.getDouble("HEIGHT");
    w = rs.getDouble("WEIGHT");
    steps = rs.getInt("STEPS");
    heart = rs.getInt("HEART_RATE");
}

rs2 = st.executeQuery("SELECT * FROM (SELECT DOCTOR_NAME, TO_CHAR(APPOINTMENT_DATE,'DD-MON-YYYY') d FROM APPOINTMENT WHERE USER_ID="+uid+" ORDER BY APPOINTMENT_DATE DESC) WHERE ROWNUM=1");
if(rs2.next()){
    doctor = rs2.getString("DOCTOR_NAME");
    adate = rs2.getString("d");
}

rp = st.executeQuery("SELECT CITY,PHONE FROM PROFILE WHERE USER_ID="+uid);
if(rp.next()){
    city = rp.getString("CITY");
    phone = rp.getString("PHONE");
}

}catch(Exception e){
    e.printStackTrace();
} finally {
    try{if(rp!=null)rp.close();}catch(Exception e){}
    try{if(rs2!=null)rs2.close();}catch(Exception e){}
    try{if(ru!=null)ru.close();}catch(Exception e){}
    try{if(rs!=null)rs.close();}catch(Exception e){}
    try{if(st!=null)st.close();}catch(Exception e){}
    try{if(con!=null)con.close();}catch(Exception e){}
}

/* BMI */
double bmi=0;
if(h>0 && w>0){
    bmi = w/((h/100)*(h/100));
}

/* GREETING */
String greet="";
int hr = java.time.LocalTime.now().getHour();
if(hr<12) greet="Good Morning";
else if(hr<17) greet="Good Afternoon";
else greet="Good Evening";
%>

<!DOCTYPE html>
<html>
<head>
<title>MedAxis Dashboard</title>

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

.sidebar h4 {
    margin-bottom: 40px;
    font-size: 28px;
    font-weight: 700;
    letter-spacing: 1px;
    text-align: center;
    padding-bottom: 20px;
    border-bottom: 2px solid rgba(255,255,255,0.2);
}

.sidebar a {
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

.sidebar a:hover {
    background: rgba(255,255,255,0.15);
    border-left: 3px solid var(--accent);
    transform: translateX(5px);
}

.sidebar a.active {
    background: rgba(255,255,255,0.2);
    border-left: 3px solid var(--accent);
}

.main {
    margin-left: 280px;
    padding: 30px;
}

.card {
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0,102,204,0.1);
    border: none;
    background: var(--card-light);
    transition: all 0.3s ease;
}

.card:hover {
    box-shadow: 0 8px 30px rgba(0,102,204,0.15);
}

.welcome {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    padding: 25px 35px;
    border-radius: 16px;
    margin-bottom: 25px;
    box-shadow: 0 10px 40px rgba(0,102,204,0.2);
}

.stat-card {
    padding: 30px;
    text-align: center;
    transition: all 0.3s;
}

.stat-card:hover {
    transform: translateY(-5px);
}

.stat-number {
    font-size: 42px;
    font-weight: 700;
    color: var(--primary);
}

.health-icon {
    font-size: 40px;
    color: var(--primary);
    margin-bottom: 15px;
    font-weight: 300;
}

.text-muted {
    color: var(--muted-light) !important;
}

.btn-primary-custom {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border: none;
    border-radius: 10px;
    color: white;
    font-weight: 600;
    transition: all 0.3s;
}

.btn-primary-custom:hover {
    background: linear-gradient(135deg, var(--primary-dark), var(--primary));
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0,102,204,0.3);
}

.divider {
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
<a href="dashboard.jsp" class="active">Dashboard</a>
<a href="health.jsp">Health</a>
<a href="healthTrends.jsp">Trends</a>
<a href="appointment.jsp">Appointments</a>
<a href="calendar.jsp">Calendar</a>
<a href="patientMedicalHistory.jsp">Medical History</a>
<a href="profile.jsp">Profile</a>
<a href="ai.jsp">AI Assistant</a>
<a href="LogoutServlet">Logout</a>
</div>

<button class="theme-toggle" onclick="toggleDarkMode()" title="Toggle Dark Mode">
    <span id="themeIcon">&#9788;</span>
</button>

<div class="main">

<div class="welcome">
<div class="row align-items-center">
<div class="col-md-8">
<h3><%=greet%>, <%=userName!=null?userName:uname%></h3>
<p class="mb-0"><%=uemail%></p>
</div>
<div class="col-md-4 text-end">
<button onclick="generatePDF()" class="btn btn-light" style="border-radius:10px;color:#e94560;font-weight:600;">
Export Report
</button>
</div>
</div>
</div>

<div class="row g-4">

<div class="col-md-3">
<div class="card stat-card">
<div class="health-icon">P</div>
<h5 class="text-muted">Profile</h5>
<p class="mb-1">City: <b style="color:var(--primary);"><%=city%></b></p>
<p class="mb-3">Phone: <b style="color:var(--primary);"><%=phone%></b></p>
<a href="profile.jsp" class="btn btn-primary-custom w-100">Edit Profile</a>
</div>
</div>

<div class="col-md-3">
<div class="card stat-card">
<div class="health-icon">H</div>
<h5 class="text-muted">Health Stats</h5>
<p class="mb-1">BMI: <b style="color:var(--primary);"><%=String.format("%.2f",bmi)%></b></p>
<p class="mb-1">Steps: <b style="color:var(--primary);"><%=steps%></b></p>
<p class="mb-3">Heart: <b style="color:var(--primary);"><%=heart%> bpm</b></p>
<a href="health.jsp" class="btn btn-primary-custom w-100">Update Health</a>
</div>
</div>

<div class="col-md-3">
<div class="card stat-card">
<div class="health-icon">A</div>
<h5 class="text-muted">Appointment</h5>
<p class="mb-1">Doctor: <b style="color:var(--primary);"><%=doctor%></b></p>
<p class="mb-3">Date: <b style="color:var(--primary);"><%=adate%></b></p>
<a href="appointment.jsp" class="btn btn-primary-custom w-100">Manage</a>
</div>
</div>

<div class="col-md-3">
<div class="card stat-card">
<div class="health-icon">AI</div>
<h5 class="text-muted">AI Assistant</h5>
<p class="small text-muted mb-3">Get personalized health insights powered by AI</p>
<a href="ai.jsp" class="btn btn-primary-custom w-100">Get AI Advice</a>
</div>
</div>

</div>

</div>

<script>
// Toast Notification System
function showToast(message, type = 'success') {
    const container = document.getElementById('toastContainer');
    if(!container) return;
    const toast = document.createElement('div');
    toast.className = `toast align-items-center text-white bg-${type} border-0 show`;
    toast.style.minWidth = '300px';
    toast.style.marginBottom = '10px';
    toast.style.borderRadius = '12px';
    toast.style.boxShadow = '0 4px 15px rgba(0,0,0,0.2)';
    toast.innerHTML = `<div class="d-flex"><div class="toast-body fw-semibold">${message}</div><button type="button" class="btn-close btn-close-white me-2 m-auto" onclick="this.parentElement.parentElement.remove()"></button></div>`;
    container.appendChild(toast);
    setTimeout(() => toast.remove(), 4000);
}

// Dark Mode
function toggleDarkMode() {
    const body = document.body;
    const isDark = body.classList.toggle('dark-mode');
    localStorage.setItem('darkMode', isDark);
    const themeIcon = document.getElementById('themeIcon');
    if(themeIcon) themeIcon.innerHTML = isDark ? '&#9790;' : '&#9788;';
    showToast(isDark ? 'Dark mode enabled' : 'Light mode enabled', 'info');
}

// Load saved dark mode preference
if(localStorage.getItem('darkMode') === 'true') {
    document.body.classList.add('dark-mode');
    const themeIcon = document.getElementById('themeIcon');
    if(themeIcon) themeIcon.innerHTML = '&#9790;';
}

// Language Support
const translations = {en:{dashboard:'Dashboard',health:'Health',appointments:'Appointments'},hi:{dashboard:'डैशबोर्ड',health:'स्वास्थ्य',appointments:'अपॉइंटमेंट'}};
function changeLanguage(lang) {
    localStorage.setItem('language', lang);
    showToast(lang === 'hi' ? 'भाषा बदली' : 'Language changed', 'success');
}

// Gamification
function checkAchievements() {
    const steps = <%=steps%>;
    const bmi = <%=bmi%>;
    if(steps >= 10000) showToast('ACHIEVEMENT: Step Master! (10,000+ steps)', 'warning');
    if(bmi >= 18.5 && bmi <= 25) showToast('ACHIEVEMENT: Healthy BMI!', 'success');
    if(steps >= 8000 && steps < 10000) showToast('ACHIEVEMENT: Active Lifestyle! (8,000+ steps)', 'info');
}
setTimeout(checkAchievements, 1500);

// PDF Generation with Times New Roman
function generatePDF() {
    const now = new Date().toLocaleString();
    const steps = <%=steps%>;
    const bmi = <%=bmi%>;
    const heart = <%=heart%>;
    
    const reportHTML = `
<!DOCTYPE html>
<html>
<head>
<style>
body { font-family: 'Times New Roman', Times, serif; margin: 40px; color: #333; }
h1 { text-align: center; color: #0066cc; border-bottom: 2px solid #0066cc; padding-bottom: 10px; }
h2 { color: #0066cc; margin-top: 30px; }
.info { background: #f0f7ff; padding: 15px; border-left: 4px solid #0066cc; margin: 20px 0; }
.metric { margin: 10px 0; }
.achievement { margin: 5px 0; }
.check { color: #00d4aa; font-weight: bold; }
.uncheck { color: #999; }
.footer { margin-top: 40px; text-align: center; font-size: 12px; color: #666; border-top: 1px solid #ddd; padding-top: 20px; }
</style>
</head>
<body>
<h1>MEDAXIS HEALTH REPORT</h1>
<p style="text-align: center; color: #666;">Generated: ${now}</p>

<h2>Patient Information</h2>
<div class="info">
<p class="metric"><strong>Name:</strong> <%=userName!=null?userName:uname%></p>
<p class="metric"><strong>Email:</strong> <%=uemail%></p>
</div>

<h2>Health Metrics</h2>
<p class="metric"><strong>BMI:</strong> <%=String.format("%.2f",bmi)%></p>
<p class="metric"><strong>Steps:</strong> <%=steps%></p>
<p class="metric"><strong>Heart Rate:</strong> <%=heart%> bpm</p>

<h2>Achievements</h2>
<p class="achievement">${steps >= 10000 ? '<span class="check">[COMPLETED]</span>' : '<span class="uncheck">[PENDING]</span>'} Step Master (10,000+ steps)</p>
<p class="achievement">${bmi >= 18.5 && bmi <= 25 ? '<span class="check">[COMPLETED]</span>' : '<span class="uncheck">[PENDING]</span>'} Healthy BMI</p>
<p class="achievement">${steps >= 8000 ? '<span class="check">[COMPLETED]</span>' : '<span class="uncheck">[PENDING]</span>'} Active Lifestyle (8,000+ steps)</p>

<h2>Recommendations</h2>
<p>${bmi > 25 ? 'Consider weight management program' : 'Maintain healthy weight'}</p>
<p>${steps < 5000 ? 'Increase daily activity' : 'Keep up the good activity level'}</p>
<p>${heart > 100 ? 'Monitor heart rate regularly' : 'Heart rate in healthy range'}</p>

<div class="footer">
<p>MedAxis Health Management System</p>
<p>This report is generated for informational purposes only.</p>
<p>Please consult with your healthcare provider for medical advice.</p>
</div>
</body>
</html>`;
    
    const blob = new Blob([reportHTML], {type: 'text/html'});
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'Health_Report_<%=userName!=null?userName:uname%>.html';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    showToast('Health report downloaded!', 'success');
}
</script>

<div id="toastContainer" class="position-fixed top-0 end-0 p-3" style="z-index:1050;"></div>

</body>
</html>