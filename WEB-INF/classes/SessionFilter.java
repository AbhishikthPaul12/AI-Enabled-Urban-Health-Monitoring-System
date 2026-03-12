import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class SessionFilter implements Filter {
    
    public void init(FilterConfig config) throws ServletException {}
    
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
    throws IOException, ServletException {
        
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        
        String path = request.getRequestURI();
        
        if(path.endsWith("index.html") || path.endsWith("register.html") || 
           path.endsWith("forgot.html") || path.endsWith("LoginServlet") ||
           path.endsWith("RegisterServlet") || path.endsWith("ForgotServlet") ||
           path.contains(".css") || path.contains(".js")) {
            chain.doFilter(req, res);
            return;
        }
        
        HttpSession session = request.getSession(false);
        
        if(session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("index.html");
            return;
        }
        
        chain.doFilter(req, res);
    }
    
    public void destroy() {}
}
