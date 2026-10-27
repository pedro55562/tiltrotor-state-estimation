function [ GeneralizedForcesAerodynamics ] = GetGeneralizedForcesAerodynamics( q, Parameters, RelativeWind, AerodynamicControlerSurfaces )

Phi = q(3);
Theta = q(4);
Psi = q(5);

DaR = AerodynamicControlerSurfaces(1);
DaL = AerodynamicControlerSurfaces(2);
De = AerodynamicControlerSurfaces(3);
Dr = AerodynamicControlerSurfaces(4);

[ AeroCoefficients ] = GetCoefV2( RelativeWind );

RIB = rotz(Psi)*roty(Theta)*rotx(Phi);
   
Wn = [1,            0,             -sin(Theta);
      0,          cos(Phi),    sin(Phi)*cos(Theta);
      0,         -sin(Phi),    cos(Phi)*cos(Theta)];   

Jvf    = [zeros(3,2) -RIB*SkewSymmetricMatrix(  Parameters.DBf )*Wn eye(3)]; 
JvwR  = [zeros(3,2) -RIB*SkewSymmetricMatrix( Parameters.DBwR )*Wn eye(3)];
JvwL  = [zeros(3,2) -RIB*SkewSymmetricMatrix( Parameters.DBwL )*Wn eye(3)];
JvtR  = [zeros(3,2) -RIB*SkewSymmetricMatrix( Parameters.DBtR )*Wn eye(3)];
JvtL  = [zeros(3,2) -RIB*SkewSymmetricMatrix( Parameters.DBtL )*Wn eye(3)];
Jvcg  = [zeros(3,2) -RIB*SkewSymmetricMatrix( Parameters.DBc1 )*Wn eye(3)];

Jw = [zeros(3,2) RIB*Wn zeros(3,3)];


%Rotation matrix Wind frame Fuselage
RBFw = roty(-RelativeWind.Alphaf)*rotz(-RelativeWind.Betaf);

%Rotation Matrix wind frame Wing
RBwRw = roty(-RelativeWind.AlphawR)*rotz(-RelativeWind.BetawR);
RBwLw = roty(-RelativeWind.AlphawL)*rotz(-RelativeWind.BetawL);

%Rotation Matrix wind frame Tail
RBtRw = roty(-RelativeWind.AlphatR)*rotz(-RelativeWind.BetatR);
RBtLw = roty(-RelativeWind.AlphatL)*rotz(-RelativeWind.BetatL);

%interference
RBcGw = roty(-RelativeWind.AlphaCG)*rotz(-RelativeWind.BetaCG);

%dynamic pressure
kf  = (1/2) * Parameters.Ho * Parameters.Sw * (RelativeWind.Vf^2);
kwR = (1/2) * Parameters.Ho * Parameters.Sw * (RelativeWind.VwR^2);
kwL = (1/2) * Parameters.Ho * Parameters.Sw * (RelativeWind.VwL^2);
ktR = (1/2) * Parameters.Ho * Parameters.Sw * (RelativeWind.VtR^2);
ktL = (1/2) * Parameters.Ho * Parameters.Sw * (RelativeWind.VtL^2);
kcG = (1/2) * Parameters.Ho * Parameters.Sw * (RelativeWind.VCG^2);

%---Computing the vector of generalized forces applied by the Fuselage-----
FFuselage = Jvf' * RIB * RBFw * (kf*[-(AeroCoefficients.CDfxy+AeroCoefficients.CDfxz); AeroCoefficients.CYfxy; AeroCoefficients.CLfxz]);

FWings = JvwR' * RIB * RBwRw * ( kwR*[-(AeroCoefficients.CDwRxy+AeroCoefficients.CDwRxz); AeroCoefficients.CYwRxy; AeroCoefficients.CLwRxz + AeroCoefficients.Cla*DaR]) ...
       + JvwL' * RIB * RBwLw * ( kwL*[-(AeroCoefficients.CDwLxy+AeroCoefficients.CDwLxz); AeroCoefficients.CYwLxy; AeroCoefficients.CLwLxz + AeroCoefficients.Cla*DaL]);

FVTail =  JvtR' * RIB * RBtRw * ( ktR*[-(AeroCoefficients.CDtRxy+AeroCoefficients.CDtRxz); AeroCoefficients.CYtRxy + AeroCoefficients.Cyr*Dr; AeroCoefficients.CLtRxz + AeroCoefficients.Cle*De]) ...
       +  JvtL' * RIB * RBtLw * ( ktL*[-(AeroCoefficients.CDtLxy+AeroCoefficients.CDtLxz); AeroCoefficients.CYtLxy + AeroCoefficients.Cyr*Dr; AeroCoefficients.CLtLxz + AeroCoefficients.Cle*De]);

AerodynamicMoments = Jw' * RIB * [0; -(kf*AeroCoefficients.CMfxz + kwR*AeroCoefficients.CMwRxz + kwL*AeroCoefficients.CMwLxz + ktR*AeroCoefficients.CMtRxz + ktL*AeroCoefficients.CMtLxz)*Parameters.MeanGeometricChord; -(kf*AeroCoefficients.CNfxy + kwR*AeroCoefficients.CNwRxy + kwL*AeroCoefficients.CNwLxy + ktR*AeroCoefficients.CNtRxy + ktL*AeroCoefficients.CNtLxy)*Parameters.WingSpan];
   
FInterference = Jvcg' * RIB * RBcGw * kcG * [-(AeroCoefficients.CDixy+AeroCoefficients.CDixz); AeroCoefficients.CYixy; AeroCoefficients.CLixz];

GeneralizedForcesAerodynamics = FFuselage + FWings + FVTail + AerodynamicMoments + FInterference;

end

