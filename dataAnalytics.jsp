<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
HttpSession s = request.getSession(false);
if(s==null || s.getAttribute("user_id")==null || !"admin".equals(s.getAttribute("role"))){
    response.sendRedirect("index.html");
    return;
}

// Analytics data
int totalUsers = 0;
int activeUsers = 0;
double avgBMI = 0;
int avgSteps = 0;
int highRiskUsers = 0;
int normalRiskUsers = 0;
int lowRiskUsers = 0;

// Monthly appointments data
StringBuilder monthLabels = new StringBuilder();
StringBuilder monthData = new StringBuilder();

Connection con = null;
Statement st = null;
ResultSet rs = null;

try{
Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
st = con.createStatement();

rs = st.executeQuery("SELECT COUNT(*) FROM USERS WHERE ROLE='user'");
if(rs.next()) totalUsers = rs.getInt(1);
rs.close();

rs = st.executeQuery("SELECT COUNT(DISTINCT USER_ID) FROM FITNESS_DATA WHERE TIMESTAMP > SYSDATE - 7");
if(rs.next()) activeUsers = rs.getInt(1);
rs.close();

rs = st.executeQuery("SELECT AVG(WEIGHT/((HEIGHT/100)*(HEIGHT/100))) FROM FITNESS_DATA WHERE HEIGHT > 0 AND WEIGHT > 0");
if(rs.next()) avgBMI = rs.getDouble(1);
rs.close();

rs = st.executeQuery("SELECT AVG(STEPS) FROM FITNESS_DATA");
if(rs.next()) avgSteps = rs.getInt(1);
rs.close();

// Risk analysis
rs = st.executeQuery("SELECT COUNT(*) FROM FITNESS_DATA WHERE WEIGHT/((HEIGHT/100)*(HEIGHT/100)) > 30");
if(rs.next()) highRiskUsers = rs.getInt(1);
rs.close();

rs = st.executeQuery("SELECT COUNT(*) FROM FITNESS_DATA WHERE WEIGHT/((HEIGHT/100)*(HEIGHT/100)) BETWEEN 25 AND 30");
if(rs.next()) normalRiskUsers = rs.getInt(1);
rs.close();

rs = st.executeQuery("SELECT COUNT(*) FROM FITNESS_DATA WHERE WEIGHT/((HEIGHT/100)*(HEIGHT/100)) < 25");
if(rs.next()) lowRiskUsers = rs.getInt(1);
rs.close();

// Monthly data
rs = st.executeQuery("SELECT TO_CHAR(APPOINTMENT_DATE,'Mon') month, COUNT(*) cnt FROM APPOINTMENT WHERE APPOINTMENT_DATE > SYSDATE - 180 GROUP BY TO_CHAR(APPOINTMENT_DATE,'Mon'), TO_CHAR(APPOINTMENT_DATE,'MM') ORDER BY TO_CHAR(APPOINTMENT_DATE,'MM')");
boolean first = true;
while(rs.next()){
    if(!first) {
        monthLabels.append(",");
        monthData.append(",");
    }
    monthLabels.append("'").append(rs.getString("month")).append("'");
    monthData.append(rs.getInt("cnt"));
    first = false;
}
rs.close();

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
<title>Data Analytics - MedAxis</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
body{background:#f8f9fa;}
.sidebar{height:100vh;width:250px;position:fixed;background:#212529;color:white;padding:20px;}
.sidebar a{display:block;color:white;margin:15px 0;text-decoration:none;padding:10px;border-radius:5px;}
.sidebar a:hover{background:#495057;}
.main{margin-left:270px;padding:30px;}
.card{border-radius:15px;box-shadow:0 4px 15px rgba(0,0,0,0.1);}
.stat-card{text-align:center;padding:25px;}
.stat-number{font-size:32px;font-weight:bold;color:#0d6efd;}
</style>
</head>

<body>

<div class="sidebar">
<h4>Analytics</h4>
<a href="adminDashboard.jsp">Dashboard</a>
<a href="dbReport.jsp">Database Schema</a>
<a href="dataAnalytics.jsp" style="background:#495057;">Data Analytics</a>
<a href="adminUsers.jsp">Manage Users</a>
<a href="LogoutServlet">Logout</a>
</div>

<div class="main">

<h2 class="mb-4">Health Data Analytics</h2>

<div class="row mb-4">
<div class="col-md-3">
<div class="card stat-card">
<div class="stat-number"><%=totalUsers%></div>
<h6>Total Users</h6>
</div>
</div>
<div class="col-md-3">
<div class="card stat-card">
<div class="stat-number" style="color:#198754;"><%=activeUsers%></div>
<h6>Active (7 days)</h6>
</div>
</div>
<div class="col-md-3">
<div class="card stat-card">
<div class="stat-number" style="color:#dc3545;"><%=String.format("%.1f", avgBMI)%></div>
<h6>Average BMI</h6>
</div>
</div>
<div class="col-md-3">
<div class="card stat-card">
<div class="stat-number" style="color:#ffc107;"><%=avgSteps%></div>
<h6>Avg Daily Steps</h6>
</div>
</div>
</div>

<div class="row mb-4">
<div class="col-md-6">
<div class="card p-4">
<h5 class="mb-3">Health Risk Distribution</h5>
<canvas id="riskChart"></canvas>
</div>
</div>
<div class="col-md-6">
<div class="card p-4">
<h5 class="mb-3">Monthly Appointments Trend</h5>
<canvas id="trendChart"></canvas>
</div>
</div>
</div>

<div class="card p-4">
<h5 class="mb-3">Insights & Recommendations</h5>
<div class="row">
<div class="col-md-4">
<div class="alert alert-info">
<h6>BMI Analysis</h6>
<p class="small">Average BMI of <%=String.format("%.1f", avgBMI)%> indicates 
<%= avgBMI > 25 ? "overweight population. Recommend diet programs." : "healthy population. Maintain current programs." %></p>
</div>
</div>
<div class="col-md-4">
<div class="alert alert-warning">
<h6>Activity Level</h6>
<p class="small">Average <%=avgSteps%> steps/day. 
<%= avgSteps < 5000 ? "Below recommended 8,000 steps. Launch step challenges." : "Good activity level. Keep motivating users!" %></p>
</div>
</div>
<div class="col-md-4">
<div class="alert alert-success">
<h6>User Engagement</h6>
<p class="small"><%=activeUsers%> users active in last 7 days (<%= totalUsers > 0 ? (activeUsers*100/totalUsers) : 0 %>%). 
<%= activeUsers < totalUsers/2 ? "Send engagement reminders." : "Strong engagement!" %></p>
</div>
</div>
</div>
</div>

</div>

<script>
// Risk Chart
new Chart(document.getElementById('riskChart'), {
    type: 'pie',
    data: {
        labels: ['Low Risk (BMI < 25)', 'Moderate Risk (BMI 25-30)', 'High Risk (BMI > 30)'],
        datasets: [{
            data: [<%=lowRiskUsers%>, <%=normalRiskUsers%>, <%=highRiskUsers%>],
            backgroundColor: ['#198754', '#ffc107', '#dc3545']
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: { position: 'bottom' }
        }
    }
});

// Trend Chart
new Chart(document.getElementById('trendChart'), {
    type: 'line',
    data: {
        labels: [<%=monthLabels.toString()%>],
        datasets: [{
            label: 'Appointments',
            data: [<%=monthData.toString()%>],
            borderColor: '#0d6efd',
            backgroundColor: 'rgba(13, 110, 253, 0.1)',
            fill: true,
            tension: 0.4
        }]
    },
    options: {
        responsive: true,
        scales: {
            y: { beginAtZero: true }
        }
    }
});
</script>

</body>
</html>
