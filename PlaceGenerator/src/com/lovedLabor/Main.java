package com.lovedLabor;

import java.io.IOException;

public class Main {

    public static void main(String[] args) {
        String inputFilePath = "";
        String outputDirectory = "";
        int targetFrames = 10000;
        int maxBufferSize = 25;
        int i = 0, j;
        String arg;

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
            } else if (arg.equalsIgnoreCase("-bufferSize") || arg.equalsIgnoreCase("-b")) {
                maxBufferSize = Integer.parseInt(args[i++]);
            }
        }

        if (inputFilePath.isEmpty() || outputDirectory.isEmpty()) {
            showUsage(targetFrames);
            return;
        }
        outputSettings(inputFilePath, outputDirectory, targetFrames, maxBufferSize);
        performActionWithSettings(inputFilePath, outputDirectory, targetFrames, maxBufferSize);

    }

    private static void toConsole(String output) {
        System.out.println(output);
    }

    private static void outputSettings(String inputFilePath, String outputDirectory, int targetFrames, int maxBufferSize) {
        toConsole("inputFilePath: " + inputFilePath);
        toConsole("outputDirectory: " + outputDirectory);
        toConsole("targetFrames" + targetFrames);
        toConsole("imageBufferSize" + maxBufferSize);
    }

    private static void showUsage(int targetFrames) {
        toConsole("Usage: Cmd -i inputFile -o outputDirectory [-t fps]");
        toConsole("-o or -outputDirectory: where to write the png files");
        toConsole("-i or -inputFile: the csv with the pixel placements");
        toConsole("-t or -targetFrames: the approximate number of frames to produce in the outputDirectory");
        toConsole("-b or -bufferSize: how many images to store in memory before writing them to disk");
        toConsole("Notes: The targetFrames are defaulted to " + targetFrames);
        toConsole("       The lower the targetFrames, the faster the overall process will go");
        toConsole("       and the amount of disk space required will be smaller (30000 takes about 8.5GB)");
        toConsole("       However, fewer frames also means less detail in the overall timelapse");
        toConsole("");
        toConsole("bufferSize affects how many frames get built in memory before writing them all to disk");
        toConsole(" This helps in that the system can handle batches of file io better than sporadic file io");
        toConsole(" which makes the export slightly faster and less disk intensive");
        toConsole(" the default is 25, which uses 600 to 700MB or RAM");
        toConsole(" a buffer size of 300 uses about 1.5GB of RAM");
        toConsole(" they both performed similarly in my testing, but your mileage my vary");
    }

    private static void performActionWithSettings(String inputFilePath, String outputDirectory, int targetFrames, int maxBufferSize) {
        try {
            PlaceReader reader = new PlaceReader(inputFilePath);
            PlaceImageWriter writer = new PlaceImageWriter();
            String directoryPath = outputDirectory;
            writer.writeSeries(reader, targetFrames, directoryPath, maxBufferSize);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
