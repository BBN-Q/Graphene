function result = GetCriticalCurrent(IbiasArray, dVdIArray, SmoothSpan)

    ArraySize = size(dVdIArray);
    if min(ArraySize)~= 1
        for k = 1:ArraySize(1)
            [maxValue, maxIndex] = max(MovingAvg(diff(dVdIArray(k,:)), SmoothSpan));
            [minValue, minIndex] = min(MovingAvg(diff(dVdIArray(k,:)), SmoothSpan));
            result.DiffMax(k) = interp1(IbiasArray, maxIndex+0.5);
            result.DiffMin(k) = interp1(IbiasArray, minIndex+0.5);
            result.maxIndex(k) = maxIndex+1;
            result.minIndex(k) = minIndex+1;
        end
    else
        [maxValue, maxIndex] = max(MovingAvg(diff(dVdIArray),SmoothSpan));
        [minValue, minIndex] = min(MovingAvg(diff(dVdIArray),SmoothSpan));
        result.DiffMax = interp1(IbiasArray, maxIndex+0.5);
        result.DiffMin = interp1(IbiasArray, minIndex+0.5);
        result.maxIndex = maxIndex+1;
        result.minIndex = minIndex+1;
    end
end