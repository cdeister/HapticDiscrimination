// Check servo positions

#include <Servo.h>

int testPosition=20;  
Servo myservo;  // create servo object to control a servo 
                // twelve servo objects can be created on most boards
 
 
void setup() 
{ 
   myservo.attach(9);  // attaches the servo on pin 9 to the servo object
   myservo.write(testPosition); 
} 
 
void loop() 
{ 
  myservo.write(testPosition);
} 

