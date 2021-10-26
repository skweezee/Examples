// Shield pins to enable & select multiplexers
// all shields are wired in parallel to digital pins 7–13
#define EN 13
#define S0_A 12
#define S1_A 11
#define S2_A 10
#define S0_B 9
#define S1_B 8
#define S2_B 7

const char mode = 'U'; // Mode: P = Plain: normalised magnitude -- default
                       //       C = Clipped: normalised magnitude (ignoring under/overshoot)
                       //       F = Filtered: normalised moving average
                       //       I = Integral: sum over time
                       
                       //       R = Square root: emphasizes nuances in light squeezes
                       //       S = Squared: emphasizes nuances in hard squeezes
                       //       T = Square root (Clipped): emphasizes nuances in light squeezes
                       //       U = Squared (Clipped): emphasizes nuances in hard squeezes
                       //       V = Square root (Filtered): emphasizes nuances in light squeezes
                       //       W = Squared (Filtered): emphasizes nuances in hard squeezes


const int periodIn = 30;  // input period (Arduino will measure & process pillows each x ms)
const int periodOut = 300;  // output period (Arduino will send out value each x ms)
const int periodReset = 12*60*1000;  // output period (Arduino will send out value each x ms)

const int buffer_size = 10;
int buffer_index = 0;

boolean started = false;

const int shields = 4;
const int dimension = 28;
const int outputRange = 255;

unsigned long now;  // current millis()
unsigned long prevIn;  // previous input
unsigned long prevOut;  // previous output
unsigned long prevReset;  // previous output

int _raw [shields][dimension];  // raw measurements (4x28): 0-255

float _mag [shields];  // vector magnitude per pillow: 0-1350
float _magMax [shields];  // max magnitude per pillow: 0-1350
float _magMin [shields];  // min magnitude per pillow: 0-1350
float _magBuffer [shields][buffer_size];  // store data points for averaging

float _avg [shields];  // moving average of magnitude per pillow (filters signal): 0-1350
float _avgMax [shields];  // max average magnitude per pillow (ignores under/overshoot): 0-1350
float _avgMin [shields];  // min average magnitude per pillow (ignores under/overshoot): 0-1350

float _integ [shields];  // simplified integral of magnitude per pillow (average)
float _integMax [shields];  // max integral per pillow
float _integMin [shields];  // min integral per pillow

float _normMag [shields]; // normalised magnitude per pillow (in ref to mag): (mag-minMag)/(maxMag-minMag): 0-1
float _normMxd [shields]; // normalised magnitude per pillow (in ref to avg): (mag-minAvg)/(maxAvg-minAvg): 0-1
float _normAvg [shields]; // normalised average per pillow (in ref to avg): (avg-minAvg)/(maxAvg-minAvg): 0-1

// float _normInteg [shields]; // normalised integral per pillow (in ref to integral): (integ - minInteg)/(maxInteg-minInteg): 0-1
//int n = 0;

void setup() {
  Serial.begin(115200); // baud rate 115200 bps
  pinMode(EN, OUTPUT);
  pinMode(S0_A, OUTPUT);
  pinMode(S1_A, OUTPUT);
  pinMode(S2_A, OUTPUT);
  pinMode(S0_B, OUTPUT);
  pinMode(S1_B, OUTPUT);
  pinMode(S2_B, OUTPUT);
  resetReferences();
}

void loop() {
  now  = millis();
  measure();  // measure values
  calc();  // process measured values
  if (now - prevOut >= periodOut) {
    // each periodOut
    out();
    prevOut = now;
  }  
  if (now - prevReset >= periodReset) {
    // each periodOut
    resetReferences();
    prevReset = now;
  }  
  while (millis() - now <= periodIn) {
    // wait periodIn
  }
  prevIn = now;
}


void resetReferences() {
  for (int i = 0; i < shields; i++) {
    _magMax[i] = 0.0;
    _magMin[i] = 2000.0; // sqrt(28*255^2) = 1349.3
    _avgMax[i] = 0.0;
    _avgMin[i] = 2000.0; // sqrt(28*255^2) = 1349.3
    _integMax[i] = 0.0;
    _integMin[i] = 200000.0; // 100*sqrt(28*255^2) = 134900.3
  }
}


void measure() {
  digitalWrite(EN, HIGH);  // enable multiplexers
  int l = 0;
  for (int i = 0; i < 8; i++) {
     for (int j = i+1; j < 8; j++) {
        // for all combinations of multiplexers
        digitalWrite(S2_A, bitRead(i,2) );
        digitalWrite(S1_A, bitRead(i,1) );
        digitalWrite(S0_A, bitRead(i,0) );
        digitalWrite(S2_B, bitRead(j,2) );
        digitalWrite(S1_B, bitRead(j,1) );
        digitalWrite(S0_B, bitRead(j,0) );
        delayMicroseconds(30); // time needed to go from L to H
        for (int k = 0; k < shields; k++) {
          _raw[k][l] = 255-(analogRead(k)>>2);
        }
        l++;
     } 
  }
  digitalWrite(EN, LOW);  // disable multiplexers
}   


void calc() {
  float m[] = {0.0, 0.0, 0.0, 0.0};
  for (int i = 0; i < shields; i++) {
    for (int j = 0; j < dimension; j++) {
      m[i] += _raw[i][j]*_raw[i][j];
    }
  }
  for (int i = 0; i < shields; i++) {
    
    // magnitude
    _mag[i] = sqrt(m[i]);
    
    // average
    _magBuffer[i][buffer_index] = _mag[i];
    float sum = 0;
    for (int j = 0; j < buffer_size; j++) {
      sum += _magBuffer[i][j];
    }
    _avg[i] = sum/buffer_size;
    
    // integral (sum)
    _integ[i] += _mag[i];
    
    // references
    if (_mag[i] > _magMax[i]) _magMax[i] = _mag[i];
    if (_mag[i] < _magMin[i]) _magMin[i] = _mag[i];
    if (_avg[i] > _avgMax[i]) _avgMax[i] = _avg[i];
    if (_avg[i] < _avgMin[i]) _avgMin[i] = _avg[i];
    
    // normalisation
    _normMag[i] = (_mag[i]-_magMin[i])/(_magMax[i]-_magMin[i]);
    _normMxd[i] = (_mag[i]-_avgMin[i])/(_avgMax[i]-_avgMin[i]);
    if (_normMxd[i] < 0) _normMxd[i] = 0;
    if (_normMxd[i] > 1) _normMxd[i] = 1;
    _normAvg[i] = (_avg[i]-_avgMin[i])/(_avgMax[i]-_avgMin[i]); 
     
  }
  buffer_index = (buffer_index + 1) % buffer_size;
}


void out() {

  switch (mode) {

    case 'P':
      for (int i = 0; i < shields; i++) {
        Serial.print(plain(i));
        Serial.print('/');
      }
      Serial.println();
    break;
    
    case 'C':
      for (int i = 0; i < shields; i++) {
        Serial.print(clipped(i));
        Serial.print('/');
      }
      Serial.println();
    break;
    
    case 'F':
      for (int i = 0; i < shields; i++) {
        Serial.print(filtered(i));
        Serial.print('/');
      }
      Serial.println();
    break;

    case 'I':
      for (int i = 0; i < shields; i++) {
        Serial.print(integral(i));
        Serial.print('/');
      }
      Serial.println();
    break;

    case 'R':
      for (int i = 0; i < shields; i++) {
        Serial.print(root(i));
        Serial.print('/');
      }
      Serial.println();
    break;
    
    case 'S':
      for (int i = 0; i < shields; i++) {
        Serial.print(square(i));
        Serial.print('/');
      }
      Serial.println();
    break;

    case 'T':
      for (int i = 0; i < shields; i++) {
        Serial.print(rootMxd(i));
        Serial.print('/');
      }
      Serial.println();
    break;

    case 'U':
      for (int i = 0; i < shields; i++) {
        Serial.print(squareMxd(i));
        Serial.print('/');
      }
      Serial.println();
    break;

    case 'V':
      for (int i = 0; i < shields; i++) {
        Serial.print(rootAvg(i));
        Serial.print('/');
      }
      Serial.println();
    break;

    case 'W':
      for (int i = 0; i < shields; i++) {
        Serial.print(squareAvg(i));
        Serial.print('/');
      }
      Serial.println();
    break;
    
    default:
      for (int i = 0; i < shields; i++) {
        Serial.print(plain(i));
        Serial.print('/');
      }
      Serial.println();
    break;
  }
   
}


int plain(int i) {
  return outputRange*_normMag[i];
}


int clipped(int i) {
  return outputRange*_normMxd[i];
}


int filtered(int i) {
  return outputRange*_normAvg[i];
}


int integral(int i) {
  if (_integ[i] > _integMax[i]) _integMax[i] = _integ[i];
  if (_integ[i] < _integMin[i]) _integMin[i] = _integ[i];
  int t = outputRange*(_integ[i]-_integMin[i])/(_integMax[i]-_integMin[i]);
  for (int i = 0; i < shields; i++) {
    _integ[i] = 0.0;
  }
  return t;
}


int root(int i) {
  return outputRange*sqrt(_normMag[i]);
}

int square(int i) {
  return outputRange*_normMag[i]*_normMag[i];
}

int rootMxd(int i) {
  return outputRange*sqrt(_normMxd[i]);
}

int squareMxd(int i) {
  return outputRange*_normMag[i]*_normMxd[i]*_normMag[i]*_normMxd[i];
}

int rootAvg(int i) {
  return outputRange*sqrt(_normAvg[i]);
}

int squareAvg(int i) {
  return outputRange*_normMag[i]*_normAvg[i];
}
