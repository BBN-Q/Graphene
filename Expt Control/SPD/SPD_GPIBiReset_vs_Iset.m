%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collecting SPD statistics by reseting the gJJ by bias current
% version 1.0
% Created in July 2016 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = SPD_GPIBiReset_Iset(TotalDuration, Vset, Vreset, AmplifiedVthreshold, ResetTime, WaitTime)
pause on;
DVM = deviceDrivers.Keithley2400();
DVM.connect('23');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
mwSource = deviceDrivers.AgilentN5183A();
mwSource.connect('192.168.5.102');
iCount = round(TotalDuration / WaitTime);

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
figure(750);
function plot_data()
    clf; plot(sum(data.photon'), '.-'); grid on;
    xlabel('Array'); ylabel('Total Count');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
for j = 1:length(Vset)
    Lockin.DC = Vreset;
    pause(ResetTime);
    Lockin.DC = Vset(j);
    for k = 1:iCount
        pause(WaitTime);
        data.dcV(j, k) = DVM.value;
        if data.dcV(j, k) > AmplifiedVthreshold
            Lockin.DC = Vreset;
            pause(ResetTime);
            Lockin.DC = Vset(j);
            data.photon(j, k) = 1;
        else
            data.photon(j, k) = 0;
        end
        %plot_data();
    end
    plot_data();
end

pause off;
DVM.disconnect(); Lockin.disconnect(); mwSource.disconnect();
clear DVM Lockin mwSource iCount;
end