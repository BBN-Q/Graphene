% Getting File Names and Parameters in the running directory
% The spectrums measured and recorded by spectrum analyzer
% DataFileList
% ParametersList = [Vds_mV, Vgate_V, T_K]
FileList = ls;
iTotal = 0;
clear DataFileList ParametersList;

for n=1:size(FileList,1);
    if strfind(FileList(n,:),'NoiseV_T');
        iTotal = iTotal + 1;
        DataFileList(iTotal, 1:size(FileList,2)) = FileList(n,:);
        para1 = GetParametersBtnStrings(DataFileList(iTotal,:), 'NoiseV_T', 'K_');
        para2 = GetParametersBtnStrings(DataFileList(iTotal,:), 'K_LP', 'MHz_dt');
        ParametersList(iTotal, :) = str2double({para1 para2});
    end
end
T_K = ParametersList(:,1);
BW = ParametersList(:,2);
clear n iTotal para1 para2 FileList;