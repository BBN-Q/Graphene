function [ Result ] = GainMapFreq3D( freq, fcList, bw, x, y, spec, ref )
% Integrating a power spectral density or S
% parameters with in a certain bandwidth

% data format
% USE LINEAR Spectrum
% freq: frequency array, fc = center frequency of the gain, bw = bandwidth
% spec(x, y) is an array with length = length(freq)
for k = 1:length(fcList)
    InterimResult = GainMap2D(freq, fcList(k), bw, x, y, spec, ref);
    InterimResult = rmfield(InterimResult, 'x'); InterimResult = rmfield(InterimResult, 'y');
    Result.Gain(k, :,:) = InterimResult.Gain;
end
Result.x = x;
Result.y = y;
Result.fc = fcList;

%%%% PLOT %%%%
figure(601);clf(figure(601))
for k = 1:length(fcList)
    zMatrix(k, :,:) = ones(length(x), length(y))*fcList(k)*1e-9;
    hold on; surf(x, y, squeeze(zMatrix(k,:,:))', squeeze(Result.Gain(k,:,:))', 'FaceAlpha', 0.5); shading interp;
    colormap jet;
end
xlabel('x'); ylabel('y'); zlabel('f_{center} (GHz)');
title(['BW = ', num2str(bw*1e-9), ' GHz']);
set(gca, 'FontSize', 18);

clear InterimResult zMatrix;
end