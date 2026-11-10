%VERIFYATTITUDEEKF Checks for the generated attitude models and the attitude EKF.
testRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(testRoot);
cfg = setupProject();
sensors = sensorConfig(cfg.Ts);

% Generated measurement model matches measurementModel at hover (xi_dd ~ 1e-8
% from the trim residual).
x = cfg.x_eq;
hFull = measurementModel(x,cfg.u_eq,zeros(3,1),sensors);
h = attitudeMeasurement(x(3:5),sensors.g_I,sensors.m_I);
assert(max(abs(h(1:3)-hFull(4:6))) < 1e-6,'Accelerometer model differs at hover.');
assert(max(abs(h(4:6)-hFull(7:9))) < 1e-18,'Magnetometer model differs at hover.');
x(3:5) = [0.3;-0.2;1.1];
hFull = measurementModel(x,cfg.u_eq,zeros(3,1),sensors);
h = attitudeMeasurement(x(3:5),sensors.g_I,sensors.m_I);
assert(max(abs(h(4:6)-hFull(7:9))) < 1e-18,'Magnetometer model differs off hover.');

% Symbolic Jacobians against central differences.
stream = RandStream('mt19937ar','Seed',3);
for trial = 1:20
    eta = [0.6;0.6;pi].*(2*rand(stream,3,1)-1);
    omega = 2*rand(stream,3,1)-1;
    [~,F,G] = attitudeProcess(eta,omega,cfg.Ts);
    [~,H] = attitudeMeasurement(eta,sensors.g_I,sensors.m_I);
    Fn = zeros(3); Gn = zeros(3); Hn = zeros(6,3);
    step = 1e-6;
    for j = 1:3
        e = zeros(3,1); e(j) = step;
        Fn(:,j) = (attitudeProcess(eta+e,omega,cfg.Ts)-attitudeProcess(eta-e,omega,cfg.Ts))/(2*step);
        Gn(:,j) = (attitudeProcess(eta,omega+e,cfg.Ts)-attitudeProcess(eta,omega-e,cfg.Ts))/(2*step);
        Hn(:,j) = (attitudeMeasurement(eta+e,sensors.g_I,sensors.m_I) ...
            -attitudeMeasurement(eta-e,sensors.g_I,sensors.m_I))/(2*step);
    end
    assert(max(abs(F-Fn),[],'all') < 1e-8,'F differs from finite differences.');
    assert(max(abs(G-Gn),[],'all') < 1e-8,'G differs from finite differences.');
    assert(max(abs(H(1:3,:)-Hn(1:3,:)),[],'all') < 1e-6,'H_acc differs from finite differences.');
    assert(max(abs(H(4:6,:)-Hn(4:6,:)),[],'all') < 1e-12,'H_mag differs from finite differences.');
end

% Noise-free gyro reproduces the true attitude with the plant's Euler rule.
data = load(fullfile(testRoot,'results','helix.mat'));
result = data.result;
meas = generateMeasurements(result,Seed=1,SaveResults=false);
eta = result.x_true(1,3:5)';
drift = 0;
for k = 1:numel(result.t)-1
    eta = attitudeProcess(eta,meas.y_clean(k,1:3)',cfg.Ts);
    drift = max(drift,max(abs(eta-result.x_true(k+1,3:5)')));
end
assert(drift < 1e-9,'Gyro integration does not reproduce the true attitude.');

% Filter on the helix: converges from the initial error and stays consistent.
est = ekfAttitude(result,meas);
settled = est.t >= 5;
rmseSettled = rad2deg(sqrt(mean(est.err(settled,:).^2,1)));
inside = mean(abs(est.err) <= 3*est.sigma,1);
assert(all(isfinite(est.x_hat),'all') && all(isfinite(est.P),'all'));
assert(all(rmseSettled < [0.5 0.5 0.5]),'Attitude RMSE after 5 s too large.');
assert(all(inside > 0.9),'Errors leave the 3-sigma envelope too often.');
fprintf(['PASS: attitude models, symbolic Jacobians, gyro integration and EKF ' ...
    '(RMSE after 5 s [deg]: %.3f %.3f %.3f).\n'],rmseSettled);
