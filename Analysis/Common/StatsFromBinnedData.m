function binData = StatsFromBinnedData(binValue, binCounts)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
totalCounts=sum(binCounts);
binData.totalCounts=totalCounts;
meanValue=sum(binValue.*binCounts)/totalCounts;
binData.mean=meanValue;
SD=sqrt(sum(binCounts.*(binValue-meanValue).^2)/(totalCounts-1));
binData.std=SD;
binData.var=SD.^2;
binData.binValue=binValue;
binData.binCounts=binCounts;


end

