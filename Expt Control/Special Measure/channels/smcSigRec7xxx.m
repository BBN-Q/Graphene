function [val, rate] = smcSigRec7xxx(ic, val, rate, ctrl)
%Driver for the Signal Recovery 
%CHANNELS
%1: X, 2: Y, 3: R, 4: Theta, 5: freq, 6: ref amp.
global smdata;

cmds   = {'X.',    'Y.',     'MAG.',   'PHA.',   'OF.',   'OA.'};
limits = [-Inf Inf; -Inf Inf; -Inf Inf; -Inf Inf; 0 2.5E5; 0 5];

switch ic(2) %Which channel?
    case{1,2,3,4} %get-only channels
        switch ic(3) %operation
            case 0 %get
                val = query(smdata.inst(ic(1)).data.inst, cmds{ic(2)}, '%s', '%f');
                if isempty(strfind(smdata.inst(ic(1)).device,'7280'))
                    fread(smdata.inst(ic(1)).data.inst,3); %clean communication buffer after read
                end
            otherwise
                error('Operation not supported');
        end
    case{5,6} %get and set channels
        switch ic(3) %operation
            case 0 %get
                val = query(smdata.inst(ic(1)).data.inst, cmds{ic(2)}, '%s', '%f');
                if isempty(strfind(smdata.inst(ic(1)).device,'7280'))
                    fread(smdata.inst(ic(1)).data.inst,3); %clean communication buffer after read
                end
            case 1 %set
                if val >= limits(ic(2),1) && val <= limits(ic(2),2)
                    fprintf(smdata.inst(ic(1)).data.inst, sprintf('%s %f', cmds{ic(2)}, val));
                else
                    error('Set value out of range');
                end
            otherwise
                error('Operation not supported');
        end
    otherwise
        error('Channel does not exist');
end



