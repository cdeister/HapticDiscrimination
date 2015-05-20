%%
dataLabels={'states','positions','deltas','timeInStates','totalTime','trialCount','stimChangePositions','stimChangeRanges','clickTrainLeft','clickTrainRight','pythonTime'};

%%
targetPositions=data(find(data(:,1)==2),7);
stateDeltas=diff(data(:,1));
stateDeltas(end+1,1)=0;
st2_stateDeltas=stateDeltas(find(data(:,1)==2));
st2_trialBreaks=find(st2_stateDeltas~=0);
st3_stateDeltas=stateDeltas(find(data(:,1)==3));
st3_trialBreaks=find(st3_stateDeltas~=0);
st2_positions=data(find(data(:,1)==2),2);
st3_positions=data(find(data(:,1)==3),2);
st4_positions=data(find(data(:,1)==4),2);
st5_positions=data(find(data(:,1)==5),2);

%%
figure,nhist({st2_positions,st3_positions,st5_positions},'box')

%%
figure,plot(targetPositions(st2_trialBreaks),st2_positions(st2_trialBreaks),'ko')
hold all,plot(targetPositions(st3_trialBreaks),st3_positions(st3_trialBreaks),'ro')
corr(targetPositions(st2_trialBreaks),st2_positions(st2_trialBreaks-1))
corr(targetPositions(st3_trialBreaks),st3_positions(st3_trialBreaks-1))

figure,nhist({st2_positions(st2_trialBreaks-1),st3_positions(st3_trialBreaks-1)},'box')