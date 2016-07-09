%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_IBias(BiasList, InitialWaitTime, measurementWaitTime)
StarTime = clock;
FileName = strcat('Backup', '.mat');
pause on;
%Keithley=deviceDrivers.Keithley2400();
%Keithley.connect('23');
%Yoko = deviceDrivers.YokoGS200();
%Yoko.connect('2');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
figure(999);
function plot_data()
    clf; plot(BiasList(1:k), data.X); grid on;
    xlabel('V_{bias} (V)'); ylabel('dV/dI (\Omega)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = VexcitArray(1);
Lockin.DC = BiasList(1);
pause(InitialWaitTime);
for k=1:length(BiasList)
    Lockin.DC = BiasList(k);
    pause(measurementWaitTime);
    data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
    save(FileName)
    plot_data()
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;
Lockin.DC = 0;
Lockin.disconnect(); 
pause off; clear Lockin FileName StarTime;
end