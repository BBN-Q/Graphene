% Pick out minimum in the shot noise thermometry spectrum
% Then analyze the data to get the Johnson Noise

function [VgrapheneArray, VapplyArray, VdiodeArray] = ReadHotElectronDataFile( FileList, ParaList, Vgate)
%function [ VsdArray, RsdArray ] = ReadHotElectronDataFile( FileList)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
iTotal = 0;
for k=1:length(ParaList)
    if(ParaList(k, 1) == Vgate)
        iTotal = iTotal +1 ;
        %Temp_K(iTotal) = ParaList(iTotal,2);
        MM = importdata(FileList(k,:), '\t', GetDataLineNum(FileList(k,:))+1);
        %VsdArray(iTotal, :) = 1e3*MM.data(:,1)';
        %SpecArray(iTotal, :) = MM.data(:,2)';
        %TmpArray(iTotal, :) = MM.data(:,3)';
        %RsdArray(iTotal, :) = 1e-3*wrev(MM.data(:,4)');  %Reversing because the ordering in the Noise Spectrum file readout (see AnalyzeSpectrums' sorting)
        %RsdArray(iTotal, :) = 1e-3*wrev(MM.data(:,4)');  %Reversing because the ordering in the Noise Spectrum file readout (see AnalyzeSpectrums' sorting)
        %IsdArray(iTotal, :) = 1e9*wrev(MM.data(:,1)');  
        %TArray(iTotal, :) = wrev(MM.data(:,3)'); 
        VgrapheneArray(iTotal, :) = (MM.data(:,4)');  %Reversing because the ordering in the Noise Spectrum file readout (see AnalyzeSpectrums' sorting)
        VapplyArray(iTotal, :) = (MM.data(:,1)');  
        VdiodeArray(iTotal, :) = (MM.data(:,2)'); 
    end
end
%   SpecArray = SpecArray*0.001;