import net.skweezee.processing.*;
import processing.serial.*;

int scene;
int x1, x2, x3, x4, x5, x6;
float x;
float y;
float top;
float r;
float f;
float h;
float camY;
ArrayList<float[]> bath;
int ref;
PFont myFont;
color bgd = color(235, 235, 235);
color fxd = color(210, 210, 210);
color blue = color(10, 146, 191);
color darkBlue = color(15, 51, 65);
color red = color(230, 35, 0);
color darkRed = color(100, 15, 0);

void setup() {
  
  myFont = createFont("GillSans-SemiBold", 32);
  textFont(myFont);
  textAlign(CENTER, CENTER);
  
  size(1000, 500);
  background(bgd);
  Skweezee.connect(this);
  noStroke();
  
  h = 150;
  x1 = width;
  x2 = x1 + 200;
  x3 = x2 + 2*width/5;
  x4 = x3 + 4*width/5;
  x5 = x4 + 1*width/5;
  x6 = x5 + width;
  r = 10*width;
  x = 100;
  y = h-r/2;
  camY = 0;
  f = 0;
  top = 0;
  scene = 1;
  ref = 0;
  bath = new ArrayList<float[]>();
  float z = 50;
  while(z < width) {
    float s = 20+80*((float) Math.random());
    float w = 20*((float) Math.random())-10;
    z += 5 + (s/2-10)*((float) Math.random());
    if(z-s/2-10 < 0) z = s/2+10;
    bath.add(new float[] {z, w, s});
  }
}

void draw() {
  
  background(bgd);
  
  if (scene == 1) {  // START
    
    r = 10*width;
    y = h-r/2;
    //if (r < 100 && millis()-ref > 5000) scene++;
    
  } else if (scene == 2) {  // ROLL
    
    if(r > 100) r = r - (r - 15 + 85*(Skweezee.root()))*0.15;
    else r = 15 + 85*Skweezee.root();
    
    //r = r - (r - (15 + 85*(1-Skweezee.root())))*0.1;
    top = h; // (2*h*(Skweezee.norm())-top)/5;
    y = h;
    if (x <= x1) {
      x += 1 + 5*Skweezee.root();
    } else {
      scene++;
    }
    
  } else if (scene == 3) {  // LIFT
  
    // r = 15 + 50*(1-Skweezee.square());
    r = r - (r - 50)*0.1;
    if(x < x2) {
      top += (2*h*(Skweezee.norm())-top)/5;
      if(Math.abs(top - h) < 10) x += 1;// + 5*Skweezee.root();
      if(x > x1+6) y = top;
     } else {
       scene++;
     }
  
  } else if (scene == 4) {  // DUCK
  
    r = r - (r - (15 + 85*(1-Skweezee.root())))*0.2;
    if(x > x3 && x < x4 && r > 50) r = 50;
    if(x > x3 && x < x4 && r == 50) x = x;
    else x += 1 + 7*Skweezee.square();
    y = h;
    top *= 0.97;
    f = 10*Skweezee.root();
    if(x > x5) scene++;
    
  } else if (scene == 5) {  // BATH
  
    x += 1 + 4*Skweezee.root();
    y -= 1;
    f = 10*Skweezee.root();
    top *= 0.97;
    if(x >= x5+2*width/5) {
      camY = 0.5;
      scene++;
    }
    
  } else if (scene == 6) {  // END
  
    y -= 1;
    camY *= 1 + 0.03*Skweezee.root();
    f = 10*Skweezee.root();
    if(camY >= height) scene++;
  
  } else {  // BACK TO START
  
    h = 150;
    r = 10*width;
    x = 100;
    y = h;
    f = 0;
    camY = 0;
    top = 0;
    scene = 1;
    ref = millis();
    
  }
  
  // DRAW ELEMENTS
  pushMatrix();
  
    // MOVE CAMERA
    if(x > 2*width/5 ) {
      if(x < x6-width/2)
        translate(-(x - 2*width/5), 0);
      else
        translate(-(x6-width/2-2*width/5), 0);
    }
    
    translate(0, -camY);
    
    // END BALLS 
    if(scene > 2) {
      
      fill(red);
      ellipse(x5+50+f/2, height-h, 100+f, 100+f);
      for(int i = 0; i < bath.size(); i++) {
        float[] n = bath.get(i);
        ellipse(x5+n[0], height-h+n[1], n[2]+f, n[2]+f);
      }
      rect(x5, height-h, width, 10*height);
    }
    
    // FLOORS & BALL
    fill(fxd);
    rect(0, height-h, x1, h);
    rect(x2, height-h, x5-x2, h);
    rect(x3, 0, x4-x3, height-h-50);
    fill(darkBlue);
    rect(x1, height-top, x2-x1, height);
    fill(red);
    ellipse(x, height-y-r/2, r, r);
    
    
 
    // TEXT
    fill(bgd);
    
    // INTRO
    textAlign(CENTER, BOTTOM);
    textSize(72);
    text("Skweezee for Processing", width/2, height/3);
    textAlign(CENTER, TOP);
    textSize(28);
    if(millis()-ref < 10000) text("press any key to start", width/2, height/3+10);
    else if (millis()%3000 < 1500)  text("press any key to start", width/2, height/3+10);
    textAlign(RIGHT, BOTTOM);
    textSize(21);
    text("skweezee.net", width-10, height-10);
    
    // END
    textAlign(CENTER, BOTTOM);
    textSize(72);
    text("Skweezee for Processing", x5+width/2, height+height/3);
    textAlign(CENTER, TOP);
    textSize(28);
    text("press any key to start", x5+width/2,  height+height/3);
    textAlign(RIGHT, BOTTOM);
    textSize(21);
    text("skweezee.net", x5+width-10, height+height-10);
 
  popMatrix();
  
}

void keyPressed() {
  if(scene == 1 || scene >= 5) scene++;
}
