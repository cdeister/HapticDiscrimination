function out=filterDataByState(cellData,cellStateData,State)

for n=1:numel(cellData)
    out{n}=cellData{n}(cellStateData{n}==State);
end

end