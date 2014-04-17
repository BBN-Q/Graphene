function [ AvgX, AvgY ] = AveragingSpectrum( XData, YData, Pts )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
for k=0:(length(XData)/Pts-1)
    AvgX(k+1) = mean(XData(Pts*k+1:Pts*(k+1)));
    AvgY(k+1) = mean(YData(Pts*k+1:Pts*(k+1)));
end

