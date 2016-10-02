% Smoothing funciton in Matlab
% 'span should be an odd integer

function result = MovingAvg(x, span)

WingSpan = (span-1)/2;
Padx = [zeros(1, WingSpan) x zeros(1, WingSpan)];

for k = WingSpan+1:length(Padx)-WingSpan
    result(k-WingSpan) = sum(Padx(k-WingSpan:k+WingSpan))/span;
end

end