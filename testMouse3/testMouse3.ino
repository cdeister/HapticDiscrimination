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
int hFreq=1000;
int targPos=9000;
int tRange=2000;
long timeOffset;
unsigned long tS;

int lastPos;
int mouseDelta;
const float pi = 3.14;
int sB;

// These control stop/run detection
int aa=10000;
int bb=0;

# define s1pin 7
# define s2pin 8
# define s3pin 9
# define texturePin 5

SM Simple(S1_H, S1_B); // Trial State Machine


//------------- Program Block

void setup()
{
    Serial.begin(115200);
        if (Usb.Init() == -1)
        Serial.println("OSC did not start.");
        Serial.setTimeout(100);

    delay(200);
    
    Serial.println("Start"); 
    HidMouse.SetReportParser(0,(HIDReportParser*)&Prs);
    pinMode(s1pin, OUTPUT);
    pinMode(s2pin, OUTPUT);
    pinMode(s3pin, OUTPUT);
    pinMode(texturePin,OUTPUT);
    digitalWrite(s3pin, LOW);
    digitalWrite(s2pin, LOW);
    digitalWrite(s1pin, LOW);
    sB=1;
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
}


State S1_B(){ 
  //sin_texture(Prs.curPos,lFreq);
  //burriedSin_texture(Prs.curPos, targPos, tRange, lFreq, hFreq);
  mouseDelta=Prs.curPos-lastPos;
  lastPos=Prs.curPos;
  aa=aa+moveTacker(mouseDelta);
  tS=Simple.Statetime();
  Serial.println(1);
  Serial.println(Prs.curPos);
  Serial.println(mouseDelta);
  Serial.println(tS);
  sB=lookForSerial();
  Serial.println(sB);
  if(sB==53) Simple.Set(S2_H,S2_B);
}

State S2_H(){
  digitalWrite(s1pin, LOW);
  digitalWrite(s2pin, HIGH);
  digitalWrite(s3pin, LOW);
}

State S2_B(){
  //sin_texture(Prs.curPos,lFreq);
  burriedSin_texture(Prs.curPos, targPos, tRange, lFreq, hFreq);
  mouseDelta=Prs.curPos-lastPos;
  lastPos=Prs.curPos;
  aa=aa+moveTacker(mouseDelta);
  tS=Simple.Statetime();
  Serial.println(2);
  Serial.println(Prs.curPos);
  Serial.println(mouseDelta);
  Serial.println(tS);
  sB=lookForSerial();
  Serial.println(sB);
  if(Simple.Timeout(10000)) Simple.Set(S3_H,S3_B);
  if(sB==49) Simple.Set(S1_H,S1_B);
  if(sB==51) Simple.Set(S3_H,S3_B);
}

State S3_H(){
  digitalWrite(s1pin, LOW);
  digitalWrite(s2pin, LOW);
  digitalWrite(s3pin, HIGH);
}

State S3_B(){
  //sin_texture(Prs.curPos,lFreq);
  //burriedSin_texture(Prs.curPos, targPos, tRange, lFreq, hFreq);
  mouseDelta=Prs.curPos-lastPos;
  lastPos=Prs.curPos;
  aa=aa+moveTacker(mouseDelta);
  tS=Simple.Statetime();
  Serial.println(3);
  Serial.println(Prs.curPos);
  Serial.println(mouseDelta);
  Serial.println(tS);
  sB=lookForSerial();
  Serial.println(sB);
  if(sB==49) Simple.Set(S1_H,S1_B);
  if(Simple.Timeout(5000)) Simple.Set(S1_H,S1_B);
}


// ---------- Helper Functions

void sin_texture(int pos, int freq)
{
  if (sin(2*pi*pos*freq)>0){
    digitalWrite(texturePin, HIGH);
  } 
  else if (sin(2*pi*pos*freq)<=0){
    digitalWrite(texturePin, LOW);
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

int runTacker(int mov){
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
  }
  else if(Serial.available()<=0){
    saBit=48;  // This is something ... 
  }
  return saBit;
}
 



    
    


