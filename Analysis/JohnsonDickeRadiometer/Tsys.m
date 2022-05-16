
function result = Tsys(freq, T, PSD, bw)

%f_bound = freq(1):bw:freq(end);
f_bound = linspace(freq(1), freq(end), floor(range(freq)/bw)+1);
new_bw = range(freq)/floor(range(freq)/bw);
f_sys = f_bound(1:end-1)+new_bw/2;

for k = 1:length(f_sys)
    avg_PSD = sum(PSD(GetIndex(freq,f_bound(k)):GetIndex(freq,f_bound(k+1)),:))*new_bw;
    FitResult = fit(T', avg_PSD', 'poly1');
    result.Tsys(k) = FitResult.p2/FitResult.p1;
    result.p1(k) = FitResult.p1;
    result.avg_PSD(k, :) = avg_PSD;
    %if ((result.Tsys(k) > 0.1) && (result.Tsys(k) < 1)) && (18 == 18)
    if k == 23
        figure; plot(T, avg_PSD, 'd'); grid on; xlim([-1 1]);
        hold on; plot(FitResult);
        title(['Center Freq. = ', f_sys(k)*1e-9,' GHz']);
    end
    result.dTsys(k) = result.Tsys(k)*(sum(0.5*range(confint(FitResult))./mean(confint(FitResult))));
end
result.freq = f_sys;

figure; plot(result.freq, result.Tsys, 's-'); grid on;
xlabel('Freq. (Hz)'); ylabel('T_{sys} (K)')
set(gca, 'FontSize', 16)