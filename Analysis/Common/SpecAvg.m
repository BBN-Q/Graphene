function [ Result ] = SpecAvg( freq, spec, fc, bw )
% Integrating a power spectral density or S
% parameters with in a certain bandwidth

% data format
% spec in linear unit, i.e. for PSD: V/rtHz or for S parameters unitless

% mat-file spectrum files:
[v, iBegin] = min(abs(freq-(fc-0.5*bw)));
[v, iEnd] = min(abs(freq-(fc+0.5*bw)));
Result = mean(abs(spec(iBegin:iEnd)));

end