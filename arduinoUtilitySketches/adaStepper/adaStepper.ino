/* 
Stepper drive of syringe pump for water rewards.
This uses the adafruit Motor Shield for Arduino v2
---->	http://www.adafruit.com/products/1438
*/


#include <Wire.h>
#include <Adafruit_MotorShield.h>
#include "utility/Adafruit_PWMServoDriver.h"
# define bitPin 2

int stepsPerReward=34;
int toggleDelay=1000;
int reading;           // the current reading from the input pin
int previous = 0;    // the previous reading from the input pin

Adafruit_MotorShield AFMS = Adafruit_MotorShield(); 

// Connect a stepper motor with 200 steps per revolution (1.8 degree)
// to motor port #2 (M3 and M4)
Adafruit_StepperMotor *myMotor = AFMS.getStepper(200, 2);


void setup() {  
  pinMode(bitPin,INPUT);
  digitalWrite(bitPin, LOW); 
  AFMS.begin();  // freq is argument  
  myMotor->setSpeed(40);  // 10 rpm    
}

void loop() {
  reading = digitalRead(bitPin);
  if (reading==1 && previous==0){
    for (int n=0; n<stepsPerReward; n++){
      myMotor->onestep(FORWARD, MICROSTEP); 
    }
    delay(toggleDelay);
  }
  previous=reading;
}
