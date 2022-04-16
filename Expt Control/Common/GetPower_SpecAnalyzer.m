%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Readout Power spectral density
% version 3.0
% Created in June 2019 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function power = GetPower_SpecAnalyzer()
SpecAnalyzer = deviceDrivers.AgilentN9020A();
SpecAnalyzer.connect('128.33.89.3');    % last '128.33.89.213'
[freq, spec] = SpecAnalyzer.SAGetTrace();
SpecAnalyzer.disconnect();
clear SpecAnalyzer

power.Freq = freq; power.Spec = spec;

figure(145); clf; semilogy(power.Freq*1e-9, power.Spec*1e12); grid on;
xlabel('Frequency (GHz)'); ylabel('Reflected P_{probe} (pW)');