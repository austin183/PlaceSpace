package com.lovedLabor;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.color.ColorSpace;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.IndexColorModel;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

public class PlaceImageWriter {
    BufferedImage currentImage;
    IndexColorModel model;
    Graphics2D graphics;

    public PlaceImageWriter() throws IOException {
        model = new PlaceColorModel().getPlaceColorModel();
        currentImage = new BufferedImage(1000,1000, BufferedImage.TYPE_BYTE_BINARY, model);
        graphics = currentImage.createGraphics();
        graphics.setBackground(Color.white);
    }

    public BufferedImage getCurrentImage() {
        return currentImage;
    }

    public void changePixel(int x, int y, int colorIndex) {
        int r = model.getRed(colorIndex);
        int g = model.getGreen(colorIndex);
        int b = model.getBlue(colorIndex);
        int p = (r<<16) | (g<<8) | b;
        try{
            currentImage.setRGB(x, y, p);
        }
        catch (Exception e){
            e.printStackTrace();
            System.out.println("x " + x + " y " + y);
        }

    }

    public void writeToFile(File file) throws IOException {
        ImageIO.write(currentImage, "PNG", file);
    }
}
