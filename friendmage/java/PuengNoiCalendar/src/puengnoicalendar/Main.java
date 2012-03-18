/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package puengnoicalendar;

import java.awt.image.BufferedImage;
/**
 *
 * @author Tanin
 */
public class Main {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        //MyCalendar c = new MyCalendar();
        int year = 2011;
        //int month = 5;
        //BufferedImage image = c.generateYear(year);
        //for testing
        //String path = "C:\\CalendarImage\\Testcalendar"+Integer.toString(year)+Integer.toString(month)+".png";
        //String path = "C:\\CalendarImage\\Testcalendar"+Integer.toString(year)+".png";
        //c.writeImageToFile(path,image);
        Birthday[] birthdays = new Birthday[122];
        String [] s1={"http://a6.sphotos.ak.fbcdn.net/hphotos-ak-ash4/199752_10150117418043727_664888726_6489514_1772452_n.jpg"};
        String [] s2= {"http://a3.sphotos.ak.fbcdn.net/hphotos-ak-snc4/154337_470745263726_664888726_5740821_2064459_n.jpg",
                        "http://a7.sphotos.ak.fbcdn.net/photos-ak-snc1/v4438/181/45/664888726/n664888726_1941829_3285959.jpg",
                        "http://a6.sphotos.ak.fbcdn.net/hphotos-ak-ash4/199752_10150117418043727_664888726_6489514_1772452_n.jpg",
                        "http://a5.sphotos.ak.fbcdn.net/photos-ak-snc1/v4438/181/45/664888726/n664888726_1901979_3186236.jpg"};
        
        String [] s3= {"http://a1.sphotos.ak.fbcdn.net/hphotos-ak-ash1/25611_380025763726_664888726_3840645_3525865_n.jpg",
                        "http://a6.sphotos.ak.fbcdn.net/hphotos-ak-ash4/199752_10150117418043727_664888726_6489514_1772452_n.jpg"};
        String [] s4= {"http://a1.sphotos.ak.fbcdn.net/hphotos-ak-ash1/25611_380025763726_664888726_3840645_3525865_n.jpg",
                        "http://a6.sphotos.ak.fbcdn.net/hphotos-ak-ash4/199752_10150117418043727_664888726_6489514_1772452_n.jpg",
                        "http://a5.sphotos.ak.fbcdn.net/photos-ak-snc1/v4438/181/45/664888726/n664888726_1901979_3186236.jpg"};
        for(int i = 0 ;i <31;i++){
            Birthday b = new Birthday("05-"+Integer.toString(i+1),s1);
            birthdays[i]=b;
        }
        for(int i = 31 ;i <61;i++){
            Birthday b = new Birthday("9-"+Integer.toString(i-30),s2);
            birthdays[i]=b;
        }
        for(int i = 61 ;i <92;i++){
            Birthday b = new Birthday("10-"+Integer.toString(i-60),s3);
            birthdays[i]=b;
        }
        for(int i = 92 ;i <122;i++){
            Birthday b = new Birthday("12-"+Integer.toString(i-91),s4);
            birthdays[i]=b;
        }

        Birthday b1 = new Birthday("05-30",s2);
        birthdays[29]= b1;
        Birthday b2 = new Birthday("05-24",s3);
        birthdays[23]= b2;
        Birthday b3 = new Birthday("05-20",s4);
        birthdays[19]= b3;
        
        BirthdayCalendar fc = new BirthdayCalendar(year, birthdays,4);
        
        
        //BufferedImage fImg = fc.generateMonthBDCalendar(5);
        BufferedImage fImg = fc.generateBDCalendar();
        String path2 = "C:\\CalendarImage\\TestBDcalendar"+Integer.toString(year)+".png";
        fc.writeImageToFile(path2,fImg);

       
    }

}
