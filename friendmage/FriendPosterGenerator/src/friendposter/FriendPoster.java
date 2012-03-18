/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package friendposter;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import javax.imageio.ImageIO;
import org.apache.log4j.Logger;

/**
 *
 * @author Tanin
 */
public class FriendPoster extends AbstractImageEntity{
    private  Logger logger = Logger.getLogger(FriendPoster.class);

    public static int ROW_PER_FILE = 10;

    public String[] imageUrls = new String[0];
    
    public int perRow = 20;
    public int border = 100;
    public int gap = 30;
    

    public FriendPoster(String orderKey)
    {
        appId = "FriendPoster";
        this.orderKey = orderKey;
    }

    private void obtainAllData() throws Exception
    {
        if (TEST_MODE) return;
        
        String[] fields = {"width","photo_per_row","border","gap","background_color","image_urls"};
        HashMap[] hs = mysql.selectQuery("SELECT * FROM friend_posters WHERE friendmage_order_key='"+orderKey+"'", fields);
        HashMap h = hs[0];

        width = ((Integer)(h.get("width"))).intValue();
        perRow = ((Integer)(h.get("photo_per_row"))).intValue();
        border = ((Integer)(h.get("border"))).intValue();
        gap = ((Integer)(h.get("gap"))).intValue();
        backgroundColor = (String)(h.get("background_color"));
        imageUrls = ((String)(h.get("image_urls"))).split(",");
    }

    private int getDimension()
    {
        return (int)(((width - border*2 - (perRow-1)*gap)/perRow));
    }

    private void generateSignature(Image[] images) throws Exception
    {
        int dimension = getDimension();
        int width = border*2 + dimension*4 + gap;
        int height = border*2 + dimension;
        
        logger.debug("Signature's dimension=" + width + "x" + height);
        BufferedImage img = new BufferedImage(width,height,BufferedImage.TYPE_INT_RGB);

        Graphics g = img.getGraphics();

        for (int i=0;i<images.length;i++)
        {
            drawThumb(i, dimension, images[i], g,0);
        }
        try{
            writeSignatureImageToFile(img);
        }
        catch(Exception ex){
            throw ex;
        }
    }



    public void generate() throws Exception
    {

        obtainAllData();

        ArrayList<Image> signatureImages = new ArrayList<Image>();
        try
        {
            int dimension = getDimension();
            int height = (int)(border*2 + Math.ceil(((double)imageUrls.length)/perRow) * (dimension+gap));
            int cHeight = 0;
            
            // top border
            {
                writeToPartialFile(createPartialImage(border));
                cHeight += border;
            }

            int partialHeight =  ROW_PER_FILE * (dimension+gap);
            BufferedImage img = null;
            Graphics g = null;

            logger.debug("Place " + imageUrls.length + " images.");
            for (int i=0;i<imageUrls.length;i++)
            {
                Image thumb = readFromUrl(imageUrls[i]);

                if (thumb == null) {
                    logger.debug("Connot read image from " + imageUrls[i]);
                    throw new Exception("Cannot read image from " + imageUrls[i]);
                }

                if (signatureImages.size() < 4) signatureImages.add(thumb);

                int y = border + ((int) (i/perRow)) * (dimension + gap);

                //logger.debug("y="+y+",cHeight="+cHeight+",partialHeight="+partialHeight);

                if ((y-cHeight) >= partialHeight || img == null)
                {
                    // write previous image
                    if (img != null) {
                        writeToPartialFile(img);
                        cHeight += img.getHeight();
                    }

                    // create new image
                    img = createPartialImage(Math.min(partialHeight,height-border*2-y));
                    g = img.getGraphics();
                }

                drawThumb(i, dimension, thumb, g, cHeight);

                //logger.debug("Image "+i+" drawn.");
            }
            
            int duplicateSize = (perRow - imageUrls.length%perRow);

            logger.debug("Place " + duplicateSize + " duplicates.");

            for (int i=0;i<duplicateSize;i++)
            {
                Image thumb = readFromUrl(imageUrls[(imageUrls.length/4) + (i * 7) % (imageUrls.length/2)]);
                if (signatureImages.size() < 4) signatureImages.add(thumb);

                drawThumb(imageUrls.length + i, dimension, thumb, g,cHeight);
            }

            // write last image
            writeToPartialFile(img);

            // top border
            {

                writeToPartialFile(createPartialImage(border));
                cHeight += border;
            }
            
            composePartialFiles();
            try
            {
                Image[] signatureImagesArray = new Image[signatureImages.size()];

                for (int i=0;i<signatureImagesArray.length;i++)
                    signatureImagesArray[i] = signatureImages.get(i);

                generateSignature(signatureImagesArray);

            } catch (Exception e) {
                logger.error("Cannot generate signature image of '" + originalFilePath + "'",e);
                throw e;
            }
            
            
            
        }
        catch (Exception e)
        {
            logger.error("Failed to create image",e);
             throw e;
        }
        try{
            updateOrderUrl();
            mysql.updateQuery("UPDATE `friend_posters` SET `status`='FINISHED' WHERE `friendmage_order_key`='"+orderKey+"'");
        }
        catch (Exception e)
        {
            logger.error("Failed to update database",e);
             throw e;
        }

        
    }

    private void drawThumb(int i, int dimension, Image thumb, Graphics g,int cHeight) {
            int x = border + (i % perRow) * (dimension + gap);
            int y = border + ((int) (i/perRow)) * (dimension + gap) - cHeight;

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

            g.drawImage(thumb, x, y, x + dimension, y + dimension, sx, sy, sx + sw, sy + sh, null);
    }
}
