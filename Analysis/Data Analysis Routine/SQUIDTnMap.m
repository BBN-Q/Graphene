GenerateNoiseSpectrumDataFileList
NoiseSpecFileList = DataFileList;
GenerateS11DataFileList
S11SpecFileList = DataFileList;

CurrentBiasT = ParametersList(:,1);
FluxBiasT = ParametersList(:,2);
Temp = ParametersList(:,3);

BiasCurrentInPlot = min(CurrentBiasT):0.05:max(CurrentBiasT);
FluxBiasInPlot = min(FluxBiasT):0.05:max(FluxBiasT);
NGRatio = zeros(length(BiasCurrentInPlot),length(FluxBiasInPlot));
EstTn = ones(length(BiasCurrentInPlot),length(FluxBiasInPlot));
EstTn = 10*EstTn;

fCenter = 1.35e9; bw = 50e6;

[dummy1, Freq_GHz, AvgNoiseSpec_mW, dummy2, AllNoiseSpectrums] = AnalyzeSpectrums(NoiseSpecFileList, ParametersList, 0, fCenter, bw, 0);
[dummy1, Freq_GHz, AvgS11Spec, dummy2, AllS11Spectrums] = AnalyzeSpectrums(S11SpecFileList, ParametersList, 0, fCenter, bw, 0);
AllS11Spectrums = 1000*AllS11Spectrums;
AvgS11Spec = AvgS11Spec*1000;
Telec = 0.38
RtoT = (Telec + 1000)/2e-8;

for m=1:length(Temp)
    [dummy3, CurrentIndex] = min(abs(BiasCurrentInPlot-CurrentBiasT(m)));
    [dummy3, FluxIndex] = min(abs(FluxBiasInPlot-FluxBiasT(m)));
    NGRatio(CurrentIndex, FluxIndex) = AvgNoiseSpec_mW(m)/AvgS11Spec(m);
    EstTn(CurrentIndex, FluxIndex) = NGRatio(CurrentIndex, FluxIndex)*RtoT;
end

%figure;
%surf( FluxBiasInPlot, BiasCurrentInPlot, NGRatio)
%xlabel('Flux Bias (turns)'); ylabel('Current Bias (turns)'); zlabel('Noise-to-Gain Ratio'); title('Noise-to-Gain Ratio');
%figure;
%surf( FluxBiasInPlot, BiasCurrentInPlot, EstTn)
%xlabel('Flux Bias (turns)'); ylabel('Current Bias (turns)'); zlabel('T_N (K)'); title('Estimated T_N');

figure; [AX,H1,H2] = plotyy(FluxBiasInPlot, AvgS11Spec, FluxBiasInPlot, AvgNoiseSpec_mW);
set(get(AX(1),'Ylabel'),'String','Avg. Gain');
set(get(AX(2),'Ylabel'),'String','Avg. Noise (mW)');
xlabel('Flux bias (turns)'); title('Optimization 25, Current bias = 9.0 turns, f_{center} = 1.6 GHz'); grid on;
figure; semilogy(FluxBiasInPlot, NGRatio, 'd-');
xlabel('Flux bias (turns)'); ylabel('Avg. Noise-to-Gain Ratio'); title('Optimization 25, Current bias = 9.0 turns, f_{center} = 1.6 GHz'); grid on;