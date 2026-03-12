package com.medaxis.servlet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import org.springframework.beans.factory.annotation.Autowired;
import javax.sql.DataSource;
import javax.servlet.annotation.WebServlet;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Autowired
    private DataSource dataSource;

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
    throws ServletException, IOException {

        Connection con = null;
        Statement st = null;
        ResultSet rs = null;

        try{
            String email = req.getParameter("email");
            String pass = PasswordHash.hash(req.getParameter("password"));

            con = dataSource.getConnection();
            st = con.createStatement();

            String sql = "SELECT USER_ID, NAME, ROLE FROM USERS WHERE EMAIL='"+email+"' AND PASSWORD='"+pass+"'";
            rs = st.executeQuery(sql);

            if(rs.next()){
                HttpSession session = req.getSession();
                session.setAttribute("user_id", rs.getInt("USER_ID"));
                session.setAttribute("user_name", rs.getString("NAME"));
                session.setAttribute("role", rs.getString("ROLE"));
                session.setMaxInactiveInterval(30*60);

                String role = rs.getString("ROLE");

                if("admin".equals(role)){
                    res.sendRedirect("adminDashboard.jsp");
                } else if("doctor".equals(role)){
                    res.sendRedirect("doctorDashboard.jsp");
                } else {
                    res.sendRedirect("dashboard.jsp");
                }
            }else{
                res.sendRedirect("index.html?error=invalid");
            }

        }catch(Exception e){
            e.printStackTrace();
            res.getWriter().println("LOGIN ERROR: "+e);
        } finally {
            try{if(rs!=null)rs.close();}catch(Exception e){}
            try{if(st!=null)st.close();}catch(Exception e){}
            try{if(con!=null)con.close();}catch(Exception e){}
        }
    }

    protected void doGet(HttpServletRequest req,HttpServletResponse res)
    throws IOException{
        res.sendRedirect("index.html");
    }
}
