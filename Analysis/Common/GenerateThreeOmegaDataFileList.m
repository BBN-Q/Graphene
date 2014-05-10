% Getting File Names and Parameters in the running directory
% The spectrums measured and recorded by spectrum analyzer
% DataFileList
% ParametersList = [T_K]
FileList = ls;
iTotal = 0;
clear DataFileList ParametersList;

for n=1:size(FileList,1);
    if strfind(FileList(n,:),'NoiseSpec_T');
        iTotal = iTotal + 1;
        DataFileList(iTotal, 1:size(FileList,2)) = FileList(n,:);
        para1 = GetParametersBtnStrings(DataFileList(iTotal,:), 'K_Pow', 'V_#');
        ParametersList(iTotal, :) = str2double(para1);
    end
end
Vsd = ParametersList;
clear n iTotal para1 FileList ParametersList;