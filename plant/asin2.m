function [ val ] = asin2( x, y )

if(x == 0)
    val = 0;
else
    val = asin(x/y);
end

end

