%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Evan Walsh (evanwalsh@seas.harvard.edu), July 2015 
%
% Takes traces from the VNA at different graphene backgate voltages to
% determine impedance matching. The backgate is controlled by the Yokogawa
% Inputs:
%   VGate: A vector containing the backgate voltages to be tested
% Outputs:
%   freq: A vector containing the frequency values from the VNA measurement
%   trace: A matrix with size length(freq) x length(VGate) that contains
%       the S11 values from the VNA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [freq, trace] = Graphene_Imp_Match(VGate)

prompt='How many traces do you want to plot? ';
numplots = input(prompt);

prompt='How long to pause at each voltage? ';
pausetime = input(prompt);

% Connect to the VNA
VNA = deviceDrivers.AgilentE8363C();
VNA.connect('192.168.5.101')

% Connect to the Yoko
% Yoko = deviceDrivers.YokoGS200;
% Yoko.connect('2')
Keithley=deviceDrivers.Keithley2400();
Keithley.connect('24');

% Initialize variables
pause on;
start_dir = pwd;
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Graphene_Imp_Match_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' S11 from VNA as function of Graphene Backgate Voltage \r\n'));
fclose(FilePtr);
Graphene_Imp_Match_Data=struct('V_gate',VGate,'freq',[],'trace',[]);

%Go to first voltage
% Yoko.value = VGate(1);
Keithley.value = VGate(1);

%Get First Trace
[freq, trace1] = VNA.getTrace();
if numplots~=0
    figure;
    hold on
    plot(freq*1e-6, 20*log10(abs(trace1)));
    grid on;
end

 FilePtr = fopen(fullfile(start_dir, FileName), 'a');
 fprintf(FilePtr,'%e\t',VGate(1),freq);
 fprintf(FilePtr,'\r\n');
 fprintf(FilePtr,'%e\t',VGate(1),real(trace1));
 fprintf(FilePtr,'\r\n');
 fprintf(FilePtr,'%e\t',VGate(1),imag(trace1));
 fprintf(FilePtr,'\r\n');
 fclose(FilePtr);

Graphene_Imp_Match_Data.freq=freq;

%Initialize trace output
VG_length=length(VGate);
freq_length=length(freq);
trace=[trace1; zeros(VG_length-1,freq_length)];
    
pause(pausetime)

%Sweep through remaining gate voltages
plotflag=floor(VG_length/numplots);
if VG_length ~= 1
    for n=2:VG_length
%         Yoko.value = VGate(n);
        Keithley.value = VGate(n);        
        [freq, trace(n,:)]=VNA.getTrace();
        %create plots
        if gcd(n,plotflag)~=1 || plotflag==0 || plotflag==1
                plot(freq*1e-6, 20*log10(abs(trace(n,:))),'r');            
        end
        %Save to File
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
         fprintf(FilePtr,'%e\t',VGate(n),real(trace(n,:)));
         fprintf(FilePtr,'\r\n');
         fprintf(FilePtr,'%e\t',VGate(n),imag(trace(n,:)));
         fprintf(FilePtr,'\r\n');
        fclose(FilePtr);
        pause(pausetime)
    end
end

Graphene_Imp_Match_Data.trace=trace;
FileName = strcat('Graphene_Imp_Match_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
save(FileName,'Graphene_Imp_Match_Data')

%Ramp gate back to zero

% while Yoko.value>0
%     Yoko.value=Yoko.value-1;
%     pause(pausetime)
% end

while Keithley.value>0
    Keithley.value=Keithley.value-1;
    pause(pausetime)
end

% while Yoko.value<0
%     Yoko.value=Yoko.value+1;
%     pause(pausetime)
% end

while Keithley.value<0
    Keithley.value=Keithley.value+1;
    pause(pausetime)
end

%Disconnect from hardware
VNA.disconnect();
% Yoko.disconnect();
Keithley.disconnect();
clear VNA
% clear Yoko
clear Keithley

end
    









