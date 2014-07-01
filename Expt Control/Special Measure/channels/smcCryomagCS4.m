function val = smcCryomagCS4(ico, val, rate)
%Driver for the Cryomagnetics CS-4 power supply
%currently manual ramp

TeslaPerAmp=0.1167;

global smdata;

switch ico(2) %channel
    case 1 %magnetic field
        switch ico(3) %operation
            case 0 %get
                fprintf(smdata.inst(ico(1)).data.inst,'UNITS T');
                val = query(smdata.inst(ico(1)).data.inst, 'IMAG?','%s','%f %*c');
            case 1 %set
                
%                 if abs(rate) > MAX
%                     error('Magnet ramp rate too high');
                
                fprintf(smdata.inst(ico(1)).data.inst,'UNITS T');
                curr = query(smdata.inst(ico(1)).data.inst, 'IMAG?','%s','%f %*c'); %Get current value
                AmpRate=abs(rate/TeslaPerAmp);
                fprintf(smdata.inst(ico(1)).data.inst, ['RATE 0 ' num2str(AmpRate)]);   %Set rate the same for all ranges
                fprintf(smdata.inst(ico(1)).data.inst, ['RATE 1 ' num2str(AmpRate)]);
                fprintf(smdata.inst(ico(1)).data.inst, ['RATE 2 ' num2str(AmpRate)]);
                
                if val > curr   %Are We Sweeping Up or Sweeping Down?
                    %fprintf(smdata.inst(ico(1)).data.inst, ['LLIM ' num2str(curr)]);
                    fprintf(smdata.inst(ico(1)).data.inst, ['ULIM ' num2str(val)]);
                    smdata.inst(ico(1)).data.sweep='UP';
                else
                    fprintf(smdata.inst(ico(1)).data.inst, ['LLIM ' num2str(val)]);   
                    %fprintf(smdata.inst(ico(1)).data.inst, ['ULIM ' num2str(curr)]);
                    smdata.inst(ico(1)).data.sweep='DOWN';
                end
                
                if rate > 0
                    fprintf(smdata.inst(ico(1)).data.inst, ['SWEEP ' smdata.inst(ico(1)).data.sweep]);
                end
                
                val = abs(val-curr)/abs(rate);
            case 3 %trigger
                fprintf(smdata.inst(ico(1)).data.inst, ['SWEEP ' smdata.inst(ico(1)).data.sweep]);               
                
            otherwise
                error('Operation not supported');
        end
    otherwise
        error('Channel not supported');
end