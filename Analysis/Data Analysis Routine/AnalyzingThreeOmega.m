% Analyze the Three Omega Data

GenerateThreeOmegaDataFileList;
VDirac = 0.3;   

clear AvgNoise;

for k=1:length(Vsd)
    MM = importdata(DataFileList(k,:), '\t', GetDataLineNum(DataFileList(k,:))+1);
    NoiseSpectrum_W(k,:) = 0.001*10.^(0.1*MM.data(:,2));
    NoisePeak_W(k) = GetSpecAvg(MM.data', 1.161e9, 0.002e9);
    NoiseT_V(k) = GetSpecAvg(MM.data', 1.145e9, 0.02e9);
end
Freq_GHz = MM.data(:,1)*1e-9;

NoisePeak_V = (50*NoisePeak_W).^0.5;
%figure; plot(Vsd, NoisePeak_V, 'd');
figure; plot(Vsd.^2, NoiseT_V, 'd');