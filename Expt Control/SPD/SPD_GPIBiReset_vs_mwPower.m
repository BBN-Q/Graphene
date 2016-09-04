%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collecting SPD statistics by reseting the gJJ by bias current
% version 1.0
% Created in July 2016 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = SPD_GPIBiReset_mwPower(TotalDuration, Vset, Vreset, AmplifiedVthreshold, mwPowerList, ResetTime, WaitTime)
pause on;
DVM = deviceDrivers.Keithley2400();
DVM.connect('23');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
mwSource = deviceDrivers.AgilentN5183A();
mwSource.connect('192.168.5.102');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
figure(750);
function plot_data()
    clf; plot(sum(data.photon'), '.-'); grid on;
    xlabel('Freq Array'); ylabel('Total Count');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
for j = 1:length(mwPowerList)
    mwSource.power = mwPowerList(j);
    iCount = 0;
    Lockin.DC = Vreset;
    pause(ResetTime);
    Lockin.DC = Vset;
    StartTime = clock;
    while (TotalDuration > etime(clock, StartTime))
        iCount = iCount +1;
        data.dcV(j, iCount) = DVM.value;
        if data.dcV(j, iCount) > AmplifiedVthreshold
            Lockin.DC = Vreset;
            pause(ResetTime);
            Lockin.DC = Vset;
            data.photon(j, iCount) = 1;
        else
            pause(ResetTime);
            data.photon(j, iCount) = 0;
        end
        %plot_data();
    end
    data.TotalCount = iCount;
    plot_data();
end

pause off;
DVM.disconnect(); Lockin.disconnect(); mwSource.disconnect();
clear DVM Lockin mwSource iCount;
end