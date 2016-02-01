function StatsFromJJSwitch = GetStatsFromJJSwitch(JJ_switch_data,timeInterval)
%Takes data from JJ_switch and a binning time interval and returns the
%mean and standard deviation of counts per bin with a histogram

%Extract data from JJ_switch_data
time=JJ_switch_data.Time;
VJJ=JJ_switch_data.VJJ;
Vthresh=JJ_switch_data.Vthresh;

bins=floor(time(end)/timeInterval); %number of bins - ignore leftover data

StatsFromJJSwitch=struct('avg_countsperbin',[],'std_countsperbin',[],'var_countsperbin',[],'countsperbin',zeros(1,bins),'bin_times',timeInterval:timeInterval:bins*timeInterval);

bin_idx=1; %initialize bin index
j=2; %Ignore first data point
for i=1:bins
    while time(j)<i*timeInterval
        if VJJ(j)>Vthresh %&& VJJ(j-1)<=Vthresh %Include to ignore counts that occur twice in a row
            StatsFromJJSwitch.countsperbin(bin_idx)=StatsFromJJSwitch.countsperbin(bin_idx)+1;
        end
        j=j+1;
    end
    bin_idx=bin_idx+1;
end

StatsFromJJSwitch.avg_countsperbin=mean(StatsFromJJSwitch.countsperbin);
StatsFromJJSwitch.std_countsperbin=std(StatsFromJJSwitch.countsperbin);
StatsFromJJSwitch.var_countsperbin=StatsFromJJSwitch.std_countsperbin.^2;
figure; hist(StatsFromJJSwitch.countsperbin,0:1:max(StatsFromJJSwitch.countsperbin)); grid on;
xlabel('Counts Per Bin','FontSize',14); ylabel('Number of Bins','FontSize',14); set(gca,'FontSize',14);
title_str=sprintf('Switching Distribution with %d Minute Bins',timeInterval/60);
title(title_str,'FontSize',14);
stats_str=sprintf('Avg: %4.1f\r\nVar: %4.1f',StatsFromJJSwitch.avg_countsperbin,StatsFromJJSwitch.var_countsperbin);
text(.8,.9,stats_str,'Units','normalized','FontSize',14);
end
