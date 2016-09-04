function result = GetCriticalCurrent(IbiasArray, dVdIArray)

    ArraySize = size(dVdIArray);
    if min(ArraySize)~= 1
        for k = 1:ArraySize(1)
            [maxValue, maxIndex] = max(diff(dVdIArray(k,:)));
            [minValue, minIndex] = max(diff(dVdIArray(k,:)));
            result.DiffMax(k) = interp1(IbiasArray, maxIndex+0.5);
            result.DiffMin(k) = interp1(IbiasArray, minIndex+0.5);
        end
    else
        [maxValue, maxIndex] = max(diff(dVdIArray));
        [maxValue, maxIndex] = min(diff(dVdIArray));
        result.DiffMax = interp1(IbiasArray, maxIndex+0.5);
        result.DiffMin = interp1(IbiasArray, maxIndex+0.5);
    end
end