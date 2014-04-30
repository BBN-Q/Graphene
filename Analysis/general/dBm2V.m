% Converting power in dBm to voltage
% assuming 50 Ohm termination

function [volt_V, power_W] = dBm2V(power_dBm)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
power_W = 10.^(power_dBm/10)*0.001;
volt_V = sqrt(power_W*50);