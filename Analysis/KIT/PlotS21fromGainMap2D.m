function [result] = PlotS21fromGainMap2D(freq, x, y, spec, ref)
% Plotting the S21 or Spec under the data cursor in the GainMap2D figure

% data format
% USE LINEAR Spectrum
figure(600);
CursorInfo = getCursorInfo(datacursormode(gcf));
result.pos = CursorInfo.Position;
[v, xIndex] = min(abs(x-result.pos(1)));
[v, yIndex] = min(abs(y-result.pos(2)));
result.Freq = freq;
result.spec = (abs(squeeze(spec(xIndex, yIndex, :)))'./abs(ref));

%%%% PLOT %%%%
figure(602); clf;
plot(freq*1e-9, (result.spec).^2); grid on;
xlabel('Frequency (GHz)'); ylabel('Gain');
title(['S_{21} at the cursor position [', num2str(result.pos(1)), ', ', num2str(result.pos(2)), '] in Gain 2D Map']);
set(gca, 'FontSize', 18);
figure(603); clf;
plot(freq*1e-9, 20*log10(result.spec)); grid on;
xlabel('Frequency (GHz)'); ylabel('S_{21} (dB)');
title(['S_{21} at the cursor position [', num2str(result.pos(1)), ', ', num2str(result.pos(2)), '] in Gain 2D Map']);
set(gca, 'FontSize', 18);

clear v xIndex yIndex CursorInfo;
end