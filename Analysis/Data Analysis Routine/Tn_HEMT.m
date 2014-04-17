GenerateNoiseSpectrumDataFileList
StartFreq = 0.4e9; StopFreq=2e9;
for k=1:31
% fCenter(k) = (0.01*k+0.8)*1e9;
fCenter(k) = (0.05e9*k+StartFreq);
[dummy, Freq_GHz, AvgSpecPow, T_K, AllSpectrums] = AnalyzeSpectrums(DataFileList, ParametersList, 0, fCenter(k), 100e6, 0);
[FitResult, gof] = fit(T_K(1:85)', AvgSpecPow(1:85)', 'poly1')
TNoise(k) = FitResult.p2/FitResult.p1;

    if abs(fCenter(k)-1.0e9)<0.05e9
        figure; plot(T_K, AvgSpecPow, 'd'); hold on; plot(FitResult); title(fCenter(k)); grid on;
    else if abs(fCenter(k)-8e9)<0.1e9
        figure; plot(T_K, AvgSpecPow, 'd'); hold on; plot(FitResult); title(fCenter(k)); grid on;
    end
end
end
hold on;
figure; plot(fCenter, TNoise, 'bd');
grid on;
xlabel('Freq (GHz)'); ylabel('T_N (K)'); title('Noise Temperature (K)'); ylim([0,10]);