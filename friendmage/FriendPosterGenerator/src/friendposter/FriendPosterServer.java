/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package friendposter;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import org.apache.log4j.Logger;

/**
 *
 * @author Tanin
 */
public class FriendPosterServer implements Runnable,HttpHandler {

    public static Logger logger = Logger.getLogger(FriendPoster.class);
    public boolean isRunning = false;
    public static final Object lockObject = new Object();

    public HashMap<String,String> hashQueue = new HashMap<String,String>();

    Timer timer;
    WakeUpToEnqueueUnfinishedOrder enqueueTask;

    public FriendPosterServer()
    {
        enqueueTask = new WakeUpToEnqueueUnfinishedOrder();

        timer = new Timer();
        timer.scheduleAtFixedRate(enqueueTask,0,60000*5);
    }


    class WakeUpToEnqueueUnfinishedOrder extends TimerTask {
        public void run()
        {
            try
            {
                MySqlConnector mysql = new MySqlConnector();
                String[] fields = {"key","app_id"};
                HashMap[] hs = mysql.selectQuery("SELECT `key`,`app_id` FROM `orders` WHERE `status`='PAID' AND (`print_image_url` IS NULL OR `signature_image_url` IS NULL OR `preview_image_url` IS NULL OR `print_image_url`='' OR `signature_image_url`='' OR `preview_image_url`='') ORDER BY `paid_time` ASC", fields);

                for (int i=0;i<hs.length;i++)
                {
                    enqueue((String)hs[i].get("app_id"), (String)hs[i].get("key"));
                }
            } catch (Exception e)
            {
               logger.error("Error in obtainUnfinishedOrder()",e);
            }
        }
    }

    public void handle(HttpExchange t) throws IOException
    {
        logger.debug("Enter handle()");
        try
        {
            Map<String, Object> params = (Map<String, Object>)t.getAttribute("parameters");

            String orderKey = (String) params.get("order_key");
            String appId = (String) params.get("app_id");

            logger.debug("orderKey="+orderKey);

            enqueue(appId,orderKey);
            
            String response = "{'ok':true}";
            t.sendResponseHeaders(200, response.length());
            OutputStream os = t.getResponseBody();
            os.write(response.getBytes());
            os.close();

            logger.debug("Server's response: "+response);
        } catch (Exception e)
        {
            logger.error("Error in Server's handler",e);
        }

        logger.debug("Exit handle()");
    }

    public LinkedList<AbstractImageEntity> queue = new LinkedList<AbstractImageEntity>();

    private AbstractImageEntity chooseApp(String appId,String orderKey)
    {
        if (appId.compareTo("FriendPoster")==0)
            return new FriendPoster(orderKey);
        else if (appId.compareTo("BirthdayCalendar")==0)
            return new  BirthdayCalendar(orderKey);
        else
            return null;
    }

    private void enqueue(String appId, String orderKey)
    {
        try
        {
            AbstractImageEntity obj = chooseApp(appId,orderKey);

            

            if (obj == null) return;

            synchronized(lockObject)
            {
                if (hashQueue.containsKey(orderKey)) return;

                logger.debug("Enqueue "+orderKey);

                queue.add(obj);
                hashQueue.put(orderKey, "true");

                if (isRunning == false)
                {
                    isRunning = true;

                    (new Thread(this)).start();
                }
            }
        } catch (Exception e)
        {
            logger.error("Error in Enqueue()",e);
        }
    }

    public void run()
    {
        try
        {
            while(true)
            {
                AbstractImageEntity poster = null;

                synchronized(lockObject)
                {
                    poster = queue.poll();

                    if (poster == null)
                    {
                        isRunning = false;
                        break;
                    }
                }

                int retry_count = 0;
                while (retry_count < 3)
                {
                    try
                    {
                        logger.debug("Start doing " + poster.orderKey + "(retry="+retry_count+")");
                        poster.generate();

                        break;
                    }
                    catch (Exception e) {
                        logger.error("Error while generating",e);
                        poster = chooseApp(poster.appId,poster.orderKey);
                    }

                    retry_count++;
                }

                logger.debug("Finish doing " + poster.orderKey);

                synchronized (lockObject)
                {
                    if (hashQueue.containsKey(poster.orderKey))
                    {
                        hashQueue.remove(poster.orderKey);
                    }
                }
            }
        } catch (Exception e)
        {
            logger.error("Error in run()",e);
        }

    }
}

