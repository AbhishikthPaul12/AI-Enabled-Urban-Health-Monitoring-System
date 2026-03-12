import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class HealthServlet extends HttpServlet {

protected void doPost(HttpServletRequest req, HttpServletResponse res)
throws ServletException, IOException {

Connection con = null;
Statement st = null;
ResultSet rs = null;

try {

HttpSession s = req.getSession(false);
if(s==null || s.getAttribute("user_id")==null){
res.sendRedirect("index.html");
return;
}

int uid=(int)s.getAttribute("user_id");

double h=Double.parseDouble(req.getParameter("height"));
double w=Double.parseDouble(req.getParameter("weight"));
int steps=Integer.parseInt(req.getParameter("steps"));
int heart=Integer.parseInt(req.getParameter("heart"));

con = DBConnection.getConnection();
st = con.createStatement();

rs=st.executeQuery("SELECT DATA_ID FROM FITNESS_DATA WHERE USER_ID="+uid);

if(rs.next()){
    st.executeUpdate("UPDATE FITNESS_DATA SET HEIGHT="+h+",WEIGHT="+w+",STEPS="+steps+",HEART_RATE="+heart+",TIMESTAMP=SYSDATE WHERE USER_ID="+uid);
}
else{
    st.executeUpdate("INSERT INTO FITNESS_DATA (DATA_ID,USER_ID,HEIGHT,WEIGHT,STEPS,HEART_RATE,TIMESTAMP) VALUES(fitness_seq.NEXTVAL,"+uid+","+h+","+w+","+steps+","+heart+",SYSDATE)");
}

res.sendRedirect("healthTrends.jsp");

}catch(Exception e){
e.printStackTrace();
} finally {
DBConnection.close(con, st, rs);
}
}
}