/////////////////////////////////////////////////////////////////////////////////////////////
//  SPS Technology :: 2016  //////////////////////////////////////  OV7670 Camera Grabber  //
/////////////////////////////////////////////////////////////////////////////////////////////
import processing.serial.*;
Serial port;

final int frameX = 160;    // Разрешение по горизонтали 94
final int frameY = 120;      // Разрешение по вертикали
final int frameSZ = 2;       // Масштаб пикселя

final int bufsize = frameX*frameY;

boolean   recive = false;    // Статус приема
int       rx;                // Буфер принятого байта
int[]     frame;             // Массив кадра
int[]     postframe;         // Массив кадра на вывод
int[]     cpiframe;          // Массив кадра для обработки движений
int[]     probeframe;        // Массив результатов сравнения
int       probe;             // Степень "Движения"
int       framepos=0;        // Позиция в массиве кадра

PFont     font;              // Шрифт

int       secstore;          // Временная переменная для отлова смены секунд
int       timer;
float     fps,postfps;       // Подсчет FPS
int       grafbuf;

int       ww=150/2;          // Центр квадрата
int       hw=100/2;          // Центр квадрата
int       gist=5;            // Порог срабатывания

//////////////////////////////////////  ИНИЦИАЛИЗАЦИЯ  ///////////////////////////////////////
void setup()
{
  size( 320, 262 );                          // Размер окна Windows для отрисовки
  frame = new int[bufsize];                  // Выделяем память
  postframe = new int[bufsize];              // Выделяем память
  cpiframe = new int[bufsize];               // Выделяем память
  probeframe = new int[bufsize];             // Выделяем память
  
  port = new Serial(this, "COM3", 346000);   // Подключаемся к СОМ-порту

  font = loadFont("Vrinda-Bold-16.vlw");
  textFont(font,16);
  
  noStroke();                                // Не обводить квараты рамкой
  smooth();                                  // Не сглаживать грани
}
//////////////////////////////////////  ОСНОВНОЙ ЦИКЛ  //////////////////////////////////////
void draw()
{
//--------------------------------------------------------------------------------------------------------------------
  background(0);
  
  int readpos=0;                                               // Начинаем сначала
    for(int j=0;j<frameY;j++)                                  // Координаты по Y
  {
    for(int i=0;i<frameX;i++)                                  // Координаты по Х
    {
       fill(postframe[readpos]);                               // Преобразуем диапазон входных чисел
       rect(i * frameSZ, j * frameSZ, frameSZ, frameSZ);       // Рисуем квадраты
       readpos++;                                              // Переходим к следующей ячейке
    }
  }
//--------------------------------------------------------------------------------------------------------------------  
  stroke(255);                                                  // Отрисовываем горизонтальную линию разделения
  line(0,height-22,width,height-22);                                        
  noStroke();
//--------------------------------------------------------------------------------------------------------------------  
  fill(255);             
  textFont(font,16);                                            // Отрисовываем логотип
  textAlign(RIGHT); //<>// //<>// //<>//
  text(":: SPS TECH :: 2016 ::",width-5,height-6);             
//-------------------------------------------------------------------------------------------------------------------- 
  textAlign(LEFT);                                              // Отображаем FPS   
  text(postfps+" fps",5,height-6);
  
  if(second()!=secstore)TimerUpdate();
  secstore=second();
//--------------------------------------------------------------------------------------------------------------------  
  textFont(font,8);                                             // Графики
  text("BUF",60,height-12);                           
  rect(85,height-16,map(framepos,0,bufsize,0,60),4);            // График заполнения буфера
  fill(100); 
  text("FPS",60,height-4);                            
  rect(85,height-8,timer*6,4);                                  // График таймера FPS
  //-------------------------------------------------------------------------------------------------------------------- 
 
  if(probe>gist){stroke(0,255,0);}else{stroke(255,0,0);};       // Отрисовываем горизонтальную линию разделения
  if(probe>gist){fill(0,255,0,20);}else{fill(255,0,0,20);};
  
  int hu=(height-22)/2;                                         // Рисуем квадрат в центире 
  quad(width/2-ww, hu-hw,width/2+ww, hu-hw,width/2+ww, hu+hw,width/2-ww, hu+hw);                                      
  noStroke();
  
  if(probe>gist){fill(0,255,0);}else{fill(255,0,0);};           
  
  textFont(font,20);                                            // Выводим текст
  textAlign(CENTER); //<>// //<>//
  text("MOVE = "+probe,width/2,height/2+hw/2+40);    

  //--------------------------------------------------------------------------------------------------------------------  
}
//////////////////////////////////////// ПРИЕМ ДАННЫХ ///////////////////////////////////////
void serialEvent(Serial p)
{
  rx = p.read();                             // Считываем принятый байт из порта
    
  if(recive)                                 // Прием пакета
  {
    if(framepos < bufsize)                   // Складываем принятые байты в буфер
    {
      frame[framepos]=rx;
      framepos++;
    }
    if(framepos == bufsize)                  // Закончили, отключили прием, збросили счетчик
    {
      recive = false; //<>//
    }
  }
  if( rx == 0xFF){
    recive = true;                           // Если это маркер начала, запускаем прием пакета
    framepos=0;
    arrayCopy(postframe,cpiframe);
    arrayCopy(frame, postframe);
    fps++;
    MoveProbe();
  }
}
//////////////////////////////////////// ИССЛЕДУЕМ "ДВИЖЕНЕ" //////////////////////////////////////
void MoveProbe()
{
  for(int i=0; i<bufsize; i++)                 // Проверяем степень "отличия" пикселей
  {
    if(postframe[i]>cpiframe[i])               // Исключаем отрицательные значения
    {
      probeframe[i]=postframe[i]-cpiframe[i];  
    }else{
      probeframe[i]=cpiframe[i]-postframe[i];
    }
  }
  
  for(int by=0; by<frameY; by++)              
  {
    for(int bx=0; bx<frameX; bx++)                  
    {
      if(bx>(frameX-ww)/2 && bx<(frameX-ww)/2+ww && by>(frameY-hw)/2 && by<(frameY-hw)/2+hw) probe+=probeframe[by*frameX+bx];
    }
  }
  probe=probe/bufsize;                         // Получаем среднее арифметическое
}
/////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// ВЫЧЕСЛЯЕМ FPS //////////////////////////////////////
void TimerUpdate()
{
  timer++;
  if (timer>10){
     postfps = fps/10;
     timer=0;
     fps=0;
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////