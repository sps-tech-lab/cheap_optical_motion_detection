int data;

void setup() {
  Serial.begin(9600);
}

void loop() {
  //////////////////////////////////////  
  Serial.write(255);
 //////////////////////////////////////  
  data = analogRead(A0)>>2;
  cut();
  Serial.write(data);
  data = analogRead(A1)>>2;
  cut();
  Serial.write(data);
  data = analogRead(A2)>>2;
  cut();
  Serial.write(data);
  data = analogRead(A3)>>2;
  cut();
  Serial.write(data);
 //////////////////////////////////////   
  delay(100);
 //////////////////////////////////////  
}

void rnd(){
  data= random(1, 254);
}

void cut(){
  if (data == 255){ data = 254; }
}

