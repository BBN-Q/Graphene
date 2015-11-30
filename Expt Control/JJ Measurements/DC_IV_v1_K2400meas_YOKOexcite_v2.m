%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DC IV characteristics for a JJ. Sweeps current with Yokogawa GS200 and
% measures voltage with Keithley 2400. 
% 
% Evan Walsh, July 2015 (evanwalsh@seas.harvard.edu)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DC_IV_data = DC_IV_v1_K2400meas_YOKOexcite_v2()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear DC_IV_data;
%close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
K2400=deviceDrivers.Keithley2400();
K2400.connect('24');
Yoko=deviceDrivers.YokoGS200;
Yoko.connect('2');

% Initialize variables
% DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = pwd;
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('DC_IV_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' DC IV using Keithley \r\n'));
fprintf(FilePtr,'Yoko_DC_V\tKeithley_V\r\n');
fclose(FilePtr);

% temperature log loop
prompt='What is the load resistor (ohm)? ';
LoadResistor = input(prompt);
prompt = 'What is the start dc voltage (V)? ';
StartDCVoltage = input(prompt);
prompt = 'What is the end dc voltage (V)? ';
EndDCVoltage = input(prompt);
prompt = 'What is the step dc voltage (V)? ';
StepDCVoltage = input(prompt);
prompt = 'What is the wait time (s)? ';
WaitTime = input(prompt);
TotalStep=(EndDCVoltage-StartDCVoltage)/StepDCVoltage+1;

figure; pause on;



for j = 1:TotalStep
    SetVolt = (j-1)*StepDCVoltage + StartDCVoltage;
    Yoko.value = SetVolt;
    pause(WaitTime);
    
    DC_IV_data(j,:) = [SetVolt K2400.value()];
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    fprintf(FilePtr,'%e\t%e\r\n',DC_IV_data(j,:));
    fclose(FilePtr);
    clf; plot(DC_IV_data(:,1)/LoadResistor, DC_IV_data(:,2)); grid on; xlabel('Current (A)'); ylabel('Voltage (V)'); title(strcat('DC IV Measurement for JJ, ', datestr(StartTime)));
end



pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
K2400.disconnect();
Yoko.disconnect();
clear SetVolt;
clear K2400;
clear Yoko;

