import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class RegisterServlet extends HttpServlet {

protected void doPost(HttpServletRequest req, HttpServletResponse res)
throws ServletException, IOException {

Connection con = null;
Statement st = null;

try{

String name=req.getParameter("name");
String age=req.getParameter("age");
String email=req.getParameter("email");
String password=PasswordHash.hash(req.getParameter("password"));

con = DBConnection.getConnection();
st = con.createStatement();

String sql = "INSERT INTO USERS (USER_ID, NAME, AGE, EMAIL, PASSWORD, ROLE) VALUES(USER_SEQ.NEXTVAL,'"+name+"',"+age+",'"+email+"','"+password+"','user')";
st.executeUpdate(sql);

res.sendRedirect("index.html?msg=registered");

}catch(Exception e){
e.printStackTrace();
res.getWriter().println("ERROR: "+e);
} finally {
DBConnection.close(con, st);
}
}
}