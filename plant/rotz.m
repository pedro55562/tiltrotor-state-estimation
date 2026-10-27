function [rotMtrx] = rotz(ang)
%ROTZ Summary of this function goes here
%   Detailed explanation goes here
    rotMtrx = [cos(ang), -sin(ang), 0;
               sin(ang), cos(ang),  0;
                  0,         0,     1];
end

