% Pick out spectrums with the same parameters, i.e. same Vgate
% Then analyze the data with the same window
% ParametersList = [Vds_mV, Vgate_V, T_K]

function [Freq_GHz, Spectrums, Isd, Tmp ] = GetReflectometryS11( FileList, ParaList, cmpValue) %, GainSpec)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
iTotal = 0;
for k=1:length(ParaList)
    if((ParaList(k, 1)-cmpValue) >= 0)
        iTotal = iTotal +1 ;
        Isd(iTotal) = ParaList(k, 1);
        Tmp(iTotal) = ParaList(k, 3);
        MM = importdata(FileList(k,:));    %MM = importdata(FileList(k,:), '\t', GetDataLineNum(FileList(k,:))+1);
        %SpecPow_W(iTotal) = 1;
        %Freq_GHz = 1e-9*MM.data(:,1);
        Spectrums(iTotal,:) = MM(2,:);
        %Spectrums(iTotal,:) = MM(2,:)-GainSpec; %Spectrums(iTotal, :) = MM.data(2,:);        %Spectrums(iTotal,:) = MM.data(:,2)-GainSpec;
    end
end
Freq_GHz = MM(1,:)*1e-9;
end
