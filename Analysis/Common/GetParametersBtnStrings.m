function [ output_str ] = GetParametersBtnStrings( str0, str1, str2 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
m = findstr(str0,str1);
n = findstr(str0,str2);
output_str = str0(m+length(str1):n-1);
end