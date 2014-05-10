function [ output_arg ] = GetDataLineNum( FileName )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fid = fopen(FileName);
iHeadLineNum = 1;
str = fgetl(fid);
while (str ~= -1)
    iHeadLineNum = iHeadLineNum+1;
    str = fgetl(fid);
    if strcmp(str, '### Data ###')==1
        str = -1;
    else str = 1;
    end
    %if strcmp(str, '')==1
    %    str = 1;
    %end
end
fclose(fid);
output_arg = iHeadLineNum;
end

