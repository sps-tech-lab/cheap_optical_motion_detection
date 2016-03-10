int data;

void setup() {
  Serial.begin(9600);
}

void loop() {
  Serial.write(255);
  
  rnd();
  Serial.write(data);
  rnd();
  Serial.write(data);
  rnd();
  Serial.write(data);
  rnd();
  Serial.write(data);
  delay(100);
  
}

void rnd(){
  data= random(1, 254);
}
