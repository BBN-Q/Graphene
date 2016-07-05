function counts = CountsvsTime(VJJvsTime,interval,Vthresh,delay)
%Gives the number of counts in each successive time interval (where
%interval is the number of seconds in each interval) with threshold
%voltage Vthresh (V) and delay between pulses delay (s).
points=length(VJJvsTime.Time_s);
steps_per_interval=interval*VJJvsTime.Sampling_Rate_Hz;
bins=floor(points/steps_per_interval);
counts=zeros(bins,1);
for i=1:bins
    start_idx=(i-1)*steps_per_interval+1;
    end_idx=i*steps_per_interval;
    counts(i)=CountPeaks2(VJJvsTime.Voltage_V(start_idx:end_idx),Vthresh,delay*VJJvsTime.Sampling_Rate_Hz);
end

end

