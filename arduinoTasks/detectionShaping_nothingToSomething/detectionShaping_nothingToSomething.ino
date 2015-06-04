
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

//**** Servo Stuff
Servo myservo;
int rewardPos=19;
int restPos=26;

//**** Other Vars
long timeOffset;
unsigned long tS;
unsigned long beginTime;
int lastKnownState=49;
int sB;

//**** Trial Params
long lFreq[]={0,300};  //baseline,stim
int clickTime=1000;  // in microseconds
long targPos=12000;
long tRange=20000;  //15000
long lowPos= 7000;   //8000;
long highPos=25000;   //50000;
int rewardTime=2000;    // in ms
int stepperTime=100;    // in ms
int timeoutTime=5000;   // in ms
int trialTimeout=60000; // in ms
int catchProb=10;       // in % (p*100)


//*** Trial Variables
int lRand=0;
int rRand=1;
long clickPosL;
long clickPosR;
int clickDeltaL;
int clickDeltaR;
int clickLBool;
int clickRBool;
int previousToggle;
int positionToggle;
int temp_lRand;
int temp_rRand;
int tCount=1;
int catchNum=0;           // random integer that will trip catch condition

# define rPin 6
# define gPin 5
# define bPin 3
# define clickPinL 7
# define clickPinR 8
# define servoPin 9
# define stepperPin 12
# define alertPin 11
# define cameraPin 2

SM Simple(S1_H, S1_B); // Trial State Machine


//------------- Program Block

void setup()
{
    Serial.begin(115200);
    if (Usb.Init() == -1)
      Serial.println("OSC did not start.");
    //Serial.setTimeout(4000);
    delay(800);
    
    //beginTime=millis();
    //Serial.println("Start"); 
    HidMouse.SetReportParser(0,(HIDReportParser*)&Prs);
    
    pinMode(rPin, OUTPUT);
    pinMode(gPin, OUTPUT);
    pinMode(bPin, OUTPUT);
    pinMode(clickPinL,OUTPUT);
    pinMode(clickPinR,OUTPUT);
    pinMode(stepperPin,OUTPUT);
    pinMode(alertPin,OUTPUT);
    pinMode(cameraPin,OUTPUT);
    
    digitalWrite(rPin, HIGH);
    digitalWrite(gPin, HIGH);
    digitalWrite(bPin, HIGH);
    digitalWrite(clickPinL, LOW);
    digitalWrite(clickPinR, LOW);
    digitalWrite(stepperPin,LOW);
    digitalWrite(alertPin,LOW);
    digitalWrite(cameraPin, LOW);
    
    myservo.attach(servoPin);
    myservo.write(restPos); 
    
    randomSeed(analogRead(0));
    sB=49;
}

void loop()
{
  Usb.Task();    // HID Parsing
  EXEC(Simple);  // State Machine
}


//------------ State Definitions

State S1_H(){
  beginTime=millis();
  digitalWrite(cameraPin, HIGH);
  digitalWrite(rPin, LOW);
  digitalWrite(gPin, HIGH);
  digitalWrite(bPin, LOW);
  lastPos=Prs.curPos;
  Prs.curPos=0;
  lastKnownState=49;
}


State S1_B(){ 
  mouseDelta=Prs.curPos-lastPos;
  lastPos=Prs.curPos;
  tS=Simple.Statetime();
  Serial.println(1);
  Serial.println(Prs.curPos);
  Serial.println(mouseDelta);
  Serial.println(tS);
  sB=lookForSerial();
  Serial.println(millis()-beginTime);
  Serial.println(tCount);
  Serial.println(targPos);
  Serial.println(tRange);
  Serial.println(clickLBool);
  Serial.println(clickRBool);
  Serial.println(lFreq[lRand]);
  Serial.println(lFreq[rRand]);
  Serial.println(catchNum);
  if(Simple.Timeout(4000)) Simple.Set(S2_H,S2_B);
  if(sB==50) Simple.Set(S2_H,S2_B);
  if(sB==54) Simple.Set(S6_H,S6_B);
}

State S2_H(){
  digitalWrite(rPin, HIGH);
  digitalWrite(gPin, LOW);
  digitalWrite(bPin, HIGH);
  digitalWrite(clickPinL,HIGH);
  digitalWrite(clickPinR,HIGH);
  delayMicroseconds(clickTime);
  digitalWrite(clickPinR,LOW);
  digitalWrite(clickPinL,LOW);
  lastPos=Prs.curPos;
  Prs.curPos=0;
  lastKnownState=50;
  clickDeltaL=0;
  clickDeltaR=0;
  temp_lRand=lFreq[lRand];
  clickPosL=getNextClickTarget(temp_lRand);
  clickPosR=clickPosL;
  previousToggle=1;
  positionToggle=0;
}

State S2_B(){
    mouseDelta=Prs.curPos-lastPos;
    lastPos=Prs.curPos;
    clickDeltaL=clickDeltaL+abs(mouseDelta);
    clickDeltaR=clickDeltaL;
    
    // ---- This block determines what to do with the stimulus based on a position condition ----
    if (Prs.curPos>=targPos && Prs.curPos<=targPos+tRange && catchNum!=1){
      positionToggle=1;
    } // if this isn't a catch trial, then switch the stimulus somehow
    else if (Prs.curPos>=targPos && Prs.curPos<=targPos+tRange && catchNum==1){
      positionToggle=0;
    } // if this is a catch trial, then don't switch
    else if (Prs.curPos<targPos){
      positionToggle=0;
    } // if below the switch position keep it the same (default condition)
    else if (Prs.curPos>targPos+tRange && catchNum!=1){
      Simple.Set(S5_H,S5_B);
    } // if the animal runs off, and it isn't a catch, then send to timeout state (miss)
    else if (Prs.curPos>targPos+tRange && catchNum==1){  // If this is a catch-trial, then don't timeout if he runs off.
      Simple.Set(S3_H,S3_B);  
    } // if the animal runs off, and it is a catch, then put back to wait state (correct-rejection)
    // ---- end position condition block
    
    // ---- this block is concerned with updating the click train
    if (positionToggle==0 && previousToggle==1){
      temp_lRand=lFreq[lRand];
      clickPosL=getNextClickTarget(temp_lRand);
      clickPosR=clickPosL;
      clickDeltaL=0;
      clickDeltaR=0;
    }
    else if (positionToggle==1 && previousToggle==0){
      temp_lRand=lFreq[rRand];
      //temp_rRand=lFreq[lRand];
      clickPosL=getNextClickTarget(temp_lRand);
      clickPosR=clickPosL;
      clickDeltaL=0;
      clickDeltaR=0;
    }

   if (clickDeltaL >= clickPosL){
    digitalWrite(clickPinL,HIGH);
    delayMicroseconds(clickTime);
    digitalWrite(clickPinL,LOW);
    clickPosL=getNextClickTarget(temp_lRand);
    clickDeltaL=0;
    clickLBool=1;
   }
   else if (clickDeltaL < clickPosL) {
     clickLBool=0;
   }
   
   if (clickDeltaR >= clickPosR){
     digitalWrite(clickPinR,HIGH);
     delayMicroseconds(clickTime);
     digitalWrite(clickPinR,LOW);
     clickPosR=clickPosL;
     clickDeltaR=0;
     clickRBool=1;
   }
   else if (clickDeltaR < clickPosR) {
     clickRBool=0;
   }
  // ---- end click train block
  
  tS=Simple.Statetime();
  Serial.println(2);
  Serial.println(Prs.curPos);
  Serial.println(mouseDelta);
  Serial.println(tS);
  sB=lookForSerial();
  Serial.println(millis()-beginTime);
  Serial.println(tCount);
  Serial.println(targPos);
  Serial.println(tRange);
  Serial.println(clickLBool);
  Serial.println(clickRBool);
  Serial.println(lFreq[lRand]);
  Serial.println(lFreq[rRand]);
  Serial.println(catchNum);
  previousToggle=positionToggle;
  if(Simple.Timeout(trialTimeout)) Simple.Set(S3_H,S3_B);
  if(sB==51) Simple.Set(S3_H,S3_B); // wait state
  if(sB==52) Simple.Set(S4_H,S4_B); // reward state
  if(sB==53) Simple.Set(S5_H,S5_B); // miss (punishment) state
  if(sB==54) Simple.Set(S6_H,S6_B);
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
  targPos=random(lowPos, highPos);
  //tRange=2*targPos;
  catchNum=random(0,11);  //to-do add variable to scale % of catch trials. 
  lRand=0;
  rRand=1; 
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
  Serial.println(millis()-beginTime);
  Serial.println(tCount);
  Serial.println(targPos);
  Serial.println(tRange);
  Serial.println(clickLBool);
  Serial.println(clickRBool);
  Serial.println(lFreq[lRand]);
  Serial.println(lFreq[rRand]);
  Serial.println(catchNum);
  if(sB==49) Simple.Set(S1_H,S1_B);
  if(sB==50) Simple.Set(S2_H,S2_B);
  if(sB==54) Simple.Set(S6_H,S6_B);
}

State S4_H(){
  digitalWrite(stepperPin, HIGH);
  blinkAlertPin(8,20);
  blinkBlue(5,20);
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
  Serial.println(millis()-beginTime);
  Serial.println(tCount);
  Serial.println(targPos);
  Serial.println(tRange);
  Serial.println(clickLBool);
  Serial.println(clickRBool);
  Serial.println(lFreq[lRand]);
  Serial.println(lFreq[rRand]);
  Serial.println(catchNum);
  if (tS>stepperTime){
    digitalWrite(stepperPin,LOW);
  }
  if(Simple.Timeout(rewardTime))  Simple.Set(S3_H,S3_B);
}

State S5_H(){
  //blinkTeal(8,20);
    digitalWrite(rPin, HIGH);
  digitalWrite(gPin, HIGH);
  digitalWrite(bPin, HIGH);
  lastPos=Prs.curPos;
  Prs.curPos=0;
  lastKnownState=53; 
}

State S5_B(){
  mouseDelta=Prs.curPos-lastPos;
  lastPos=Prs.curPos;
  tS=Simple.Statetime();
  Serial.println(5);
  Serial.println(Prs.curPos);
  Serial.println(mouseDelta);
  Serial.println(tS);
  sB=lookForSerial();
  Serial.println(millis()-beginTime);
  Serial.println(tCount);
  Serial.println(targPos);
  Serial.println(tRange);
  Serial.println(clickLBool);
  Serial.println(clickRBool);
  Serial.println(lFreq[lRand]);
  Serial.println(lFreq[rRand]);
  Serial.println(catchNum);
  if(Simple.Timeout(timeoutTime))  Simple.Set(S3_H,S3_B);
}

State S6_H(){
  digitalWrite(rPin, HIGH);
  digitalWrite(gPin, LOW);
  digitalWrite(bPin, LOW);
  lastPos=Prs.curPos;
  Prs.curPos=0;
  lastKnownState=54;
  Serial.flush(); 
}

State S6_B(){
  tS=Simple.Statetime();
  sB=lookForSerial();
  if(Simple.Timeout(500))  Simple.Set(S3_H,S3_B);
  if(sB==49) Simple.Set(S1_H,S1_B);
  if(sB==50) Simple.Set(S2_H,S2_B);
  if(sB==51) Simple.Set(S3_H,S3_B);
}


// ---------- Helper Functions


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

long getNextClickTarget(long expVal){
   long nextClickPos;
   nextClickPos= long(-log(random(1,101)*0.01)*expVal);
   if (expVal==0){
        nextClickPos=long(500000);
   }
   return nextClickPos;
}

void blinkBlue(int reps,int msInterval){
  for (int n=0; n<reps; n++){
    digitalWrite(rPin, HIGH);
    digitalWrite(gPin, HIGH);
    digitalWrite(bPin, LOW);
    delay(msInterval);
    digitalWrite(rPin, HIGH);
    digitalWrite(gPin, HIGH);
    digitalWrite(bPin, HIGH);
    delay(msInterval);
  }
}

void blinkGreen(int reps,int msInterval){
  for (int n=0; n<reps; n++){
    digitalWrite(rPin, HIGH);
    digitalWrite(gPin, LOW);
    digitalWrite(bPin, HIGH);
    delay(msInterval);
    digitalWrite(rPin, HIGH);
    digitalWrite(gPin, HIGH);
    digitalWrite(bPin, HIGH);
    delay(msInterval);
  }
}

void blinkTeal(int reps,int msInterval){
  for (int n=0; n<reps; n++){
    digitalWrite(rPin, HIGH);
    digitalWrite(gPin, LOW);
    digitalWrite(bPin, LOW);
    delay(msInterval);
    digitalWrite(rPin, HIGH);
    digitalWrite(gPin, HIGH);
    digitalWrite(bPin, HIGH);
    delay(msInterval);
  }
}

void blinkAlertPin(int reps,int msInterval){
  for (int n=0; n<reps; n++){
    digitalWrite(alertPin, HIGH);
    delay(msInterval);
    digitalWrite(alertPin, LOW);
    delay(msInterval);
  }
}
    
    



