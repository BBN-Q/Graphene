% Analyzing the Noise Time Traces
% 1. (SKIP THIS) low pass by a 2nd order butterworth filter at a specific cutoff
% frequency
% 2. compute the mean and standard deviation of the noise; the mean is
% proportional to the graphene electron temperature while the s.d. is the
% dT
% 3. repeating procedures 1 and 2 for different time average

LP = [70];% 15 30 70 100 300];
Tau = [0.0001 0.0002 0.0005 0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.5 1];
TauPts = [10 20 50 100 200 500 1000 2000 5000 10000 20000 50000 100000];

GenerateTimeTracesDataFileList
for i = 1:length(TauPts)
    for k=1:length(LP)
        i
        k
        jTotal = 0;
        for j=1:length(T_K)
            if(ParametersList(j, 2) == LP(k));
                jTotal = jTotal+1;
                MM = importdata(DataFileList(j,:));
                AvgMicrowavePower(jTotal) = mean(MM(1:TauPts(i)));   % NoisePower is proportional to graphene electron temperature
            end
        end
        AvgP(i, k) = mean(AvgMicrowavePower);
        dP(i, k) = std(AvgMicrowavePower);
        dPoverP(i,k) = dP(i,k)/AvgP(i,k);
    end
end

%figure; semilogy(ParametersList(:,1), ParametersList(:,2),'d'); grid on;
%xlabel('Temperature (K)'); ylabel('Low Pass Frequency (MHz)'); title('Temperature Distribution');

figure; loglog(Tau, dPoverP(:,1), 'd');
for k = 2:length(LP)
    hold on; loglog(Tau, dPoverP(:,k), 'd');
end
grid on; xlabel('\tau (s)'); ylabel('\delta T/T_N + T_e'); title('Dicke Radiometer Formula');