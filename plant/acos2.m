function [ val ] = acos2( x, y )

if(x == 0)
    val = 0;
else
    val = acos(x/y);
end

end

