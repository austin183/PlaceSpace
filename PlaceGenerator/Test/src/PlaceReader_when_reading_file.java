import com.lovedLabor.PlaceReader;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.net.URL;


public class PlaceReader_when_reading_file {
    @Test
    public void should_fail_to_find_file_for_reading_when_filePath_is_not_provided() {
        String filePath = "";
        try {
            PlaceReader reader = new PlaceReader(filePath);
        } catch (Exception e) {
            Assertions.assertTrue(true, "should have failed to find file because filepath is blank");
        }
    }

    @Test
    public void should_fail_to_find_file_for_reading_when_file_does_not_exist() {
        String filePath = "gibberish";
        try {
            PlaceReader reader = new PlaceReader(filePath);
        } catch (Exception e) {
            Assertions.assertTrue(true, "should have failed to find file because filepath is nonexistent");
        }
    }

    @Test
    public void should_find_existing_file_for_reading_and_return_the_line_count() {
        ClassLoader classLoader = getClass().getClassLoader();
        URL resource = classLoader.getResource("test.txt");
        String filePath = resource.getPath();
        try {
            PlaceReader reader = new PlaceReader(filePath);
            int actual = reader.getLineCount();
            Assertions.assertEquals(15, actual);
        } catch (Exception e) {
            e.printStackTrace();
            Assertions.fail("Unexpected exception");
        }
    }

    @Test
    public void should_get_next_line_for_test_file() {
        ClassLoader classLoader = getClass().getClassLoader();
        URL resource = classLoader.getResource("test.txt");
        String filePath = resource.getPath();
        try {
            PlaceReader reader = new PlaceReader(filePath);
            String actual = reader.getNextLine();
            Assertions.assertEquals("ts,user,x_coordinate,y_coordinate,color", actual);
            actual = reader.getNextLine();
            Assertions.assertEquals("1491167838000,c2Md9m4QckH8M+lhNh9btgoiFDk=,326,258,0", actual);
            int countDown = reader.getLineCount() - 1;
            while (countDown > 0) {
                countDown--;
                String line = reader.getNextLine();
                Assertions.assertFalse(line.isEmpty(), "Expecting data from the file");
            }
            String line = reader.getNextLine();
            Assertions.assertNull(line, "Line should be null");
        } catch (Exception e) {
            e.printStackTrace();
            Assertions.fail("Unexpected exception");
        }
    }

    @Test
    public void should_output_full_csv_to_color_coordinates_only() {
        try {
            PlaceReader reader = new PlaceReader("/Users/austin/Documents/PlaceSpace/tile_placements.csv");
            System.out.println(reader.getLineCount());
        } catch (IOException e) {
            e.printStackTrace();
            Assertions.fail("Should not have failed unless the file moved");
        }

    }
}
