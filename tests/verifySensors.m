%VERIFYSENSORS Checks for the synthetic measurement model and generator.
testRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(testRoot);
cfg = setupProject();
sensors = sensorConfig(cfg.Ts);
xEq = cfg.x_eq;
wind0 = zeros(3,1);

% Equilibrium: zero rates, specific force tilted by theta, exact states.
h = measurementModel(xEq,cfg.u_eq,wind0,sensors);
assert(max(abs(h(1:3))) < 1e-12,'Gyro is not zero at hover.');
assert(max(abs(h(4:6)-[-1.340;0;9.708])) < 1e-3,'Unexpected hover specific force.');
assert(abs(norm(h(7:9))-norm(sensors.m_I)) < 1e-15,'Magnetometer changed field norm.');
assert(isequal(h(10:16),xEq([6 7 8 1 2 9 10])),'Direct channels do not match states.');

% Gyro: identity at zero roll/pitch and independent W_eta elsewhere.
x = xEq;
x(3:4) = 0;
x(11:13) = [0.1;-0.2;0.3];
h = measurementModel(x,cfg.u_eq,wind0,sensors);
assert(max(abs(h(1:3)-x(11:13))) < 1e-15,'W_eta is not identity at zero attitude.');
x(3:5) = [0.2;-0.15;0.7];
ph = x(3);
th = x(4);
omega = [x(11)-sin(th)*x(13);
    cos(ph)*x(12)+sin(ph)*cos(th)*x(13);
    -sin(ph)*x(12)+cos(ph)*cos(th)*x(13)];
h = measurementModel(x,cfg.u_eq,wind0,sensors);
assert(max(abs(h(1:3)-omega)) < 1e-15,'Gyro does not match W_eta*deta.');

% Accelerometer: plant acceleration matches the ode1 velocity increments.
x0 = xEq;
x0(3) = x0(3)+deg2rad(1);
sim1 = simulateHover(Duration=1,InitialState=x0,SaveResults=false);
maxErr = 0;
for k = 1:numel(sim1.t)-1
    qdd = TiltRotor4dot0Trim_Hover([sim1.x_true(k,:)';sim1.u(k,:)';sim1.wind(k,:)']);
    fd = (sim1.x_true(k+1,14:16)-sim1.x_true(k,14:16))'/cfg.Ts;
    maxErr = max(maxErr,max(abs(qdd(6:8)-fd)));
end
assert(maxErr < 1e-6,'Plant acceleration disagrees with logged velocities (%g).',maxErr);

% Rates, NaN pattern and noise statistics on a constant 100 s trajectory.
N = 25001;
synthetic = struct('t',(0:N-1)'*cfg.Ts,'x_true',repmat(xEq',N,1), ...
    'u',repmat(cfg.u_eq',N,1),'wind',zeros(N,3),'Ts',cfg.Ts);
meas = generateMeasurements(synthetic,Seed=7,SaveResults=false);
expectedCount = [repmat(25001,6,1);repmat(5001,3,1);1001;1001;5001;repmat(25001,4,1)];
assert(isequal(sum(meas.available)',expectedCount),'Unexpected sample counts.');
assert(all(meas.available(1,:)),'All channels must be available at t = 0.');
assert(isequal(isnan(meas.y),~meas.available),'NaN pattern differs from mask.');
assert(all(isfinite(meas.y_clean),'all'),'Clean measurements must be finite.');
for c = 1:16
    e = meas.y(meas.available(:,c),c)-meas.y_clean(meas.available(:,c),c);
    n = numel(e);
    s = sensors.sigma(c);
    assert(abs(mean(e)) < 4*s/sqrt(n),'Channel %d noise mean is biased.',c);
    assert(abs(std(e)/s-1) < 0.1,'Channel %d noise std is off.',c);
end

% Reproducibility without touching the global generator.
rng(123);
before = rng;
again = generateMeasurements(synthetic,Seed=7,SaveResults=false);
assert(isequal(rng,before),'Global rng state was modified.');
assert(isequaln(again.y,meas.y),'Same seed did not reproduce measurements.');
other = generateMeasurements(synthetic,Seed=8,SaveResults=false);
assert(~isequaln(other.y,meas.y),'Different seeds produced identical noise.');
fprintf('PASS: hover measurements, gyro mapping, accelerometer timing, rates, noise and seeding.\n');
