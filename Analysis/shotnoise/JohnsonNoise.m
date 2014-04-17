% Pick out minimum in the shot noise thermometry spectrum
% Then analyze the data to get the Johnson Noise

function [ Temp_K, Vdiode_V] = JohnsonNoise( FileList, ParaList, GateV)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
iTotal = 0;
for k=1:length(ParaList)
    if(ParaList(k, 1) == GateV)
        iTotal = iTotal +1 ;
        %Temp_K(iTotal) = ParaList(iTotal,2);
        MM = importdata(FileList(k,:), '\t', GetDataLineNum(FileList(k,:))+1);
        VsdArray = MM.data(:,1);
        SpecArray = MM.data(:,2);
        TmpArray = MM.data(:,3);
        % need minimum Vsd input here
        [MinValue, MinIndex] = min(abs(VsdArray-0.004));
        %[MaxValue, MaxIndex] = min(SpecArray);
        Vdiode_V(iTotal) =  mean(SpecArray(MinIndex-2:MinIndex+2));
        Temp_K(iTotal) = mean(TmpArray(MinIndex-2:MinIndex+2));
    end
end
end

