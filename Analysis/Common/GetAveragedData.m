% number of data waves should be the ROW
% number of data points of each data wave should be the COLUMN

function [AvgMatrix, SDMatrix] = GetAveragedData( DataMatrix, CmpIndex, CmpList)
tmp = size(DataMatrix);
NumOfWaves = tmp(2);
iCheck = 0;
iCmpListIndex = 0;
for j=1:length(CmpList)
    clear tmpMatrix;
    tmpMatrix = [];
    for k=1:length(DataMatrix)
        if(abs(DataMatrix(k, CmpIndex)-CmpList(j)) < 0.015)
            iCheck = iCheck +1;
            tmpMatrix = [tmpMatrix, DataMatrix(k, :)];
        end
    end
    tmpMatrix = reshape(tmpMatrix, NumOfWaves, length(tmpMatrix)/NumOfWaves)';
    AvgMatrix(j,:) = mean(tmpMatrix);
    SDMatrix(j,:) = std(tmpMatrix);
end
iCheck
