/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package puengnoicalendar;

import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;
import java.util.Calendar;
import java.awt.Graphics;
import java.awt.Color;
import java.awt.Image;
import java.net.MalformedURLException;
import java.net.URL;

/**
 *
 * @author Tanin
 */
public class BirthdayCalendar extends MyCalendar {
    private BufferedImage bdCalendar;
    private Birthday[] birthdays;
    private int mode;
    private int dimension1 = 295;
    private int dimension4 = 147;
    public BirthdayCalendar(int y, Birthday[] bds,int m){
        year = y;
        birthdays = bds;
        mode = m;
    }
    public BufferedImage generateBDCalendar(){
        int calHeight = (topMargin + headerHeight + vGap + (height+vGap)*6);
        bdCalendar = new BufferedImage(calWidth,calHeight,BufferedImage.TYPE_INT_ARGB);
        Graphics g = bdCalendar.getGraphics();
        g.setColor(Color.WHITE);
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

        return bdCalendar;
    }
    public BufferedImage generateMonthBDCalendar(int month){
        BufferedImage monthBDCalendar = this.generateMonth(year, month);
        Graphics g = monthBDCalendar.getGraphics();
        for(int i = 0; i<birthdays.length; i++){
           Birthday b = birthdays[i];
           
           if(b.getMonth()==month){
               if(mode==1 || b.getUrl().length<2)
                   drawFriend(g,b);
               else
                  drawFriend4(g,b);
           }
        }

        return monthBDCalendar;
    }
    public void drawFriend(Graphics g,Birthday b){            
            Image thumb = this.readFromUrl(b.getUrl()[0]);
            int d = b.getDate()-1;
            int col = (dayOfWeek+d) % 7;
            int dx1 = monthLeftWidth+(dayWidth*col);
            int dy1 = monthHeaderHeight+(dayHeight*((dayOfWeek+d)/7));
            int dx2 = dx1+dimension1;
            int dy2 = dy1+dimension1;

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
    public void drawFriend4(Graphics g,Birthday b){
            for(int i = 0;i<b.getUrl().length;i++){
                Image thumb = this.readFromUrl(b.getUrl()[i]);
                int d = b.getDate()-1;
                int col = (dayOfWeek+d) % 7;
                int index = (4-i) % 4;
                int dx1 = (monthLeftWidth+(dayWidth*col))+(dimension4*(index%2));
                int dy1 = (monthHeaderHeight+(dayHeight*((dayOfWeek+d)/7)))+(dimension4*(index/2));
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
    public Image readFromUrl(String url_string)
    {
        //logger.debug("Read image from " + url_string);
        int retry_count = 0;
        while (retry_count < 10)
        {
            try
            {
               return ImageIO.read(new URL(url_string));
            }
            catch (MalformedURLException e)
            {
                //logger.error("MalformedURL ",e);
                System.out.println(e.toString());
                return null;
            }
            catch (Exception e)
            {
                //logger.error("Error while reading image " + url_string,e);
                System.out.println(e.toString());
                retry_count++;
                try { Thread.sleep(1000); } catch (Exception e2) {}
            }
        }

        return null;
    }

}
