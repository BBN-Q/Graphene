% Pick out spectrums with the same parameters, i.e. same Vgate
% Then analyze the data with the same window
% ParametersList = [Vds_mV, Vgate_V, T_K]

function [yyMinValue, CenterValue, Curvature] = Fit4Extremum(xx, yy, xxCenter, HFitPts, PlotFlag)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[xxMinValue, xxMinIndex] = min(abs(xx-xxCenter));
[FitResult, gof] = fit(xx(xxMinIndex-HFitPts:xxMinIndex+HFitPts), yy(xxMinIndex-HFitPts:xxMinIndex+HFitPts), 'poly2')
yyMinValue = FitResult.p3-0.25*FitResult.p2*FitResult.p2/FitResult.p1
CenterValue = -0.5*FitResult.p2/FitResult.p1
Curvature = FitResult.p1
HDisplayPts = HFitPts*2;
maxyy = max(yy);
if PlotFlag == 1
    figure; plot(xx(xxMinIndex-HDisplayPts:xxMinIndex+HDisplayPts), yy(xxMinIndex-HDisplayPts:xxMinIndex+HDisplayPts), '.');
    hold on; plot(FitResult); %ylim([0.9*min(yy(xxMinIndex-HDisplayPts:xxMinIndex+HDisplayPts)) 1.1*max(yy(xxMinIndex-HDisplayPts:xxMinIndex+HDisplayPts))])
    grid on;
end