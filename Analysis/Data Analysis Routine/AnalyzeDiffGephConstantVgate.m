% Analyzing Differential G_eph at constant gate voltage
% first written to analyze data from sample 105F on Sept 11, 2012
% Data is written by the Diff Gth program v3 with extension *.lvm
% T_K, X_V, Y_V(dT data), R_Ohm, ExcitV_V, JohnsonV_V, TestSignalV_V

% Reading out data from files
GenerateHotElectronDataFileList
Vgate = ParametersList(:,1);

for k=1:length(Vgate)
    MM = importdata(DataFileList(k,:));
    T_K(:,k) = MM(:,2);
    X_V(:,k) = MM(:,3);
    Y_V(:,k) = MM(:,4);
    R_Ohm(:,k) = MM(:,5);
    ExcitV_V(:,k) = MM(:,6);
    JohnsonV_V(:,k) = MM(:,7);
    TestSignalV_V(:,k) = MM(:,8);
end

% Johnson Noise Analysis
for k=1:length(Vgate)
    NormalizedJohnsonV(:,k) = JohnsonV_V(:,k);%./TestSignalV_V(:,k);
    [FitResult, gof] = fit(T_K(:,k), NormalizedJohnsonV(:,k),'poly1');
    %figure; plot(T_K(:,k), NormalizedJohnsonV(:,k), 'd'); hold on; plot(FitResult);
    %grid on; xlabel('T (K)'); ylabel('V_{diode} (V)'); title(Vgate(k));
    dTdV(k) = 1/FitResult.p1;
    NoiseT(k) = FitResult.p2/FitResult.p1;
end

% Calculate Gth
figure;
for k=1:length(Vgate)
    dT_K(:,k) = X_V(:,k)*dTdV(k);%(X_V(:,k)./TestSignalV_V(:,k))*dTdV(k);
    dTerror_K(:,k) = Y_V(:,k)*dTdV(k);%(Y_V(:,k)./TestSignalV_V(:,k))*dTdV(k);
    Gth_pWperKum2(:,k) = (1/25)*1e12*((ExcitV_V(:,k)/988e3).^2.*R_Ohm(:,k))./dT_K(:,k);
    dGth_pWperKum2(:,k) = Gth_pWperKum2(:,k).*dTerror_K(:,k)./dT_K(:,k);
    hold on; plot(T_K(:,k), Gth_pWperKum2(:,k), '-'); grid on;
    xlabel('T (K)'); ylabel('G_{th} (pW/K \mu m^2)'); %title(Vgate(k));
end

% Averaging and calculate the error bar
for j=1:length(Vgate)
    for k=1:length(T_K)/4
        AvgT(k,j) = mean(T_K(4*k-3:4*k,j));
        AvgGth_pWperKum2(k,j) = mean(Gth_pWperKum2(4*k-3:4*k,j));
        StdGth_pWperKum2(k,j) = std(Gth_pWperKum2(4*k-3:4*k,j));
        AvgR(k,j) = mean(R_Ohm(4*k-3:4*k,j));
    end
end
for k=1:length(Vgate)
    EstimatedDensity(k) = (1e4/(AvgR(9,k)-497)-1.75)*4.225;   % see Notebook 8, p.19 for the fitting and formula
end
figure; errorbar(AvgT, AvgGth_pWperKum2, StdGth_pWperKum2); grid on;
xlabel('T (K)'); ylabel('G_{th} (pW/K \mum^2)'); %title(Vgate(k));

% Fitting
EPhFit = fittype('Sigma*x^2', 'independent', 'x')
for k=1:length(Vgate)
    [FitResult, gof] = fit(T_K(:,k), Gth_pWperKum2(:,k), EPhFit, 'StartPoint', [1])
    %EPhPower(k) = FitResult.n;
    Sigma_ep(k) = FitResult.Sigma/(2+1);
    %Sigma_ep(k) = FitResult.Sigma/(EPhPower(k)+1);
end