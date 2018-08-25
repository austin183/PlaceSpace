package com.lovedLabor;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.IndexColorModel;
import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class PlaceImageWriter {
    private BufferedImage currentImage;
    private IndexColorModel model;
    private Graphics2D graphics;
    private List<BufferedImage> imageFileBuffer;
    private int maxBufferSize = 100;
    private int fileCounter = 0;
    private int frameCountLength = 0;

    public PlaceImageWriter() throws IOException {
        model = new PlaceColorModel().getPlaceColorModel();
        currentImage = new BufferedImage(1001, 1001, BufferedImage.TYPE_BYTE_BINARY, model);
        graphics = currentImage.createGraphics();
        graphics.setBackground(Color.white);
        imageFileBuffer = new ArrayList<>();
    }

    public BufferedImage getCurrentImage() {
        return currentImage;
    }

    public void changePixel(int x, int y, int colorIndex) {
        int r = model.getRed(colorIndex);
        int g = model.getGreen(colorIndex);
        int b = model.getBlue(colorIndex);
        int p = (r << 16) | (g << 8) | b;
        try {
            currentImage.setRGB(x, y, p);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("x " + x + " y " + y);
        }
    }

    public void writeToFile(BufferedImage currentImage, File file) throws IOException {
        ImageIO.write(currentImage, "PNG", file);
    }

    public void writeSeries(PlaceReader reader, int targetFrames, String directoryPath) {
        try {
            long start = System.nanoTime();
            int cutContentPeriod = reader.getLineCount() / targetFrames;
            String line = "";
            frameCountLength = String.valueOf(targetFrames).length() + 1;
            int counter = 0;
            int lineCount = reader.getLineCount();
            while (line != null) {
                line = reader.getNextLine();
                counter++;
                changePixelFromLine(line, counter, lineCount);
                if (counter % cutContentPeriod == 0) {
                    writeSeriesFile(directoryPath);
                }
            }
            if (counter % cutContentPeriod != 0) {
                writeSeriesFile(directoryPath);
            }
            writeLastOfSeriesToFile(directoryPath);
            System.out.println("Write Series took " + String.valueOf(System.nanoTime() - start) + " nanoseconds");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void writeLastOfSeriesToFile(String directoryPath) throws IOException {
        writeFilesFromBuffer(directoryPath);
    }

    private void writeSeriesFile(String directoryPath) throws IOException {
        imageFileBuffer.add(deepCopy(currentImage));
        if (imageFileBuffer.size() > maxBufferSize) {
            writeFilesFromBuffer(directoryPath);
        }
    }

    private void writeFilesFromBuffer(String directoryPath) throws IOException {
        long start = System.nanoTime();
        System.out.println("Buffer Started at file number" + fileCounter);
        for (BufferedImage image : imageFileBuffer) {
            int counterLength = String.valueOf(fileCounter).length();
            String filler = new String(new char[frameCountLength]).replace("\0", "0");
            String suffix = (filler + String.valueOf(fileCounter)).substring(counterLength);
            Path filePath = Paths.get(directoryPath, "image_" + suffix + ".png");
            File file = filePath.toFile();
            if (fileCounter % maxBufferSize == 0) System.out.println(filePath);
            writeToFile(image, file);
            fileCounter++;
        }
        System.out.println("Buffer Write took " + (System.nanoTime() - start) * .000000001 + " seconds");
        imageFileBuffer.clear();
    }

    private BufferedImage deepCopy(BufferedImage bi) {
        ColorModel cm = model;
        boolean isAlphaPremultiplied = cm.isAlphaPremultiplied();
        return new BufferedImage(cm, bi.copyData(null), isAlphaPremultiplied, null);
    }

    private void changePixelFromLine(String line, int counter, int lineCount) {
        int x;
        int y;
        int ci;
        String[] split = line.split(",");
        try {
            if (Integer.parseInt(split[0]) > 0) {
                x = Integer.parseInt(split[0]);
                y = Integer.parseInt(split[1]);
                ci = Integer.parseInt(split[2]);
                changePixel(x, y, ci);
            }
        } catch (NumberFormatException e) {
            return;
        }

    }
}
