package com.lovedLabor;

import java.io.IOException;

public class PlaceShrink {
    private PlaceReader reader;
    private PlaceTextWriter writer;

    public PlaceShrink(PlaceReader source, PlaceTextWriter destination) {
        reader = source;
        writer = destination;
    }

    public void writePlaceAsColorAndCoordinatesOnly() throws IOException {
        String line = "";
        int commasToCut = 2;
        do {
            line = reader.getNextLine();
            if (line != null && !line.isEmpty()) {
                int lastCommaIndex = 0;
                for (int i = 0; i < commasToCut; i++) {
                    lastCommaIndex = line.indexOf(',', lastCommaIndex + 1);
                }
                line = line.substring(lastCommaIndex + 1);
                writer.writeLine(line);
            }
        } while (line != null);
        writer.finalizeTextFile();
    }
}
