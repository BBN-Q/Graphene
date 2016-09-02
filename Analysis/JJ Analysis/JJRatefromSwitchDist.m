function RatevsBias = JJRatefromSwitchDist(Ibias,Counts,dIdt)
%Takes switching distribution (counts as a function of bias current) and
%gives the corresponding switching rate as a function of Ibias. dIdt is the
%scan rate used to get the distribution data.

RatevsBias.Ib=Ibias;
totalcounts=sum(Counts);
dI=Ibias(2)-Ibias(1);
biaspoints=length(Ibias);

for i=1:biaspoints
    RatevsBias.Rate(i)=dIdt/dI*log((sum(Counts(i:end)/totalcounts)*dI)./(sum(Counts(i+1:end)/totalcounts)*dI));
end

end

