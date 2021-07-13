%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_RFPower(PowerList_dBm, InitialWaitTime, measurementWaitTime)
pause on;
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
LockinCurrent = deviceDrivers.SRS865();
LockinCurrent.connect('9');
RFLockin = deviceDrivers.SRS830();
RFLockin.connect('15');
RFLockinRef = deviceDrivers.SRS830();
RFLockinRef.connect('20');
RFSource = deviceDrivers.AgilentN5183A();
RFSource.connect('19');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(PowerList_dBm(1:k), data.X, '.-'); grid on;
    xlabel('x_{bias} '); ylabel('Lockin X (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
RFSource.power = PowerList_dBm(1);
pause(InitialWaitTime);
for k=1:length(PowerList_dBm)
    RFSource.power = PowerList_dBm(k);
    pause(measurementWaitTime);
    data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
    data.IX(k) = LockinCurrent.X; data.IY(k) = LockinCurrent.Y;
    data.RFX(k) = RFLockin.X; data.RFY(k) = RFLockin.Y;
    data.RFrX(k) = RFLockinRef.X; data.RFrY(k) = RFLockinRef.Y;
    %save('backup.mat')
    plot_data()
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
RFSource.power = PowerList_dBm(1);
Lockin.disconnect(); LockinCurrent.disconnect(); RFLockin.disconnect(); RFLockinRef.disconnect();
RFSource.disconnect();
pause off; clear Lockin;
end