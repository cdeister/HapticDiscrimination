import serial # import Serial Library
import numpy  # Import numpy
import matplotlib.pyplot as plt #import matplotlib library
from drawnow import *
import time

states=[]
stateTime=[]
totalTime=[]
mousePos=[]
pythonTime=[]
tOffset=2.2
latch=0
n=1

arduino = serial.Serial('/dev/cu.usbmodem1461', 115200) #Creating our serial object named arduinoData



startTime = time.time()
currentTime=0    
while currentTime<=1800+tOffset:
    while (arduino.inWaiting()==0): #Wait here until there is data
        pass #do nothing
    tS = float(arduino.readline().strip())            
    tST = float(arduino.readline().strip())    
    tTT = float(arduino.readline().strip())  
    tMP = int(arduino.readline().strip())           
           
    states.append(tS)                     
    stateTime.append(tST)    
    totalTime.append(tTT)
    mousePos.append(tMP)
    pythonTime.append(currentTime)      
    if latch==0 and tS==1 and currentTime>6:
        arduino.write('2')
        latch=1           
    n=n+1
    currentTime=time.time()-startTime

exportArray=numpy.array([states,stateTime,totalTime,mousePos,pythonTime])
exportArray = exportArray[numpy.newaxis].T
numpy.savetxt("foo4.csv", exportArray, delimiter=",",fmt='%f')
arduino.close()
plt.plot(pythonTime,mousePos)
plt.pause(60)