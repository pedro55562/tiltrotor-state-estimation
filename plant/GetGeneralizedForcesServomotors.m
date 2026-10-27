function [ GeneralizedForcesServomotors ] = GetGeneralizedForcesServomotors(q, qp, Torques, Parameters )

    alfaR = q(1);
    alfaL = q(2);
    phi = q(3);
    theta = q(4);
    psi = q(5);

    RIB = rotz(psi)*roty(theta)*rotx(phi);

    Wn = [1,                 0,             -sin(theta);
          0,          cos(phi),     sin(phi)*cos(theta);
          0,         -sin(phi),     cos(phi)*cos(theta)];
  
    ayR = rotx(-Parameters.B)'*[0;1;0];
    ayL = rotx( Parameters.B)'*[0;1;0];
    ay = [0;1;0];
    
    RBCR = roty(alfaR)*rotx(-Parameters.B); 
    RBCL = roty(alfaL)*rotx( Parameters.B);
    RICR = RIB*RBCR;
    RICL = RIB*RBCL;
    
    JwCm = [zeros(3,2) RIB*Wn zeros(3,3)];
    JwRf = [RICR*ayR   zeros(3,1) RIB*Wn zeros(3,3)];
    JwLf = [zeros(3,1)  RICL*ayL  RIB*Wn zeros(3,3)]; 
    
    GeneralizedForcesServomotors = [(JwRf - JwCm)'*RICR*ay (JwLf - JwCm)'*RICL*ay]*[Torques(1); Torques(2)] - Parameters.v*[eye(2), zeros(2,6); zeros(6,8)]*qp;
 
end

