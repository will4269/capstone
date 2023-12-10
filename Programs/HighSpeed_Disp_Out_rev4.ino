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

bool clear,fire,fired; //input for clear, fire, and fire_lock
int del; //delay bits
int count_T=0; //exponent for time
int count_S=0; //exponent for speed
float temp, temp2, T0, T1, T2; //temp for time, temp for speed, Time_0, Time_1, Time_2
float time,speed; //display values
String mode="";
String printer = "";


int time1=2; //pin for T1
int time2=3; //pin for T2

float dist; //distance between T1 and T2

void setup() {  //given from adafruit database
#ifndef __AVR_ATtiny85__
  Serial.begin(9600);
  Serial.println("7 Segment Backpack Test");
#endif
  matrix.begin(0x70);

  

  //capstone code again
  pinMode(7, OUTPUT);
  fired=false;//initialize to false
  del = 0; //delay to zero
  speed = 7.234; //delfault print
  time = 10.45; //default print
  //18inches and 5/16, between T1 and T2, 
  dist=0.46355; //space betwen boards timing 18.25in
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
  clear=digitalRead(4);
  fire=digitalRead(5);
  //state declaration
  //00idle
  //01fire
  //10clear
  //stall
  if(clear==false && fire==false){ //00
    mode="_00_"; //idle state
  }else if (clear==false && fire==true) {//01
    mode="_01_"; //fire mode
  }else if (clear==true && fire==false) {//10
    mode="_10_"; //clear mode
  } else {
    mode="_11_"; //idle state
  }


  if (del < 500){
    matrix.println("SPED"); //speed print
  }
  else if (del < 1000){
    matrix.println(speed); 
  }
  else if (del < 1500){
   matrix.println(count_S); //count of exponent for speed=speed*{10^count_S} [M/S]
  }
  else if (del < 2000){
   matrix.println("TIME"); //time print
  }
  else if (del < 2500){
    matrix.println(time);
  }
  else if (del < 3000){  //setting print
    matrix.println(count_T); //count of exponent for time time=time*{10^-6}*{10^count_T} [S]
  }

  //output strings
  matrix.writeDisplay();
  delay(2);
  del += 2;
  if (del > 3000) {
    del = 0;
  }
  


  //firing control
  if(mode=="_01_" && fired==false){ //if in firing mode, and hasn't fired, trigger first mosfet

    digitalWrite(7,HIGH);//send power to trigger first thyristor
    //digitalWrite(8,HIGH);//test comparison no pull down
    //delay(800); //testing [400ms is visible but something pulls it down]

    //determined thyristor is cause due to oversized load resistor preventing latch

    delay(1); //pulse period [40,80,800us maybe to short if direct or pulling down]

    fired=true; //prevent this from looping

    T0=millis();//capture fire time
    
    digitalWrite(7,LOW); //drop trigger
    //digitalWrite(8,LOW);//test comparison no pull down
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
  temp=(T2-T1); //temp is in microseconds
  count_T=0;
  count_S=0;
  while(temp>99){
    temp=temp/10;
    count_T+=1; //count increments per division to acknowledge division
  }
  time=temp; //store divided number in time in proper order


  temp2=(dist/((T2-T1)*0.000001)); //speed in m/s
  while(temp2>99){
    temp2=temp2/10;
    count_S+=1; //count increments per division to acknowledge division
  }
  speed=temp2;
}



  

  // print with print/println
  


