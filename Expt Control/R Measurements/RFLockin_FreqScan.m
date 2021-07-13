%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RF lockin freq. scan
% version 1.0 in Nov 2020 by BBN Graphene Trio: KC Fong
%
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = RFLockin_FreqScan(FreqList, InitialWaitTime, measurementWaitTime)
pause on;
LockinRFTWG = deviceDrivers.SRS865();
LockinRFTWG.connect('15');
LockinRefRFTWG = deviceDrivers.SRS865();
LockinRefRFTWG.connect('20');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
LockinCurrent = deviceDrivers.SRS865();
LockinCurrent.connect('9');
RFSource = deviceDrivers.AgilentN5183A();
RFSource.connect('19');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(FreqList(1:k), data.X, '.-', FreqList(1:k), data.Y, '.-'); grid on;
    xlabel('Frequency (Hz)'); ylabel('Lockin X, Y (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%Lockin.sineFreq = FreqList(1);
RFSource.frequency = FreqList(1)*1e-9;
pause(InitialWaitTime);
for k=1:length(FreqList)
    %Lockin.sineFreq = FreqList(k);
    RFSource.frequency = FreqList(k)*1e-9;
    pause(measurementWaitTime);
    str = LockinRFTWG.query('SNAP?1,2');
    data.RFX(k) = str2num(str(1:strfind(str, ',')-1)); data.RFY(k) = str2num(str(strfind(str, ',')+1:end));
    str = LockinRefRFTWG.query('SNAP?1,2');
    data.RFrX(k) = str2num(str(1:strfind(str, ',')-1)); data.RFrY(k) = str2num(str(strfind(str, ',')+1:end));
    data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
    data.IX(k) = LockinCurrent.X; data.IY(k) = LockinCurrent.Y;
    plot_data()
end
RFSource.frequency = FreqList(1)*1e-9;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
LockinRFTWG.disconnect(); LockinRefRFTWG.disconnect(); Lockin.disconnect(); LockinCurrent.disconnect();
pause off; clear Lockin str RFSource;
end