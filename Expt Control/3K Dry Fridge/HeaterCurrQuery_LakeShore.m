%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaporation cooling
% version 1.0 in August 2021 by BBN Cool-Quad Team: Mary, Caleb, Bevin, and KC
%
% Find out the heater current range from LakeShore T controller
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [curr, HeaterPower, CurrRange] = HeaterCurrQuery_Lakeshore()
    TController = deviceDrivers.Lakeshore370();
    TController.connect('12');  
    range = convertCharsToStrings(TController.query('RANGE?'));
    PercentCurrOutput = str2num(TController.query('HTR?'));
    TController.disconnect();
    
    switch str2num(range)
        case 0
            %disp('Heater is off!')
            CurrRange = 0.0;
        case 1
            CurrRange = 31.6e-6;
        case 2
            CurrRange = 100e-6;
        case 3
            CurrRange = 316e-6;
        case 4
            CurrRange = 1e-3;
        case 5
            CurrRange = 3.16e-3;
        case 6
            CurrRange = 10e-3;
        case 7
            CurrRange = 31.6e-3;
        case 8
            CurrRange = 100e-3;
        otherwise
            %disp('error')
            CurrRange = -1;
    end
    curr = PercentCurrOutput*CurrRange/100;
    HeaterPower = 200*curr*curr;
    %disp(['Heater power = ', HeaterPower])
end