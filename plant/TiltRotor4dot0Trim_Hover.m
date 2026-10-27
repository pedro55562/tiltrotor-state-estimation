function [ qpp ] = TiltRotor4dot0Trim_Hover( Input )

    q = Input(1:8); % q = AlphaR AlphaL Phi Theta Psi x y z
    qp = Input(9:16);
    ControlInputs = Input(17:20);
    EnvironmentWindI = Input(21:23);

    RPS = ControlInputs(1:2); %[RPSR, RPSL]
    Torques = ControlInputs(3:4); %[tau_R, tau_L]
    AerodynamicControlerSurfaces = zeros(1,4);
    
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

