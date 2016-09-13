/*
 * TABLEAU
 * 
 * Generate a Tableau (textured grid) surface, where every parameter is defined by a streaming message
 * that contains the layout and every tile configuration
 *
 * @author          Marc Vilella
 *                  Observatori de la Sostenibilitat d'Andorra (OBSA)
 *                  mvilella@obsa.ad
 * @contributors    
 * @copyright       Copyright (c) 2016 Marc Vilella
 * @license         MIT License
 * @required        Color class
 * @version         1.0a
 *
 * @bugs       
 *
 * @todo            Identify neighbors and adapt texture to them
 *                  3D object tiles
*/



// TABLEAU CLASS =========================================================================================================================
public class Tableau {

    /* ATTRIBUTES ---------------------------------------------------------------------------------> */

    private static final String TILES_FILE = "tiles.json";
    private static final String COLORS_FILE = "colors.json";

    private ArrayList<Tile> tiles;
    private int rows;
    private int cols;
    private float rotation = 0;

    HashMap<String, Color> colors;
    HashMap<String, Tile> molds;
  
    private boolean view3D = false;
  
  
    /* CONSTRUCTORS ------------------------------------------------------------------------------> */
    
    /*
    * Construct a Tableau surface with default settings
    * @param parent 
    */
    Tableau(PApplet parent) {
        this(parent, COLORS_FILE, TILES_FILE);
    }
  
    /*
    * Construct a Tiles surface from provided files
    * @param parent  Sketch environment
    * @param colorSettings  File path with colors' settings
    * @param tileSettings  File path with tiles' settings
    */
    Tableau(PApplet parent, String colorSettings, String tileSettings) {
        parent.registerMethod("mouseEvent", this);
        tiles = new ArrayList<Tile>();
        loadSettings(colorSettings, tileSettings);
        clear();
    }
  
  
    /* GETTERS & SETTERS --------------------------------------------------------------------------> */
    
    public void set3D(boolean view3D) { this.view3D = view3D; }
  
  
    /* METHODS ------------------------------------------------------------------------------------> */
    
    /*
    * Clear surface to empty state
    */
    public void clear() {
        tiles = new ArrayList<Tile>();
        rows = 0;
        cols = 0;
    }
  
  
  
    /*
    * Read JSON message and update tableau with new tiles
    * @param msg  JSON object with tableau configuration, with tiles' positions and rotations
    */
    public void update(JSONObject tableau) {
        this.clear();  // Reset grid
        JSONObject properties = tableau.getJSONObject("properties");
            cols = properties.getInt("columns");
            rows = properties.getInt("rows");
        JSONArray tiles = tableau.getJSONArray("tiles");
        for(int i = 0; i < tiles.size(); i++) {
            JSONObject tile = tiles.getJSONObject(i);
            createTile( tile.getString("name"), tile.getInt("x"), tile.getInt("y"), tile.getInt("rotation") );
        }
    }
  
  
  
    /*
    * Create new tile, cloning from a mold and adding location attributes
    * @param name  Name of the tile to be cloned
    * @param x  Column position in the surface
    * @param y  Row position in the surface
    * @param rotation  Rotation of the tile [0, 90, 180, 270]
    */
    public void createTile(String name, int x, int y , int rotation){
        Tile tile = molds.get(name).clone();
             tile.setPosition(x, y);
             tile.setRotation(rotation);
        tiles.add( tile );
    }
  
  
  
    /*
    * Draw Tiles surface
    * @param x  x-coordinate of the surface's center
    * @param y  y-coordinate of the surface's center
    * @param tileSize tile side size
    */
    public void draw(int x, int y, int tileSize) {
        pushMatrix();
            translate(x, y);
            if(view3D) {
                rotateX(PI/3);
                rotateZ(rotation);
            }
            translate( -(tileSize * cols) / 2, -(tileSize * rows) / 2);
            for(Tile tile : tiles) tile.draw( tileSize );
        popMatrix();
    }

  
  
    /*
    * Update rotation angle for 3D view
    * @param angle  Rotation angle in the z-axis
    */
    public void rotate(float angle) {
        if(view3D) rotation -= angle;
    }
  
  
  
    /*
    * Load settings from files
    * @param colorSettings  File path containing colors definitions
    * @param tileSettings  File path containing tiles definitions
    */
    public void loadSettings(String colorSettings, String tileSettings) {
        // Check file existance -->
        if(colorSettings != null) colors = loadColorSettings(colorSettings);
        if(tileSettings != null) molds = loadTileSettings(tileSettings);
    }
  
  
  
    /*
    * Load colors settings
    * @param colorsPath File path containing all definitions
    * @return list of color object referenced by its id, or null if file doesn't exist
    */
    private HashMap loadColorSettings(String colorsPath) {
        HashMap<String, Color> colors = new HashMap();
        JSONArray colorsJSON = loadJSONArray(colorsPath);
        for(int i = 0; i < colorsJSON.size(); i++) {
            JSONObject colorJSON = colorsJSON.getJSONObject(i);
                int id = colorJSON.getInt("id");
                String name = colorJSON.getString("name");
                JSONObject value = colorJSON.getJSONObject("value");
                    String original = value.getString("original");
                    String adjusted = value.getString("adjusted");
                boolean binary = colorJSON.getBoolean("binary");
            colors.put(name, new Color(id, name, binary, original, adjusted));
        }
        return colors;
    }
  
  
  
    /*
    * Load Tiles' parameters from file and create mold tiles to be cloned in the future
    * @param    settingsPath    File path containing all Tiles parameters
    * @return   HashMap containing a sample of every different tile referenced by
    *           its name
    */
    private HashMap loadTileSettings(String settingsPath) {
        HashMap<String, Tile> molds = new HashMap();
        JSONArray tilesJSON = loadJSONArray(settingsPath);
        for(int i = 0; i < tilesJSON.size(); i++) {
            JSONObject tileJSON = tilesJSON.getJSONObject(i);
            PShape shape = null;
            JSONArray colorCode = tileJSON.getJSONArray("colors");
            JSONObject aspect = tileJSON.getJSONObject("aspect");
            String render = aspect.getString("render");
            if(render.equals("COLOR")) {
                shape = createShape(RECT, 0, 0, 1, 1);
                color fill = Color.decode( aspect.getString("color") );
                shape.setFill(fill);
            } else if(render.equals("TEXTURE")) {
                PImage texture = loadImage( aspect.getString("texture") );
                shape = createShape(RECT, 0, 0, 1, 1);
                shape.setTexture(texture);
            } else {
                shape = createShape(GROUP);
                int width = floor( sqrt( colorCode.size() ) );
                for(int j = 0; j < colorCode.size(); j++) {
                    color c = colors.get( colorCode.getString(j) ).getColor();
                    PShape jQ = createShape(RECT, j % width, j / width, 1, 1);
                    jQ.setFill(c);
                    shape.addChild(jQ);
                }
            }
            shape.setStroke(false);
            molds.put(tileJSON.getString("name"), new Tile(tileJSON.getString("name"), shape));
        }
        return molds;
    }
    
    
  
    /*
    * Mouse events handler. Rotate tableau when mouse dragged
    * @param    event    Event firing the function
    */
    public void mouseEvent(MouseEvent event) {
        switch(event.getAction()) {
            case MouseEvent.PRESS:
                break;
            case MouseEvent.DRAG:
                rotate( map(mouseX-pmouseX, 0, width, 0, PI) );
                break;
            case MouseEvent.RELEASE:
                break;
        }
        
    }
    
}


// TILE CLASS =========================================================================================================================
public class Tile {
  
    /* ATTRIBUTES ----------------------------------------------------------------------------------> */
    
    private String name;
    private int[] position;
    private int rotation;
    private PShape shape;
  
  
    /* CONSTRUCTORS --------------------------------------------------------------------------------> */
      
    /*
    * Construct a Tile with its basic parameters: codification and texture
    * @params name  Name of the type Tile
    * @params shape Visual shape and texture
    */
    Tile(String name, PShape shape) {
        this.name = name;
        this.shape = shape;
    }
  
  
    /* GETTERS & SETTERS ---------------------------------------------------------------------------> */
  
    public void setRotation(int r) { rotation = r; }
    public void setPosition(int x, int y) { position = new int[] {x, y}; }
  
  
    /* METHODS -------------------------------------------------------------------------------------> */
    
    /*
    * Return a clone of itself
    * @return new tile that's a copy of this
    */
    public Tile clone() {
        return new Tile(name, shape);
    }
  
  
    /*
    * Draw tile's visual shape
    * @param size  Side size of the tile to be drawn
    */
    public void draw(int size) {
        pushMatrix();
            translate( (position[0] + 0.5) * size, (position[1] + 0.5) * size);
            rotate( radians(rotation) );
            translate(-size/2, -size/2);
            shape(shape, 0, 0, size, size);    
        popMatrix();
    }
    
  
}