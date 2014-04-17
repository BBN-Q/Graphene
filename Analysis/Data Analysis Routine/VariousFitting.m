if 1 == 1
    EPhFit = fittype('Sigma*x^n', 'independent', 'x')
    %EPhFit = fittype('Sigma*x^n + 5', 'independent', 'x')
    %EPhFit = fittype('Sigma*x^2 + u', 'independent', 'x')
    for k=1:length(Density)
        [FitResult, gof] = fit(AvgT, AvgGth(:,k), EPhFit, 'StartPoint', [1, 2])
        %[FitResult, gof] = fit(T_K, Gth(:,k), EPhFit, 'StartPoint', [1, 0.01])
        %[FitResult, gof] = fit(T_K, Gth(:,k), EPhFit, 'StartPoint', [1])
        EPhPower(k) = FitResult.n + 1;
        Sigma_ep(k) = FitResult.Sigma/(EPhPower(k));
        %Sigma_ep(k) = FitResult.Sigma/(3);
        %Sigma_ep(k) = FitResult.Sigma/(2+1);
        figure; loglog(T_K, Gth(:,k), 'd'); hold on;
        plot(FitResult); xlim([1,10]); grid on; title(Vgate(k));
        RangeMatrix = confint(FitResult, 0.68);
        dSigma_ep(k) = 0.5*diff(RangeMatrix(:,1));
        dEPhPower(k) = 0.5*diff(RangeMatrix(:,2));
        %Offset(k) = FitResult.u;
    end
    figure; errorbar(Density, EPhPower, dEPhPower, 'rs-'); grid on;
    figure; errorbar(Density, Sigma_ep, dSigma_ep, 'bd-'); grid on;
else
    for k=1:101
        [FitResult, gof] = fit(log(AvgT), log(AvgGth(:,k)), 'poly1')
        EPhPower(k) = FitResult.p1 + 1;
        Sigma_ep(k) = exp(FitResult.p2)/(EPhPower(k));
        RangeMatrix = confint(FitResult, 0.68);
        dEPhPower(k) = 0.5*diff(RangeMatrix(:,1));
        dSigma_ep(k) = 0.5*diff(RangeMatrix(:,2))*Sigma_ep(k);
    end
    figure; errorbar(Density, EPhPower, dEPhPower, 'rs-'); grid on;
    figure; errorbar(Density, Sigma_ep, dSigma_ep, 'bd-'); grid on;
end

