%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RF lockin freq. scan
% version 1.0 in Nov 2020 by BBN Graphene Trio: KC Fong
%
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = RFLockin_DCBiasScan(DCBiasList, InitialWaitTime, measurementWaitTime)
pause on;
LockinRFTWG = deviceDrivers.SRS865();
LockinRFTWG.connect('15');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
LockinCurrent = deviceDrivers.SRS865();
LockinCurrent.connect('9');
RFSource = deviceDrivers.AgilentN5183A();
RFSource.connect('19');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(DCBiasList(1:k), sqrt(data.RFX.^2+data.RFY.^2), 'o-'); grid on;
    xlabel('DC V Bias (V)'); ylabel('Lockin R (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%Lockin.sineFreq = FreqList(1);
Lockin.DC = DCBiasList(1);
pause(InitialWaitTime);
for k=1:length(DCBiasList)
    %Lockin.sineFreq = FreqList(k);
    Lockin.DC = DCBiasList(k);
    pause(measurementWaitTime);
    str = LockinRFTWG.query('SNAP?1,2');
    data.RFX(k) = str2num(str(1:strfind(str, ',')-1)); data.RFY(k) = str2num(str(strfind(str, ',')+1:end));
    data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
    data.IX(k) = LockinCurrent.X; data.IY(k) = LockinCurrent.Y;
    plot_data()
end


%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Lockin.DC = DCBiasList(1);
LockinRFTWG.disconnect();
pause off; clear Lockin str RFSource;
end