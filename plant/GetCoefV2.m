function [ AeroCoefficients ] = GetCoefV2( RelativeWind )

%Alphaf, Betaf, Alphaw, Betaw, Alphat, Betat )
 
SaturationInterval = [-1.55, 1.55];
[ Alphaf  ] = Saturation( -RelativeWind.Alphaf , SaturationInterval );
[ Betaf   ] = Saturation( -RelativeWind.Betaf  , SaturationInterval );
[ AlphawR ] = Saturation( -RelativeWind.AlphawR, SaturationInterval );
[ BetawR  ] = Saturation( -RelativeWind.BetawR , SaturationInterval );
[ AlphawL ] = Saturation( -RelativeWind.AlphawL, SaturationInterval );
[ BetawL  ] = Saturation( -RelativeWind.BetawL , SaturationInterval );
[ AlphatR ] = Saturation( -RelativeWind.AlphatR, SaturationInterval );
[ BetatR  ] = Saturation( -RelativeWind.BetatR , SaturationInterval ); 
[ AlphatL ] = Saturation( -RelativeWind.AlphatL, SaturationInterval );
[ BetatL  ] = Saturation( -RelativeWind.BetatL , SaturationInterval );
[ AlphaCG ] = Saturation( -RelativeWind.AlphaCG, SaturationInterval );
[ BetatCG ] = Saturation( -RelativeWind.BetaCG , SaturationInterval );


global VetCLw VetCLt VetCLf VetCDwxz VetCDtxz VetCDfxz VetCYw VetCYt VetCYf VetCDwxy ...
       VetCDtxy VetCDfxy VetCLi VetCDixz VetCMi VetCYi VetCDixy VetCNi VetCMw VetCMt ...
       VetCMf VetCNw VetCNt VetCNf

DeltaCoefRad = deg2rad(0.5);

%Data for Linear Interpolation
Valfa = ((Alphaf+pi/2)/DeltaCoefRad)+1;
Indexfa = floor(Valfa);
Proporcaofa = Valfa - Indexfa;

Valfs = ((Betaf+pi/2)/DeltaCoefRad)+1;
Indexfs = floor(Valfs);
Proporcaofs = Valfs - Indexfs;

%Interpolating data from table | Computing the fuselage coeficients
AeroCoefficients.CDfxz  = VetCDfxz(Indexfa) + Proporcaofa*(VetCDfxz(Indexfa+1) - VetCDfxz(Indexfa));
AeroCoefficients.CLfxz  =   VetCLf(Indexfa) + Proporcaofa*  (VetCLf(Indexfa+1) -   VetCLf(Indexfa));
AeroCoefficients.CMfxz  =   VetCMf(Indexfa) + Proporcaofa*  (VetCMf(Indexfa+1) -   VetCMf(Indexfa));

AeroCoefficients.CDfxy  = VetCDfxy(Indexfs) + Proporcaofs*(VetCDfxy(Indexfs+1) - VetCDfxy(Indexfs));
AeroCoefficients.CYfxy  =   VetCYf(Indexfs) + Proporcaofs*  (VetCYf(Indexfs+1) -   VetCYf(Indexfs));  
AeroCoefficients.CNfxy  =   VetCNf(Indexfs) + Proporcaofs*  (VetCNf(Indexfs+1) -   VetCNf(Indexfs));  

%Interpolating data from table | Computing the right wing coeficients
Valwa = ((AlphawR+pi/2)/DeltaCoefRad)+1;
Indexwa = floor(Valwa);
Proporcaowa = Valwa - Indexwa;
Valws = ((BetawR+pi/2)/DeltaCoefRad)+1;
Indexws = floor(Valws);
Proporcaows = Valws - Indexws;

AeroCoefficients.CDwRxz = VetCDwxz(Indexwa) + Proporcaowa*(VetCDwxz(Indexwa+1) - VetCDwxz(Indexwa));
AeroCoefficients.CLwRxz =   VetCLw(Indexwa) + Proporcaowa*  (VetCLw(Indexwa+1) -   VetCLw(Indexwa)); 
AeroCoefficients.CMwRxz =   VetCMw(Indexwa) + Proporcaowa*  (VetCMw(Indexwa+1) -   VetCMw(Indexwa)); 

AeroCoefficients.CDwRxy = VetCDwxy(Indexws) + Proporcaows*(VetCDwxy(Indexws+1) - VetCDwxy(Indexws));
AeroCoefficients.CYwRxy =   VetCYw(Indexws) + Proporcaows*  (VetCYw(Indexws+1) -   VetCYw(Indexws));  
AeroCoefficients.CNwRxy =   VetCNw(Indexws) + Proporcaows*  (VetCNw(Indexws+1) -   VetCNw(Indexws));  

%Interpolating data from table | Computing the left wing coeficients
Valwa = ((AlphawL+pi/2)/DeltaCoefRad)+1;
Indexwa = floor(Valwa);
Proporcaowa = Valwa - Indexwa;
Valws = ((BetawL+pi/2)/DeltaCoefRad)+1;
Indexws = floor(Valws);
Proporcaows = Valws - Indexws;

AeroCoefficients.CDwLxz = VetCDwxz(Indexwa) + Proporcaowa*(VetCDwxz(Indexwa+1) - VetCDwxz(Indexwa));
AeroCoefficients.CLwLxz =   VetCLw(Indexwa) + Proporcaowa*  (VetCLw(Indexwa+1) -   VetCLw(Indexwa)); 
AeroCoefficients.CMwLxz =   VetCMw(Indexwa) + Proporcaowa*  (VetCMw(Indexwa+1) -   VetCMw(Indexwa)); 


AeroCoefficients.CDwLxy = VetCDwxy(Indexws) + Proporcaows*(VetCDwxy(Indexws+1) - VetCDwxy(Indexws));
AeroCoefficients.CYwLxy =   VetCYw(Indexws) + Proporcaows*  (VetCYw(Indexws+1) -   VetCYw(Indexws));  
AeroCoefficients.CNwLxy =   VetCNw(Indexws) + Proporcaows*  (VetCNw(Indexws+1) -   VetCNw(Indexws));  

%Interpolating data from table | Computing the right tail coeficients
Valta = ((AlphatR+pi/2)/DeltaCoefRad)+1;
Indexta = floor(Valta);
Proporcaota = Valta - Indexta;
Valts = (( BetatR+pi/2)/DeltaCoefRad)+1;
Indexts = floor(Valts);
Proporcaots = Valts - Indexts;

AeroCoefficients.CDtRxz = VetCDtxz(Indexta) + Proporcaota*(VetCDtxz(Indexta+1) - VetCDtxz(Indexta));
AeroCoefficients.CLtRxz =   VetCLt(Indexta) + Proporcaota*  (VetCLt(Indexta+1) -   VetCLt(Indexta));
AeroCoefficients.CMtRxz =   VetCMt(Indexta) + Proporcaota*  (VetCMt(Indexta+1) -   VetCMt(Indexta)); 

AeroCoefficients.CDtRxy = VetCDtxy(Indexts) + Proporcaots*(VetCDtxy(Indexts+1) - VetCDtxy(Indexts));
AeroCoefficients.CYtRxy =   VetCYt(Indexts) + Proporcaots*  (VetCYt(Indexts+1) -   VetCYt(Indexts));  
AeroCoefficients.CNtRxy =   VetCNt(Indexts) + Proporcaots*  (VetCNt(Indexts+1) -   VetCNt(Indexts));  

%Interpolating data from table | Computing the left tail coeficients
Valta = ((AlphatL+pi/2)/DeltaCoefRad)+1;
Indexta = floor(Valta);
Proporcaota = Valta - Indexta;
Valts = ((BetatL+pi/2)/DeltaCoefRad)+1;
Indexts = floor(Valts);
Proporcaots = Valts - Indexts;
  
AeroCoefficients.CDtLxz = VetCDtxz(Indexta) + Proporcaota*(VetCDtxz(Indexta+1) - VetCDtxz(Indexta));
AeroCoefficients.CLtLxz =   VetCLt(Indexta) + Proporcaota*  (VetCLt(Indexta+1) -   VetCLt(Indexta));
AeroCoefficients.CMtLxz =   VetCMt(Indexta) + Proporcaota*  (VetCMt(Indexta+1) -   VetCMt(Indexta)); 

AeroCoefficients.CDtLxy = VetCDtxy(Indexts) + Proporcaots*(VetCDtxy(Indexts+1) - VetCDtxy(Indexts));
AeroCoefficients.CYtLxy =   VetCYt(Indexts) + Proporcaots*  (VetCYt(Indexts+1) -   VetCYt(Indexts));  
AeroCoefficients.CNtLxy =   VetCNt(Indexts) + Proporcaots*  (VetCNt(Indexts+1) -   VetCNt(Indexts));

%Interpolating data from table | Computing the interference coeficients 

Valia = ((AlphaCG+pi/2)/DeltaCoefRad)+1;
Indexia = floor(Valia);
Proporcaoia = Valia - Indexia;
Valis = ((BetatCG+pi/2)/DeltaCoefRad)+1;
Indexis = floor(Valis);
Proporcaois = Valis - Indexis;

AeroCoefficients.CDixz = VetCDixz(Indexia) + Proporcaoia*(VetCDixz(Indexia+1) - VetCDixz(Indexia));
AeroCoefficients.CLixz =   VetCLi(Indexia) + Proporcaoia*  (VetCLi(Indexia+1) -   VetCLi(Indexia));
AeroCoefficients.CMixz =   VetCMi(Indexia) + Proporcaoia*  (VetCMi(Indexia+1) -   VetCMi(Indexia));

AeroCoefficients.CDixy = VetCDixy(Indexis) + Proporcaois*(VetCDixy(Indexis+1) - VetCDixy(Indexis));
AeroCoefficients.CYixy =   VetCYi(Indexis) + Proporcaois*  (VetCYi(Indexis+1) -   VetCYi(Indexis));  
AeroCoefficients.CNixy =   VetCNi(Indexis) + Proporcaois*  (VetCNi(Indexis+1) -   VetCNi(Indexis)); 

AeroCoefficients.Cla = 0.7104;
AeroCoefficients.Cle = 0.3759;
AeroCoefficients.Cyr = -0.0730;
AeroCoefficients.Clf = 0.6674;
end

