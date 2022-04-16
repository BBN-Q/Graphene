%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ramp voltage bias
% version 1.0
% Created in March 2022 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = RampVBias(TargetVolt, RampSteps, inst)
maxVoltage = 300;
%assert(abs(InitVolt) < maxVoltage)
assert(abs(TargetVolt) < maxVoltage) 
KeithleyFlag = 1;

switch inst
    case 'K'
        VoltSource = deviceDrivers.Keithley2400();
%         VoltSource.connect('23');
        VoltSource.connect('24');
        KeithleyFlag = 1;
    case 'Y'
        VoltSource = deviceDrivers.YokoGS200();
        VoltSource.connect('1');
        KeithleyFlag = 0;
    case 'L'
        VoltSource = deviceDrivers.SRS865();
        VoltSource.connect('4');
        KeithleyFlag = 0;
    otherwise
        disp(['Incorrect instrument input. Quiting.'])
        assert(1 < 0)
end   
    
    

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(338); clf; plot(VList(1:k), LeakCurrent(1:k), '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('LeakCurrent (A)');
    title('Ramping Gate Voltage Monitor');
end

if KeithleyFlag == 1
    str = VoltSource.query('MEAS:VOLT?'); value = str2num(str); StartVolt = value(1);
    disp(['Starting gate voltage = ', num2str(StartVolt), ' V'])
    str = VoltSource.query('MEAS:CURR?');
else
    StartVolt = VoltSource.value;
end

VList = linspace(StartVolt, TargetVolt, abs(RampSteps)+1);
pause on;
for k = 1:length(VList)
    VoltSource.value = VList(k);
    %pause(round(RampTime/length(VList),1)+0.1);
    pause(0.5);
    if KeithleyFlag == 1
        LeakCurrent(k) = VoltSource.value;
        plot_data()
    end
    pause(0.5)
end
%pause off;
VoltSource.disconnect();
disp(['Successfully ramped the voltage from ', num2str(StartVolt), ' V to ', num2str(TargetVolt), ' V at ', datestr(now)])

clear VList k GateController;
end