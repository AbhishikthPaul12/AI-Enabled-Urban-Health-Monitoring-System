import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class AIServlet extends HttpServlet {

protected void doPost(HttpServletRequest req, HttpServletResponse res)
throws ServletException, IOException {

String advice = "";
Connection con = null;
Statement st = null;
ResultSet rs = null;

try{

HttpSession session = req.getSession(false);

if(session == null || session.getAttribute("user_id") == null){
req.setAttribute("result","Please login first");
RequestDispatcher rd = req.getRequestDispatcher("ai.jsp");
rd.forward(req,res);
return;
}

int uid = (int) session.getAttribute("user_id");

con = DBConnection.getConnection();
st = con.createStatement();

rs = st.executeQuery("SELECT * FROM (SELECT * FROM FITNESS_DATA WHERE USER_ID="+uid+" ORDER BY TIMESTAMP DESC) WHERE ROWNUM=1");

if(rs.next()){
double h = rs.getDouble("HEIGHT");
double w = rs.getDouble("WEIGHT");
int steps = rs.getInt("STEPS");
int heart = rs.getInt("HEART_RATE");

double bmi = 0;
if(h>0 && w>0) bmi = w/((h/100)*(h/100));

StringBuilder sb = new StringBuilder();
sb.append("AI Health Report: ");

if(bmi<18.5) sb.append("Underweight. ");
else if(bmi<25) sb.append("BMI normal. ");
else if(bmi<30) sb.append("Overweight. Exercise more. ");
else sb.append("High obesity risk. ");

if(steps<3000) sb.append("Very low steps. Walk daily. ");
else if(steps<8000) sb.append("Average activity. ");
else sb.append("Great activity! ");

if(heart>100) sb.append("Heart rate high. Reduce stress. ");
else sb.append("Heart rate normal. ");

advice = sb.toString();
}
else{
advice = "No health data found. Please enter health details first.";
}

}catch(Exception e){
advice = "AI error occurred.";
e.printStackTrace();
} finally {
DBConnection.close(con, st, rs);
}

req.setAttribute("result", advice);
RequestDispatcher rd = req.getRequestDispatcher("ai.jsp");
rd.forward(req,res);
}
}