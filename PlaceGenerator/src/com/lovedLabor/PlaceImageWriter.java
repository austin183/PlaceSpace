package com.lovedLabor;

import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.IndexColorModel;
import java.util.ArrayList;

public class PlaceImageWriter {
    BufferedImage currentImage;

    public PlaceImageWriter(){



        currentImage = new BufferedImage(1000,1000, BufferedImage.TYPE_BYTE_INDEXED);

    }

    public BufferedImage getCurrentImage() {
        return currentImage;
    }
}
