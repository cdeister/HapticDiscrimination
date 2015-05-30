%%
options = statset('UseParallel',true);
if parpool('size')==0
    parpool open
else
end

%%

clear B


origTrain=st2.leftClickTrain(1:50000,1);
B = TreeBagger(50,origTrain,smooth(st2.positions(1:50000,1),20));
%%
z=B.predict(origTrain);
decodeTrain=str2num(cell2mat(z));
%%
figure,plot(decodeTrain)
hold all,plot(origTrain)

corr(decodeTrain,origTrain)

%%
evClass=TreeBagger(34,bag.fullEventTrainSetE, bag.flatVariablesT(:,variableI),...
    'method','r','oobpred','on','oobvarimp', 'on','minleaf',20,'Options',options);
% consider'oobpred','on'


[evPred evPredSD]=evClass.predict(repmat(bag.flatResponsesEventsP,1,lag));