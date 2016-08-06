%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collecting SPD statistics by reseting the gJJ by bias current
% version 1.0
% Created in July 2016 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = SPD_GPIBiReset(TotalDuration, Vset, Vreset, AmplifiedVthreshold, ResetTime, WaitTime)
pause on;
DVM = deviceDrivers.Keithley2400();
DVM.connect('23');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
figure(750);
function plot_data()
    clf; plot(WaitTime*(1:1:iCount), data.dcV, '.-'); grid on;
    xlabel('Time (s)'); ylabel('dc V_{JJ} (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
iCount = 0;
Lockin.DC = Vreset;
pause(ResetTime);
Lockin.DC = Vset;
StartTime = clock;
while (TotalDuration > etime(clock, StartTime))
    iCount = iCount +1;
    data.dcV(iCount) = DVM.value;
    if data.dcV(iCount) > AmplifiedVthreshold
        Lockin.DC = Vreset;
        pause(ResetTime);
        Lockin.DC = Vset;
        data.photon(iCount) = 1;
    else
        pause(ResetTime);
        data.photon(iCount) = 0;
    end
    %plot_data();
end
data.TotalCount = iCount;
plot_data();

pause off;
DVM.disconnect(); Lockin.disconnect();
clear DVM Lockin iCount StartTime;
end