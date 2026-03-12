import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class LogoutServlet extends HttpServlet {

protected void doGet(HttpServletRequest req, HttpServletResponse res)
throws ServletException, IOException {

req.getSession().invalidate();
res.sendRedirect("index.html");
}
}