% Largley Folowing robot grrl tutorial:
% http://robotgrrl.com/blog/2010/01/15/arduino-to-matlab-read-in-sensor-data/
% and also, http://www.arduino.cc/en/Tutorial/SerialCallResponse

% TODO: write collect data function to clean up default state. lots of
% repate code

% clear data
numTrials=1;
sensorCal=9000/9.5;  % in inches
for k=1;
%%
clc;
clear cS d i numSec p s s1 sB t t0 targetPos targetRange w
numSec=100;
s=[];
p=[];
d=[];
t=[];
sB=[];
d(1:1000)=10;  % KLUDGE: This is just to make sure we initialize the running condition.

targetPos=4000;
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
%pause(0.1)  %<--- irrenlevant apparently
cS=1;
sC=0;
i=0;
t0=tic;
while (toc(t0)<=numSec)
    if cS==1
        i=i+1;
        s(i)=fscanf(s1,'%d');
        p(i)=fscanf(s1,'%d');       % must define the input % d, %f, %s, etc.
        d(i)=fscanf(s1,'%f');       % must define the input % d, %f, %s, etc.
        t(i)=fscanf(s1,'%f');
        sB(i)=fscanf(s1,'%d');  % debug transitions
        cS=s(i);
        
    elseif cS==2
        if t(i)<4000
            i=i+1;
            s(i)=fscanf(s1,'%d');
            p(i)=fscanf(s1,'%d');       % must define the input % d, %f, %s, etc.
            d(i)=fscanf(s1,'%f');       % must define the input % d, %f, %s, etc.
            t(i)=fscanf(s1,'%f');
            sB(i)=fscanf(s1,'%d');  % debug transitions
            cS=s(i);
        else
            if mean(abs(d(end-2999:end)))<0.1
                sC=sC+1;
                i=i+1;
                s(i)=fscanf(s1,'%d');
                p(i)=fscanf(s1,'%d');       % must define the input % d, %f, %s, etc.
                d(i)=fscanf(s1,'%f');       % must define the input % d, %f, %s, etc.
                t(i)=fscanf(s1,'%f');
                sB(i)=fscanf(s1,'%d');  % debug transitions
                cS=s(i);
                fprintf(s1,'%u',3);
                cS=3;
                disp(['stop ' num2str(sC)])  % When I last left this was looping multiple times.
            else
                i=i+1;
                s(i)=fscanf(s1,'%d');
                p(i)=fscanf(s1,'%d');       % must define the input % d, %f, %s, etc.
                d(i)=fscanf(s1,'%f');       % must define the input % d, %f, %s, etc.
                t(i)=fscanf(s1,'%f');
                sB(i)=fscanf(s1,'%d');  % debug transitions
                cS=s(i);
            end
        end
        

        
    elseif cS==3
        if t(i)<3000
            sC=0; % debug flag
            i=i+1;
            s(i)=fscanf(s1,'%d');
            p(i)=fscanf(s1,'%d');       % must define the input % d, %f, %s, etc.
            d(i)=fscanf(s1,'%f');       % must define the input % d, %f, %s, etc.
            t(i)=fscanf(s1,'%f');
            sB(i)=fscanf(s1,'%d');  % debug transitions
            cS=s(i);
        else  % if the animal reamins still re-enter the trial state
            if mean(abs(d(end-999:end)))<2
                fprintf(s1,'%u',2);
                cS=2;
            else
                i=i+1;
                s(i)=fscanf(s1,'%d');
                p(i)=fscanf(s1,'%d');       % must define the input % d, %f, %s, etc.
                d(i)=fscanf(s1,'%f');       % must define the input % d, %f, %s, etc.
                t(i)=fscanf(s1,'%f');
                sB(i)=fscanf(s1,'%d');  % debug transitions
                cS=s(i);
            end
        end
    end
end


fprintf(s1,'%u',3);  %debug <-- this should trigger a transition to the wait state
fclose(s1);
%%
figure(88),plot(p,'k-')
hold all,plot(s*1000,'r-')
hold all,plot(d,'b-')
hold all,plot([0 size(t,2)],[targetPos targetPos],'b-')
hold all,plot([0 size(t,2)],[targetPos+targetRange targetPos+targetRange],'b-')
title(['trial number ' num2str(k)])

%%
data.s{k}=s;
data.p{k}=p;
data.d{k}=d;
data.t{k}=t;


    

catch exception
    fclose(s1);                 
    throw (exception);
end    
end

% %%
% figure(199),hold all
% plot([0 15],[targetPos./sensorCal targetPos./sensorCal],'b-')
% plot([0 15],[(targetPos+targetRange)./sensorCal (targetPos+targetRange)./sensorCal],'b-')
% for n=1:numTrials
%     figure(199),hold all
%     plot(data.t{n}(data.s{n}==2)./1000,data.p{n}(data.s{n}==2)./sensorCal,'k-')
% end
% ylabel('position in inches')
% xlabel('time in seconds')
% 
% %%
% figure(197),hold all
% 
% for n=1:numTrials
%     figure(197),hold all
%     plot(data.t{n}(data.s{n}==1)./1000,data.p{n}(data.s{n}==1),'ok-')
% 
% end