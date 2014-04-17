% Analyze the Three Omega Data

GenerateNoiseSpectrumDataFileList;
Vheatinput = ParametersList(:, 1)*1e-3;
T_K = ParametersList(:,3)
Vinput_V = ParametersList(:,1)*1e-3;

clear NoisePeak_W NoiseT_V;

for k=1:length(Vheatinput)
    MM = importdata(DataFileList(k,:));
    NoiseSpectrum_W(k,:) = 0.001*10.^(0.1*MM(2,:));
    %SortedNoiseSpectrum(k,:) = sort(NoiseSpectrum_W(k,:));
    %[MaxValue, MaxIndex] = max(NoiseSpectrum_W(k,:));
    %NoisePeak_W(k) = mean(SortedNoiseSpectrum(k, 990:1000));
    %NoiseT_W(k) = (mean(SortedNoiseSpectrum(k,1:950)));
end
Freq_GHz = 0.05:0.05:50;
%Freq_GHz = MM(1,:)*1e-9;

for k=1:length(Vheatinput)
    %MaxIndex = 91;
    [MaxValue, MaxIndex] = max(NoiseSpectrum_W(k,:));
    NoisePeak_W(k) = MaxValue; %mean(NoiseSpectrum_W(k,MaxIndex-1:MaxIndex+1));
    NoiseT_W(k) = mean([NoiseSpectrum_W(k,1:MaxIndex-100) NoiseSpectrum_W(k, MaxIndex+100:1000)]);
    dNoiseT_W(k) = std([NoiseSpectrum_W(k,1:MaxIndex-100) NoiseSpectrum_W(k, MaxIndex+100:1000)]);
    %NoiseT_W(k) = mean(NoiseSpectrum_W(k, 600:900));
end

NoisePeak_V = (50*(NoisePeak_W-NoiseT_W)).^0.5;
LowerError = (50*(NoisePeak_W-NoiseT_W-2*dNoiseT_W)).^0.5-NoisePeak_V;
UpperError = (50*(NoisePeak_W-NoiseT_W+2*dNoiseT_W)).^0.5-NoisePeak_V;

%NoisePeak_V = (50*(NoisePeak_W)).^0.5;
%NoisePeak_V(1) = 0;
%figure; plot(Vinput_V, NoisePeak_V, 'd'); xlabel('V_{heat input} [V]'); ylabel('Noise Peak Voltage [V]'); title('Noise Peak'); grid on;
%xlim([0 max(Vinput_V)*1.05]); ylim([0 max(NoisePeak_V)*1.05]);
figure; errorbar(Vinput_V, NoisePeak_V, LowerError, UpperError, 'd'); xlabel('V_{heat input} [V]'); ylabel('Noise Peak Voltage [V]'); title('Noise Peak'); grid on;
xlim([0 max(Vinput_V)*1.05]); ylim([0 max(NoisePeak_V)*1.05]);
%figure; loglog(fRF, NoiseT_V, 's'); xlabel('RF Freq. [GHz]'); ylabel('Noise Temperature [a.u.]'); title('Noise Temperature'); grid on;
%figure; loglog(Tau, NoisePeak_V, 's'); xlabel('\tau [s]'); ylabel('Noise Peak Voltage [V]'); title('Noise Peak'); grid on;
Rheat = 2.7e6;
%IncidentCurrent = 0.022/Rheat;
%Vtheory = (Vrf/Rheat).^2.*(Vmod/Rheat)*27600*660/(1750e-12*23.5)*10^2.3;
%IncidentPower_W = (10^-5.2)*0.5*Vrf.^2/50;
%IncidentPower_W = (Vrf/Rheat).^2*30200;
%ModulationCurrent = 10e-9; ((10^-5.2)*0.5*0.0002^2/(50*26500))^0.5; %1e-9;

%Iteration to get heating current
%for k = 1:length(T_K)
%    HeatingCurrent(k) = 30e-9;
%end

%for k = 1:length(T_K)
%    HeatingCurrent(k) = (Vheatinput(k)^2/(21.84e6*interp2(T_Rmeas, CurrentArray,RArray,T_K(k),HeatingCurrent(k)))).^0.5;
%end
%for k = 1:length(T_K)
%    HeatingCurrent(k) = (Vheatinput(k)^2/(21.84e6*interp2(T_Rmeas, CurrentArray,RArray,T_K(k),HeatingCurrent(k)))).^0.5;
%end
%HeatingCurrent = Vheatinput/9.86e6;

%GET dRdT
%for k=1:length(T_K)
%    HeatingCurrent(k) = 10e-9;
%    if k == 1
%        dRdT(k) = 10*(interp2(T_Rmeas, CurrentArray,RArray,T_K(k)+0.1,HeatingCurrent(k))-interp2(T_Rmeas, CurrentArray,RArray,T_K(k),HeatingCurrent(k)));
%    elseif k==length(T_K)
%        dRdT(k) = 10*(interp2(T_Rmeas, CurrentArray,RArray,T_K(k),HeatingCurrent(k))-interp2(T_Rmeas, CurrentArray,RArray,T_K(k)-0.1,HeatingCurrent(k)));
%    else
%        dRdT(k) = 5*(interp2(T_Rmeas, CurrentArray,RArray,T_K(k)+0.1,HeatingCurrent(k))-interp2(T_Rmeas, CurrentArray,RArray,T_K(k)-0.1,HeatingCurrent(k)));
%    end
%    R(k) = interp2(T_Rmeas, CurrentArray,RArray,T_K(k),HeatingCurrent(k));
%    GthArray(k) = Gth(T_K(k),100);
%end

%dT = HeatingCurrent.^2.*R'./GthArray';
%Vtheory = 3*ModulationCurrent*abs(dRdT).*dT'*8.5;