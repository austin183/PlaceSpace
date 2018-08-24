/*
index	color code r,g,b
0	#FFFFFF 255,255,255 white
1	#E4E4E4 228,228,228 gray
2	#888888 136,136,136 darkgray
3	#222222 34,34,34 black
4	#FFA7D1 255,167,209 pink
5	#E50000 229,0,0 red
6	#E59500 229,149,0 dark yellow
7	#A06A42 160,106,66 brownorange
8	#E5D900 229,217,0 yellow
9	#94E044 148,224,68 limegreen
10	#02BE01 2,190,1 green
11	#00E5F0 0,229,240 lightblue
12	#0083C7 0,131,199 blue
13	#0000EA 0,0,234 royalblue
14	#E04AFF 224,74,255 magenta
15	#820080 130,0,128 offpurple
*/
package com.lovedLabor;

import java.awt.image.IndexColorModel;

public class PlaceColorModel {
    private byte[] r;
    private byte[] g;
    private byte[] b;

    public IndexColorModel getPlaceColorModel() {
        int bits = 4;
        int size = 16;
        r = new byte[size];
        g = new byte[size];
        b = new byte[size];

        setRGBByIndex(0, 255, 255, 255);
        setRGBByIndex(1, 228, 228, 228);
        setRGBByIndex(2, 136, 136, 136);
        setRGBByIndex(3, 34, 34, 34);
        setRGBByIndex(4, 255, 167, 209);
        setRGBByIndex(5, 229, 0, 0);
        setRGBByIndex(6, 229, 149, 0);
        setRGBByIndex(7, 160, 106, 66);
        setRGBByIndex(8, 229, 217, 0);
        setRGBByIndex(9, 148, 224, 68);
        setRGBByIndex(10, 2, 190, 1);
        setRGBByIndex(11, 0, 229, 240);
        setRGBByIndex(12, 0, 131, 199);
        setRGBByIndex(13, 0, 0, 234);
        setRGBByIndex(14, 224, 74, 255);
        setRGBByIndex(15, 130, 0, 128);
        return new IndexColorModel(bits, size, r, g, b);
    }

    private void setRGBByIndex(int i, int r, int g, int b) {
        this.r[i] = (byte) r;
        this.g[i] = (byte) g;
        this.b[i] = (byte) b;
    }


}
