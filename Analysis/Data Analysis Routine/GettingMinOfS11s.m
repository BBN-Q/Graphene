% Analyze the Three Omega Data

% Get the S11
for k=1:length(Vgate)
    [MinValue, MinIndex] = min(S11Spectrum(k,:));
    MinS11(k) = Fit4Extremum(Freq_GHz', S11Spectrum(k,:)', Freq_GHz(MinIndex), 15, 1)
end

clear MinValue MinIndex;