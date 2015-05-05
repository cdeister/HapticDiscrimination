%%
pH=find(abs(diff(data.cP{3}(data.s{3}==2)))>2);
pFA=find(abs(diff(data.cP{3}(data.s{3}==3)))>2);

%%
cP2=data.cP{3}(data.s{3}==2);
cP3=data.cP{3}(data.s{3}==3);

p2=data.p{3}(data.s{3}==2);
p3=data.p{3}(data.s{3}==3);

for n=1:numel(pH)-1
    cP2_vals(n)=cP2(pH(n));
    p2_vals(n)=p2(pH(n+1)-1);
    if p2_vals(n)>cP2_vals(n)
        p2_H(n)=1;
    elseif p2_vals(n)<cP2_vals(n)
        p2_H(n)=0;
    end
    
end

for n=1:numel(pFA)-1
    cP3_vals(n)=cP3(pFA(n));
    p3_vals(n)=p3(pFA(n+1)-1);
    if p3_vals(n)>cP3_vals(n)
        p3_H(n)=1;
    elseif p3_vals(n)<cP3_vals(n)
        p3_H(n)=0;
    end
    
end



%%
numel(find(p2_H==1))/numel(p2_H)
numel(find(p3_H==1))/numel(p3_H)