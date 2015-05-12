% Parse Behavior

%% flatten epochs

% The data is acquired in chunks for sanity/saftey sake. Each epoch is an
% entry in the cell arrays within "data."


% first make a flat time vector.
flatData.time=flattenData(data.totalTime,1);
flatData.states=flattenData(data.states);
flatData.positions=flattenData(data.positions);
flatData.stimChangePositions=flattenData(data.stimChangePositions);
flatData.leftVal=flattenData(data.leftExpectedVal);
flatData.rightVal=flattenData(data.rightExpectedVal);
flatData.stimDiff=abs(flatData.leftVal-flatData.rightVal);

stimCalA=(9000/25.4); % 9000 d/i * 1/25.4 in/mm

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


state_2.positions=smooth(flattenData(filterDataByState(data.positions,data.states,2),0));
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

%% deriv trigger
clear derivCrossings dCrossPos
derivThresh=700;
for n=1:numel(state_2.positions_byTrial)
    dCrossPos=find(state_2.positions_byTrial{n}>=derivThresh);
   if numel(dCrossPos)>0
    derivCrossings(:,n)=dCrossPos(1);
   else
    derivCrossings(:,n)=0;
   end
end

%% 
clear state_2.thresholdAlignedPositions{n}
attemptedCrosses=derivCrossings(find(derivCrossings>10));
for n=1:numel(state_2.positions_byTrial)
    state_2.endTriggerChangePositions(:,n)=state_2.stimChangePositions_byTrial{n}(end);
    state_2.endTriggerPositions(:,n)=state_2.positions_byTrial{n}(end);
end
figure(876);
h=gcf;
clf; hold on;
plot(state_2.endTriggerChangePositions./stimCalA,state_2.endTriggerPositions./stimCalA,'ko')
a=200;
plot([0 1].*a,[0 1].*a,'k');
ylabel('end position in mm')
xlabel('stim switch position in mm')
daspect([1 1 1]);
saveas(h,'~/Desktop/shape1.png')

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