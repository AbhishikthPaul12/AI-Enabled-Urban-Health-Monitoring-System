<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
HttpSession s = request.getSession(false);
if(s==null || s.getAttribute("user_id")==null){
    response.sendRedirect("index.html");
    return;
}

int uid = (int)s.getAttribute("user_id");
double h=0,w=0;
int steps=0,heart=0;

Connection con = null;
Statement st = null;
ResultSet rs = null;

try{
Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
st = con.createStatement();
rs = st.executeQuery("SELECT * FROM (SELECT * FROM FITNESS_DATA WHERE USER_ID="+uid+" ORDER BY TIMESTAMP DESC) WHERE ROWNUM=1");
if(rs.next()){
    h = rs.getDouble("HEIGHT");
    w = rs.getDouble("WEIGHT");
    steps = rs.getInt("STEPS");
    heart = rs.getInt("HEART_RATE");
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
<title>AI Health Assistant - MedAxis</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@4.10.0/dist/tf.min.js"></script>
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
}

.metric-card{
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    padding: 25px;
    border-radius: 16px;
}

.score-card{
    background: linear-gradient(135deg, #00d4aa, #00a8e8);
    color: white;
    padding: 25px;
    border-radius: 16px;
}

.btn-ai{
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border: none;
    border-radius: 10px;
    padding: 16px;
    font-weight: 600;
    font-size: 16px;
    color: white;
    transition: all 0.3s;
}

.btn-ai:hover{
    background: linear-gradient(135deg, var(--primary-dark), var(--primary));
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0,102,204,0.3);
}

.suggestion-item{
    border-left: 4px solid var(--primary);
    margin-bottom: 10px;
    padding: 15px;
    background: #f8fbff;
    border-radius: 0 10px 10px 0;
}

.page-header{
    color: var(--primary);
    font-weight: 700;
    margin-bottom: 25px;
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
<a href="calendar.jsp">Calendar</a>
<a href="profile.jsp">Profile</a>
<a href="ai.jsp" class="active">AI Assistant</a>
<div class="divider"></div>
<a href="#" onclick="toggleDarkMode(); return false;">
    <span id="modeText">Dark Mode</span>
</a>
<a href="LogoutServlet">Logout</a>
</div>

<div class="main">

<h2 class="page-header">AI Health Assistant</h2>
<p class="text-muted mb-4">Powered by TensorFlow.js Machine Learning</p>

<div id="healthData" data-height="<%=h%>" data-weight="<%=w%>" data-steps="<%=steps%>" data-heart="<%=heart%>"></div>

<div class="row g-4">
<div class="col-md-6">
<div class="card metric-card">
<h5>Your Health Metrics</h5>
<div class="mt-3">
<p class="mb-2"><strong>Height:</strong> <%=h%> cm</p>
<p class="mb-2"><strong>Weight:</strong> <%=w%> kg</p>
<p class="mb-2"><strong>Steps:</strong> <%=steps%></p>
<p class="mb-2"><strong>Heart Rate:</strong> <%=heart%> bpm</p>
<p class="mb-0"><strong id="bmiDisplay">BMI: Calculating...</strong></p>
</div>
</div>
</div>
<div class="col-md-6">
<div class="card score-card">
<h5>AI Risk Assessment</h5>
<div class="mt-3">
<p class="mb-2" id="riskLevel">Analyzing...</p>
<p class="mb-0"><strong id="healthScore">Score: --</strong></p>
</div>
</div>
</div>
</div>

<div class="card mt-4 p-4">
<h5 class="mb-3">Personalized AI Suggestions</h5>
<div id="aiSuggestions">
<p class="text-muted">Click below to generate AI recommendations based on your health data</p>
</div>
<button class="btn btn-ai w-100 mt-3" onclick="generateAIAdvice()">
Generate AI Health Advice
</button>
</div>

</div>

<script>
const healthData = document.getElementById('healthData');
const height = parseFloat(healthData.dataset.height) || 0;
const weight = parseFloat(healthData.dataset.weight) || 0;
const steps = parseInt(healthData.dataset.steps) || 0;
const heartRate = parseInt(healthData.dataset.heart) || 0;

// Calculate BMI
let bmi = 0;
if(height > 0 && weight > 0) {
    bmi = weight / ((height/100) * (height/100));
}
document.getElementById('bmiDisplay').innerText = 'BMI: ' + bmi.toFixed(2);

// AI Health Score Calculation using TensorFlow.js
async function calculateHealthScore() {
    if(height === 0 || weight === 0) {
        document.getElementById('riskLevel').innerText = 'No data available';
        return;
    }
    
    // Normalize inputs (simple normalization)
    const bmiNorm = Math.min(bmi / 40, 1);
    const stepsNorm = Math.min(steps / 10000, 1);
    const heartNorm = heartRate > 60 && heartRate < 100 ? 1 : 0.5;
    
    // Create a simple neural network
    const model = tf.sequential({
        layers: [
            tf.layers.dense({inputShape: [3], units: 8, activation: 'relu'}),
            tf.layers.dense({units: 4, activation: 'relu'}),
            tf.layers.dense({units: 1, activation: 'sigmoid'})
        ]
    });
    
    // Input tensor
    const input = tf.tensor2d([[bmiNorm, stepsNorm, heartNorm]]);
    
    // Predict (using untrained model for demo - in production, load trained model)
    const prediction = model.predict(input);
    const score = (await prediction.data())[0] * 100;
    
    document.getElementById('healthScore').innerText = 'AI Health Score: ' + score.toFixed(1) + '/100';
    
    let risk = 'Low Risk';
    if(score < 40) risk = 'High Risk';
    else if(score < 70) risk = 'Moderate Risk';
    document.getElementById('riskLevel').innerText = risk;
    
    tf.dispose([input, prediction, model]);
}

// Generate AI Suggestions
function generateAIAdvice() {
    const suggestions = [];
    
    // BMI-based suggestions
    if(bmi < 18.5) {
        suggestions.push({icon: 'NUTRITION:', title: 'Nutrition Focus', text: 'Your BMI indicates underweight. Increase calorie intake with nutrient-dense foods like nuts, avocados, and lean proteins.'});
    } else if(bmi >= 25 && bmi < 30) {
        suggestions.push({icon: 'WEIGHT:', title: 'Weight Management', text: 'Your BMI indicates overweight. Aim for 150 minutes of moderate exercise weekly and reduce processed food intake.'});
    } else if(bmi >= 30) {
        suggestions.push({icon: 'ALERT:', title: 'Health Priority', text: 'Your BMI indicates obesity. Consider consulting a healthcare provider for a personalized weight management plan.'});
    } else {
        suggestions.push({icon: 'GOOD:', title: 'Healthy Weight', text: 'Your BMI is in the healthy range. Maintain it with balanced nutrition and regular exercise.'});
    }
    
    // Steps-based suggestions
    if(steps < 3000) {
        suggestions.push({icon: 'ACTIVITY:', title: 'Activity Boost', text: 'Very low step count detected. Start with short 10-minute walks after meals to improve circulation.'});
    } else if(steps < 8000) {
        suggestions.push({icon: 'GOAL:', title: 'Step Goal', text: 'Good start! Try to reach 8,000 steps daily for cardiovascular health benefits.'});
    } else {
        suggestions.push({icon: 'GREAT:', title: 'Excellent Activity', text: 'Great step count! You are exceeding daily activity recommendations.'});
    }
    
    // Heart rate-based suggestions
    if(heartRate > 100) {
        suggestions.push({icon: 'HEART:', title: 'Heart Health', text: 'Elevated resting heart rate. Practice stress management techniques like deep breathing or meditation.'});
    } else if(heartRate > 0 && heartRate < 60) {
        suggestions.push({icon: 'FITNESS:', title: 'Athletic Heart', text: 'Low resting heart rate may indicate good cardiovascular fitness, or consult doctor if feeling unwell.'});
    } else if(heartRate >= 60 && heartRate <= 100) {
        suggestions.push({icon: 'HEART:', title: 'Normal Heart Rate', text: 'Your resting heart rate is within the healthy range of 60-100 bpm.'});
    }
    
    // General wellness suggestions
    suggestions.push({icon: 'WATER:', title: 'Hydration', text: 'Drink at least 8 glasses of water daily for optimal body function.'});
    suggestions.push({icon: 'SLEEP:', title: 'Sleep', text: 'Aim for 7-9 hours of quality sleep to support recovery and mental health.'});
    
    // Display suggestions
    const container = document.getElementById('aiSuggestions');
    container.innerHTML = '';
    
    suggestions.forEach(s => {
        const item = document.createElement('div');
        item.className = 'list-group-item list-group-item-action';
        item.innerHTML = '<h6 class="mb-1"><span class="badge bg-primary me-2">' + s.icon + '</span>' + s.title + '</h6><p class="mb-1 small">' + s.text + '</p>';
        container.appendChild(item);
    });
}

// Run on load
calculateHealthScore();

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