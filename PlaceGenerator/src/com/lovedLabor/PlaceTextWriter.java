package com.lovedLabor;

import java.io.*;
import java.util.UUID;

public class PlaceTextWriter {
    private int buffer = 20000;
    private int counter = 0;
    private StringBuilder builder = new StringBuilder();
    private String tempName;
    private String finalFilePath;

    public PlaceTextWriter(String outputPath) throws IOException {
        finalFilePath = outputPath;
        tempName = File.createTempFile("got-", ".txt").getAbsolutePath();
    }

    public void writeLine(String line) throws IOException {
        builder.append(line + "\n");
        counter++;
        if(counter == buffer){
            flushBufferToFile();
        }
    }

    public void flushBufferToFile() throws IOException {
        FileWriter fw = new FileWriter(tempName, true);
        BufferedWriter bw = new BufferedWriter(fw);
        PrintWriter out = new PrintWriter(bw);
        String outputString = builder.toString();
        if(outputString.trim().length() > 0){
            out.println(builder.toString().trim());
        }
        out.close();
        bw.close();
        fw.close();
        counter = 0;
        builder = null;
        builder = new StringBuilder();
    }

    public void finalizeTextFile() throws IOException {
        if(counter > 0){
            flushBufferToFile();
        }
        copyFileUsingStream(new File(tempName), new File(finalFilePath));
    }


    private static void copyFileUsingStream(File source, File dest) throws IOException {
        InputStream is = null;
        OutputStream os = null;
        try {
            is = new FileInputStream(source);
            os = new FileOutputStream(dest);
            byte[] buffer = new byte[1024];
            int length;
            while ((length = is.read(buffer)) > 0) {
                os.write(buffer, 0, length);
            }
        } finally {
            is.close();
            os.close();
        }
    }

}
