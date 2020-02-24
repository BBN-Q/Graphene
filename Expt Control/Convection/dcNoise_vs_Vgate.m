%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convection Software
% version 1.0 in July 2017 by BBN Graphene Team: KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = dcNoise_vs_Vgate(VgateList, InitialWaitTime, measurementWaitTime)
pause on;
DVM1 = deviceDrivers.Keysight34410A();
DVM1.connect('21');
DVM2 = deviceDrivers.Keysight34410A();
DVM2.connect('22');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(699); clf; plot(VgateList(1:k), data.X(1:k), 's-', VgateList(1:k), data.Y(1:k), 'o-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('DVM (V)'); legend('DVM1', 'DVM2');
    %figure(689); clf; plot(VgateList(1:k), data.Y, 'o-'); grid on;
    %xlabel('V_{bias} (V)'); ylabel('DVM (V)'); title('DVM2');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%RampGateVoltage(0, VgateList(1), 5);
SetGateVoltage(VgateList(1));
pause(InitialWaitTime);
for k=1:length(VgateList)
    SetGateVoltage(VgateList(k));
    pause(measurementWaitTime);
    data.X(k) = DVM1.value; data.Y(k) = DVM2.value;
    plot_data()
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
SetGateVoltage(0);
DVM1.disconnect(); DVM2.disconnect();
pause off; clear DVM1 DVM2;
end