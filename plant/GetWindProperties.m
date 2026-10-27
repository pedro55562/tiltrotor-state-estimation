function [ RelativeWind ] = GetWindProperties( q, qp, Parameters, EnvironmentWindI )

%q = [Ar Al Phi Theta Psi x y z]';
%qp = [dAr dAl dPhi dTheta dPsi dx dy dz]'
%EnvironmentWindI = [Xa Ya Za]' expressed in the inertial frame
AlphaR = q(1);
AlphaL = q(2);
Phi = q(3);
Theta = q(4);
Psi = q(5);

B = Parameters.B;

%Rotation matrices

RIB = rotz(Psi)*roty(Theta)*rotx(Phi);
RBR = roty(AlphaR)*rotx(-B); 
RBL = roty(AlphaL)*rotx( B); 
RBWR = rotx(-Parameters.BW);
RBWL = rotx(Parameters.BW);

Wn = [1,            0,             -sin(Theta);
      0,          cos(Phi),    sin(Phi)*cos(Theta);
      0,         -sin(Phi),    cos(Phi)*cos(Theta)];

%Compute the velocity of the aerodynamic centers expressed in the Inertial
%frame
ay = [0; 1; 0];
dPIpR = [-RIB*RBR*SkewSymmetricMatrix(Parameters.DA2P2)*rotx(-B).'*ay zeros(3,1) -RIB*SkewSymmetricMatrix(Parameters.DBA2 + RBR*Parameters.DA2P2)*Wn eye(3)]*qp;
dPIpL = [ zeros(3,1) -RIB*RBL*SkewSymmetricMatrix(Parameters.DA3P3)*rotx(B).'*ay -RIB*SkewSymmetricMatrix(Parameters.DBA3 + RBL*Parameters.DA3P3)*Wn eye(3)]*qp;

dPIf   = [zeros(3,2) -RIB*SkewSymmetricMatrix(  Parameters.DBf )*Wn eye(3)]*qp; 
dPIwR  = [zeros(3,2) -RIB*SkewSymmetricMatrix( Parameters.DBwR )*Wn eye(3)]*qp;
dPIwL  = [zeros(3,2) -RIB*SkewSymmetricMatrix( Parameters.DBwL )*Wn eye(3)]*qp;
dPItR  = [zeros(3,2) -RIB*SkewSymmetricMatrix( Parameters.DBtR )*Wn eye(3)]*qp;
dPItL  = [zeros(3,2) -RIB*SkewSymmetricMatrix( Parameters.DBtL )*Wn eye(3)]*qp;
dPICG  = [zeros(3,2) -RIB*SkewSymmetricMatrix( Parameters.DBc1 )*Wn eye(3)]*qp;

%----------Computing Properties of Relative wind for fuselage---------%

UVWf = RIB' * (dPIf - EnvironmentWindI); %Compute the relative wind-speed vector

RelativeWind.Vf = sqrt(UVWf(3)^2 + UVWf(2)^2 + UVWf(1)^2);
%RelativeWind.Vfxz = sqrt(UVWf(3)^2 + UVWf(1)^2); %Magnitude
%RelativeWind.Vfxy = sqrt(UVWf(2)^2 + UVWf(1)^2); %Magnitude

RelativeWind.Alphaf = atan2(UVWf(3),UVWf(1)); %Orientation
RelativeWind.Betaf =  asin2(UVWf(2),RelativeWind.Vf); %Orientation

%----------Computing Properties of Relative wind for wings---------%
 
%Right Wing
UVWwR =  (RIB*RBWR)' * (dPIwR - EnvironmentWindI); %Compute the relative wind-speed vector

RelativeWind.VwR = sqrt(UVWwR(3)^2 + UVWwR(2)^2 + UVWwR(1)^2);
%RelativeWind.VwRxz = sqrt(UVWwR(3)^2+UVWwR(1)^2); %Magnitude
%RelativeWind.VwRxy = sqrt(UVWwR(2)^2+UVWwR(1)^2); %Magnitude

RelativeWind.AlphawR = atan2(UVWwR(3),UVWwR(1)); %Orientation
RelativeWind.BetawR =  asin2(UVWwR(2),RelativeWind.VwR); %Orientation

%Left Wing

UVWwL =  (RIB*RBWL)' * (dPIwL - EnvironmentWindI); %Compute the relative wind-speed vector

RelativeWind.VwL = sqrt(UVWwL(3)^2 + UVWwL(2)^2 + UVWwL(1)^2);
%RelativeWind.VwLxz = sqrt(UVWwL(3)^2+UVWwL(1)^2); %Magnitude
%RelativeWind.VwLxy = sqrt(UVWwL(2)^2+UVWwL(1)^2); %Magnitude

RelativeWind.AlphawL = atan2(UVWwL(3),UVWwL(1)); %Orientation
RelativeWind.BetawL  =  asin2(UVWwL(2),RelativeWind.VwL); %Orientation

%----------Computing Properties of Relative wind for Center of gravity---------%
 
%Right Wing
UVWCG =  RIB' * (dPICG - EnvironmentWindI); %Compute the relative wind-speed vector

RelativeWind.VCG = sqrt(UVWCG(3)^2 + UVWCG(2)^2 + UVWCG(1)^2);
%RelativeWind.VCGxz = sqrt(UVWCG(3)^2+UVWCG(1)^2); %Magnitude
%RelativeWind.VCGxy = sqrt(UVWCG(2)^2+UVWCG(1)^2); %Magnitude

RelativeWind.AlphaCG = atan2(UVWCG(3),UVWCG(1)); %Orientation
RelativeWind.BetaCG =  asin2(UVWCG(2),RelativeWind.VCG); %Orientation

%----------Computing Properties of Relative wind for V-tail---------%

%Right tail
UVWtR = RIB' * (dPItR - EnvironmentWindI); %Compute the relative wind-speed vector

RelativeWind.VtR = sqrt(UVWtR(3)^2 + UVWtR(2)^2 + UVWtR(1)^2);
%RelativeWind.VtRxz = sqrt(UVWtR(3)^2+UVWtR(1)^2); %Magnitude
%RelativeWind.VtRxy = sqrt(UVWtR(2)^2+UVWtR(1)^2); %Magnitude

RelativeWind.AlphatR = atan2(UVWtR(3),UVWtR(1)); %Orientation
RelativeWind.BetatR =  asin2(UVWtR(2),RelativeWind.VtR); %Orientation

%left tail
UVWtL = RIB' * (dPItL - EnvironmentWindI); %Compute the relative wind-speed vector

RelativeWind.VtL = sqrt(UVWtL(3)^2 + UVWtL(2)^2 + UVWtL(1)^2); %Magnitude
%RelativeWind.VtLxz = sqrt(UVWtL(3)^2+UVWtL(1)^2); %Magnitude
%RelativeWind.VtLxy = sqrt(UVWtL(2)^2+UVWtL(1)^2); %Magnitude

RelativeWind.AlphatL = atan2(UVWtL(3),UVWtL(1)); %Orientation
RelativeWind.BetatL =  asin2(UVWtL(2),RelativeWind.VtL); %Orientation

%right and left thruster group
UVWpR = (RIB*RBR)' * (dPIpR - EnvironmentWindI);
RelativeWind.VpRxz = sqrt(UVWpR(3)^2 + UVWpR(2)^2+UVWpR(1)^2);
RelativeWind.AlphapR = acos2(UVWpR(3),RelativeWind.VpRxz);

%right and left thruster group
UVWpL = (RIB*RBL)' * (dPIpL - EnvironmentWindI);
RelativeWind.VpLxz = sqrt(UVWpL(3)^2+UVWpL(2)^2+UVWpL(1)^2);
RelativeWind.AlphapL = acos2(UVWpL(3),RelativeWind.VpLxz);

end

