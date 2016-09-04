function avgData = avgEveryN(data,N)
%Takes vector (data) and averages every N points
points=length(data);
avgPoints=floor(points/N);
avgData=zeros(1,avgPoints);
for i = 1:avgPoints
    avgData(i)=mean(data(N*(i-1)+1:N*i));
end

end

