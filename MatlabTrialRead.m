% Largley Folowing robot grrl tutorial:
% http://robotgrrl.com/blog/2010/01/15/arduino-to-matlab-read-in-sensor-data/
% and also, http://www.arduino.cc/en/Tutorial/SerialCallResponse

% TODO: write collect data function to clean up default state. lots of
% repate code

%% clear data
numTrials=1;
sensorCal=9000/9.5;  % in inches

%%
clc;
clear cS d i numSec p s s1 sB t t0 targetPos targetRange w
numSec=120;
s=[];
p=[];
d=[];
t=[];
sB=[];
tT=[];
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

cS=1;
i=0;
t0=tic;
rng('shuffle')
while (toc(t0)<=numSec)
    aa=randi([3000,12000]);
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
            if t(i)>aa && mean(abs(d(end-1999:end)))<0.1
                fprintf(s1,'%u',2);
            else
            end
    end
end
    


fprintf(s1,'%u',3);
fclose(s1);
%%
figure(88),plot(p,'k-')
hold all,plot(s*1000,'r-')
hold all,plot(d,'b-')
hold all,plot([0 size(t,2)],[targetPos targetPos],'b-')
hold all,plot([0 size(t,2)],[targetPos+targetRange targetPos+targetRange],'b-')
title(['trial number ' num2str(k)])

    

catch exception
    fclose(s1);                 
    throw (exception);
end    