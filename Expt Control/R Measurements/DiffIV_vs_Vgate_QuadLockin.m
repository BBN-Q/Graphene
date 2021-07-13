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

function [data, data2] = DiffIV_vs_Vgate(VgateList, InitialWaitTime, measurementWaitTime)
pause on;
GateController = deviceDrivers.Keithley2400();
GateController.connect('23');
%Yoko = deviceDrivers.YokoGS200();
%Yoko.connect('2');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
LockinCurrent = deviceDrivers.SRS830();
LockinCurrent.connect('9');

Lockin2 = deviceDrivers.SRS865();
Lockin2.connect('15');
LockinCurrent2 = deviceDrivers.SRS830();
LockinCurrent2.connect('20');

%Vxx2 lockin 
% Lockin2 = deviceDrivers.SRS830();
% Lockin2.connect('15');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); subplot(4, 1, 1);
    cla; plot(VgateList(1:k), data.X, '.-'); grid on;
    ylabel('Lockin X (V)'); title('data1');
    set(gca, 'XTickLabel', []);
    subplot(4, 1, 2); cla; plot(VgateList(1:k), data.IX); grid on;
    ylabel('Lockin Current (A)'); set(gca, 'XTickLabel', []);
    subplot(4, 1, 3); cla; plot(VgateList(1:k), data.X./data.IX); grid on;
    ylabel('R_{xx} (\Omega)'); set(gca, 'XTickLabel', []);
    subplot(4, 1, 4); cla; plot(VgateList(1:k), data.LeakCurrent, '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('LeakCurrent (A)');
end

function plot_data2()
    figure(699); subplot(4, 1, 1);
    cla; plot(VgateList(1:k), data2.X, '.-'); grid on;
    ylabel('Lockin X (V)'); title('data2'); set(gca, 'XTickLabel', []);
    subplot(4, 1, 2); cla; plot(VgateList(1:k), data2.IX); grid on;
    ylabel('Lockin Current (A)'); set(gca, 'XTickLabel', []);
    subplot(4, 1, 3); cla; plot(VgateList(1:k), data2.X./data2.IX); grid on;
    ylabel('R_{xx} (\Omega)'); set(gca, 'XTickLabel', []);
    subplot(4, 1, 4); cla; plot(VgateList(1:k), data2.LeakCurrent, '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('LeakCurrent (A)'); 
end


%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
GateController.value = VgateList(1);
pause(InitialWaitTime);
for k=1:length(VgateList)
    GateController.value = VgateList(k);
    pause(measurementWaitTime);
    data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
    data.IX(k) = LockinCurrent.X; data.IY(k) = LockinCurrent.Y;
    data.LeakCurrent(k) = GateController.value;
    data2.X(k) = Lockin2.X; data2.Y(k) = Lockin2.Y;
    data2.IX(k) = LockinCurrent2.X; data2.IY(k) = LockinCurrent2.Y;
    data2.LeakCurrent(k) = data.LeakCurrent(k);

    plot_data()
    plot_data2()
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;
%GateController.value = 0;
Lockin.disconnect(); GateController.disconnect();
pause off; clear Lockin GateController;
end