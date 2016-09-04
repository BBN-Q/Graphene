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
function Diff_IV_data = Diff_IV_SR865Meas_K2400Gate()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end

%close all;
fclose all;

% Connect to the devices
Lockin = deviceDrivers.SRS865();
Lockin.connect('9');
K2400=deviceDrivers.Keithley2400;
K2400.connect('24');

% Initialize variables
StartTime = clock;

% Input Parameters
prompt='What is the SR865 excitation voltage? ';
SR865ExciteVolt = input(prompt);
prompt='What is the load resistor on the SR865? ';
LoadResistor = input(prompt);

prompt = 'What is the start dc voltage (V)? ';
StartDCVoltage = (input(prompt));
prompt = 'What is the end dc voltage (V)? ';
EndDCVoltage = (input(prompt));
prompt = 'What is the step dc voltage (V)? ';
StepDCVoltage = input(prompt);
prompt = 'One way (0) or round trip (1)? ';
roundtripDC=input(prompt);
prompt = 'What is the wait time (s)? ';
WaitTime = input(prompt);
[JJV_Array, TotalStep]=V_Array(StartDCVoltage,EndDCVoltage,StepDCVoltage,roundtripDC);
if roundtripDC==0
    JJV_Back = V_Array(EndDCVoltage,StartDCVoltage,-StepDCVoltage,roundtripDC);
end

prompt = 'What is the start gate voltage (V)? ';
StartGate = input(prompt);
prompt = 'What is the end gate voltage (V)? ';
EndGate = input(prompt);
prompt = 'What is the step gate voltage (V)? ';
StepGate = input(prompt);
prompt = 'One way (0) or round trip (1)? ';
roundtripGate=input(prompt);
prompt = 'What is the gate wait time (s)? ';
GateWait = input(prompt);
[V_Gate_Array, GateSteps]=V_Array(StartGate,EndGate,StepGate,roundtripGate);



Diff_IV_data=struct('V_Gate_Array',V_Gate_Array,'JJCurr_Array',JJV_Array/LoadResistor,'LockInX',[],'LockInY',[],'LockInR',[],'LockInTH',[],'SR865_Excite_Volt',SR865ExciteVolt,'SR865_Load_Resistor',LoadResistor,'LockIn_Time_Constant',Lockin.timeConstant(),'Measurement_Wait_Time',WaitTime);

FileName2 = strcat('Diff_IV_vs_VG_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
figure; pause on;
for i=1:GateSteps
    SetGate = V_Gate_Array(i);
    K2400.value=SetGate;
    pause(GateWait);       
    
        for j = 1:TotalStep
            SetVolt = JJV_Array(j);
            Lockin.DC = SetVolt;
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
        
            Diff_IV_temp(j,:) = [SetVolt LockinX LockinY LockinR LockinTH];
            clf; plot(Diff_IV_temp(:,1)/LoadResistor, Diff_IV_temp(:,4)/(SR865ExciteVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (\Omega)'); title(strcat('Diff IV for JJ, start date and time: ', datestr(StartTime)));
        end
        if roundtripDC==0
            for j = 1:TotalStep
                SetVolt = JJV_Back(j);
                Lockin.DC = SetVolt;
                pause(.1);
            end
        end

        Diff_IV_data.LockInX(i,:)= Diff_IV_temp(:,2);
        Diff_IV_data.LockInY(i,:)= Diff_IV_temp(:,3);
        Diff_IV_data.LockInR(i,:)= Diff_IV_temp(:,4);
        Diff_IV_data.LockInTH(i,:)= Diff_IV_temp(:,5);
        
        save(FileName2,'Diff_IV_data')
        
end


pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Lockin.disconnect(); K2400.disconnect();
clear SetVolt;
clear Lockin;
clear K2400;

end