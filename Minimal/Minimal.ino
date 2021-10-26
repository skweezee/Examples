float mag = 0;
float maxmag = 0;

void setup() {
  pinMode(A0, INPUT_PULLUP);
  pinMode(3, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
}

void loop() {
  int x = analogRead(0);
  mag = x;
  if(maxmag < mag) maxmag = mag;
  float norm = 1.0 - (mag / maxmag);
  float square = norm*norm;
  analogWrite(3, 255.0*square);
  analogWrite(5, 255.0*(1-norm));
  delay(20);
}
