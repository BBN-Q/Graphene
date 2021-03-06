function val = smcKeithley1(ico, val, rate)
display(rate)
%Driver for the Keithley 2400 SourceMeter
%channel 1 = voltage manual ramp
%channel 2 = voltage self ramp
%channel 3 = current
global smdata;

%Keithley read command returns five elements separated by commas
%1) Voltage reading 2) Current reading 3) Resistance reading
%4) Timestamp 5) Status Word
%Keithely returns 9.91E37 as NaN for function not enabled
%the InputBufferSize of the Keithley gpib object should be set to 175000 to
%allow for it to hold the entire output possible of the instrument

%read buffer
if isfield(smdata.inst(ico(1)).data, 'MeasurementsToRead') && smdata.inst(ico(1)).data.MeasurementsToRead
      buffer=fgets(smdata.inst(ico(1)).data.inst);
      bufferlength=(length(strmatch(',',buffer'))+1)/5
      smdata.inst(ico(1)).data.MeasurementsToRead=false;
end

switch ico(2) % channel
    case {1, 2} %manual and self ramp voltage
        switch ico(3) %operation
            case 1 %set
                switch ico(2)
                    case 1
                        disp('SET1')
                        disp(val)
                        fprintf(smdata.inst(ico(1)).data.inst, ':SOUR:VOLT:LEV:IMM:AMPL %f\n', val);
                    case 2
                        disp('SET2')
                        volt_curr = query(smdata.inst(ico(1)).data.inst, 'SOUR:VOLT:LEV:IMM:AMPL?', '%s\n', '%f');
                        numpoints=2500; %2500 total stored data points but must save data at starting point
                        
                        %voltage_step=(val-volt_curr)/numsteps; %possibility of negative values necessary
                        
                        fprintf(smdata.inst(ico(1)).data.inst, 'SOUR:VOLT:STAR %f', volt_curr)
                        fprintf(smdata.inst(ico(1)).data.inst, 'SOUR:VOLT:STOP %f', val)
                        %fprintf(smdata.inst(ico(1)).data.inst, 'SOUR:VOLT:STEP %f', voltage_step)
                        fprintf(smdata.inst(ico(1)).data.inst, 'SOUR:SWE:POIN %f', numpoints)
                        fprintf(smdata.inst(ico(1)).data.inst, 'SOUR:VOLT:MODE SWE')
                        fprintf(smdata.inst(ico(1)).data.inst, 'TRIG:COUN %f', numpoints)
                        voltage_step = query(smdata.inst(ico(1)).data.inst, 'SOUR:VOLT:STEP?','%s\n', '%f');
                        fprintf(smdata.inst(ico(1)).data.inst, 'TRIG:DEL %f', abs(voltage_step/rate))
                        if rate>0
                            fprintf(smdata.inst(ico(1)).data.inst, 'READ?');
                            smdata.inst(ico(1)).data.MeasurementsToRead=true;
                        end   
                end
            case 0 %get
                disp('GET')
                val = query(smdata.inst(ico(1)).data.inst, 'SOUR:VOLT:LEV:IMM:AMPL?', '%s\n', '%f')
            case 3 %trigger
                disp('TRIG')
                fprintf(smdata.inst(ico(1)).data.inst, 'READ?');
                smdata.inst(ico(1)).data.MeasurementsToRead=true;
            otherwise
                error('Operation not supported');
        end
    case 3 %current
        switch ico(3) %operation
            case 0 %get
                quer = query(smdata.inst(ico(1)).data.inst,  'READ?', '%s\n', '%f,%f,%f,%f,%f');
                val = quer(2);
            otherwise
                error('Operation not supported');
        end
    otherwise
        error('Channel not supported');
end