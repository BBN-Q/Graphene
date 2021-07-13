%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_Vgate(VgateList, InitialWaitTime, measurementWaitTime)
pause on;
GateController = deviceDrivers.Keithley2400();
GateController.connect('23');
%Yoko = deviceDrivers.YokoGS200();
%Yoko.connect('2');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
LockinCurrent = deviceDrivers.SRS865();
LockinCurrent.connect('9');

%Vxx2 lockin 
% Lockin2 = deviceDrivers.SRS830();
% Lockin2.connect('15');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(VgateList(1:k), data.X, '.-'); grid on;
%     hold on; plot(VgateList(1:k), data.X2, '.-'); 
%     legend('X1', 'X2');
    xlabel('V_{bias} (V)'); ylabel('Lockin X (V)');
    figure(789); clf; plot(VgateList(1:k), data.IX); grid on;
    xlabel('V_{bias} (V)'); ylabel('Lockin Current (A)');
    figure(779); clf; plot(VgateList(1:k), data.X./data.IX); grid on;
    xlabel('V_{bias} (V)'); ylabel('Resistance (\Omega)');
    figure(899); clf; plot(VgateList(1:k), data.LeakCurrent, '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('LeakCurrent (A)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
GateController.value = VgateList(1);
pause(InitialWaitTime);
for k=1:length(VgateList)
    GateController.value = VgateList(k);
    pause(measurementWaitTime);
    data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
%     data.X2(k) = Lockin2.X; data.Y2(k) = Lockin2.Y;
    data.IX(k) = LockinCurrent.X; data.IY(k) = LockinCurrent.Y;
    data.LeakCurrent(k) = GateController.value;
    plot_data()
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;
%GateController.value = 0;
Lockin.disconnect(); GateController.disconnect();
pause off; clear Lockin GateController;
end