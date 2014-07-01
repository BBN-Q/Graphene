function val = smcLakeshore3xx(ico, val, rate)

global smdata;

switch ico(2) %channel
    case 1 %A channel
        switch ico(3) %operation     
            case 0 
                val = query(smdata.inst(ico(1)).data.inst, 'KRDG? A', '%s', '%f');
            otherwise
                error('Operation not supported');
        end
    case 2 %B channel\
        switch ico(3) %operation
            case 0
                val = query(smdata.inst(ico(1)).data.inst, 'KRDG? B', '%s', '%f');
            otherwise
                error('Operation not supported');
        end
    otherwise
        error('Channel not supported');
end
