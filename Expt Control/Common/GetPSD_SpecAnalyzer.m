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
function psd = GetPSD_SpecAnalyzer()
SpecAnalyzer = deviceDrivers.AgilentN9020A();
SpecAnalyzer.connect('128.33.89.217');
[freq, spec] = SpecAnalyzer.SAGetTrace();
SpecAnalyzer.disconnect();
clear SpecAnalyzer

psd.Freq = freq; psd.PSD = (0.9495*spec.^2/3e6)';

figure(144); clf; semilogy(psd.Freq*1e-9, psd.PSD); grid on;
xlabel('Frequency (GHz)'); ylabel('S_V (V^2/Hz)');