import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class AdviceServlet extends HttpServlet {

protected void doPost(HttpServletRequest req, HttpServletResponse res)
throws ServletException, IOException {

Connection con = null;
Statement st = null;

try{

HttpSession s = req.getSession(false);
if(s==null || s.getAttribute("user_id")==null || !"doctor".equals(s.getAttribute("role"))){
    res.sendRedirect("index.html");
    return;
}

String doctorName = (String)s.getAttribute("user_name");
String patientName = req.getParameter("patientName");
String category = req.getParameter("category");
String advice = req.getParameter("advice");
String priority = req.getParameter("priority");

Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
st = con.createStatement();

st.executeUpdate("INSERT INTO MEDICAL_ADVICE (ADVICE_ID, DOCTOR_NAME, PATIENT_NAME, CATEGORY, ADVICE_TEXT, PRIORITY, ADVICE_DATE) VALUES (advice_seq.NEXTVAL, '"+doctorName+"', '"+patientName+"', '"+category+"', '"+advice+"', '"+priority+"', SYSDATE)");

res.sendRedirect("doctorAdvice.jsp?success=1");

}catch(Exception e){
    e.printStackTrace();
    res.sendRedirect("doctorAdvice.jsp?error=1");
} finally {
    try{if(st!=null)st.close();}catch(Exception e){}
    try{if(con!=null)con.close();}catch(Exception e){}
}
}

protected void doGet(HttpServletRequest req,HttpServletResponse res)
throws IOException{
res.sendRedirect("doctorAdvice.jsp");
}
}
