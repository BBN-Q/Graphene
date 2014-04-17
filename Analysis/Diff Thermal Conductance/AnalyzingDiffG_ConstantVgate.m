% Analyze Gth at constant gate voltage

T_K_Vgate50V = DiffThermalCond_Vgate50V(:,1);
dR_V_Vgate50V = DiffThermalCond_Vgate50V(:,2);
R_Ohm_Vgate50V = DiffThermalCond_Vgate50V(:,3);
Vexcit_V_Vgate50V = DiffThermalCond_Vgate50V(:,4);
JohnsonVolt_V_Vgate50V = DiffThermalCond_Vgate50V(:,5);

%Tbin = [0.31 0.43 0.55 0.68 0.8];
%Tbin = [0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 1 1.1 1.2 1.3];

figure; plot(T_K_Vgate50V, JohnsonVolt_V_Vgate50V, 'd');
[JohnsonFit, gof] = fit(T_K_Vgate50V(:), JohnsonVolt_V_Vgate50V(:), 'poly1')
hold on; plot(JohnsonFit);
xlabel('Temperature [K]'); ylabel('V_{diode} (V)'); title('Johnson Noise'); grid on;

dT_K_Vgate50V = dR_V_Vgate50V/JohnsonFit.p1;
%Pexcit_pW_neg8V_3GLT = (Vexcit_V_neg8V_3GLT/9.86e6).^2.*R_Ohm_neg8V_3GLT*1e12;
P_W_Vgate50V = (Vexcit_V_Vgate50V/9.86e6).^2.*R_Ohm_Vgate50V;
Gth_pWperKum2_Vgate50V = (1/sqrt(2))*P_W_Vgate50V./(dT_K_Vgate50V*25e-12);
%figure;  plot(T_K_Vgate50V, Gth_pWperKum2_Vgate50V, 's');
%xlabel('Temperature [K]'); ylabel('G_{th} [pW/K\mu m^2]'); title('Diff. Thermal Conductance'); grid on;

for k=1:length(T_K_Vgate50V)/4
    AvgT_Vgate50V(k) = mean(T_K_Vgate50V(4*k-3:4*k));
    Avg_Gth_pWperKum2_Vgate50V(k) = mean(Gth_pWperKum2_Vgate50V(4*k-3:4*k));
    SD_Gth_pWperKum2_Vgate50V(k) = std(Gth_pWperKum2_Vgate50V(4*k-3:4*k));
end
figure;  errorbar(AvgT_Vgate50V, Avg_Gth_pWperKum2_Vgate50V, SD_Gth_pWperKum2_Vgate50V, 's');
xlabel('Temperature [K]'); ylabel('G_{th} [pW/K\mu m^2]'); title('Diff. Thermal Conductance'); grid on;
    

% Averaging out the measured data
% use the GetAveragedData function