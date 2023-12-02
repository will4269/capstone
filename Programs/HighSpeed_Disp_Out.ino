#include <math.h>

/*************************************************** 
  This is a library for our I2C LED Backpacks

  Designed specifically to work with the Adafruit LED 7-Segment backpacks 
  ----> http://www.adafruit.com/products/881
  ----> http://www.adafruit.com/products/880
  ----> http://www.adafruit.com/products/879
  ----> http://www.adafruit.com/products/878

  These displays use I2C to communicate, 2 pins are required to 
  interface. There are multiple selectable I2C addresses. For backpacks
  with 2 Address Select pins: 0x70, 0x71, 0x72 or 0x73. For backpacks
  with 3 Address Select pins: 0x70 thru 0x77

  Adafruit invests time and resources providing this open source code, 
  please support Adafruit and open-source hardware by purchasing 
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.  
  BSD license, all text above must be included in any redistribution
 ****************************************************/

#include <Wire.h> // Enable this line if using Arduino Uno, Mega, etc.
#include <Adafruit_GFX.h>
#include "Adafruit_LEDBackpack.h"

Adafruit_7segment matrix = Adafruit_7segment();

bool in1,in2,fired;
int del;
float temp, temp2, T0, T1, T2;
String time,speed; 
String mode="";
String printer = "";


int time1=2;
int time2=3;

float dist;

void setup() {
#ifndef __AVR_ATtiny85__
  Serial.begin(9600);
  Serial.println("7 Segment Backpack Test");
#endif
  matrix.begin(0x70);

  del = 0;
  speed = "7.234";
  time = "10.45";
  //18inches and 5/16, between T1 and T2, 
  dist=0.4651375; //space betwen boards timing
  fired=false; //indicates if triggered
  //pinMode(LED_BUILTIN, OUTPUT);
  attachInterrupt(digitalPinToInterrupt(time1), tim_1, RISING);
  attachInterrupt(digitalPinToInterrupt(time2), tim_2, RISING);
}
//pin 4 is in1 clear
//pin 5 is in2 fire

//pin2 t1
//pin3 t2


void loop() {
  //fetch current inputs
  in1=digitalRead(4);
  in2=digitalRead(5);
  //state declaration
  //00idle
  //01fire
  //10clear
  //stall
  if(in1==false && in2==false){ //00
    mode="_00_";
  }else if (in1==false && in2==true) {//01
    mode="_01_";
  }else if (in1==true && in2==false) {//10
    mode="_10_";
  } else {
    mode="_11_";
  }


  if (del < 1000){
    matrix.println("SPED"); //speed print
  }
  else if (del < 2000){
    matrix.println(speed); 
  }
  else if (del < 3000){
   matrix.println("TIME"); //time print
  }
  else if (del < 4000){
    matrix.println(time);
  }
  else if (del < 5000){  //setting print
    matrix.println(mode);
  }

  //output strings
  matrix.writeDisplay();
  delay(2);
  del += 2;
  if (del > 5000) {
    del = 0;
  }
  


  //firing control
  if(mode=="_01_"&&fired==false){ //if in firing mode, and hasn't fired, trigger first mosfet
    digitalWrite(7,HIGH);//send power to trigger first thyristor
    //delay(40);
    delayMicroseconds(40); //pulse period
    fired=true;
    T0=millis();//capture fire time
    
    digitalWrite(7,LOW); //drop trigger
  }


  //clearing control
  if(mode=="_10_"){//only in clear mode
    fired=false; //reset fired case allowing to be fired again
  }

}
 
void tim_1() {
  T1=micros();
}

void tim_2() {
  T2=micros();
  temp=(T2-T1)*0.000001;
  time=String(temp);
  temp2=(dist/((T2-T1)*0.000001));
  speed=String(temp2);
}



  

  // print with print/println
  


