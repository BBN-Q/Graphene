%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ramp gate voltage
% version 1.0
% Created in July 2017 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = RampGateVoltage(TargetVolt, RampSteps)
maxVoltage = 15;
%assert(abs(InitVolt) < maxVoltage)
assert(abs(TargetVolt) < maxVoltage)
GateController = deviceDrivers.Keithley2400();
GateController.connect('23');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(338); clf; plot(VList(1:k), LeakCurrent(1:k), '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('LeakCurrent (A)');
    title('Ramping Gate Voltage Monitor');
end
str = GateController.query('MEAS:VOLT?'); value = str2num(str); StartVolt = value(1);
disp(['Starting gate voltage = ', num2str(StartVolt), ' V'])
str = GateController.query('MEAS:CURR?');

VList = linspace(StartVolt, TargetVolt, abs(RampSteps)+1);
pause on;
for k = 1:length(VList)
    GateController.value = VList(k);
    %pause(round(RampTime/length(VList),1)+0.1);
    pause(0.5);
    LeakCurrent(k) = GateController.value;
    pause(0.5);
    plot_data()
end
pause off;
GateController.disconnect();
disp(['Successfully ramped to gate voltage to ', num2str(TargetVolt), ' V at ', datestr(now)])

clear VList k GateController;
end