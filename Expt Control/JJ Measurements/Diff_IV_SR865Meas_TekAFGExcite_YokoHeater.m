%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Differential resistance measurement for Josephson junction
% with SR865 measuring resistance and providing dc bias
% Includes Heat Voltage Provided by Yoko GS200
% Modified in November 2015 by Evan Walsh
% Created in June 2015 by KC Fong and Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Diff_IV_Heat_data = Diff_IV_SR865Meas_TekAFGExcite_YokoHeater()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end

%close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
Lockin = deviceDrivers.SRS865();
Lockin.connect('10');
Yoko=deviceDrivers.YokoGS200;
Yoko.connect('2');
AFG = deviceDrivers.TekAFG3102;
AFG.connect('11');

% Initialize variables
% DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = pwd;
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Diff_IV_vs_Heat', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Differential IV using SR865 \r\n'));
fprintf(FilePtr,'Heat\tSR865_DC_V\tLockinX\tLockinY\r\n');
fclose(FilePtr);

% Input Parameters
prompt='What is the gate voltage? ';
GateVolt = input(prompt);
prompt='What is the AFG excitation voltage? ';
AFGExcitVolt = input(prompt);
prompt='What is the load resistor on the AFG? ';
LoadResistor = input(prompt);

prompt = 'What is the start dc voltage (V)? ';
StartDCVoltage = (input(prompt));
prompt = 'What is the end dc voltage (V)? ';
EndDCVoltage = (input(prompt));
prompt = 'What is the step dc voltage (V)? ';
StepDCVoltage = abs(input(prompt));
prompt = 'What is the wait time (s)? ';
WaitTime = input(prompt);
TotalStep=(EndDCVoltage-StartDCVoltage)/StepDCVoltage+1;

prompt = 'What is the heater resistor (Ohm)? ';
HeaterResistor = input(prompt);
prompt = 'What is the start heater voltage (V)? ';
StartHeat = input(prompt);
prompt = 'What is the end heater voltage (V)? ';
EndHeat = input(prompt);
prompt = 'What is the step heater voltage (V)? ';
StepHeat = input(prompt);
prompt = 'What is the heat wait time (s)? ';
HeatWait = input(prompt);
HeatSteps=(EndHeat-StartHeat)/StepHeat+1;

Diff_IV_Heat_data=struct('V_Heat_Array',[],'JJCurr_Array',[],'LockInX',[],'LockInY',[],'AFG_Excite_Volt',AFGExcitVolt,'AFG_Load_Resistor',LoadResistor,'LockIn_Time_Constant',Lockin.timeConstant(),'Measurement_Wait_Time',WaitTime,'Heater_Resistor',HeaterResistor,'V_gate',GateVolt);



figure; pause on;
for i=1:HeatSteps
    SetHeat = (i-1)*StepHeat + StartHeat;
    Yoko.value=SetHeat;
    Diff_IV_Heat_data.V_Heat_Array(i)=SetHeat;
    pause(HeatWait);
    
    for j = 1:TotalStep
        SetVolt = (j-1)*StepDCVoltage + StartDCVoltage;
        AFG.offset = SetVolt;
        if j == 1
            pause(WaitTime + 10);
        else pause(WaitTime);
        end
        [LockinX, LockinY] = Lockin.get_XY();
        Diff_IV_data(j,:) = [SetVolt LockinX LockinY];
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        fprintf(FilePtr,'%e\t%e\t%e\t%e\r\n',Diff_IV_Heat_data.V_Heat_Array(i),Diff_IV_data(j,:));
        fclose(FilePtr);
        clf; plot(Diff_IV_data(:,1)/LoadResistor, Diff_IV_data(:,2)/(AFGExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (Ohm)'); title(strcat('Diff IV measurement for Josephson junction, start date and time: ', datestr(StartTime)));
    end
    for j = 1:TotalStep
        SetVolt = (TotalStep-j)*StepDCVoltage + StartDCVoltage;
        AFG.offset = SetVolt;
        pause(.1);
    end
 
    
     Diff_IV_Heat_data.JJCurr_Array=Diff_IV_data(:,1)/LoadResistor;
     Diff_IV_Heat_data.LockInX(i,:)= Diff_IV_data(:,2);
     Diff_IV_Heat_data.LockInY(i,:)= Diff_IV_data(:,3);
end
Diff_IV_Heat_data.V_Heat_Array=Diff_IV_Heat_data.V_Heat_Array';

FileName = strcat('Diff_IV_vs_Heat_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
save(FileName,'Diff_IV_Heat_data')

%Ramp Yoko back to 0V
i=0;
while SetHeat~=0
    i=i+1;
    SetHeat = (HeatSteps-i)*StepHeat + StartHeat;
    Yoko.value=SetHeat;
    pause(1);
end

%Ramp SR865 Back to Zero
%     Lockin.scan_time_set(60);
%     Lockin.scan_interval_set(1);
%     Lockin.DC_scan_begin_set(SetVolt)
%     Lockin.DC_scan_end_set(0);
%     Lockin.enable_scan();
%     Lockin.run_scan();
%     Lockin.DC=0;

    pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Lockin.disconnect(); Yoko.disconnect(); AFG.disconnect;
clear SetVolt;
clear Lockin;
clear Yoko
clear AFG
end