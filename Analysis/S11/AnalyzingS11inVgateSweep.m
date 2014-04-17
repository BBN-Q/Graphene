% Analyze the S11 in Gate Voltage Sweep
% Constant or no heating power applied

GenerateS11DataFileList
Vgate = ParametersList(:,2);

clear S11Minimum S11CenterFreq;
[S11Freq_GHz, S11Spectrums] = GetReflectometryS11( DataFileList, ParametersList, 0);
for k=1:length(Vgate)
    [BestMatchS11, BestMatchIndex] = min(S11Spectrums(k, :));
    %if mod(k,50) == 0
    %    [S11Minimum(k), S11CenterFreq(k)] = Fit4Extremum(S11Freq_GHz', S11Spectrums(k, :)', S11Freq_GHz(BestMatchIndex), 20, 1);
    %else
        [S11Minimum(k), S11CenterFreq(k)] = Fit4Extremum(S11Freq_GHz', S11Spectrums(k, :)', S11Freq_GHz(BestMatchIndex), 20, 0);
    %end
end

figure; plot(Vgate, S11Minimum, 'd'); grid on;
xlabel('V_{gate} [V]'); ylabel('S_{11} Minimum Value [dB]'); grid on; title('S_{11} Minimum Value');

figure; plot(Vgate, S11CenterFreq, 'd'); grid on; 
xlabel('V_{gate} [V]'); ylabel('LC Matched Freq [GHz]'); grid on; title('Center Frequency of S_{11} Reflection');