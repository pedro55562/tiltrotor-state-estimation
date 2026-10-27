function result = simulateHover(options)
%SIMULATEHOVER Run the original nonlinear plant and full-state H-infinity loop.
% result = simulateHover(Duration=10, InitialState=x0, SaveResults=true)
% Wind is zero by default. Original wind steps can be enabled explicitly.
arguments
    options.Duration (1,1) double {mustBePositive,mustBeFinite} = 10
    options.InitialState double = []
    options.OriginalWind (1,1) logical = false
    options.SaveResults (1,1) logical = true
end
cfg = setupProject();
assert(abs(options.Duration/cfg.Ts-round(options.Duration/cfg.Ts)) < 1e-8, ...
    'tiltrotor:DurationGrid','Duration must be a multiple of Ts = 0.004 s.');
x0 = options.InitialState;
if isempty(x0)
    x0 = cfg.x_eq;
end
validateattributes(x0,{'double'},{'real','finite','size',[16 1]});
if bdIsLoaded(cfg.model)
    assert(strcmp(get_param(cfg.model,'FileName'),cfg.modelFile), ...
        'tiltrotor:ShadowedModel','A different hover model is already loaded.');
end
in = Simulink.SimulationInput(cfg.model);
vars = struct('K_v4Hover',cfg.K,'Ts',cfg.Ts,'q0',x0(1:8),'qp0',x0(9:16), ...
    'q_eq',cfg.q_eq,'qp_eq',cfg.qp_eq,'nR_eq',cfg.u_eq(1), ...
    'nL_eq',cfg.u_eq(2),'tauR_eq',cfg.u_eq(3),'tauL_eq',cfg.u_eq(4),'enableOriginalWind',double(options.OriginalWind));
names = fieldnames(vars);
for k = 1:numel(names)
    in = in.setVariable(names{k},vars.(names{k}));
end
in = in.setModelParameter('StopTime',num2str(options.Duration,17), ...
    'ReturnWorkspaceOutputs','on','SimulationMode','normal', ...
    'SolverType','Fixed-step','Solver','ode1','FixedStep','Ts');
out = sim(in);
result.t = out.q_out.time(:);
assert(isequal(result.t,out.dq_out.time(:),out.u_real_out.time(:), ...
    out.u_nom_out.time(:),out.w_out.time(:)), ...
    'tiltrotor:LoggingTime','Logged signals have different timestamps.');
result.x_true = [out.q_out.signals.values,out.dq_out.signals.values];
result.u = out.u_real_out.signals.values;
result.u_nominal = out.u_nom_out.signals.values;
result.wind = out.w_out.signals.values;
assert(isequal(size(result.x_true),[numel(result.t),16]) && ...
    isequal(size(result.u),[numel(result.t),4]), ...
    'tiltrotor:LoggingShape','Unexpected state or input dimensions.');
assert(all(isfinite([result.t,result.x_true,result.u,result.u_nominal,result.wind]),'all'), ...
    'tiltrotor:NonfiniteSimulation','Simulation produced NaN or Inf.');
expectedTime = (0:round(options.Duration/cfg.Ts))'*cfg.Ts;
assert(isequal(size(expectedTime),size(result.t)) && ...
    max(abs(expectedTime-result.t)) < 1e-9, ...
    'tiltrotor:IncompleteSimulation','Simulation did not finish on the expected time grid.');
result.stateNames = cfg.stateNames;
result.stateUnits = cfg.stateUnits;
result.inputNames = cfg.inputNames;
result.inputUnits = cfg.inputUnits;
result.x_eq = cfg.x_eq;
result.u_eq = cfg.u_eq;
result.K = cfg.K;
result.Ts = cfg.Ts;
result.validation = cfg.validation;
result.originalWind = options.OriginalWind;
result.matlabVersion = version;
result.generatedAt = char(datetime('now','TimeZone','UTC'));
if options.SaveResults
    resultDir = fullfile(cfg.root,'results');
    if ~isfolder(resultDir), mkdir(resultDir); end
    save(fullfile(resultDir,'hover.mat'),'result');
    columns = [{'t_s'},cfg.stateNames,{'n_R','n_L','tau_R','tau_L', ...
        'n_R_nominal','n_L_nominal','tau_R_nominal','tau_L_nominal', ...
        'wind_x','wind_y','wind_z'}];
    data = array2table([result.t,result.x_true,result.u,result.u_nominal,result.wind], ...
        'VariableNames',columns);
    writetable(data,fullfile(resultDir,'hover.csv'));
end
end
