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

/**
 *
 * @author Tanin
 */
public class MyCalendar {
    //main calendar
    protected int calWidth = 6000;
    protected int headerHeight = 300;
    protected int topMargin = 0;
    protected int leftMargin = 400;
    protected int hGap = 340;
    protected int vGap = 200;
    protected int year;


    //month
    private int[] months = { 31,28,31,30,31,30,31,31,30,31,30,31};
    protected int mTagWidth = 300;
    protected int mTagHeight = 1800;
    protected int width = 2131 + mTagWidth;
    protected int height = 2136;
    protected int redLineWidth = 17;
    protected int monthHeaderHeight = 322;
    protected int monthLeftWidth = mTagWidth + redLineWidth;
    protected int dayWidth = 300;
    protected int dayHeight = 298;
    protected int dateWidth = 590;
    protected int dateHeight = 236;
    protected int drawnDateWidth = 200;
    protected int drawnDateHeight = 80;
    protected int dateLeftMargin = 125;

    private String baseMonthPath = "C:\\CalendarImage\\month.png";
    private String baseDatePath = "C:\\CalendarImage\\date.png";
    protected int days =0;
    protected int dayOfWeek;

    public MyCalendar(){}
    public MyCalendar(int y){
        year = y;
    }

    public BufferedImage generateYear(){
        int calHeight = (topMargin + headerHeight + vGap + (height+vGap)*6);
        BufferedImage image = new BufferedImage(calWidth,calHeight,BufferedImage.TYPE_INT_ARGB);
        Graphics g = image.getGraphics();
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
            g.drawImage(generateMonth(year,i+1),x,y, null);
        }

        return image;

    }

    public BufferedImage generateMonth(int year,int month){
        //change actual month to relative month (actual motnh -> jan = 1)
        int m =  month-1;
        //set calendar to get day of week
        Calendar calendar = Calendar.getInstance();
        calendar.set(year,m,1);

        days = months[m];
        if (m==1 && year % 4 == 0)
            days = 29;
        dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK)-1;

        //draw image for a month
        BufferedImage imageMonth = new BufferedImage(width,height,BufferedImage.TYPE_INT_ARGB);
        Graphics g = imageMonth.getGraphics();
 
        //draw month + month tag
        drawMonth(g,m);
        
        //draw date
        drawDate(g);
        
        return imageMonth;
    }
    private void drawMonth(Graphics g,int m){
        int weeks = (int)Math.ceil((days+dayOfWeek)/7.0);
        String baseImagePath = "C:\\CalendarImage\\calendar"+Integer.toString(weeks)+"Row.png";
        BufferedImage baseImage = getImageFromFile(baseImagePath);
        g.drawImage(baseImage, mTagWidth, 0,null);
        //get month tag
        BufferedImage baseMonthImage = getImageFromFile(baseMonthPath);
        int sx1 = 0;
        int sy1 = mTagHeight*m;
        int sx2 = mTagWidth;
        int sy2 = sy1 + mTagHeight;
        g.drawImage(baseMonthImage, 0, 0, mTagWidth,mTagHeight,sx1,sy1,sx2,sy2,null);
    }
    private void drawDate(Graphics g){
        BufferedImage baseDateImage = getImageFromFile(baseDatePath);
        for(int i = 0;i<days; i++){
            int col = (dayOfWeek+i) % 7;
            int dx1 = monthLeftWidth+dateLeftMargin+(dayWidth*col);
            int dy1 = monthHeaderHeight+(dayHeight*((dayOfWeek+i)/7));
            int dx2 = dx1+drawnDateWidth;
            int dy2 = dy1+drawnDateHeight;

            int dsx1 = 0;
            if(col == 0 || col == 6)
                dsx1 = dateWidth;
            int dsy1 = dateHeight*i;
            int dsx2 = dsx1 + dateWidth;
            int dsy2 = dsy1 + dateHeight;
            g.drawImage(baseDateImage,dx1,dy1,dx2,dy2,dsx1,dsy1,dsx2,dsy2,null);
        }
    }
    protected BufferedImage getImageFromFile(String path){
        try{
            return ImageIO.read(new File(path));
        }
        catch(Exception ex){
            //TODO write log
            System.out.println(ex.toString());
        }
        return null;
    }
    //FOR TESTING
    public void writeImageToFile(String path,BufferedImage img){
        try
        {
            File outputfile = new File(path);
            ImageIO.write(img, "png", outputfile);
        }
        catch(Exception ex){
            //TODO write log
        }

    }

}
