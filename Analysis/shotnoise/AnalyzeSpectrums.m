% Pick out spectrums with the same parameters, i.e. same Vgate
% Then analyze the data with the same window
% ParametersList = [Vds_mV, Vgate_V, T_K]

function [ Vds_mV, Freq_GHz, SpecPow, Temp_K, Spectrums, CaliFactor ] = AnalyzeSpectrums( FileList, ParaList, cmpValue, CenterFreq, BandWidth, CalibrationFlag)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
iTotal = 0;
for k=1:length(ParaList)
    if((ParaList(k,3)-cmpValue) > 0)      %if(abs(ParaList(k,2)-cmpValue) == 0)
        iTotal = iTotal +1 ;
        Vds_mV(iTotal) = ParaList(k,1);
        Temp_K(iTotal) = ParaList(k,3);
        MM = importdata(FileList(k,:));
        %SpecPow_W(iTotal) = 1;
        Spectrums(iTotal,:) = 0.001*10.^(0.1*MM(2,:));  %unit in W
        Freq_GHz = MM(1,:)*1e-9;
        if CalibrationFlag == 1
            CaliFactor(iTotal) = Fit4Extremum(Freq_GHz', Spectrums(iTotal, :)', 1.7, 4, 0);
            SpecPow(iTotal) = GetSpecAvg(MM, CenterFreq, BandWidth)/CaliFactor(iTotal);
        else
            CaliFactor(iTotal) = Fit4Extremum(Freq_GHz', Spectrums(iTotal, :)', 1.7, 4, 0);
            SpecPow(iTotal) = GetSpecAvg(MM, CenterFreq, BandWidth);
        end
    end
    a = cmpValue;
end
end