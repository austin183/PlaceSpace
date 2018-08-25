package com.lovedLabor;

import java.io.IOException;

public class Main {

    public static void main(String[] args) {
        String inputFilePath = "";
        String outputDirectory = "";
        int targetFrames = 10000;
        int i = 0, j;
        String arg;
        char flag;

        if (i == args.length) {
            showUsage(targetFrames);
            return;
        }

        while (i < args.length && args[i].startsWith("-")) {
            arg = args[i++];

            if (arg.equalsIgnoreCase("-inputFile") || arg.equalsIgnoreCase("-i")) {
                if (i < args.length)
                    inputFilePath = args[i++];
                else
                    System.err.println("-inputFile requires a filename");
            } else if (arg.equalsIgnoreCase("-outputDirectory") || arg.equalsIgnoreCase("-o")) {
                if (i < args.length)
                    outputDirectory = args[i++];
                else
                    System.err.println("-outputDirectory requires a filename");
            } else if (arg.equalsIgnoreCase("-targetFrames") || arg.equalsIgnoreCase("-t")) {
                targetFrames = Integer.parseInt(args[i++]);
            }
        }

        if (inputFilePath.isEmpty() || outputDirectory.isEmpty()) {
            showUsage(targetFrames);
            return;
        }
        outputSettings(inputFilePath, outputDirectory, targetFrames);
        performActionWithSettings(inputFilePath, outputDirectory, targetFrames);

    }

    private static void outputSettings(String inputFilePath, String outputDirectory, int targetFrames) {
        System.out.println(inputFilePath);
        System.out.println(outputDirectory);
        System.out.println(targetFrames);
    }

    private static void showUsage(int targetFrames) {
        System.out.println("Usage: Cmd -i inputFile -o outputDirectory [-t fps]");
        System.out.println("-o or -outputDirectory: where to write the png files");
        System.out.println("-i or -inputFile: the csv with the pixel placements");
        System.out.println("-t or -targetFrames: the approximate number of frames to produce in the outputDirectory");
        System.out.println("Note: The targetFrames are defaulted to " + targetFrames);
        System.out.println("      The lower the targetFrames, the faster the overall process will go");
        System.out.println("      and the amount of disk space required will be smaller (30000 takes about 8.5GB)");
        System.out.println("      However, fewer frames also means less detail in the overall timelapse");
    }

    private static void performActionWithSettings(String inputFilePath, String outputDirectory, int targetFrames) {
        try {
            PlaceReader reader = new PlaceReader(inputFilePath);
            int lineCount = reader.getLineCount();
            System.out.println(lineCount);
            PlaceImageWriter writer = new PlaceImageWriter();
            String directoryPath = outputDirectory;
            writer.writeSeries(reader, targetFrames, directoryPath);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
