%% Make Training and Prediction Sets
clear('stimTrainsT','stimTrainsP','bag','fullEventTrainSetE','fullEventTrainSetD')

% Narow your focus if you like.
twindow=[1,200];

% populate trial types you might deal with.
catchTrials=find(trialFilter.rejectTrials==1 | trialFilter.rejectTrials==0);
runTrials=find(max(trials.stSpeeds_rs)>0);
hitTrials=find(trialFilter.hitTrials==1);
missTrials=find(trialFilter.hitTrials==0);

% Subsample Trials
trialTypeSS=hitTrials;
trialsToSample=trialTypeSS;
trainRatio=0.8;
trainCount=fix(numel(trialsToSample)*0.8);

for k=1:fix(1/(1-trainRatio))
    rng('shuffle')
    for n=1:numel(trainCount)
        prm=randi(numel(trialsToSample));
        trainingTrials(n,k)=prm;
        trialsToSample(prm)=[];
    end
    predictionTrials(:,k)=setdiff(trialTypeSS,)




% Determine which trials should make your training set and predict set.
trainTrialType=hitTrials;
predTrialType=hitTrials;

% Make Training Set
dfsT=trials.stDfs(twindow(1):twindow(2),trainTrialType,:);
evT=trials.stEvents(twindow(1):twindow(2),trainTrialType,:);
lkT=trials.lickRasters_rs(twindow(1):twindow(2),trainTrialType);
spT=trials.stSpeeds_rs(twindow(1):twindow(2),trainTrialType);

% Timing stuff
sampI=timingParams.twoPTrialTime_rsInterval;
origR=10000;

% Reconstruct and downsample the stimulus.
for n=1:numel(trainTrialType),
    stimTrainsT(:,n)=downsample(smooth(pulser_whale(-1*trialFilter.stimAmps(trainTrialType(n)),...
        .006,.02,10,20,0.5,0,1,1,10000,2+sampI),origR*sampI),origR*sampI);
end

stimTrainsT=stimTrainsT(twindow(1):twindow(2),:);

bag.flatResponsesT=reshape(dfsT,size(dfsT,1)*size(dfsT,2),size(dfsT,3));
bag.flatResponsesEventsT=reshape(evT,size(dfsT,1)*size(dfsT,2),size(dfsT,3));
bag.flatVariablesT(:,1)=reshape(lkT,numel(lkT),1);
bag.flatVariablesT(:,2)=reshape(spT,numel(spT),1);
bag.flatVariablesT(:,3)=reshape(stimTrainsT,numel(stimTrainsT),1);

sampsPerTrial=size(bag.flatVariablesT,1)/numel(trainTrialType);

clear('dfsT','lkT','spT','evT')

% Make Time Shifted Cell Set
lag=1;
for n=1:lag
    fullEventTrainSetE(:,:,n)=bag.flatResponsesEventsT((lag+1)-(n-1):end-(n-1),:);
    fullEventTrainSetD(:,:,n)=bag.flatResponsesT((lag+1)-(n-1):end-(n-1),:);
end
bag.fullEventTrainSetE=reshape(fullEventTrainSetE,size(fullEventTrainSetE,1),size(fullEventTrainSetE,2)*size(fullEventTrainSetE,3));
bag.fullEventTrainSetD=reshape(fullEventTrainSetD,size(fullEventTrainSetD,1),size(fullEventTrainSetD,2)*size(fullEventTrainSetD,3));
clear('fullEventTrainSetE','fullEventTrainSetD')

% Trim everything else
bag.flatVariablesT=bag.flatVariablesT(lag+1:end,:);


% Make Prediction Set
dfsP=trials.stDfs(twindow(1):twindow(2),predTrialType,:);
evP=trials.stEvents(twindow(1):twindow(2),predTrialType,:);
lkP=trials.lickRasters_rs(twindow(1):twindow(2),predTrialType);
spP=trials.stSpeeds_rs(twindow(1):twindow(2),predTrialType);

% Timing stuff
sampI=timingParams.twoPTrialTime_rsInterval;
origR=10000;

% Reconstruct and downsample the stimulus.
for n=1:numel(predTrialType),
    stimTrainsP(:,n)=downsample(smooth(pulser_whale(-1*trialFilter.stimAmps(predTrialType(n)),...
        .006,.02,10,20,0.5,0,1,1,10000,2+sampI),origR*sampI),origR*sampI);
end

stimTrainsP=stimTrainsP(twindow(1):twindow(2),:);

bag.flatResponsesP=reshape(dfsP,size(dfsP,1)*size(dfsP,2),size(dfsP,3));
bag.flatResponsesEventsP=reshape(evP,size(dfsP,1)*size(dfsP,2),size(dfsP,3));
bag.flatVariablesP(:,1)=smooth(reshape(lkP,numel(lkP),1),100);
bag.flatVariablesP(:,2)=smooth(reshape(spP,numel(spP),1),100);
bag.flatVariablesP(:,3)=smooth(reshape(stimTrainsP,numel(stimTrainsP),1),5);

% Trim everything else
% bag.flatVariablesP=bag.flatVariablesP(lag+1:end,:);
% bag.flatResponsesEventsP=bag.flatResponsesEventsP(lag+1:end,:);

clear('dfsP','lkP','spP','evP')

%% Bag

% Enable Parralelization
options = statset('UseParallel',true);
if matlabpool('size')==0
    matlabpool open
else
end

% cellsToFocus=17;
% cellsToFocus=1:size(ndata.dfs,2);

variableI=3;

% Train the classifier
evClass=TreeBagger(34,bag.fullEventTrainSetE, bag.flatVariablesT(:,variableI),...
    'method','r','oobpred','on','oobvarimp', 'on','minleaf',20,'Options',options);
% consider'oobpred','on'


[evPred evPredSD]=evClass.predict(repmat(bag.flatResponsesEventsP,1,lag));

figure,plot(smooth(evPred,100))
hold all
plot(bag.flatVariablesP(:,variableI))
title(['trained on hits predicting running in misses prediction/data r2=',num2str(corr(evPred,bag.flatVariablesP(:,variableI))^2)])

