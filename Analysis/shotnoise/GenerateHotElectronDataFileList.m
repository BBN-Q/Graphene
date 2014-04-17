% Getting File Names and Parameters in the running directory
% The spectrums measured and recorded by spectrum analyzer
% DataFileList
% ParametersList = [Vds_mV, Vgate_V, T_K]
FileList = ls;
iTotalSpecFile = 0;
clear DataFileList ParametersList;

for n=1:size(FileList,1);
    if strfind(FileList(n,:),'HotElectronEff_');
        iTotalSpecFile = iTotalSpecFile + 1;
        %DataFileList(iTotalSpecFile, :) = FileList(n,:);
        TempDataFileList(iTotalSpecFile, 1:size(FileList,2)) = FileList(n,:);
        para1 = GetParametersBtnStrings(TempDataFileList(iTotalSpecFile,:), 'HotElectronEff_Vgate', 'V_');
        %para1 = GetParametersBtnStrings(DataFileList(iTotalSpecFile,:), 'ShotNoise_Vgate', 'V__T');
        %para2 = GetParametersBtnStrings(TempDataFileList(iTotalSpecFile,:), 'Vgate', 'V_T');
        para3 = GetParametersBtnStrings(TempDataFileList(iTotalSpecFile,:), 'V_T', 'K_');
        ParametersList(iTotalSpecFile, :) = str2double({para1 para1 para3});
    end
end
%ParametersList = sortrows(ParametersList, 2);
[ParametersList, IndexParametersList] = sortrows(ParametersList);
for n=1:size(TempDataFileList,1);
    DataFileList(n, 1:size(TempDataFileList, 2)) = TempDataFileList(IndexParametersList(n), :);
end
clear n iTotalSpecFile para1 para2 para3 TempDataFileList IndexParametersList;