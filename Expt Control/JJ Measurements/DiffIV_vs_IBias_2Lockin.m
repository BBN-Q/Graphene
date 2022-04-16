%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_IBias_2Lockin(BiasList, InitialWaitTime, measurementWaitTime)
pause on;
Lockin = deviceDrivers.SRS865();
Lockin.connect('9');
LockinI = deviceDrivers.SRS865();
LockinI.connect('4');
SA = deviceDrivers.AgilentN9020A();
SA.connect('128.33.89.3')
SigGen = deviceDrivers.TekAFG3102();
SigGen.connect('11');
%Keithley = deviceDrivers.Keithley2400();
%Keithley.connect('24');
%DMM = deviceDrivers.Keysight34410A();
%DMM.connect('22');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(BiasList(1:k), data.X, '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('Lockin X (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%LockinI.DC = BiasList(1);
SigGen.offset = BiasList(1);
%Keithley.value = BiasList(1);
pause(InitialWaitTime);
for k=1:length(BiasList)
    StartTime = clock;
    %LockinI.DC = BiasList(k);
    SigGen.offset = BiasList(k);
    %Keithley.value = BiasList(k);
    pause(measurementWaitTime);
    [f, spec] = SA.SAGetTrace();
    data.Freq = f; data.Spec(k,:) = spec';
    data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
    data.IX(k) = LockinI.X; data.IY(k) = LockinI.Y;
    %data.dcCurrent(k) = DMM.value;
    save('backup.mat')
    plot_data()
    StopTime = clock;
    sprintf('Finished k = %d. It takes %e mins.', k, etime(StopTime, StartTime)/60)
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%LockinI.DC = 0;
SigGen.offset = 0;
%Keithley.value = 0;
Lockin.disconnect(); LockinI.disconnect(); SA.disconnect(); %
%SigGen.disconnect();
%DMM.disconnect();
%Keithley.disconnect();
pause off; clear Lockin;
end