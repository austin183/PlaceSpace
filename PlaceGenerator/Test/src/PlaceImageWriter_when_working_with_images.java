import com.lovedLabor.PlaceImageWriter;
import com.lovedLabor.PlaceReader;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.net.URL;

public class PlaceImageWriter_when_working_with_images {
    @Test
    public void should_create_new_image_with_white_background() {
        PlaceImageWriter writer = null;
        try {
            writer = new PlaceImageWriter();

            BufferedImage image = writer.getCurrentImage();

            File temp = File.createTempFile("img", "test").getAbsoluteFile();
            System.out.println(temp.getAbsolutePath());
            ImageIO.write(image, "PNG", temp);
        } catch (IOException e) {
            e.printStackTrace();
            Assertions.fail();
        }
    }

    @Test
    public void should_create_new_image_with_white_background_and_a_few_pixels_from_x_y_color_index() {
        PlaceImageWriter writer = null;
        try {
            writer = new PlaceImageWriter();
            int x = 500;
            int y = 500;
            int colorIndex = 4; //pink
            writer.changePixel(x, y, colorIndex);
            writer.changePixel(x+1, y, colorIndex);
            writer.changePixel(x, y+1, colorIndex);
            writer.changePixel(x-1, y, colorIndex);
            writer.changePixel(x, y-1, colorIndex);
            BufferedImage image = writer.getCurrentImage();


            File temp = File.createTempFile("img", "test").getAbsoluteFile();
            System.out.println(temp.getAbsolutePath());
            writer.writeToFile(temp);
        } catch (IOException e) {
            e.printStackTrace();
            Assertions.fail();
        }
    }

    @Test
    public void should_create_new_image_and_generate_pixel_values_from_file(){
        try {
            ClassLoader classLoader = getClass().getClassLoader();
            URL resource = classLoader.getResource("bigccTest.txt");
            String filePath = resource.getPath();
            PlaceReader reader = new PlaceReader(filePath);
            int lineCount=reader.getLineCount();
            System.out.println(lineCount);
            PlaceImageWriter writer = new PlaceImageWriter();
            String line = "";
            int counter = 0;
            while(line != null){
                counter++;
                line = reader.getNextLine();
                if(line == null) continue;
                try{
                    String[] split = line.split(",");
                    if(Integer.parseInt(split[0]) > 0 ){
                        int x = Integer.parseInt(split[0]);
                        int y = Integer.parseInt(split[1]);
                        int ci = Integer.parseInt(split[2]);
                        System.out.println("changing " + x + " " + y + " to ci" + ci);
                        writer.changePixel(x, y, ci);
                    }
                }catch(NumberFormatException e){
                    e.printStackTrace();
                    continue;
                }
            }
            File temp = File.createTempFile("img", "test.png").getAbsoluteFile();
            System.out.println(temp.getAbsolutePath());
            writer.writeToFile(temp);
        } catch (Exception e) {
            e.printStackTrace();
            Assertions.fail("Should not have failed unless the file moved");
        }

    }
}
