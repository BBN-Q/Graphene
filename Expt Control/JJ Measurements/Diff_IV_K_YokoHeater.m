%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Differential resistance measurement for Josephson junction
% with Lockin measuring resistance and Keithley2400 providing dc bias
% Includes Heater Voltage Provided by Yoko GS200
% Modified in August 2015 by Evan Walsh
% Created in June 2015 by KC Fong and Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Diff_IV_Heat_data = Diff_IV_K_YokoHeater()
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
Lockin.connect('7');
Yoko=deviceDrivers.YokoGS200;
Yoko.connect('2');

% Initialize variables
% DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = pwd;
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Diff_IV_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Differential IV using K2400 and SR830 \r\n'));
fprintf(FilePtr,'HeatCurr\tK2400_DC_V\tLockinX\tLockinY\r\n');
fclose(FilePtr);

% temperature log loop
prompt='What is the lock-in excitation voltage? ';
LockinExcitVolt = input(prompt);
prompt='What is the load resistor on the lock-in? ';
LoadResistor = input(prompt);

StartDCVoltage = 0;
prompt = 'What is the end dc voltage (V)? (will sweep to positive and negative of this value, start dc voltage is 0) ';
EndDCVoltage = abs(input(prompt));
prompt = 'What is the step dc voltage (V)? ';
StepDCVoltage = abs(input(prompt));
prompt = 'What is the wait time (s)? ';
WaitTime = input(prompt);
TotalStep=(EndDCVoltage-StartDCVoltage)/StepDCVoltage+1;

StartHeat=0;
prompt='What is the resistor on the heater? ';
HeatResistor = input(prompt);
prompt = 'What is the end heater voltage (V)? (start heater voltage is 0) ';
EndHeat = abs(input(prompt));
prompt = 'What is the step heater voltage (V)? ';
StepHeat = abs(input(prompt));
prompt = 'What is the heater wait time (s)? ';
HeatWait = input(prompt);
HeatSteps=(EndHeat-StartHeat)/StepHeat+1;

Diff_IV_Heat_data(HeatSteps)=struct('HeatCurr',[],'JJCurr',[],'LockInX',[],'LockInY',[]);



figure; pause on;
for i=1:HeatSteps
    SetHeat = (i-1)*StepHeat + StartHeat;
    Yoko.value=SetHeat;
    Diff_IV_Heat_data(i).HeatCurr=SetHeat/HeatResistor;
    pause(HeatWait);
    
    for j = 1:TotalStep
        SetVolt = (j-1)*StepDCVoltage + StartDCVoltage;
        Keithley.value = SetVolt;
        if j == 1
            pause(WaitTime + 10);
        else pause(WaitTime);
        end
        Diff_IV_data(j,:) = [SetVolt Lockin.X() Lockin.Y()];
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        fprintf(FilePtr,'%e\t%e\t%e\t%e\r\n',Diff_IV_Heat_data(i).HeatCurr,Diff_IV_data(j,:));
        fclose(FilePtr);
        clf; plot(Diff_IV_data(:,1)/LoadResistor, Diff_IV_data(:,2)/(LockinExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (Ohm)'); title(strcat('Diff IV measurement for Josephson junction, start date and time: ', datestr(StartTime)));
    end
    for j = 1:TotalStep
        SetVolt = (TotalStep-j)*StepDCVoltage - StartDCVoltage;
        Keithley.value = SetVolt;
        pause(WaitTime);
        Diff_IV_data(j+TotalStep,:) = [SetVolt Lockin.X() Lockin.Y()];
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        fprintf(FilePtr,'%e\t%e\t%e\t%e\r\n',Diff_IV_Heat_data(i).HeatCurr,Diff_IV_data(j+TotalStep,:));
        fclose(FilePtr);
        clf; plot(Diff_IV_data(:,1)/LoadResistor, Diff_IV_data(:,2)/(LockinExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (Ohm)'); title(strcat('Diff IV measurement for Josephson junction, start date and time: ', datestr(StartTime)));
    end
    for j = 1:TotalStep
        SetVolt = -(j-1)*StepDCVoltage + StartDCVoltage;
        Keithley.value = SetVolt;
        pause(WaitTime);
        Diff_IV_data(j+2*TotalStep,:) = [SetVolt Lockin.X() Lockin.Y()];
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        fprintf(FilePtr,'%e\t%e\t%e\t%e\r\n',Diff_IV_Heat_data(i).HeatCurr,Diff_IV_data(j+2*TotalStep,:));
        fclose(FilePtr);
        clf; plot(Diff_IV_data(:,1)/LoadResistor, Diff_IV_data(:,2)/(LockinExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (Ohm)'); title(strcat('Diff IV measurement for Josephson junction, start date and time: ', datestr(StartTime)));
    end
    for j = 1:TotalStep
        SetVolt = -(TotalStep-j)*StepDCVoltage + StartDCVoltage;
        Keithley.value = SetVolt;
        pause(WaitTime);
        Diff_IV_data(j+3*TotalStep,:) = [SetVolt Lockin.X() Lockin.Y()];
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        fprintf(FilePtr,'%e\t%e\t%e\t%e\r\n',Diff_IV_Heat_data(i).HeatCurr,Diff_IV_data(j+3*TotalStep,:));
        fclose(FilePtr);
        clf; plot(Diff_IV_data(:,1)/LoadResistor, Diff_IV_data(:,2)/(LockinExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (Ohm)'); title(strcat('Diff IV measurement for Josephson junction, start date and time: ', datestr(StartTime)));
    end
    
     Diff_IV_Heat_data(i).JJCurr=Diff_IV_data(:,1)/LoadResistor;
     Diff_IV_Heat_data(i).LockInX= Diff_IV_data(:,2)/(LockinExcitVolt/LoadResistor);
     Diff_IV_Heat_data(i).LockInY= Diff_IV_data(:,3)/(LockinExcitVolt/LoadResistor);
end

%Ramp Yoko back to 0V
for i=1:HeatSteps
    SetHeat = (HeatSteps-i)*StepHeat - StartHeat;
    Yoko.value=SetHeat;
    pause(HeatWait);
end
    Keithley.value = 0;
    pause off;

FileName = strcat('Diff_IV_vs_Heat_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
save(FileName,'Diff_IV_Heat_data')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Keithley.disconnect(); Lockin.disconnect(); Yoko.disconnect();
clear SetVolt;
clear Keithley;
clear Lockin;
clear Yoko