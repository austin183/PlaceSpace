import com.lovedLabor.PlaceReader;
import com.lovedLabor.PlaceShrink;
import com.lovedLabor.PlaceTextWriter;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.io.IOException;
import java.net.URL;

public class PlaceShrink_when_converting_full_csv_to_color_coordinates_only {
    @Test
    public void should_output_full_csv_to_color_coordinates_only() throws IOException {
        ClassLoader classLoader = getClass().getClassLoader();
        URL resource = classLoader.getResource("test.txt");
        String filePath = resource.getPath();
        File got = File.createTempFile("got-", ".txt");
        String outputPath = got.getAbsolutePath();
        try {
            PlaceReader reader = new PlaceReader(filePath);
            //PlaceReader reader = new PlaceReader("!/Documents/PlaceSpace/tile_placements.csv");
            PlaceShrink shrink = new PlaceShrink(reader, new PlaceTextWriter(outputPath));
            shrink.writePlaceAsColorAndCoordinatesOnly();
            PlaceReader resultsReader = new PlaceReader(outputPath);
            System.out.println(outputPath);
            Assertions.assertTrue(resultsReader.getLineCount() > 0, "Should get lines in the output file");
        }catch (Exception e){
            e.printStackTrace();
            Assertions.fail();
        }

    }
}
