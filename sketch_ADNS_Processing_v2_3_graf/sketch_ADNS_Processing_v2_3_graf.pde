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
  smooth();                                // Не сглаживать грани
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
  line(0,300,width,300);                                        // Отрисовываем горизонтальную линию разделения //<>//
  line(width-130,height,width-80,height-80);                    // Отрисовываем рамку логотипа
  line(width-80,height-80,width,height-80); 
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
  text("SumPix          ["+frame[frameX*frameY+8]+"]",hrshift,upshift);
  upshift+=20;
  text("MinPix            ["+frame[frameX*frameY+9]+"]",hrshift,upshift);
  upshift+=20;
  text("MouseCtrl      ["+frame[frameX*frameY+10]+"]",hrshift,upshift);
  upshift+=20;
//--------------------------------------------------------------------------------------------------------------------    
  textAlign(RIGHT);                          // Отрисовываем логотип  
  textFont(f,12); 
  text("SPS",width-10,height-30);
  textFont(f,8);
  text(":: TECH ::",width-10,height-10);
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