% Analyze Gth at large gate bias

GenerateDiffGDataFileList
VDirac = 0.7;   

for k=1:length(T_K)
    k
    MM = importdata(DataFileList(k,:), '\t', GetDataLineNum(DataFileList(k,:))+1);
    %size(MM.data)
    dX(k,:) = MM.data(:,3); % measured by lock-in
    dY(k,:) = MM.data(:,4);
    R_Ohm(k,:) = MM.data(:,5);
    ExcitCurrent(k,:) = MM.data(:,6); % unit: pW
    JohnsonVoltage(k,:) = MM.data(:,7); % unit: V; measured by Keithley multimeter
    MeasuredT(k,:) = MM.data(:,9);% unit: K
end

Vgate = MM.data(:,1);
Density = 0.0001*8.85e-12*4*(Vgate-VDirac)/(100e-9*1.6e-19); % unit: cm^-2

% Smooth out the measured temperature data
for k=1:length(T_K)
    T_K(k) = mean(smooth(Vgate, MeasuredT(k,:), 0.1, 'rloess'));
    dT_K(k) = std(smooth(Vgate, MeasuredT(k,:), 0.1, 'rloess'));
end

% Calibration of Johnson Noise
for k=1:length(Vgate)
    [JohnsonFit, gof] = fit(T_K(1:10), JohnsonVoltage(1:10,k), 'poly1')
    %[JohnsonFit, gof] = fit(T_K(:), JohnsonVoltage(:,k), 'poly1')
    TNoise(k) = JohnsonFit.p2/JohnsonFit.p1;
    dTdV(k) = 1/(JohnsonFit.p1);
    if(mod(k+7,8) == 0)
        if(k==1)
            figure;
        end
        hold on; plot(T_K, JohnsonVoltage(:,k), 'd'); xlim([.3  1.5]);
        hold on; plot(JohnsonFit); xlabel('Temperature [K]'); ylabel('Johnson Noise [V]'); title(Vgate(k));
    end
end

for k=1:length(T_K)
    dTe_K(k,:) = dX(k,:).*dTdV;
end
Gth = 0.01*(ExcitCurrent.^2.*R_Ohm)./dTe_K;
figure; plot(Density, Gth); xlabel('Density [cm^{-2}]'); ylabel('G_{th} [pW/K\mum^2]'); title('Differential Thermal Conductance'); grid on;

figure;
for k=1:length(Vgate)
    if(mod(k+7,8) == 0)
        hold on; plot(T_K, JohnsonVoltage(:,k), 'd'); grid on;
    end
end
xlabel('Temperature [K]'); ylabel('V_{diode} [V]'); title('Johnson Noise Calibration'); grid on;

figure;
for k=1:length(Vgate)
    if(mod(k+7,8) == 0)
        hold on; plot(T_K, Gth(:,k), 's'); grid on;
    end
end
xlabel('Temperature [K]'); ylabel('G_{th} [pW/K\mu m^2]'); title('Diff. Thermal Conductance'); grid on;

% Wiedemann-Franz Analysis
for k=1:length(Vgate)
    [WFFitResult, gof] = fit(T_K(1:10)./R_Ohm(1:10,k), Gth(1:10,k), 'poly1');
    CI = confint(WFFitResult, 0.68);
    NormLorenz(k) = 100*WFFitResult.p1/(12*2.44e-8);
    dNormLorenz(k) = 0.5*abs(CI(1,1)-CI(2,1))*100/(12*2.44e-8);
    OffsetGth(k) = WFFitResult.p2;
    dOffsetGth(k) = 0.5*abs(CI(1,2)-CI(2,2));
end
figure; errorbar(Vgate, NormLorenz, dNormLorenz, 'd'); grid on;
xlabel('Gate Voltage (V)'); ylabel('L_{meas}/L_0'); title('Normalized Lorenz Number');
%xlabel('Gate Voltage (V)'); ylabel('G_{th} Offset (pW/K \mu^2 m)'); title('G_{th} Offset');