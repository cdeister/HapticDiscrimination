
#include <hidboot.h>
#include <usbhub.h>
#include <SPI.h>
#include <SM.h>
#include <Servo.h> 

class MouseRptParser : public MouseReportParser
{

public:
        long curPos;
        // unsigned long timeStamp;
        
protected:
	void OnMouseMove	(MOUSEINFO *mi);
};

void MouseRptParser::OnMouseMove(MOUSEINFO *mi)
{
      //timeStamp=millis();
      curPos=curPos+(mi->dX);
};

// ---------------------- Params
//**** Mouse Crap
USB     Usb;
USBHub  Hub(&Usb);
HIDBoot<HID_PROTOCOL_MOUSE>    HidMouse(&Usb);
MouseRptParser  Prs;
int lastPos;
int mouseDelta;
int invertRun=0;

//**** Servo Stuff
Servo myservo;
int rewardPos=17;
int restPos=27;
//random(min, max)

//**** Other Vars
long timeOffset;
unsigned long tS;
unsigned long beginTime;
int lastKnownState=49;
int sB;

//**** Trial Stuff
int lFreq=2;
int hFreq=10;
int targPos=1000;
int tRange=1000;
int tRangeE;
const float pi = 3.14;
int tCount=1;
int lowPos=2000;
int highPos=9000;
int rewardTime=2000;

# define rPin 3
# define gPin 5
# define bPin 6
# define texturePin 7
# define servoPin 9

SM Simple(S1_H, S1_B); // Trial State Machine


//------------- Program Block

void setup()
{
    Serial.begin(115200);
//    while (!Serial) {
//      ; // wait for serial port to connect. Needed for Leonardo only
//    }
    if (Usb.Init() == -1)
      Serial.println("OSC did not start.");
    Serial.setTimeout(100);
    delay(200);
    beginTime=millis();
    Serial.println("Start"); 
    HidMouse.SetReportParser(0,(HIDReportParser*)&Prs);
    pinMode(rPin, OUTPUT);
    pinMode(gPin, OUTPUT);
    pinMode(bPin, OUTPUT);
    pinMode(texturePin,OUTPUT);
    digitalWrite(rPin, HIGH);
    digitalWrite(gPin, HIGH);
    digitalWrite(bPin, HIGH);
    myservo.attach(servoPin);
    myservo.write(restPos); 
    randomSeed(analogRead(0));
    sB=49;
    if (invertRun==1){
      tRangeE=-1*tRange;
    }
    else {
      tRangeE=tRange;
    }
}

void loop()
{
  Usb.Task();    // HID Parsing
  EXEC(Simple);  // State Machine
}


//------------ State Definitions

State S1_H(){
  digitalWrite(rPin, LOW);
  digitalWrite(gPin, HIGH);
  digitalWrite(bPin, LOW);
  lastPos=Prs.curPos;
  Prs.curPos=0;
  lastKnownState=49;
  //myservo.write(restPos);
}


State S1_B(){ 
  mouseDelta=Prs.curPos-lastPos;;
  lastPos=Prs.curPos;
  tS=Simple.Statetime();
  Serial.println(1);
  Serial.println(Prs.curPos);
  Serial.println(mouseDelta);
  Serial.println(tS);
  sB=lookForSerial();
  //Serial.println(sB);
  Serial.println(millis()-beginTime);
  Serial.println(tCount);
  Serial.println(targPos);
  Serial.println(tRangeE);
  if(Simple.Timeout(6000)) Simple.Set(S2_H,S2_B);
  if(sB==50) Simple.Set(S2_H,S2_B);
}

State S2_H(){
  digitalWrite(rPin, HIGH);
  digitalWrite(gPin, LOW);
  digitalWrite(bPin, HIGH);
  //myservo.write(restPos);
  lastPos=Prs.curPos;
  Prs.curPos=0;
  lastKnownState=50;
  // myservo.write(restPos);
}

State S2_B(){
  //sin_texture(Prs.curPos,lFreq);
  burriedSin_texture(Prs.curPos, targPos, tRange, lFreq, hFreq);
  mouseDelta=Prs.curPos-lastPos;
  lastPos=Prs.curPos;
  tS=Simple.Statetime();
  Serial.println(2);
  Serial.println(Prs.curPos);
  Serial.println(mouseDelta);
  Serial.println(tS);
  sB=lookForSerial();
  //Serial.println(sB);
  Serial.println(millis()-beginTime);
  Serial.println(tCount);
  Serial.println(targPos);
  Serial.println(tRangeE);
  if(Simple.Timeout(60000)) Simple.Set(S3_H,S3_B);
  // if(sB==49) Simple.Set(S1_H,S1_B);
  if(sB==51) Simple.Set(S3_H,S3_B);
  if(sB==52) Simple.Set(S4_H,S4_B);
}

State S3_H(){
  digitalWrite(rPin, LOW);
  digitalWrite(gPin, HIGH);
  digitalWrite(bPin, HIGH);
  lastPos=Prs.curPos;
  Prs.curPos=0;
  lastKnownState=51;
  myservo.write(restPos);
  tCount=tCount+1;
  if (invertRun==1){
    targPos=-1*random(lowPos, highPos);
  }
  else {
    targPos=random(lowPos, highPos);
  }
}

State S3_B(){
  mouseDelta=Prs.curPos-lastPos;
  lastPos=Prs.curPos;
  tS=Simple.Statetime();
  Serial.println(3);
  Serial.println(Prs.curPos);
  Serial.println(mouseDelta);
  Serial.println(tS);
  sB=lookForSerial();
  //Serial.println(sB);
  Serial.println(millis()-beginTime);
  Serial.println(tCount);
  Serial.println(targPos);
  Serial.println(tRangeE);
  // if(Simple.Timeout(10000)) Simple.Set(S2_H,S2_B);
  if(sB==49) Simple.Set(S1_H,S1_B);
  if(sB==50) Simple.Set(S2_H,S2_B);
}

State S4_H(){
  digitalWrite(rPin, HIGH);
  digitalWrite(gPin, HIGH);
  digitalWrite(bPin, LOW);
  lastPos=Prs.curPos;
  Prs.curPos=0;
  lastKnownState=52; 
  myservo.write(rewardPos);
}

State S4_B(){
  mouseDelta=Prs.curPos-lastPos;
  lastPos=Prs.curPos;
  tS=Simple.Statetime();
  Serial.println(4);
  Serial.println(Prs.curPos);
  Serial.println(mouseDelta);
  Serial.println(tS);
  sB=lookForSerial();
  //Serial.println(sB);
  Serial.println(millis()-beginTime);
  Serial.println(tCount);
  Serial.println(targPos);
  Serial.println(tRangeE);
  //myservo.write(rewardPos);
  if(Simple.Timeout(rewardTime))  Simple.Set(S3_H,S3_B);
//  if(sB==49) Simple.Set(S1_H,S1_B);
//  if(sB==50)  myservo.write(restPos); Simple.Set(S2_H,S2_B);
//  if(sB==51) myservo.write(restPos); Simple.Set(S3_H,S3_B);
}

State S5_H(){
  digitalWrite(rPin, HIGH);
  digitalWrite(gPin, LOW);
  digitalWrite(bPin, LOW);
  lastPos=Prs.curPos;
  Prs.curPos=0;
  lastKnownState=53;
  Serial.flush(); 
}

State S5_B(){
  tS=Simple.Statetime();
  sB=lookForSerial();
  if(Simple.Timeout(1500))  Simple.Set(S3_H,S3_B);
  if(sB==49) Simple.Set(S1_H,S1_B);
  if(sB==50) Simple.Set(S2_H,S2_B);
  if(sB==51) Simple.Set(S3_H,S3_B);
}


// ---------- Helper Functions

void sin_texture(int pos, int freq)
{
  if (sin(2*pi*pos*freq)>0){
    digitalWrite(texturePin, HIGH);
    //digitalWrite(texturePinG, HIGH);
  } 
  else if (sin(2*pi*pos*freq)<=0){
    digitalWrite(texturePin, LOW);
    //digitalWrite(texturePinG, LOW);
  }          
}

void burriedSin_texture(int pos, int targetPos, int targetRange, int lowFreq, int highFreq)
{
  if (invertRun==0){
    if (pos < targetPos | pos > targetPos+targetRange){ 
      sin_texture(pos, lowFreq);
    }
    else if (pos >= targetPos | pos <= targetPos+targetRange){
      sin_texture(pos, highFreq);
    }
  }
  else
    if (pos > targetPos | pos < (targetPos-targetRange)){ 
      sin_texture(pos, lowFreq);
    }
    else if (pos <= targetPos | pos >= (targetPos-targetRange)){
      sin_texture(pos, highFreq);
    }  
}

int lookForSerial(){
  int saBit;
  if(Serial.available()>0){
      saBit=Serial.read();
      lastKnownState=saBit;
  }
  else if(Serial.available()<=0){
    saBit=lastKnownState;
  }
  return saBit;
}
 



    
    


