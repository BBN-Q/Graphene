function actualSignal = timingToArray(timingSignal,waveform, rising)
% Takes timingSignal (a square wave) and converts it to actual signal which
% is waveform starting at each new period of the square wave. timingSignal
% can be any length. waveform should be the length of one cycle of
% timingSignal. If rising = 1, waveform starts at each rising edge of
% timingSignal. If rising = 0, waveform starts at each falling edge of
% timingSignal. actualSignal will have same length as timingSignal.

numPoints = length(timingSignal);
pointsPerCycle = length(waveform);
numCycles = floor(numPoints/pointsPerCycle);

%Sort Difference to Put Trigger signals at beginning or end
[~, idxTrigAll] = sort(diff(timingSignal));

% Falling trigger is at beggining of idxTrigAll
if rising == 0
    idxTrig = idxTrigAll(1:numCycles);
% Rising trigger is at end of idxTrigAll
elseif rising == 1
    idxTrig = idxTrigAll(end-numCycles+1:end);
else
    error('rising must be 0 or 1');
end
   
% Put idxTrig in ascending order and calculate spacing
idxTrig = sort(idxTrig);
trigSpacing = diff(idxTrig);

% Check if there was an extra trigger in timingSignal that was excluded
if any(trigSpacing>1.5*pointsPerCycle) || numPoints-idxTrig(end)>pointsPerCycle || idxTrig(1)>pointsPerCycle
    % Falling trigger is at beggining of idxTrigAll
    if rising == 0
        idxTrig = idxTrigAll(1:numCycles+1);
    % Rising trigger is at end of idxTrigAll
    elseif rising == 1
        idxTrig = idxTrigAll(end-numCycles:end);
    else
        error('rising must be 0 or 1');
    end
    idxTrig = sort(idxTrig);
    trigSpacing = diff(idxTrig);
end

% x values for interpolation with nonuniform trigger spacing
x  = linspace(0,1,pointsPerCycle);

% Initialize actualSignal
actualSignal = zeros(1,numPoints);

numTrig = length(idxTrig);

for i = 1:numTrig-1
    % If trigger spacing is exactly what it should be, just use waveform
    if trigSpacing(i) == pointsPerCycle
        actualSignal(idxTrig(i):idxTrig(i)+pointsPerCycle-1) = waveform;
    % If trigger spacing is not as expected, interpolate to make waveform
    % length of actual timing signal
    else
        xq = linspace(0,1,trigSpacing(i));
        scaledWaveform = interp1(x,waveform,xq);
        actualSignal(idxTrig(i):idxTrig(i)+trigSpacing(i)-1) = scaledWaveform;
    end
end

if idxTrig(1) ~= 1
    actualSignal(1:idxTrig(1)-1) = waveform(end-idxTrig(1)+2:end);
end

if idxTrig(end) ~= numPoints
    actualSignal(idxTrig(end):end) = waveform(1:numPoints-idxTrig(end)+1);
end


end

