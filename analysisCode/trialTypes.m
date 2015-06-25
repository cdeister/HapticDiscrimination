% loop through trials
for n=1:numel(attemptedTrials)
    tTrialStarts=st2.trialStarts(attemptedTrials(n));
    tTrialEnds=st2.trialEnds(attemptedTrials(n));
    tTrialPos=st2.positions(tTrialStarts:tTrialEnds);
    tTrialTargets=st2.targetPositions(attemptedTrials(n));
    % find the time in which the animal crossed so we only look before

    tPosCross=find(tTrialPos>tTrialTargets);
    if numel(tPosCross)>0
        tCutPos=tPosCross(1);
    elseif numel(tPosCross)==0
        tCutPos=tTrialPos(end);
    end
    sC(n)=mean(st2.leftClicks(tTrialStarts:tTrialStarts+tCutPos));
    
    
end