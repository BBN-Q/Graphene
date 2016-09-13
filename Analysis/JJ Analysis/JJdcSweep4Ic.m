% Getting Ic and Ir from dcV of the JJ acquired from NI-DAQ

function result = JJdcSweep4Ic(data, TrimRatio)
dClock = diff(data.clocking);
OneSweepLength = floor(data.SweepTime*data.fs);
IBias = linspace(data.IbiasRange(2), data.IbiasRange(1), OneSweepLength);
StartingIndex = 1;
iCounter = 1;
for k = 1:length(dClock)
    if dClock(k) > 2.5
        CriticalCurrent = GetCriticalCurrent(IBias(1+floor(TrimRatio*OneSweepLength):floor(end/2)+1), data.dcV(StartingIndex+floor(TrimRatio*OneSweepLength):StartingIndex+floor(OneSweepLength/2)));
        %result.Ir(iCounter) = CriticalCurrent.DiffMin;
        result.IrIndex(iCounter) = CriticalCurrent.minIndex;
        result.Ir(iCounter) = IBias(result.IrIndex(iCounter));
        CriticalCurrent = GetCriticalCurrent(IBias(floor(end/2):end), data.dcV(StartingIndex+floor(OneSweepLength/2):k));
        %result.Ic(iCounter) = abs(CriticalCurrent.DiffMin);
        result.IcIndex(iCounter) = CriticalCurrent.minIndex;
        result.Ic(iCounter) = abs(IBias(floor(end/2)+result.IcIndex(iCounter)));
        result.EndingIndex(iCounter) = k;
    %if result.Ic(iCounter) > 1e-6
    %    StartingIndex
    %    figure; plot(data.dcV(StartingIndex+floor(OneSweepLength/2):k), '.-'); grid on;
    %    hold on; plot(diff(data.dcV(StartingIndex+floor(OneSweepLength/2):k-floor(TrimRatio*OneSweepLength))));
    %end
        iCounter = iCounter + 1;
        StartingIndex = k + 1;
    end
end
result.AvgIc = mean(result.Ic);
result.AvgIr = mean(result.Ir);
result.StdIc = std(result.Ic);
result.StdIr = std(result.Ir);
result.OneSweepLength = OneSweepLength;
result.IBias = IBias;
end