function report = validateHoverGain(design,K)
%VALIDATEHOVERGAIN Check dimensions, trim, plant Jacobian and Euler stability.
% Local compatibility does not recertify the H-infinity performance bound.
assert(isequal(size(K),[4 16]) && isreal(K) && all(isfinite(K),'all'), ...
    'tiltrotor:GainDimensions','The gain must be a finite real 4-by-16 matrix.');
assert(isequal(size(design.A),[16 16]) && isequal(size(design.B),[16 7]), ...
    'tiltrotor:DesignDimensions','Expected 16 states and 4 controls + 3 wind inputs.');
assert(design.Ts == 0.004,'tiltrotor:SampleTime','Gain validated for Ts = 0.004 s.');
x = [design.q_eq;design.qp_eq];
v = [design.u_eq;zeros(3,1)];
f = @(state,input) [state(9:16);TiltRotor4dot0Trim_Hover([state;input])];
report.trimResidual = norm(f(x,v),inf);
assert(report.trimResidual < 1e-6, ...
    'tiltrotor:TrimMismatch','Saved trim is incompatible with the nonlinear plant.');
h = 1e-5;
A = zeros(16);
B = zeros(16,7);
for k = 1:16
    delta = zeros(16,1);
    delta(k) = h;
    A(:,k) = (f(x+delta,v)-f(x-delta,v))/(2*h);
end
for k = 1:7
    delta = zeros(7,1);
    delta(k) = h;
    B(:,k) = (f(x,v+delta)-f(x,v-delta))/(2*h);
end
report.relativeAError = norm(A-design.A,'fro')/max(1,norm(design.A,'fro'));
report.relativeBError = norm(B-design.B,'fro')/max(1,norm(design.B,'fro'));
assert(max(report.relativeAError,report.relativeBError) < 1e-4, ...
    'tiltrotor:LinearizationMismatch','The nonlinear plant differs from the gain design.');
report.maxRealPole = max(real(eig(A+B(:,1:4)*K)));
report.eulerSpectralRadius = max(abs(eig(eye(16)+design.Ts*(A+B(:,1:4)*K))));
assert(report.maxRealPole < 0 && report.eulerSpectralRadius < 1, ...
    'tiltrotor:UnstableGain','Gain is unstable with u = u_eq + K*(x-x_eq) and Euler Ts.');
end
