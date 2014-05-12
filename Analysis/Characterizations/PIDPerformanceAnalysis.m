%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluating the performance of PID control
% written to improve CryoCon temperature control over 3K Dry Fridge
%
function PIDPerformanceAnalysis(SetT, MeasT)
SetT = reshape(SetT, length(SetT), 1);
MeasLength = length(MeasT);
SetLength = length(SetT);
if MeasLength ~= SetLength
    if mod(MeasLength, SetLength) == 0
        TStatistics(:,1) = mean(reshape(MeasT, length(MeasT)/length(SetT), length(SetT)));
        TStatistics(:,2) = std(reshape(MeasT, length(MeasT)/length(SetT), length(SetT)));
        figure; errorbar(SetT, TStatistics(:,1)-SetT, TStatistics(:,2), '-x'); grid on;
        xlabel('T_{set} (K)'); ylabel('T_{CryoCon}-T_{set} (K)');
        title(strcat('PID performance analysis, working dir: ', pwd));
    else
        warning('Number of data points at each set temperature are not the same!');
    end
else
    figure; plot(SetT, MeasT); grid on;
    xlabel('T_{set} (K)'); ylabel('T_{CryoCon} (K)');
end

