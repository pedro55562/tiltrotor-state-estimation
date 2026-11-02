function sensors = sensorConfig(Ts)
%SENSORCONFIG Synthetic sensor parameters in the channel order of eq. (24).
% sensors = sensorConfig(Ts) returns names, units, noise standard deviations,
% sample decimation w.r.t. Ts, R = diag(sigma.^2), gravity and magnetic field.
arguments
    Ts (1,1) double {mustBePositive}
end
sensors.channelNames = {'gyro_x','gyro_y','gyro_z','acc_x','acc_y','acc_z', ...
    'mag_x','mag_y','mag_z','gps_x','gps_y','baro_z', ...
    'alpha_R','alpha_L','dalpha_R','dalpha_L'};
sensors.channelUnits = [repmat({'rad/s'},1,3),repmat({'m/s^2'},1,3), ...
    repmat({'T'},1,3),repmat({'m'},1,3),{'rad','rad','rad/s','rad/s'}];
sensors.sigma = [repmat(0.005,3,1);repmat(0.05,3,1);repmat(5e-7,3,1); ...
    1.0;1.0;0.2;0.002;0.002;0.02;0.02];
sensors.rateHz = [repmat(250,6,1);repmat(50,3,1);10;10;50;repmat(250,4,1)];
sensors.decimation = round(1./(sensors.rateHz*Ts));
assert(all(abs(sensors.decimation*Ts-1./sensors.rateHz) < 1e-12), ...
    'tiltrotor:SensorRate','Sensor rates must be integer divisors of 1/Ts.');
sensors.R = diag(sensors.sigma.^2);
sensors.g_I = [0;0;-9.8];
% Approximate Belo Horizonte field (|m| ~ 23 uT, inclination ~ -36 deg),
% x toward magnetic north, z up: the field points upward in Brazil.
sensors.m_I = [18.6;0;13.5]*1e-6;
end
