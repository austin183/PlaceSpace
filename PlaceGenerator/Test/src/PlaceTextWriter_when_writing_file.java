import com.lovedLabor.PlaceReader;
import com.lovedLabor.PlaceTextWriter;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.io.File;

public class PlaceTextWriter_when_writing_file {
    @Test
    public void should_write_multiple_lines(){
        try{
            File got = File.createTempFile("got-", ".txt");
            String outputPath = got.getAbsolutePath();
            PlaceTextWriter writer = new PlaceTextWriter(outputPath);
            writer.writeLine("Hello");
            writer.writeLine("Hi");
            writer.finalizeTextFile();
            PlaceReader reader = new PlaceReader(got.getPath());
            int lineCount = reader.getLineCount();
            Assertions.assertTrue(lineCount > 0, "Should have found two lines");
        }
        catch (Exception e){
            e.printStackTrace();
            Assertions.fail("Should not have thrown exception");
        }
    }
}
