function [shuffledTs]=shuffleTrialsSimp(vectorToShuf,replacementBool)

if nargin==1 || (nargin==2 && replacementBool==0) 
rng('shuffle')
for n=1:numel(vectorToShuf)
    a=randi(numel(vectorToShuf));
    shuffledTs(:,n)=vectorToShuf(a);
end

elseif nargin==2 && replacementBool==1
    rng('shuffle')
    loopCount=numel(vectorToShuf);
    n=1;
    
    while n<=loopCount
        a=randi(numel(vectorToShuf));
        shuffledTs(:,n)=vectorToShuf(a);
        vectorToShuf(a)=[];
        n=n+1;
    end       
        

    
end
    

end