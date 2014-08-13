function [f,Y] = plotfft(Fs,data)
L=length(data);
NFFT = 2^nextpow2(L); % Next power of 2 from length of data
Y = fft(data,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2+1))) ;
title('Single-Sided Amplitude Spectrum)');
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
end
