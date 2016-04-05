/////////////////////////////////////////////////////////////////////////////////////////////
//  SPS Technology :: 2016  //////////////////////////////  ADNS-5030 Smart Motion Sensor  //
/////////////////////////////////////////////////////////////////////////////////////////////
 
import processing.serial.*;
 
Serial com;
 
final int frameX = 15;
final int frameY = 15;
final int frameSZ = 40;

boolean   recive = false;    // Статус приема
int       rx;                // Буфер принятого байта
int[]     frame;             // Массив кадра
int       framepos=0;        // Позиция в массиве кадра

//////////////////////////////////////  ИНИЦИАЛИЗАЦИЯ  ///////////////////////////////////////

void setup()
{
  size( 600, 600 );                          // Размер окна Windows для отрисовки
  frame = new int[frameX*frameY];            // Выделяем память 225 байт
  com = new Serial(this, "COM3", 9600);    // Подключаемся к СОМ-порту
  noStroke();                                // Не обводить квараты рамкой
  noSmooth();                                // Не сглаживать грани
}

//////////////////////////////////////  ОСНОВНОЙ ЦИКЛ  //////////////////////////////////////

void draw()
{
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
} //<>//
 
/////////////////////////////////////////////////////////////////////////////////////////////

void serialEvent(Serial p)
{
  rx = p.read();                             // Считываем принятый байт из порта
    
  if(recive)                                 // Прием пакета
  {
    if(framepos < frameX*frameY)             // Складываем принятые байты в буфер
    {
      frame[framepos]=rx;
      framepos++;
    }
    if(framepos == frameX*frameY)            // Закончили, отключили прием, збросили счетчик
    {
      recive = false;
      framepos=0;
    }
  }
  if( rx == 0xFF) recive = true;             // Если это маркер начала, запускаем прием пакета
}