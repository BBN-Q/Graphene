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
function data = RampIBias(TargetCurrent, RampSteps, inst)
maxCurrent = 1e-6;
%assert(abs(InitVolt) < maxVoltage)
assert(abs(TargetCurrent) < maxCurrent) 
KeithleyFlag = 1;

switch inst
    case 'K'
       CurrSource = deviceDrivers.Keithley2400();
       CurrSource.connect('24');
       VoltMeas = deviceDrivers.Keysight34410A();
       VoltMeas.connect('22');
        KeithleyFlag = 1;
    case 'Y'
        VoltSource = deviceDrivers.YokoGS200();
        VoltSource.connect('1');
        KeithleyFlag = 0;
    otherwise
        disp(['Incorrect instrument input. Quiting.'])
        assert(1 < 0)
end   
    
    

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(338); clf; plot(1e3*VoltDMM(1:k), 1e9*IList(1:k),'.-'); grid on;
    xlabel('V_{DMM} (mV)'); ylabel('Current (nA)');
    title('Ramping Current Monitor');
end



if KeithleyFlag == 1
    str = CurrSource.query('MEAS:VOLT?'); value = str2num(str); StartCurr = value(2);
    disp(['Starting Keithley Current = ', num2str(StartCurr), ' A'])
    str = CurrSource.query('MEAS:CURR?');
else
   StartCurr = CurrSource.value;
end

IList = linspace(StartCurr, TargetCurrent, abs(RampSteps)+1);
pause on;
for k = 1:length(IList)
    CurrSource.value = IList(k);
    %pause(round(RampTime/length(VList),1)+0.1);
    pause(0.5);
    if KeithleyFlag == 1
%       VoltKeithley(k) = CurrSource.value;
        VoltDMM(k) = VoltMeas.value;
        plot_data()
    end
    pause(0.5)
end
%pause off;
CurrSource.disconnect(); VoltMeas.disconnect();
disp(['Successfully ramped the curent from ', num2str(StartCurr), ' A to ', num2str(TargetCurrent), ' A at ', datestr(now)])

clear VList k GateController;
end