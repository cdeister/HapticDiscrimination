%%
clicks=[330,3267,5287,7444,9486];
clicksVid=[1535,7188,11044,15160,19035];
% if they line up your ok

%% get frame rate
for n=2:numel(clicks)
    fr(:,n-1)=(clicksVid(n)-clicksVid(n-1))/((data(clicks(n),5)-data(clicks(n-1),5))/1000);
end
frameRateEst=mean(fr);
frameTime=1/frameRateEst;

%% plot some camera data with a time vector
camSamples=60000-(clicksVid(1)-1);
camTime=0:frameTime:frameTime*(camSamples-1);
camTime=camTime';

%%
figure,plot(camTime+4,(w1(clicksVid(1):end)-w2(clicksVid(1):end))*1000)
hold all,plot(data(:,5)/1000,data(:,2))

%%
figure,plot(camTime+4,((p1(clicksVid(1):end)-p2(clicksVid(1):end))*1000)-mean((p1(clicksVid(1):end)-p2(clicksVid(1):end))*1000))
hold all,plot(data(:,5)/1000,data(:,2))

%%
figure,plot(camTime+4,((p1(clicksVid(1):end)-p2(clicksVid(1):end)))-mean((p1(clicksVid(1):end)-p2(clicksVid(1):end))))
hold all,plot(data(:,5)/1000,data(:,1))

%%
figure,plot(camTime+4,(folicle(clicksVid(1):end)-mean(folicle(clicksVid(1):end)))*500)
hold all,plot(data(:,5)/1000,data(:,2))