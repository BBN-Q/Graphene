%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = DC_IV_Keithley2400measure_Keithley2400excite(VbiasList, InitialWaitTime, measurementWaitTime)
pause on;
VoltageSource = deviceDrivers.Keithley2400();
VoltageSource.connect('24');
str = VoltageSource.query('MEAS:CURR?');

% GateSource = deviceDrivers.Keithley2400();
% GateSource.connect('23');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%

function plot_data()
    figure(338); clf; plot(1e3*VbiasList(1:k), 1e9*Current(1:k), '.-'); grid on;
    xlabel('V_{bias} (mV)'); ylabel('Current (nA)');
    title('Bias Voltage Monitor');
end
%%%%%%%%%%%%%%%%% RUN EXPERIMENT %%%%%%%%%%%%%%%%%
%     str = VoltageSource.query('MEAS:VOLT?'); value = str2num(str); StartVolt = value(1);
%     disp(['Starting gate voltage = ', num2str(StartVolt), ' V'])
%     str = VoltageSource.query('MEAS:CURR?');
% 
% VbiasList = linspace(StartVolt, TargetVolt, abs(RampSteps)+1);
% pause on;
VoltageSource.value = VbiasList(1);
pause(InitialWaitTime);
for k = 1:length(VbiasList)
    VoltageSource.value = VbiasList(k);
    pause(measurementWaitTime);
    %pause(round(RampTime/length(VList),1)+0.1);
%     pause(0.5);
    
    Current(k) = VoltageSource.value;
    plot_data()
    
    pause(0.5)
end

data.Current = Current;
%pause off;
VoltageSource.disconnect();
disp(['Successfully ramped the voltage from ', num2str(VbiasList(1)), ' V to ', num2str(VbiasList(end)), ' V at ', datestr(now)])

clear RampVBias k GateController;
end
