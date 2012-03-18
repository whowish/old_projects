/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package friendposter;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import org.apache.log4j.Logger;

/**
 *
 * @author Tanin
 */
public class MySqlConnector {

    private Connection conn = null;
    private static Logger logger = Logger.getLogger(MySqlConnector.class);

    @Override
    protected void finalize() throws Throwable
    {
      try { conn.close(); } catch (Exception e){}
      super.finalize(); //not necessary if extending Object.
    }

    private Connection getConnection()
    {
        if (conn == null)
        {
            try {
                conn = DriverManager.getConnection("jdbc:mysql://127.0.0.1/friendmage?" +
                                               "user=root&password=ninat");

            } catch (SQLException ex) {
                logger.error("Create MySQL connection error",ex);
            }

        }

        return conn;
    }

    public HashMap[] selectQuery(String q,String[] fields) throws Exception
    {
        Statement stmt = null;
        ResultSet rs = null;

        ArrayList<HashMap<String,Object>> hs = new ArrayList<HashMap<String,Object>>();
        try
        {
            stmt = getConnection().createStatement();
            rs = stmt.executeQuery(q);

            while(rs.next())
            {

                HashMap<String,Object> h = new HashMap<String,Object>();
                for (int i=0;i<fields.length;i++)
                {
                    h.put(fields[i], rs.getObject(fields[i]));
                }

                hs.add(h);
            }
        }
        catch (Exception e)
        {
            throw e;
        }
        finally {
            try { rs.close(); } catch (Exception e) {}
            try { stmt.close(); } catch (Exception e) {}
        }

        HashMap[] hsArray = new HashMap[hs.size()];
        
        for (int i=0;i<hsArray.length;i++)
            hsArray[i] = hs.get(i);

        return hsArray;
    }

    public void updateQuery(String q) throws Exception
    {
        Statement stmt = null;

        try
        {
            stmt = getConnection().createStatement();
            stmt.executeUpdate(q);
        } catch (Exception e)
        {
            throw e;
        }
        finally{
            try { stmt.close(); } catch (Exception e) {}
        }
    }
}
