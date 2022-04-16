%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_IBias_vs_Freq_evaporative(BiasList, FreqList, ExcitVolt, InitialWaitTime, measurementWaitTime)
pause on;
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(BiasList(1:k), 1e9*data.X(m,1:k), '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('Lockin X (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
Lockin.sineAmp = ExcitVolt;
Lockin.DC = BiasList(1);
Lockin.sineFreq = FreqList(1);
pause(InitialWaitTime);
for m=1:length(FreqList)
    Lockin.sineFreq = FreqList(m);
    for k=1:length(BiasList)
        Lockin.DC = BiasList(k);
        pause(measurementWaitTime);
        data.X(m,k) = Lockin.X; data.Y(m,k) = Lockin.Y;
        save('backup.mat')
        plot_data()
    end
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
Lockin.DC = 0;
Lockin.disconnect(); 
pause off; clear Lockin;
end