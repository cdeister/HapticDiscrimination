%%
clear clips clipS clipT
breakPos=find(diff(s)>0.5);
for n=1:numel(breakPos)-2
    clipS(:,n)=s(breakPos(n)-10:breakPos(n)+2000);
    clipT(:,n)=tT(breakPos(n)-10:breakPos(n)+2000)-tT(breakPos(n));
end
