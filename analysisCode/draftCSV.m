
%% Load and organize data.
[scratch.fN,scratch.pN] = uigetfile('*.csv','Select CSV file');
data=csvread([scratch.pN scratch.fN]);
dataLabels={'states','positions','deltas','timeInStates','totalTime','trialCount','stimChangePositions','stimChangeRanges','clickTrainLeft','clickTrainRight','pythonTime'};

%%
stateDeltas=diff(data(:,1));
stateDeltas(end+1)=0;


% positions
st2.positions=data(find(data(:,1)==2),2);
st3.positions=data(find(data(:,1)==3),2);
st4.positions=data(find(data(:,1)==4),2);
st5.positions=data(find(data(:,1)==5),2);

% click trains
st2.leftClicks=data(find(data(:,1)==2),9);
st3.leftClicks=data(find(data(:,1)==3),9);

% time in state, by trial
st2.trialTime=data(find(data(:,1)==2),4);
st3.trialTime=data(find(data(:,1)==3),4);

%
st2.targetPositions=data(find(data(:,1)==2),7);
st2.targetRanges=data(find(data(:,1)==2),8);
st3.targetPositions=data(find(data(:,1)==3),7);
st3.targetRanges=data(find(data(:,1)==3),8);


% breaks
st2.trialStarts=vertcat(1,find(diff(st2.trialTime)<-10)+1);
st3.trialStarts=vertcat(1,find(diff(st3.trialTime)<-10)+1);
st2.trialEnds=vertcat(find(diff(st2.trialTime)<-10),size(st2.trialTime,1));
st3.trialEnds=vertcat(find(diff(st3.trialTime)<-10),size(st3.trialTime,1));

% flatten time
st2.flatTime=sumFlat(st2.trialTime,-500);
st3.flatTime=sumFlat(st3.trialTime,-500);



%% Animal Pace Over Time
figure,hold all
subplot(2,1,1)
nhist({st2.trialTime(1:10000),st2.trialTime(10001:20000),st2.trialTime(20001:30000),st2.trialTime(30001:40000),st2.trialTime(40001:50000)},'box');
subplot(2,1,2)
plot(st2.trialTime,'k-')

%% Animal Pace Over Time
figure,hold all
subplot(2,1,1)
plot(st2.trialTime,'k-')
hold all
plot([1,numel(st2.trialTime)],[3100,3100])
subplot(2,1,2)
plot(st3.trialTime,'k-')
hold all
plot([1,numel(st3.trialTime)],[1000,1000])

%%
figure,nhist({st2.positions,st3.positions,st5.positions},'box');

%%

%allTrials=(1:100)';
st2.allTrials=(1:numel(st2.trialEnds))';
st3.allTrials=(1:numel(st3.trialEnds))';
%st2.allTrials=(90:120);
%st3.allTrials=(90:120);
%st2.allTrials=[(20:50) (80:110)];
%st3.allTrials=[(20:50) (80:110)];

st2.endPositions=st2.positions(st2.trialEnds(st2.allTrials));
st2.endTargets=st2.targetPositions(st2.trialEnds(st2.allTrials));
st2.endTargetRanges=st2.targetRanges(st2.trialEnds(st2.allTrials));

st3.endPositions=st3.positions(st3.trialEnds(st3.allTrials));
st3.endTargets=st3.targetPositions(st3.trialEnds(st3.allTrials));
st3.endTargetRanges=st3.targetRanges(st3.trialEnds(st3.allTrials));

hitTrials=find(st2.endPositions>=st2.endTargets & st2.endPositions<st2.endTargets+st2.endTargetRanges);
fauxHitTrials=find(st3.endPositions>=st3.endTargets & st3.endPositions<st3.endTargets+st3.endTargetRanges);

passThreshold=3000;
skippedTrials=find(st2.endPositions<=passThreshold);
fauxSkippedTrials=find(st3.endPositions<=passThreshold);
attemptedTrials=setdiff(st2.allTrials,skippedTrials);
fauxAttemptedTrials=setdiff(st3.allTrials,fauxSkippedTrials);

st2.hitPlot=zeros(size(st2.allTrials));
st2.hitPlot(hitTrials)=1;
st3.hitPlot=zeros(size(st3.allTrials));
st3.hitPlot(fauxHitTrials)=1;
figure,plot(smooth(st2.hitPlot,20))
hold all,plot(smooth(st3.hitPlot,20))

figure,plot(st2.endPositions)
hold all,plot([1 numel(st2.endPositions)],[passThreshold passThreshold])

st2.attemptedPlot=zeros(size(st2.allTrials));
st2.attemptedPlot(attemptedTrials)=1;
figure,plot(smooth(st2.attemptedPlot,5))
%% d-prime estimate
bProb=0.5;      
% technically the prob should be some normalized distance metric, 
% but the hypotesis is that the animal is detecting a stimulus change 
% above chance, so I think it is fair to treat the faux distribution as
% 0.5. If anything this is more conservative.

fa.attemptedCount=numel(fauxAttemptedTrials);
fa.hitCount=numel(fauxHitTrials);

fa.meanEst=(fa.attemptedCount)*0.5;
fa.sdEst=((fa.attemptedCount)*0.5)*(1-bProb);
fa.zScore=(fa.hitCount-fa.meanEst)/fa.sdEst;

ht.attemptedCount=numel(attemptedTrials);
ht.hitCount=numel(hitTrials);

ht.meanEst=(ht.attemptedCount)*0.5;
ht.sdEst=((ht.attemptedCount)*0.5)*(1-bProb);
ht.zScore=(ht.hitCount-ht.meanEst)/ht.sdEst;

bStats.dPrimeEst=ht.zScore-fa.zScore

%% plot all attempted trials
figure,hold all,
h=gcf;
plot(st2.endTargets(attemptedTrials),st2.endPositions(attemptedTrials),'ko')
plot(st3.endTargets(fauxAttemptedTrials),st3.endPositions(fauxAttemptedTrials),'bo')
a=30000;
plot(([0 1].*a)+0,([0 1].*a)+0,'k');
title(['r= ' num2str(corr(st2.endTargets(attemptedTrials),st2.endPositions(attemptedTrials))) ' ; n=' num2str(numel(fauxAttemptedTrials)) ' r= ' num2str(corr(st3.endTargets(fauxAttemptedTrials),st3.endPositions(fauxAttemptedTrials))) ' ; n=' num2str(numel(fauxAttemptedTrials))])
saveas(h,'~/Desktop/shape.png')

%% plot only hit trials and 'false alarms'

figure,hold all,
plot(st2.endTargets(hitTrials),st2.endPositions(hitTrials),'ko')
plot(st3.endTargets(fauxHitTrials),st3.endPositions(fauxHitTrials),'bo')
a=30000;
plot(([0 1].*a)+0,([0 1].*a)+0,'k');
title(['r= ' num2str(corr(st2.endTargets(hitTrials),st2.endPositions(hitTrials))) ' ; n=' num2str(numel(hitTrials)) ' r= ' num2str(corr(st3.endTargets(fauxHitTrials),st3.endPositions(fauxHitTrials))) ' ; n=' num2str(numel(fauxHitTrials))])
% saveas(h,'~/Desktop/shape3a.png')

%% look at click train with position state 2
figure,plot(st2.flatTime/1000,smooth(st2.positions,100))
hold all,plot(st2.flatTime/1000,st2.leftClicks*30000)
hold all,plot(st2.flatTime/1000,st2.targetPositions,'k:')
hold all,plot(st2.flatTime/1000,st2.targetPositions+st2.targetRanges,'k:')
hold all,plot(st2.flatTime/1000,smooth(padarray(diff(smooth(st2.positions,100)),1,'pre'),20)*500,'k-')
hold all,plot(st2.flatTime(2:end)/1000,circshift(smooth(diff(smooth(padarray(diff(smooth(st2.positions,100)),1,'pre'),20)*50000),50),50),'b-')

%% look at click train with position
figure,plot(st3.flatTime/1000,smooth(st3.positions,100))
hold all,plot(st3.flatTime/1000,st3.leftClicks*30000)
hold all,plot(st3.flatTime/1000,st3.targetPositions,'k:')
hold all,plot(st3.flatTime/1000,st3.targetPositions+st3.targetRanges,'k:')
hold all,plot(st3.flatTime/1000,smooth(padarray(diff(smooth(st3.positions,100)),1,'pre'),20)*500,'k-')
hold all,plot(st3.flatTime(2:end)/1000,circshift(smooth(diff(smooth(padarray(diff(smooth(st3.positions,100)),1,'pre'),20)*50000),50),50),'b-')
