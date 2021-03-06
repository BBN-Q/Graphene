function [ SpecAvg_W ] = GetSpecSum( data, fc, bw )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% ascii spectrum files:
%[v, iBegin] = min(abs(data-(fc-bw)));
%[v, iEnd] = min(abs(data-(fc+bw)));
%Spec_W = 0.001*10.^(0.1*data(:,2));
%SpecAvg_W = mean(Spec_W(iBegin:iEnd));

% mat-file spectrum files:
[v, iBegin] = min(abs(data(1,:)-(fc-bw)));
[v, iEnd] = min(abs(data(1,:)-(fc+bw)));
Spec_W = 0.001*10.^(0.1*data(2,:));
%Spec_W = data(2,:);
SpecAvg_W = sum(Spec_W(iBegin:iEnd));

end

