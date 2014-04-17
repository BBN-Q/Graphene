% Data structure:
% SpecPow_All stores all the averaged spectral power as function of Vds_mV
% and CenterFreq
% Keeping the bandwidth of the analysis window small at 10 MHz
MM = importdata(DataFileList(1,:), '\t', GetDataLineNum(DataFileList(1,:))+1);
Freq = MM.data(:,1);
bw = 0.01e9;
StartFreq = min(Freq);
clear CenterFreq AvgPowAll;
for k=1:2%(max(Freq)-StartFreq)/bw-1
    CenterFreq(k) = StartFreq+k*bw
    [Vds_mV, AvgPowAll(k, :), T_K] = AnalyzeSpectrums(DataFileList, ParametersList, 10, CenterFreq(k), bw);
end
clear bw StartFreq;
    
%for k=
%[Vds, SpecPow, T_K] = AnalyzeSpectrums(DataFileList, ParametersList, -3, 1.46e9, 0.1e9);