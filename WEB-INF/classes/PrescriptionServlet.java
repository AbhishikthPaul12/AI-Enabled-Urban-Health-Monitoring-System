import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class PrescriptionServlet extends HttpServlet {

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
String medication = req.getParameter("medication");
String dosage = req.getParameter("dosage");
String duration = req.getParameter("duration");
String instructions = req.getParameter("instructions");

Class.forName("oracle.jdbc.driver.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","abhi","ap1234");
st = con.createStatement();

st.executeUpdate("INSERT INTO PRESCRIPTION (PRESCRIPTION_ID, DOCTOR_NAME, PATIENT_NAME, MEDICATION, DOSAGE, DURATION, INSTRUCTIONS, PRESCRIPTION_DATE) VALUES (prescription_seq.NEXTVAL, '"+doctorName+"', '"+patientName+"', '"+medication+"', '"+dosage+"', '"+duration+"', '"+instructions+"', SYSDATE)");

res.sendRedirect("doctorPrescription.jsp?success=1");

}catch(Exception e){
    e.printStackTrace();
    res.sendRedirect("doctorPrescription.jsp?error=1");
} finally {
    try{if(st!=null)st.close();}catch(Exception e){}
    try{if(con!=null)con.close();}catch(Exception e){}
}
}

protected void doGet(HttpServletRequest req,HttpServletResponse res)
throws IOException{
res.sendRedirect("doctorPrescription.jsp");
}
}
