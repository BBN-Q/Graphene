function AlazarTraces = GetAlazarTraces(PlusMinusVoltage, SampleRate, SampleLength, plotFlag)
StartTime = clock;
scope = deviceDrivers.AlazarATS9870();
scope.connect(0);
scope.vertical = struct('verticalScale', PlusMinusVoltage, 'verticalCoupling', 'AC', 'bandwidth', 'Full');
scope.horizontal = struct('samplingRate', SampleRate, 'delayTime', 0);
scope.trigger = struct('triggerLevel', 100, 'triggerSource', 'ext', 'triggerCoupling', 'DC', 'triggerSlope', 'rising');
scope.acquireStream(SampleLength);
stop(scope);
AlazarTraces(:,1) = (1:1:SampleLength)/SampleRate;
AlazarTraces(:,2) = scope.data{1}; AlazarTraces(:,3) = scope.data{2}; 
if strcmp(plotFlag, 'True')
    figure(); plot(AlazarTraces(:,1), AlazarTraces(:,2)); hold on; plot(AlazarTraces(:,1), AlazarTraces(:,3), 'r');
end
clear scope;
%disp(num2str(etime(clock, StartTime)));