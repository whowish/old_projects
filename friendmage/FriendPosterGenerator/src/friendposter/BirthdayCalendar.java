/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package friendposter;
import java.awt.Graphics;
import java.awt.Image;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import json.JSONArray;
import json.JSONObject;
import org.apache.log4j.Logger;

/**
 *
 * @author Tanin
 */
public class BirthdayCalendar extends MyCalendar {
    private Logger logger = Logger.getLogger(BirthdayCalendar.class);
    private Birthday[] birthdays;
    private int mode;
    private int dimension1 = 300;
    private int dimension4 = 150;

    public BirthdayCalendar(String orderKey)
    {
        appId = "BirthdayCalendar";
        this.orderKey = orderKey;
        this.backgroundColor = "FFFFFF";
    }

    @Override
    protected void obtainAllData() throws Exception
    {
        if (TEST_MODE) return;

        String[] fields = {"year","offset_x","offset_y","gap_x","gap_y","background_color","mode","birthday_information"};
        HashMap[] hs = mysql.selectQuery("SELECT * FROM birthday_calendars WHERE friendmage_order_key='"+orderKey+"'", fields);
        HashMap h = hs[0];

        year = ((Integer)(h.get("year"))).intValue();
        leftMargin = ((Integer)(h.get("offset_x"))).intValue();
        topMargin = ((Integer)(h.get("offset_y"))).intValue();
        hGap = ((Integer)(h.get("gap_x"))).intValue();
        vGap = ((Integer)(h.get("gap_y"))).intValue();
        backgroundColor = (String)(h.get("background_color"));
        String modeStr = (String)(h.get("mode"));

        if(modeStr.equals("ONE_PEOPLE"))
            mode = 1;
        else if (modeStr.equals("FOUR_PEOPLE"))
            mode =4;

        JSONObject json = new JSONObject((String)(h.get("birthday_information")));

        Iterator e = json.keys();

        logger.debug("birthday_information.length="+json.length());
        
        birthdays = new Birthday[json.length()];
        int run = 0;

        while(e.hasNext())
        {
            String key = (String) e.next();
            JSONArray arr = json.getJSONArray(key);

            String[] urls = new String[arr.length()];
            for (int i=0;i<urls.length;i++) urls[i] = arr.getJSONObject(i).getString("url");

            Birthday b = new Birthday(key,urls);

            birthdays[run++] = b;
        }
    }
    /*
    @Override
    public void generate() throws Exception{
        obtainAllData();
        calHeight = (topMargin + headerHeight + vGap + (height+vGap)*6);
        
        try{
            image = new BufferedImage(calWidth,calHeight,BufferedImage.TYPE_INT_ARGB);
            Graphics g = image.getGraphics();
            g.setColor((new Color(Integer.parseInt(bgColor, 16))));
            g.fillRect(0, 0, calWidth, calHeight);

            //get header
            String headerPath = "C:\\CalendarImage\\calendarHeader"+Integer.toString(year)+".png";
            BufferedImage headerImage = getImageFromFile(headerPath);
            g.drawImage(headerImage, 0, 0,null);

            int x0 = leftMargin;
            int y0 = topMargin + headerHeight + vGap;
            for(int i=0;i<12;i++){
                int x = x0 + width*(i%2);
                if(i%2 ==1)
                    x = x + hGap;
                int y = y0 + ((height+vGap)*(i/2));
                g.drawImage(generateMonthBDCalendar(i+1),x,y, null);
            }

            writeOriginalImageToFile(image);

            //TODO gen+ write signature file
            BufferedImage signImg= new BufferedImage(200,200,BufferedImage.TYPE_INT_ARGB);
            writeSignatureImageToFile(signImg);

            previewHeight = PREVIEW_WIDTH * calHeight / calWidth;
            writePreviewImageToFile(image);
        }
         catch (Exception e)
        {
            logger.error("Failed to create image",e);
             throw e;
        }
        try{
            updateOrderUrl();
            mysql.updateQuery("UPDATE `birthday_calendars` SET `status`='FINISHED'");
        }
        catch (Exception e)
        {
            logger.error("Failed to update database",e);
             throw e;
        }

    }
    */

    @Override
    public void generateMonth(int year,int month,Graphics g, int offsetX,int offsetY) throws Exception
    {
        super.generateMonth(year, month,g,offsetX,offsetY);

        Calendar calendar = Calendar.getInstance();
        calendar.set(year,month-1,1);

        int startDayOfWeek = calendar.get(Calendar.DAY_OF_WEEK)-1;

        for(int i = 0; i<birthdays.length; i++){
           Birthday b = birthdays[i];

           //exception
           if ((year%4) >0 && b.getMonth() == 2 && b.getDate() == 29) continue;

           if(b.getMonth()==month){
               if(mode==1 || b.getUrl().length<2)
                   drawFriend(g,b,startDayOfWeek,offsetX,offsetY);
               else
                  drawFriend4(g,b,startDayOfWeek,offsetX,offsetY);
           }
        }
    }
    public void drawFriend(Graphics g,Birthday b,int startDayOfWeek, int offsetX,int offsetY) throws Exception
    {
            Image thumb = this.readFromUrl(b.getUrl()[0]);
            int d = b.getDate()-1;
            int col = (startDayOfWeek+d) % 7;
            int dx1 = offsetX+monthLeftWidth+(dayWidth*col);
            int dy1 = offsetY+monthHeaderHeight+(dayHeight*((startDayOfWeek+d)/7));
            int dx2 = dx1+dimension1;
            int dy2 = dy1+dimension1;

            int h = thumb.getHeight(null);
            int w = thumb.getWidth(null);

            int sx = 0,sy = 0,sw = w,sh = h;

            if (h > w) {
                //sy = (h - w) / 2;
                sh = w;
            } else {
                sx = (w - h) / 2;
                sw = h;
            }

            g.drawImage(thumb, dx1,dy1,dx2,dy2, sx, sy, sx + sw, sy + sh, null);

    }
    public void drawFriend4(Graphics g,Birthday b,int startDayOfWeek, int offsetX,int offsetY) throws Exception
    {

            int len = Math.min(b.getUrl().length,4);
            for(int i = 0;i<len;i++){
                Image thumb = this.readFromUrl(b.getUrl()[i]);
                int d = b.getDate()-1;
                int col = (startDayOfWeek+d) % 7;
                int index = (4-i) % 4;
                int dx1 = offsetX+(monthLeftWidth+(dayWidth*col))+(dimension4*(index%2));
                int dy1 = offsetY+(monthHeaderHeight+(dayHeight*((startDayOfWeek+d)/7)))+(dimension4*(index/2));
                int dx2 = dx1+dimension4;
                int dy2 = dy1+dimension4;

                int h = thumb.getHeight(null);
                int w = thumb.getWidth(null);

                int sx = 0,sy = 0,sw = w,sh = h;

                if (h > w) {
                    sy = (h - w) / 2;
                    sh = w;
                } else {
                    sx = (w - h) / 2;
                    sw = h;
                }
                g.drawImage(thumb, dx1,dy1,dx2,dy2, sx, sy, sx + sw, sy + sh, null);
            }
    }

    @Override
    public void updateStatus() throws Exception
    {
        mysql.updateQuery("UPDATE `birthday_calendars` SET `status`='FINISHED' WHERE `friendmage_order_key`='"+orderKey+"'");
    }

}
