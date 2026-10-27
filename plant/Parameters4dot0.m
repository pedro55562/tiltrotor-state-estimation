function [ Parameters ] = Parameters4dot0( )

%Par�metos do Tiltrotor
%global Parameters

Parameters.Ixx1 = 2.727;
Parameters.Iyy1 = 7.447;
Parameters.Izz1 = 9.95;
Parameters.Ixz1 = -0.002;

%tensores de in�rcia dos servos
Parameters.Ixx2 = 0.005;
Parameters.Iyy2 = 0.005;
Parameters.Izz2 = 0.002;
Parameters.Ixx3 = 0.005;
Parameters.Iyy3 = 0.005;
Parameters.Izz3 = 0.002;

%�ngulo de inclina��o dos servos em graus
Parameters.B = deg2rad(5);
Parameters.BW = deg2rad(0);
Parameters.BT = deg2rad(30);


%m�dulo da gravidade
Parameters.g = 9.8;
Parameters.v = 0.005;

%massas
Parameters.M1 = 7;
Parameters.M2 = 0.3;
Parameters.M3 = 0.3;

TranslateBodyFrameX = -0.65;
TranslateBodyFrameZ = -0.12;
TranslateBodyFrame = [TranslateBodyFrameX; 0; TranslateBodyFrameZ];

%posi��o dos centros de massa com rela��o ao frame do corpo
Parameters.XB1 = -0.6;
Parameters.YB1 = 0;
Parameters.ZB1 = 0;

Parameters.XB1 = Parameters.XB1 - TranslateBodyFrameX;
Parameters.ZB1 = Parameters.ZB1 - TranslateBodyFrameZ;

Parameters.DBc1 = [Parameters.XB1; Parameters.YB1; Parameters.ZB1];


%aR
Parameters.XB2 = -0.62;
Parameters.YB2 = -1.025;
Parameters.ZB2 = 0.172;

Parameters.XB2 = Parameters.XB2 - TranslateBodyFrameX;
Parameters.ZB2 = Parameters.ZB2 - TranslateBodyFrameZ;

Parameters.DBA2 = [Parameters.XB2; Parameters.YB2; Parameters.ZB2];

%aL
Parameters.XB3 = -0.62;
Parameters.YB3 = 1.025;
Parameters.ZB3 = 0.172;

Parameters.XB3 = Parameters.XB3 - TranslateBodyFrameX;
Parameters.ZB3 = Parameters.ZB3 - TranslateBodyFrameZ;

Parameters.DBA3 = [Parameters.XB3; Parameters.YB3; Parameters.ZB3];

%deslocamento dos servos com rela��o ao eixo de rota��o
Parameters.ds = 0.07;
Parameters.dp = 0.1;
Parameters.DA2C2 = [0; 0; Parameters.ds];
Parameters.DA3C3 = [0; 0; Parameters.ds];
Parameters.DA2P2 = [0; 0; Parameters.dp];
Parameters.DA3P3 = [0; 0; Parameters.dp];


%thruster group parameters
Parameters.DiameterPropeller = 24*(0.0254); %converting from inches to meters
Parameters.WingSpan = 1.7835;
Parameters.MeanGeometricChord = 0.1366; 

%aerodynamic parameters
Parameters.Ho = 1.21;

%Position of the aerodynamic centers
Parameters.DBf  = [ -0.454;       0;     0];
Parameters.DBwR = [ -0.644;  -0.465; 0.1420];
Parameters.DBwL = [ -0.644;   0.465; 0.1420];
Parameters.DBtR = [-1.1323; -0.2952;  0.2332];
Parameters.DBtL = [-1.1323;  0.2952;  0.2332];

Parameters.DBf  = Parameters.DBf  - TranslateBodyFrame;
Parameters.DBwR = Parameters.DBwR - TranslateBodyFrame;
Parameters.DBwL = Parameters.DBwL - TranslateBodyFrame;
Parameters.DBtR = Parameters.DBtR - TranslateBodyFrame;
Parameters.DBtL = Parameters.DBtL - TranslateBodyFrame;

Parameters.Sw = 0.25/2; 

end

