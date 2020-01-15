import processing.serial.*;

Serial port;
Boolean reading = false;
Boolean mute = true;
Boolean invert = false;
Boolean stable = false;

ArrayList<Integer> values = new ArrayList<Integer>();
ArrayList<Integer> buffer = new ArrayList<Integer>();
ArrayList<Float> amplitude = new ArrayList<Float>();
ArrayList<Float> filtered = new ArrayList<Float>();
ArrayList<Float> amplitude0 = new ArrayList<Float>();
ArrayList<Float> amplitude1 = new ArrayList<Float>();
ArrayList<Float> amplitude2 = new ArrayList<Float>();
ArrayList<Float> amplitude3 = new ArrayList<Float>();
ArrayList<Float> amplitude4 = new ArrayList<Float>();
ArrayList<Float> amplitude5 = new ArrayList<Float>();
ArrayList<Float> amplitude6 = new ArrayList<Float>();
ArrayList<Float> amplitude7 = new ArrayList<Float>();
float[] points = new float[8];
ArrayList<float[]> pmem = new ArrayList<float[]>();

void setup() {

  size(1300, 785);
  colorMode(HSB, 360, 100, 100);
  background(0, 0, 98);
  noStroke();

  printArray(Serial.list());
  port = new Serial(this, Serial.list()[6], 9600);
  port.clear();

  frameRate(12);
}

void draw() {

  background(0, 0, 98);
  noStroke();
  fill(0, 0, 95);
  rect(10, 10, 200, 380);
  rect(215, 10, 675, 380);
  rect(895, 10, 395, 380);
  rect(10, 395, 200, 380);
  rect(215, 395, 675, 380);
  rect(895, 395, 395, 380);

  getSqueeze();
  int m = getAmplitude();
  getAmplitudes();
  

  // draw bar graph current features
  textSize(8);
  noStroke();
  textAlign(LEFT);
  for (int i = 0; i < values.size(); i++) {
    fill(210, 40, 15);
    rect(20, 19+13*i, 180-180*values.get(i)/255, 10);
    fill(210, 0, 100);
    text(i, 25, 27+13*i);
  }
  
  // draw bar graph points
  textSize(12);
  noStroke();
  textAlign(LEFT);
  for (int i = 0; i < points.length; i++) {
    fill(210, 40, 15);
    if(points[i] > 0) rect(20, 399+47*i, (180-180*points[i]/255), 30);
    fill(210, 0, 100);
    text(i, 25, 420+47*i);
  }


  // draw line graph
  noFill();
  strokeWeight(1);
  stroke(210, 60, 15);

  beginShape();
  int speed = 2;
  int s = amplitude.size();
  int p = 0;
  int i = 0;
  float a = amplitude.get(s-1);
  float y = 0;
  if (s > (655/speed)) p = s - (655/speed);
  for (i = p; i < s; i++) {
    y = amplitude.get(i);
    y = 380*(y/255);
    vertex(225+(i-p)*speed, 10+y);
  }
  endShape();
  
  // draw filtered line graph
  /*noFill();
  strokeWeight(1);
  stroke(210, 60, 15);

  beginShape();
  int speeda = 2;
  int sa = filtered.size();
  int pa = 0;
  int ia = 0;
  float ya = 0;
  if (sa > (655/speeda)) pa = sa - (655/speeda);
  for (ia = pa; ia < sa; ia++) {
    ya = filtered.get(ia);
    ya = 380*(ya/255);
    vertex(225+(ia-pa)*speeda, 10+ya);
  }
  endShape();  
  */
  
  // draw line graph
  noFill();
  strokeWeight(1);
  stroke(210, 10, 95);
  
  beginShape();
  int z = amplitude0.size();
  p = 0;
  i = 0;
  y = 0;
  if (z > (655/speed)) p = z - (655/speed);
  for (i = p; i < z; i++) {
    y = amplitude0.get(i);
    y = 380*(y/255);
    vertex(225+(i-p)*speed, 400+y);
  }
  endShape();
  
  beginShape();
  z = amplitude1.size();
  p = 0;
  i = 0;
  y = 0;
  if (z > (655/speed)) p = z - (655/speed);
  for (i = p; i < z; i++) {
    y = amplitude1.get(i);
    y = 380*(y/255);
    vertex(225+(i-p)*speed, 400+y);
  }
  endShape();
    
  beginShape();
  z = amplitude2.size();
  p = 0;
  i = 0;
  y = 0;
  if (z > (655/speed)) p = z - (655/speed);
  for (i = p; i < z; i++) {
    y = amplitude2.get(i);
    y = 380*(y/255);
    vertex(225+(i-p)*speed, 400+y);
  }
  endShape();
  
  beginShape();
  z = amplitude4.size();
  p = 0;
  i = 0;
  y = 0;
  if (z > (655/speed)) p = z - (655/speed);
  for (i = p; i < z; i++) {
    y = amplitude4.get(i);
    y = 380*(y/255);
    vertex(225+(i-p)*speed, 400+y);
  }
  endShape();

  beginShape();
  z = amplitude5.size();
  p = 0;
  i = 0;
  y = 0;
  if (z > (655/speed)) p = z - (655/speed);
  for (i = p; i < z; i++) {
    y = amplitude5.get(i);
    y = 380*(y/255);
    vertex(225+(i-p)*speed, 400+y);
  }
  endShape();
  
  beginShape();
  z = amplitude7.size();
  p = 0;
  i = 0;
  y = 0;
  if (z > (655/speed)) p = z - (655/speed);
  for (i = p; i < z; i++) {
    y = amplitude7.get(i);
    y = 380*(y/255);
    vertex(225+(i-p)*speed, 400+y);
  }
  endShape();  
  
  stroke(90, 100, 70);  
  beginShape();
  z = amplitude6.size();
  p = 0;
  i = 0;
  y = 0;
  float c = 0;
  if(z > 1) c = amplitude6.get(z-1);
  if (z > (655/speed)) p = z - (655/speed);
  for (i = p; i < z; i++) {
    y = amplitude6.get(i);
    y = 380*(y/255);
    vertex(225+(i-p)*speed, 400+y);
  }
  endShape();
 
  
  
  stroke(20, 100, 80);  
  beginShape();
  z = amplitude3.size();
  p = 0;
  i = 0;
  y = 0;
  float b = 0;
  if(z > 1) b = amplitude3.get(z-1);
  if (z > (655/speed)) p = z - (655/speed);
  for (i = p; i < z; i++) {
    y = amplitude3.get(i);
    y = 380*(y/255);
    vertex(225+(i-p)*speed, 400+y);
  }
  endShape();

  // draw stable
  fill(255);
  textSize(12);
  textAlign(LEFT);
  text("std: "+nf(getStdDev(), 1, 2), 800, 50);
  if(stable) text("stable", 800, 30);
  else  text("not stable",800, 30);
  if(stable) fill(90, 100, 90);
  else fill(10, 100, 80);
  noStroke();
  ellipse(870, 25, 12, 12);


  // output
  // Canvas: rect(895, 10, 395, 380);
  int r = 50;

  if ( a > 0) {

    if (!invert) {
      fill((10+40*int(a)/255), 100, 100);
      r = (40+240*int(a)/255);
    } else {
      fill((10+40*int(a)/255), 100, 100);
      r = (280-240*int(a)/255);
    }

    noStroke();
    ellipse(1092, 200, r, r);
  }
  
  
  
  int rx = 50;
  int ry = 50;
  
    if (!invert) {
      fill((180+30*int(a)/255), 90, 100);
      rx = (40+240*int(b*b/a)/255);
      ry = (40+240*int(c*c/a)/255);
    } else {
      fill((180+30*int(a)/255), 90, 100);
      rx = (40+240*int((b*b))/255);
      ry = (40+240*int(c*c)/255);
    }

    noStroke();
    ellipse(1092, 600, rx, ry);

  //sine.freq(330-220*a/255);
  //sine.amp(0.25+3*(1-a/255)/4);

  // Text
  fill(255);
  textSize(12);
  textAlign(LEFT);
  text("Amplitude: "+(255-int(amplitude.get(s-1))), 225, 30);
  textAlign(RIGHT);
  text("Features: "+m, 200, 30);
}

void getSqueeze() {

  int n = port.available();

  if (n > 0) {

    byte[] u = new byte[n];
    port.readBytes(u);

    for (int i = 0; i < u.length; i++) {

      int t = (int) u[i] & 0xff;

      if (!reading) {
        if (t == 0) {
          reading = true;
          buffer = new ArrayList<Integer>();
        }
      } else {
        if (t == 0) {
          values = buffer;
          buffer = new ArrayList<Integer>();
        } else {
          buffer.add(t);
        }
      }
    }
  }
}

int getAmplitude() {

  float t = 0;

  int m = values.size();

  for (int i = 0; i < values.size(); i++) {

    int u = values.get(i);

    if (u != 255) {
      t += values.get(i);
    } else m--;
  }

  amplitude.add(t/m);
  //filtered.add(movingAverage());
  //println(memory.size());

  return m;
}

void getAmplitudes() {
  
    if(values.size() >=  28) {
      
      float t = 0;
  
    /*
    
    0 1 : 0      0 1 : 0       0 2 : 1       0 3 : 2       0 4 : 3       0 5 : 4       0 6 : 5       0 7 : 6
    0 2 : 1      1 2 : 7       1 2 : 7       1 3 : 8       1 4 : 9       1 5 : 10      1 6 : 11      1 7 : 12
    0 3 : 2      1 3 : 8       2 3 : 13      2 3 : 13      2 4 : 14      2 5 : 15      2 6 : 16      2 7 : 17
    0 4 : 3      1 4 : 9       2 4 : 14      3 4 : 18      3 4 : 18      3 5 : 19      3 6 : 20      3 7 : 21  
    0 5 : 4      1 5 : 10      2 5 : 15      3 5 : 19      4 5 : 22      4 5 : 22      4 6 : 23      4 7 : 24
    0 6 : 5      1 6 : 11      2 6 : 16      3 6 : 20      4 6 : 23      5 6 : 25      5 6 : 25      5 7 : 26
    0 7 : 6      1 7 : 12      2 7 : 17      3 7 : 21      4 7 : 24      5 7 : 26      6 7 : 27      6 7 : 27
    
    {{0, 1, 2, 3, 4, 5, 6}, {0, 7, 8, 9, 10, 11, 12}, {1, 7, 13, 14, 15, 16, 17}, {2, 8, 13, 18, 19, 20, 21},
     {3, 9, 14, 18, 22, 23, 24}, {4, 10, 15, 19, 22, 25, 26}, {5, 11, 16, 20, 23, 25, 27}, {6, 12, 17, 21, 24, 26, 27}}
    
    */
    
    
    
    int[][] k = {{0, 1, 2, 3, 4, 5, 6}, {0, 7, 8, 9, 10, 11, 12}, {1, 7, 13, 14, 15, 16, 17}, {2, 8, 13, 18, 19, 20, 21},
                 {3, 9, 14, 18, 22, 23, 24}, {4, 10, 15, 19, 22, 25, 26}, {5, 11, 16, 20, 23, 25, 27}, {6, 12, 17, 21, 24, 26, 27}};
    
    
    int m = 8;
    for(int i = 0; i < 7; i++) {
    
      if(values.get(k[0][i]) != 255) t+= values.get(k[0][i]);
      else m--;
      
    }
    amplitude0.add(t/m);
    
    m = 8;
    t = 0;
    for(int i = 0; i < 7; i++) {
    
      if(values.get(k[1][i]) != 255) t+= values.get(k[1][i]);
      else m--;
      
    }
    amplitude1.add(t/m);
    
    m = 8;
    t = 0;
    for(int i = 0; i < 7; i++) {
    
      if(values.get(k[2][i]) != 255) t+= values.get(k[2][i]);
      else m--;
      
    }
    amplitude2.add(t/m);
    
    m = 8;
    t = 0;
    for(int i = 0; i < 7; i++) {
    
      if(values.get(k[3][i]) != 255) t+= values.get(k[3][i]);
      else m--;
      
    }
    amplitude3.add(t/m);
    
    m = 8;
    t = 0;
    for(int i = 0; i < 7; i++) {
    
      if(values.get(k[4][i]) != 255) t+= values.get(k[4][i]);
      else m--;
      
    }
    amplitude4.add(t/m);
    
    m = 8;
    t = 0;
    for(int i = 0; i < 7; i++) {
    
      if(values.get(k[5][i]) != 255) t+= values.get(k[5][i]);
      else m--;
      
    }
    amplitude5.add(t/m);
    
    m = 8;
    t = 0;
    for(int i = 0; i < 7; i++) {
    
      if(values.get(k[6][i]) != 255) t+= values.get(k[6][i]);
      else m--;
      
    }
    amplitude6.add(t/m);
    
    m = 8;
    t = 0;
    for(int i = 0; i < 7; i++) {
    
      if(values.get(k[7][i]) != 255) t+= values.get(k[7][i]);
      else m--;
      
    }
    amplitude7.add(t/m);
    
    
    
    for(int j = 0; j < 8; j++) {
      t = 0;
    m = 8;
    for(int i = 0; i < 7; i++) {
    
      if(values.get(k[j][i]) != 255) t+= values.get(k[j][i]);
      else m--;
      
    }
    
    
    points[j] = t/m;
    
  }
  //pmem.add(points);

   }
  
}

void keyPressed() {

  invert = !invert;

  saveFrame("one-####.png");
}

float movingAverage() {

  int n = amplitude.size();
  float t = 0.0;

  if (n  > 5) {

    for (int i = 0; i < 5; i++) {
      t += amplitude.get(n-1-i);
    }
    
  }
  
  return t/5;
  
}

float getStdDev() {
  
  int n = amplitude.size();
  int m = 5;
  
  float mean = 0.0;
  float dev = 0.0;

  if (n  > m) {
    
    float sum = 0.0;
    float var = 0.0;
    
    for(int i = n-m; i < n; i++) sum += amplitude.get(i);
    mean = sum/m;
    for(int i = 0; i < m; i++) var += sq(amplitude.get(n-1-i)-mean);
    
    dev = sqrt(var/m);
    if(dev < 2) stable = true; //println("stable ("+dev+")");
    else stable = false; //println("not stable ("+dev+")");
    
  }
  
  return dev;
  
}
