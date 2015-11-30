%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Takes spectrum as function of Yoko heater voltage
% Created in November 2015 by Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Spectrum_Heat_data = Spectrum_YokoHeater()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
fclose all;

% Connect to the Cryo-Con 22 temperature controler
SA=deviceDrivers.AgilentN9020A();
SA.connect('128.33.89.183');
Yoko=deviceDrivers.YokoGS200;
Yoko.connect('2');

% Initialize variables
% DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = pwd;
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Spectrum_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' JNT Spectrum vs Heater Current \r\n'));
fprintf(FilePtr,'HeatCurr(A)\tFirst Row is Frequency(Hz)\tOther Rows are Spectrums(log10(dbM))\r\n');
fclose(FilePtr);

% temperature log loop
prompt='What is the resistor on the heater? ';
HeatResistor = input(prompt);
prompt='What is the start heater voltage (V)? ';
StartHeat=input(prompt);
prompt = 'What is the end heater voltage (V)? ';
EndHeat = abs(input(prompt));
prompt = 'What is the step heater voltage (V)? ';
StepHeat = abs(input(prompt));
prompt = 'What is the heater wait time (s)? ';
HeatWait = input(prompt);
HeatSteps=(EndHeat-StartHeat)/StepHeat+1;

prompt = 'What is SA Resolution Bandwidth (Hz)? ';
RBW = input(prompt);
prompt = 'What is SA Video Bandwidth (Hz)? ';
VBW = input(prompt);

Spectrum_Heat_data=struct('HeatCurr',[],'Freq',[],'Spec',[],'RBW',RBW,'VBW',VBW);

figure; pause on;
for i=1:HeatSteps
    SetHeat = (i-1)*StepHeat + StartHeat;
    Yoko.value=SetHeat;
    Spectrum_Heat_data.HeatCurr(i)=SetHeat/HeatResistor;
    pause(HeatWait);
    [Spectrum_Heat_data.Freq, Spectrum_Heat_data.Spec(:,i)] = SA.SAGetTrace();
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    if i==1
        fprintf(FilePtr,'%e\t%e',Spectrum_Heat_data.HeatCurr(i),Spectrum_Heat_data.Freq);
        fprintf(FilePtr,'\r\n');
    end
    fprintf(FilePtr,'%e\t%e',Spectrum_Heat_data.HeatCurr(i),Spectrum_Heat_data.Spec(:,i));
    fprintf(FilePtr,'\r\n');
    fclose(FilePtr);
    clf; semilogy(Spectrum_Heat_data.Freq/10^6,10.^Spectrum_Heat_data.Spec(:,i)); grid on; xlabel('Frequency (MHz)'); ylabel('Power (dBm)'); title('Graphene JNT Spectrum');
end

FileName = strcat('Spectrum_Heat_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
save(FileName,'Spectrum_Heat_data')

%Ramp Yoko back to 0V
for i=1:HeatSteps
    SetHeat = (HeatSteps-i)*StepHeat + StartHeat;
    Yoko.value=SetHeat;
    pause(HeatWait);
end
    pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Yoko.disconnect;
SA.disconnect;
clear SetVolt;
clear SA
clear Yoko