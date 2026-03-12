import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class AppointmentServlet extends HttpServlet {

protected void doPost(HttpServletRequest req, HttpServletResponse res)
throws ServletException, IOException {

Connection con = null;
Statement st = null;
ResultSet rs = null;

try{

HttpSession s=req.getSession(false);
if(s==null || s.getAttribute("user_id")==null){
res.sendRedirect("index.html");
return;
}

int uid=(int)s.getAttribute("user_id");

String doctor=req.getParameter("doctor");
String date=req.getParameter("date");

con = DBConnection.getConnection();
st = con.createStatement();

rs=st.executeQuery("SELECT APPOINTMENT_ID FROM APPOINTMENT WHERE USER_ID="+uid);

if(rs.next()){
    st.executeUpdate("UPDATE APPOINTMENT SET DOCTOR_NAME='"+doctor+"',APPOINTMENT_DATE=TO_DATE('"+date+"','YYYY-MM-DD'),STATUS='Booked' WHERE USER_ID="+uid);
}
else{
    st.executeUpdate("INSERT INTO APPOINTMENT (APPOINTMENT_ID,USER_ID,DOCTOR_NAME,APPOINTMENT_DATE,STATUS) VALUES(appointment_seq.NEXTVAL,"+uid+",'"+doctor+"',TO_DATE('"+date+"','YYYY-MM-DD'),'Booked')");
}

res.sendRedirect("appointment.jsp?success=1");

}catch(Exception e){
e.printStackTrace();
} finally {
DBConnection.close(con, st, rs);
}
}
}