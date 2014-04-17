% Analyze the Three Omega Data

GenerateNoiseSpectrumDataFileList;
Vrf = ParametersList(:, 1)*1e-3;
HeatPower_W = Vrf.^2/50;

clear NoisePeak_W NoiseT_V TempSpec;

for k=1:length(Vrf)
    MM = importdata(DataFileList(k,:));
    NoiseSpectrum_W(k,:) = 0.001*10.^(0.1*MM(2,:));
    %TempSpec = [NoiseSpectrum_W(k,1:695-20) NoiseSpectrum_W(k,695+20:length(NoiseSpectrum_W(k,:)))];
    %NoisePeak_W(k) = mean(NoiseSpectrum_W(k,MaxIndex-3:MaxIndex+3));
    %NoiseT_W(k) = mean(NoiseSpectrum_W(k,351:651));
    NoiseT_W(k) = mean(NoiseSpectrum_W(k,:));
end
Freq_GHz = MM(1,:)*1e-9;

figure; plot(Vrf.^2, NoiseT_W, 'd');