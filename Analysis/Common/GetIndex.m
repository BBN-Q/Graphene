% returning the index nearest to the XValue
% not using interp1() because it demands a monotonic function

function result = GetIndex(XArray, XValue)

    [minValue, result] = min(abs(XArray-XValue));

end