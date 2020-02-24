function [ SpecAvg_W ] = GetSpecAvg( freq, spec_W, fc, bw )
% Function to get the averaged value of a power spectral density or S
% parameters with in a certain bandwidth

% ascii spectrum files:
%[v, iBegin] = min(abs(data-(fc-bw)));
%[v, iEnd] = min(abs(data-(fc+bw)));
%Spec_W = 0.001*10.^(0.1*data(:,2));
%SpecAvg_W = mean(Spec_W(iBegin:iEnd));

% mat-file spectrum files:
[v, iBegin] = min(abs(freq-(fc-0.5*bw)));
[v, iEnd] = min(abs(freq-(fc+0.5*bw)));
SpecAvg_W = mean(spec_W(iBegin:iEnd));

end

