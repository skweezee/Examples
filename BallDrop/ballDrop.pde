
float y, v, a;
int size = 50;

void setup() {

  size(300, 800);
  background(0);
  
  y = -100;
  v = 0;
  a = 1.2;
  
  frameRate(20);

}

void draw() {
  
  background(0);
  
  dropBall();

  fill(255);
  ellipse(width/2, y, size, size);
  
}

void dropBall() {
  
  v += a;
  y += v;
  
}
