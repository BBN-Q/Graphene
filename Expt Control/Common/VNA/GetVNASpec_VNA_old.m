%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Readout VNA Spectrum
% version 2.0
% Created in June 2014 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function spec = GetVNASpec_VNA()

VNA = deviceDrivers.AgilentE8363C();
%VNA.connect('16');
VNA.connect('128.33.89.251');   % Old
%VNA.connect('128.33.89.252');   % New
if VNA.averaging == '1'
    VNA.reaverage();
end
[spec.Freq spec.S] = VNA.getTrace();
VNA.disconnect();
clear VNA;

figure(124); clf; plot(spec.Freq*1e-9, 20*log10(abs(spec.S))); grid on;
xlabel('Frequency (GHz)'); ylabel('S_{11} (dB)');
%xlabel('Frequency (GHz)'); ylabel('S_{21} (dB)');