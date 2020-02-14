function SwitchingRate = JJRatefromSwitchDist(Ibias, Counts, dIdt)
%Takes switching distribution (counts as a function of bias current) and
%gives the corresponding switching rate as a function of Ibias. dIdt is the
%scan rate used to get the distribution data.

SwitchingRate.Ibias=Ibias;
totalcounts=sum(Counts);   
dI=Ibias(2)-Ibias(1);

for i=1:length(Ibias)
    SwitchingRate.Rate(i)=dIdt/dI*log((sum(Counts(i:end)/totalcounts)*dI)./(sum(Counts(i+1:end)/totalcounts)*dI));
end

end

