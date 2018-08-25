package com.lovedLabor;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.color.ColorSpace;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.IndexColorModel;
import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;

public class PlaceImageWriter {
    BufferedImage currentImage;
    IndexColorModel model;
    Graphics2D graphics;

    public PlaceImageWriter() throws IOException {
        model = new PlaceColorModel().getPlaceColorModel();
        currentImage = new BufferedImage(1001,1001, BufferedImage.TYPE_BYTE_BINARY, model);
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

    public void writeSeries(PlaceReader reader, int targetFrames, String directoryPath) {
        try{
            int cutContentPeriod = reader.getLineCount() / targetFrames;
            String line = "";
            int frameCountLength = String.valueOf(targetFrames).length() +1;
            int counter = 0;
            int fileCounter = 0;
            int lineCount = reader.getLineCount();
            while(line != null){
                line = reader.getNextLine();
                counter++;
                changePixelFromLine(line, counter, lineCount);
                if(counter % cutContentPeriod == 0){
                    fileCounter++;
                    int counterLength = String.valueOf(fileCounter).length();
                    writeSeriesFile(directoryPath, frameCountLength, fileCounter, counterLength);
                }
            }
            if(counter % cutContentPeriod != 0){
                fileCounter++;
                int counterLength = String.valueOf(fileCounter).length();
                writeSeriesFile(directoryPath, frameCountLength, fileCounter, counterLength);
            }
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void writeSeriesFile(String directoryPath, int frameCountLength, int fileCounter, int counterLength) throws IOException {
        String filler = new String(new char[frameCountLength]).replace("\0", "0");
        String suffix = (filler + String.valueOf(fileCounter)).substring(counterLength);
        Path filePath = Paths.get(directoryPath, "image_"+suffix+".png");
        File file = filePath.toFile();
        if(fileCounter % 100 == 0) System.out.println(filePath);
        writeToFile(file);
    }

    private void changePixelFromLine(String line, int counter, int lineCount) {
        int x;
        int y;
        int ci;
        String[] split = line.split(",");
        try{
            if(Integer.parseInt(split[0]) > 0 ){
                x = Integer.parseInt(split[0]);
                y = Integer.parseInt(split[1]);
                ci = Integer.parseInt(split[2]);
                if(counter % 1000000 == 0)System.out.println(counter + " of " + lineCount + " changing " + x + " " + y + " to ci " + ci);
                changePixel(x, y, ci);
            }
        }
        catch (NumberFormatException e){
            return;
        }

    }
}
