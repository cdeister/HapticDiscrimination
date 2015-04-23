% Largley Folowing robot grrl tutorial:
% http://robotgrrl.com/blog/2010/01/15/arduino-to-matlab-read-in-sensor-data/
% and also, http://www.arduino.cc/en/Tutorial/SerialCallResponse

%%
clc;
clear all
numSec=20;
s=[];
p=[];
d=[];
t=[];
sB=[];
targetPos=9000;
targetRange=2000;


%%
s1 = serial('/dev/tty.usbmodem1461');    % define serial port
s1.BaudRate=115200;               % define baud rate
set(s1, 'terminator', 'LF');    % define the terminator for println
fopen(s1);
fprintf(s1,'%u',1);  % 1 is 49 in ascii

%%
try                             % use try catch to ensure fclose
                                % signal the arduino to start collection
w=fscanf(s1,'%s');              % must define the input % d or %s, etc.
% if (w=='A')
%     display(['Collecting data']);
%     fprintf(s1,'%s\n','A');     % establishContact just wants 
%                                 % something in the buffer
% end


i=0;
t0=tic;
while (toc(t0)<=numSec)
    i=i+1;
    s(i)=fscanf(s1,'%d');
    p(i)=fscanf(s1,'%d');       % must define the input % d, %f, %s, etc.
    d(i)=fscanf(s1,'%f');       % must define the input % d, %f, %s, etc.
    t(i)=fscanf(s1,'%f');
    sB(i)=fscanf(s1,'%d');  % debug transitions
    fprintf(s1,'%u',3);   % debug transitions (3 is 51 in ascii); 5 is 53
end

fprintf(s1,'%u',5);  %debug <-- this should trigger a transition to the wait state
fclose(s1);
figure,plot(t./1000,p,'ko-')
hold all,plot([0 numSec],[targetPos targetPos],'b-')
hold all,plot([0 numSec],[targetPos+targetRange targetPos+targetRange],'b-')                       

catch exception
    fclose(s1);                 
    throw (exception);
end                             