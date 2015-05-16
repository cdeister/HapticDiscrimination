% Parse Behavior

%% flatten epochs

% The data is acquired in chunks for sanity/saftey sake. Each epoch is an
% entry in the cell arrays within "data."


% first make a flat time vector.
flatData.time=flattenData(data.totalTime,1);
flatData.states=flattenData(data.states);
flatData.positions=flattenData(data.positions);
flatData.stimChangePositions=flattenData(data.stimChangePositions);
flatData.stimChangeRanges=flattenData(data.stimChangeRanges);
flatData.leftVal=flattenData(data.leftExpectedVal);
flatData.rightVal=flattenData(data.rightExpectedVal);
flatData.stimDiff=flatData.leftVal-flatData.rightVal;

stimCalA=(900/25.4); % 900 points/inch * 1/25.4 inch/mm

%% if you want to fish out by state


state_2.time=flattenData(filterDataByState(data.timeInStates,data.states,2),0);
state_2.positions=flattenData(filterDataByState(data.positions,data.states,2),0);
% now this will have a bunch of resets to zero.
timeResets=diff(state_2.time);  % These predict the reset by 1 sample of course, but we need this time.
resetPositions=find(timeResets<0); % As a sanity check, these should equal the total number of trials minus 1.


state_2.time_byTrial{1}=state_2.time(1:resetPositions(1))';
for n=1:numel(resetPositions)-1
    state_2.time_byTrial{n+1}=state_2.time(resetPositions(n)+1:resetPositions(n+1))';
end
state_2.time_byTrial{numel(resetPositions)+1}=state_2.time(resetPositions(end)+1:end)';
state_2.flatTime=flattenData(state_2.time_byTrial,1);


state_2.positions=(flattenData(filterDataByState(data.positions,data.states,2),0));
state_2.positions_byTrial{1}=state_2.positions(1:resetPositions(1))';
for n=1:numel(resetPositions)-1
    state_2.positions_byTrial{n+1}=state_2.positions(resetPositions(n)+1:resetPositions(n+1))';
end
state_2.positions_byTrial{numel(resetPositions)+1}=state_2.positions(resetPositions(end)+1:end)';

state_2.stimChangePositions=flattenData(filterDataByState(data.stimChangePositions,data.states,2),0);
state_2.stimChangePositions_byTrial{1}=state_2.stimChangePositions(1:resetPositions(1))';
for n=1:numel(resetPositions)-1
    state_2.stimChangePositions_byTrial{n+1}=state_2.stimChangePositions(resetPositions(n)+1:resetPositions(n+1))';
end
state_2.stimChangePositions_byTrial{numel(resetPositions)+1}=state_2.stimChangePositions(resetPositions(end)+1:end)';

state_2.stimChangeRanges=flattenData(filterDataByState(data.stimChangeRanges,data.states,2),0);
state_2.stimChangeRanges_byTrial{1}=state_2.stimChangeRanges(1:resetPositions(1))';
for n=1:numel(resetPositions)-1
    state_2.stimChangeRanges_byTrial{n+1}=state_2.stimChangeRanges(resetPositions(n)+1:resetPositions(n+1))';
end
state_2.stimChangeRanges_byTrial{numel(resetPositions)+1}=state_2.stimChangeRanges(resetPositions(end)+1:end)';

state_2.stimDiff=flatData.stimDiff(find(flatData.states==2));
state_2.stimDiff_byTrial{1}=state_2.stimDiff(1:resetPositions(1))';
for n=1:numel(resetPositions)-1
    state_2.stimDiff_byTrial{n+1}=state_2.stimDiff(resetPositions(n)+1:resetPositions(n+1))';
end
state_2.stimDiff_byTrial{numel(resetPositions)+1}=state_2.stimDiff(resetPositions(end)+1:end)';
trialCount=numel(resetPositions)+1;
%% Look at a trial
n=1; figure,plot(state_2.positions_byTrial{n})
hold all,plot(smooth(diff(smooth(state_2.positions_byTrial{n}))*1000,50))
hold all,plot(state_2.stimChangePositions_byTrial{n},'k:')
hold all,plot(state_2.stimChangePositions_byTrial{n}+state_2.stimChangeRanges_byTrial{n},'k:')

%% Get HM etc.


% get all hits
for n=1:trialCount;
    state2_lastPosition(:,n)=state_2.positions_byTrial{n}(end);
    state2_switchPosition(:,n)=state_2.stimChangePositions_byTrial{n}(end);
    state2_switchEnd(:,n)=state_2.stimChangeRanges_byTrial{n}(end);
    state2_hits(:,n)=ismember(state_2.positions_byTrial{n}(end),(state_2.stimChangePositions_byTrial{n}(end):state_2.stimChangePositions_byTrial{n}(end)+state_2.stimChangeRanges_byTrial{n}(end)));
    state2_stimDiff(:,n)=state_2.stimDiff_byTrial{n}(end);

end
figure,plot(state2_hits)
hold all,plot(smooth(state2_hits,10))
hh=gcf;
ylabel('hit/miss')
xlabel('trial number')
saveas(hh,'~/Desktop/engagment.png');
legend('actual','smoothed')

movThresh=1000;

% are hits/misses biased to a distance?
figure,nhist({state2_lastPosition(state2_hits(find(state2_lastPosition>movThresh))),state2_lastPosition(find(state2_hits(find(state2_lastPosition>movThresh))==0))},'box')
figure,nhist({state2_lastPosition(state2_hits(find(state2_lastPosition>movThresh & state2_stimDiff<0))),state2_lastPosition(find(state2_hits(find(state2_lastPosition>movThresh & state2_stimDiff<0))==0))},'box')
figure,nhist({state2_lastPosition(state2_hits(find(state2_lastPosition>movThresh & state2_stimDiff>0))),state2_lastPosition(find(state2_hits(find(state2_lastPosition>movThresh & state2_stimDiff>0))==0))},'box')
figure,nhist({state2_lastPosition(state2_hits(find(state2_lastPosition>movThresh & state2_stimDiff<0))),state2_lastPosition(find(state2_hits(find(state2_lastPosition>movThresh & state2_stimDiff<0))==0)),state2_lastPosition(state2_hits(find(state2_lastPosition>movThresh & state2_stimDiff>0))),state2_lastPosition(find(state2_hits(find(state2_lastPosition>movThresh & state2_stimDiff>0))==0))},'box')
legend('left hit','left miss','right hit','right miss')

lH=state2_lastPosition(find(state2_hits(find(state2_lastPosition>movThresh & state2_stimDiff>0))==0));
rH=state2_lastPosition(find(state2_hits(find(state2_lastPosition>movThresh & state2_stimDiff<0))==0));
% [cis,H,bsDist,pValEst]=bootstrapDif(lH,rH,1000,1)

%% 'psychometrics'
psyDelta=2000;
movThresh=2000;
trialBounds=[1:200];
hits1{1}=find(state2_lastPosition(trialBounds)>movThresh & state2_switchPosition(trialBounds)<=movThresh+psyDelta & state2_hits(trialBounds)==1);
miss1{1}=find(state2_lastPosition(trialBounds)>movThresh & state2_switchPosition(trialBounds)<=movThresh+psyDelta & state2_hits(trialBounds)==0);
for n=2:12
    hits1{n}=find(state2_switchPosition(trialBounds)>movThresh+(psyDelta*(n-1)) & state2_switchPosition(trialBounds)<=movThresh+(psyDelta*(n)) & state2_hits(trialBounds)==1);
    miss1{n}=find(state2_switchPosition(trialBounds)>movThresh+(psyDelta*(n-1)) & state2_switchPosition(trialBounds)<=movThresh+(psyDelta*(n)) & state2_hits(trialBounds)==0);
end

for n=1:12
    hitRate(:,n)=numel(hits1{n})/(numel(hits1{n})+numel(miss1{n}));
end
figure,plot([10000:10000:10000*12]./stimCalA,hitRate)
hh=gcf;
ylabel('hit rate')
xlabel('switch position in mm')
saveas(hh,'~/Desktop/psycho.png');


%% 
clear state_2.thresholdAlignedPositions{n}
for n=1:numel(state_2.positions_byTrial)
    state_2.endTriggerChangePositions(:,n)=state_2.stimChangePositions_byTrial{n}(end);
    state_2.endTriggerPositions(:,n)=state_2.positions_byTrial{n}(end);
    state_2.endTriggerStimDif(:,n)=state_2.stimDiff_byTrial{n}(end);
end
figure;
h=gcf;
clf; hold on;
plot(state_2.endTriggerChangePositions,state_2.endTriggerPositions,'ko')
a=90000;
plot(([0 1].*a)+0,([0 1].*a)+0,'k');
ylabel('end position in points')
xlabel('stim switch position in points')
daspect([1 1 1]);
saveas(h,'~/Desktop/shape2a.png')

%%
figure;
h2=gcf;
clf; hold on;
plot(state_2.endTriggerChangePositions(state2_hits),state_2.endTriggerPositions(state2_hits),'ko')
a=90000;
plot(([0 1].*a)+0,([0 1].*a)+0,'k');
ylabel('end position in points')
xlabel('stim switch position in points')
daspect([1 1 1]);
figure,plot(state_2.endTriggerChangePositions(state2_hits==0),state_2.endTriggerPositions(state2_hits==0),'ko')
% saveas(h2,'~/Desktop/shape2a.png')
corr(state_2.endTriggerChangePositions(state2_hits)',state_2.endTriggerPositions(state2_hits)')

%% Get misses, and types.


%% 
figure,hold all
for n=1:numel(find(derivCrossings>0))
    plot(state_2.thresholdAlignedPositions{n})
end

%% Look at what happens just before each stop.

for n=1:numel(state_2.positions_byTrial)
    state_2.endTriggerPositions(:,n)=state_2.positions_byTrial{n}(end-10:end);
    state_2.endTriggerChangePositions(:,n)=state_2.stimChangePositions_byTrial{n}(end-10:end);
end

%%
hits=state_2.endTriggerPositions(end,:)>=state_2.endTriggerChangePositions(end,:);
misses=abs(1-hits);
hitRate=numel(find(hits==1))/numel(hits);

%% get length of each trial
for n=1:numel(state_2.time_byTrial)
state_2.trialLengths(:,n)=state_2.time_byTrial{n}(end);
end
state_2.attemptedTrials=find(state_2.trialLengths>5000);
filteredHits=state_2.endTriggerPositions(end,state_2.trialLengths>5000)>=state_2.endTriggerChangePositions(end,state_2.trialLengths>5000);
attemtptedHits=state_2.attemptedTrials(filteredHits==1);
attemtptedMisses=state_2.attemptedTrials(filteredHits==0);

figure,nhist(flatData.stimDiff(attemtptedHits))

%%
n=attemtptedMisses(7);
figure,plot(state_2.endTriggerPositions(:,n))
hold all,plot(state_2.endTriggerChangePositions(:,n))
hold all,plot(smooth(diff(smooth(state_2.endTriggerPositions(:,n),10))*500))
hold all,plot(smooth(diff(smooth(diff(smooth(state_2.endTriggerPositions(:,n),10)),10))*10000))


%%

for n=1:numel(attemtptedHits)
    state_2.endTriggerPositionsAtHits(:,n)=state_2.positions_byTrial{attemtptedHits(n)}(end-1000:end);
    state_2.endTriggerChangePositionsAtHits(:,n)=state_2.stimChangePositions_byTrial{attemtptedHits(n)}(end-1000:end);
end

for n=1:numel(attemtptedMisses)
    state_2.endTriggerPositionsAtMisses(:,n)=state_2.positions_byTrial{attemtptedMisses(n)}(end-1000:end);
    state_2.endTriggerChangePositionsAtMisses(:,n)=state_2.stimChangePositions_byTrial{attemtptedMisses(n)}(end-1000:end);
end