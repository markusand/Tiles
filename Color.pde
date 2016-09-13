/*
 * COLOR CLASS
 * 
 * Class used to encapsulate basic colors and adjusted values, plus some utilities to deal with colors
 *
 * @author          Marc Vilella
 *                  Observatori de la Sostenibilitat d'Andorra (OBSA)
 *                  mvilella@obsa.ad
 * @contributors    
 * @copyright       Copyright (c) 2016 Marc Vilella
 * @license         MIT License
 * @required        
 * @version         1.0a
 *
 * @bugs       
 *
 * @todo            Implement simple dictionary for color names
*/


private static class Color {
    
    /* ATTRIBUTES ---------------------------------------------------------------------------------> */
    
    private int id;
    private String name;
    private IntList values = new IntList();
    private boolean binary;
    
    
    /* CONSTRUCTORS ------------------------------------------------------------------------------> */
    
    /*
    * Construct a Color object with all basic settings
    * @param id  Color id
    * @param name  Color name
    * @param binary  True if color is used as codification color
    * @param value  Color values in #hex format or rgba() format
    */
    
    Color(int id, String name, boolean binary, String... values) {
        this.id = id;
        this.name = name;
        this.binary = binary;
        for(int i = 0; i < values.length; i++) {
            this.values.append( decode(values[i]) );
        }
    }
    
    
    /* GETTERS & SETTERS --------------------------------------------------------------------------> */
    
    private int getID() { return id; }
    private String getName() { return name; }
    private color getColor() { return values.get( values.size()-1 ); }
    private color getBaseColor() { return values.get(0); }
    private void setAdjusted(color value) { values.set(1, value); }
    
    
    /* METHODS ------------------------------------------------------------------------------------> */
    
    /*
    * Decode a color in any of the allowed formats as an int value
    * @param fColor  String with color in hex #xxxxxx or rgba(xx,xx,xx,xx) formats
    * @return color in integer format
    */
    private static color decode(String fColor) {
        // Hex format #AARRGGBB
        if( fColor.indexOf("#") != -1 ) {  
            return unhex( fColor.substring(1) );
        // aRGB format rgba(RR, GG, BB, AA)
        } else if( fColor.indexOf("rgba(") != -1 ) {  
            String[] RGBA = split( fColor.substring(5, fColor.length()-1) , ",");
            int R = (int(RGBA[0]) << 16) & 0x00FF0000;
            int G = (int(RGBA[1]) << 8) & 0x0000FF00;
            int B = int(RGBA[2]) & 0x000000FF;
            int A = (int(RGBA[3]) << 24) & 0xFF000000;
            return 0x00000000 | A | R | G | B; 
        // Use dictionary for color
        } else {
        }
        return 0;
    }
    
    
    
    /*
    * Get the average color in pixels of an image
    * @param img  Image to find the average color 
    * @return average color in image
    */
    private static int average(PImage img) {
        img.loadPixels();
        int R = 0, G = 0, B = 0;
        for(int i = 0; i < img.pixels.length; i++) {
            R += img.pixels[i] >> 16&0xFF;
            G += img.pixels[i] >> 8&0xFF;
            B += img.pixels[i] &0xFF;
        }
        R /= img.pixels.length;
        G /= img.pixels.length;
        B /= img.pixels.length;
        R = (R << 16) & 0x00FF0000;
        G = (G << 8) & 0x0000FF00;
        B = B & 0x000000FF;
        return 0xFF000000 | R | G | B;
    }
    
    
    
    /*
    * Compare a color with a set of reference colors
    * @param c  Color to compare
    * @param refColors  Set of colors to find closest to c
    * @return closest color to c in refColors set
    */
    public static Color compare(color c, ArrayList<Color> refColors) {
        float minDist = Float.MAX_VALUE;
        Color closestColor = null;
        for(Color refC : refColors) {
            float dist = dist( refC.getColor() >> 16&0xFF, refC.getColor() >> 8&0xFF, refC.getColor() &0xFF, c >> 16&0xFF, c >> 8&0xFF, c &0xFF );
            if( dist < minDist ) {
                minDist = dist;
                closestColor = refC;
            }
        }
        return closestColor;
        
    }
       
    
}