%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Differential resistance measurement for Josephson junction
% with SR865 measuring resistance and providing dc bias
% Includes Gate Voltage Provided by Keithley 2400
% Modified in November 2015 by Evan Walsh
% Created in June 2015 by KC Fong and Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Diff_IV_data = Diff_IV_SR865Meas_TekAFGExcite_K2400Gate_YokoHeater()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end

%close all;
fclose all;

% Connect to the devices
Lockin = deviceDrivers.SRS865();
Lockin.connect('10');
K2400=deviceDrivers.Keithley2400;
K2400.connect('24');
Yoko=deviceDrivers.YokoGS200;
Yoko.connect('2');
AFG = deviceDrivers.TekAFG3102;
AFG.connect('11');

% Initialize variables
% DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = pwd;
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Diff_IV_Gate_Heat', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Differential IV using SR865 \r\n'));
fprintf(FilePtr,'Gate\tHeat\tSR865_DC_V\tLockinX\tLockinY\tLockinR\tLockinTH\r\n');
fclose(FilePtr);

% Input Parameters
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

prompt = 'What is the start gate voltage (V)? ';
StartGate = input(prompt);
prompt = 'What is the end gate voltage (V)? ';
EndGate = input(prompt);
prompt = 'What is the step gate voltage (V)? ';
StepGate = input(prompt);
prompt = 'What is the gate wait time (s)? ';
GateWait = input(prompt);
GateSteps=(EndGate-StartGate)/StepGate+1;

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

Diff_IV_data=struct('V_Gate_Array',[],'V_Heat_Array',[],'JJCurr_Array',[],'LockInX',[],'LockInY',[],'LockInR',[],'LockInTH',[],'AFG_Excite_Volt',AFGExcitVolt,'AFG_Load_Resistor',LoadResistor,'LockIn_Time_Constant',Lockin.timeConstant(),'Measurement_Wait_Time',WaitTime,'Heater_Resistor',HeaterResistor);

figure; pause on;
for i=1:GateSteps
    SetGate = (i-1)*StepGate + StartGate;
    K2400.value=SetGate;
    Diff_IV_data.V_Gate_Array(i)=SetGate;
    pause(GateWait);
    
    for k=1:HeatSteps
        SetHeat = (k-1)*StepHeat + StartHeat;
        Yoko.value=SetHeat;
        Diff_IV_data.V_Heat_Array(k)=SetHeat;
        pause(HeatWait);
        
    
        for j = 1:TotalStep
            SetVolt = (j-1)*StepDCVoltage + StartDCVoltage;
            AFG.offset = SetVolt;
            pause(WaitTime);
            
            flag=1;
            while flag==1
                try                
                    [LockinX, LockinY] = Lockin.get_XY();
                    [LockinR, LockinTH] = Lockin.get_Rtheta();
                    flag=0;
                catch
                    flag=1;        
                end
            end
        
            Diff_IV_temp(j,:,k) = [SetVolt LockinX LockinY LockinR LockinTH];
            FilePtr = fopen(fullfile(start_dir, FileName), 'a');
            fprintf(FilePtr,'%e\t%e\t%e\t%e\t%e\t%e\t%e\r\n',Diff_IV_data.V_Gate_Array(i),Diff_IV_data.V_Heat_Array(k),Diff_IV_temp(j,:,k));
            fclose(FilePtr);
            clf; plot(Diff_IV_temp(:,1,k)/LoadResistor, Diff_IV_temp(:,4,k)/(AFGExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (\Omega)'); title(strcat('Diff IV for JJ, start date and time: ', datestr(StartTime)));
        end
        for j = 1:TotalStep
            SetVolt = (TotalStep-j)*StepDCVoltage + StartDCVoltage;
            AFG.offset = SetVolt;
            pause(.1);
        end
        Diff_IV_data.JJCurr_Array=Diff_IV_temp(:,1,k)/LoadResistor;
        Diff_IV_data.LockInX(i,:,k)= Diff_IV_temp(:,2,k);
        Diff_IV_data.LockInY(i,:,k)= Diff_IV_temp(:,3,k);
        Diff_IV_data.LockInR(i,:,k)= Diff_IV_temp(:,4,k);
        Diff_IV_data.LockInTH(i,:,k)= Diff_IV_temp(:,5,k);
        
    end
    for k = 1:HeatSteps
        SetHeat = (HeatSteps-k)*StepHeat + StartHeat;
        Yoko.value = SetHeat;
        pause(.1);
    end
    
    
end

Diff_IV_data.V_Gate_Array=Diff_IV_data.V_Gate_Array';

FileName = strcat('Diff_IV_vs_VGHEAT', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
save(FileName,'Diff_IV_data')

%Ramp K2400 back to 0V
% i=0;
% while SetGate~=0
%     i=i+1;
%     SetGate = (GateSteps-i)*StepGate + StartGate;
%     K2400.value=SetGate;
%     pause(1);
% end

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
Lockin.disconnect(); K2400.disconnect(); AFG.disconnect; Yoko.disconnect();
clear SetVolt;
clear Lockin;
clear K2400;
clear Yoko;
clear AFG;
end