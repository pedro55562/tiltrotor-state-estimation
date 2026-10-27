function [ GeneralizedForcesThrusters ] = GetGeneralizedForcesThrusters( q, Parameters, RelativeWind, RPS )

%q = [Ar AL Phi Theta Psi X Y Z]

AlphaR = q(1);
AlphaL = q(2);
Phi = q(3);
Theta = q(4);
Psi = q(5);

%propellers' inclination angle (toward the center of the aircraft)
B = Parameters.B;


%Configuration Matrices
ay = [0 1 0]'; 
Wn = [1,            0,             -sin(Theta);
      0,          cos(Phi),    sin(Phi)*cos(Theta);
      0,         -sin(Phi),    cos(Phi)*cos(Theta)];

RIB = rotz(Psi)*roty(Theta)*rotx(Phi);
RB2 = roty(AlphaR)*rotx(-B); 
RB3 = roty(AlphaL)*rotx(B); 



Jvc2 = [-RIB*RB2*SkewSymmetricMatrix(Parameters.DA2P2)*rotx(-B).'*ay zeros(3,1) -RIB*SkewSymmetricMatrix(Parameters.DBA2 + RB2*Parameters.DA2P2)*Wn eye(3)];
Jvc3 = [ zeros(3,1) -RIB*RB3*SkewSymmetricMatrix(Parameters.DA3P3)*rotx(B).'*ay -RIB*SkewSymmetricMatrix(Parameters.DBA3 + RB3*Parameters.DA3P3)*Wn eye(3)];

Jwc2 = [RIB*RB2*rotx(-B).'*ay  zeros(3,1) RIB*Wn zeros(3,3)];
Jwc3 = [zeros(3,1)   RIB*RB3*rotx(B).'*ay RIB*Wn zeros(3,3)];


az = [0; 0; 1];


if RPS(1) < 1
    RPS(1) = 1;
end
if RPS(2) < 1
    RPS(2) = 1;
end

Fr =  Parameters.Ho*(Parameters.DiameterPropeller^4)*((RPS(1))^2)*GetCtNew2( RelativeWind.VpRxz/(Parameters.DiameterPropeller*RPS(1)), RelativeWind.AlphapR );
Tr =  Parameters.Ho*(Parameters.DiameterPropeller^5)*((RPS(1))^2)*GetCqNew2( RelativeWind.VpRxz/(Parameters.DiameterPropeller*RPS(1)), RelativeWind.AlphapR );
Fl =  Parameters.Ho*(Parameters.DiameterPropeller^4)*((RPS(2))^2)*GetCtNew2( RelativeWind.VpLxz/(Parameters.DiameterPropeller*RPS(2)), RelativeWind.AlphapL );
Tl = -Parameters.Ho*(Parameters.DiameterPropeller^5)*((RPS(2))^2)*GetCqNew2( RelativeWind.VpLxz/(Parameters.DiameterPropeller*RPS(2)), RelativeWind.AlphapL );

GeneralizedForcesThrusters = Jvc2'*RIB*RB2*az*Fr + Jwc2'*RIB*RB2*az*Tr + Jvc3'*RIB*RB3*az*Fl + Jwc3'*RIB*RB3*az*Tl;

end

