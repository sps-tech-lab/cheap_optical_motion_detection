/////////////////////////////////////////////////////////////////////////////////////////////
//  SPS Technology :: 2016  //////////////////////////////  ADNS-5030 Smart Motion Sensor  //
/////////////////////////////////////////////////////////////////////////////////////////////
 
import processing.serial.*;
 
Serial com;
 
final int frameX = 15;
final int frameY = 15;
final int frameSZ = 20;

boolean   recive = false;    // Статус приема
int       rx;                // Буфер принятого байта
int[]     frame;             // Массив кадра
int       framepos=0;        // Позиция в массиве кадра

float[]     DeltaX   = new float[100];       // Массив
float[]     DeltaY   = new float[100];       // Массив
float[]     SQUAL    = new float[100];       // Массив
float[]     SHUTTER  = new float[100];       // Массив
float[]     MaxPix   = new float[100];       // Массив
float[]     SumPix   = new float[100];       // Массив
float[]     MinPix   = new float[100];       // Массив

float[]     watch    = new float[10];

PFont f;                     // Шрифт
int   upshift;               // Межстрочный интервал для текста
int   hrshift = 10;          // Отступ от края для текста

//////////////////////////////////////  ИНИЦИАЛИЗАЦИЯ  ///////////////////////////////////////

void setup()
{
  size( 300, 500 );                          // Размер окна Windows для отрисовки
  frame = new int[frameX*frameY+11];         // Выделяем память 225 байт
  com = new Serial(this, "COM3", 9600);      // Подключаемся к СОМ-порту
  noStroke();                                // Не обводить квараты рамкой
  smooth();                                  // Не сглаживать грани
  f = createFont("Arial",16,true);
}

//////////////////////////////////////  ОСНОВНОЙ ЦИКЛ  //////////////////////////////////////

void draw()
{
//--------------------------------------------------------------------------------------------------------------------
  background(0);
  int readpos=0;
  for(int i=0;i<frameX;i++)
  {
    for(int j=frameY-1;j>=0;j--)
    {
       fill(map(frame[readpos], 0, 127, 0, 225));              // Преобразуем диапазон входных чисел
       rect(i * frameSZ, j * frameSZ, frameSZ, frameSZ);       // Рисуем квадратики
       readpos++;                                              // Переходим к следующей ячейке
    }
  }
//--------------------------------------------------------------------------------------------------------------------    
  stroke(255);                                                  // Устанавливаем цвет линий
  line(0,300,width,300);                                        // Отрисовываем горизонтальную линию разделения
  line(width-120,height,width-90,height-22);                    // Отрисовываем рамку логотипа
  line(width-90,height-22,width,height-22); 
  noStroke();                                                   // Убираем цвет линий

  textFont(f);                                                  // Устанавливаем шрифт
  fill(255);                                                    // Цвет текста     
  textFont(f,16);
  textAlign(LEFT);                                              // Выравнивание текста
  upshift = 300+25;                                             // Начальная позиция колонки текстоых параметров
  
  int shutL   = frame[frameX*frameY+5];                         // Загружаем старший байт
  int shutH   = frame[frameX*frameY+6];                         // Загружаем младший байт
  int shutter = shutL << 8 | shutH;                             // Формируем двухбайтное число
//--------------------------------------------------------------------------------------------------------------------    
  text("Move              ["+recive+"]",hrshift,upshift);
  upshift+=20;
  text("DeltaX            ["+frame[frameX*frameY+2]+"]",hrshift,upshift);
  upshift+=20;
  text("DeltaY            ["+frame[frameX*frameY+3]+"]",hrshift,upshift);
  upshift+=20;
  text("SQUAL           ["+frame[frameX*frameY+4]+"]",hrshift,upshift);
  upshift+=20;
  text("SHUTTER      ["+shutter+"]",hrshift,upshift);
  upshift+=20;
  text("MaxPix           ["+frame[frameX*frameY+7]+"]",hrshift,upshift);
  upshift+=20;
  text("SumPix          ["+frame[frameX*frameY+8]+"]",hrshift,upshift); //<>//
  upshift+=20;
  text("MinPix            ["+frame[frameX*frameY+9]+"]",hrshift,upshift);
  upshift+=20;
  text("MouseCtrl      ["+frame[frameX*frameY+10]+"]",hrshift,upshift);
  upshift+=20;
//--------------------------------------------------------------------------------------------------------------------  
// ГРАФИКИ

    for(int i=99;i>0;i--)
  {
    DeltaX[i]=DeltaX[i-1];
    DeltaY[i]=DeltaY[i-1];
    SQUAL[i]=SQUAL[i-1];
    SHUTTER[i]=SHUTTER[i-1];
    MaxPix[i]=MaxPix[i-1];
    SumPix[i]=SumPix[i-1];
    MinPix[i]=MinPix[i-1];
  }
  
    for(int i=2;i<10;i++)
  {
    if (watch[i]<frame[frameX*frameY+i] && watch[i]<255 && i!=5){watch[i]+=4;} else {watch[i]-=4;}
  }
 //<>//
DeltaX[0]=map(watch[2], 0, 255, 0, 15);
DeltaY[0]=map(watch[3], 0, 255, 0, 15);
SQUAL[0]=map(watch[4], 0, 150, 0, 15);
MaxPix[0]=map(watch[7], 0, 127, 0, 15);
SumPix[0]=map(watch[8], 0, 127, 0, 15);
MinPix[0]=map(watch[9], 0, 127, 0, 15);

  
  stroke(255);
    for(int i=1;i<100;i++)
  {
    upshift = 300+45;
    line(180+i,upshift,180+i,upshift-DeltaX[i]);
    upshift+=20;
    line(180+i,upshift,180+i,upshift-DeltaY[i]);
    upshift+=20;
    line(180+i,upshift,180+i,upshift-SQUAL[i]);
    upshift+=20;
    upshift+=20;
    line(180+i,upshift,180+i,upshift-MaxPix[i]);
    upshift+=20;
    line(180+i,upshift,180+i,upshift-SumPix[i]);
    upshift+=20;
    line(180+i,upshift,180+i,upshift-MinPix[i]);
  }
  noStroke();  
//--------------------------------------------------------------------------------------------------------------------  
  textAlign(RIGHT);                          // Отрисовываем логотип  
  textFont(f,12);
  text(":: SPS TECH ::",width-10,height-6);
//--------------------------------------------------------------------------------------------------------------------  
}
/////////////////////////////////////////////////////////////////////////////////////////////

void serialEvent(Serial p)
{
  rx = p.read();                             // Считываем принятый байт из порта
    
  if(recive)                                 // Прием пакета
  {
    if(framepos < frameX*frameY+11)          // Складываем принятые байты в буфер
    {
      frame[framepos]=rx;
      framepos++;
    }
    if(framepos == frameX*frameY+11)         // Закончили, отключили прием, збросили счетчик
    {
      recive = false;
      framepos=0;
    }
  }
  if( rx == 0xFF) recive = true;             // Если это маркер начала, запускаем прием пакета
}