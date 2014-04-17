% Pick out spectrums with the same parameters, i.e. same Vgate
% Then analyze the data with the same window
% ParametersList = [Vds_mV, Vgate_V, T_K]

function [GthValue] = Gth(Temperature, Area)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% unit of Area = um^2
% unit: pW/K
GthValue = Area*1e-12*(2.2163+0.10707*Temperature^3.053);