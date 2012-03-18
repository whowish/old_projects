/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package friendposter;

import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.net.MalformedURLException;
import java.net.URL;
import javax.imageio.ImageIO;
import org.apache.log4j.Logger;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import javax.imageio.IIOImage;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.metadata.IIOMetadata;
import javax.imageio.stream.ImageOutputStream;

/**
 *
 * @author Tanin
 */
public abstract class AbstractImageEntity {

    public static String CONVERT_PATH = "\"C:/Program Files/ImageMagick-6.6.6-Q16/convert.exe\"";
    public static String DOMAIN_NAME = "www.friendmage.com";
    public static String RAILS_ROOT = "../public/uploads";

    static {
        // windows

        String[] possiblePath = {
            "C:/Program Files/ImageMagick-6.6.6-Q16/convert.exe",
            "C:/Program Files/ImageMagick-6.6.7-Q16/convert.exe"
        };

        boolean existWindow = false;

        for (int i=0;i<possiblePath.length;i++)
        {
            if ((new File(possiblePath[i])).exists())
            {
                CONVERT_PATH = "\""+possiblePath[i]+"\"";
                existWindow = true;
            }
        }

        if (existWindow)
        {
            
            RAILS_ROOT = "../public/uploads";
            System.out.println("This is Windows");
        }
        else // linux
        {
            CONVERT_PATH = "convert";
            RAILS_ROOT = "/friendmage/shared/public/uploads";
            System.out.println("This is Linux");
        }

    }

    public MySqlConnector mysql = new MySqlConnector();

    private static Logger logger = Logger.getLogger(AbstractImageEntity.class);

    public static boolean TEST_MODE = false;
    public String appId = "UNKNOWN";
    public String orderKey = "";
    public String printImageUrl = "";
    public String signatureImageUrl = "";
    public String previewImageUrl = "";
    public String backgroundColor = "000000";
    public int width = 6000;

    public String originalFilename;
    public String originalFilePath;

    public String previewFilename;
    public String previewFilePath;

    public String signatureFilename;
    public String signatureFilePath;

    public static int PREVIEW_WIDTH = 600;
    public int previewHeight;

    ArrayList<String> partialFileNames = new ArrayList<String>();
    ArrayList<String> previewPartialFileNames = new ArrayList<String>();

    public BufferedImage createPartialImage(int height)
    {
        Color bgColor = new Color(Integer.parseInt(backgroundColor, 16));
        BufferedImage img = new BufferedImage(width,height,BufferedImage.TYPE_INT_RGB);

        Graphics g = img.getGraphics();
        g.setColor(bgColor);
        g.fillRect(0, 0, width, height);
        return img;
    }

    public void writeToPartialFile(BufferedImage img) throws Exception
    {
        int width = img.getWidth();
        int height = img.getHeight();

        {
            String thisFileName = RAILS_ROOT + "/partial"+ orderKey+"--"+partialFileNames.size()+".jpg";
            writeJpeg(img, thisFileName);
            partialFileNames.add(thisFileName);

            logger.debug("partial="+thisFileName+" ("+width+"x"+height+")");
        }

        previewHeight = PREVIEW_WIDTH * height / width;
        
        BufferedImage previewImg = new BufferedImage(PREVIEW_WIDTH,previewHeight,BufferedImage.TYPE_INT_RGB);
        Graphics2D g = (Graphics2D)previewImg.getGraphics();
        g.setComposite(AlphaComposite.Src);

        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION,RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.setRenderingHint(RenderingHints.KEY_RENDERING,RenderingHints.VALUE_RENDER_QUALITY);
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,RenderingHints.VALUE_ANTIALIAS_ON);
        
        g.drawImage(img, 0, 0, PREVIEW_WIDTH, previewHeight, 0, 0, width, height, null);

        {
            String thisFileName = RAILS_ROOT + "/partial"+ orderKey+"--"+previewPartialFileNames.size()+"--preview.jpg";
            writeJpeg(previewImg, thisFileName);
            previewPartialFileNames.add(thisFileName);
        }
    }

    public void runCommand(String cmd) throws Exception
    {
        runCommand(new String[] {cmd});
    }

    public void runCommand(ArrayList<String> cmdBuffer) throws Exception
    {
        String[] cmds = new String[cmdBuffer.size()];

        for (int i=0;i<cmds.length;i++) cmds[i] = cmdBuffer.get(i);
        runCommand(cmds);
    }

    public void runCommand(String[] cmd) throws Exception
    {
        StringBuffer b = new StringBuffer();
        for (int i=0;i<cmd.length;i++) b.append(" "+cmd[i]);

        logger.debug("Run " + b.toString());

        Process pr = Runtime.getRuntime().exec(cmd);

        BufferedReader input = new BufferedReader(new InputStreamReader(pr.getInputStream()));

        String line=null;

        while((line=input.readLine()) != null) {
            logger.debug("> " + line);
        }


        int exitVal = pr.waitFor();
        logger.debug("Exit "+exitVal);

        if (exitVal != 0) throw new Exception("Return value from command line is not 0");
    }

    public void composePartialFiles() throws Exception
    {
        originalFilename = orderKey+"--"+Math.random()+".jpg";
        originalFilePath = RAILS_ROOT + "/"+originalFilename;

        previewFilename = orderKey+"--"+Math.random()+"-preview.jpg";
        previewFilePath = RAILS_ROOT + "/"+previewFilename;

        {
            ArrayList<String> cmds = new ArrayList<String>();
            cmds.add(CONVERT_PATH);

            for (int i=0;i<partialFileNames.size();i++) cmds.add(partialFileNames.get(i));

            cmds.add("-append");
            cmds.add(originalFilePath);

            runCommand(cmds);

            printImageUrl = "http://"+DOMAIN_NAME+"/uploads/"+originalFilename;

            for (int i=0;i<partialFileNames.size();i++)
            {
                new File(partialFileNames.get(i)).delete();
            }
        }

        {
            ArrayList<String> cmds = new ArrayList<String>();
            cmds.add(CONVERT_PATH);

            for (int i=0;i<previewPartialFileNames.size();i++) cmds.add(previewPartialFileNames.get(i));

            cmds.add("-append");
            cmds.add(previewFilePath);

            runCommand(cmds);

            previewImageUrl = "http://"+DOMAIN_NAME+"/uploads/"+previewFilename;

            for (int i=0;i<previewPartialFileNames.size();i++)
            {
                new File(previewPartialFileNames.get(i)).delete();
            }
        }

    }

    public static void writePng(BufferedImage img, String filepath) throws Exception
    {
        ImageIO.write(img, "png", new File(filepath));
    }

    public static void writeJpeg(BufferedImage img, String filepath) throws Exception
    {
        Iterator writers = ImageIO.getImageWritersBySuffix("jpeg");

        if (!writers.hasNext()) throw new IllegalStateException("No writers for jpeg?!");

        ImageWriter writer = (ImageWriter) writers.next();
        ImageWriteParam imageWriteParam = writer.getDefaultWriteParam();
        imageWriteParam.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);

        List thumbNails = null;
        IIOImage iioImage = new IIOImage(img, thumbNails, (IIOMetadata) null);
        writeStream(writer, imageWriteParam, iioImage, filepath, 1.0f);
    }

    public static void writeStream(ImageWriter writer, ImageWriteParam imageWriteParam,
            IIOImage iioImage, String filepath, float compressionQuality) throws IOException
    {
        ImageOutputStream out = ImageIO.createImageOutputStream(new File(filepath));
        imageWriteParam.setCompressionQuality(compressionQuality);
        writer.setOutput(out);
        writer.write((IIOMetadata) null, iioImage, imageWriteParam);
        out.flush();
        out.close();
    }


    public abstract void generate() throws Exception;

    public void writeSignatureImageToFile(BufferedImage img)throws Exception{
        signatureFilename = orderKey+"--"+Math.random()+"-signature.jpg";
        signatureFilePath = RAILS_ROOT + "/"+signatureFilename;
        try
        {
            writeJpeg(img, signatureFilePath);

            signatureImageUrl = "http://"+DOMAIN_NAME+"/uploads/"+signatureFilename;

        } catch (Exception e) {
            logger.error("Cannot write image to '" + signatureFilePath + "'",e);
            throw e;
        }
    }

    public Image readFromUrl(String url_string) throws Exception
    {
        //logger.debug("Read image from " + url_string);
        int retry_count = 0;
        while (true)
        {
            try
            {
                
               return ImageIO.read(new URL(url_string));
            }
            catch (MalformedURLException e)
            {
                logger.error("MalformedURL ",e);
                throw e;
            }
            catch (Exception e)
            {
                retry_count++;
                
                try { Thread.sleep(1000); } catch (Exception e2) {}

                if (retry_count >= 10) {
                    logger.error("Error while reading image " + url_string,e);
                    throw e;
                }

                if (retry_count >= 8) {
                    logger.error("Cannot load image. Switch to default image.");
                    url_string = "http://b.static.ak.fbcdn.net/rsrc.php/v1/yp/r/yDnr5YfbJCH.gif";
                }

            }
        }

    }

    
    public BufferedImage resizeImage(BufferedImage img,int width,int height)
    {
        BufferedImage newImg = new BufferedImage(width,height,BufferedImage.TYPE_INT_ARGB);
        Graphics g = newImg.getGraphics();

        g.drawImage(img, 0, 0, width, height, null);

        return newImg;
    }
   

    public void updateOrderUrl() throws Exception
    {
        if (TEST_MODE) return;
        mysql.updateQuery("UPDATE `orders` SET `print_image_url`='"+printImageUrl+"', `signature_image_url`='"+signatureImageUrl+"', `preview_image_url`='"+previewImageUrl+"' WHERE `key`='"+orderKey+"'");
    }
}
