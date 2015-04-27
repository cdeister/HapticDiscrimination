% Largley Folowing robot grrl tutorial:
% http://robotgrrl.com/blog/2010/01/15/arduino-to-matlab-read-in-sensor-data/
% and also, http://www.arduino.cc/en/Tutorial/SerialCallResponse

% TODO: write collect data function to clean up default state. lots of
% repate code

%% clear data
numTrials=1;
sensorCal=9000/9.5;  % in inches
close all
toPlot=1;
p_fps=60;

%%
clc;
clear cS d i numSec p s s1 sB t t0 targetPos targetRange w
numSec=60;
s=[];
p=[];
d=[];
t=[];
sB=[];
tT=[];
d(1:1000)=10;  % KLUDGE: This is just to make sure we initialize the running condition.

targetPos=6000;
targetRange=600;
%pause(0.2)

%%
s1 = serial('/dev/cu.usbmodem1461');    % define serial port
s1.BaudRate=115200;       % define baud rate
set(s1, 'terminator', 'LF');    % define the terminator for println
fopen(s1);
%fprintf(s1,'%u',1);  % 1 is 49 in ascii
%pause(0.2)
%%

try                             % use try catch to ensure fclose
                                % signal the arduino to start collection
w=fscanf(s1,'%s');              % must define the input % d or %s, etc.
% if (w=='A')
%     display(['Collecting data']);
%     fprintf(s1,'%s\n','A');     % establishContact just wants 
%                                 % something in the buffer
% end
pause(0.5)   %<--- This has to be at leas 0.5 on my comp, or it will break. This indicates a buffer issue.
% State 1 always collects 187 points with 186 over ~300 ms then a 2 sec
% delay. 

fprintf(s1,'%u',1);  % 1 is 49 in ascii

cS=1;
i=0;
t0=tic;
tT(1)=0;
bS=2;
tCnt=1;

% --- set up plot
figure(998)
aPL = animatedline('Color',[0.1 0.1 0.1]);
aSL=animatedline('Color',[0.8 0 0]);
axis([0,numSec*1000,-(targetPos./sensorCal),(targetPos./sensorCal)*2])
hold all,plot([0 numSec*1000],[targetPos./sensorCal targetPos./sensorCal],'g-')
hold all,plot([0 numSec*1000],[(targetPos./sensorCal+targetRange./sensorCal) (targetPos./sensorCal+targetRange./sensorCal)],'g-')
legend('pos.','state')

% --- main block

while ((tT/1000)<numSec)    
    switch(cS)
        case 1
            i=i+1;
            s(i)=fscanf(s1,'%d');
            p(i)=fscanf(s1,'%d');       
            d(i)=fscanf(s1,'%f');       
            t(i)=fscanf(s1,'%f');
            sB(i)=fscanf(s1,'%d'); 
            tT(i)=fscanf(s1,'%f');
            cS=s(i);
        case 2
            i=i+1;
            s(i)=fscanf(s1,'%d');
            p(i)=fscanf(s1,'%d');       
            d(i)=fscanf(s1,'%f');       
            t(i)=fscanf(s1,'%f');
            sB(i)=fscanf(s1,'%d');
            tT(i)=fscanf(s1,'%f');
            cS=s(i);
            if t(i)>3000 && mean(abs(d(end-1999:end)))<0.1
                fprintf(s1,'%u',3);
                if ismember(p(i),targetPos:targetPos+targetRange)
                    bS=1;
                else
                    bS=0;
                end
            else
            end
        case 3
            i=i+1;
            s(i)=fscanf(s1,'%d');
            p(i)=fscanf(s1,'%d');       
            d(i)=fscanf(s1,'%f');       
            t(i)=fscanf(s1,'%f');
            sB(i)=fscanf(s1,'%d');
            tT(i)=fscanf(s1,'%f');
            cS=s(i);
            if t(i)>1000 && mean(abs(d(end-999:end)))<0.1
                fprintf(s1,'%u',2);
            else
            end
    end
    if mod(i,p_fps)==0
        addpoints(aPL,tT(i),p(i)./sensorCal);
        addpoints(aSL,tT(i),s(i));
        drawnow
        switch(bS)
            case 2
                title(['state ' num2str(s(i))])
            case 1
                title(['state ' num2str(s(i)) ' \color[rgb]{0 .8 .2}last trial = hit'])
            case 0
                title(['state ' num2str(s(i)) ' \color{red}last trial = miss'])
        end
        
    else
    end
end
    


fprintf(s1,'%u',3);
fclose(s1);

catch exception
    fclose(s1);                 
    throw (exception);
end    
%%
% figure(88),plot(tT./1000,p./sensorCal,'k-')
% hold all,plot(tT./1000,s,'r-')
% hold all,plot(tT(2:end)./1000,smooth(diff(smooth(p,50))),'b-')
% hold all,plot([tT(1)./1000 tT(end)./1000],[targetPos./sensorCal targetPos./sensorCal],'g-')
% hold all,plot([tT(1)./1000 tT(end)./1000],[(targetPos+targetRange)./sensorCal (targetPos+targetRange)./sensorCal],'g-')
% ylabel('Position,State and Delta')
% xlabel('Time (sec)')
% legend('pos','state','delta')
% ylim([-10 10])

    

