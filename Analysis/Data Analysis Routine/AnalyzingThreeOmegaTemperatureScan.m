% Analyze the Three Omega Data

% Get the S11
S11Flag = 0;
if S11Flag == 1
GenerateS11DataFileList
S11T_K = ParametersList(:,3);
T_K = S11T_K;
for k=1:length(T_K)
    [S11Freq_GHz, S11Spectrums_dB] = GetReflectometryS11( DataFileList, ParametersList, 0.3);
    TempData(1,:) = S11Freq_GHz;
    TempData(2,:) = S11Spectrums_dB(k,:);
end
[MinValue, MinIndex] = min(abs(S11Freq_GHz-1.161));
S11Spectrums = 10.^(0.1*(S11Spectrums_dB+5));
for k=1:length(T_K)
    AvgS11(k) = mean(S11Spectrums(k, MinIndex-20:MinIndex+20));
end
end

clear ParametersList MinIndex MinValue T_K

% Get the Noise Spectrums
GenerateNoiseSpectrumDataFileList;
%Vheatinput = ParametersList(:, 1)*1e-3;
Vmod = ParametersList(:, 2);
Vheatinput = Vmod;
T_K = ParametersList(:,1)
clear NoisePeak_W NoiseT_V;
for k=1:length(T_K)
    MM = importdata(DataFileList(k,:));
    NoiseSpectrum_W(k,:) = 0.001*10.^(0.1*MM(2,:));
end
Freq_GHz = 0.05:0.05:50;
for k=1:length(T_K)
    [MaxValue, MaxIndex] = max(NoiseSpectrum_W(k,:));
    NoisePeak_W(k) = MaxValue; %mean(NoiseSpectrum_W(k,MaxIndex-1:MaxIndex+1));
    NoiseT_W(k) = mean([NoiseSpectrum_W(k,1:MaxIndex-100) NoiseSpectrum_W(k, MaxIndex+100:1000)]);
    dNoiseT_W(k) = std([NoiseSpectrum_W(k,1:MaxIndex-100) NoiseSpectrum_W(k, MaxIndex+100:1000)]);
    %NoiseT_W(k) = mean(NoiseSpectrum_W(k, 600:900));
end
NoisePeak_V = (50*(NoisePeak_W-NoiseT_W)).^0.5;
LowerError = (50*(NoisePeak_W-NoiseT_W-2*dNoiseT_W)).^0.5-NoisePeak_V;
UpperError = (50*(NoisePeak_W-NoiseT_W+2*dNoiseT_W)).^0.5-NoisePeak_V;

% Calculate the CalcVpk
%CalcVpk = (T_K.^(.5))'.*Vmod'.*(Vheatinput.^2)'.*((1-AvgS11).^(3/2).*(1000*(T_K/4).^-3)');
CalcVpk = 1.3*3*(1/25)*1e12*10^2.3*(10^-(5.2*1.5))*sqrt(0.02/11000)*0.02*abs(1000*0.15).*Vmod'.*(Vheatinput.^2)'.*((1-AvgS11).^(3/2)./(1000*(T_K/4).^(2.7))'); %(-1089+85.9*T_K)'

% Plots
%figure; errorbar(T_K, NoisePeak_V, LowerError, UpperError, 'd'); xlabel('Temperature [K]'); ylabel('Noise Peak Voltage [V]'); title('Temperature Scan'); grid on;
%xlim([0 max(T_K)*1.05]); ylim([0 max(NoisePeak_V)*1.05]);

VRatio = NoisePeak_V./CalcVpk;
VRatioLowerErr = (NoisePeak_V-LowerError)./CalcVpk-VRatio;
VRatioUpperErr = (NoisePeak_V+UpperError)./CalcVpk-VRatio;
figure; semilogy(T_K, VRatio, 'd'); xlabel('Temperature [K]'); ylabel('V_{mixing}/V_{calc} [V]'); title('Temperature Scan'); grid on;
xlim([0 max(T_K)*1.05]); %ylim([0 max(NoisePeak_V)*1.05]);
figure; errorbar(T_K, VRatio, VRatioLowerErr, VRatioUpperErr, 'd'); xlabel('Temperature [K]'); ylabel('V_{mixing}/V_{calc} [V]'); title('Temperature Scan'); grid on;
xlim([0 max(T_K)*1.05]); %ylim([0 max(NoisePeak_V)*1.05]);