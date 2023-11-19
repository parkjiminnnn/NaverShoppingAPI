package shop;

import java.sql.*;
import java.util.List;

public class DBconnect {

    public static void saveToDatabase(List<Data> dataList) {
    	 Connection conn = null;
         PreparedStatement stmt = null;
   
        try {
        		Class.forName("com.mysql.cj.jdbc.Driver");	
        		conn = DriverManager.getConnection("jdbc:mysql://localhost/navershop_db","root","1234");
           
        		stmt = conn.prepareStatement(
        				"INSERT INTO Navershop (title, link,image, lprice, hprice, mallName, productId, productType, brand, maker, category1) "
        				+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        		
                for (Data data : dataList) {
                    stmt.setString(1, data.getTitle());
                    stmt.setString(2, data.getLink());
                    stmt.setString(3, data.getImage());
                    stmt.setString(4, data.getLprice());
                    stmt.setString(5, data.getHprice());
                    stmt.setString(6, data.getMallName());
                    stmt.setString(7, data.getProductId());
                    stmt.setString(8, data.getProductType());
                    stmt.setString(9, data.getBrand());
                    stmt.setString(10, data.getMaker());
                    stmt.setString(11, data.getCategory1());

                    stmt.executeUpdate();
                }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
    }
    }
}