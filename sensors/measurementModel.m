function y = measurementModel(x, u, wind, sensors)
%MEASUREMENTMODEL Noise-free measurement h(x,u) of eq. (24), 16x1.
% Channels: gyro W_eta*deta, accelerometer R_IB'*(xi_dd - g_I),
% magnetometer R_IB'*m_I, GPS [x;y], barometer z, tilt [aR;aL;daR;daL].
phi = x(3);
theta = x(4);
R_IB = rotz(x(5))*roty(theta)*rotx(phi);
W_eta = [1, 0, -sin(theta);
         0, cos(phi), sin(phi)*cos(theta);
         0, -sin(phi), cos(phi)*cos(theta)];
qdd = TiltRotor4dot0Trim_Hover([x;u;wind]);
y = [W_eta*x(11:13);
     R_IB'*(qdd(6:8)-sensors.g_I);
     R_IB'*sensors.m_I;
     x(6:8);
     x([1 2 9 10])];
end
