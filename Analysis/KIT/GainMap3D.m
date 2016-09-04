function [ Result ] = GainMap3D( freq, fc, bw, x, y, z, spec, ref )
% Integrating a power spectral density or S
% parameters with in a certain bandwidth
% GainMap3D( freq, fc, bw, x, y, z, spec, ref )
% data format
% USE LINEAR Spectrum
% z is third axis stacking with (x, y) from GainMap2D
% freq: frequency array, fc = center frequency of the gain, bw = bandwidth
% spec(x, y) is an array with length = length(freq)

for k = 1:length(z)
    InterimResult = GainMap2D(freq, fc, bw, x, y, squeeze(spec(k,:,:,:)), ref);
    InterimResult = rmfield(InterimResult, 'x'); InterimResult = rmfield(InterimResult, 'y');
    Result.Gain(k, :,:) = InterimResult.Gain;
end
Result.x = x;
Result.y = y;
Result.z = z;

%%%% PLOT %%%%
figure(601);
for k = 1:length(z)
    zMatrix(k, :,:) = ones(length(x), length(y))*z(k);
    hold on; surf(x, y, squeeze(zMatrix(k,:,:))', squeeze(Result.Gain(k,:,:))', 'FaceAlpha', 0.5); shading interp;
    colormap jet;
end
xlabel('x'); ylabel('y'); zlabel('z');
title(['BW = [', num2str((fc-0.5*bw)*1e-9), ' ', num2str((fc+0.5*bw)*1e-9), '] GHz']);
set(gca, 'FontSize', 18);

clear InterimResult zMatrix;
end