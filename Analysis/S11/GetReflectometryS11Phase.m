% Pick out spectrums with the same parameters, i.e. same Vgate
% Then analyze the data with the same window
% ParametersList = [Vds_mV, Vgate_V, T_K]

function [ Vgate_V, Freq_GHz, S11Phase ] = GetReflectometryS11Phase( FileList, ParaList)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
iTotal = 0;
for k=1:length(ParaList)
    %if(ParaList(k, 2) == VGate)
        iTotal = iTotal +1 ;
        Vgate_V(iTotal) = ParaList(iTotal);
        MM = importdata(FileList(k,:), '\t', GetDataLineNum(FileList(k,:))+1);
        %SpecPow_W(iTotal) = 1;
        Freq_GHz = 1e-9*MM.data(:,1);
        S11Phase(iTotal,:) = MM.data(:,2)-(11136-1.601e+4.*Freq_GHz);
    %end
end
end
