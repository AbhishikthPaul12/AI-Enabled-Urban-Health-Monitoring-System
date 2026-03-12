import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class ProfileServlet extends HttpServlet {

protected void doPost(HttpServletRequest req, HttpServletResponse res)
throws ServletException, IOException {

Connection con = null;
Statement st = null;
ResultSet rs = null;

try{

HttpSession s=req.getSession(false);
int uid=(int)s.getAttribute("user_id");

String city=req.getParameter("city");
String phone=req.getParameter("phone");

con = DBConnection.getConnection();
st = con.createStatement();

rs=st.executeQuery("SELECT * FROM PROFILE WHERE USER_ID="+uid);

if(rs.next()){
st.executeUpdate("UPDATE PROFILE SET CITY='"+city+"', PHONE='"+phone+"' WHERE USER_ID="+uid);
}
else{
st.executeUpdate("INSERT INTO PROFILE VALUES("+uid+",'"+city+"','"+phone+"')");
}

res.sendRedirect("dashboard.jsp");

}catch(Exception e){e.printStackTrace();}
finally {
DBConnection.close(con, st, rs);
}
}
}