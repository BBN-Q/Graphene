function PoissStats = GetPoissStats(peakTimes,timeTot,timeInterval)
%Takes a series of event times (peakTimes) from an experiment that lasted
%time timeTot and splits the event into bins of length timeInterval. The
%best Poissonian fit to the data is given.


bins=floor(timeTot/timeInterval); %number of bins - ignore leftover data
peakCounts=length(peakTimes);
PoissStats=struct('avg_countsperbin',[],'std_countsperbin',[],'var_countsperbin',[],'countsperbin',zeros(1,bins),'binTimes',timeInterval:timeInterval:bins*timeInterval,'peakTimes',peakTimes,'peakCounts',peakCounts);

for i=1:peakCounts
    binIndex=ceil(peakTimes(i)/timeInterval);
    if peakTimes(i)==0
        binIndex=1;
    end
    PoissStats.countsperbin(binIndex)=PoissStats.countsperbin(binIndex)+1;
end

PoissStats.avg_countsperbin=mean(PoissStats.countsperbin);
PoissStats.std_countsperbin=std(PoissStats.countsperbin);
PoissStats.var_countsperbin=PoissStats.std_countsperbin.^2;
figure; hist(PoissStats.countsperbin,0:1:max(PoissStats.countsperbin)); grid on;
xlabel('Counts Per Bin','FontSize',14); ylabel('Number of Bins','FontSize',14); set(gca,'FontSize',14);
title_str=sprintf('Switching Distribution with %d Second Bins',timeInterval);
title(title_str,'FontSize',14);
stats_str=sprintf('Avg: %4.1f\r\nVar: %4.1f',PoissStats.avg_countsperbin,PoissStats.var_countsperbin);
text(.8,.9,stats_str,'Units','normalized','FontSize',14);

lambda=poissfit(PoissStats.countsperbin);
x=linspace(0,max(PoissStats.countsperbin));
dist=((lambda.^x)*exp(-lambda))./gamma(x+1);
hold on; plot(x,bins*dist,'r','LineWidth',2)

end