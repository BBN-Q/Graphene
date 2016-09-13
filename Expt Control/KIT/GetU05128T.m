%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the BBN calibrated thermometer temperature via lockin resistance measurement
% version 1.0
% Created in September 2016 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [T, R, ExcitPower] = GetU05128T(Vexcit)
LoadResistor = 9.95e6;
ExcitCurrent = Vexcit/LoadResistor;
load('C:\Users\qlab\Documents\data\KIT\Thermometer Calibration 2016-06\U05128.mat');

Lockin = deviceDrivers.SRS830();
Lockin.connect('9');
R = Lockin.X/ExcitCurrent; 
ExcitPower = ExcitCurrent^2*R;
T = interp1(U05128.resistance, U05128.temperature, R);
%disp(['Excitation power = ' num2str(ExcitPower) ' W'])
Lockin.disconnect();
clear Lockin;