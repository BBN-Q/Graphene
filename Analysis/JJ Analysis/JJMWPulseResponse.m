% Getting Ic and Ir from dcV of the JJ acquired from NI-DAQ

function result = JJMWPulseResponse(data, VThreshold, TrimmedIndex, SmoothSpan)
dClock = diff(data.clocking);
OneSweepLength = length(data.OneTime);
StartingIndex = 1;
iCounter = 1;
iSamplingCounter = 1;
iThresholdCounter = 0;
for k = 1:length(dClock)
        % MovingAvg is a function to replace smooth moving avg
        if max(data.dcV(StartingIndex-1+TrimmedIndex:StartingIndex-1+floor(OneSweepLength/2))) > VThreshold
            SwitchingTime = GetCriticalCurrent(data.OneTime(TrimmedIndex:floor(end/2)), data.dcV(StartingIndex-1+TrimmedIndex:StartingIndex-1+floor(OneSweepLength/2)), SmoothSpan);
            result.SwitchingTime(iCounter) = SwitchingTime.DiffMax;
            %if mod(iCounter, 500) == 0
            %    result.dcV(iSamplingCounter, :) = data.dcV(StartingIndex:StartingIndex-1+OneSweepLength);
            %    iSamplingCounter = iSamplingCounter + 1;
            %send
            iThresholdCounter = iThresholdCounter +1;
        else
            result.SwitchingTime(iCounter) = 0;  % patching zeros          
        end
        result.EndingIndex(iCounter) = k;
        iCounter = iCounter + 1;
        StartingIndex = k + 1;
    end
end
result.OneSweepLength = OneSweepLength;
result.SwitchProb = iThresholdCounter/iCounter;
end
