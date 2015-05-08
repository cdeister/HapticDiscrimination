// Stepper control for syringe pump.
// Turns a specific amount if pin 2 is high.
// All the heavy-lifting via: Frankie Chu
// http://41j.com/blog/2014/05/seeedstudio-motorshield-v2-with-stp-42d206-stepper/
//
// 


#define MOTOR_CLOCKWISE      0
#define MOTOR_ANTICLOCKWISE  1
/******Pins definitions*************/
#define MOTORSHIELD_IN1 8//8
#define MOTORSHIELD_IN2 11//11
#define MOTORSHIELD_IN3 12//12
#define MOTORSHIELD_IN4 13//13
#define CTRLPIN_A   9//9
#define CTRLPIN_B   10//10
# define bitPin 2
 
const unsigned char stepper_ctrl[]={0x27,0x36,0x1e,0x0f};
int pinFlip;

 
 
struct MotorStruct
{
  int8_t speed;
  uint8_t direction;
};
MotorStruct stepperMotor;
unsigned int number_of_steps = 200;
/**********************************************************************/
/*Function: Get the stepper motor rotate                               */
/*Parameter:-int steps,the total steps and the direction the motor rotates.*/
/*      if steps > 0,rotates anticlockwise,                 */
/*      if steps < 0,rotates clockwise.                     */
/*Return: void                                          */
void step(int steps)
{
  int steps_left = abs(steps)*4;
  int step_number;
  int millis_delay = 60L * 1000L /number_of_steps/(stepperMotor.speed + 50);
  delay(millis_delay);
 
 
  if (steps > 0) 
  {
    stepperMotor.direction= MOTOR_ANTICLOCKWISE;
    step_number = 0; 
  }
    else if (steps < 0) 
  {
    stepperMotor.direction= MOTOR_CLOCKWISE;
    step_number = number_of_steps;
  }
  else return;
 
 
  while(steps_left > 0) 
  {
   
               if(step_number%4 == 0) {
                 digitalWrite(MOTORSHIELD_IN1,1);
                 digitalWrite(MOTORSHIELD_IN2,0);
                 digitalWrite(MOTORSHIELD_IN3,0);
                 digitalWrite(MOTORSHIELD_IN4,0);
                 digitalWrite(CTRLPIN_A,1);
                 digitalWrite(CTRLPIN_B,0);                                
               }
               if(step_number%4 == 1) {
                 digitalWrite(MOTORSHIELD_IN1,0);
                 digitalWrite(MOTORSHIELD_IN2,0);
                 digitalWrite(MOTORSHIELD_IN3,1);
                 digitalWrite(MOTORSHIELD_IN4,0);
                 digitalWrite(CTRLPIN_A,0);
                 digitalWrite(CTRLPIN_B,1);                                
               }
               if(step_number%4 == 2) {
                 digitalWrite(MOTORSHIELD_IN1,0);
                 digitalWrite(MOTORSHIELD_IN2,1);
                 digitalWrite(MOTORSHIELD_IN3,0);
                 digitalWrite(MOTORSHIELD_IN4,0);
                 digitalWrite(CTRLPIN_A,1);
                 digitalWrite(CTRLPIN_B,0);                                
               }
               if(step_number%4 == 3) {
                 digitalWrite(MOTORSHIELD_IN1,0);
                 digitalWrite(MOTORSHIELD_IN2,0);
                 digitalWrite(MOTORSHIELD_IN3,0);
                 digitalWrite(MOTORSHIELD_IN4,1);
                 digitalWrite(CTRLPIN_A,0);
                 digitalWrite(CTRLPIN_B,1);                                
               }               
   
    //PORTB = stepper_ctrl[step_number%4];
    delay(millis_delay);
    if(stepperMotor.direction== MOTOR_ANTICLOCKWISE)
    {
      step_number++;
        if (step_number == number_of_steps)
          step_number = 0;
    }
    else
    {
      step_number--;
        if (step_number == 0)
          step_number = number_of_steps;
    }
    steps_left --;
     
  }
}
void initialize()
{
  pinMode(MOTORSHIELD_IN1,OUTPUT);
  pinMode(MOTORSHIELD_IN2,OUTPUT);
  pinMode(MOTORSHIELD_IN3,OUTPUT);
  pinMode(MOTORSHIELD_IN4,OUTPUT);
  pinMode(CTRLPIN_A,OUTPUT);
  pinMode(CTRLPIN_B,OUTPUT);
  pinMode(bitPin,INPUT);
  digitalWrite(bitPin, LOW); 
  stop();
  stepperMotor.speed = 40;
  stepperMotor.direction = MOTOR_CLOCKWISE;
}
/*******************************************/
void stop()
{
  /*Unenble the pin, to stop the motor. */
    digitalWrite(CTRLPIN_A,LOW);
    digitalWrite(CTRLPIN_B,LOW);
}
 
void setup()
{
  initialize();//Initialization for the stepper motor.
}
 
void loop()
{
  pinFlip=digitalRead(bitPin);
  if (pinFlip==1){
    step(30);//Stepper motors rotate anticlockwise 200 steps.
    delay(1000);
    step(-5);//Stepper motors rotate clockwise 200 steps.
  }
}
