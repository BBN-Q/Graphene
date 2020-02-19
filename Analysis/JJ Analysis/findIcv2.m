function IcfromSweep = findIcv2(VJJ,Ib,numSweeps,IbBins,pointsPerSweep)
%findIcv2: Get Ic from JJ using Ib as trigger
%   VJJ is the voltage of a JJ at bias current Ib. numSweeps is how many
% current sweeps are contained within Ib. IbBins are the bins into which to
% sort the switching current (usually the current steps of the sweep).
% pointsPerSweep is the approximate number of points in one current sweep.
% Ib is also used as a trigger for the beggining of each sweep (falling
% edge).


IcfromSweep=struct('JJCurr_Array', IbBins,'IcCount',zeros(1,length(IbBins)),'IcAvg',[],'IcStd',[], 'NumTrials', numSweeps);

[~, idxTrigAll] = sort(diff(Ib));
% [~, idxTrigAll] = sort(diff(VJJ));
idxTrig = idxTrigAll(1:numSweeps);
% idxTrig = idxTrig - min(.25*pointsPerSweep,min(idxTrig)-1);
idxRemove = 1;
removals = 0;
while ~isempty(idxRemove)
    idxTrig = sort(idxTrig);
    while idxTrig(end) > length(Ib)-pointsPerSweep
        idxTrig(end) = idxTrigAll(numSweeps+removals+1);
        removals = removals + 1;
        idxTrig = sort(idxTrig);
    end
    trigSpacing = diff(idxTrig);
    idxRemove = find(trigSpacing<.25*pointsPerSweep);
    if ~isempty(idxRemove)
    for i = 1:length(idxRemove)
        idxTrig(idxRemove(i)) = idxTrigAll(numSweeps+i+removals);
    end
    end
    removals = removals + length(idxRemove);
end




% Take difference of all VJJ values in sweep - find maximum
% Take difference
VJJdiff = diff(VJJ);
%Find start of sweep
Voffset = mean(VJJ(1:idxTrig(1)));

for i = 1:numSweeps
    %Put each sweep in order
    if i<numSweeps
        [~, idx] = sort(VJJdiff(idxTrig(i):idxTrig(i+1)));
    else
        idxEnd = min(idxTrig(i)+pointsPerSweep,length(VJJdiff));
        [~, idx] = sort(VJJdiff(idxTrig(i):idxEnd));
    end
    idx = idx + idxTrig(i) - 1;

    %Take median to eliminate outliers
%     idxIc = median(idx(end-4:end));
    idxIc = idx(end);
    j = 1;
    while Ib(idxIc)<0
        idxIc = idx(end-j);
        j = j+1;
    end
    %Find Ic
    Ic(i) = 0.5*(Ib(idxIc)+Ib(idxIc+1));
    
    if idxIc+5<=length(VJJ)
        IcRn(i) = VJJ(idxIc+5)-Voffset;
    else
        IcRn(i) = VJJ(idxIc)-Voffset;
    end
    Rn(i) = IcRn(i)/Ic(i);
%     Rn(i) = mean(VJJdiff((idxIc+5):(idxIc+25)))/dI;
%     IcRn(i) = Ic(i)*Rn(i);
    
% % Sort difference from low to high - resets (large negative) will be in
% % beginning, Ic (large positive) will be at end
% [~, idx] = sort(VJJdiff);
% % Find indices of Ic
% idxIc = idx(end-numSweeps:end);
% % Find Ic
% Ic = 0.5*(Ib(idxIc)+Ib(idxIc+1));
% IcfromSweep.IcAvg = mean(Ic);

% for i = 1:numSweeps
    [~, idxMin] = min(abs(IbBins-Ic(i))); %Find bin to place count into
    IcfromSweep.IcCount(idxMin) = IcfromSweep.IcCount(idxMin)+1;
    IcfromSweep.idxIc(i) = idxIc;
end

    IcfromSweep.IcStd = std(Ic);
    IcfromSweep.IcAvg = mean(Ic);
    IcfromSweep.IcRnAvg = mean(IcRn);
    IcfromSweep.RnAvg = mean(Rn);
    IcfromSweep.Ic = Ic;
    IcfromSweep.IcRn = IcRn;
    IcfromSweep.Rn = Rn;
    IcfromSweep.Voffset = Voffset;
    IcfromSweep.idxTrig = idxTrig;
end

