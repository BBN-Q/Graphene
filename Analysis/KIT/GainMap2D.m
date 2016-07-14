function [ Result ] = GainMap2D( freq, fc, bw, x, y, spec, ref )
% Integrating a power spectral density or S
% parameters with in a certain bandwidth

% data format
% USE LINEAR Spectrum
% freq: frequency array, fc = center frequency of the gain, bw = bandwidth
% spec(x, y) is an array with length = length(freq)

Result.Freq = freq;
Result.x = x;
Result.y = y;
for j=1:length(x)
    for k=1:length(y)
        gain(j,k) = ((SpecAvg(freq, squeeze(spec(j,k,:)), fc, bw))/SpecAvg(freq, ref, fc, bw))^2;
    end
end
Result.Gain = gain;
figure; contour(Result.x, Result.y, Result.Gain', 'ShowText','on'); grid on;
title(['BW = [', num2str((fc-0.5*bw)*1e-9), ' ', num2str((fc+0.5*bw)*1e-9), '] GHz']);
set(gca, 'FontSize', 18);

clear gain;
end