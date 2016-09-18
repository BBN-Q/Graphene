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
        %if iCounter == 1
        %    figure; plot(IBias(1+floor(TrimRatio*OneSweepLength):floor(end/2)+1), data.dcV(StartingIndex+floor(TrimRatio*OneSweepLength):StartingIndex+floor(OneSweepLength/2)), '.-');
        %    figure; plot(diff(data.dcV(101:501)));
        %end
        result.Ir(iCounter) = CriticalCurrent.DiffMin;
        %result.IrIndex(iCounter) = CriticalCurrent.minIndex;
        %result.Ir(iCounter) = IBias(result.IrIndex(iCounter));
        CriticalCurrent = GetCriticalCurrent(IBias(floor(end/2):end), data.dcV(StartingIndex+floor(OneSweepLength/2):k));
        %result.Ic(iCounter) = abs(CriticalCurrent.DiffMin);
        result.IcIndex(iCounter) = CriticalCurrent.minIndex;
        if floor(length(IBias)/2) > result.IcIndex(iCounter)
            result.Ic(iCounter) = abs(IBias(floor(end/2)+result.IcIndex(iCounter)));
        else
            result.Ic(iCounter) = abs(IBias(end));
            disp(['iCounter = ' num2str(iCounter) ', length of IBias = ' num2str(length(IBias)) ' and result.IcIndex is now = ' num2str(result.IcIndex(iCounter))])
            %figure; plot(data.dcV(StartingIndex+floor(TrimRatio*OneSweepLength):StartingIndex+floor(OneSweepLength/2))); grid on; title(k);
        end
        result.EndingIndex(iCounter) = k;
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