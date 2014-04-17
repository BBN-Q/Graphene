% Analyze the S11 in Gate Voltage Sweep
% Constant or no heating power applied

GenerateS11DataFileList
temperature = ParametersList(:,3);

clear S11Minimum S11CenterFreq;
for k=1:length(temperature)
    [S11Freq_GHz, S11Spectrum(k,:)] = GetReflectometryS11( DataFileList, ParametersList, temperature(k));
    [S11Minimum(k), S11CenterFreq(k)] = Fit4Extremum(S11Freq_GHz', S11Spectrum(k, :)', 1.25, 100, 0)
end

figure; plot(temperature, S11Minimum, 'd'); grid on;
xlabel('T [K]'); ylabel('S_{11} Minimum Value [dB]'); grid on; title('S_{11} Minimum Value (T = 7.5 K)');

figure; plot(temperature, S11CenterFreq, 'd'); grid on; 
xlabel('T [K]'); ylabel('LC Matched Freq [GHz]'); grid on; title('oCenter Frequency of S_{11} Reflection');