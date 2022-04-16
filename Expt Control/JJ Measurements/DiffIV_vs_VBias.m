%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_VBias(BiasList, InitialWaitTime, measurementWaitTime)
pause on;
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
LockinI = deviceDrivers.SRS865();
LockinI.connect('9');


%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(BiasList(1:k), data.X, '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('Lockin X (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
LockinI.DC = BiasList(1);
pause(InitialWaitTime);
for k=1:length(BiasList)
    LockinI.DC = BiasList(k);
    pause(measurementWaitTime);
    data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
    data.IX(k) = LockinI.X; data.IY(k) = LockinI.Y;
    save('backup.mat')
    plot_data()
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
LockinI.DC = 0;
Lockin.disconnect();  LockinI.disconnect(); 
pause off; clear Lockin LockinI; 
end