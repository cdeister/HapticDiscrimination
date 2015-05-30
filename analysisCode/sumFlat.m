function out=sumFlat(inputVector,threshold)

vectorDiffs=diff(inputVector);
resetPositions=find(vectorDiffs<=threshold);


for n=1:numel(resetPositions)-1
    inputVector(resetPositions(n)+1:resetPositions(n+1))=inputVector(resetPositions(n)+1:resetPositions(n+1))+inputVector(resetPositions(n));
end
inputVector(resetPositions(end)+1:end)=inputVector(resetPositions(end)+1:end)+inputVector(resetPositions(end));

out=inputVector;
end