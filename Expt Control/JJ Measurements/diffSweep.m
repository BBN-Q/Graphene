%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in September 2016 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = diffSweep(BiasRange, SweepTime, CaptureLength, CaptureRateDenominator, InitialWaitTime)
% up and down ramp from low to high bias current value
pause on;
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(567); clf; plot(data.time, data.X, '.-'); grid on;
    xlabel('time (s)'); ylabel('Lockin X (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
eval(['Lockin.write(''SCNSEC ' num2str(SweepTime) ''');']);
eval(['Lockin.write(''SCNDC BEGIN,' num2str(BiasRange(1)) 'V'');']);
eval(['Lockin.write(''SCNDC END,' num2str(BiasRange(2)) 'V'');']);
eval(['Lockin.write(''CAPTURELEN ' num2str(CaptureLength) ''');']);
eval(['Lockin.write(''CAPTURERATE ' num2str(CaptureRateDenominator) ''');']);
data.fs = str2num(Lockin.query('CAPTURERATE?'));
TotalTime = CaptureLength*256 / data.fs;
Lockin.write('SCNENBL OFF');
Lockin.write('SCNENBL ON');

Lockin.write('SCNRST');
Lockin.DC = BiasRange(1);
pause(InitialWaitTime);
Lockin.write('SCNRUN; CAPTURESTART ONE, OFF');
pause(1.05*TotalTime);
if str2num(Lockin.query('CAPTURESTAT?')) == 6
    eval(['Lockin.write(''CAPTUREGET? 0,' num2str(CaptureLength) ''');']);
    OneSweep = Lockin.binblockread();
    data.X = typecast(uint8(OneSweep), 'single');
    data.time = linspace(0, TotalTime, length(data.X));
    %plot_data();
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
Lockin.write('SCNRST');
Lockin.disconnect();
pause off; clear Lockin OneSweep TotalTime;
end