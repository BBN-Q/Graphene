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
function result = RampCurrBias(TargetCurrent, RampSteps, inst)
maxCurrent = 10e-3;
%assert(abs(InitVolt) < maxVoltage)
assert(abs(TargetCurrent) < maxCurrent ) 
KeithleyFlag = 1;

switch inst
    case 'K'
        CurrSource = deviceDrivers.Keithley2400();
        CurrSource.connect('23');
        KeithleyFlag = 1;
    case 'Y'
        CurrSource = deviceDrivers.YokoGS200();
        CurrSource.connect('1');
        KeithleyFlag = 0;
    otherwise
        disp(['Incorrect instrument input. Quiting.'])
        assert(1 < 0)
end   
    
    

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(338); clf; plot(CurrentList(1:k), LeakCurrent(1:k), '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('LeakCurrent (A)');
    title('Ramping Gate Voltage Monitor');
end

if KeithleyFlag == 1
    str = CurrSource.query('MEAS:CURR?'); value = str2num(str); StartCurrent = value(2);
    disp(['Starting current = ', num2str(StartCurrent), ' A'])
    str = CurrSource.query('MEAS:VOLT?');
else
    StartCurrent = CurrSource.value;
end

CurrentList = linspace(StartCurrent, TargetCurrent, abs(RampSteps)+1);
pause on;
for k = 1:length(CurrentList)
    CurrSource.value = CurrentList(k);
    %pause(round(RampTime/length(VList),1)+0.1);
    pause(1);
end
%pause off;
CurrSource.disconnect();
disp(['Successfully ramped the current from ', num2str(StartCurrent), ' A to ', num2str(TargetCurrent), ' A at ', datestr(now)])

clear CurrentList k GateController;
end