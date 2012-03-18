/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package friendposter;
import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;
import java.util.Calendar;
import java.awt.Graphics;
import java.awt.Color;
import java.awt.Font;
import org.apache.log4j.Logger;

/**
 *
 * @author Tanin
 */
public class MyCalendar extends AbstractImageEntity{
    
    private Logger logger = Logger.getLogger(MyCalendar.class);
    //main calendar
    //fixed
    protected int calWidth = 6000;
    protected int headerHeight = 300;
    //obtained from db
    protected int topMargin = 200;
    protected int leftMargin = 400;
    protected int hGap = 340;
    protected int vGap = 100;
    protected int year;
    //calculated
    protected int calHeight = 0;

    //month
    protected int[] months = { 31,28,31,30,31,30,31,31,30,31,30,31};
    protected int mTagWidth = 300;
    protected int mTagHeight = 1800;
    protected int monthWidth = 2176 + mTagWidth;
    protected int monthHeight = 2183;
    protected int redLineWidth = 20;
    protected int monthHeaderHeight = 333;
    protected int monthLeftWidth = mTagWidth + redLineWidth;
    protected int dayWidth = 306;
    protected int dayHeight = 306;
    protected int dateWidth = 590;
    protected int dateHeight = 236;
    protected int drawnDateWidth = 200;
    protected int drawnDateHeight = 80;
    protected int dateLeftMargin = 125;

    private String basePath = "../public/images/calendar/original";

    private String baseMonthPath = basePath + "/month.png";
    private String baseDatePath = basePath + "/date.png";


    public MyCalendar(){}
    public MyCalendar(String orderKey)
    {
        this.orderKey = orderKey;
        this.backgroundColor = "FFFFFF";
        
    }
    
    protected void obtainAllData() throws Exception
    {

    }
    
    public void generate() throws Exception{
        obtainAllData();

        try{

            BufferedImage img = null;
            Graphics g = null;
            {
                BufferedImage headerImage = getImageFromFile(basePath + "/calendarHeader"+Integer.toString(year)+".png");
                img =  createPartialImage(headerHeight + topMargin);
                g = img.getGraphics();
                g.drawImage(headerImage, 0, 0,null);
            }
            
            int x0 = leftMargin;
            for(int i=0;i<12;i++){

                if ((i%2)==0)
                {
                    // write previous image
                    writeToPartialFile(img);

                    int partialHeight = calculateHeight(year,i+1);

                    // create a new one
                    img =  createPartialImage(partialHeight+vGap);
                    g = img.getGraphics();
                }
                
                int x = x0 + monthWidth*(i%2);

                if(i%2 ==1)
                    x = x + hGap;
                
                generateMonth(year,i+1,g,x,0);
            }

            // write signature
            g.setColor(new Color(Integer.parseInt("e7e7e8", 16)));
            g.setFont(new Font(Font.MONOSPACED, Font.PLAIN, 10));
            g.drawString("BC-"+orderKey, 0,img.getHeight());

            // write previous image
            writeToPartialFile(img);
            composePartialFiles();

            {
                BufferedImage signImg= new BufferedImage(200,200,BufferedImage.TYPE_INT_RGB);
                Graphics sg = signImg.getGraphics();
                sg.setColor(Color.WHITE);
                sg.fillRect(0, 0, 200, 200);
                writeSignatureImageToFile(signImg);
            }

        }
        catch (Exception e)
        {
            logger.error("Failed to create image",e);
             throw e;
        }
        try{
            updateOrderUrl();
            updateStatus();
        }
        catch (Exception e)
        {
            logger.error("Failed to update database",e);
             throw e;
        }
    }

    public int calculateHeight(int year,int m) throws Exception
    {
        //change actual month to relative month (actual motnh -> jan = 1)
        m =  m-1;
        
        //set calendar to get day of week
        Calendar calendar = Calendar.getInstance();
        

        int days = months[m];
        int days_next_month = months[m+1];
        if (m==1 && year % 4 == 0)
            days = 29;

        calendar.set(year,m,1);
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK)-1;
        
        calendar.set(year,m+1,1);
        int dayOfWeek_next_month = calendar.get(Calendar.DAY_OF_WEEK)-1;

        int rows = (int)Math.ceil((days+dayOfWeek)/7.0);
        int rows_next_month = ((int)Math.ceil((days_next_month+dayOfWeek_next_month)/7.0));

        BufferedImage baseImage = getImageFromFile(basePath+"/calendar"+Math.max(rows,rows_next_month)+"Row.png");

        return baseImage.getHeight();
    }

    public void updateStatus() throws Exception
    {

    }

    public void generateMonth(int year,int month,Graphics g, int offsetX,int offsetY) throws Exception
    {
        //change actual month to relative month (actual motnh -> jan = 1)
        int m =  month-1;
        //set calendar to get day of week
        Calendar calendar = Calendar.getInstance();
        calendar.set(year,m,1);

        int days = months[m];
        if (m==1 && year % 4 == 0)
            days = 29;
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK)-1;

        int weeks = (int)Math.ceil((days+dayOfWeek)/7.0);
        BufferedImage baseImage = getImageFromFile(basePath+"/calendar"+Integer.toString(weeks)+"Row.png");

        g.drawImage(baseImage, offsetX+mTagWidth, offsetY,null);

        BufferedImage baseMonthImage = getImageFromFile(baseMonthPath);

        int sx1 = 0;
        int sy1 = mTagHeight*m;
        int sx2 = mTagWidth;
        int sy2 = sy1 + mTagHeight;
        g.drawImage(baseMonthImage, offsetX, offsetY, offsetX+mTagWidth,offsetY+mTagHeight,sx1,sy1,sx2,sy2,null);

        //draw date
        drawDate(g,days,dayOfWeek, offsetX, offsetY);
    }

    private void drawDate(Graphics g,int days, int startDayOfWeek, int offsetX, int offsetY) throws Exception
    {
        BufferedImage baseDateImage = getImageFromFile(baseDatePath);
        for(int i = 0;i<days; i++){
            int col = (startDayOfWeek+i) % 7;
            int dx1 = offsetX + monthLeftWidth+dateLeftMargin+(dayWidth*col);
            int dy1 = offsetY + monthHeaderHeight+(dayHeight*((startDayOfWeek+i)/7));
            int dx2 = dx1+drawnDateWidth;
            int dy2 = dy1+drawnDateHeight;

            int dsx1 = 0;
            if(col == 0 || col == 6)
                dsx1 = dateWidth;
            int dsy1 = dateHeight*i+4;
            int dsx2 = dsx1 + dateWidth;
            int dsy2 = dsy1 + dateHeight-4;
            g.drawImage(baseDateImage,dx1,dy1,dx2,dy2,dsx1,dsy1,dsx2,dsy2,null);
        }
    }
    protected BufferedImage getImageFromFile(String path) throws Exception
    {
        try{
            return ImageIO.read(new File(path));
        }
        catch(Exception ex){
            logger.error("Error while reading image " + path,ex);
            throw ex;
        }
        
    }

}
