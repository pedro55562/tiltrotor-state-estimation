%RUNATTITUDEEKF Attitude-only EKF on the helix trajectory (nominal, no GPS outage).
% Needs results/helix.mat (run experiments/runHelix.m). Saves figures to
% results/figures/ekf/.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);
setupProject();
data = load(fullfile(root,'results','helix.mat'));
meas = generateMeasurements(data.result,Seed=1,SaveResults=false);
est = ekfAttitude(data.result,meas);
plotAttitudeEKF(est,OutputDir=fullfile(root,'results','figures','ekf'),Visible=false);
fprintf('Attitude EKF RMSE [deg]: phi %.3f, theta %.3f, psi %.3f; mean NEES %.2f\n', ...
    rad2deg(est.rmse),est.neesMean);
