% Written esp for getting Fano Factor in Experiment 063 Graphene

% Getting File Names and Parameters in the running directory
% Files are the SHOT NOISE THERMOMETRY data. Already averaged out from
% spectrums
% DataFileList
% ParametersList = [Vds_mV, Vgate_V, T_K]
FileList = ls;
iTotalSpecFile = 0;
clear DataFileList ParametersList;
%ParametersList = [];
for n=1:size(FileList,1);
    if strfind(FileList(n,:), 'ShotNoise');     %'HotElectronEff');   %'ShotNoiseThermometry');   'HotElectron');
        iTotalSpecFile = iTotalSpecFile + 1;
        DataFileList(iTotalSpecFile, :) = FileList(n,:);
        TempDataFileList(iTotalSpecFile, 1:size(FileList,2)) = FileList(n,:);
        para1 = GetParametersBtnStrings(TempDataFileList(iTotalSpecFile,:), '_T', 'K_');
        %para3 = GetParametersBtnStrings(DataFileList(iTotalSpecFile,:),
        %'_T', 'K_');
        %para2 = GetParametersBtnStrings(TempDataFileList(iTotalSpecFile,:), 'Eff_T', 'K_');
        %para3 = GetParametersBtnStrings(DataFileList(iTotalSpecFile,:), 'Vgate', 'V__T');
        ParametersList(iTotalSpecFile, :) = str2double({para1});
        %ParametersList(iTotalSpecFile) = str2double({para1});
    end
end
[ParametersList, IndexParametersList] = sort(ParametersList);
for n=1:size(TempDataFileList,1);
    DataFileList(n, 1:size(TempDataFileList, 2)) = TempDataFileList(IndexParametersList(n), :);
end
T_K = ParametersList;
clear n IndexParametersList ParametersList FileList iTotalSpecFile para1 para2 TempDataFileList; % para2 para3 TempDataFileList;