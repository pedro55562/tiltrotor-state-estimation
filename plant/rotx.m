function [rotMtrx] = rotx(ang)
%ROTX Summary of this function goes here
%   Detailed explanation goes here
    rotMtrx = [1,    0,        0;
               0, cos(ang), -sin(ang);
               0  sin(ang), cos(ang)];
end

