<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
HttpSession s = request.getSession(false);
if(s==null || s.getAttribute("user_id")==null || !"doctor".equals(s.getAttribute("role"))){
    response.sendRedirect("index.html");
    return;
}

String doctorName = (String)s.getAttribute("user_name");
String selectedPatient = request.getParameter("patient");
%>

<!DOCTYPE html>
<html>
<head>
<title>Medical Advice - MedAxis Doctor</title>
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
    padding: 40px;
}

.page-header{
    color: var(--primary);
    font-weight: 700;
    margin-bottom: 30px;
}

.form-control{
    border-radius: 10px;
    border: 2px solid #e0e8f0;
    padding: 14px;
    font-size: 15px;
    margin-bottom: 20px;
    background: #fafbfc;
    transition: all 0.3s;
}

.form-control:focus{
    border-color: var(--primary);
    box-shadow: 0 0 0 0.2rem rgba(0,102,204,0.15);
    background: white;
}

.form-label{
    color: var(--muted-light);
    font-weight: 600;
    font-size: 14px;
}

.btn-submit{
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border: none;
    border-radius: 10px;
    padding: 16px;
    font-weight: 600;
    font-size: 16px;
    transition: all 0.3s;
}

.btn-submit:hover{
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
<a href="doctorDashboard.jsp">Dashboard</a>
<a href="doctorAppointments.jsp">My Appointments</a>
<a href="doctorPatients.jsp">My Patients</a>
<a href="doctorPrescription.jsp">New Prescription</a>
<a href="doctorViewPrescriptions.jsp">Past Prescriptions</a>
<a href="doctorAdvice.jsp" class="active">New Advice</a>
<a href="doctorViewAdvice.jsp">Past Advice</a>
<a href="LogoutServlet">Logout</a>
<div class="divider"></div>
<a href="#" onclick="toggleDarkMode(); return false;">
    <span id="modeText">Dark Mode</span>
</a>
</div>

<div class="main">

<h2 class="page-header">Send Medical Advice</h2>

<div class="row justify-content-center">
<div class="col-md-8">
<div class="card">

<form action="AdviceServlet" method="post">

<div class="mb-4">
<label class="form-label">Patient Name</label>
<input type="text" name="patientName" class="form-control" value="<%=selectedPatient != null ? selectedPatient : ""%>" placeholder="Enter patient name" required>
</div>

<div class="mb-4">
<label class="form-label">Advice Category</label>
<select name="category" class="form-control" required>
<option value="">Select category</option>
<option value="Diet">Diet & Nutrition</option>
<option value="Exercise">Exercise & Fitness</option>
<option value="Lifestyle">Lifestyle Changes</option>
<option value="Medication">Medication Reminder</option>
<option value="General">General Health</option>
</select>
</div>

<div class="mb-4">
<label class="form-label">Medical Advice</label>
<textarea name="advice" class="form-control" rows="6" placeholder="Enter your medical advice for the patient..." required></textarea>
</div>

<div class="mb-4">
<label class="form-label">Priority</label>
<select name="priority" class="form-control">
<option value="Normal">Normal</option>
<option value="High">High</option>
<option value="Urgent">Urgent</option>
</select>
</div>

<button type="submit" class="btn btn-submit w-100 text-white">Send Advice</button>

</form>

</div>
</div>
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
