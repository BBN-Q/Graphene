GenerateNoiseSpectrumDataFileList
bw = .2; % GHz
for k=1:(2/.2)
fCenter(k) = (.2*k)*1e9;
[dummy, Freq_GHz, AvgSpecPow, T_K, AllSpectrums] = AnalyzeSpectrumsSameVgate(DataFileList, ParametersList, 20, fCenter(k), bw*1e9, 0);
[FitResult, gof] = fit(T_K', AvgSpecPow', 'poly1')
TNoise(k) = FitResult.p2/FitResult.p1;

    if abs(fCenter(k)-1.1e9)< (.02*1e9)
        figure; plot(T_K, AvgSpecPow, 'd'); hold on; plot(FitResult); title(fCenter(k)); grid on;
        %else if abs(fCenter(k)-1.3e9)<0.01e9
       %figure; plot(T_K, AvgSpecPow, 'd'); hold on; plot(FitResult); title(fCenter(k)); grid on;
    %end
    end
end
hold on;
figure; plot(fCenter*1e-9, TNoise, 'd-');
grid on;
xlabel('Freq (GHz)'); ylabel('T_N (K)'); title('T_N Measurement 18a, I_{bias} = 9.9 turns and \Phi_{bias} = 0.4 turn'); ylim([0,10]);