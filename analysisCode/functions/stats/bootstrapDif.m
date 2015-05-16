function [cis,H,bsDist,pValEst]=bootstrapDif(d1,d2,reps,toPlot,alphaV,moment)

% d1 and d2 are the distributions you are comparing
% reps is the number of times to resample
% toPlot (optional) is whether you want a graph
% alpha (optional) is your alpha criterion
% moment (optional) is which type of distribution feature you want to test:
% 1 = mean, 2=median

if nargin<4
    toPlot=0;
end

if nargin<5
    alphaV=0.05;
else
end

if nargin<6
    moment=1;
else
end

tic

parfor n=1:reps
    a=shuffleTrialsSimp(1:numel(d1));
    b=shuffleTrialsSimp(1:numel(d2));
    if moment==2
        bsDist(:,n)=median(d1(a))-median(d2(b));
    elseif moment==1
        bsDist(:,n)=mean(d1(a))-mean(d2(b));
    else
        disp('not sure what you want to compare')
    end
end

bsTime=toc;
disp('#$#$#$#$ your are strapped #$#$#$#$')



alphaV=0.05;
cis=prctile(bsDist,[100*alphaV/2,100*(1-alphaV/2)]);

if toPlot
figure,nhist(bsDist,'box')
hold all,plot([cis(1) cis(1)],[0 100],'k:')
hold all,plot([cis(2) cis(2)],[0 100],'k:')
else
end

H = cis(1)>0 | cis(2)<0;

%estimate p-value

fCI=cis(2)-cis(1);
SE=fCI/(2*1.96);
zS=abs(mean(bsDist))/SE;
pValEst=exp((-0.717*zS)-(0.416*(zS^2)));

disp('*** stats ***')
mean(bsDist)
std(bsDist)
cis(2)-cis(1)

pValEst
disp('*** end stats ***')


end