% Getting Ic and Ir from dcV of the JJ acquired from NI-DAQ

function result = JJdcSweep4Ic(data, TrimRatio, SmoothSpan)
dClock = diff(data.clocking);
OneSweepLength = floor(data.SweepTime*data.fs);
IBias = linspace(data.IbiasRange(2), data.IbiasRange(1), OneSweepLength);
StartingIndex = 1;
iCounter = 1;
iSamplingCounter = 1;
for k = 1:length(dClock)
    if dClock(k) > 2.5
        % MovingAvg is a function to replace smooth moving avg
        CriticalCurrent = GetCriticalCurrent(IBias(1+floor(TrimRatio*OneSweepLength):floor(end/2)), data.dcV(StartingIndex+floor(TrimRatio*OneSweepLength):StartingIndex-1+floor(OneSweepLength/2)), SmoothSpan);
        result.Ir(iCounter) = CriticalCurrent.DiffMin;
        CriticalCurrent = GetCriticalCurrent(IBias(floor(end/2)+1:end), data.dcV(StartingIndex+floor(OneSweepLength/2):StartingIndex-1+OneSweepLength), SmoothSpan);
        %result.IcIndex(iCounter) = CriticalCurrent.minIndex;
        result.Ic(iCounter) = abs(CriticalCurrent.DiffMin);
        result.EndingIndex(iCounter) = k;
        if mod(iCounter, 500) == 0
            result.dcV(iSamplingCounter, :) = data.dcV(StartingIndex:StartingIndex-1+OneSweepLength);
            iSamplingCounter = iSamplingCounter + 1;
        end
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