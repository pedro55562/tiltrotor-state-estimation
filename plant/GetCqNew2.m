function [ Cq ] = GetCqNew2( J, phi )

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
    Cq = [1 J phi J^2 J*phi phi^2 J^3 (J^2)*phi J*(phi^2) phi^3 J^4 (J^3)*phi (J^2)*(phi^2) J*(phi^3) phi^4] ...
              * [0.0053; 0.0074; 0; -0.0078; -0.0190; 0; -0.0215; 0.0254; 0.0183; 0; 0.0112; -0.0024; -0.0049; -0.0068; 0];

end

