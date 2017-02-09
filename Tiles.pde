Tableau tableau;

void setup() {
    
    size(960, 540, P3D);
    pixelDensity(2);
    
    tableau = new Tableau(this, "colors.json", "tiles.json");
    tableau.update( loadJSONObject("msg.json") );
  
}


void draw() {
    
    background(#555555);
    
    tableau.set3D(false);
    tableau.draw(50, 50, 10);
    tableau.set3D(true);
    tableau.draw(width/2, height/2, 100);
    
}