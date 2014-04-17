% Analyzing Large Bias Heating data with Gate Sweep
% first written to analyze data from sample 104D on Oct 19, 2012
% Data files are "HotElectronEff_Vgate0.00V_T*K_*.dat" where some numbers
% Voltage Input (V);	Diode Voltage (V);	Temp_K (K); 	GrapheneVds_V;	TestSignal_V;

% Reading out data from files
GenerateHotElectronDataFileList;
Vgate = ParametersList(:,1);
VDirac = 1.8; Rload = 9.86e6;
Density = 0.0001*8.85e-12*3.9*(Vgate-VDirac)/(285e-9*1.6e-19);
figure;
for k=1:length(Vgate)
    k
    MM = importdata(DataFileList(k,:), '\t', GetDataLineNum(DataFileList(k,:))+1);
    %NormalizedJohnsonSignal(:,k) = MM.data(:,2)./MM.data(:,5);
    JohnsonSignal(:,k) = MM.data(:,2);
    %figure; plot(MM.data(:,1), NormalizedJohnsonSignal);
    AvgT(:,k) = mean(smooth(MM.data(:,3),'rlowess'));
    Current_nA(:,k) = (MM.data(:,1)/Rload)*1e9;
    HeatingPower_W(:,k) = abs((MM.data(:,1)/Rload).*(MM.data(:,4)-min(MM.data(:,4))));
    R_Ohm(:,k) = (MM.data(:,4)-min(MM.data(:,4)))./(MM.data(:,1)/Rload);
    %TnLinear = Vgate(k)*(14-9.8)/20+10;
    %Te_K(:,k) = NormalizedJohnsonSignal(:,k).*((TnLinear+AvgT(:,k))/min(NormalizedJohnsonSignal(:,k))) - TnLinear;
    if Vgate(k) == -50
        Tn = Tnoise(1)
    end
    if Vgate(k) == 1.6
        Tn = Tnoise(2)
    end
    if Vgate(k) == 30
        Tn =  Tnoise(3)
    end
    Te_K(:,k) = JohnsonSignal(:,k).*((Tn+T_K(k))/min(JohnsonSignal(:,k))) - Tn;
    
    %if abs(Vgate(k))==5
    %else
    %   Vgate(k)
    %    hold on; loglog(HeatingPower_W(:,k), Te_K(:,k), '.'); grid on;
    %    xlabel('Heating Power (W)'); ylabel('T_e (K)'); title(Vgate(k));
    %end
end

TeHeatFlux = fittype('(x/Sigma)^(1/n)', 'independent', 'x')
for k=1:length(Vgate)
    [MinValue, MinIndex] = min(abs(1e12*HeatingPower_W(:,k)-2e4))
    [EndValue, EndIndex] = min(abs(1e12*HeatingPower_W(:,k)-0.5e7));
    %EndIndex = length(HeatingPower_W);
    [FitResult, gof] = fit(1e12*HeatingPower_W(MinIndex:EndIndex,k), Te_K(MinIndex:EndIndex,k), TeHeatFlux, 'StartPoint', [1, 3])
    EPhPower(k) = FitResult.n;
    Sigma_ep(k) = FitResult.Sigma/24.55;
end