% returning the index nearest to the XValue
% not using interp1() because it demands a monotonic function

function result = GetIndex(XArray, XValue)
    ArraySize = size(XValue);
    if max(ArraySize)~= 1
        for k = 1:max(ArraySize)
            [minValue, minIndex] = min(abs(XArray-XValue(k)));
            result(k) = minIndex;
        end
    else
        [minValue, result] = min(abs(XArray-XValue));
    end
end