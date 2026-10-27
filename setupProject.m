function cfg = setupProject()
%SETUPPROJECT Configure explicit paths and validate the existing hover gain.
root = fileparts(mfilename('fullpath'));
folders = {'plant','controller','simulation','sensors', ...
    fullfile('filters','ekf'),fullfile('filters','ukf_scaled'),'experiments','tests'};
addpath(root);
for k = 1:numel(folders)
    addpath(fullfile(root,folders{k}));
end
assert(exist('Simulink.SimulationInput','class') == 8, ...
    'tiltrotor:MissingSimulink','MATLAB and Simulink are required.');
assert(strcmp(which('TiltRotor4dot0Trim_Hover'), ...
    fullfile(root,'plant','TiltRotor4dot0Trim_Hover.m')), ...
    'tiltrotor:ShadowedPlant','Another plant is shadowing this project.');
StartParameters;
cfg = load(fullfile(root,'controller','hoverDesign.mat'));
cfg.root = root;
cfg.model = 'hover';
cfg.modelFile = fullfile(root,'simulation','hover.slx');
cfg.gainFile = fullfile(root,'controller','LMI_GAINS_D.txt');
cfg.K = load(cfg.gainFile);
cfg.validation = validateHoverGain(cfg,cfg.K);
cfg.x_eq = [cfg.q_eq;cfg.qp_eq];
cfg.stateNames = {'alpha_R','alpha_L','phi','theta','psi','x','y','z', ...
    'dalpha_R','dalpha_L','dphi','dtheta','dpsi','dx','dy','dz'};
cfg.stateUnits = [repmat({'rad'},1,5),repmat({'m'},1,3), ...
    repmat({'rad/s'},1,5),repmat({'m/s'},1,3)];
cfg.inputNames = {'n_R','n_L','tau_R','tau_L'};
cfg.inputUnits = {'rev/s','rev/s','N*m','N*m'};
end
