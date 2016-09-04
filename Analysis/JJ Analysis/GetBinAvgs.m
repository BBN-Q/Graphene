function bin_avg_data=GetBinAvgs(JJ_switch_data,smallbintime,bigbintime)

bin_avg_data=struct('bintime',[],'avgN',[],'VARoverN',[]);
steps=bigbintime/smallbintime;
for i=1:steps
    bin_avg_data.bintime(i)=i*smallbintime;
    stats=GetStatsFromJJSwitch(JJ_switch_data,i*smallbintime);
    close all
    bin_avg_data.avgN(i)=stats.avg_countsperbin;
    bin_avg_data.VARoverN(i)=stats.var_countsperbin/stats.avg_countsperbin;
end

end