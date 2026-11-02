function meas = generateMeasurements(result, options)
%GENERATEMEASUREMENTS Offline synthetic measurements from a hover result.
% meas = generateMeasurements(result, Seed=1, SaveResults=true)
% y(k,:) = h(x_true(k), u(k), wind(k)) + v(k), v ~ N(0,R), with NaN where the
% channel has no new sample at t(k). available marks the new samples.
arguments
    result (1,1) struct
    options.Seed (1,1) double {mustBeInteger,mustBeNonnegative} = 1
    options.SaveResults (1,1) logical = true
end
sensors = sensorConfig(result.Ts);
N = numel(result.t);
yClean = zeros(N,16);
for k = 1:N
    yClean(k,:) = measurementModel(result.x_true(k,:)',result.u(k,:)', ...
        result.wind(k,:)',sensors)';
end
assert(all(isfinite(yClean),'all'), ...
    'tiltrotor:NonfiniteMeasurement','Measurement model produced NaN or Inf.');
stream = RandStream('mt19937ar','Seed',options.Seed);
noise = randn(stream,N,16).*sensors.sigma';
available = mod((0:N-1)',sensors.decimation') == 0;
y = yClean+noise;
y(~available) = NaN;
meas.t = result.t;
meas.y = y;
meas.available = available;
meas.y_clean = yClean;
meas.noise = noise;
meas.seed = options.Seed;
meas.sensors = sensors;
meas.channelNames = sensors.channelNames;
meas.channelUnits = sensors.channelUnits;
if options.SaveResults
    resultDir = fullfile(fileparts(fileparts(mfilename('fullpath'))),'results');
    if ~isfolder(resultDir), mkdir(resultDir); end
    save(fullfile(resultDir,'measurements.mat'),'meas');
end
end
