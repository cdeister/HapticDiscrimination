import serial # import Serial Library
import numpy  # Import numpy
import matplotlib.pyplot as plt #import matplotlib library
from drawnow import *
import time




# behavior variables (you might want to change these)
trialGrace=2000         # in ms; this is the minimum time a trial (state 2) will run for
bufferSize=499          # in samples; The crapier the mouse the higher this needs to be.
stopThreshold=1         # derivative crossing
giveTerminalFeedback=1  # boolean flag to output trial state to terminal
trialsToRun=10          # number of trials to collect


# initialize data containers (python lists)
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
hitRecord=[]
sampleBreaks=[]

# flow variables (shouldn't need to mess with these)
n=1
displayLatch=0
currentState=1
currentTrial=1
plt.ion()

# start serial communication
arduino = serial.Serial('/dev/cu.usbmodem1461', 115200) #Creating our serial object named arduinoData
arduino.write('1')

# variables to track time
startTime = time.time()
currentTime=0    

while currentTrial<=trialsToRun: #currentTime<=60+tOffset:
    while (arduino.inWaiting()==0): #Wait here until there is data
        pass #do nothing
    # state flow: 1) initialization state --> 2) trial state <--> 3) wait state <--> 6) clean-up state (flushes serial etc.)
    #                                                        <--> 4) reward state
    #                                                        <--> 5) miss state (with a timeout set in arduino; could set here) 
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
            if displayLatch==0:
                displayLatch=1
                hitRecord.append(1)
                print("trial # %d") % trialCount[-1],
                print("= hit; elapsed time: %.2f") % currentTime,
                print("seconds; hit rate = %.2f") % numpy.mean(hitRecord)
                plt.cla()
                plt.plot(totalTime,positions,'k-',totalTime,stimChangePositions,'r--',totalTime,numpy.add(stimChangePositions,stimChangeRanges),'b--')
                plt.ylabel('position')
                plt.xlabel('time (ms)')
                plt.title("trial # %d; Hit" % trialCount[-1])
                plt.pause(0.000001)
            arduino.write('4')
        elif timeInStates[-1]>trialGrace and numpy.mean(numpy.abs(deltas[-199:-1]))<stopThreshold and positions[-1]<stimChangePositions[-1] or positions[-1]>stimChangePositions[-1]+stimChangeRanges[-1]:  
            if displayLatch==0:
                displayLatch=1
                hitRecord.append(0)
                print("trial # %d") % trialCount[-1],
                print("= miss; elapsed time: %.2f") % currentTime,
                print("seconds; hit rate = %.2f") % numpy.mean(hitRecord)
                plt.cla()
                plt.plot(totalTime,positions,'k-',totalTime,stimChangePositions,'r--',totalTime,numpy.add(stimChangePositions,stimChangeRanges),'b--')
                plt.ylabel('position')
                plt.xlabel('time (ms)')
                plt.title("trial # %d; Hit" % trialCount[-1])
                plt.pause(0.000001)
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
        if timeInStates[-1]>1000:
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
    currentTrial=trialCount[-1]
    
    if n>4 and giveTerminalFeedback==1:
        trialDif=trialCount[-1]-trialCount[-2]
        if trialDif==1:
            lastSample=len(pythonTime)
            print lastSample
            displayLatch=0     #This is for terminal feedback of trial flow

# save data
exportArray=numpy.array([states,positions,deltas,timeInStates,totalTime,trialCount,stimChangePositions,stimChangeRanges,clickTrainLeft,clickTrainRight,pythonTime])
exportArray = exportArray[numpy.newaxis].T
numpy.savetxt("foo4.csv", exportArray, delimiter=",",fmt='%f')

# clean up
arduino.write('6')
arduino.close()
exit()