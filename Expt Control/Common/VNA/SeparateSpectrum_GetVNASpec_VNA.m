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
VNA.connect('128.33.89.252');% New
%VNA.connect('128.33.89.237');    % Old
if VNA.averaging == '1'
    VNA.reaverage();
end
[spec.Freq spec.S] = VNA.getTrace();
VNA.disconnect();
clear VNA;

%plot left and right side of spectrum separately
figure(123); clf; plot(1e-9*spec.Freq(1:1024), 20*log10(abs(spec.S(1:1024)))); grid on;
figure(124); clf; plot(1e-9*spec.Freq(1025:2048), 20*log10(abs(spec.S(1025:2048)))); grid on;
%xlabel('Frequency (GHz)'); ylabel('S_{11} (dB)');
xlabel('Frequency (GHz)'); ylabel('S_{21} (dB)');