package com.lovedLabor;

import java.io.*;

public class PlaceReader {
    private BufferedReader reader;
    private int lineCount;
    public PlaceReader(String filePath) throws IllegalArgumentException, IOException, IndexOutOfBoundsException {
        if(filePath.isEmpty()) throw new IllegalArgumentException("Cannot read a blank string as a path to a file");
        reader = new BufferedReader(new FileReader(filePath));
        lineCount = getLineCount(filePath);
        if(lineCount <= 1) throw new IndexOutOfBoundsException("Could not find any lines to process");
    }

    public void throwNoReaderAvailableError(){
        if(reader == null) throw new NullPointerException("No reader available");
    }

    public String getNextLine() throws IOException {
        throwNoReaderAvailableError();
        String line = reader.readLine();
        return line;
    }

    public int getLineCount(){
        return lineCount;
    }

    private int getLineCount(String filePath) throws IOException {
        InputStream is = new BufferedInputStream(new FileInputStream(filePath));
        try {
            byte[] c = new byte[1024];

            int readChars = is.read(c);
            if (readChars == -1) {
                // bail out if nothing to read
                return 0;
            }

            // make it easy for the optimizer to tune this loop
            int count = 0;
            while (readChars == 1024) {
                for (int i=0; i<1024;) {
                    if (c[i++] == '\n') {
                        ++count;
                    }
                }
                readChars = is.read(c);
            }

            // count remaining characters
            while (readChars != -1) {
                System.out.println(readChars);
                for (int i=0; i<readChars; ++i) {
                    if (c[i] == '\n') {
                        ++count;
                    }
                }
                readChars = is.read(c);
            }

            return count == 0 ? 1 : count;
        } finally {
            is.close();
        }
    }
}