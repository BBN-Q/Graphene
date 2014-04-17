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
    if strfind(FileList(n,:),'S11_Ids');
        iTotalSpecFile = iTotalSpecFile + 1;
        %DataFileList(iTotalSpecFile, :) = FileList(n,:);
        TempDataFileList(iTotalSpecFile, 1:size(FileList,2)) = FileList(n,:);
        para1 = GetParametersBtnStrings(TempDataFileList(iTotalSpecFile,:), 'S11_Ids', 'nA_');
        para2 = GetParametersBtnStrings(TempDataFileList(iTotalSpecFile,:), '_Vgate', 'V_T');
        para3 = GetParametersBtnStrings(TempDataFileList(iTotalSpecFile,:), 'V_T', 'K_');
        %para1 = GetParametersBtnStrings(TempDataFileList(iTotalSpecFile,:), 'K_', '.mat');
        ParametersList(iTotalSpecFile, :) = str2double({para1 para2 para3});
    end
end
[ParametersList, IndexParametersList] = sortrows(ParametersList);
for n=1:size(TempDataFileList,1);
    DataFileList(n, 1:size(TempDataFileList, 2)) = TempDataFileList(IndexParametersList(n), :);
end
clear iTotalSpecFile para2 para3 TempDataFileList; % para2 para3 TempDataFileList; FileList