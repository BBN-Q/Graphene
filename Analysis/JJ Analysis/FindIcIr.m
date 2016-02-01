function IcIr_Data = FindIcIr(DC_IV_data)
%Takes as input the output from DC_IV programs and returns Ic and Ir as a
%function of gate voltage

IcIr_Data=struct('V_Gate_Array',DC_IV_data.V_Gate_Array,'Ic',[],'Ir',[]);

VGate_size=length(DC_IV_data.V_Gate_Array);
JJCurr_size=length(DC_IV_data.JJCurr_Array);
%If current sweep was round trip, get length of sweep in one direction
tripflag=0;
if DC_IV_data.JJCurr_Array(1)==DC_IV_data.JJCurr_Array(JJCurr_size)
    tripflag=1;
    JJCurr_size=.5*JJCurr_size;
end

sweepsize=.5*JJCurr_size;
for i=1:VGate_size
    %Find Retrap Current
    [~, idxmax1] = max(diff(DC_IV_data.JJ_V(i,1:floor(sweepsize)),2));
    Ir1=DC_IV_data.JJCurr_Array(idxmax1);
    if tripflag==1
        [~, idxmax2] = min(diff(DC_IV_data.JJ_V(i,(JJCurr_size+1):(JJCurr_size+1+floor(sweepsize))),2));
        Ir2=DC_IV_data.JJCurr_Array(idxmax2+JJCurr_size);
        IcIr_Data.Ir(i)=.5*(abs(Ir1)+abs(Ir2));
    else
        IcIr_Data.Ir(i)=Ir1;
    end
    %Find Critical Current
    [~, idxmax1] = max(diff(DC_IV_data.JJ_V(i,ceil(sweepsize):JJCurr_size),2));
    Ic1=DC_IV_data.JJCurr_Array(idxmax1+floor(sweepsize));
    if tripflag==1
        [~, idxmax2] = min(diff(DC_IV_data.JJ_V(i,(JJCurr_size+1+ceil(sweepsize)):(2*JJCurr_size)),2));
        Ic2=DC_IV_data.JJCurr_Array(idxmax2+JJCurr_size+ceil(sweepsize));
        IcIr_Data.Ic(i)=.5*(abs(Ic1)+abs(Ic2));
    else
        IcIr_Data.Ic(i)=Ic1;
    end
end
end

