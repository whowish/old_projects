/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package puengnoicalendar;

/**
 *
 * @author Tanin
 */
public class Birthday {
    private String birthday;
    private String[] url;

    public Birthday(String b, String[] u){
        birthday = b;
        url = u;
    }
    public void setBirthday(String b){
        birthday = b;
    }
    public void setUrl(String[] u){
        url = u;
    }
    public String getBirthday(){
        return birthday;
    }
    public String[] getUrl(){
        return url;
    }
    public int getDate(){
        String[] bd = birthday.split("-");
        return Integer.parseInt(bd[1]);
    }
    public int getMonth(){
        String[] bd = birthday.split("-");
        return Integer.parseInt(bd[0]);
    }
}
