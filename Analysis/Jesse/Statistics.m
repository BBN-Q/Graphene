function [stats] = Statistics(data)
%Used to analyse statistics from 2014-09-03 on XC using caltech amps
%takes in 0.1s measurements and finds ave and mean&std of [0.1:0.1:5]s

%create the time list from 0.1 to 5s
stats.times=[0.3,0.4,0.5,0.7,1,1.3,1.6,2];
stats.mean=zeros([1,length(stats.times)]);
stats.std=zeros([1,length(stats.times)]);
s=max(stats.times)*10;
m=floor(length(data)/s);
%go through all s different time values
for j=1:length(stats.times)
    %initialize the l data points
    n = stats.times(j)*10;
    points=zeros([1,m]);
    for k=1:m
        %make the kth point the mean of j*0.1s values
        points(k)=mean(data((s*k-s+1:s*k-s+n)));
    end
    stats.mean(j)=mean(points);
    stats.std(j)=std(points);
end
figure;plot(stats.times,stats.std);
xlabel('Integration time (s)');ylabel('standard Deviation (K)')
end

