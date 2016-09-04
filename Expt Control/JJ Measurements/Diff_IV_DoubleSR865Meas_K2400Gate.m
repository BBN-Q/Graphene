%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Differential resistance measurement for 2 Josephson junctions
% with SR865 measuring resistance and providing dc bias
% Includes Gate Voltage Provided by Keithley 2400
% Modified in April 2016 by Evan Walsh
% Created in June 2015 by KC Fong and Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Diff_IV_data = Diff_IV_DoubleSR865Meas_K2400Gate()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end

%close all;
fclose all;

% Connect to the devices
Lockin0=deviceDrivers.SRS865();
Lockin0.connect('10');
Lockin1=deviceDrivers.SRS865();
Lockin1.connect('9');
K2400=deviceDrivers.Keithley2400;
K2400.connect('24');

StartTime = clock;

% Input Parameters
prompt='What is the JJ0 SR865 excitation voltage? ';
SR865ExciteVolt0 = input(prompt);
prompt='What is the load resistor on the JJ0 SR865? ';
LoadResistor0 = input(prompt);

prompt='What is the JJ1 SR865 excitation voltage? ';
SR865ExciteVolt1 = input(prompt);
prompt='What is the load resistor on the JJ1 SR865? ';
LoadResistor1 = input(prompt);

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



Diff_IV_data=struct('V_Gate_Array',V_Gate_Array,'JJ0Curr_Array',JJV_Array/LoadResistor0,'JJ1Curr_Array',JJV_Array/LoadResistor1,'LockInX0',[],'LockInY0',[],'LockInR0',[],'LockInTH0',[],'LockInX1',[],'LockInY1',[],'LockInR1',[],'LockInTH1',[],'SR865_Excite_Volt_JJ0',SR865ExciteVolt0,'SR865_Load_Resistor0',LoadResistor0,'LockIn_Time_Constant0',Lockin0.timeConstant(),'SR865_Excite_Volt_JJ1',SR865ExciteVolt1,'SR865_Load_Resistor1',LoadResistor1,'LockIn_Time_Constant1',Lockin1.timeConstant(),'Measurement_Wait_Time',WaitTime);

FileName2 = strcat('Diff_IV_vs_VG_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
figure; pause on;
for i=1:GateSteps
    SetGate = V_Gate_Array(i);
    K2400.value=SetGate;
    pause(GateWait);       
    
        for j = 1:TotalStep
            SetVolt = JJV_Array(j);
            Lockin0.DC = SetVolt;
            Lockin1.DC = SetVolt;
            pause(WaitTime);
            
            flag=1;
            while flag==1
                try                
                    [LockinX0, LockinY0] = Lockin0.get_XY();
                    [LockinR0, LockinTH0] = Lockin0.get_Rtheta();
                    flag=0;
                catch
                    flag=1;        
                end
            end
        
            flag=1;
            while flag==1
                try                
                    [LockinX1, LockinY1] = Lockin1.get_XY();
                    [LockinR1, LockinTH1] = Lockin1.get_Rtheta();
                    flag=0;
                catch
                    flag=1;        
                end
            end            
            
            Diff_IV_temp0(j,:) = [SetVolt LockinX0 LockinY0 LockinR0 LockinTH0];
            Diff_IV_temp1(j,:) = [SetVolt LockinX1 LockinY1 LockinR1 LockinTH1];

            clf;
            subplot(2,1,1)
            plot(Diff_IV_temp0(:,1)/LoadResistor0, Diff_IV_temp0(:,4)/(SR865ExciteVolt0/LoadResistor0)); grid on; xlabel('Current (A)'); ylabel('dV/dI (\Omega)'); title(strcat('Diff IV for JJ0, start date and time: ', datestr(StartTime)));
            subplot(2,1,2)
            plot(Diff_IV_temp1(:,1)/LoadResistor1, Diff_IV_temp1(:,4)/(SR865ExciteVolt1/LoadResistor1)); grid on; xlabel('Current (A)'); ylabel('dV/dI (\Omega)'); title(strcat('Diff IV for JJ1, start date and time: ', datestr(StartTime)));
            
        end
        if roundtripDC==0
            for j = 1:TotalStep
                SetVolt = JJV_Back(j);
                Lockin0.DC = SetVolt;
                Lockin1.DC = SetVolt;
                pause(.01);
            end
        end

        Diff_IV_data.LockInX0(i,:)= Diff_IV_temp0(:,2);
        Diff_IV_data.LockInY0(i,:)= Diff_IV_temp0(:,3);
        Diff_IV_data.LockInR0(i,:)= Diff_IV_temp0(:,4);
        Diff_IV_data.LockInTH0(i,:)= Diff_IV_temp0(:,5);
        
        Diff_IV_data.LockInX1(i,:)= Diff_IV_temp1(:,2);
        Diff_IV_data.LockInY1(i,:)= Diff_IV_temp1(:,3);
        Diff_IV_data.LockInR1(i,:)= Diff_IV_temp1(:,4);
        Diff_IV_data.LockInTH1(i,:)= Diff_IV_temp1(:,5);
        
        save(FileName2,'Diff_IV_data')
        
end


pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Lockin0.disconnect(); Lockin1.disconnect(); K2400.disconnect();
clear SetVolt;
clear Lockin0;
clear Lockin1;
clear K2400;

end