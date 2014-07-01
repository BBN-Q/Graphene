function val = smcYokoGS200(ico, val, rate)
%Driver for the Yokogawa GS200 Voltage Source
%channel 1 = voltage manual ramp
%channel 2 = current
global smdata;



switch ico(2) % channel
    case 1 %manual ramp voltage
        switch ico(3) %operation
            case 1 %set
                fprintf(smdata.inst(ico(1)).data.inst, ':SOUR:LEV %f\n', val);
                
            case 0 %get
                val = query(smdata.inst(ico(1)).data.inst, ':SOUR:LEV?', '%s\n', '%f');
                
            otherwise
                error('Operation not supported');
        end
    otherwise
        error('Channel not supported');
end