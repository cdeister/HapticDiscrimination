
% Serial com mostly from robot grrl tutorial:
% http://robotgrrl.com/blog/2010/01/15/arduino-to-matlab-read-in-sensor-data/
% and also, http://www.arduino.cc/en/Tutorial/SerialCallResponse

for k=1:5
%% clear data
clearvars -except k data
close all
numTrials=1;
sensorCal= 9000/9;  % in inches
toPlot=1;
p_fps=20; % doesn't keep up below 5, but loop is still good.
invert=0;
yRange=[-5,45];

%%
clc;
numSec=300;
s=[];
p=[];
d=[];
t=[];
sB=[];
tT=[];
tC=[];
cP=[];
cR=[];
d(1:200)=100;  % KLUDGE: This is just to make sure we initialize the running condition.

targetPos=700;
targetRange=350;
%pause(0.2)
cP(1)=targetPos;
cR(1)=targetRange;

%%
s1 = serial('/dev/cu.usbmodem1411');    % define serial port
s1.BaudRate=115200;       % define baud rate
set(s1, 'terminator', 'LF');    % define the terminator for println
fopen(s1);
%fprintf(s1,'%u',1);  % 1 is 49 in ascii
%pause(0.2)
%%

% try 
                         
w=fscanf(s1,'%s');   % signal the arduino to start collection           
% if (w=='A')
%     display(['Collecting data']);
%     fprintf(s1,'%s\n','A');     
% end
pause(0.5)   %<--- This has to be at leas 0.5 on my comp, or it will break. This indicates a buffer issue.
% State 1 always collects 187 points with 186 over ~300 ms then a 2 sec
% delay. 

fprintf(s1,'%u',1);  % 1 is 49 in ascii

cS=1;
n=0;
t0=tic;
tT(1)=0;
bS=2;
tCnt=1;

% --- set up plot
figure(998)
aPL = animatedline('Color',[0.1 0.1 0.1]);
aSL=animatedline('Color',[0.8 0 0]);
aSP=animatedline('Color',[0.8 0 0.6]);
axis([0,numSec*1000,yRange(1),yRange(2)])
legend('pos.','state')

% --- main block

while ((tT/1000)<numSec)    
    switch(cS)
        case 1
            n=n+1;
            s(n)=fscanf(s1,'%d');
            p(n)=fscanf(s1,'%d');       
            d(n)=fscanf(s1,'%f');       
            t(n)=fscanf(s1,'%f');
            % sB(n)=fscanf(s1,'%d'); 
            tT(n)=fscanf(s1,'%f');
            tC=fscanf(s1,'%d');
            cP(n)=fscanf(s1,'%d');
            cR(n)=fscanf(s1,'%d');
            cS=s(n);
        case 2
            n=n+1;
            s(n)=fscanf(s1,'%d');
            p(n)=fscanf(s1,'%d');       
            d(n)=fscanf(s1,'%f');       
            t(n)=fscanf(s1,'%f');
            % sB(n)=fscanf(s1,'%d');
            tT(n)=fscanf(s1,'%f');
            tC=fscanf(s1,'%d');
            cP(n)=fscanf(s1,'%d');
            cR(n)=fscanf(s1,'%d');
            cS=s(n);
            if t(n)>1000 && mean(abs(d(end-199:end)))<10
                if invert==1
                    if p(n)<cP(end)+cR(end)
                        bS=1;
                        fprintf(s1,'%u',4);
                    else
                        bS=0;
                        fprintf(s1,'%u',3);
                    end
                elseif invert==0
                    if p(n)>cP(end)+cR(end) %ismember(p(n),cP(end):cP(end)+cR(end))
                        bS=1;
                        fprintf(s1,'%u',4);
                    else
                        bS=0;
                        fprintf(s1,'%u',3);
                    end
                end
            else
            end
        case 3
            n=n+1;
            s(n)=fscanf(s1,'%d');
            p(n)=fscanf(s1,'%d');       
            d(n)=fscanf(s1,'%f');       
            t(n)=fscanf(s1,'%f');
            % sB(n)=fscanf(s1,'%d');
            tT(n)=fscanf(s1,'%f');
            tC=fscanf(s1,'%d');
            cP(n)=fscanf(s1,'%d');
            cR(n)=fscanf(s1,'%d');
            cS=s(n);
            if t(n)>1000 && mean(abs(d(end-199:end)))<10
                fprintf(s1,'%u',2);
            else
            end
        case 4
            n=n+1;
            s(n)=fscanf(s1,'%d');
            p(n)=fscanf(s1,'%d');       
            d(n)=fscanf(s1,'%f');       
            t(n)=fscanf(s1,'%f');
            % sB(n)=fscanf(s1,'%d');
            tT(n)=fscanf(s1,'%f');
            tC=fscanf(s1,'%d');
            cP(n)=fscanf(s1,'%d');
            cR(n)=fscanf(s1,'%d');
            cS=s(n);
    end
    if mod(n,p_fps)==0
        addpoints(aPL,tT(n),p(n)./sensorCal);
        addpoints(aSL,tT(n),mean(abs(d(end-99:end))));
        addpoints(aSP,tT(n),cP(n)./sensorCal);
        drawnow
        switch(bS)
            case 2
                title(['trial# ' num2str(tC(end)) ' & state ' num2str(s(n))])
            case 1
                title(['trial# ' num2str(tC(end)) ' & state ' num2str(s(n)) ' \color[rgb]{0 .5 .2}last trial = hit'])
            case 0
                title(['trial# ' num2str(tC(end)) ' & state ' num2str(s(n)) ' \color{red}last trial = miss'])
        end
        
    else
    end
end
    


fprintf(s1,'%u',5);  % Pause State (no serial)
fclose(s1);

% catch exception
%     fclose(s1);                 
%     throw (exception);
% end

data.s{k}=s;
data.p{k}=p;
data.d{k}=d;
data.t{k}=t;
data.tT{k}=tT;
data.tC{k}=tC;
data.cP{k}=cP;
data.cR{k}=cR;
end

%% save data
tic
exportPath='~/Desktop/';
save([exportPath 'jv16_a.mat'],'data','-v7.3')
toc



% %% Plot Summary
% figure(88),plot(tT./1000,p./sensorCal,'k-')
% hold all,plot(tT./1000,s,'r-')
% hold all,plot(tT(2:end)./1000,smooth(diff(smooth(p,50))),'b-')
% hold all,plot(tT./1000,cP./sensorCal,'m-')
% hold all,plot(tT./1000,(cP+cR)./sensorCal,'m-')
% ylabel('Position,State and Delta')
% xlabel('Time (sec)')
% legend('pos','state','delta')
% ylim([-10 10])

    

