% Integrating the oscillation in the dVdI of the JJ to get 

function result = JJoscAnalyzer(Ibias, dVdI)
	CriticalCurrent = GetCriticalCurrent(Ibias, dVdI);
    result.Ic = CriticalCurrent.DiffMax;
    DdVdI = diff(dVdI')';
    dI = diff(Ibias);
    
    ArraySize = size(dVdI);
    if min(ArraySize)~= 1 % assuming a 2D matrix     
        for k=1:min(ArraySize)
            j = CriticalCurrent.maxIndex(k)-1; iCounter = 0;
            while (j <= length(DdVdI(k,:))-1) && (iCounter <= 6)
                if DdVdI(k,j)*DdVdI(k,j+1) <= 0
                    iCounter = iCounter + 1;
                    result.ZeroCrossIndex(k, iCounter) = j+1;
                end
                j = j+1;
            end
            for m = 1:3
                result.dV(m,k) = trapz(dVdI(k,result.ZeroCrossIndex(k,2*m-1):result.ZeroCrossIndex(k,2*m+1)))*dI(1);
            end
        end
    else % assuming a 1D array
        % picking up critical current
        j = CriticalCurrent.maxIndex-1; iCounter = 0;
        while (j <= length(DdVdI)-1) && (iCounter <= 6)
            if DdVdI(j)*DdVdI(j+1) <= 0
                iCounter = iCounter + 1;
                result.ZeroCrossIndex(iCounter) = j+1;
            end
            j = j+1;
        end
        for m = 1:3
            result.dV(m) = trapz(dVdI(result.ZeroCrossIndex(1):result.ZeroCrossIndex(3)))*dI(1);
        end
    end
    
    
end