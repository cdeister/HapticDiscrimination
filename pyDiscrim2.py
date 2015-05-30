# pyDiscrim:
#This script works with an optical mouse and an arduino for behavioral control intended for a tactile disctimination task in mice.
#
# 5/18/2015
# questions? --> Chris Deister --> cdeister@Bbrown.edu
#


import serial
import numpy
import matplotlib.pyplot as plt
import time
import datetime


# behavior variables (you might want to change these)
trialsToRun=200          # number of trials to collect
trialGrace=3000         # in ms; this is the minimum time a trial (state 2) will run for
bufferSize=69          # in samples; The crapier the mouse the higher this needs to be.
stopThreshold=7         # derivative crossing
giveTerminalFeedback=1  # boolean flag to output trial state to terminal
plotFeedback=1



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
lastTrial=1  # I will use this to gate a latch when there is a new trial.

# flow variables (shouldn't need to mess with these)
n=1
displayLatch=0
currentState=1
currentTrial=1
plt.ion()



# start serial communication
arduino = serial.Serial('/dev/cu.usbmodem1421', 115200) #Creating our serial object named arduinoData
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')
arduino.write('1')




# variables to track time
startTime = time.time()
currentTime=0


while currentTrial<=trialsToRun: #currentTime<=60+tOffset:
#    while (arduino.inWaiting()==0): #Wait here until there is data
#        pass #do nothing
# state flow: 1) initialization state --> 2) trial state <--> 3) wait state <--> 6) clean-up state (flushes serial etc.)
#                                                        <--> 4) reward state
#                                                        <--> 5) miss state (with a timeout set in arduino; could set here)
    try:
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
            if timeInStates[-1]>trialGrace and stimDif !=0 and numpy.mean(numpy.abs(deltas[-bufferSize:-1]))<stopThreshold and positions[-1]>stimChangePositions[-1] and positions[-1]<=stimChangePositions[-1]+stimChangeRanges[-1]:
                if displayLatch==0:
                    displayLatch=1
                    hitRecord.append(1)
                    print("trial # %d") % trialCount[-1],
                    print("= hit; elapsed time: %.2f") % currentTime,
                    print("seconds; hit rate = %.2f") % numpy.mean(hitRecord)
                    if plotFeedback==1:
                        plt.cla()
                        plt.subplot(2,1,1)
                        plt.plot(totalTime,positions,'k-',totalTime,stimChangePositions,'r--',totalTime,numpy.add(stimChangePositions,stimChangeRanges),'r--')
                        plt.ylabel('position')
                        plt.xlabel('time (ms)')
                        plt.title("trial # %d; Hit" % trialCount[-1])
                        plt.subplot(2,1,2)
                        plt.plot(totalTime,states,'k-')
                        plt.ylabel('state')
                        plt.xlabel('time (ms)')
                        plt.pause(0.000001)
                    arduino.write('4')
            elif timeInStates[-1]>trialGrace and numpy.mean(numpy.abs(deltas[-bufferSize:-1]))<stopThreshold and positions[-1]<stimChangePositions[-1] or positions[-1]>stimChangePositions[-1]+stimChangeRanges[-1]:
                if displayLatch==0:
                    displayLatch=1
                    hitRecord.append(0)
                    print("trial # %d") % trialCount[-1],
                    print("= miss; elapsed time: %.2f") % currentTime,
                    print("seconds; hit rate = %.2f") % numpy.mean(hitRecord)
                    if plotFeedback==1:
                        plt.cla()
                        plt.subplot(2,1,1)
                        plt.plot(totalTime,positions,'k-',totalTime,stimChangePositions,'r--',totalTime,numpy.add(stimChangePositions,stimChangeRanges),'r--')
                        plt.ylabel('position')
                        plt.xlabel('time (ms)')
                        plt.title("trial # %d; Miss" % trialCount[-1])
                        plt.subplot(2,1,2)
                        plt.plot(totalTime,states,'k-')
                        plt.ylabel('state')
                        plt.xlabel('time (ms)')
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
            if timeInStates[-1]>1500 and numpy.mean(numpy.abs(deltas[-bufferSize:-1]))<stopThreshold:
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
        trialDif=currentTrial-lastTrial
        lastTrial=currentTrial
        if trialDif==1:
            lastSample=len(pythonTime)        #<-- Place holder for real time graph stuff.
            print lastSample
            displayLatch=0     #This is for terminal feedback of trial flow

    except:
        dateString = datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d_%H:%M')
        if len(states)>20:
            tempLen=[len(states),len(positions),len(deltas),len(timeInStates),len(totalTime),len(trialCount),len(stimChangePositions),len(stimChangeRanges),len(clickTrainLeft),len(clickTrainRight),len(pythonTime)]
            smallestList=tempLen.index(min(tempLen))
            smallestLength=tempLen[smallestList]
            states=states[0:smallestLength]
            positions=positions[0:smallestLength]
            deltas=deltas[0:smallestLength]
            timeInStates=timeInStates[0:smallestLength]
            totalTime=totalTime[0:smallestLength]
            trialCount=trialCount[0:smallestLength]
            stimChangePositions=stimChangePositions[0:smallestLength]
            stimChangeRanges=stimChangeRanges[0:smallestLength]
            clickTrainLeft=clickTrainLeft[0:smallestLength]
            clickTrainRight=clickTrainRight[0:smallestLength]
            pythonTime=pythonTime[0:smallestLength]
            exportArray=numpy.array([states,positions,deltas,timeInStates,totalTime,trialCount,stimChangePositions,stimChangeRanges,clickTrainLeft,clickTrainRight,pythonTime])
            exportArray = exportArray[numpy.newaxis].T
            numpy.savetxt("jv16_%s_temp.csv" %dateString, exportArray, delimiter=",",fmt='%f')
            arduino.write('6')
            arduino.close()
            print ('saved your shit homes')
        elif len(states)==0:
            print('bad serial read; restart')

        exit()           


# save data
dateString = datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d_%H:%M')
exportArray=numpy.array([states,positions,deltas,timeInStates,totalTime,trialCount,stimChangePositions,stimChangeRanges,clickTrainLeft,clickTrainRight,pythonTime])
exportArray = exportArray[numpy.newaxis].T
numpy.savetxt("jv16_%s.csv" %dateString, exportArray, delimiter=",",fmt='%f')

# clean up
arduino.write('6')
arduino.close()
exit()
