%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_IBias_Vgate(BiasList, VgateList, InitialWaitTime, measurementWaitTime)
StarTime = clock;
FileName = strcat('Backup', '.mat');
pause on;
%GateCtrller = deviceDrivers.Keithley2400();
%GateCtrller.connect('23');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
%Thermometer = deviceDrivers.Lakeshore335();
%Thermometer.connect('12');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(899);
    clf; plot(BiasList(1:k), data.X(j,1:k),'.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('dV/dI (\Omega)');
    if k == length(BiasList) && j>1
        figure(898);
        clf; imagesc(VgateList(1:j), BiasList, data.X(1:j,:)); grid on;
        xlabel('I_{bias} (A)'); ylabel('V_{gate} (V)');
    end
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%     %%%%%%%%%%%%%%%%%%%%%%%%%
RampGateVoltage(VgateList(1), 30);
pause on;
pause(InitialWaitTime);
for j=1:length(VgateList)
    %GateCtrller.value = VgateList(j);
    RampGateVoltage(VgateList(j), 90);
    pause on;
    Lockin.DC = BiasList(1);
    pause(InitialWaitTime);
    disp(['Gate Voltage = ' num2str(VgateList(j)) ' V'])
    disp(['Time now is ' datestr(clock)])
    for k=1:length(BiasList)
        Lockin.DC = BiasList(k);
        pause(measurementWaitTime);
        data.X(j, k) = Lockin.X; data.Y(j, k) = Lockin.Y;
        %data.T(j, k) = str2num(Thermometer.query('RDGK? 5'));
        save(FileName)
        plot_data()
    end
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;
Lockin.DC = 0; % RampGateVoltage(0, 60);
Lockin.disconnect(); %GateCtrller.disconnect(); %Thermometer.disconnect();
pause off; clear Lockin FileName StarTime GateCtrller Thermometer;
end