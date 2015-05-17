import serial # import Serial Library
import numpy  # Import numpy
import matplotlib.pyplot as plt #import matplotlib library
from drawnow import *
import time



states=[]
positions=[]
deltas=[]
timeInStates=[]
totalTime=[]
trialCount=[]
stimChangePositions=[]
stimChangeRanges=[]
clickTrainLeft=[]
clickTrainRight=[]
leftExpectedVal=[]
rightExpectedVal=[]
pythonTime=[]

tOffset=2.2
latch=0
n=1
currentState=1
trialGrace=3000
bufferSize=499 # The crapier the mouse the higher this needs to be
stopThreshold=1

arduino = serial.Serial('/dev/cu.usbmodem1421', 115200) #Creating our serial object named arduinoData
#arduino.write('1')


startTime = time.time()
currentTime=0    
while currentTime<=60+tOffset:
    while (arduino.inWaiting()==0): #Wait here until there is data
        pass #do nothing
    if currentState==1:    
        states.append(int(arduino.readline().strip()))
        positions.append(int(arduino.readline().strip()))
        deltas.append(int(arduino.readline().strip()))
        timeInStates.append(float(arduino.readline().strip()))
        totalTime.append(float(arduino.readline().strip()))
        trialCount.append(int(arduino.readline().strip()))
        stimChangePositions.append(int(arduino.readline().strip()))
        stimChangeRanges.append(int(arduino.readline().strip()))
        clickTrainLeft.append(int(arduino.readline().strip()))
        clickTrainRight.append(int(arduino.readline().strip()))
        leftExpectedVal.append(int(arduino.readline().strip()))
        rightExpectedVal.append(int(arduino.readline().strip()))
        pythonTime.append(currentTime)
        currentState=states[-1]      
    elif currentState==2:
        states.append(int(arduino.readline().strip()))
        positions.append(int(arduino.readline().strip()))
        deltas.append(int(arduino.readline().strip()))
        timeInStates.append(float(arduino.readline().strip()))
        totalTime.append(float(arduino.readline().strip()))
        trialCount.append(int(arduino.readline().strip()))
        stimChangePositions.append(int(arduino.readline().strip()))
        stimChangeRanges.append(int(arduino.readline().strip()))
        clickTrainLeft.append(int(arduino.readline().strip()))
        clickTrainRight.append(int(arduino.readline().strip()))
        leftExpectedVal.append(int(arduino.readline().strip()))
        rightExpectedVal.append(int(arduino.readline().strip()))
        pythonTime.append(currentTime)
        currentState=states[-1]
        stimDif=leftExpectedVal[-1]-rightExpectedVal[-1]
        if timeInStates[-1]>trialGrace and numpy.mean(numpy.abs(deltas[-199:-1]))<stopThreshold and positions[-1]>stimChangePositions[-1] and positions[-1]<=stimChangePositions[-1]+stimChangeRanges[-1]:
            arduino.write('4')
        elif timeInStates[-1]>trialGrace and numpy.mean(numpy.abs(deltas[-199:-1]))<stopThreshold and positions[-1]<stimChangePositions[-1] or positions[-1]>stimChangePositions[-1]+stimChangeRanges[-1]:  
            arduino.write('5')
            
    elif currentState==3:
        states.append(int(arduino.readline().strip()))
        positions.append(int(arduino.readline().strip()))
        deltas.append(int(arduino.readline().strip()))
        timeInStates.append(float(arduino.readline().strip()))
        totalTime.append(float(arduino.readline().strip()))
        trialCount.append(int(arduino.readline().strip()))
        stimChangePositions.append(int(arduino.readline().strip()))
        stimChangeRanges.append(int(arduino.readline().strip()))
        clickTrainLeft.append(int(arduino.readline().strip()))
        clickTrainRight.append(int(arduino.readline().strip()))
        leftExpectedVal.append(int(arduino.readline().strip()))
        rightExpectedVal.append(int(arduino.readline().strip()))
        pythonTime.append(currentTime)
        currentState=states[-1]
        if timeInStates[-1]>2000:
            arduino.write('2')
    elif currentState==4:
        states.append(int(arduino.readline().strip()))
        positions.append(int(arduino.readline().strip()))
        deltas.append(int(arduino.readline().strip()))
        timeInStates.append(float(arduino.readline().strip()))
        totalTime.append(float(arduino.readline().strip()))
        trialCount.append(int(arduino.readline().strip()))
        stimChangePositions.append(int(arduino.readline().strip()))
        stimChangeRanges.append(int(arduino.readline().strip()))
        clickTrainLeft.append(int(arduino.readline().strip()))
        clickTrainRight.append(int(arduino.readline().strip()))
        leftExpectedVal.append(int(arduino.readline().strip()))
        rightExpectedVal.append(int(arduino.readline().strip()))
        pythonTime.append(currentTime)
        currentState=states[-1]
    elif currentState==5:
        states.append(int(arduino.readline().strip()))
        positions.append(int(arduino.readline().strip()))
        deltas.append(int(arduino.readline().strip()))
        timeInStates.append(float(arduino.readline().strip()))
        totalTime.append(float(arduino.readline().strip()))
        trialCount.append(int(arduino.readline().strip()))
        stimChangePositions.append(int(arduino.readline().strip()))
        stimChangeRanges.append(int(arduino.readline().strip()))
        clickTrainLeft.append(int(arduino.readline().strip()))
        clickTrainRight.append(int(arduino.readline().strip()))
        leftExpectedVal.append(int(arduino.readline().strip()))
        rightExpectedVal.append(int(arduino.readline().strip()))
        pythonTime.append(currentTime)
        currentState=states[-1]            
    n=n+1
    currentTime=time.time()-startTime

exportArray=numpy.array([states,positions,deltas,timeInStates,totalTime,trialCount,stimChangePositions,stimChangeRanges,clickTrainLeft,clickTrainRight,pythonTime])
exportArray = exportArray[numpy.newaxis].T
numpy.savetxt("foo4.csv", exportArray, delimiter=",",fmt='%f')
arduino.write('6')
arduino.close()
plt.plot(pythonTime,positions)
plt.pause(10)
exit()