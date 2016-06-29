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
function DC_IV_data = DC_IV_DoubleK2400meas_SRS865excite_YokoGate()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear DC_IV_data;
%close all;
fclose all;

% Connect to the instruments
Yoko=deviceDrivers.YokoGS200();
Yoko.connect('2');
KMeasJJ0=deviceDrivers.Keithley2400();
KMeasJJ0.connect('23');
KMeasJJ1=deviceDrivers.Keithley2400();
KMeasJJ1.connect('24');
Lockin=deviceDrivers.SRS865;
Lockin.connect('9');

% Initialize variables
% DataInterval = input('Time interval in temperature readout (in second) = ');
StartTime = clock;


% User Inputs
prompt='What is the load resistor on JJ0 (ohm)? ';
LoadResistor0 = input(prompt);
prompt='What is the load resistor on JJ1 (ohm)? ';
LoadResistor1 = input(prompt);
prompt = 'What is the start dc voltage (V)? ';
StartDCVoltage = input(prompt);
prompt = 'What is the end dc voltage (V)? ';
EndDCVoltage = input(prompt);
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

DC_IV_data=struct('V_Gate_Array',V_Gate_Array,'JJ0Curr_Array',JJV_Array/LoadResistor0,'JJ0_V',[],'JJ1Curr_Array',JJV_Array/LoadResistor1,'JJ1_V',[],'LoadResistor0',LoadResistor0,'LoadResistor1',LoadResistor1,'Measurement_Wait_Time',WaitTime);

FileName = strcat('DC_IV_vs_VG_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
figure; pause on;
for i = 1:GateSteps
    Yoko.value = V_Gate_Array(i);
    pause(GateWait);
    for j = 1:TotalStep
        SetVolt = JJV_Array(j);
        Lockin.DC = SetVolt;
        pause(WaitTime);
    
        DC_IV_data.JJ0_V(i,j) = KMeasJJ0.value();
        DC_IV_data.JJ1_V(i,j) = KMeasJJ1.value();
        clf;
        subplot(2,1,1)
        plot(DC_IV_data.JJ0Curr_Array(1:j), DC_IV_data.JJ0_V(i,1:j)); grid on; xlabel('Current (A)'); ylabel('Voltage (V)'); title(strcat('DC IV Measurement for JJ, ', datestr(StartTime)));
        subplot(2,1,2)
        plot(DC_IV_data.JJ1Curr_Array(1:j), DC_IV_data.JJ1_V(i,1:j)); grid on; xlabel('Current (A)'); ylabel('Voltage (V)'); title(strcat('DC IV Measurement for JJ, ', datestr(StartTime)));
    end

save(FileName,'DC_IV_data')
    if roundtripDC==0
        for j=1:TotalStep
            Lockin.DC=JJV_Back(j);
            pause(.01)
        end
    end

end


pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KMeasJJ0.disconnect();
Lockin.disconnect();
Yoko.disconnect();
clear SetVolt;
clear KMeasJJ0;
clear KMeasJJ1;
clear Yoko
clear Lockin;