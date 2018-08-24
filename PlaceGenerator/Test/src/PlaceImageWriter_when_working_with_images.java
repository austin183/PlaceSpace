import com.lovedLabor.PlaceImageWriter;
import org.junit.jupiter.api.Test;

import java.awt.image.BufferedImage;

public class PlaceImageWriter_when_working_with_images {
    @Test
    public void should_create_new_image_with_white_background(){
        PlaceImageWriter writer = new PlaceImageWriter();
        BufferedImage image = writer.getCurrentImage();
    }
}
