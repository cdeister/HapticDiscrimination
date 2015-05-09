function out=flattenData(cellData,addLast)

% This flattens a cell array. You can opptionally add the last values to
% each, which is helpful for a cummulative time vector.

if nargin==2
    if addLast==1
        out(:,1)=cellData{1};
        for n=2:numel(cellData)
            dataToAdd=cellData{n}+out(end);
            out=vertcat(out,dataToAdd');
        end
    elseif addLast==0
        out(:,1)=cellData{1};
        for n=2:numel(cellData)
            dataToAdd=cellData{n};
            out=vertcat(out,dataToAdd');
        end   
    end
elseif nargin==1
    out(:,1)=cellData{1};
    for n=2:numel(cellData)
        dataToAdd=cellData{n};
        out=vertcat(out,dataToAdd');
    end    

end

end