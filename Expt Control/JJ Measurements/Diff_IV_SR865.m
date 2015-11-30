%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Differential resistance measurement for Josephson junction
% with SR865 measuring resistance and providing dc bias
% Modified in September 2015 by Evan Walsh
% Created in June 2015 by KC Fong and Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Diff_IV_data = Diff_IV_SR865()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end

%close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
LockinDC = deviceDrivers.SRS865();
LockinDC.connect('10');

% Initialize variables
% DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = pwd;
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Diff_IV', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Differential IV using SR865 \r\n'));
fprintf(FilePtr,'SR865_DC_V\tLockinX\tLockinY\r\n');
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

Diff_IV_data_struct=struct('JJCurr_Array',[],'LockInX',[],'LockInY',[],'LockIn_Excite_Volt',LockinExcitVolt,'LockIn_Load_Resistor',LoadResistor,'LockIn_Time_Constant',LockinDC.timeConstant(),'Measurement_Wait_Time',WaitTime);



figure; pause on;
    for j = 1:TotalStep
        SetVolt = (j-1)*StepDCVoltage + StartDCVoltage;
        LockinDC.DC = SetVolt;
        if j == 1
            pause(WaitTime + 10);
        else pause(WaitTime);
        end
        [LockinX, LockinY] = LockinDC.get_XY();
        Diff_IV_data(j,:) = [SetVolt LockinX LockinY];
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        fprintf(FilePtr,'%e\t%e\t%e\r\n',Diff_IV_data(j,:));
        fclose(FilePtr);
        clf; plot(Diff_IV_data(:,1)/LoadResistor, Diff_IV_data(:,2)/(LockinExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (Ohm)'); title(strcat('Diff IV measurement for Josephson junction, start date and time: ', datestr(StartTime)));
    end
    for j = 1:TotalStep
        SetVolt = (TotalStep-j)*StepDCVoltage - StartDCVoltage;
        LockinDC.DC = SetVolt;
        pause(WaitTime);
        [LockinX, LockinY] = LockinDC.get_XY();
        Diff_IV_data(j+TotalStep,:) = [SetVolt LockinX LockinY];
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        fprintf(FilePtr,'%e\t%e\t%e\r\n',Diff_IV_data(j+TotalStep,:));
        fclose(FilePtr);
        clf; plot(Diff_IV_data(:,1)/LoadResistor, Diff_IV_data(:,2)/(LockinExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (Ohm)'); title(strcat('Diff IV measurement for Josephson junction, start date and time: ', datestr(StartTime)));
    end
    for j = 1:TotalStep
        SetVolt = -(j-1)*StepDCVoltage + StartDCVoltage;
        LockinDC.DC = SetVolt;
        pause(WaitTime);
        [LockinX, LockinY] = LockinDC.get_XY();
        Diff_IV_data(j+2*TotalStep,:) = [SetVolt LockinX LockinY];
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        fprintf(FilePtr,'%e\t%e\t%e\r\n',Diff_IV_data(j+2*TotalStep,:));
        fclose(FilePtr);
        clf; plot(Diff_IV_data(:,1)/LoadResistor, Diff_IV_data(:,2)/(LockinExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (Ohm)'); title(strcat('Diff IV measurement for Josephson junction, start date and time: ', datestr(StartTime)));
    end
    for j = 1:TotalStep
        SetVolt = -(TotalStep-j)*StepDCVoltage + StartDCVoltage;
        LockinDC.DC = SetVolt;
        pause(WaitTime);
        [LockinX, LockinY] = LockinDC.get_XY();
        Diff_IV_data(j+3*TotalStep,:) = [SetVolt LockinX LockinY];
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        fprintf(FilePtr,'%e\t%e\t%e\r\n',Diff_IV_data(j+3*TotalStep,:));
        fclose(FilePtr);
        clf; plot(Diff_IV_data(:,1)/LoadResistor, Diff_IV_data(:,2)/(LockinExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (Ohm)'); title(strcat('Diff IV measurement for Josephson junction, start date and time: ', datestr(StartTime)));
    end
    
     Diff_IV_data_struct.JJCurr_Array=Diff_IV_data(:,1)/LoadResistor;
     Diff_IV_data_struct.LockInX= Diff_IV_data(:,2);
     Diff_IV_data_struct.LockInY= Diff_IV_data(:,3);

%Ramp SR865 Back to Zero
%     LockinDC.scan_time_set(60);
%     LockinDC.scan_interval_set(1);
%     LockinDC.DC_scan_begin_set(SetVolt)
%     LockinDC.DC_scan_end_set(0);
%     LockinDC.enable_scan();
%     LockinDC.run_scan();
%     LockinDC.DC=0;

    pause off;

FileName = strcat('Diff_IV_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
save(FileName,'Diff_IV_data_struct')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LockinDC.disconnect();
clear SetVolt;
clear LockinDC;