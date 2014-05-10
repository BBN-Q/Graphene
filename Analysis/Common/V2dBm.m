% Converting voltage to dBm
% assuming 50 Ohm termination

function [power_dBm, power_W] = V2dBm(volt_V)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
power_W = 0.02*volt_V.^2;
power_dBm = 10*log(1000*power_W)./log(10);