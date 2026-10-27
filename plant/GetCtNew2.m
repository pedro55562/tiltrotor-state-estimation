function [ Ct ] = GetCtNew2( J, phi )
    
    J_min = 0;
    J_max = 0.75;
    phi_min = -pi/2;
    phi_max = pi/2;

    if(J < J_min)
        J = J_min;
    elseif(J > J_max)
        J = J_max;
    end

    if(phi < phi_min)
        phi = phi_min;
    elseif(phi > phi_max)
        phi = phi_max;
    end
    
    phi = abs(phi);
    Ct = [1 J phi J^2 J*phi phi^2 J^3 (J^2)*phi J*(phi^2) phi^3 J^4 (J^3)*phi (J^2)*(phi^2) J*(phi^3) phi^4] ...
              * [0.0829; 0.0066; 0; -0.2197; -0.1504; 0; 0.0630; 0.2064; 0.2217; 0; 0.0302; -0.1115; 0.0173; -0.0856; 0];

end

