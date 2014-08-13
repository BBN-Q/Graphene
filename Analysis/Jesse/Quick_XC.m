for i=1:10
DoubleTraces = GetAlazarTraces(0.04, 500e6, 20E6, 'False');
DoubleTraces(:,3) = DoubleTraces(:,3) - mean(DoubleTraces(:,3));
DoubleTraces(:,2) = DoubleTraces(:,2) - mean(DoubleTraces(:,2));
XC=DoubleTraces(1:end,3).*DoubleTraces(1:end,2);
data(i)=mean(XC);
end
mean(data)
std(data)
