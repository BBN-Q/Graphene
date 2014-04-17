% Analyzing Large Bias Heating data
% first written to analyze data from sample 105F on Sept 14, 2012
% Data files are "HotElectronEff_Vgate0.00V_T*K_*.dat" where some numbers
% SupplyBiasVoltage_V, V_diode_V, T_K, V_sd_V, TestSignalV_V

% Reading out data from files
ActiveDataSet = EPhHeatTransfer_20V_3K;
k = 5;

%MiddleIndex = int16(length(ActiveDataSet)/2);
NormalizedJohnsonSignal = ActiveDataSet(:,2); %./ActiveDataSet(:,5);
%figure; plot(ActiveDataSet(:,1), NormalizedJohnsonSignal);
%figure; plot(ActiveDataSet(:,1), ActiveDataSet(:,2));
%MinimumFitRange = 30;
%[MinimumFitResult, gof] = fit(ActiveDataSet(MiddleIndex-MinimumFitRange:MiddleIndex+MinimumFitRange,1), ActiveDataSet(MiddleIndex-MinimumFitRange:MiddleIndex+MinimumFitRange,2), 'poly2')
%hold on; plot(MinimumFitResult); grid on;
%xlabel('Supply Voltage Bias (V)'); ylabel('Normalized Johnson Signal');
% Supply Bias offset (x-offset):
%-0.5*MinimumFitResult.p2/MinimumFitResult.p1
% Normalized Johnson Signal offset (y-offset):
%MinimumFitResult.p3-MinimumFitResult.p2^2*0.25/MinimumFitResult.p1


%RunningIndex = 5;
%AvgT(RunningIndex) = mean(smooth(ActiveDataSet(:,3),'rlowess'));
AvgT = mean(smooth(ActiveDataSet(:,3),'rlowess'));
HeatingPower_W(:,k) = abs((ActiveDataSet(:,1)/988e3).*(ActiveDataSet(:,4)-min(ActiveDataSet(1,4)))); %V_graphene has an offset at -6.368838230000E-4 V
%HeatingPower_W = abs((ActiveDataSet(:,1)/217.6e3).*ActiveDataSet(:,4));
R_Ohm(:,k) = (ActiveDataSet(:,4)-min(ActiveDataSet(1,4)))./(ActiveDataSet(:,1)/988e3);
Vthermalelectric(k) = min(ActiveDataSet(1,4));
%R_Ohm = ActiveDataSet(:,4)./(ActiveDataSet(:,1)/217.6e3);
%Te_K = (ActiveDataSet(:,2)-(MinimumFitResult.p3-MinimumFitResult.p2^2*0.25/MinimumFitResult.p1))*(16/(MinimumFitResult.p3-MinimumFitResult.p2^2*0.25/MinimumFitResult.p1)) + AvgT;
%Te_K = ActiveDataSet(:,2)*((10.5+AvgT)/min(ActiveDataSet(:,2))) - 10.5;
SortedJohnsonSignal = sort(NormalizedJohnsonSignal);
Tn = 12;
CorrectedTe_K(:,k) = NormalizedJohnsonSignal*((Tn+AvgT)/mean(SortedJohnsonSignal(1:2))) - Tn;

% plot and fit the large bias data
%figure; loglog(HeatingPower_W*1e12, Te_K, '.'); grid on;
%hold on; loglog(HeatingPower_W(:,RunningIndex), Te_K(:,RunningIndex), '.'); grid on;
%xlabel('Heating Power (pW)'); ylabel('T_e (K)');
%clear ActiveDataSet, NormalizedJohnsonSignal;
%clear MinimumFitRange;
%clear RunningIndex, MiddleIndex;