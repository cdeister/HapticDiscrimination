#include <hidboot.h>
#include <usbhub.h>
#include <SPI.h>
#include <SM.h>

class MouseRptParser : public MouseReportParser
{

public:
        long curPos;
        unsigned long timeStamp;
        
protected:
	void OnMouseMove	(MOUSEINFO *mi);
};

void MouseRptParser::OnMouseMove(MOUSEINFO *mi)
{
      timeStamp=millis();
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

// These control stop/run detection
int aa=10000;
int bb=0;

# define s1pin 7
# define s2pin 6
# define texturePin 5
# define texturePinG 4
# define readyPin 11

SM Simple(S1); // Trial State Machine


//------------- Program Block

void setup()
{
    Serial.begin(115200);
    Serial.println("Start");

    if (Usb.Init() == -1){
        Serial.println("OSC did not start.");
    }

    delay(200);
    HidMouse.SetReportParser(0,(HIDReportParser*)&Prs);
    pinMode(s1pin, OUTPUT);
    pinMode(s2pin, OUTPUT);
    pinMode(texturePin,OUTPUT);
    pinMode(texturePinG,OUTPUT);
    pinMode(readyPin,OUTPUT);
    timeOffset=Prs.timeStamp; 
}

void loop()
{
  Usb.Task();    // HID Parsing
  EXEC(Simple);  // State Machine
}


//------------ State Definitions

State S1(){
  digitalWrite(readyPin, HIGH);  
  digitalWrite(s1pin, HIGH);
  digitalWrite(s2pin, LOW);
  //sin_texture(Prs.curPos,lFreq);
  burriedSin_texture(Prs.curPos, targPos, tRange, lFreq, hFreq);
  mouseDelta=Prs.curPos-lastPos;
  lastPos=Prs.curPos;
  aa=aa+moveTacker(mouseDelta);
  tS=Prs.timeStamp-timeOffset;
  Serial.println(1);
  Serial.println(Prs.curPos);
  Serial.println(mouseDelta);
  Serial.println(tS);
  if(aa<=0) Simple.Set(S2);
}

State S2(){
  timeOffset=Prs.timeStamp;
  lastPos=0;
  aa=10000;
  bb=0;
  digitalWrite(texturePin, LOW);
  Simple.Set(S3);
}

State S3(){

  digitalWrite(s1pin, LOW);
  digitalWrite(s2pin, HIGH);
  mouseDelta=Prs.curPos-lastPos;
  lastPos=Prs.curPos;
  bb=bb+runTacker(mouseDelta);
  tS=Prs.timeStamp-timeOffset;
  Serial.println(3);
  Serial.println(Prs.curPos);
  Serial.println(mouseDelta);
  Serial.println(tS);
  if(bb>=1000) Simple.Set(S4);
}

State S4(){
  timeOffset=Prs.timeStamp;
  lastPos=0;
  aa=10000;
  bb=0;
  digitalWrite(texturePin, LOW);
  Simple.Set(S1);
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



    
    


