%VERIFYHOVER Integration checks against the actual nonlinear Simulink model.
testRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(testRoot);
cfg = setupProject();
rejected = false;
try
    validateHoverGain(cfg,load(fullfile(testRoot,'controller','HINF_LMI_GAINS.txt'))');
catch failure
    assert(strcmp(failure.identifier,'tiltrotor:UnstableGain'));
    rejected = true;
end
assert(rejected,'Continuous gain was incorrectly accepted for Euler integration.');
equilibrium = simulateHover(Duration=1,SaveResults=false);
assert(max(abs(equilibrium.x_true-cfg.x_eq'),[],'all') < 1e-5, ...
    'Hover did not stay near the saved equilibrium.');
x0 = cfg.x_eq;
x0(3) = x0(3)+deg2rad(1);
perturbed = simulateHover(Duration=10,InitialState=x0,SaveResults=false);
assert(norm(perturbed.x_true(end,:)-cfg.x_eq') < norm(x0-cfg.x_eq), ...
    'Small roll perturbation did not decay within 10 seconds.');
assert(all(perturbed.u(:,1:2) >= 0 & perturbed.u(:,1:2) <= 100,'all'));
assert(all(abs(perturbed.u(:,3:4)) <= 10,'all'));
windCase = simulateHover(Duration=12,OriginalWind=true,SaveResults=false);
assert(all(windCase.wind(windCase.t<10,:) == 0,'all'));
assert(all(windCase.wind(windCase.t>=10,1) == 5));
assert(all(windCase.wind(:,2:3) == 0,'all'));
fprintf('PASS: gain rejection, equilibrium, roll recovery, timestamps, actuator limits and original wind steps.\n');
