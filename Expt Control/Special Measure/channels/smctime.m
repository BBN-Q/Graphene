function val = smctime(ico, val, rate)

global smdata;

switch ico(2) % channel
    case 1 %time
        switch ico(3) 
            case 0
                val=toc;
            otherwise
                error('Operation not supported');
        end
    otherwise
        error('Channel not supported');
end
