import java.sql.*;

public class DBConnection {
    
    private static final String URL = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String USER = "abhi";
    private static final String PASS = "ap1234";
    
    static {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }
    
    public static void close(Connection con, Statement st, ResultSet rs) {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (st != null) st.close(); } catch (Exception e) {}
        try { if (con != null) con.close(); } catch (Exception e) {}
    }
    
    public static void close(Connection con, Statement st) {
        close(con, st, null);
    }
}
