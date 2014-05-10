%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluating the performance of PID control
% written to improve CryoCon temperature control over 3K Dry Fridge
%
function PIDPerformanceAnalysis(SetT, MeasT)
MeasLength = (MeasT)
SetLength = length(SetT)
if MeasLength != SetLength
    if mod(length(MeasT)/length(SetT)) == 0
        TStatistics(:,1) = mean(reshape(MeasT, length(MeasT)/length(SetT), length(SetT)))
        TStatistics(:,2) = std(reshape(MeasT, length(MeasT)/length(SetT), length(SetT)))
    end
    figure; errorbar(SetT, TStatistics(:,1), TStatistics(:,2)); grid on;
else
    figure; plot(SetT, MeasT); grid on;
end
xlabel('T_{set} (K)'); ylabel('T_{CryoCon} (K)');
