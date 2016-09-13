%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in September 2016 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result] = LockinCapturePara(length, denominator)
    Lockin = deviceDrivers.SRS865();
    Lockin.connect('4');
    eval(['Lockin.write(''CAPTURERATE ' num2str(denominator) ''')']);
    fs = str2num(Lockin.query('CAPTURERATE?'))
    ['Sampling frequency = ' num2str(fs)]
    ['Total capture time = ' num2str(length*256/fs)]
    Lockin.disconnect();
    clear Lockin fs;
end