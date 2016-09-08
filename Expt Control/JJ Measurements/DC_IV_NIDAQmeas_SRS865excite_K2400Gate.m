%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DC IV characteristics for a JJ. Sweeps current with SRS865 and
% measures voltage with NI-USB-6341. 
% 
% Evan Walsh, July 2015 (evanwalsh@seas.harvard.edu)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DC_IV_data = DC_IV_NIDAQmeas_SRS865excite_K2400Gate()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear DC_IV_data;
%close all;
fclose all;

% Connect to Instruments
KGate=deviceDrivers.Keithley2400();
KGate.connect('24');
Lockin=deviceDrivers.SRS865;
Lockin.connect('9');

% Initialize variables
% DataInterval = input('Time interval in temperature readout (in second) = ');
StartTime = clock;


% User Inputs
prompt='What is the load resistor (ohm)? ';
LoadResistor = input(prompt);
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
prompt = 'What is the NIDAQ sampling rate (samples/s)? ';
sampling_rate = input(prompt);
prompt = 'What is the number of NIDAQ samples per bias current? ';
num_points = input(prompt);

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

DC_IV_data=struct('V_Gate_Array',V_Gate_Array,'JJCurr_Array',JJV_Array/LoadResistor,'JJ_V',[],'Load_Resistor',LoadResistor,'Measurement_Wait_Time',WaitTime);

FileName = strcat('DC_IV_vs_VG_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');

num_points=py.int(num_points);
sampling_rate=py.int(sampling_rate);
figure; pause on;
for i = 1:GateSteps
    KGate.value = V_Gate_Array(i);
    pause(GateWait);
    for j = 1:TotalStep
        SetVolt = JJV_Array(j);
        Lockin.DC = SetVolt;
        pause(WaitTime);
        flag=0;
        while flag==0
            try
                pydata=py.take_data.take_data(num_points,sampling_rate);
                flag=1;
            catch
                flag=0;
                py.take_data.reset_device;
            end
        end
        DC_IV_data.JJ_V(i,j) = mean(double(py.array.array('d',py.numpy.nditer(pydata))));
        
        clf; plot(DC_IV_data.JJCurr_Array(1:j), DC_IV_data.JJ_V(i,1:j)); grid on; xlabel('Current (A)'); ylabel('Voltage (V)'); title(strcat('DC IV Measurement for JJ, ', datestr(StartTime)));
    end

save(FileName,'DC_IV_data')
    if roundtripDC==0
        for j=1:TotalStep
            Lockin.DC=JJV_Back(j);
            pause(.1)
        end
    end

end


pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Lockin.disconnect();
KGate.disconnect();
clear SetVolt;
clear KGate;
clear Lockin;