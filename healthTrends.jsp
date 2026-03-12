<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
HttpSession s = request.getSession(false);
if(s==null || s.getAttribute("user_id")==null){
    response.sendRedirect("index.html");
    return;
}

int uid = (int)s.getAttribute("user_id");

// Build trend data
StringBuilder dates = new StringBuilder();
StringBuilder bmiData = new StringBuilder();
StringBuilder stepsData = new StringBuilder();
StringBuilder heartData = new StringBuilder();

Connection con = null;
Statement st = null;
ResultSet rs = null;

try{
Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
st = con.createStatement();

rs = st.executeQuery("SELECT TO_CHAR(TIMESTAMP,'DD-Mon') as dt, HEIGHT, WEIGHT, STEPS, HEART_RATE FROM FITNESS_DATA WHERE USER_ID="+uid+" ORDER BY TIMESTAMP DESC FETCH FIRST 10 ROWS ONLY");

boolean first = true;
while(rs.next()){
    double h = rs.getDouble("HEIGHT");
    double w = rs.getDouble("WEIGHT");
    int steps = rs.getInt("STEPS");
    int heart = rs.getInt("HEART_RATE");
    double bmi = (h > 0 && w > 0) ? w/((h/100)*(h/100)) : 0;
    
    if(!first) {
        dates.append(",");
        bmiData.append(",");
        stepsData.append(",");
        heartData.append(",");
    }
    dates.append("'").append(rs.getString("dt")).append("'");
    bmiData.append(String.format("%.1f", bmi));
    stepsData.append(steps);
    heartData.append(heart);
    first = false;
}

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
<title>Health Trends - MedAxis</title>
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

h5{color: var(--muted-light);}

.btn-add{
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border: none;
    border-radius: 10px;
    color: white;
    font-weight: 600;
    padding: 12px 24px;
}

.btn-add:hover{
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
<a href="healthTrends.jsp" class="active">Trends</a>
<a href="appointment.jsp">Appointments</a>
<a href="calendar.jsp">Calendar</a>
<a href="profile.jsp">Profile</a>
<a href="ai.jsp">AI Assistant</a>
<div class="divider"></div>
<a href="#" onclick="toggleDarkMode(); return false;">
    <span id="modeText">Dark Mode</span>
</a>
<a href="LogoutServlet">Logout</a>
</div>

<div class="main">

<h2 class="page-header">Your Health Trends</h2>

<div class="row">
<div class="col-md-6 mb-4">
<div class="card">
<h5 class="text-muted mb-3">BMI Trend</h5>
<canvas id="bmiChart"></canvas>
</div>
</div>
<div class="col-md-6 mb-4">
<div class="card">
<h5 class="text-muted mb-3">Daily Steps</h5>
<canvas id="stepsChart"></canvas>
</div>
</div>
</div>

<div class="row">
<div class="col-md-6 mb-4">
<div class="card">
<h5 class="text-muted mb-3">Heart Rate</h5>
<canvas id="heartChart"></canvas>
</div>
</div>
<div class="col-md-6 mb-4">
<div class="card">
<h5 class="text-muted mb-3">Health Summary</h5>
<div style="background:#f0f7ff;padding:15px;border-radius:10px;border-left:4px solid var(--primary);">
<p><strong style="color:var(--primary);">Analysis:</strong></p>
<p>Track your health metrics over time to identify patterns and improvements.</p>
<p class="mb-0">Consistent tracking leads to better health outcomes!</p>
</div>
<a href="health.jsp" class="btn btn-add w-100">+ Add New Entry</a>
</div>
</div>
</div>

</div>

<script>
const dates = [<%=dates.toString()%>];
const bmiData = [<%=bmiData.toString()%>];
const stepsData = [<%=stepsData.toString()%>];
const heartData = [<%=heartData.toString()%>];

// Reverse for chronological order
dates.reverse();
bmiData.reverse();
stepsData.reverse();
heartData.reverse();

// BMI Chart
new Chart(document.getElementById('bmiChart'), {
    type: 'line',
    data: {
        labels: dates,
        datasets: [{
            label: 'BMI',
            data: bmiData,
            borderColor: '#00b4b4',
            backgroundColor: 'rgba(0,180,180,0.1)',
            fill: true,
            tension: 0.4
        }]
    },
    options: {
        responsive: true,
        scales: {
            y: { beginAtZero: false }
        }
    }
});

// Steps Chart
new Chart(document.getElementById('stepsChart'), {
    type: 'bar',
    data: {
        labels: dates,
        datasets: [{
            label: 'Steps',
            data: stepsData,
            backgroundColor: '#20b2aa'
        }]
    },
    options: {
        responsive: true,
        scales: {
            y: { beginAtZero: true }
        }
    }
});

// Heart Rate Chart
new Chart(document.getElementById('heartChart'), {
    type: 'line',
    data: {
        labels: dates,
        datasets: [{
            label: 'Heart Rate (bpm)',
            data: heartData,
            borderColor: '#dc3545',
            backgroundColor: 'rgba(220,53,69,0.1)',
            fill: true,
            tension: 0.4
        }]
    },
    options: {
        responsive: true,
        scales: {
            y: { beginAtZero: false, min: 40, max: 150 }
        }
    }
});
</script>

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
