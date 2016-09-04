clear data_tmp S11 T_n B_n Vg_n sT sB sVg index cf lb ub i bw
data_tmp = J209;
BW_cutoff = -6;

[sT,sB,sVg]=size(data_tmp.time);

cf = zeros(sT,sB,sVg);
bw = zeros(sT,sB,sVg);
ub = zeros(sT,sB,sVg);
lb = zeros(sT,sB,sVg);
S11_min = zeros(sT,sB,sVg);

for T_n=1:sT
    for B_n=1:sB
        for Vg_n=1:sVg
            S11 = 20*log10(abs(squeeze(data_tmp.traces(T_n,B_n,Vg_n,:))));
            [S11_min(T_n,B_n,Vg_n),index] = min(S11);
            cf(T_n,B_n,Vg_n) = data_tmp.freq(index);
            for i=index:-1:1
                if S11(i) > BW_cutoff
                    lb(T_n,B_n,Vg_n) = data_tmp.freq(i);
                    break
                end
            end
            for i=index:length(data_tmp.freq)
                if S11(i) > BW_cutoff
                    ub(T_n,B_n,Vg_n) = data_tmp.freq(i);
                    break
                end
            end
            bw(T_n,B_n,Vg_n) = ub(T_n,B_n,Vg_n)-lb(T_n,B_n,Vg_n);
        end
    end
end
clear data_tmp S11 T_n B_n Vg_n sT sB sVg index i BW_cutoff

J209.centerFreq = cf;
J209.bw_6dB = bw;
J209.bw_6dB.bw = bw;
J209.bw_6dB.lower_bound = lb;
J209.bw_6dB.upper_bound = ub;
J209.S11_min = S11_min;
            