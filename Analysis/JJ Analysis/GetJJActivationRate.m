function result = GetJJActivationRate(hHistogram, dIdt, Iswitch)
    % based on Fulton and Dunkleberger PRB 1974
    % assume a decreasing Ibias

    dI = hHistogram.BinWidth;
    % Iswitch = hHistogram.BinEdges(1:end-1) + hHistogram.BinWidth/2;
    Values = hHistogram.Values;
    for k = 1:length(Values)
        if Values(k) == 0
            RemovalIndex(k) = k;
        else RemovalIndex(k) = 0;
        end
    end
    RemovalIndex = RemovalIndex(RemovalIndex~=0);
    Values(RemovalIndex) = [];
    Iswitch(RemovalIndex) = [];
    result.ICount = Values; result.IsBins = Iswitch(1:end-1);
    for k = 1:length(Values)-1
        result.JJRate(length(Values)-k) = (dIdt/dI)*log(sum(Values(end-k:end))/sum(Values(end-k+1:end)));
    end
    figure; semilogy(result.IsBins, result.JJRate, '.-'); grid on;
end