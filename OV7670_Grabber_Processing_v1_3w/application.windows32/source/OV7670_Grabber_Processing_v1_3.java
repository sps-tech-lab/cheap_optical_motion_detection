import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class OV7670_Grabber_Processing_v1_3 extends PApplet {

/////////////////////////////////////////////////////////////////////////////////////////////
//  SPS Technology :: 2016  //////////////////////////////////////  OV7670 Camera Grabber  //
/////////////////////////////////////////////////////////////////////////////////////////////

Serial port;

final int frameX = 320;    // \u0420\u0430\u0437\u0440\u0435\u0448\u0435\u043d\u0438\u0435 \u043f\u043e \u0433\u043e\u0440\u0438\u0437\u043e\u043d\u0442\u0430\u043b\u0438 94
final int frameY = 240;      // \u0420\u0430\u0437\u0440\u0435\u0448\u0435\u043d\u0438\u0435 \u043f\u043e \u0432\u0435\u0440\u0442\u0438\u043a\u0430\u043b\u0438
final int frameSZ = 2;       // \u041c\u0430\u0441\u0448\u0442\u0430\u0431 \u043f\u0438\u043a\u0441\u0435\u043b\u044f

final int bufsize = frameX*frameY+11;

boolean   recive = false;    // \u0421\u0442\u0430\u0442\u0443\u0441 \u043f\u0440\u0438\u0435\u043c\u0430
int       rx;                // \u0411\u0443\u0444\u0435\u0440 \u043f\u0440\u0438\u043d\u044f\u0442\u043e\u0433\u043e \u0431\u0430\u0439\u0442\u0430
int[]     frame;             // \u041c\u0430\u0441\u0441\u0438\u0432 \u043a\u0430\u0434\u0440\u0430
int[]     postframe;         // \u041c\u0430\u0441\u0441\u0438\u0432 \u043a\u0430\u0434\u0440\u0430 \u043d\u0430 \u0432\u044b\u0432\u043e\u0434
int       framepos=0;        // \u041f\u043e\u0437\u0438\u0446\u0438\u044f \u0432 \u043c\u0430\u0441\u0441\u0438\u0432\u0435 \u043a\u0430\u0434\u0440\u0430

PFont     font;              // \u0428\u0440\u0438\u0444\u0442

int       secstore;          // \u0412\u0440\u0435\u043c\u0435\u043d\u043d\u0430\u044f \u043f\u0435\u0440\u0435\u043c\u0435\u043d\u043d\u0430\u044f \u0434\u043b\u044f \u043e\u0442\u043b\u043e\u0432\u0430 \u0441\u043c\u0435\u043d\u044b \u0441\u0435\u043a\u0443\u043d\u0434
int       timer;
float     fps,postfps;
int       grafbuf;

//////////////////////////////////////  \u0418\u041d\u0418\u0426\u0418\u0410\u041b\u0418\u0417\u0410\u0426\u0418\u042f  ///////////////////////////////////////
public void setup()
{
                            // \u0420\u0430\u0437\u043c\u0435\u0440 \u043e\u043a\u043d\u0430 Windows \u0434\u043b\u044f \u043e\u0442\u0440\u0438\u0441\u043e\u0432\u043a\u0438
  frame = new int[bufsize];                  // \u0412\u044b\u0434\u0435\u043b\u044f\u0435\u043c \u043f\u0430\u043c\u044f\u0442\u044c
  postframe = new int[bufsize];              // \u0412\u044b\u0434\u0435\u043b\u044f\u0435\u043c \u043f\u0430\u043c\u044f\u0442\u044c
  
  port = new Serial(this, "COM3", 460800);   // \u041f\u043e\u0434\u043a\u043b\u044e\u0447\u0430\u0435\u043c\u0441\u044f \u043a \u0421\u041e\u041c-\u043f\u043e\u0440\u0442\u0443

  font = loadFont("Vrinda-Bold-16.vlw");
  textFont(font,16);
  
  noStroke();                                // \u041d\u0435 \u043e\u0431\u0432\u043e\u0434\u0438\u0442\u044c \u043a\u0432\u0430\u0440\u0430\u0442\u044b \u0440\u0430\u043c\u043a\u043e\u0439
                                    // \u041d\u0435 \u0441\u0433\u043b\u0430\u0436\u0438\u0432\u0430\u0442\u044c \u0433\u0440\u0430\u043d\u0438
}
//////////////////////////////////////  \u041e\u0421\u041d\u041e\u0412\u041d\u041e\u0419 \u0426\u0418\u041a\u041b  //////////////////////////////////////
public void draw()
{
//--------------------------------------------------------------------------------------------------------------------
  background(0);
  
  int readpos=0;                                               // \u041d\u0430\u0447\u0438\u043d\u0430\u0435\u043c \u0441\u043d\u0430\u0447\u0430\u043b\u0430
    for(int j=0;j<frameY;j++)                               // \u041a\u043e\u043e\u0440\u0434\u0438\u043d\u0430\u0442\u044b \u043f\u043e Y
  {
    for(int i=0;i<frameX;i++)                                    // \u041a\u043e\u043e\u0440\u0434\u0438\u043d\u0430\u0442\u044b \u043f\u043e \u0425
    {
       fill(postframe[readpos]);                               // \u041f\u0440\u0435\u043e\u0431\u0440\u0430\u0437\u0443\u0435\u043c \u0434\u0438\u0430\u043f\u0430\u0437\u043e\u043d \u0432\u0445\u043e\u0434\u043d\u044b\u0445 \u0447\u0438\u0441\u0435\u043b
    //   fill(map(frame[readpos], 0, 15, 0, 250));             // \u041f\u0440\u0435\u043e\u0431\u0440\u0430\u0437\u0443\u0435\u043c \u0434\u0438\u0430\u043f\u0430\u0437\u043e\u043d \u0432\u0445\u043e\u0434\u043d\u044b\u0445 \u0447\u0438\u0441\u0435\u043b
       rect(i * frameSZ, j * frameSZ, frameSZ, frameSZ);   // \u0420\u0438\u0441\u0443\u0435\u043c \u043a\u0432\u0430\u0434\u0440\u0430\u0442\u044b
       readpos++;                                              // \u041f\u0435\u0440\u0435\u0445\u043e\u0434\u0438\u043c \u043a \u0441\u043b\u0435\u0434\u0443\u044e\u0449\u0435\u0439 \u044f\u0447\u0435\u0439\u043a\u0435
    }
  }
//--------------------------------------------------------------------------------------------------------------------  
  stroke(255);                                                  // \u041e\u0442\u0440\u0438\u0441\u043e\u0432\u044b\u0432\u0430\u0435\u043c \u0433\u043e\u0440\u0438\u0437\u043e\u043d\u0442\u0430\u043b\u044c\u043d\u0443\u044e \u043b\u0438\u043d\u0438\u044e \u0440\u0430\u0437\u0434\u0435\u043b\u0435\u043d\u0438\u044f
  line(0,height-22,width,height-22);                                        
  noStroke();
//--------------------------------------------------------------------------------------------------------------------  
  fill(255);             
  textFont(font,16);                                            // \u041e\u0442\u0440\u0438\u0441\u043e\u0432\u044b\u0432\u0430\u0435\u043c \u043b\u043e\u0433\u043e\u0442\u0438\u043f
  textAlign(RIGHT); //<>// //<>//
  text(":: SPS TECH :: 2016 ::",width-5,height-6);             
//-------------------------------------------------------------------------------------------------------------------- 
  textAlign(LEFT);                                              // \u041e\u0442\u043e\u0431\u0440\u0430\u0436\u0430\u0435\u043c FPS   
  text(postfps+" fps",5,height-6);
  
  if(second()!=secstore)TimerUpdate();
  secstore=second();
//--------------------------------------------------------------------------------------------------------------------  
  textFont(font,8);                                             // \u0413\u0440\u0430\u0444\u0438\u043a\u0438
  text("BUF",60,height-12);                           
  rect(85,height-16,map(framepos,0,bufsize,0,60),4);            // \u0413\u0440\u0430\u0444\u0438\u043a \u0437\u0430\u043f\u043e\u043b\u043d\u0435\u043d\u0438\u044f \u0431\u0443\u0444\u0435\u0440\u0430
  fill(100); 
  text("FPS",60,height-4);                            
  rect(85,height-8,timer*6,4);                                  // \u0413\u0440\u0430\u0444\u0438\u043a \u0442\u0430\u0439\u043c\u0435\u0440\u0430 FPS
  //-------------------------------------------------------------------------------------------------------------------- 
}
//////////////////////////////////////// \u041f\u0420\u0418\u0415\u041c \u0414\u0410\u041d\u041d\u042b\u0425 ///////////////////////////////////////
public void serialEvent(Serial p)
{
  rx = p.read();                             // \u0421\u0447\u0438\u0442\u044b\u0432\u0430\u0435\u043c \u043f\u0440\u0438\u043d\u044f\u0442\u044b\u0439 \u0431\u0430\u0439\u0442 \u0438\u0437 \u043f\u043e\u0440\u0442\u0430
    
  if(recive)                                 // \u041f\u0440\u0438\u0435\u043c \u043f\u0430\u043a\u0435\u0442\u0430
  {
    if(framepos < bufsize)                   // \u0421\u043a\u043b\u0430\u0434\u044b\u0432\u0430\u0435\u043c \u043f\u0440\u0438\u043d\u044f\u0442\u044b\u0435 \u0431\u0430\u0439\u0442\u044b \u0432 \u0431\u0443\u0444\u0435\u0440
    {
      frame[framepos]=rx;
      framepos++;
    }
    if(framepos == bufsize)                  // \u0417\u0430\u043a\u043e\u043d\u0447\u0438\u043b\u0438, \u043e\u0442\u043a\u043b\u044e\u0447\u0438\u043b\u0438 \u043f\u0440\u0438\u0435\u043c, \u0437\u0431\u0440\u043e\u0441\u0438\u043b\u0438 \u0441\u0447\u0435\u0442\u0447\u0438\u043a
    {
      recive = false;
    }
  }
  if( rx == 0xFF){
    recive = true;                           // \u0415\u0441\u043b\u0438 \u044d\u0442\u043e \u043c\u0430\u0440\u043a\u0435\u0440 \u043d\u0430\u0447\u0430\u043b\u0430, \u0437\u0430\u043f\u0443\u0441\u043a\u0430\u0435\u043c \u043f\u0440\u0438\u0435\u043c \u043f\u0430\u043a\u0435\u0442\u0430
    framepos=0;
    arrayCopy(frame, postframe);
    fps++;
  }
}

//////////////////////////////////////// \u0412\u042b\u0427\u0415\u0421\u041b\u042f\u0415\u041c FPS //////////////////////////////////////
public void TimerUpdate()
{
  timer++;
  if (timer>10){
     postfps = fps/10;
     timer=0;
     fps=0;
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////
  public void settings() {  size( 640, 502 );  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "OV7670_Grabber_Processing_v1_3" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
