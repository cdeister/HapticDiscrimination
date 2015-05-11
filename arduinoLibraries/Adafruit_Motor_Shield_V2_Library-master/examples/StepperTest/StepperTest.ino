/* 
This is a test sketch for the Adafruit assembled Motor Shield for Arduino v2
It won't work with v1.x motor shields! Only for the v2's with built in PWM
control

For use with the Adafruit Motor Shield v2 
---->	http://www.adafruit.com/products/1438
*/


#include <Wire.h>
#include <Adafruit_MotorShield.h>
#include "utility/Adafruit_PWMServoDriver.h"

# define bitPin 2
int pinFlip;

// Create the motor shield object with the default I2C address
Adafruit_MotorShield AFMS = Adafruit_MotorShield(); 
// Or, create it with a different I2C address (say for stacking)
// Adafruit_MotorShield AFMS = Adafruit_MotorShield(0x61); 

// Connect a stepper motor with 200 steps per revolution (1.8 degree)
// to motor port #2 (M3 and M4)
Adafruit_StepperMotor *myMotor = AFMS.getStepper(200, 2);


void setup() {
//  Serial.begin(9600);           // set up Serial library at 9600 bps
//  Serial.println("Stepper test!");
  
  pinMode(bitPin,INPUT);
  digitalWrite(bitPin, LOW); 

  AFMS.begin();  // create with the default frequency 1.6KHz
  //AFMS.begin(1000);  // OR with a different frequency, say 1KHz
  
  myMotor->setSpeed(40);  // 10 rpm   
}

void loop() {
pinFlip=digitalRead(bitPin);
  if (pinFlip==1){
    for (int n=0; n<8; n++){
      myMotor->onestep(FORWARD, MICROSTEP); 
    }
  delay(2000);
  for (int n=0; n<4; n++){
    myMotor->onestep(BACKWARD, MICROSTEP); 
  }
  }
}
