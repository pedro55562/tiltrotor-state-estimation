function [ Val ] = Saturation( Val, Interval )

    if(Interval(2) - Interval(1) < 0)
        disp('Interval Error')
    end
    if Val < Interval(1)
        Val = Interval(1);
    elseif Val > Interval(2)
        Val = Interval(2);
    end
    
end

