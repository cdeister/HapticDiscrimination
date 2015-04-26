#include <hidboot.h>
#include <usbhub.h>
#include <SPI.h>
#include <SM.h>

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

//**** My Crap
int lFreq=1;
int hFreq=200;
int targPos=4000;
int tRange=600;
long timeOffset;
unsigned long tS;
unsigned long cT;
int lastKnownState=49;

int lastPos;
int mouseDelta;
const float pi = 3.14;
int sB;


# define s1pin 7
# define s2pin 8
# define s3pin 9
# define texturePin 5
# define texturePinG 4

SM Simple(S1_H, S1_B); // Trial State Machine


//------------- Program Block

void setup()
{
    Serial.begin(115200);
        if (Usb.Init() == -1)
        Serial.println("OSC did not start.");
        Serial.setTimeout(100);

    delay(200);
    cT=millis();
    Serial.println("Start"); 
    HidMouse.SetReportParser(0,(HIDReportParser*)&Prs);
    pinMode(s1pin, OUTPUT);
    pinMode(s2pin, OUTPUT);
    pinMode(s3pin, OUTPUT);
    pinMode(texturePin,OUTPUT);
    pinMode(texturePinG,OUTPUT);
    digitalWrite(s3pin, LOW);
    digitalWrite(s2pin, LOW);
    digitalWrite(s1pin, LOW);
    sB=49;
}

void loop()
{
  Usb.Task();    // HID Parsing
  EXEC(Simple);  // State Machine
}


//------------ State Definitions

State S1_H(){
  digitalWrite(s1pin, HIGH);
  digitalWrite(s2pin, LOW);
  digitalWrite(s3pin, LOW);
  lastPos=Prs.curPos;
  Prs.curPos=0;
  lastKnownState=49;
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
  Serial.println(sB);
  Serial.println(millis()-cT);
  if(Simple.Timeout(6000)) Simple.Set(S2_H,S2_B);
  if(sB==50) Simple.Set(S2_H,S2_B);
}

State S2_H(){
  digitalWrite(s1pin, LOW);
  digitalWrite(s2pin, HIGH);
  digitalWrite(s3pin, LOW);
  lastPos=Prs.curPos;
  Prs.curPos=0;
  lastKnownState=50;
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
  Serial.println(sB);
  Serial.println(millis()-cT);
  if(Simple.Timeout(20000)) Simple.Set(S3_H,S3_B);
  // if(sB==49) Simple.Set(S1_H,S1_B);
  if(sB==51) Simple.Set(S3_H,S3_B);
}

State S3_H(){
  digitalWrite(s1pin, LOW);
  digitalWrite(s2pin, LOW);
  digitalWrite(s3pin, HIGH);
  lastPos=Prs.curPos;
  Prs.curPos=0;
  lastKnownState=51;
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
  Serial.println(sB);
  Serial.println(millis()-cT);
  // if(Simple.Timeout(10000)) Simple.Set(S2_H,S2_B);
  if(sB==49) Simple.Set(S1_H,S1_B);
  if(sB==50) Simple.Set(S2_H,S2_B);
}


// ---------- Helper Functions

void sin_texture(int pos, int freq)
{
  if (sin(2*pi*pos*freq)>0){
    digitalWrite(texturePin, HIGH);
    digitalWrite(texturePinG, LOW);
  } 
  else if (sin(2*pi*pos*freq)<=0){
    digitalWrite(texturePin, LOW);
    digitalWrite(texturePinG, LOW);
  }          
}

void burriedSin_texture(int pos, int targetPos, int targetRange, int lowFreq, int highFreq)
{
  if (pos < targetPos | pos > targetPos+targetRange){ 
    sin_texture(pos, lowFreq);
  }
  else if (pos >= targetPos | pos <= targetPos+targetRange){
    sin_texture(pos, highFreq);
  }  
}

int moveTacker(int mov){
  int rMov;
  if (abs(mov)>0){
    rMov=0;
  }
  else if (abs(mov)==0){
    rMov=0;
  }    
  return rMov; 
}

int runTacker(int mov, int intPeriod){
  int rMov;
  if (abs(mov)>0){
    rMov=0;
  }
  else if (abs(mov)==0){
    rMov=0;
  }    
  return rMov; 
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
 



    
    


