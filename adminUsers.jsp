<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
HttpSession s = request.getSession(false);
if(s==null || s.getAttribute("user_id")==null || !"admin".equals(s.getAttribute("role"))){
    response.sendRedirect("index.html");
    return;
}

String message = "";
String msgType = "";

// Handle delete request
String deleteId = request.getParameter("delete");
if(deleteId != null) {
    Connection con = null;
    Statement st = null;
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
        st = con.createStatement();
        st.executeUpdate("DELETE FROM USERS WHERE USER_ID="+deleteId);
        message = "User deleted successfully";
        msgType = "success";
    } catch(Exception e) {
        message = "Error: " + e.getMessage();
        msgType = "danger";
    } finally {
        try{if(st!=null)st.close();}catch(Exception e){}
        try{if(con!=null)con.close();}catch(Exception e){}
    }
}

// Handle role update
String updateId = request.getParameter("updateId");
String newRole = request.getParameter("newRole");
if(updateId != null && newRole != null) {
    Connection con = null;
    Statement st = null;
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
        st = con.createStatement();
        st.executeUpdate("UPDATE USERS SET ROLE='"+newRole+"' WHERE USER_ID="+updateId);
        message = "Role updated successfully";
        msgType = "success";
    } catch(Exception e) {
        message = "Error: " + e.getMessage();
        msgType = "danger";
    } finally {
        try{if(st!=null)st.close();}catch(Exception e){}
        try{if(con!=null)con.close();}catch(Exception e){}
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Manage Users - MedAxis</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
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

.dark-mode .modal-content {
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

.table th{
    background: var(--primary);
    color: white;
}

.btn-action{
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border: none;
    border-radius: 8px;
    color: white;
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
<a href="adminDashboard.jsp">Dashboard</a>
<a href="adminUsers.jsp" class="active">Manage Users</a>
<a href="dataAnalytics.jsp">Analytics</a>
<a href="LogoutServlet">Logout</a>
</div>

<button class="theme-toggle" onclick="toggleDarkMode()" title="Toggle Dark Mode">
    <span id="themeIcon">&#9788;</span>
</button>

<div class="main">

<h2 class="mb-4">User Management</h2>

<% if(!message.isEmpty()) { %>
<div class="alert alert-<%=msgType%> alert-dismissible fade show" role="alert">
<%=message%>
<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<% } %>

<div class="card p-4">
<h5 class="mb-3">All Users</h5>
<div class="table-responsive">
<table class="table table-hover">
<thead>
<tr>
<th>ID</th>
<th>Name</th>
<th>Email</th>
<th>Age</th>
<th>Role</th>
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
rs = st.executeQuery("SELECT USER_ID, NAME, EMAIL, AGE, ROLE FROM USERS ORDER BY USER_ID");

while(rs.next()){
    int uid = rs.getInt("USER_ID");
    String name = rs.getString("NAME");
    String email = rs.getString("EMAIL");
    int age = rs.getInt("AGE");
    String role = rs.getString("ROLE");
%>
<tr>
<td><%=uid%></td>
<td><%=name%></td>
<td><%=email%></td>
<td><%=age%></td>
<td><span class="badge bg-primary"><%=role%></span></td>
<td>
<button class="btn btn-sm btn-warning" onclick="editRole(<%=uid%>, '<%=role%>');">
<i class="bi bi-pencil"></i> Edit
</button>
<a href="adminUsers.jsp?delete=<%=uid%>" class="btn btn-sm btn-danger ms-1" onclick="return confirm('Delete this user?');">
<i class="bi bi-trash"></i>
</a>
</td>
</tr>
<%
}
} catch(Exception e){
    out.println("<tr><td colspan='6' class='text-danger'>Error: "+e.getMessage()+"</td></tr>");
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

<div class="card p-4 mt-4">
<h5 class="mb-3">Quick Actions</h5>
<div class="row">
<div class="col-md-4">
<a href="register.html" class="btn btn-success w-100">
<i class="bi bi-person-plus"></i> Add New User
</a>
</div>
<div class="col-md-4">
<a href="dataAnalytics.jsp" class="btn btn-info w-100">
<i class="bi bi-graph-up"></i> View Analytics
</a>
</div>
<div class="col-md-4">
<a href="dbReport.jsp" class="btn btn-primary w-100">
<i class="bi bi-database"></i> DB Report
</a>
</div>
</div>
</div>

</div>

<!-- Edit Role Modal -->
<div class="modal fade" id="editRoleModal" tabindex="-1">
<div class="modal-dialog">
<div class="modal-content">
<div class="modal-header">
<h5 class="modal-title">Edit User Role</h5>
<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
</div>
<form method="post" action="adminUsers.jsp">
<div class="modal-body">
<input type="hidden" name="updateId" id="updateId">
<div class="mb-3">
<label class="form-label">Select Role</label>
<select name="newRole" class="form-select" id="newRole">
<option value="user">User</option>
<option value="doctor">Doctor</option>
<option value="admin">Admin</option>
</select>
</div>
</div>
<div class="modal-footer">
<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
<button type="submit" class="btn btn-primary">Save Changes</button>
</div>
</form>
</div>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
function editRole(id, currentRole) {
    document.getElementById('updateId').value = id;
    document.getElementById('newRole').value = currentRole;
    new bootstrap.Modal(document.getElementById('editRoleModal')).show();
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
