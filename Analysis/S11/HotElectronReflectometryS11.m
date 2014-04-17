% Pick out spectrums with the same parameters, i.e. same Vgate
% Then analyze the data with the same window
% ParametersList = [Vds_mV, Vgate_V, T_K]

function [ Vds_V, Freq_GHz, Spectrums ] = HotElectronReflectometryS11( FileList, ParaList, VGate)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
iTotal = 0;
for k=1:length(ParaList)
    if(ParaList(k, 2) == VGate)
        iTotal = iTotal +1 ;
        Vds_V(iTotal) = ParaList(k,1);
        MM = importdata(FileList(k,:), '\t', GetDataLineNum(FileList(k,:))+1);
        %SpecPow_W(iTotal) = 1;
        Freq_GHz = 1e-9*MM.data(:,1);
        Spectrums(iTotal,:) = MM.data(:,2);
    end
end
end

