% Analyze the Three Omega Data

GenerateNoiseSpectrumDataFileList;
VDirac = 0.3;   
fRF = ParametersList(:, 1);

clear NoisePeak_W NoiseT_V;

for k=1:length(fRF)
    MM = importdata(DataFileList(k,:));
    NoiseSpectrum_W(k,:) = 0.001*10.^(0.1*MM(2,:));
    NoisePeak_W(k) = GetSpecAvg(MM, 1.161e9, 0.002e9);
    NoiseT_V(k) = GetSpecAvg(MM, 1.17e9, 0.01e9);
end
Freq_GHz = MM(1,:)*1e-9;
Tau = 1./(4*pi*fRF*1e6);

NoisePeak_V = (50*NoisePeak_W).^0.5;
figure; loglog(fRF, NoisePeak_V, 'd'); xlabel('RF Freq. [GHz]'); ylabel('Noise Peak Voltage [V]'); title('Noise Peak'); grid on;
figure; loglog(fRF, NoisePeak_V./NoiseT_V, 'd'); xlabel('RF Freq. [GHz]'); ylabel('Noise Peak Voltage [a.u.]'); title('Normalized Noise Peak'); grid on;
figure; loglog(fRF, NoiseT_V, 's'); xlabel('RF Freq. [GHz]'); ylabel('Noise Temperature [a.u.]'); title('Noise Temperature'); grid on;

figure; loglog(Tau, NoisePeak_V, 's'); xlabel('\tau [s]'); ylabel('Noise Peak Voltage [V]'); title('Noise Peak'); grid on;