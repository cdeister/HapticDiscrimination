% Simple arduino control and readout to support discrimination task.
%
% Last Update: 5/6/2015 (CAD)
% Serial com mostly from robot grrl tutorial: http://robotgrrl.com/blog/2010/01/15/arduino-to-matlab-read-in-sensor-data/

exportPath='~/Desktop/';
startTimeLog=fix(clock);
saveName=['cad_' date '_' num2str(startTimeLog(4)) ':' num2str(startTimeLog(5))];
clear startTimeLog

for k=1:5
%% clear data
clearvars -except k data exportPath saveName startTimeLog
close all
numTrials=1;
sensorCal= 900/25.4;  % in mm
toPlot=1;
p_fps=20; % doesn't keep up below 5, but loop is still good.
invert=0;
yRange=[-500,6500];
bufferSize=199;  %499 for debug mouse, 199 for production


%%
clc;
numSec=300;
states=[];
positions=[];
deltas=[];
timeInStates=[];
totalTime=[];
trialCount=[];
stimChangePositions=[];
stimChangeRanges=[];
clickTrainLeft=[];
clickTrainRight=[];
d(1:(bufferSize-1))=100;  % KLUDGE: This is just to make sure we initialize the running condition.

%% behavior variables
trialStartGrace=4000;  % in ms
minWaitStopTime=500;  % in ms
stopThreshold=6;
targetPos=60000;
targetRange=60000;
stimChangePositions(1)=targetPos;
stimChangeRanges(1)=targetRange;

%%
s1 = serial('/dev/cu.usbmodem1421');    % define serial port
s1.BaudRate=115200;       % define baud rate
set(s1, 'terminator', 'LF');    % define the terminator for println
fopen(s1);

%%

% try 
                         
w=fscanf(s1,'%s');   % signal the arduino to start collection           
pause(0.5) % <-- There is some lag in getting serial up and running on arduino end.

fprintf(s1,'%u',1);  % 1 is 49 in ascii

currentState=1;
n=0;
totalTime(1)=0;
behaviorState=2;
tCnt=1;

% --- set up plot
figure(998)
aPL = animatedline('Color',[0.1 0.1 0.1]);
aSL=animatedline('Color',[0.8 0 0]);
aSP=animatedline('Color',[0.8 0 0.6]);
aSR=animatedline('Color',[0.8 0.5 0.6]);

axis([0,numSec*1000,yRange(1),yRange(2)])
legend('pos.','state','stim change','choice boundary')

% --- main block

while ((totalTime/1000)<numSec)    
    switch(currentState)
        case 1
            n=n+1;
            states(n)=fscanf(s1,'%d');
            positions(n)=fscanf(s1,'%d');       
            deltas(n)=fscanf(s1,'%f');       
            timeInStates(n)=fscanf(s1,'%f');
            totalTime(n)=fscanf(s1,'%f');
            trialCount=fscanf(s1,'%d');
            stimChangePositions(n)=fscanf(s1,'%d');
            stimChangeRanges(n)=fscanf(s1,'%d');
            clickTrainLeft(n)=fscanf(s1,'%d');
            clickTrainRight(n)=fscanf(s1,'%d');
            leftExpectedVal(n)=fscanf(s1,'%d');
            rightExpectedVal(n)=fscanf(s1,'%d');
            currentState=states(n);
        case 2
            n=n+1;
            states(n)=fscanf(s1,'%d');
            positions(n)=fscanf(s1,'%d');       
            deltas(n)=fscanf(s1,'%f');       
            timeInStates(n)=fscanf(s1,'%f');
            totalTime(n)=fscanf(s1,'%f');
            trialCount=fscanf(s1,'%d');
            stimChangePositions(n)=fscanf(s1,'%d');
            stimChangeRanges(n)=fscanf(s1,'%d');
            clickTrainLeft(n)=fscanf(s1,'%d');
            clickTrainRight(n)=fscanf(s1,'%d');
            leftExpectedVal(n)=fscanf(s1,'%d');
            rightExpectedVal(n)=fscanf(s1,'%d');
            stimDif=leftExpectedVal(n)-rightExpectedVal(n);
            currentState=states(n);
            if timeInStates(n)>trialStartGrace && mean(abs(deltas(end-(bufferSize-1):end)))<stopThreshold
                if stimDif==0
                    if (positions(n)>=stimChangePositions(end) && positions(n)<=stimChangePositions(end)+stimChangeRanges(end))
                        behaviorState=0;
                        fprintf(s1,'%u',5);
                    else
                        behaviorState=0;
                        fprintf(s1,'%u',3);
                    end
                elseif stimDif~=0
                    if (positions(n)>=stimChangePositions(end) && positions(n)<=stimChangePositions(end)+stimChangeRanges(end))
                        behaviorState=1;
                        fprintf(s1,'%u',4);
                    elseif (positions(n)>stimChangePositions(end)+stimChangeRanges(end)) % if animal runs past switch for too long miss + time out
                        behaviorState=0;
                        fprintf(s1,'%u',5);
                    else                                                        % if animal doesn't run, or too little, just start anew
                        behaviorState=0;
                        fprintf(s1,'%u',3);
                    end
                end
            else
            end
        case 3
            n=n+1;
            states(n)=fscanf(s1,'%d');
            positions(n)=fscanf(s1,'%d');       
            deltas(n)=fscanf(s1,'%f');       
            timeInStates(n)=fscanf(s1,'%f');
            totalTime(n)=fscanf(s1,'%f');
            trialCount=fscanf(s1,'%d');
            stimChangePositions(n)=fscanf(s1,'%d');
            stimChangeRanges(n)=fscanf(s1,'%d');
            clickTrainLeft(n)=fscanf(s1,'%d');
            clickTrainRight(n)=fscanf(s1,'%d');
            leftExpectedVal(n)=fscanf(s1,'%d');
            rightExpectedVal(n)=fscanf(s1,'%d');
            currentState=states(n);
            if timeInStates(n)>minWaitStopTime && mean(abs(deltas(end-(bufferSize-1):end)))<stopThreshold
                fprintf(s1,'%u',2);
            else
            end
        case 4
            n=n+1;
            states(n)=fscanf(s1,'%d');
            positions(n)=fscanf(s1,'%d');       
            deltas(n)=fscanf(s1,'%f');       
            timeInStates(n)=fscanf(s1,'%f');
            totalTime(n)=fscanf(s1,'%f');
            trialCount=fscanf(s1,'%d');
            stimChangePositions(n)=fscanf(s1,'%d');
            stimChangeRanges(n)=fscanf(s1,'%d');
            clickTrainLeft(n)=fscanf(s1,'%d');
            clickTrainRight(n)=fscanf(s1,'%d');
            leftExpectedVal(n)=fscanf(s1,'%d');
            rightExpectedVal(n)=fscanf(s1,'%d');
            currentState=states(n);
         case 5
            n=n+1;
            states(n)=fscanf(s1,'%d');
            positions(n)=fscanf(s1,'%d');       
            deltas(n)=fscanf(s1,'%f');       
            timeInStates(n)=fscanf(s1,'%f');
            totalTime(n)=fscanf(s1,'%f');
            trialCount=fscanf(s1,'%d');
            stimChangePositions(n)=fscanf(s1,'%d');
            stimChangeRanges(n)=fscanf(s1,'%d');
            clickTrainLeft(n)=fscanf(s1,'%d');
            clickTrainRight(n)=fscanf(s1,'%d');
            leftExpectedVal(n)=fscanf(s1,'%d');
            rightExpectedVal(n)=fscanf(s1,'%d');
            currentState=states(n);
    end
    if mod(n,p_fps)==0
        addpoints(aPL,totalTime(n),positions(n)./sensorCal);
        addpoints(aSL,totalTime(n),states(n));
        addpoints(aSP,totalTime(n),stimChangePositions(n)./sensorCal);
        addpoints(aSR,totalTime(n),(stimChangePositions(n)+stimChangeRanges(n))./sensorCal);
        drawnow
        switch(behaviorState)
            case 2
                title(['trial# ' num2str(trialCount(end)) ' & state ' num2str(states(n)) ' left EV= ' num2str(leftExpectedVal(end)) ' right EV= ' num2str(rightExpectedVal(end))])
            case 1
                title(['trial# ' num2str(trialCount(end)) ' & state ' num2str(states(n)) ' \color[rgb]{0 .5 .2}last trial = hit' ' \color[rgb]{0 0 0}left EV= ' num2str(leftExpectedVal(end)) ' right EV= ' num2str(rightExpectedVal(end))])
            case 0
                title(['trial# ' num2str(trialCount(end)) ' & state ' num2str(states(n)) ' \color{red}last trial = miss' ' \color[rgb]{0 0 0}left EV= ' num2str(leftExpectedVal(end)) ' right EV= ' num2str(rightExpectedVal(end))])
        end
        
    else
    end
end
    


fprintf(s1,'%u',6);  % Pause State (no serial)
fclose(s1);

% catch exception
%     fclose(s1);                 
%     throw (exception);
% end

data.states{k}=states;
data.positions{k}=positions;
data.deltas{k}=deltas;
data.timeInStates{k}=timeInStates;
data.totalTime{k}=totalTime;
data.trialCount{k}=trialCount;
data.stimChangePositions{k}=stimChangePositions;
data.stimChangeRanges{k}=stimChangeRanges;
data.clickTrainLeft{k}=clickTrainLeft;
data.clickTrainRight{k}=clickTrainRight;
data.leftExpectedVal{k}=leftExpectedVal;
data.rightExpectedVal{k}=rightExpectedVal;
end

%% save data
tic
save([exportPath saveName],'data','-v7.3')
toc

    

