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

SM Simple(S1_H, S1_B); // Trial State Machine
unsigned long beginTime;
unsigned long curStateTime;
int lastKnownState;
int sB;

void setup()
{
    Serial.begin(115200);
    if (Usb.Init() == -1)
      Serial.println("OSC did not start.");
    Serial.setTimeout(100);
    delay(200);
    
    beginTime=millis();
    //Serial.println("Start"); 
    HidMouse.SetReportParser(0,(HIDReportParser*)&Prs);
    
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
  lastKnownState=49;
  //lastPos=Prs.curPos;
  Prs.curPos=0;
}


State S1_B(){ 
  curStateTime=Simple.Statetime();
  Serial.println(1);
  Serial.println(curStateTime);
  Serial.println(millis()-beginTime);
  Serial.println(Prs.curPos);
  sB=lookForSerial();
  // if(Simple.Timeout(1000)) Simple.Set(S2_H,S2_B);
  if(sB==50) Simple.Set(S2_H,S2_B);
}

State S2_H(){
  lastKnownState=50;
  Prs.curPos=0;
}

State S2_B(){
  curStateTime=Simple.Statetime();
  Serial.println(2);
  Serial.println(curStateTime);
  Serial.println(millis()-beginTime);
  Serial.println(Prs.curPos);
  sB=lookForSerial();
  if(Simple.Timeout(10000)) Simple.Set(S1_H,S1_B);
  if(sB==49) Simple.Set(S1_H,S1_B);
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
    
    



