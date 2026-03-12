import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class ForgotServlet extends HttpServlet {

protected void doPost(HttpServletRequest req, HttpServletResponse res)
throws ServletException, IOException {

Connection con = null;
Statement st = null;
ResultSet rs = null;

try{

String email = req.getParameter("email");
String newPass = PasswordHash.hash(req.getParameter("newpassword"));
String confirmPass = PasswordHash.hash(req.getParameter("confirmpassword"));

if(!newPass.equals(confirmPass)){
    res.sendRedirect("forgot.html?error=match");
    return;
}

con = DBConnection.getConnection();
st = con.createStatement();

rs = st.executeQuery("SELECT USER_ID FROM USERS WHERE EMAIL='"+email+"'");

if(rs.next()){
    st.executeUpdate("UPDATE USERS SET PASSWORD='"+newPass+"' WHERE EMAIL='"+email+"'");
    res.sendRedirect("index.html?msg=reset");
} else {
    res.sendRedirect("forgot.html?error=notfound");
}

}catch(Exception e){ 
    e.printStackTrace(); 
} finally {
    DBConnection.close(con, st, rs);
}
}
}