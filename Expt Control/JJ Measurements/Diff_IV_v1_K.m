%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Differential resistance measurement for Josephson junction
% with Lockin measuring resistance and Keithley providing dc bias
% Created in June 2015 by KC Fong and Evan
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Diff_IV_data = Diff_IV_v1_K()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear Diff_IV_data;
%close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
Keithley=deviceDrivers.Keithley2400();
Keithley.connect('24');
Lockin = deviceDrivers.SRS830();
Lockin.connect('8');

% Initialize variables
% DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = pwd;
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Diff_IV_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Differential IV using Yoko and SR830 \r\n'));
fprintf(FilePtr,'Yoko_DC_V\tLockinX\tLockinY\r\n');
fclose(FilePtr);

% temperature log loop
prompt='What is the lock-in excitation voltage? ';
LockinExcitVolt = input(prompt);
prompt='What is the load resistor? ';
LoadResistor = input(prompt);
prompt = 'What is the start dc voltage (V)? ';
StartDCVoltage = input(prompt);
prompt = 'What is the step dc voltage (V)? ';
StepDCVoltage = input(prompt);
prompt = 'How many steps in total? ';
TotalStep = input(prompt);
WaitTime = 5*Lockin.timeConstant();

figure; pause on;
for j = 1:TotalStep
    SetVolt = (j-1)*StepDCVoltage + StartDCVoltage;
    Keithley.value = SetVolt;
    if j == 1
        pause(WaitTime + 10);
    else pause(WaitTime);
    end
    Diff_IV_data(j,:) = [SetVolt Lockin.X() Lockin.Y()];
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    fprintf(FilePtr,'%e\t%e\t%e\r\n',Diff_IV_data(j,:));
    fclose(FilePtr);
    clf; plot(Diff_IV_data(:,1)/LoadResistor, Diff_IV_data(:,2)/(LockinExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (Ohm)'); title(strcat('Diff IV measurement for Josephson junction, start date and time: ', datestr(StartTime)));
end
for j = 1:TotalStep
    SetVolt = (TotalStep-j)*StepDCVoltage - StartDCVoltage;
    Keithley.value = SetVolt;
    pause(WaitTime);
    Diff_IV_data(j+TotalStep,:) = [SetVolt Lockin.X() Lockin.Y()];
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    fprintf(FilePtr,'%e\t%e\t%e\r\n',Diff_IV_data(j+TotalStep,:));
    fclose(FilePtr);
    clf; plot(Diff_IV_data(:,1)/LoadResistor, Diff_IV_data(:,2)/(LockinExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (Ohm)'); title(strcat('Diff IV measurement for Josephson junction, start date and time: ', datestr(StartTime)));
end
Keithley.value = 0;
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Keithley.disconnect(); Lockin.disconnect();
clear SetVolt;
clear Keithley;
clear Lockin;