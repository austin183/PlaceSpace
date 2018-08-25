import com.lovedLabor.PlaceColorModel;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.awt.image.IndexColorModel;

public class PlaceColorModel_when_building_IndexColorModel {
    @Test
    public void should_return_IndexColorModel_for_place() {
        IndexColorModel model = new PlaceColorModel().getPlaceColorModel();
        Assertions.assertTrue(model.isValid());

    }
}
