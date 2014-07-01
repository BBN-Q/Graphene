function val = smctemplate(ico, val, rate)

global smdata;

switch ico(2) % channel
    case 1 %resistance
        switch ico(3) %operation
            case 1 %set
                fprintf(smdata.inst(ico(1)).data.inst, 'SOURce:DATA %09d0\n', round(val));
                smdata.inst(ico(1)).data.rval=val;
                
            case 0 %get
                val = smdata.inst(ico(1)).data.rval;
                
            otherwise
                error('Operation not supported');
        end
    otherwise
        error('Channel not supported');
end