function smprintgpib(inst)
% smprintgpib(inst)
%
% Print information about instruments inst (Default all).
% If inst is a single instrument, the avialable channels are printed.

global smdata;

if nargin < 1
    inst = 1:length(smdata.inst);
else
    inst = sminstlookup(inst);
end

fmt = '%2d  %-10s  %-10s  %-10s\n';
fprintf(['Inst', fmt(4:end)], 'Device', 'Dev. Name', 'GPIB Address');
fprintf([repmat('-', 1, 60), '\n']);
for i = inst;
    try
    fprintf([fmt(1:17),'%2d\n'], i, smdata.inst(i).device, smdata.inst(i).name, smdata.inst(i).data.inst.PrimaryAddress);
    catch
        fprintf([fmt(1:17),'\n'], i, smdata.inst(i).device, smdata.inst(i).name);
    end
end
if length(inst) == 1
    disp(strvcat(smdata.inst(i).channels));
end