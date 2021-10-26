#include<FastLED.h>
#define NUM_LEDS 100

// first define the functions of the digital I/O pins
// the following pins control the multiplexers (enable and select)
#define EN 13
#define S0_A 12
#define S1_A 11
#define S2_A 10
#define S0_B 9
#define S1_B 8
#define S2_B 7

int raw[28]; // vector
float _max = 0; 
float _mag = 0;
int dir[28];
float _mags[5];

int c = 0;
int target = 500;
int speed = 2;

// FASTLED
CRGBArray<NUM_LEDS> leds;

void setup() {
  
  FastLED.addLeds<WS2811,6, RGB>(leds, NUM_LEDS);

  Serial.begin(9600); // baud rate 9600 bps
  pinMode(EN, OUTPUT);
  pinMode(S0_A, OUTPUT);
  pinMode(S1_A, OUTPUT);
  pinMode(S2_A, OUTPUT);
  pinMode(S0_B, OUTPUT);
  pinMode(S1_B, OUTPUT);
  pinMode(S2_B, OUTPUT);

}

void loop(){

  // SKWEEZEE

  
  digitalWrite(EN, HIGH);
   // Loop through all the relevant combinations of the multiplexers
  int n = 0;
  for (int i=0; i<7; i++) { 
     for (int j=i+1; j<8; j++) {
        digitalWrite(S2_A, bitRead(i,2) );
        digitalWrite(S1_A, bitRead(i,1) );
        digitalWrite(S0_A, bitRead(i,0) );
        digitalWrite(S2_B, bitRead(j,2) );
        digitalWrite(S1_B, bitRead(j,1) );
        digitalWrite(S0_B, bitRead(j,0) );
        delayMicroseconds(30); // time needed to go from L to H
        raw[n] = analogRead(0)>>2;
        raw[n] = 255-raw[n];
        n++;
     } 
  }

  // Performs basic vector and time series analysis.
  analysis();
static uint8_t hue;
static uint8_t sat;
  leds.fadeToBlackBy(25);


  int led = 99*mag();


  c++;
  //speed++;
  if(c > target) {
    c = 0;
    target = 50 + round(500*random());
    //speed = round(10*random());
  }
  int x = 100*c/500;
  x += 2*random()-1;
  x = x%99;
  int v = 255-x*x/3;
  if(v < 0) v = 0;
  leds[99-x] = CHSV(50,255,v);
  
  if(stdev() < 5) {
    sat--;
    if (sat < 0) sat = 0;
  }
  else {

    sat += 1;
    sat *= 2;
    if(sat > 255) sat = 255;
    
  }

  leds[led] = CHSV(160,sat,255);
  /*for(int i = 0; i < diff()/3; i++) {
    leds[led+i] = CHSV(160,sat,120);  
    leds[led-i] = CHSV(160,sat,120);  
  }*/
    
  
  
  
  FastLED.show(); 

  

  Serial.println(mag());
  Serial.println(avg()/_max);
  Serial.println(stdev());
  Serial.println();


  // FASTLED
  /*static uint8_t hue;
  for(int i = 0; i < NUM_LEDS; i++) {   
    // fade everything out
    leds.fadeToBlackBy(40);

    // let's set an led value
    leds[i] = CHSV(hue++,255,255);

    // now, let's first 20 leds to the top 20 leds, 
    //leds(NUM_LEDS/2,NUM_LEDS-1) = leds(NUM_LEDS/2 - 1 ,0);
    FastLED.delay(33);
  }*/
}

/* Basic vector and time series analysis, 
 */
void analysis() {
  
  // calculate vector magnitude
  float m = 0;
  for(int j = 0; j < 28; j++) {
    m += raw[j]*raw[j];  
  }
  _mag = sqrt(m);
  
  // compare & store max
  if(_mag > _max) {
    _max = _mag;  
  }
  
  // store 5 most recent magnitudes
  // in a sliding window (used for moving average)
  _mags[4] = _mags[3];
  _mags[3] = _mags[2];
  _mags[2] = _mags[1];
  _mags[1] = _mags[0];
  _mags[0] = _mag;
  
  // calculate vector direction (unit vector)
  float dir[28];
  for (int j = 0; j < 28; j++) {
    dir[j] = raw[j]/_mag;  
  }
  
}


/* Returns magnitude, relative to maximum
 * (similar to 'norm' in Processing library)
 */
float mag() {
  return _mag/_max;
}


/* Returns moving average, relative to maximum.
 * This moving average is based on the sliding window
 * of the last 5 magnitudes.
 * 
 * (this is actually the 'norm' method in Processing library)
 * 
 * avg() delivers a smoothed, auto-calibrated value
 */
float avg() {
  float sum = 0;
  for (int i = 0; i<5; i++) {
    sum += _mags[i];
  }
  return (sum/5);  
}


/* Returns moving standard deviation, which is based
 * on the sliding window of the last 5 magnitudes.
 * 
 * stdev() delivers a measure of stability.
 */
float stdev() {
  float a = avg();
  float var = 0;
  for(int i = 0; i < 5; i++) {
    float d = (float) _mags[i] - a;
    var += d*d;
  }
  return sqrt(var/5);
}


/* Returns an approximation of the first derivative.
 *  
 *  diff() delivers a measure of change (speed);
 *  a positive number indicates 'squeezing',
 *  a negative number indicates 'releasing'.
 */
int diff() {
  float sum = -1*_mags[0];
  sum += 8*_mags[1];
  sum += -8*_mags[3];
  sum += 1*_mags[4];
  return sum/12;
}


/* Inverse of avg()
 */
int inv() {
  return 255-avg();  
}


/* Returns the squared moving average.
 *  
 * square() can be used to emphasize or nuance hard squeezes.
 */
int square() {
  int a = avg();
  return a*a/255;
}


/* Returns the square root moving average.
 *  
 * root() can be used to emphasize or nuance light squeezes.
 */
int root() {
  float a = avg();
  return 255*sqrt(a/255);
}

