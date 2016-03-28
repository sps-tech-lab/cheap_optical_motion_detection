/////////////////////////////////////////////////////////////////////////////////////////////
//  SPS Technology :: 2016  /////////////////////////////  Smart Motion Sensor TestPattern //
/////////////////////////////////////////////////////////////////////////////////////////////
#define frameX 176      // Разрешение по горизонтали
#define frameY 144      // Разрешение по вертикали
#define pxls frameX*frameY
int j;
int x,y;
int fon = 100;
int pix;

const unsigned char trio [] = {   // Массив с картинкой (не реализовано)
//
};


//////////////////////////////////////  ИНИЦИАЛИЗАЦИЯ  ///////////////////////////////////////
void setup() {
  Serial.begin(56000);
}
//////////////////////////////////////  ОСНОВНОЙ ЦИКЛ  //////////////////////////////////////
void loop()
{
  Serial.write(255);                      // Отправляем тестовый градиент
  TestPattern();                          // Рисуем "настроечнцю таблицу"
  // Serial.write(random(0, 250));        // Белый шум 
  // Serial.write(100);                   // Чистый экран одним цветом
  // Serial.write(trio[i]);               // Массив с картинкой (не реализовано)
delay(100);
}
/////////////////////////////////////////////////////////////////////////////////////////////
void TestPattern(void)
{
    for (int i = 0;i <pxls; i++)
  {
   pix=fon;
   pix = rect(i, 14, 14, 160, 130, 150, pix);
   pix = rect(i, 50, 50, 123, 90, fon, pix);
   
   pix = rect(i, 24, 24, 40, 40, 50, pix);
   pix = rect(i, 135, 24, 150, 40, 190, pix);
   pix = rect(i, 24, 104, 40, 120, 0, pix);
   pix = rect(i, 135, 104, 150, 120, 250, pix);
   Serial.write(pix);
  }
}
int rect(int i, int x1, int y1, int x2, int y2, int grey, int pix)
{
    x=i/frameY;
    y=i-frameY*x;
  if (x>x1 && x<x2 && y>y1 &&y<y2) {return grey;}else{return pix;}
}
/*
  for (int i = 0;i <pxls; i++)
  {
    ter[i] = random(0, 225);
  }
  Serial.write(ter, pxls);
*/  
/*  
  Serial.write(255);                     // Отправляем тестовый градиент
  for (int i = 0;i <225; i++)
  {
    ter[i] = i;
  }
  Serial.write(ter, 225);
  */



