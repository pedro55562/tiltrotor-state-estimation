function [rotMtrx] = roty(ang)
%ROTY Summary of this function goes here
%   Detailed explanation goes here
    rotMtrx = [cos(ang), 0, sin(ang);
                   0      1,    0 ;
               -sin(ang), 0, cos(ang)];
end

