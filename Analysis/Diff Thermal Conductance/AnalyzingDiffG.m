% Analyze the S11 in Gate Voltage Sweep
% Constant or no heating power applied

GenerateDiffGDataFileList
VDirac = 1.7;   

for k=1:length(T_K)
    k
    MM = importdata(DataFileList(k,:), '\t', GetDataLineNum(DataFileList(k,:))+1);
    %size(MM.data)
    TestSignal(k,:) = MM.data(:,8); % unit: V; measured by Spectrum analyzer    
    dX(k,:) = MM.data(:,3);%./MM.data(:,8); % measured by lock-in
    dY(k,:) = MM.data(:,4);%./MM.data(:,8);
    R_Ohm(k,:) = MM.data(:,5);
    ExcitPower(k,:) = 1e12*MM.data(:,6).^2.*MM.data(:,5); % unit: pW
    JohnsonVoltage(k,:) = MM.data(:,7);%./MM.data(:,8); % unit: V; measured by Keithley multimeter
    MeasuredT(k,:) = MM.data(:,9);% unit: K
end

Vgate = MM.data(:,1);
Density = 0.0001*8.85e-12*3.9*(Vgate-VDirac)/(285e-9*1.6e-19); % unit: cm^-2

% Smooth out the measured temperature data
for k=1:length(T_K)
    T_K(k) = mean(smooth(Vgate, MeasuredT(k,:), 0.1, 'rloess'));
    dT_K(k) = std(smooth(Vgate, MeasuredT(k,:), 0.1, 'rloess'));
    %T_K(k) = mean(smooth(MeasuredT(k,2:13), 0.1, 'rloess'));
    %dT_K(k) = std(smooth(MeasuredT(k,2:13), 0.1, 'rloess'));
end

% Calibration of Johnson Noise
figure;
for k=1:length(Vgate)
    [JohnsonFit, gof] = fit(T_K, JohnsonVoltage(:,k), 'poly1')
    TNoise(k) = JohnsonFit.p2/JohnsonFit.p1;
    dTdV(k) = 1/(JohnsonFit.p1);
    %if(mod(k,9) == 0)
    %figure;
    %    hold on; plot(T_K, JohnsonVoltage(:,k), 'd');
    %    hold on; plot(JohnsonFit); xlabel('Temperature [K]'); ylabel('Johnson Noise [V]'); title(Vgate(k));
    %end
end

for k=1:length(Vgate)
    dTe_K(:,k) = dX(:,k)*dTdV(k);
    ErrdTe_K(:,k) = dY(:,k)*dTdV(k);
    %dTe_K(:,k) = dX(:,k)*578039;
end
Gth = (1/sqrt(2))*(1/24.55)*ExcitPower./dTe_K;
figure; plot(Density, Gth); xlabel('Density [cm^{-2}]'); ylabel('G_{th} [pW/K\mum^2]'); title('Differential Thermal Conductance'); grid on;

% Fitting
EPhFit = fittype('Sigma*x^n', 'independent', 'x')
%EPhFit = fittype('Sigma*x^2+g0', 'independent', 'x')
%EPhFit = fittype('Sigma*x^2', 'independent', 'x')
for k=1:length(Vgate)
    [FitResult, gof] = fit(T_K, Gth(:,k), EPhFit, 'StartPoint', [1, 2])
    %[FitResult, gof] = fit(T_K, Gth(:,k), EPhFit, 'StartPoint', [1, 0.01])
    %[FitResult, gof] = fit(T_K, Gth(:,k), EPhFit, 'StartPoint', [1])
    EPhPower(k) = FitResult.n+1;
    Sigma_ep(k) = FitResult.Sigma/(EPhPower(k));
    %Sigma_ep(k) = FitResult.Sigma/(2+1);
    %figure; loglog(T_K, Gth(:,k), 'd'); hold on;
    %plot(FitResult); xlim([1,10]); grid on; title(Vgate(k));
    RangeMatrix = confint(FitResult, 0.68);
    dSigma_ep(k) = 0.5*diff(RangeMatrix(:,1));
    dEPhPower(k) = 0.5*diff(RangeMatrix(:,2));
end
figure; errorbar(Density, EPhPower, dEPhPower, 'rs-'); grid on;
figure; errorbar(Density, Sigma_ep, dSigma_ep, 'bd-'); grid on;
%figure; plot(Density, Sigma_ep, 'd-'); grid on;