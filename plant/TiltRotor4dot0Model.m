function [ qpp ] = TiltRotor4dot0Model( Input )
    
    q = Input(1:8);
    qp = Input(9:16);
    EnvironmentWindI = Input(17:19);
    RPS = Input(20:21); %[RPSR, RPSL]
    Torques = Input(22:23); %[tau_R, tau_L]
    AerodynamicControlerSurfaces = Input(24:27);
    
    [ Parameters ] = Parameters4dot0( );
    [ M, C, G ] = GetTiltRotorMatrices( q, qp, Parameters );
    
    [ GeneralizedForcesServomotors ] = GetGeneralizedForcesServomotors(q, qp, Torques, Parameters );
    %aerodynamics
    [ RelativeWind ] = GetWindProperties( q, qp, Parameters, EnvironmentWindI );
    [ GeneralizedForcesThrusters ] = GetGeneralizedForcesThrusters( q, Parameters, RelativeWind, RPS );
    [ GeneralizedForcesAerodynamics ] = GetGeneralizedForcesAerodynamics( q, Parameters, RelativeWind, AerodynamicControlerSurfaces );
    
    
    GeralizedForces = GeneralizedForcesThrusters + GeneralizedForcesServomotors + GeneralizedForcesAerodynamics;
    qpp = M\(GeralizedForces - C*qp - G);
    
end

